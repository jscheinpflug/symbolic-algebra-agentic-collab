module SymbolicAlgebraAgenticCollab.Symbolic.Engine.Search (
    EGraphBuildError (..),
    EGraphSnapshot,
    SearchConfig (..),
    SearchMode (..),
    SearchStats (..),
    buildSearchSnapshot,
    recoverSearchTerm,
    runStrategy,
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (EGraphSnapshot)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig,
    SaturationError (SaturationNoRootEClass),
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Translate (
    EGraphBuildError (..),
    eGraphToTerm,
    termToEGraph,
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (Rule)
import SymbolicAlgebraAgenticCollab.Symbolic.Strategy (Strategy)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)
import SymbolicAlgebraAgenticCollab.Symbolic.Trace (RewriteTrace)

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

runStrategy ::
    Strategy ->
    SaturationConfig ->
    [Rule] ->
    Term ->
    Either SaturationError RewriteTrace
runStrategy _ _ _ _ = Left SaturationNoRootEClass
