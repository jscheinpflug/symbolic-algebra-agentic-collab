# TDD Phase Contract

## Purpose

Enforce feature delivery in three explicit phases:

1. `TYPES`
2. `TESTS`
3. `IMPL`

This contract is enforced by repository artifacts and CI policy checks, not by reviewer memory.

## Required Feature Artifacts

For each feature id `<feature-id>`:

1. Feature context document:
   - `artifacts/tdd/<feature-id>/FEATURE.md`
2. Phase artifact (exactly one per PR):
   - `artifacts/tdd/<feature-id>/TYPES.json`
   - `artifacts/tdd/<feature-id>/TESTS.json`
   - `artifacts/tdd/<feature-id>/IMPL.json`

Phase artifacts must validate against `schemas/tdd-phase.schema.json`.

## Feature Context Requirements

`FEATURE.md` must include these headings:

- `## Problem`
- `## Goal`
- `## Non-Goals`
- `## Public API Impact`
- `## Risks`
- `## Acceptance Criteria`

## Phase Semantics

### `TYPES`

Focus: type definitions, public interfaces, module skeletons, and contracts.

Policy restrictions:

- Must not change `test/`.
- Must not change `app/`.
- Must not change `bench/`.

### `TESTS`

Focus: failing-first tests and acceptance assertions.

Policy restrictions:

- Must include at least one changed file under `test/`.
- Must not change `src/`.
- Must not change `app/`.
- Must not change `bench/baseline/`.
- Requires existing prerequisite artifact:
  - `artifacts/tdd/<feature-id>/TYPES.json`

### `IMPL`

Focus: implementation to satisfy prior phase tests.

Policy restrictions:

- Must include at least one changed file under `src/`, `app/`, or `scripts/`.
- Must not change `test/`.
- Requires existing prerequisite artifacts:
  - `artifacts/tdd/<feature-id>/TYPES.json`
  - `artifacts/tdd/<feature-id>/TESTS.json`

## Common Per-PR Requirements

1. Exactly one changed phase artifact JSON file.
2. Artifact path must match artifact payload (`feature_id` and `phase`).
3. Artifact `feature_context` path must match `artifacts/tdd/<feature-id>/FEATURE.md`.
4. `FEATURE.md` must exist and satisfy required headings.
   - Updating `FEATURE.md` on every phase PR is optional; required when feature intent/acceptance changes.
5. Every path listed in artifact `module_docs` must:
   - exist, and
   - be changed in the same PR.
6. For `TESTS` and `IMPL`, `depends_on_pr` must be non-null and non-empty.

## Bootstrap Exception

To bootstrap this policy itself, `depends_on_pr: "bootstrap-initial"` is allowed as a one-time exception for missing prerequisite artifacts only when `feature_id` is `policy-tdd-phase-gate`.

## PR Template Requirements

Every PR must include:

- `## TDD Phase`
- `## Feature ID`
- `## Depends On PR`
- `## Feature Context`
- `## Module Docs Updated`

## Enforcement

Primary enforcement point:

- `scripts/policy/check-tdd-phase.sh`

Included in:

- `scripts/policy/check-all.sh`
- `.github/workflows/ci.yml`
