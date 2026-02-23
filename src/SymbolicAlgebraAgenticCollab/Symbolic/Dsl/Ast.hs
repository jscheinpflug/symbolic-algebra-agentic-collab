module SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Ast (
    Program (..),
    QueryDecl (..),
    RuleDecl (..),
    SymbolDecl (..),
) where

import Data.Text (Text)
import SymbolicAlgebraAgenticCollab.Symbolic.Pattern (Pattern)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head, Term)

data SymbolDecl = SymbolDecl
    { declaredHead :: Head
    , declaredAttributes :: [Text]
    }
    deriving (Eq, Show)

data RuleDecl = RuleDecl
    { declaredRuleId :: Text
    , declaredLhs :: Pattern
    , declaredRhs :: Pattern
    }
    deriving (Eq, Show)

data QueryDecl = QueryDecl
    { queryInput :: Term
    , queryTarget :: Maybe Term
    }
    deriving (Eq, Show)

data Program = Program
    { programSymbols :: [SymbolDecl]
    , programRules :: [RuleDecl]
    , programQueries :: [QueryDecl]
    }
    deriving (Eq, Show)
