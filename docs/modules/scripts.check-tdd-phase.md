# scripts/policy/check-tdd-phase.sh

## Purpose

Enforce repository TDD phase workflow (`TYPES -> TESTS -> IMPL`) and reviewer context artifacts.

## Public Interface

- Script path: `scripts/policy/check-tdd-phase.sh`
- Called by: `scripts/policy/check-all.sh`
- Inputs: git diff state + `artifacts/tdd/<feature-id>/<phase>.json`

## Invariants

- Exactly one phase artifact JSON changed per PR.
- Artifact path must match payload fields (`feature_id`, `phase`).
- Feature context file exists and contains required headings.
- Feature context file is not required to be modified in every phase PR.
- Referenced module docs exist and are updated in the same PR.
- `TESTS` phase forbids `scripts/` changes.

## Feature Progress

- [x] Phase artifact discovery and validation
- [x] Feature context heading enforcement
- [x] Phase-specific path restrictions
- [x] Module-doc update enforcement
- [x] Phase ordering enforcement (`TYPES -> TESTS -> IMPL`)
- [x] Schema-aligned additional-properties enforcement
- [x] Scoped bootstrap exception (`policy-tdd-phase-gate` only)

## Test Status

- Covered by policy integration run via `./scripts/policy/check-all.sh`.
- Edge-case fixes applied for:
  - newline rendering in violation output,
  - empty merge-base handling,
  - empty-change detection in pull request context.

## Known Gaps / Next Steps

- Add fixture-based script tests to make edge-case behavior fully regression-tested.

## Change Log

- 2026-02-23: Initial module doc and enforcement script contract added.
- 2026-02-23: Added phase-order checks, stricter artifact key validation, and reviewer-requested edge-case fixes.
- 2026-02-23: Removed per-PR feature-context edit requirement; kept heading validation and path consistency checks.
- 2026-02-23: Disallowed `scripts/` changes during TESTS phase and hardened bootstrap bypass to be one-time by base-rollout detection.
