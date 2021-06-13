{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Main (main) where

import Control.Monad.Logger
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as LB
import Database.Persist.Sql (Filter, SqlBackend, deleteWhere, runMigration, runSqlConn)
import Database.Persist.Sqlite (withSqliteConn)
import Network.HTTP.Types
import qualified Network.Wai.Test as Wai
import Shortener (app)
import Shortener.Entity
import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON

postJson :: ByteString -> LB.ByteString -> WaiSession st Wai.SResponse
postJson path = request methodPost path [("Content-Type", "application/json")]

main :: IO ()
main = runNoLoggingT $
  withSqliteConn ":memory:" $ \conn -> do
    runSqlConn (runMigration shortLinkMigration) conn
    liftIO $ hspec $ before_ (clearDB conn) $ spec conn

clearDB :: SqlBackend -> IO ()
clearDB = runSqlConn $ deleteWhere ([] :: [Filter ShortLink])

spec :: SqlBackend -> Spec
spec conn = with (pure $ app conn) $ do
  describe "short links" $ do
    it "create short link and use it" $ do
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"goo\"}" `shouldRespondWith` 200
      get "/goo" `shouldRespondWith` 302 {matchHeaders = ["Location" <:> "https://google.com"]}
    it "ok on duplicate url" $ do
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"goo1\"}" `shouldRespondWith` 200
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"goo2\"}" `shouldRespondWith` 200
    it "conflict on duplicate shortId" $ do
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"goo\"}" `shouldRespondWith` 200
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"goo\"}" `shouldRespondWith` 409
    it "not found on unknown short link id" $
      get "/xyz" `shouldRespondWith` 404
    it "bad request on empty url" $
      postJson "/shorten" "{\"url\":\"\",\"shortId\":\"goo\"}" `shouldRespondWith` 400
    it "bad request on bad url" $
      postJson "/shorten" "{\"url\":\"notaurl\",\"shortId\":\"goo\"}" `shouldRespondWith` 400
    it "bad request on multiple urls" $
      postJson "/shorten" "{\"url\":\"https://google.com\nhttps://test.com\",\"shortId\":\"goo\"}" `shouldRespondWith` 400
    it "bad request on invalid shortId" $
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"@&\"}" `shouldRespondWith` 400
    it "bad request on empty shortId" $
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"\"}" `shouldRespondWith` 400
    it "conflict on duplicate shortId" $ do
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"goo\"}" `shouldRespondWith` 200
      postJson "/shorten" "{\"url\":\"https://google.com\",\"shortId\":\"goo\"}" `shouldRespondWith` 409
