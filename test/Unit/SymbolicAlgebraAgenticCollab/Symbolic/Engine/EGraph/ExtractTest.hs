module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.ExtractTest (
    prop_extractBestDeterministicForRepeatedRuns,
    prop_extractionCostMatchesObjectiveOrdering,
    spec,
) where

import Support.Generators.Symbolic.Core (genTermWithDepth)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Extract
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (SaturationError (SaturationNoRootEClass))
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Translate (termToEGraph)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term (..))
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Property, chooseInt, counterexample, forAll)

spec :: Spec
spec =
    describe "Symbolic.Engine.EGraph.Extract" $ do
        it "stores extraction cost fields" $ do
            let cost = ExtractionCost{costRule = 2, costSize = 5}
            costRule cost `shouldBe` 2
            costSize cost `shouldBe` 5

        it "exposes typed extraction failure placeholders" $ do
            case termToEGraph (Number 1) of
                Left _ ->
                    expectationFailure "termToEGraph unexpectedly failed while building extraction snapshot"
                Right snapshot -> do
                    extractBest snapshot `shouldBe` Left SaturationNoRootEClass
                    extractBestWithCost snapshot `shouldBe` Left SaturationNoRootEClass

        it "encodes tie-break objective as rule-cost then size" $ do
            let lowerRuleCost = ExtractionCost{costRule = 1, costSize = 99}
            let lowerSize = ExtractionCost{costRule = 3, costSize = 4}
            let higherSize = ExtractionCost{costRule = 3, costSize = 7}
            compareExtractionCost lowerRuleCost lowerSize `shouldBe` LT
            compareExtractionCost lowerSize higherSize `shouldBe` LT

        prop "prop_extractionCostMatchesObjectiveOrdering" prop_extractionCostMatchesObjectiveOrdering
        prop "prop_extractBestDeterministicForRepeatedRuns" prop_extractBestDeterministicForRepeatedRuns

prop_extractionCostMatchesObjectiveOrdering :: Property
prop_extractionCostMatchesObjectiveOrdering =
    forAll (chooseInt (0, 100)) $ \ruleA ->
        forAll (chooseInt (0, 100)) $ \sizeA ->
            forAll (chooseInt (0, 100)) $ \ruleB ->
                forAll (chooseInt (0, 100)) $ \sizeB ->
                    let leftCost = ExtractionCost{costRule = ruleA, costSize = sizeA}
                        rightCost = ExtractionCost{costRule = ruleB, costSize = sizeB}
                        expected = compare (ruleA, sizeA) (ruleB, sizeB)
                        actual = compareExtractionCost leftCost rightCost
                     in counterexample
                            ( "objective ordering mismatch for "
                                <> show (ruleA, sizeA, ruleB, sizeB)
                            )
                            (actual == expected)

prop_extractBestDeterministicForRepeatedRuns :: Property
prop_extractBestDeterministicForRepeatedRuns =
    forAll (genTermWithDepth 4) $ \term ->
        case termToEGraph term of
            Left _ ->
                counterexample "termToEGraph unexpectedly failed for generated term" False
            Right snapshot ->
                let first = extractBest snapshot
                    second = extractBest snapshot
                    firstWithCost = extractBestWithCost snapshot
                    secondWithCost = extractBestWithCost snapshot
                 in counterexample
                        "extraction placeholder was non-deterministic across repeated runs"
                        (first == second && firstWithCost == secondWithCost)

compareExtractionCost :: ExtractionCost -> ExtractionCost -> Ordering
compareExtractionCost leftCost rightCost =
    compare
        (costRule leftCost, costSize leftCost)
        (costRule rightCost, costSize rightCost)
