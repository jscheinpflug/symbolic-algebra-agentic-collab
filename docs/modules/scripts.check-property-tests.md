# scripts/policy/check-property-tests.sh

## Purpose

Enforce baseline property-based test coverage for core symbolic AST contracts.

## Public Interface

- Script path: `scripts/policy/check-property-tests.sh`
- Called by: `scripts/policy/check-all.sh`
- Inputs: property test files under `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/`

## Invariants

- Required property test files must exist for `Term`, `Pattern`, and `Rule`.
- Each required file must include at least one `prop_* :: Property` declaration.
- Each required file must integrate QuickCheck (`Test.QuickCheck` and/or `Test.Hspec.QuickCheck`).

## Feature Progress

- [x] Required-file checks implemented
- [x] Property declaration checks implemented
- [x] QuickCheck usage checks implemented

## Test Status

- Verified through policy execution in `./scripts/policy/check-all.sh`.

## Known Gaps / Next Steps

- Expand baseline beyond core AST modules as implementation grows.

## Change Log

- 2026-02-23: Initial property-coverage policy script and module documentation added.
