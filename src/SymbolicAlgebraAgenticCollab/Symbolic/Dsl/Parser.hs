module SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Parser (
    ParseError (..),
    ParserContract (..),
) where

import Data.Text (Text)

data ParseError = ParseError
    { parseErrorLine :: Int
    , parseErrorColumn :: Int
    , parseErrorMessage :: Text
    }
    deriving (Eq, Show)

data ParserContract = ParserContract
    deriving (Eq, Show)
