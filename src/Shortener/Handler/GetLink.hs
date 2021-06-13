{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Shortener.Handler.GetLink where

import Control.Monad.IO.Class
import Data.Text (Text)
import qualified Data.Text as T
import Database.Persist
import Database.Persist.Sql
import Servant
import Shortener.DB
import Shortener.Data
import Shortener.Entity

handleGetLink :: SqlBackend -> Text -> Handler (Headers '[Header "Location" Text] NoContent)
handleGetLink conn shortId = do
  mShortLink <- runQuery conn $ getBy (UniqueShortId shortId)
  case mShortLink of
    Just (Entity _ ShortLink {..}) -> do
      pure $ addHeader shortLinkUrl NoContent
    Nothing -> throwError err404
