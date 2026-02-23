module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Rewrite (
    compileRewriteProgram,
    RewriteCompileError (..),
    RewriteProgram (..),
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Pattern (Pattern (..))
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (Rule (..))

data RewriteCompileError
    = RewriteUnsupportedPatternShape
    | RewriteUnsupportedGuard
    deriving (Eq, Show)

newtype RewriteProgram = RewriteProgram
    { unRewriteProgram :: [Rule]
    }
    deriving (Eq, Show)

compileRewriteProgram :: [Rule] -> Either RewriteCompileError RewriteProgram
compileRewriteProgram rules = do
    mapM_ validateRule rules
    pure (RewriteProgram rules)

validateRule :: Rule -> Either RewriteCompileError ()
validateRule rule = do
    validatePattern (ruleLhs rule)
    validatePattern (ruleRhs rule)
    case ruleGuard rule of
        Nothing ->
            Right ()
        Just _ ->
            Left RewriteUnsupportedGuard

validatePattern :: Pattern -> Either RewriteCompileError ()
validatePattern patternNode = case patternNode of
    PVar _ ->
        Right ()
    PSeqVar _ ->
        Left RewriteUnsupportedPatternShape
    PAtom _ ->
        Right ()
    PNumber _ ->
        Right ()
    PTextLit _ ->
        Right ()
    PNode _ children ->
        mapM_ validatePattern children
