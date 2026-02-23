module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Extract (
    ExtractionCost (..),
    extractBest,
    extractBestWithCost,
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (EGraphSnapshot)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationError (SaturationNoRootEClass),
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)

data ExtractionCost = ExtractionCost
    { costRule :: Int
    , costSize :: Int
    }
    deriving (Eq, Show)

extractBest :: EGraphSnapshot -> Either SaturationError Term
extractBest _ = Left SaturationNoRootEClass

extractBestWithCost :: EGraphSnapshot -> Either SaturationError (Term, ExtractionCost)
extractBestWithCost _ = Left SaturationNoRootEClass
