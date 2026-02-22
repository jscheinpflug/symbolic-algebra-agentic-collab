# Architecture Layers

## Layers

1. Contracts layer
- Files: `schemas/`, `.github/ISSUE_TEMPLATE/`, `.github/pull_request_template.md`, `.agent-reviewer-policy.json`
- Purpose: machine-readable workflow contracts.

2. Core domain layer
- Files: `src/SymbolicAlgebraAgenticCollab/Workflow.hs`
- Purpose: typed state machine and transition logic.

3. Adapter/automation layer
- Files: `scripts/`, `.github/workflows/`
- Purpose: policy enforcement and automation.

## Allowed Dependency Directions

- Adapter/automation -> Contracts
- Adapter/automation -> Core domain
- Core domain -> Contracts (conceptual only, not runtime imports)
- Contracts -> none

## Forbidden Directions

- Core domain importing workflow scripts.
- Contracts depending on runtime modules.
- Test or CI logic bypassing contracts in `schemas/` and templates.
