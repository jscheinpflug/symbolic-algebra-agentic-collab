module SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Parser (
    ParseError (..),
    ParserContract (..),
    executeProgram,
) where

import Data.Text (Text)
import SymbolicAlgebraAgenticCollab.Symbolic.Trace (executeProgram)

data ParseError = ParseError
    { parseErrorLine :: Int
    , parseErrorColumn :: Int
    , parseErrorMessage :: Text
    }
    deriving (Eq, Show)

data ParserContract = ParserContract
    deriving (Eq, Show)
