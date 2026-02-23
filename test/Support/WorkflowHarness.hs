module Support.WorkflowHarness (
    happyPathEvents,
    runEvents,
) where

import Control.Monad (foldM)
import SymbolicAlgebraAgenticCollab.Workflow

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
