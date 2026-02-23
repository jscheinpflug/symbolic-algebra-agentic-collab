module Unit.SymbolicAlgebraAgenticCollab.Symbolic.RuleTest (
    prop_ruleGenerationProducesValidContractShape,
    spec,
) where

import Support.Generators.Symbolic.Core (genRuleWithDepth, patternDepth)
import SymbolicAlgebraAgenticCollab.Symbolic.Pattern (Name (..), Pattern (..))
import SymbolicAlgebraAgenticCollab.Symbolic.Rule
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head (..))
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Property, chooseInt, counterexample, forAll)

spec :: Spec
spec =
    describe "Symbolic.Rule" $ do
        it "preserves rule fields" $ do
            let x = Name "x"
            let lhs = PNode (Head "Plus") [PVar x, PNumber 0]
            let rhs = PVar x
            let rule =
                    Rule
                        { ruleId = RuleId "plus-zero-right"
                        , ruleLhs = lhs
                        , ruleRhs = rhs
                        , ruleGuard = Just (GuardEq x x)
                        , rulePriority = 10
                        , ruleCost = 1
                        }
            ruleLhs rule `shouldBe` lhs
            ruleRhs rule `shouldBe` rhs
            rulePriority rule `shouldBe` 10
            ruleCost rule `shouldBe` 1

        prop "prop_ruleGenerationProducesValidContractShape" prop_ruleGenerationProducesValidContractShape

prop_ruleGenerationProducesValidContractShape :: Property
prop_ruleGenerationProducesValidContractShape =
    forAll (chooseInt (0, 6)) $ \bound ->
        forAll (genRuleWithDepth bound) $ \rule ->
            let lhsDepth = patternDepth (ruleLhs rule)
                rhsDepth = patternDepth (ruleRhs rule)
                condition =
                    ruleCost rule >= 0
                        && rulePriority rule >= 0
                        && lhsDepth <= bound
                        && rhsDepth <= bound
             in counterexample
                    ( "invalid generated rule shape with bound "
                        <> show bound
                        <> " and depths (lhs,rhs)="
                        <> show (lhsDepth, rhsDepth)
                    )
                    condition
