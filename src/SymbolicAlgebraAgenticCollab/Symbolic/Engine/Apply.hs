module SymbolicAlgebraAgenticCollab.Symbolic.Engine.Apply (
    ApplyConfig (..),
    ApplyError (..),
) where

data ApplyConfig = ApplyConfig
    { includeTraceSteps :: Bool
    }
    deriving (Eq, Show)

data ApplyError
    = ApplyNoMatch
    | ApplyGuardBlocked
    deriving (Eq, Show)
