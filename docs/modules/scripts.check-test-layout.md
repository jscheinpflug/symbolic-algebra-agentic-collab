# scripts/policy/check-test-layout.sh

## Purpose

Enforce mirrored unit test layout and integration test naming contracts.

## Public Interface

- Script path: `scripts/policy/check-test-layout.sh`
- Called by: `scripts/policy/check-all.sh`
- Inputs: `src/` and `test/` file trees

## Invariants

- `test/Spec.hs` must exist.
- `test/Main.hs` must not exist.
- Each `src/**/*.hs` file must have mirrored `test/Unit/**/*Test.hs`.
- Unit and integration test files must end with `Test.hs`.
- `test/Integration/` must include at least one test file.

## Feature Progress

- [x] Layout checks implemented
- [x] Naming checks implemented
- [x] Mirror checks implemented

## Test Status

- Verified through policy execution in `./scripts/policy/check-all.sh`.

## Known Gaps / Next Steps

- Add fixture-based regression tests for layout edge cases.

## Change Log

- 2026-02-23: Initial enforcement script and module documentation added.
