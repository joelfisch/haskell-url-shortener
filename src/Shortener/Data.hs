{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}

module Shortener.Data where

import Data.Aeson
import Data.Char (isAlphaNum)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Validity
import Data.Validity.Text ()
import GHC.Generics
import Text.RawString.QQ
import Text.Regex.TDFA

data LinkForm = LinkForm
  { linkFormUrl :: Text,
    linkFormShortId :: Text
  }
  deriving (Show, Eq, Ord, Generic)

-- | Note: This regular expression is debatable. It is oriented at a valid URL regex (https://rgxdb.com/r/2MQXJD5) but stripped of the scheme, user and password parts and only allows absolute URLs with protocols http and https.
urlRegex :: String
urlRegex = [r|^https?://(([a-zA-Z\d.%-]+)|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|(\[([a-fA-F\d.:]+)\]))(:(\d*))?(\/[a-zA-Z\d._~\!$&'()*+,;=:@%-]*)*(\?([a-zA-Z\d._~\!$&'()*+,;=:@%\/?-]*))?(\#([a-zA-Z\d._~\!$&'()*+,;=:@%\/?-]*))?$|]

instance Validity LinkForm where
  validate LinkForm {..} =
    mconcat
      [ check (T.unpack linkFormUrl =~ urlRegex) "The URL is valid and supported (only http and https and no user/password are supported)",
        check (T.length linkFormShortId >= 3) "The shortId is at least 3 characters",
        check (T.all isAlphaNum linkFormShortId) "The shortId contains only alpha numeric chars"
      ]

instance FromJSON LinkForm where
  parseJSON = withObject "LinkForm" $ \o ->
    LinkForm <$> o .: "url" <*> o .: "shortId"

instance ToJSON LinkForm where
  toJSON LinkForm {..} =
    object
      [ "url" .= linkFormUrl,
        "shortId" .= linkFormShortId
      ]
