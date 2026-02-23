module Unit.SymbolicAlgebraAgenticCollab.ConfigTest (spec) where

import Control.Exception (bracket_)
import SymbolicAlgebraAgenticCollab.Config
import SymbolicAlgebraAgenticCollab.Logging
import System.Environment (lookupEnv, setEnv, unsetEnv)
import Test.Hspec

spec :: Spec
spec =
    describe "Config" $ do
        it "uses ci defaults when APP_ENV=ci" $
            withTempEnv
                [("APP_ENV", Just "ci"), ("LOG_LEVEL", Nothing), ("LOG_SINK", Nothing)]
                (logConfigFromEnv `shouldReturn` defaultCiLogConfig)

        it "applies level and sink overrides" $
            withTempEnv
                [ ("APP_ENV", Just "prod")
                , ("LOG_LEVEL", Just "debug")
                , ("LOG_SINK", Just "file:/tmp/symbolic.log")
                ]
                ( logConfigFromEnv
                    `shouldReturn` LogConfig
                        { minLevel = Debug
                        , sink = FilePathSink "/tmp/symbolic.log"
                        }
                )

        it "falls back to development defaults on unknown env" $
            withTempEnv
                [("APP_ENV", Just "unknown"), ("LOG_LEVEL", Nothing), ("LOG_SINK", Nothing)]
                (logConfigFromEnv `shouldReturn` defaultDevLogConfig)

withTempEnv :: [(FilePath, Maybe FilePath)] -> IO a -> IO a
withTempEnv vars action = do
    previous <- mapM capture vars
    bracket_ (apply vars) (restore previous) action
  where
    capture :: (FilePath, Maybe FilePath) -> IO (FilePath, Maybe FilePath)
    capture (key, _) = do
        oldValue <- lookupEnv key
        pure (key, oldValue)

    apply :: [(FilePath, Maybe FilePath)] -> IO ()
    apply = mapM_ setPair

    restore :: [(FilePath, Maybe FilePath)] -> IO ()
    restore = mapM_ setPair

    setPair :: (FilePath, Maybe FilePath) -> IO ()
    setPair (key, maybeValue) = case maybeValue of
        Just value ->
            setEnv key value
        Nothing ->
            unsetEnv key
