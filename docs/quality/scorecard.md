# Quality Scorecard

## Current Baseline

- Build: configured
- Tests: configured with workflow state-machine coverage
- Formatting: enforced with `fourmolu`
- Linting: enforced with `hlint`
- Policy checks: required files, schema syntax, docs index, protocol tags
- Benchmark regression gate: criterion benchmarks with baseline + threshold enforcement
- Logging: typed config with environment-based defaults
- Safety: partial-function ban script + strict compiler warning errors
- Review gate: three reviewer artifacts (Claude/Gemini/Codex) with aggregation policy
- Rule lifecycle: freshness, coverage, and dead-rule checks enabled
- Adaptation cadence: daily policy signal/proposal PR workflow enabled
- TDD phase gate: enforced `TYPES -> TESTS -> IMPL` artifact and path policy checks

## Open Gaps

1. Add architecture import boundary checker beyond documentation.
2. Add stronger semantic validation for generated policy artifacts (beyond required keys/types).
3. Add semantic validation for reviewer command outputs before aggregation.
