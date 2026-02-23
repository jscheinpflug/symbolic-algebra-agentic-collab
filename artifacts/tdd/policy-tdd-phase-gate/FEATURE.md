## Problem

Workflow intent says types-first, tests-second, implementation-third, but this order is not mechanically enforced.

## Goal

Add machine-enforced TDD phase gating so PRs are blocked when they bypass the required phase order or omit reviewer context.

## Non-Goals

- Enforcing historical PR compliance retroactively.
- Calling external APIs to validate referenced PR numbers.

## Public API Impact

Introduces a new project workflow artifact schema and policy script. No runtime library API changes.

## Risks

- Overly strict path rules may block legitimate edge cases.
- Diff-range detection may vary across local and CI environments.

## Acceptance Criteria

- PRs without valid TDD phase artifacts fail policy checks.
- PRs missing required feature context fail policy checks.
- PR template and CI enforce required TDD metadata sections.
- Reviewer-raised edge cases are fixed:
  - phase ordering enforcement for TESTS/IMPL,
  - additional-properties rejection for artifacts,
  - merge-base and formatting edge cases in error handling.
- Bootstrap escape hatch is scoped to `policy-tdd-phase-gate` only.
- TESTS phase does not allow `scripts/` implementation changes.
- Bootstrap escape hatch is one-time via base-rollout file absence checks.
