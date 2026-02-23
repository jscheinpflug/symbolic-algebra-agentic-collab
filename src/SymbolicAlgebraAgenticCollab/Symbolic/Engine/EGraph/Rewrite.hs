module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Rewrite (
    RewriteCompileError (..),
    RewriteProgram (..),
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Rule (Rule)

data RewriteCompileError
    = RewriteUnsupportedPatternShape
    | RewriteUnsupportedGuard
    deriving (Eq, Show)

newtype RewriteProgram = RewriteProgram
    { unRewriteProgram :: [Rule]
    }
    deriving (Eq, Show)
