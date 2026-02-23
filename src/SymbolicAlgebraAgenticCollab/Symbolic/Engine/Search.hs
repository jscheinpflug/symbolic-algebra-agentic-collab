module SymbolicAlgebraAgenticCollab.Symbolic.Engine.Search (
    SearchConfig (..),
    SearchMode (..),
    SearchStats (..),
) where

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
