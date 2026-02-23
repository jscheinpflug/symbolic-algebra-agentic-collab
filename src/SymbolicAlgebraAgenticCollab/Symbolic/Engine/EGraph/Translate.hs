module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Translate (
    EGraphBuildError (..),
    eGraphToTerm,
    termToEGraph,
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (EGraphSnapshot)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)

data EGraphBuildError
    = BuildUnsupportedTermShape
    | BuildInvalidSymbolEncoding
    deriving (Eq, Show)

-- Placeholder contract-only implementation for TYPES phase.
termToEGraph :: Term -> Either EGraphBuildError EGraphSnapshot
termToEGraph _ = Left BuildUnsupportedTermShape

-- Placeholder contract-only implementation for TYPES phase.
eGraphToTerm :: EGraphSnapshot -> Either EGraphBuildError Term
eGraphToTerm _ = Left BuildInvalidSymbolEncoding
