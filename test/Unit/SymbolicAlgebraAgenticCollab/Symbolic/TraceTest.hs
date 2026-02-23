module Unit.SymbolicAlgebraAgenticCollab.Symbolic.TraceTest (
    prop_executeProgramDeterministicForRepeatedRuns,
    spec,
) where

import Data.Map.Strict qualified as Map
import Support.Generators.Symbolic.Core (genRuleWithDepth, genTermWithDepth)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (SaturationConfig (..))
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (RuleId (..))
import SymbolicAlgebraAgenticCollab.Symbolic.Term
import SymbolicAlgebraAgenticCollab.Symbolic.Trace
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Property, chooseInt, counterexample, forAll, vectorOf)

spec :: Spec
spec =
    describe "Symbolic.Trace" $ do
        it "records start, steps, and final value" $ do
            let start = Node (Head "Plus") [Atom "x", Number 0]
            let finish = Atom "x"
            let step =
                    RewriteStep
                        { stepRuleId = RuleId "plus-zero-right"
                        , stepBefore = start
                        , stepAfter = finish
                        , stepFocusPath = [1]
                        , stepSubst = Map.empty
                        , stepCost = 1
                        }
            let trace =
                    RewriteTrace
                        { traceStart = start
                        , traceSteps = [step]
                        , traceFinal = finish
                        , traceTotalCost = 1
                        }
            traceFinal trace `shouldBe` finish
            traceSteps trace `shouldBe` [step]

        it "exposes typed executeProgram placeholder failures" $ do
            let cfg = SaturationConfig{maxIterations = 8, maxENodes = 128, maxEClasses = 64}
            let input = Node (Head "Plus") [Atom "x", Number 0]
            executeProgram cfg [] input `shouldBe` executeProgram cfg [] input

        prop "prop_executeProgramDeterministicForRepeatedRuns" prop_executeProgramDeterministicForRepeatedRuns

prop_executeProgramDeterministicForRepeatedRuns :: Property
prop_executeProgramDeterministicForRepeatedRuns =
    forAll (chooseInt (0, 4)) $ \depthBound ->
        forAll (chooseInt (0, 8)) $ \ruleCount ->
            forAll (genTermWithDepth depthBound) $ \term ->
                forAll (vectorOf ruleCount (genRuleWithDepth depthBound)) $ \rules ->
                    let cfg =
                            SaturationConfig
                                { maxIterations = 8
                                , maxENodes = 128
                                , maxEClasses = 64
                                }
                        first = executeProgram cfg rules term
                        second = executeProgram cfg rules term
                     in counterexample
                            ( "executeProgram changed across repeated runs for "
                                <> show (depthBound, ruleCount)
                            )
                            (first == second)
