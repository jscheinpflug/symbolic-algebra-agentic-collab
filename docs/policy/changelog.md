# Policy Changelog

## 2026-02-22

1. Initialized daily policy adaptation workflow.
2. Added policy signal and policy proposal schemas.
3. Added rule freshness, dead-rule, and policy-coverage checks.
4. Added benchmark regression gating with criterion, checked-in baseline, and CI policy enforcement.

## 2026-02-23

1. Added a TDD phase workflow contract (`docs/domains/tdd-phases.md`) with strict `TYPES -> TESTS -> IMPL` policy gates.
2. Added `schemas/tdd-phase.schema.json` and required per-feature phase artifacts under `artifacts/tdd/`.
3. Added `scripts/policy/check-tdd-phase.sh` with feature context validation and module-doc update enforcement.
4. Updated PR template and CI required sections to include TDD phase metadata and feature context.
5. Registered RULE-008 for phase-gate enforcement and updated policy coverage requirements.
6. Incorporated reviewer feedback: phase-order prerequisite checks, schema-aligned key strictness, and commit-range/error-message edge-case fixes in `check-tdd-phase.sh`.
7. Aligned enforcement with contract by removing mandatory per-phase `FEATURE.md` edits while retaining feature context existence and heading validation.
8. Tightened feedback follow-up: `TESTS` phase now forbids `scripts/` changes, and bootstrap bypass is one-time based on base-branch rollout-file absence.
9. Added fixture-based regression tests for TDD phase enforcement and removed `HEAD~1` range fallback to avoid partial PR-range validation.
10. Added a dedicated testing contract (`docs/domains/testing.md`) that defines mirrored unit tests, integration test placement, and core property-test requirements.
11. Added `scripts/policy/check-test-layout.sh` to enforce test layout mirroring and naming contracts.
12. Added `scripts/policy/check-property-tests.sh` to enforce baseline QuickCheck property coverage for symbolic core AST modules.
13. Registered RULE-009 and extended policy-coverage requirements for `unit-tests`, `integration-tests`, `property-tests`, and `test-layout`.

## 2026-03-01

1. Added daily policy signal artifact: `artifacts/policy-signals/2026-03-01.json`.
2. Added daily policy proposal artifacts under `artifacts/policy-proposals/`.
