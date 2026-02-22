module Main (main) where

import Data.Text qualified as T
import SymbolicAlgebraAgenticCollab (
    WorkflowEvent (SubmitBrief),
    WorkflowState (DraftingBrief),
    helloMessage,
    logConfigFromEnv,
    logError,
    logInfo,
    nextState,
    withLogging,
 )

main :: IO ()
main = do
    logConfig <- logConfigFromEnv
    withLogging logConfig $ do
        logInfo helloMessage
        logInfo "Running first workflow transition demo."
        case nextState DraftingBrief SubmitBrief of
            Right newState ->
                logInfo ("Transition result: " <> T.pack (show newState))
            Left err ->
                logError ("Transition failed: " <> T.pack (show err))
