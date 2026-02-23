module Unit.SymbolicAlgebraAgenticCollab.WorkflowTest (spec) where

import Support.WorkflowHarness (happyPathEvents, runEvents)
import SymbolicAlgebraAgenticCollab.Workflow
import Test.Hspec

spec :: Spec
spec =
    describe "Workflow" $ do
        it "closes as approved on the happy path" $ do
            finalState <- runEvents defaultWorkflowConfig DraftingBrief happyPathEvents
            finalState `shouldBe` Right ClosedApproved

        it "first requested revision returns to implementation" $ do
            let events =
                    [ SubmitBrief
                    , ApproveBrief
                    , SubmitImplementation
                    , SubmitReview ReviewChangesRequested
                    ]
            finalState <- runEvents defaultWorkflowConfig DraftingBrief events
            finalState `shouldBe` Right (Implementing 1)

        it "third requested revision escalates" $ do
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
            finalState `shouldBe` Right Escalated

        it "tie-break conflict escalates" $ do
            let events =
                    [ SubmitBrief
                    , ApproveBrief
                    , SubmitImplementation
                    , SubmitReview ReviewConflict
                    , SubmitReview ReviewConflict
                    ]
            finalState <- runEvents defaultWorkflowConfig DraftingBrief events
            finalState `shouldBe` Right Escalated

        it "disallows approving a brief before submission" $ do
            transition defaultWorkflowConfig DraftingBrief ApproveBrief
                `shouldBe` Left (InvalidTransition DraftingBrief ApproveBrief)
