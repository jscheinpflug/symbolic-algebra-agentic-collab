## Problem

The repository has symbolic type scaffolds and test contracts, but the implementation roadmap still assumes tree-step rewriting instead of the newly chosen `hegg` e-graph backend.

## Goal

Define a decision-complete symbolic implementation strategy and phase-sliced roadmap aligned to:

- `hegg`-backed equality saturation,
- deterministic extraction by `rule-cost + size`,
- wrapped internal APIs (no public `hegg` type leakage).

## Non-Goals

- Implementing runtime symbolic behavior in this change.
- Adding or changing symbolic benchmark suites in this change.
- Changing the TDD phase enforcement contract.

## Public API Impact

No runtime behavior changes in this phase. This change updates planned API contracts and rollout slices for future implementation PRs.

## Risks

- Incomplete wrapper boundaries could leak backend details into public modules.
- Saturation/extraction semantics could drift if not locked in tests early.
- DSL integration could introduce non-deterministic behavior if cost/tie-break rules are ambiguous.

## Acceptance Criteria

- Strategy doc reflects `hegg` e-graph architecture and deterministic extraction policy.
- Implementation plan doc provides execution-ready slice/phase breakdown for e-graph rollout.
- Phase artifact remains valid and references updated module plan docs.
