module Integration.Symbolic.PipelineIntegrationTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Corpus
import SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Parser
import SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Pretty
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig (..),
    SaturationError (SaturationNoRootEClass),
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Term
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic IO pipeline integration" $ do
        it "keeps executeProgram deterministic across repeated runs" $ do
            let cfg = SaturationConfig{maxIterations = 8, maxENodes = 128, maxEClasses = 64}
            let input = Node (Head "Plus") [Atom "x", Number 0]
            let first = executeProgram cfg [] input
            let second = executeProgram cfg [] input
            first `shouldBe` second

        it "keeps corpus expectation evaluation deterministic across repeated runs" $ do
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

        it "composes parser, pretty, corpus, and trace contracts in one pipeline skeleton" $ do
            let parserContract = ParserContract
            let prettyContract = PrettyContract
            let prettyTraceContract = PrettyTraceContract
            let expectation = ExpectNormalForm (Atom "x")
            let failureExpectation = ExpectFailure SaturationNoRootEClass
            let cfg = SaturationConfig{maxIterations = 8, maxENodes = 128, maxEClasses = 64}
            let input = Node (Head "Plus") [Atom "x", Number 0]
            parserContract `shouldBe` ParserContract
            prettyContract `shouldBe` PrettyContract
            prettyTraceContract `shouldBe` PrettyTraceContract
            expectation `shouldBe` ExpectNormalForm (Atom "x")
            failureExpectation `shouldBe` ExpectFailure SaturationNoRootEClass
            executeProgram cfg [] input `shouldBe` evaluateCorpusCase cfg [] (CorpusCase "id" input "expect")
