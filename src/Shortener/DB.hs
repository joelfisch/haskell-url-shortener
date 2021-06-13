module Shortener.DB where

import Control.Monad.IO.Class
import Database.Persist.Sql
import Servant

runQuery :: SqlBackend -> SqlPersistT IO a -> Handler a
runQuery conn query = liftIO $ runSqlConn query conn
