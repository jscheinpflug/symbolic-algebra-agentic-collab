module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.RewriteTest (
    prop_rewriteProgramPreservesRuleCount,
    spec,
) where

import Support.Generators.Symbolic.Core (genRuleWithDepth)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Rewrite
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Property, chooseInt, counterexample, forAll, vectorOf)

spec :: Spec
spec =
    describe "Symbolic.Engine.EGraph.Rewrite" $ do
        it "exposes typed rewrite compile failure constructors" $ do
            [RewriteUnsupportedPatternShape, RewriteUnsupportedGuard]
                `shouldBe` [RewriteUnsupportedPatternShape, RewriteUnsupportedGuard]

        prop "prop_rewriteProgramPreservesRuleCount" prop_rewriteProgramPreservesRuleCount

prop_rewriteProgramPreservesRuleCount :: Property
prop_rewriteProgramPreservesRuleCount =
    forAll (chooseInt (0, 6)) $ \depthBound ->
        forAll (chooseInt (0, 12)) $ \ruleCount ->
            forAll (vectorOf ruleCount (genRuleWithDepth depthBound)) $ \rules ->
                let packed = RewriteProgram rules
                    preserved = length (unRewriteProgram packed) == length rules
                 in counterexample
                        ( "rewrite program rule count mismatch with depthBound="
                            <> show depthBound
                            <> " ruleCount="
                            <> show ruleCount
                        )
                        preserved
