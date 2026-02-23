module SymbolicAlgebraAgenticCollab.Symbolic.Corpus (
    Corpus (..),
    CorpusCase (..),
) where

import Data.Text (Text)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)

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
