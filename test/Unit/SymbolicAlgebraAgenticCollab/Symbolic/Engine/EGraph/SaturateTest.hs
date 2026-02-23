module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.SaturateTest (
    prop_saturateDeterministicForRepeatedRuns,
    spec,
) where

import Support.Generators.Symbolic.Core (genRuleWithDepth, genTermWithDepth)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Property, chooseInt, counterexample, forAll, vectorOf)

spec :: Spec
spec =
    describe "Symbolic.Engine.EGraph.Saturate" $ do
        it "stores saturation configuration limits" $ do
            let cfg =
                    SaturationConfig
                        { maxIterations = 10
                        , maxENodes = 300
                        , maxEClasses = 120
                        }
            maxIterations cfg `shouldBe` 10
            maxENodes cfg `shouldBe` 300
            maxEClasses cfg `shouldBe` 120

        it "exposes typed saturation failure constructors" $ do
            [SaturationIterationLimit 1, SaturationENodeLimit 2, SaturationEClassLimit 3, SaturationNoRootEClass]
                `shouldBe` [SaturationIterationLimit 1, SaturationENodeLimit 2, SaturationEClassLimit 3, SaturationNoRootEClass]

        prop "prop_saturateDeterministicForRepeatedRuns" prop_saturateDeterministicForRepeatedRuns

prop_saturateDeterministicForRepeatedRuns :: Property
prop_saturateDeterministicForRepeatedRuns =
    forAll (chooseInt (0, 4)) $ \depthBound ->
        forAll (chooseInt (0, 8)) $ \ruleCount ->
            forAll (genTermWithDepth depthBound) $ \term ->
                forAll (vectorOf ruleCount (genRuleWithDepth depthBound)) $ \rules ->
                    let cfg =
                            SaturationConfig
                                { maxIterations = 5
                                , maxENodes = 200
                                , maxEClasses = 100
                                }
                        first = saturate cfg rules term
                        second = saturate cfg rules term
                     in counterexample
                            ( "non-deterministic saturation result with depthBound="
                                <> show depthBound
                                <> " ruleCount="
                                <> show ruleCount
                            )
                            (first == second)
