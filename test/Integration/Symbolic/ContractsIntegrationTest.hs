module Integration.Symbolic.ContractsIntegrationTest (spec) where

import Data.Map.Strict qualified as Map
import SymbolicAlgebraAgenticCollab.Symbolic.Corpus
import SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Ast
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.Search
import SymbolicAlgebraAgenticCollab.Symbolic.Pattern
import SymbolicAlgebraAgenticCollab.Symbolic.Rule
import SymbolicAlgebraAgenticCollab.Symbolic.Term
import SymbolicAlgebraAgenticCollab.Symbolic.Trace
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic integration" $ do
        it "composes ast declarations with trace and corpus contracts" $ do
            let x = Name "x"
            let lhs = PNode (Head "Plus") [PVar x, PNumber 0]
            let rhs = PVar x
            let decl =
                    RuleDecl
                        { declaredRuleId = "plus-zero-right"
                        , declaredLhs = lhs
                        , declaredRhs = rhs
                        }
            let inputTerm = Node (Head "Plus") [Atom "x", Number 0]
            let outputTerm = Atom "x"
            let step =
                    RewriteStep
                        { stepRuleId = RuleId (declaredRuleId decl)
                        , stepBefore = inputTerm
                        , stepAfter = outputTerm
                        , stepFocusPath = [1]
                        , stepSubst = Map.empty
                        , stepCost = 1
                        }
            let trace =
                    RewriteTrace
                        { traceStart = inputTerm
                        , traceSteps = [step]
                        , traceFinal = outputTerm
                        , traceTotalCost = 1
                        }
            let corpusCase =
                    CorpusCase
                        { caseId = declaredRuleId decl
                        , caseInput = inputTerm
                        , caseExpectation = "rewrites-to x"
                        }
            let query = QueryDecl{queryInput = inputTerm, queryTarget = Just (traceFinal trace)}
            caseId corpusCase `shouldBe` declaredRuleId decl
            queryTarget query `shouldBe` Just outputTerm

        it "keeps e-graph wrapper contracts deterministic across repeated runs" $ do
            let inputTerm = Node (Head "Plus") [Atom "x", Number 0]
            let first = buildSearchSnapshot inputTerm
            let second = buildSearchSnapshot inputTerm
            first `shouldBe` second
