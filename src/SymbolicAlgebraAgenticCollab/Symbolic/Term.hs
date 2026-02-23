module SymbolicAlgebraAgenticCollab.Symbolic.Term (
    Head (..),
    Term (..),
) where

import Data.Text (Text)

newtype Head = Head
    { unHead :: Text
    }
    deriving (Eq, Ord, Show)

data Term
    = Atom Text
    | Number Integer
    | TextLit Text
    | Node Head [Term]
    deriving (Eq, Ord, Show)
