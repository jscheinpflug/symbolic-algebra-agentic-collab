# Symbolic.Implementation.Plan

## Purpose

Provide a PR-by-PR execution tracker for delivering the symbolic system on a `hegg` e-graph backend.

## How To Use This Tracker

- This document is the canonical execution board for symbolic implementation.
- Each PR has:
  1. fixed scope,
  2. fixed dependencies,
  3. fixed completion checks.
- Update only the status checkboxes and completion checks as work progresses.

## Global Constraints

- Enforce `TYPES -> TESTS -> IMPL` per feature.
- Exactly one changed phase artifact per PR under `artifacts/tdd/<feature-id>/<PHASE>.json`.
- Every path in artifact `module_docs` must be changed in the same PR.
- Unit tests mirror source structure in `test/Unit`.
- Integration tests live in `test/Integration`.
- Property tests are required for algebraic/deterministic invariants.

## Required Checks (Every PR)

- `./scripts/format-check.sh`
- `./scripts/lint.sh`
- `SKIP_BENCHMARK_POLICY_CHECK=1 ./scripts/policy/check-all.sh`
- `cabal test all`

## Progress Dashboard

- [ ] PR-01 `symbolic-egraph-foundation/TYPES`
- [ ] PR-02 `symbolic-egraph-foundation/TESTS`
- [ ] PR-03 `symbolic-egraph-foundation/IMPL`
- [ ] PR-04 `symbolic-egraph-saturation/TYPES`
- [ ] PR-05 `symbolic-egraph-saturation/TESTS`
- [ ] PR-06 `symbolic-egraph-saturation/IMPL`
- [ ] PR-07 `symbolic-egraph-strategy/TYPES`
- [ ] PR-08 `symbolic-egraph-strategy/TESTS`
- [ ] PR-09 `symbolic-egraph-strategy/IMPL`
- [ ] PR-10 `symbolic-egraph-io/TYPES`
- [ ] PR-11 `symbolic-egraph-io/TESTS`
- [ ] PR-12 `symbolic-egraph-io/IMPL`

## PR Specs

### PR-01: `symbolic-egraph-foundation/TYPES`

- Feature id: `symbolic-egraph-foundation`
- Depends on: none
- Branch: `feature/symbolic-egraph-foundation-types`
- Scope:
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/Build.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/Translate.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Engine/Search.hs`
  - module docs for affected modules
  - `artifacts/tdd/symbolic-egraph-foundation/TYPES.json`
- API contracts to add:

```haskell
data EGraphBuildError
  = BuildUnsupportedTermShape
  | BuildInvalidSymbolEncoding

termToEGraph :: Term -> Either EGraphBuildError EGraphSnapshot
eGraphToTerm :: EGraphSnapshot -> Either EGraphBuildError Term
```

- Progress checks:
  - [ ] phase artifact created and valid
  - [ ] module docs updated in same PR
  - [ ] no behavior implementation added
  - [ ] all required checks pass
  - [ ] PR merged

### PR-02: `symbolic-egraph-foundation/TESTS`

- Feature id: `symbolic-egraph-foundation`
- Depends on: `commit:<PR-01 merge sha>`
- Branch: `feature/symbolic-egraph-foundation-tests`
- Scope:
  - `test/Unit/.../Symbolic/Engine/...`
  - `test/Integration/Symbolic/ContractsIntegrationTest.hs`
  - generators/support files if needed
  - module docs
  - `artifacts/tdd/symbolic-egraph-foundation/TESTS.json`
- Tests to add (failing first):
  - translation roundtrip subset
  - unsupported term shape typed failure
  - deterministic translation representation checks
- Progress checks:
  - [ ] tests fail before implementation
  - [ ] tests are mirrored under unit/integration layout policy
  - [ ] module docs updated in same PR
  - [ ] all required checks pass
  - [ ] PR merged

### PR-03: `symbolic-egraph-foundation/IMPL`

- Feature id: `symbolic-egraph-foundation`
- Depends on: `commit:<PR-02 merge sha>`
- Branch: `feature/symbolic-egraph-foundation-impl`
- Scope:
  - implementation in `Build.hs` and `Translate.hs`
  - wrapper wiring in `Search.hs`
  - module docs
  - `artifacts/tdd/symbolic-egraph-foundation/IMPL.json`
- Implementation goals:
  - translate `Term` into `hegg` internal form
  - translate back for supported subset
  - preserve deterministic mapping behavior
- Progress checks:
  - [ ] all PR-02 tests now pass
  - [ ] no raw `hegg` types exposed in public modules
  - [ ] module docs updated in same PR
  - [ ] all required checks pass
  - [ ] PR merged

### PR-04: `symbolic-egraph-saturation/TYPES`

- Feature id: `symbolic-egraph-saturation`
- Depends on: `commit:<PR-03 merge sha>`
- Branch: `feature/symbolic-egraph-saturation-types`
- Scope:
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/Rewrite.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/Saturate.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Engine/Apply.hs`
  - module docs
  - `artifacts/tdd/symbolic-egraph-saturation/TYPES.json`
