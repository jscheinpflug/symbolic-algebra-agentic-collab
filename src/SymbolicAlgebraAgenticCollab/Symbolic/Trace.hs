module SymbolicAlgebraAgenticCollab.Symbolic.Trace (
    executeProgram,
    RewriteStep (..),
    RewriteTrace (..),
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig,
    SaturationError (SaturationNoRootEClass),
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Pattern (Subst)
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (Rule, RuleId)
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

executeProgram :: SaturationConfig -> [Rule] -> Term -> Either SaturationError RewriteTrace
executeProgram _ _ _ = Left SaturationNoRootEClass
