module SymbolicAlgebraAgenticCollab.Config (
    AppEnv (..),
    logConfigFromEnv,
) where

import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Text qualified as T
import SymbolicAlgebraAgenticCollab.Logging (
    LogConfig (..),
    LogLevel (..),
    LogSink (..),
    defaultCiLogConfig,
    defaultDevLogConfig,
    defaultProdLogConfig,
 )
import System.Environment (lookupEnv)

data AppEnv
    = EnvProd
    | EnvDev
    | EnvCi
    deriving (Eq, Show)

logConfigFromEnv :: IO LogConfig
logConfigFromEnv = do
    envValue <- fmap T.pack <$> lookupEnv "APP_ENV"
    levelValue <- fmap T.pack <$> lookupEnv "LOG_LEVEL"
    sinkValue <- fmap T.pack <$> lookupEnv "LOG_SINK"
    let appEnv = maybe EnvDev parseAppEnv envValue
        defaults = defaultsFor appEnv
        parsedLevel = levelValue >>= parseLogLevel
        parsedSink = sinkValue >>= parseLogSink
    pure
        defaults
            { minLevel = fromMaybe (minLevel defaults) parsedLevel
            , sink = fromMaybe (sink defaults) parsedSink
            }

defaultsFor :: AppEnv -> LogConfig
defaultsFor env = case env of
    EnvProd ->
        defaultProdLogConfig
    EnvDev ->
        defaultDevLogConfig
    EnvCi ->
        defaultCiLogConfig

parseAppEnv :: Text -> AppEnv
parseAppEnv input = case normalize input of
    "prod" ->
        EnvProd
    "production" ->
        EnvProd
    "ci" ->
        EnvCi
    _ ->
        EnvDev

parseLogLevel :: Text -> Maybe LogLevel
parseLogLevel input = case normalize input of
    "debug" ->
        Just Debug
    "info" ->
        Just Info
    "warn" ->
        Just Warn
    "warning" ->
        Just Warn
    "error" ->
        Just Error
    _ ->
        Nothing

parseLogSink :: Text -> Maybe LogSink
parseLogSink input = case normalize input of
    "stderr" ->
        Just StdErr
    "noop" ->
        Just NoOp
    _ ->
        parseFileSink input

parseFileSink :: Text -> Maybe LogSink
parseFileSink rawInput
    | "file:" `T.isPrefixOf` normalize rawInput && not (T.null pathText) =
        Just (FilePathSink (T.unpack pathText))
    | otherwise =
        Nothing
  where
    pathText = T.drop 5 rawInput

normalize :: Text -> Text
normalize = T.toLower