- API contracts to add:

```haskell
data SaturationConfig = SaturationConfig
  { maxIterations :: Int
  , maxENodes :: Int
  , maxEClasses :: Int
  }

data SaturationError
  = SaturationIterationLimit Int
  | SaturationENodeLimit Int
  | SaturationEClassLimit Int
  | SaturationNoRootEClass

saturate :: SaturationConfig -> [Rule] -> Term -> Either SaturationError EGraphSnapshot
```

- Progress checks:
  - [ ] phase artifact created and valid
  - [ ] module docs updated in same PR
  - [ ] no implementation logic added
  - [ ] all required checks pass
  - [ ] PR merged

### PR-05: `symbolic-egraph-saturation/TESTS`

- Feature id: `symbolic-egraph-saturation`
- Depends on: `commit:<PR-04 merge sha>`
- Branch: `feature/symbolic-egraph-saturation-tests`
- Scope:
  - unit tests for limits and typed failures
  - integration tests for deterministic saturation behavior
  - module docs
  - `artifacts/tdd/symbolic-egraph-saturation/TESTS.json`
- Tests to add (failing first):
  - iteration limit failure
  - e-node limit failure
  - e-class limit failure
  - stable behavior for same input/rules/config
- Progress checks:
  - [ ] tests fail before implementation
  - [ ] deterministic assertions present
  - [ ] module docs updated in same PR
  - [ ] all required checks pass
  - [ ] PR merged

### PR-06: `symbolic-egraph-saturation/IMPL`

- Feature id: `symbolic-egraph-saturation`
- Depends on: `commit:<PR-05 merge sha>`
- Branch: `feature/symbolic-egraph-saturation-impl`
- Scope:
  - rewrite compilation into `hegg`
  - bounded saturation loop implementation
  - module docs
  - `artifacts/tdd/symbolic-egraph-saturation/IMPL.json`
- Implementation goals:
  - compile `Rule` into internal rewrites
  - enforce all configured limits
  - return typed saturation failures only
- Progress checks:
  - [ ] all PR-05 tests now pass
  - [ ] typed failures for all limit exits
  - [ ] module docs updated in same PR
  - [ ] all required checks pass
  - [ ] PR merged

### PR-07: `symbolic-egraph-strategy/TYPES`

- Feature id: `symbolic-egraph-strategy`
- Depends on: `commit:<PR-06 merge sha>`
- Branch: `feature/symbolic-egraph-strategy-types`
- Scope:
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/Extract.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Strategy.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Engine/Search.hs`
  - module docs
  - `artifacts/tdd/symbolic-egraph-strategy/TYPES.json`
- API contracts to add:

```haskell
data ExtractionCost = ExtractionCost
  { costRule :: Int
  , costSize :: Int
  }

extractBest :: EGraphSnapshot -> Either SaturationError Term
extractBestWithCost :: EGraphSnapshot -> Either SaturationError (Term, ExtractionCost)

