# Symbolic.Dsl.Ast

## Purpose

Define textual DSL AST declarations for symbols, rules, and queries.

## Public Interface

- `SymbolDecl`
- `RuleDecl`
- `QueryDecl`
- `Program`

## Invariants

- AST is a pure representation layer without parser behavior.

## Feature Progress

- [x] Module scaffold created
- [x] AST placeholders added
- [ ] Parse/validation semantics

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.

## Known Gaps / Next Steps

- Implement module behavior and semantic assertions in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
