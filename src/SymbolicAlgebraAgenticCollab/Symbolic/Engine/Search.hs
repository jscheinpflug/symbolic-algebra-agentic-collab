module SymbolicAlgebraAgenticCollab.Symbolic.Engine.Search (
    EGraphBuildError (..),
    EGraphSnapshot,
    buildSearchSnapshot,
    recoverSearchTerm,
    SearchConfig (..),
    SearchMode (..),
    SearchStats (..),
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (EGraphSnapshot)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Translate (
    EGraphBuildError (..),
    eGraphToTerm,
    termToEGraph,
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)

data SearchMode
    = Deterministic
    | BeamSearch
    deriving (Eq, Show)

data SearchConfig = SearchConfig
    { searchMode :: SearchMode
    , maxDepth :: Int
    , maxFrontier :: Int
    , beamWidth :: Int
    }
    deriving (Eq, Show)

data SearchStats = SearchStats
    { expandedNodes :: Int
    , prunedNodes :: Int
    , maxFrontierSeen :: Int
    }
    deriving (Eq, Show)

buildSearchSnapshot :: Term -> Either EGraphBuildError EGraphSnapshot
buildSearchSnapshot = termToEGraph

recoverSearchTerm :: EGraphSnapshot -> Either EGraphBuildError Term
recoverSearchTerm = eGraphToTerm
