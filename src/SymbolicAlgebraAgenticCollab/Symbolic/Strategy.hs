module SymbolicAlgebraAgenticCollab.Symbolic.Strategy (
    Strategy (..),
) where

data Strategy
    = TopDown
    | BottomUp
    | Innermost
    | Outermost
    | Repeat Strategy
    | Choice [Strategy]
    | Limit Int Strategy
    deriving (Eq, Show)
