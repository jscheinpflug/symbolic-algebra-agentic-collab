module SymbolicAlgebraAgenticCollab.Workflow (
    FinalDecision (..),
    RetryLimit (..),
    ReviewVerdict (..),
    TransitionError (..),
    WorkflowConfig (..),
    WorkflowEvent (..),
    WorkflowState (..),
    defaultWorkflowConfig,
    transition,
) where

newtype RetryLimit = RetryLimit
    { getRetryLimit :: Int
    }
    deriving (Eq, Show)

data WorkflowConfig = WorkflowConfig
    { retryLimit :: RetryLimit
    }
    deriving (Eq, Show)

defaultWorkflowConfig :: WorkflowConfig
defaultWorkflowConfig = WorkflowConfig{retryLimit = RetryLimit 2}

data WorkflowState
    = DraftingBrief
    | WaitingBriefApproval
    | Implementing Int
    | UnderReview Int
    | TieBreakReview Int
    | WaitingFinalDecision
    | Escalated
    | ClosedApproved
    | ClosedHold
    deriving (Eq, Show)

data ReviewVerdict
    = ReviewApproved
    | ReviewChangesRequested
    | ReviewConflict
    deriving (Eq, Show)

data FinalDecision
    = FinalApprove
    | FinalHold
    deriving (Eq, Show)

data WorkflowEvent
    = SubmitBrief
    | ApproveBrief
    | RejectBrief
    | SubmitImplementation
    | SubmitReview ReviewVerdict
    | SubmitFinalDecision FinalDecision
    deriving (Eq, Show)

data TransitionError = InvalidTransition WorkflowState WorkflowEvent
    deriving (Eq, Show)

transition :: WorkflowConfig -> WorkflowState -> WorkflowEvent -> Either TransitionError WorkflowState
transition cfg state event = case (state, event) of
    (DraftingBrief, SubmitBrief) ->
        Right WaitingBriefApproval
    (WaitingBriefApproval, ApproveBrief) ->
        Right (Implementing 0)
    (WaitingBriefApproval, RejectBrief) ->
        Right DraftingBrief
    (Implementing revisionsUsed, SubmitImplementation) ->
        Right (UnderReview revisionsUsed)
    (UnderReview _, SubmitReview ReviewApproved) ->
        Right WaitingFinalDecision
    (UnderReview revisionsUsed, SubmitReview ReviewChangesRequested) ->
        Right (nextReviewOutcome cfg revisionsUsed)
    (UnderReview revisionsUsed, SubmitReview ReviewConflict) ->
        Right (TieBreakReview revisionsUsed)
    (TieBreakReview _, SubmitReview ReviewApproved) ->
        Right WaitingFinalDecision
    (TieBreakReview revisionsUsed, SubmitReview ReviewChangesRequested) ->
        Right (nextReviewOutcome cfg revisionsUsed)
    (TieBreakReview _, SubmitReview ReviewConflict) ->
        Right Escalated
    (WaitingFinalDecision, SubmitFinalDecision FinalApprove) ->
        Right ClosedApproved
    (WaitingFinalDecision, SubmitFinalDecision FinalHold) ->
        Right ClosedHold
    _ ->
        Left (InvalidTransition state event)

nextReviewOutcome :: WorkflowConfig -> Int -> WorkflowState
nextReviewOutcome cfg revisionsUsed
    | canAutoRetry cfg revisionsUsed = Implementing (revisionsUsed + 1)
    | otherwise = Escalated

canAutoRetry :: WorkflowConfig -> Int -> Bool
canAutoRetry WorkflowConfig{retryLimit = RetryLimit maxRetries} revisionsUsed =
    revisionsUsed < max 0 maxRetries
