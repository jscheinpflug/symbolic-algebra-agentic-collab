module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.ApplyTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.Apply
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term (..))
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Engine.Apply" $ do
        it "stores apply configuration" $ do
            includeTraceSteps ApplyConfig{includeTraceSteps = True} `shouldBe` True

        it "exposes apply failure constructors" $ do
            [ApplyNoMatch, ApplyGuardBlocked]
                `shouldBe` [ApplyNoMatch, ApplyGuardBlocked]

        it "re-exports saturation wrapper contracts" $ do
            let cfg =
                    SaturationConfig
                        { maxIterations = 8
                        , maxENodes = 200
                        , maxEClasses = 80
                        }
            maxIterations cfg `shouldBe` 8
            maxENodes cfg `shouldBe` 200
            maxEClasses cfg `shouldBe` 80
            let input = Atom "x" :: Term
            saturate cfg [] input `shouldBe` saturate cfg [] input
