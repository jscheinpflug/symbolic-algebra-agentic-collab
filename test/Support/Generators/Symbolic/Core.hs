module Support.Generators.Symbolic.Core (
    genHead,
    genName,
    genPatternWithDepth,
    genRuleWithDepth,
    genTermWithDepth,
    patternDepth,
    termDepth,
) where

import Data.Char (isAlphaNum)
import Data.Text (Text)
import Data.Text qualified as T
import SymbolicAlgebraAgenticCollab.Symbolic.Pattern (Name (..), Pattern (..))
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (Guard (..), Rule (..), RuleId (..))
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head (..), Term (..))
import Test.QuickCheck

termDepth :: Term -> Int
termDepth term = case term of
    Atom _ ->
        0
    Number _ ->
        0
    TextLit _ ->
        0
    Node _ children ->
        1 + foldr (max . termDepth) 0 children

patternDepth :: Pattern -> Int
patternDepth patternNode = case patternNode of
    PVar _ ->
        0
    PSeqVar _ ->
        0
    PAtom _ ->
        0
    PNumber _ ->
        0
    PTextLit _ ->
        0
    PNode _ children ->
        1 + foldr (max . patternDepth) 0 children

genHead :: Gen Head
genHead = Head <$> genIdentifier

genName :: Gen Name
genName = Name <$> genIdentifier

genTermWithDepth :: Int -> Gen Term
genTermWithDepth depthBound
    | depthBound <= 0 =
        oneof
            [ Atom <$> genIdentifier
            , Number <$> chooseInteger (-200, 200)
            , TextLit <$> genPayload
            ]
    | otherwise =
        frequency
            [ (4, Atom <$> genIdentifier)
            , (3, Number <$> chooseInteger (-200, 200))
            , (3, TextLit <$> genPayload)
            ,
                ( 5
                , do
                    nodeHead <- genHead
                    childCount <- chooseInt (0, 3)
                    children <- vectorOf childCount (genTermWithDepth (depthBound - 1))
                    pure (Node nodeHead children)
                )
            ]

genPatternWithDepth :: Int -> Gen Pattern
genPatternWithDepth depthBound
    | depthBound <= 0 =
        oneof
            [ PVar <$> genName
            , PSeqVar <$> genName
            , PAtom <$> genIdentifier
            , PNumber <$> chooseInteger (-200, 200)
            , PTextLit <$> genPayload
            ]
    | otherwise =
        frequency
            [ (3, PVar <$> genName)
            , (2, PSeqVar <$> genName)
            , (2, PAtom <$> genIdentifier)
            , (2, PNumber <$> chooseInteger (-200, 200))
            , (2, PTextLit <$> genPayload)
            ,
                ( 5
                , do
                    nodeHead <- genHead
                    childCount <- chooseInt (0, 3)
                    children <- vectorOf childCount (genPatternWithDepth (depthBound - 1))
                    pure (PNode nodeHead children)
                )
            ]

genRuleWithDepth :: Int -> Gen Rule
genRuleWithDepth depthBound = do
    lhs <- genPatternWithDepth depthBound
    rhs <- genPatternWithDepth depthBound
    lhsName <- genName
    rhsName <- genName
    rid <- RuleId <$> genIdentifier
    guardChoice <- frequency [(4, pure Nothing), (1, pure (Just (GuardEq lhsName rhsName)))]
    priority <- chooseInt (0, 30)
    cost <- chooseInt (0, 30)
    pure
        Rule
            { ruleId = rid
            , ruleLhs = lhs
            , ruleRhs = rhs
            , ruleGuard = guardChoice
            , rulePriority = priority
            , ruleCost = cost
            }

genIdentifier :: Gen Text
genIdentifier = do
    len <- chooseInt (1, 12)
    chars <- vectorOf len (elements identifierChars)
    pure (T.pack chars)

genPayload :: Gen Text
genPayload = do
    len <- chooseInt (0, 20)
    chars <- vectorOf len (elements payloadChars)
    pure (T.pack chars)

identifierChars :: FilePath
identifierChars = filter isAlphaNum (['a' .. 'z'] <> ['A' .. 'Z'] <> ['0' .. '9'])

payloadChars :: FilePath
payloadChars = identifierChars <> " _-+*/()[]"
