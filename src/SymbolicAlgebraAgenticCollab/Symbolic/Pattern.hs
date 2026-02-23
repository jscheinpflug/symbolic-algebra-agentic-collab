module SymbolicAlgebraAgenticCollab.Symbolic.Pattern (
    Name (..),
    Pattern (..),
    Subst,
) where

import Data.Map.Strict (Map)
import Data.Text (Text)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head, Term)

newtype Name = Name
    { unName :: Text
    }
    deriving (Eq, Ord, Show)

data Pattern
    = PVar Name
    | PSeqVar Name
    | PAtom Text
    | PNumber Integer
    | PTextLit Text
    | PNode Head [Pattern]
    deriving (Eq, Ord, Show)

type Subst = Map Name Term
