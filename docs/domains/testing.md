# Testing Contract

## Purpose

Define a deterministic, file-mirrored testing structure so unit, integration, and property tests remain discoverable and enforceable.

## Required Layout

- Runner entrypoint: `test/Spec.hs`
- Unit tests: `test/Unit/...`
- Integration tests: `test/Integration/...`

### Unit Test Mapping Rule

For every source file `src/<path>/<File>.hs`, a mirrored unit test must exist at:

- `test/Unit/<path>/<File>Test.hs`

This mapping is enforced by `scripts/policy/check-test-layout.sh`.

Exception for TDD `TYPES` phase:

- If a PR is a `TYPES` phase PR and introduces new `src/**/*.hs` files, mirrored unit tests may land in the follow-up `TESTS` phase PR for that feature.
- Existing source files still require mirrored tests.

### Naming Rule

- Unit test files must end with `Test.hs`.
- Integration test files must end with `Test.hs`.
- `test/Main.hs` is deprecated and forbidden once structured layout is enabled.

## Property-Based Test Baseline

Core symbolic AST contracts require property tests in:

- `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/TermTest.hs`
- `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/PatternTest.hs`
- `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/RuleTest.hs`

Each required file must include at least one declaration matching `prop_* :: Property` and QuickCheck usage.

This baseline is enforced by `scripts/policy/check-property-tests.sh`.

## Policy Integration

Both checks are required through:

- `scripts/policy/check-all.sh`
- `.github/workflows/ci.yml` (via `check-all.sh`)
