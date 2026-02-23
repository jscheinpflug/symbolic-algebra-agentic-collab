module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig (..),
    SaturationError (..),
    saturate,
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (EGraphSnapshot)
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (Rule)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)

data SaturationConfig = SaturationConfig
    { maxIterations :: Int
    , maxENodes :: Int
    , maxEClasses :: Int
    }
    deriving (Eq, Show)

data SaturationError
    = SaturationIterationLimit Int
    | SaturationENodeLimit Int
    | SaturationEClassLimit Int
    | SaturationNoRootEClass
    deriving (Eq, Show)

saturate :: SaturationConfig -> [Rule] -> Term -> Either SaturationError EGraphSnapshot
saturate _ _ _ = Left SaturationNoRootEClass
