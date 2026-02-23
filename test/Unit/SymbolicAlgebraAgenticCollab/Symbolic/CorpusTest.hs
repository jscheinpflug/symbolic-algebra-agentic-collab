module Unit.SymbolicAlgebraAgenticCollab.Symbolic.CorpusTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Corpus
import SymbolicAlgebraAgenticCollab.Symbolic.Term
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Corpus" $ do
        it "preserves corpus case fields" $ do
            let corpusCase =
                    CorpusCase
                        { caseId = "plus-zero-right"
                        , caseInput = Node (Head "Plus") [Atom "x", Number 0]
                        , caseExpectation = "rewrites-to x"
                        }
            let corpus = Corpus [corpusCase]
            caseId corpusCase `shouldBe` "plus-zero-right"
            length (unCorpus corpus) `shouldBe` 1
