{-# LANGUAGE BangPatterns #-}

module Main (main) where

import Control.Monad (foldM)
import Criterion.Main (Benchmark, bench, bgroup, defaultMain, whnf)
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
    bench (T.unpack label) (whnf runScenarioBatch events)

workflowScenarios :: [(Text, [WorkflowEvent])]
workflowScenarios =
    [
        ( "happy-path"
        ,
            [ SubmitBrief
            , ApproveBrief
            , SubmitImplementation
            , SubmitReview ReviewApproved
            , SubmitFinalDecision FinalApprove
            ]
        )
    ,
        ( "retry-loop"
        ,
            [ SubmitBrief
            , ApproveBrief
            , SubmitImplementation
            , SubmitReview ReviewChangesRequested
            , SubmitImplementation
            , SubmitReview ReviewChangesRequested
            , SubmitImplementation
            , SubmitReview ReviewApproved
            , SubmitFinalDecision FinalApprove
            ]
        )
    ,
        ( "conflict-escalation"
        ,
            [ SubmitBrief
            , ApproveBrief
            , SubmitImplementation
            , SubmitReview ReviewConflict
            , SubmitReview ReviewConflict
            ]
        )
    ,
        ( "reject-resubmit"
        ,
            [ SubmitBrief
            , RejectBrief
            , SubmitBrief
            , ApproveBrief
            , SubmitImplementation
            , SubmitReview ReviewApproved
            , SubmitFinalDecision FinalApprove
            ]
        )
    ]

runScenarioBatch :: [WorkflowEvent] -> Either TransitionError WorkflowState
runScenarioBatch events = go benchmarkIterations (Right DraftingBrief)
  where
    go :: Int -> Either TransitionError WorkflowState -> Either TransitionError WorkflowState
    go 0 !result = result
    go remaining !_ =
        let !next = runScenario events
         in go (remaining - 1) next

runScenario :: [WorkflowEvent] -> Either TransitionError WorkflowState
runScenario =
    foldM (transition defaultWorkflowConfig) DraftingBrief

benchmarkIterations :: Int
benchmarkIterations = 10000000
