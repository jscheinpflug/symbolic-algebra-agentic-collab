module SymbolicAlgebraAgenticCollab.Symbolic.Symbol (
    Attribute (..),
    SymbolDef (..),
    SymbolTable,
) where

import Data.Map.Strict (Map)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head)

data Attribute
    = Associative
    | Commutative
    | OneIdentity
    | HoldAll
    | HoldFirst
    | Flat
    | Orderless
    deriving (Eq, Ord, Show)

data SymbolDef = SymbolDef
    { symbolHead :: Head
    , symbolAttributes :: [Attribute]
    }
    deriving (Eq, Show)

type SymbolTable = Map Head SymbolDef
