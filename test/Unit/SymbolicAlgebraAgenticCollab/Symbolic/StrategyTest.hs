module Unit.SymbolicAlgebraAgenticCollab.Symbolic.StrategyTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Strategy
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Strategy" $ do
        it "preserves nested strategy shape" $ do
            let strategy = Limit 8 (Choice [TopDown, Repeat Innermost, BottomUp, Outermost])
            strategy `shouldBe` Limit 8 (Choice [TopDown, Repeat Innermost, BottomUp, Outermost])
