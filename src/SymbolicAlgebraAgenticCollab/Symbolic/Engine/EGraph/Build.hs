module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (
    EGraphSnapshot,
    mkSnapshot,
    snapshotTerm,
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)

-- | Opaque wrapper for backend e-graph snapshot data.
newtype EGraphSnapshot = EGraphSnapshot Term
    deriving (Eq, Show)

mkSnapshot :: Term -> EGraphSnapshot
mkSnapshot = EGraphSnapshot

snapshotTerm :: EGraphSnapshot -> Term
snapshotTerm (EGraphSnapshot term) = term
