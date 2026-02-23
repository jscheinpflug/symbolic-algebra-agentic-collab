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
