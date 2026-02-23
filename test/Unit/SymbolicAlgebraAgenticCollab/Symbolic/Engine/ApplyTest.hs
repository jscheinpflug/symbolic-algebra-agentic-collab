module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.ApplyTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.Apply
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Engine.Apply" $ do
        it "stores apply configuration" $ do
            includeTraceSteps ApplyConfig{includeTraceSteps = True} `shouldBe` True

        it "exposes apply failure constructors" $ do
            [ApplyNoMatch, ApplyGuardBlocked]
                `shouldBe` [ApplyNoMatch, ApplyGuardBlocked]
