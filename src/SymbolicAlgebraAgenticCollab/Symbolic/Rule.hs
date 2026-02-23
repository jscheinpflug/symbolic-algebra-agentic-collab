module SymbolicAlgebraAgenticCollab.Symbolic.Rule (
    Guard (..),
    Rule (..),
    RuleId (..),
) where

import Data.Text (Text)
import SymbolicAlgebraAgenticCollab.Symbolic.Pattern (Name, Pattern)

newtype RuleId = RuleId
    { unRuleId :: Text
    }
    deriving (Eq, Ord, Show)

data Guard
    = GuardEq Name Name
    deriving (Eq, Show)

data Rule = Rule
    { ruleId :: RuleId
    , ruleLhs :: Pattern
    , ruleRhs :: Pattern
    , ruleGuard :: Maybe Guard
    , rulePriority :: Int
    , ruleCost :: Int
    }
    deriving (Eq, Show)
