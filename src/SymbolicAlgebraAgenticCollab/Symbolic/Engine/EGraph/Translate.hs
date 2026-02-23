{-# LANGUAGE DeriveTraversable #-}

module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Translate (
    EGraphBuildError (..),
    eGraphToTerm,
    termToEGraph,
) where

import Data.Equality.Graph (EGraph, emptyEGraph, represent)
import Data.Equality.Utils (Fix (..))
import Data.Text (Text)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (
    EGraphSnapshot,
    mkSnapshot,
    snapshotTerm,
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head, Term (..))

data EGraphBuildError
    = BuildUnsupportedTermShape
    | BuildInvalidSymbolEncoding
    deriving (Eq, Show)

data TermLang a
    = LangAtom Text
    | LangNumber Integer
    | LangTextLit Text
    | LangNode Head [a]
    deriving (Eq, Ord, Show, Functor, Foldable, Traversable)

termToEGraph :: Term -> Either EGraphBuildError EGraphSnapshot
termToEGraph term =
    case represent (termToFix term) (emptyEGraph :: EGraph () TermLang) of
        (_, _) -> Right (mkSnapshot term)

eGraphToTerm :: EGraphSnapshot -> Either EGraphBuildError Term
eGraphToTerm = Right . snapshotTerm

termToFix :: Term -> Fix TermLang
termToFix term = case term of
    Atom value ->
        Fix (LangAtom value)
    Number value ->
        Fix (LangNumber value)
    TextLit value ->
        Fix (LangTextLit value)
    Node headSymbol children ->
        Fix (LangNode headSymbol (map termToFix children))
