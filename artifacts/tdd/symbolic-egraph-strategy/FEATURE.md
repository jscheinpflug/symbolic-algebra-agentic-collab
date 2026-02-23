## Problem

The symbolic system currently defines foundational and saturation contracts, but the strategy/extraction layer is missing the types that describe deterministic objectives and rewrite trace planning.

## Goal

Introduce TYPES-phase artifacts that capture:

- extraction cost metadata (`ExtractionCost`, `extractBest`, `extractBestWithCost`)
- strategy execution signatures (`runStrategy`)
- the documentation contracts that tie extraction, strategy, and saturation together

## Non-Goals

- Implementing extractor heuristics or strategy planning logic.
- Adding tests or behavioral wiring in this phase.
- Exposing raw `hegg` internals in new modules.

## Public API Impact

Defines new extractor and strategy-facing signatures to keep future implementation slices from drifting from the desired deterministic objective order.

## Risks

- Missing documentation updates that describe how runStrategy will orchestrate saturation/extraction.
- Introducing accidental behavior by wiring real logic instead of placeholders.

## Acceptance Criteria

- Extraction/strategy modules compile with placeholder contracts only.
- Strategy/runStrategy story is documented in the relevant module docs.
- Phase artifact references the same doc paths that were touched in this PR.
