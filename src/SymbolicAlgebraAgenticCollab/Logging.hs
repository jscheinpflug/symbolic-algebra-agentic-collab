module SymbolicAlgebraAgenticCollab.Logging (
    LogConfig (..),
    LogLevel (..),
    LogSink (..),
    MonadLog (..),
    defaultCiLogConfig,
    defaultDevLogConfig,
    defaultLoggerName,
    defaultProdLogConfig,
    logDebug,
    logError,
    logInfo,
    logWarn,
    withLogging,
) where

import Data.Text (Text)
import Data.Text qualified as T
import System.IO (Handle, stderr)
import System.Log.Formatter (simpleLogFormatter)
import System.Log.Handler (setFormatter)
import System.Log.Handler.Simple (GenericHandler, fileHandler, streamHandler)
import System.Log.Logger (
    Priority (DEBUG, ERROR, INFO, WARNING),
    logM,
    rootLoggerName,
    setHandlers,
    setLevel,
    updateGlobalLogger,
 )

data LogLevel
    = Debug
    | Info
    | Warn
    | Error
    deriving (Eq, Ord, Show)

data LogSink
    = StdErr
    | FilePathSink FilePath
    | NoOp
    deriving (Eq, Show)

data LogConfig = LogConfig
    { minLevel :: LogLevel
    , sink :: LogSink
    }
    deriving (Eq, Show)

defaultLoggerName :: Text
defaultLoggerName = "symbolic-algebra-agentic-collab"

defaultDevLogConfig :: LogConfig
defaultDevLogConfig =
    LogConfig
        { minLevel = Info
        , sink = StdErr
        }

defaultCiLogConfig :: LogConfig
defaultCiLogConfig =
    LogConfig
        { minLevel = Info
        , sink = StdErr
        }

defaultProdLogConfig :: LogConfig
defaultProdLogConfig =
    LogConfig
        { minLevel = Error
        , sink = NoOp
        }

class (Monad m) => MonadLog m where
    logMsg :: LogLevel -> Text -> m ()

instance MonadLog IO where
    logMsg level msg =
        logM (T.unpack defaultLoggerName) (toPriority level) (T.unpack msg)

logDebug :: (MonadLog m) => Text -> m ()
logDebug = logMsg Debug

logInfo :: (MonadLog m) => Text -> m ()
logInfo = logMsg Info

logWarn :: (MonadLog m) => Text -> m ()
logWarn = logMsg Warn

logError :: (MonadLog m) => Text -> m ()
logError = logMsg Error

withLogging :: LogConfig -> IO a -> IO a
withLogging cfg action = do
    handlers <- buildHandlers cfg
    let loggerTransform =
            setLevel (toPriority (minLevel cfg))
                . setHandlers handlers
    updateGlobalLogger rootLoggerName loggerTransform
    action

buildHandlers :: LogConfig -> IO [GenericHandler Handle]
buildHandlers cfg = case sink cfg of
    NoOp ->
        pure []
    StdErr -> do
        handler <- streamHandler stderr (toPriority (minLevel cfg))
        pure [setFormatter handler (simpleLogFormatter (T.unpack "[$time : $prio] $msg"))]
    FilePathSink path -> do
        handler <- fileHandler path (toPriority (minLevel cfg))
        pure [setFormatter handler (simpleLogFormatter (T.unpack "[$time : $prio] $msg"))]

toPriority :: LogLevel -> Priority
toPriority level = case level of
    Debug ->
        DEBUG
    Info ->
        INFO
    Warn ->
        WARNING
    Error ->
        ERROR
