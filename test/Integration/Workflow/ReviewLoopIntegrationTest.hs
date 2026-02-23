module Integration.Workflow.ReviewLoopIntegrationTest (spec) where

import Support.WorkflowHarness (happyPathEvents, runEvents)
import SymbolicAlgebraAgenticCollab.Workflow
import Test.Hspec

spec :: Spec
spec =
    describe "Workflow integration" $ do
        it "reaches closed-approved across full review flow" $ do
            finalState <- runEvents defaultWorkflowConfig DraftingBrief happyPathEvents
            finalState `shouldBe` Right ClosedApproved

        it "reaches closed-hold when final decision is hold" $ do
            let events =
                    [ SubmitBrief
                    , ApproveBrief
                    , SubmitImplementation
                    , SubmitReview ReviewApproved
                    , SubmitFinalDecision FinalHold
                    ]
            finalState <- runEvents defaultWorkflowConfig DraftingBrief events
            finalState `shouldBe` Right ClosedHold
