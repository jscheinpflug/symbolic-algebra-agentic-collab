module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Dsl.AstTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Ast
import SymbolicAlgebraAgenticCollab.Symbolic.Pattern
import SymbolicAlgebraAgenticCollab.Symbolic.Term
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Dsl.Ast" $ do
        it "preserves declarations in a program" $ do
            let symbolDecl =
                    SymbolDecl
                        { declaredHead = Head "Plus"
                        , declaredAttributes = ["Associative", "Commutative"]
                        }
            let ruleDecl =
                    RuleDecl
                        { declaredRuleId = "plus-zero-right"
                        , declaredLhs = PNode (Head "Plus") [PVar (Name "x"), PNumber 0]
                        , declaredRhs = PVar (Name "x")
                        }
            let queryDecl =
                    QueryDecl
                        { queryInput = Node (Head "Plus") [Atom "x", Number 0]
                        , queryTarget = Just (Atom "x")
                        }
            let program =
                    Program
                        { programSymbols = [symbolDecl]
                        , programRules = [ruleDecl]
                        , programQueries = [queryDecl]
                        }
            length (programSymbols program) `shouldBe` 1
            declaredRuleId ruleDecl `shouldBe` "plus-zero-right"
