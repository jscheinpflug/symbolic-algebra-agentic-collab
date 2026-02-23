module SymbolicAlgebraAgenticCollab.Symbolic.Corpus (
    Corpus (..),
    CorpusCase (..),
    CorpusExpectation (..),
    evaluateCorpusCase,
) where

import Data.Text (Text)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig,
    SaturationError,
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (Rule)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)
import SymbolicAlgebraAgenticCollab.Symbolic.Trace (RewriteTrace, executeProgram)

data CorpusCase = CorpusCase
    { caseId :: Text
    , caseInput :: Term
    , caseExpectation :: Text
    }
    deriving (Eq, Show)

newtype Corpus = Corpus
    { unCorpus :: [CorpusCase]
    }
    deriving (Eq, Show)

data CorpusExpectation
    = ExpectNormalForm Term
    | ExpectTraceLength Int
    | ExpectFailure SaturationError
    deriving (Eq, Show)

evaluateCorpusCase :: SaturationConfig -> [Rule] -> CorpusCase -> Either SaturationError RewriteTrace
evaluateCorpusCase cfg rules corpusCase = executeProgram cfg rules (caseInput corpusCase)
