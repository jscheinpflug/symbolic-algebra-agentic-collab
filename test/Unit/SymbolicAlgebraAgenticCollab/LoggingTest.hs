module Unit.SymbolicAlgebraAgenticCollab.LoggingTest (spec) where

import SymbolicAlgebraAgenticCollab.Logging
import Test.Hspec

spec :: Spec
spec =
    describe "Logging" $ do
        it "development defaults use info level to stderr" $ do
            defaultDevLogConfig
                `shouldBe` LogConfig
                    { minLevel = Info
                    , sink = StdErr
                    }

        it "production defaults use noop sink" $ do
            defaultProdLogConfig
                `shouldBe` LogConfig
                    { minLevel = Error
                    , sink = NoOp
                    }

        it "withLogging allows noop sink execution" $ do
            withLogging defaultProdLogConfig (pure ()) `shouldReturn` ()
