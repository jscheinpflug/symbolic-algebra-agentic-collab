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

- `TYPES` phase only: tests intentionally deferred.

## Known Gaps / Next Steps

- Add parser and round-trip tests in `TESTS` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
