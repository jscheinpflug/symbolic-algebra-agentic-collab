module SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Extract (
    ExtractionCost (..),
    extractBest,
    extractBestWithCost,
) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Build (
    EGraphSnapshot,
    snapshotTerm,
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationError (SaturationNoRootEClass),
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Term (..))

data ExtractionCost = ExtractionCost
    { costRule :: Int
    , costSize :: Int
    }
    deriving (Eq, Show)

extractBest :: EGraphSnapshot -> Either SaturationError Term
extractBest snapshot = fst <$> extractBestWithCost snapshot

extractBestWithCost :: EGraphSnapshot -> Either SaturationError (Term, ExtractionCost)
extractBestWithCost snapshot =
    case candidateTerms (snapshotTerm snapshot) of
        [] ->
            Left SaturationNoRootEClass
        candidates ->
            case chooseBestCandidate candidates of
                Nothing ->
                    Left SaturationNoRootEClass
                Just bestTerm ->
                    Right (bestTerm, extractionCost bestTerm)

candidateTerms :: Term -> [Term]
candidateTerms term = case term of
    Node _ _ ->
        collectSubterms term
    _ ->
        []

collectSubterms :: Term -> [Term]
collectSubterms term = case term of
    Node _ children ->
        term : concatMap collectSubterms children
    _ ->
        [term]

chooseBestCandidate :: [Term] -> Maybe Term
chooseBestCandidate = foldl' step Nothing
  where
    step :: Maybe Term -> Term -> Maybe Term
    step current candidate = case current of
        Nothing ->
            Just candidate
        Just best ->
            Just (minByObjective best candidate)

minByObjective :: Term -> Term -> Term
minByObjective leftTerm rightTerm =
    if objectiveKey leftTerm <= objectiveKey rightTerm
        then leftTerm
        else rightTerm

objectiveKey :: Term -> (Int, Int, Term)
objectiveKey term =
    (costRule candidateCost, costSize candidateCost, term)
  where
    candidateCost = extractionCost term

extractionCost :: Term -> ExtractionCost
extractionCost term =
    ExtractionCost
        { costRule = 0
        , costSize = termSize term
        }

termSize :: Term -> Int
termSize term = case term of
    Node _ children ->
        1 + sum (map termSize children)
    _ ->
        1
