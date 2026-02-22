module SymbolicAlgebraAgenticCollab (
    helloMessage,
    nextState,
    module SymbolicAlgebraAgenticCollab.Config,
    module SymbolicAlgebraAgenticCollab.Logging,
    module SymbolicAlgebraAgenticCollab.Workflow,
) where

import SymbolicAlgebraAgenticCollab.Config
import SymbolicAlgebraAgenticCollab.Logging
import SymbolicAlgebraAgenticCollab.Workflow

import Data.Text (Text)

helloMessage :: Text
helloMessage =
    "symbolic-algebra-agentic-collab: type/test-driven workflow scaffold"

nextState :: WorkflowState -> WorkflowEvent -> Either TransitionError WorkflowState
nextState = transition defaultWorkflowConfig
