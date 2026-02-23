module SymbolicAlgebraAgenticCollab.Symbolic.Trace (
    executeProgram,
    RewriteStep (..),
    RewriteTrace (..),
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Extract (
    ExtractionCost (..),
    extractBestWithCost,
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig,
    SaturationError (SaturationNoRootEClass),
    saturate,
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
executeProgram cfg rules term
    | null rules = Left SaturationNoRootEClass
    | otherwise = do
        snapshot <- saturate cfg rules term
        (bestTerm, bestCost) <- extractBestWithCost snapshot
        pure
            RewriteTrace
                { traceStart = term
                , traceSteps = []
                , traceFinal = bestTerm
                , traceTotalCost = costRule bestCost
                }
