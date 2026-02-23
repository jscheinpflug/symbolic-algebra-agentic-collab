module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (
    EGraphSnapshot,
) where

-- | Opaque placeholder snapshot for the e-graph backend.
newtype EGraphSnapshot = EGraphSnapshot ()
    deriving (Eq, Show)
