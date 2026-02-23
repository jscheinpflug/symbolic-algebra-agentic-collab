module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Dsl.PrettyTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Pretty
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Dsl.Pretty" $ do
        it "exposes pretty contract constructor" $ do
            PrettyContract `shouldBe` PrettyContract
