# Symbolic Implementation Strategy

## Objective

Define the authoritative strategy for evolving the symbolic package from type scaffolds into a programmable symbolic algebra system with a `hegg`-backed e-graph core.

This document is architecture-level source of truth. Execution slicing and PR cadence live in `docs/modules/Symbolic.Implementation.Plan.md`.

## Big Picture

- `Term` remains the canonical user-facing symbolic tree model.
- Rule execution is performed by an internal e-graph engine backed by `hegg`.
- Rewrite mode is equality saturation by default.
- Extraction is deterministic using `rule-cost + size` objective.
- Public module APIs remain project-owned and must not expose raw `hegg` types.

## Core Design Decisions

### 1. Canonical External Representation

- All DSL parsing and pretty printing use project `Term`/`Pattern`/`Rule` contracts.
- E-graph nodes are internal execution form, not public interface.

### 2. `hegg` as Execution Backend

- `hegg` is the canonical equivalence engine.
- E-class/e-node operations are wrapped behind local modules in `Symbolic.Engine.EGraph.*`.

### 3. Equality Saturation First

- Primary rewrite mode is saturation with explicit limits.
- Single-step tree rewrite is not the core execution path.

### 4. Deterministic Extraction

- Extraction objective is deterministic and stable:
  1. minimize aggregate rule cost,
  2. tie-break by term size,
  3. final tie-break by stable canonical ordering.

### 5. Local API Boundary

- External/public APIs expose project types only.
- `hegg` type details are confined to adapter modules.
- Upstream dependency changes must not force immediate public API breaks.

### 6. Strategy as Saturation Policy

- `Strategy` controls saturation/extraction behavior rather than imperative tree traversal.
- Strategy semantics must remain deterministic by default.

### 7. Trace and Corpus Are First-Class

- Successful execution must produce reproducible rewrite traces.
- Corpus runner becomes the regression surface for symbolic behavior.

## Target Module Topology

Planned internal execution modules:

- `Symbolic.Engine.EGraph.Build`
- `Symbolic.Engine.EGraph.Rewrite`
- `Symbolic.Engine.EGraph.Saturate`
- `Symbolic.Engine.EGraph.Extract`
- `Symbolic.Engine.EGraph.Translate`

Existing public modules (`Symbolic.Term`, `Symbolic.Rule`, `Symbolic.Engine.Apply`, `Symbolic.Engine.Search`, `Symbolic.Strategy`) remain user-facing contracts and delegate to this topology.

## Error Model

All recoverable failures are typed values.

Planned failure families:

- translation failures (`Term`/`Pattern`/`Rule` <-> e-graph)
- rewrite compilation failures
- saturation limits (iteration, e-node, e-class)
- extraction failures (missing root class, unsupported cost shape)
- parse failures (line/column/message)

## Semantic Milestones

1. Milestone A: term/rule translation into internal e-graph form.
2. Milestone B: rewrite compilation and bounded equality saturation.
3. Milestone C: deterministic extraction and cost accounting.
4. Milestone D: strategy mapping to saturation policy.
5. Milestone E: DSL + corpus integration on e-graph backend.
6. Milestone F: advanced optimizations (deferred).

## Performance and Benchmark Policy

- Benchmark tooling remains in-repo and preserved.
- Current CI posture temporarily skips benchmark gate execution via `SKIP_BENCHMARK_POLICY_CHECK=1`.
- Symbolic e-graph benchmarks are introduced only after corpus-backed execution stabilizes.
- When symbolic benchmarks are added, they must include:
  1. checked-in baselines,
  2. deterministic benchmark names,
  3. enforced regression thresholds.

## Rollout Contract

Each feature slice must be delivered by separate PR chain:

1. `TYPES` PR: API/types/contracts only.
2. `TESTS` PR: failing-first unit/integration/property tests.
3. `IMPL` PR: production behavior satisfying tests.

No slice may skip phase ordering.

## Deferred Scope

- AC/associative-commutative matching and canonicalization.
- Proof explanation/minimal proof extraction.
- Non-deterministic extractor experimentation.
- Cross-theory optimizations and external CAS interoperability.
