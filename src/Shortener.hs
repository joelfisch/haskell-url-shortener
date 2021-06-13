{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}

module Shortener
  ( startApp,
    app,
  )
where

import Control.Monad.IO.Class
import Control.Monad.Logger
import Data.Aeson
import Data.Aeson.TH
import Data.Text (Text)
import qualified Data.Text as T
import Database.Persist.Sql
import Database.Persist.Sqlite
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Shortener.Data
import Shortener.Entity
import Shortener.Handler.GetLink
import Shortener.Handler.PostLink

type API =
  "shorten" :> ReqBody '[JSON] LinkForm :> Post '[JSON] Text
    :<|> Capture "shortLinkId" Text :> (Verb 'GET 302) '[JSON] (Headers '[Header "Location" Text] NoContent)

startApp :: IO ()
startApp = runStderrLoggingT $
  withSqliteConn "shortLink.sqlite3" $ \conn -> do
    runSqlConn (runMigration shortLinkMigration) conn
    liftIO $ run 8080 $ app conn

app :: SqlBackend -> Application
app conn = serve api $ server conn

api :: Proxy API
api = Proxy

server :: SqlBackend -> Server API
server conn = handlePostLink conn :<|> handleGetLink conn
