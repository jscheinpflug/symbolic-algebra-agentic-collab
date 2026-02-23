module SymbolicAlgebraAgenticCollab.Symbolic.Trace (
    RewriteStep (..),
    RewriteTrace (..),
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Pattern (Subst)
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (RuleId)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term)

data RewriteStep = RewriteStep
    { stepRuleId :: RuleId
    , stepBefore :: Term
    , stepAfter :: Term
    , stepFocusPath :: [Int]
    , stepSubst :: Subst
    , stepCost :: Int
    }
    deriving (Eq, Show)

data RewriteTrace = RewriteTrace
    { traceStart :: Term
    , traceSteps :: [RewriteStep]
    , traceFinal :: Term
    , traceTotalCost :: Int
    }
    deriving (Eq, Show)
