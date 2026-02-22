module Main (main) where

import Control.Monad (foldM)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import SymbolicAlgebraAgenticCollab.Workflow
import System.Exit (exitFailure)

main :: IO ()
main = do
    runHappyPathTest
    runRetryWithinLimitTest
    runRetryExhaustionTest
    runConflictEscalationTest
    runInvalidTransitionTest
    TIO.putStrLn "All tests passed."

runHappyPathTest :: IO ()
runHappyPathTest = do
    finalState <- runEvents defaultWorkflowConfig DraftingBrief happyPathEvents
    assertRight "happy path closes as approved" ClosedApproved finalState

runRetryWithinLimitTest :: IO ()
runRetryWithinLimitTest = do
    let events =
            [ SubmitBrief
            , ApproveBrief
            , SubmitImplementation
            , SubmitReview ReviewChangesRequested
            ]
    finalState <- runEvents defaultWorkflowConfig DraftingBrief events
    assertRight "first review request returns to implementation" (Implementing 1) finalState

runRetryExhaustionTest :: IO ()
runRetryExhaustionTest = do
    let events =
            [ SubmitBrief
            , ApproveBrief
            , SubmitImplementation
            , SubmitReview ReviewChangesRequested
            , SubmitImplementation
            , SubmitReview ReviewChangesRequested
            , SubmitImplementation
            , SubmitReview ReviewChangesRequested
            ]
    finalState <- runEvents defaultWorkflowConfig DraftingBrief events
    assertRight "third requested revision escalates" Escalated finalState

runConflictEscalationTest :: IO ()
runConflictEscalationTest = do
    let events =
            [ SubmitBrief
            , ApproveBrief
            , SubmitImplementation
            , SubmitReview ReviewConflict
            , SubmitReview ReviewConflict
            ]
    finalState <- runEvents defaultWorkflowConfig DraftingBrief events
    assertRight "conflict during tie-break escalates" Escalated finalState

runInvalidTransitionTest :: IO ()
runInvalidTransitionTest = do
    let result = transition defaultWorkflowConfig DraftingBrief ApproveBrief
    assertLeft "cannot approve a brief before submission" result

happyPathEvents :: [WorkflowEvent]
happyPathEvents =
    [ SubmitBrief
    , ApproveBrief
    , SubmitImplementation
    , SubmitReview ReviewApproved
    , SubmitFinalDecision FinalApprove
    ]

runEvents :: WorkflowConfig -> WorkflowState -> [WorkflowEvent] -> IO (Either TransitionError WorkflowState)
runEvents cfg start events = pure (foldM (transition cfg) start events)

assertRight :: (Eq a, Show a, Show e) => Text -> a -> Either e a -> IO ()
assertRight label expected result = case result of
    Right actual ->
        assertEqual label expected actual
    Left err -> do
        TIO.putStrLn ("[FAIL] " <> label)
        TIO.putStrLn ("  expected Right " <> T.pack (show expected))
        TIO.putStrLn ("  got Left " <> T.pack (show err))
        exitFailure

assertLeft :: Text -> Either a b -> IO ()
assertLeft label result = case result of
    Left _ ->
        TIO.putStrLn ("[PASS] " <> label)
    Right _ -> do
        TIO.putStrLn ("[FAIL] " <> label)
        TIO.putStrLn "  expected Left _"
        TIO.putStrLn "  got Right _"
        exitFailure

assertEqual :: (Eq a, Show a) => Text -> a -> a -> IO ()
assertEqual label expected actual
    | expected == actual =
        TIO.putStrLn ("[PASS] " <> label)
    | otherwise = do
        TIO.putStrLn ("[FAIL] " <> label)
        TIO.putStrLn ("  expected: " <> T.pack (show expected))
        TIO.putStrLn ("  actual:   " <> T.pack (show actual))
        exitFailure
