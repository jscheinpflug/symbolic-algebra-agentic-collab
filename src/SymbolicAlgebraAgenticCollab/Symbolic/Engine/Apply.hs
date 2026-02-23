module SymbolicAlgebraAgenticCollab.Symbolic.Engine.Apply (
    ApplyConfig (..),
    ApplyError (..),
    SaturationConfig (..),
    SaturationError (..),
    saturate,
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig (..),
    SaturationError (..),
    saturate,
 )

data ApplyConfig = ApplyConfig
    { includeTraceSteps :: Bool
    }
    deriving (Eq, Show)

data ApplyError
    = ApplyNoMatch
    | ApplyGuardBlocked
    deriving (Eq, Show)
