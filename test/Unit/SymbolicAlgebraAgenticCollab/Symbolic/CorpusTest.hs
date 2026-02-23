module Unit.SymbolicAlgebraAgenticCollab.Symbolic.CorpusTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Corpus
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig (..),
    SaturationError (SaturationNoRootEClass),
 )
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

        it "exposes corpus expectation constructors" $ do
            let expectedTerm = Atom "x"
            let expectNormal = ExpectNormalForm expectedTerm
            let expectLength = ExpectTraceLength 2
            let expectFailure = ExpectFailure SaturationNoRootEClass
            expectNormal `shouldBe` ExpectNormalForm expectedTerm
            expectLength `shouldBe` ExpectTraceLength 2
            expectFailure `shouldBe` ExpectFailure SaturationNoRootEClass

        it "keeps corpus case evaluation deterministic for repeated runs" $ do
            let cfg = SaturationConfig{maxIterations = 8, maxENodes = 128, maxEClasses = 64}
            let corpusCase =
                    CorpusCase
                        { caseId = "plus-zero-right"
                        , caseInput = Node (Head "Plus") [Atom "x", Number 0]
                        , caseExpectation = "rewrites-to x"
                        }
            let first = evaluateCorpusCase cfg [] corpusCase
            let second = evaluateCorpusCase cfg [] corpusCase
            first `shouldBe` second
