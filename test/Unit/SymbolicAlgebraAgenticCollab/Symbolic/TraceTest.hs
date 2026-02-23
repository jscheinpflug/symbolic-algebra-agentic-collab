module Unit.SymbolicAlgebraAgenticCollab.Symbolic.TraceTest (spec) where

import Data.Map.Strict qualified as Map
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (RuleId (..))
import SymbolicAlgebraAgenticCollab.Symbolic.Term
import SymbolicAlgebraAgenticCollab.Symbolic.Trace
import Test.Hspec

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
