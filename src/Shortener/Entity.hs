{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

module Shortener.Entity where

import Data.Text (Text)
import Database.Persist.Sqlite
import Database.Persist.TH
import GHC.Generics (Generic)

share
  [mkPersist sqlSettings, mkMigrate "shortLinkMigration"]
  [persistLowerCase|

ShortLink
  url Text
  shortId Text

  UniqueShortId shortId

  deriving Show Eq Ord Generic
|]