runStrategy :: Strategy -> SaturationConfig -> [Rule] -> Term -> Either SaturationError RewriteTrace
```

- Progress checks:
  - [ ] phase artifact created and valid
  - [ ] module docs updated in same PR
  - [ ] no behavior implementation added
  - [ ] all required checks pass
  - [ ] PR merged

### PR-08: `symbolic-egraph-strategy/TESTS`

- Feature id: `symbolic-egraph-strategy`
- Depends on: `commit:<PR-07 merge sha>`
- Branch: `feature/symbolic-egraph-strategy-tests`
- Scope:
  - unit tests for extraction objective and tie-break behavior
  - integration tests for strategy policy determinism
  - module docs
  - `artifacts/tdd/symbolic-egraph-strategy/TESTS.json`
- Tests to add (failing first):
  - extractor minimizes `rule-cost` first
  - extractor tie-break on `size`
  - stable result across repeated runs
- Progress checks:
  - [ ] tests fail before implementation
  - [ ] deterministic objective checks included
  - [ ] module docs updated in same PR
  - [ ] all required checks pass
  - [ ] PR merged

### PR-09: `symbolic-egraph-strategy/IMPL`

- Feature id: `symbolic-egraph-strategy`
- Depends on: `commit:<PR-08 merge sha>`
- Branch: `feature/symbolic-egraph-strategy-impl`
- Scope:
  - deterministic extractor implementation
  - strategy mapping implementation
  - module docs
  - `artifacts/tdd/symbolic-egraph-strategy/IMPL.json`
- Implementation goals:
  - enforce objective ordering exactly
  - ensure deterministic tie-break behavior
  - keep `hegg` internals encapsulated
- Progress checks:
  - [ ] all PR-08 tests now pass
  - [ ] deterministic extraction objective verified
  - [ ] module docs updated in same PR
  - [ ] all required checks pass
  - [ ] PR merged

### PR-10: `symbolic-egraph-io/TYPES`

- Feature id: `symbolic-egraph-io`
- Depends on: `commit:<PR-09 merge sha>`
- Branch: `feature/symbolic-egraph-io-types`
- Scope:
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Dsl/Parser.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Dsl/Pretty.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Corpus.hs`
  - `src/SymbolicAlgebraAgenticCollab/Symbolic/Trace.hs`
  - module docs
  - `artifacts/tdd/symbolic-egraph-io/TYPES.json`
- API contracts to add:

```haskell
executeProgram :: SaturationConfig -> [Rule] -> Term -> Either SaturationError RewriteTrace

data CorpusExpectation
  = ExpectNormalForm Term
  | ExpectTraceLength Int
  | ExpectFailure SaturationError

evaluateCorpusCase :: SaturationConfig -> [Rule] -> CorpusCase -> Either SaturationError RewriteTrace
```

- Progress checks:
  - [ ] phase artifact created and valid
  - [ ] module docs updated in same PR
  - [ ] no behavior implementation added
  - [ ] all required checks pass
  - [ ] PR merged

### PR-11: `symbolic-egraph-io/TESTS`

- Feature id: `symbolic-egraph-io`
- Depends on: `commit:<PR-10 merge sha>`
- Branch: `feature/symbolic-egraph-io-tests`
- Scope:
  - integration tests parse -> saturate -> extract -> pretty
  - corpus determinism regression tests
  - module docs
  - `artifacts/tdd/symbolic-egraph-io/TESTS.json`
- Tests to add (failing first):
  - end-to-end deterministic pipeline
  - corpus expectation success/failure behavior
  - stable trace shape for equivalent runs
- Progress checks:
  - [ ] tests fail before implementation
  - [ ] integration coverage includes full pipeline
  - [ ] module docs updated in same PR
  - [ ] all required checks pass
  - [ ] PR merged

### PR-12: `symbolic-egraph-io/IMPL`

- Feature id: `symbolic-egraph-io`
- Depends on: `commit:<PR-11 merge sha>`
- Branch: `feature/symbolic-egraph-io-impl`
- Scope:
  - end-to-end execution implementation
  - corpus evaluator implementation
  - trace finalization
  - module docs
  - `artifacts/tdd/symbolic-egraph-io/IMPL.json`
- Implementation goals:
  - execute full pipeline on e-graph backend
  - produce deterministic trace/corpus outcomes
  - preserve public API boundary
- Progress checks:
  - [ ] all PR-11 tests now pass
  - [ ] end-to-end flow deterministic
  - [ ] module docs updated in same PR
  - [ ] all required checks pass
  - [ ] PR merged

## Cross-PR Definition of Done

- [ ] All 12 PRs merged in order.
- [ ] No public module exposes raw `hegg` types.
- [ ] Deterministic extraction objective enforced (`rule-cost + size`).
- [ ] Corpus-backed end-to-end deterministic regression path exists.
- [ ] Module docs and phase artifacts are fully updated and consistent.

## Assumptions

- `hegg` is required for execution internals.
- CI benchmark policy remains temporarily skipped via `SKIP_BENCHMARK_POLICY_CHECK=1`.
- AC matching, proof extraction, and advanced optimizations are deferred.
