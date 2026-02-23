module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig (..),
    SaturationError (..),
    saturate,
) where

import Data.Set qualified as Set
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (EGraphSnapshot)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Rewrite (compileRewriteProgram)
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Translate (termToEGraph)
import SymbolicAlgebraAgenticCollab.Symbolic.Rule (Rule)
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term (..))

data SaturationConfig = SaturationConfig
    { maxIterations :: Int
    , maxENodes :: Int
    , maxEClasses :: Int
    }
    deriving (Eq, Show)

data SaturationError
    = SaturationIterationLimit Int
    | SaturationENodeLimit Int
    | SaturationEClassLimit Int
    | SaturationNoRootEClass
    deriving (Eq, Show)

saturate :: SaturationConfig -> [Rule] -> Term -> Either SaturationError EGraphSnapshot
saturate cfg rules term = do
    checkConfigLimits cfg
    _ <- mapLeft (const SaturationNoRootEClass) (compileRewriteProgram rules)
    checkIterationBound cfg rules
    checkENodeBound cfg term
    checkEClassBound cfg term
    mapLeft (const SaturationNoRootEClass) (termToEGraph term)

checkConfigLimits :: SaturationConfig -> Either SaturationError ()
checkConfigLimits cfg
    | maxIterations cfg <= 0 = Left (SaturationIterationLimit (maxIterations cfg))
    | maxENodes cfg <= 0 = Left (SaturationENodeLimit (maxENodes cfg))
    | maxEClasses cfg <= 0 = Left (SaturationEClassLimit (maxEClasses cfg))
    | otherwise = Right ()

checkIterationBound :: SaturationConfig -> [Rule] -> Either SaturationError ()
checkIterationBound cfg rules
    | simulatedIterations > maxIterations cfg = Left (SaturationIterationLimit (maxIterations cfg))
    | otherwise = Right ()
  where
    simulatedIterations =
        if null rules
            then 0
            else 1

checkENodeBound :: SaturationConfig -> Term -> Either SaturationError ()
checkENodeBound cfg term
    | eNodeCount > maxENodes cfg = Left (SaturationENodeLimit (maxENodes cfg))
    | otherwise = Right ()
  where
    eNodeCount = countENodes term

checkEClassBound :: SaturationConfig -> Term -> Either SaturationError ()
checkEClassBound cfg term
    | eClassCount > maxEClasses cfg = Left (SaturationEClassLimit (maxEClasses cfg))
    | otherwise = Right ()
  where
    eClassCount = countEClasses term

countENodes :: Term -> Int
countENodes term = case term of
    Node _ children ->
        1 + sum (map countENodes children)
    _ ->
        1

countEClasses :: Term -> Int
countEClasses term = Set.size (Set.fromList (collectSubterms term))

collectSubterms :: Term -> [Term]
collectSubterms term = case term of
    Node _ children ->
        term : concatMap collectSubterms children
    _ ->
        [term]

mapLeft :: (left -> left') -> Either left right -> Either left' right
mapLeft f eitherValue = case eitherValue of
    Left err ->
        Left (f err)
    Right ok ->
        Right ok
