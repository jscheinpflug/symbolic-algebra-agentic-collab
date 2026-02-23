module Unit.SymbolicAlgebraAgenticCollabTest (spec) where

import Data.Text qualified as T
import SymbolicAlgebraAgenticCollab
import Test.Hspec

spec :: Spec
spec =
    describe "SymbolicAlgebraAgenticCollab" $ do
        it "hello message is not empty" $ do
            T.null helloMessage `shouldBe` False

        it "nextState delegates to transition with default config" $ do
            nextState DraftingBrief SubmitBrief
                `shouldBe` transition defaultWorkflowConfig DraftingBrief SubmitBrief
