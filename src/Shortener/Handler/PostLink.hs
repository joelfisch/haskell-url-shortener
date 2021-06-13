{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Shortener.Handler.PostLink where

import Data.Text (Text)
import qualified Data.Text as T
import Data.Validity
import Database.Persist
import Database.Persist.Sql
import Servant
import Shortener.DB
import Shortener.Data
import Shortener.Entity

handlePostLink :: SqlBackend -> LinkForm -> Handler Text
handlePostLink conn lf@LinkForm {..} = do
  if isValid lf
    then do
      mShortLink <- runQuery conn $ getBy (UniqueShortId linkFormShortId)
      case mShortLink of
        Just _ -> throwError err409
        Nothing -> do
          runQuery conn $ insert_ $ ShortLink {shortLinkUrl = linkFormUrl, shortLinkShortId = linkFormShortId}
          pure linkFormShortId
    else throwError err400
