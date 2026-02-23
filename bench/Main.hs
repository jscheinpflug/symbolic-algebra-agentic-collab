module Main (main) where

import Control.Monad (foldM)
import Criterion.Main (Benchmark, bench, bgroup, defaultMain, nf)
import Data.Text (Text)
import Data.Text qualified as T
import SymbolicAlgebraAgenticCollab.Workflow

main :: IO ()
main =
    defaultMain
        [ bgroup (T.unpack "workflow") (map scenarioBenchmark workflowScenarios)
        ]

scenarioBenchmark :: (Text, [WorkflowEvent]) -> Benchmark
scenarioBenchmark (label, events) =
    bench (T.unpack label) (nf scenarioScore events)

workflowScenarios :: [(Text, [WorkflowEvent])]
workflowScenarios =
    [ ("reject-resubmit-cycles-50000", rejectResubmitEvents 50000)
    , ("reject-resubmit-cycles-100000", rejectResubmitEvents 100000)
    , ("reject-resubmit-cycles-200000", rejectResubmitEvents 200000)
    , ("reject-resubmit-cycles-400000", rejectResubmitEvents 400000)
    ]

happyPathEvents :: [WorkflowEvent]
happyPathEvents =
    [ SubmitBrief
    , ApproveBrief
    , SubmitImplementation
    , SubmitReview ReviewApproved
    , SubmitFinalDecision FinalApprove
    ]

rejectResubmitEvents :: Int -> [WorkflowEvent]
rejectResubmitEvents cycleCount =
    concat (replicate cycleCount [SubmitBrief, RejectBrief]) <> happyPathEvents

scenarioScore :: [WorkflowEvent] -> Int
scenarioScore events = case runScenario events of
    Right workflowState ->
        workflowStateScore workflowState
    Left transitionError ->
        transitionErrorScore transitionError

runScenario :: [WorkflowEvent] -> Either TransitionError WorkflowState
runScenario =
    foldM (transition defaultWorkflowConfig) DraftingBrief

workflowStateScore :: WorkflowState -> Int
workflowStateScore workflowState = case workflowState of
    DraftingBrief -> 0
    WaitingBriefApproval -> 1
    Implementing revisionsUsed -> 2 + revisionsUsed
    UnderReview revisionsUsed -> 3 + revisionsUsed
    TieBreakReview revisionsUsed -> 4 + revisionsUsed
    WaitingFinalDecision -> 5
    Escalated -> 6
    ClosedApproved -> 7
    ClosedHold -> 8

transitionErrorScore :: TransitionError -> Int
transitionErrorScore transitionError = case transitionError of
    InvalidTransition workflowState workflowEvent ->
        1000 + workflowStateScore workflowState + workflowEventScore workflowEvent

workflowEventScore :: WorkflowEvent -> Int
workflowEventScore workflowEvent = case workflowEvent of
    SubmitBrief -> 10
    ApproveBrief -> 11
    RejectBrief -> 12
    SubmitImplementation -> 13
    SubmitReview reviewVerdict -> 14 + reviewVerdictScore reviewVerdict
    SubmitFinalDecision finalDecision -> 17 + finalDecisionScore finalDecision

reviewVerdictScore :: ReviewVerdict -> Int
reviewVerdictScore reviewVerdict = case reviewVerdict of
    ReviewApproved -> 0
    ReviewChangesRequested -> 1
    ReviewConflict -> 2

finalDecisionScore :: FinalDecision -> Int
finalDecisionScore finalDecision = case finalDecision of
    FinalApprove -> 0
    FinalHold -> 1
