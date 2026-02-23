# Rules Catalog

This is the canonical registry for enforced project rules.

| rule_id | owner | enforcement_point | coverage_tags | last_reviewed | freshness_sla_days | rationale |
| --- | --- | --- | --- | --- | --- | --- |
| RULE-001 | platform | `.github/workflows/ci.yml`, `scripts/policy/check-all.sh` | build, tests, format, lint | 2026-02-22 | 30 | Core quality checks must block merges. |
| RULE-002 | platform | `.github/workflows/agent-loop.yml` | issue-contract, pr-contract, review-findings | 2026-02-22 | 30 | Agent workflow contracts must stay structured and auditable. |
| RULE-003 | platform | `scripts/policy/check-schemas.sh` | policy-schema | 2026-02-22 | 30 | Contract schema files must remain valid JSON syntax. |
| RULE-004 | platform | `scripts/policy/check-doc-index.sh` | policy-docs | 2026-02-22 | 30 | Documentation links and path references must not drift. |
| RULE-005 | platform | `scripts/policy/check-no-partials.sh`, `scripts/policy/check-no-string.sh` | partial-ban, string-ban | 2026-02-22 | 30 | Safety and data representation rules must be mechanically enforced. |
| RULE-006 | platform | `scripts/policy/check-rule-freshness.sh`, `scripts/policy/check-policy-coverage.sh`, `scripts/policy/check-dead-rules.sh`, `.github/workflows/policy-daily.yml` | rule-freshness, policy-coverage, dead-rules, review-findings | 2026-02-22 | 30 | Rule maintenance must be continuous and evidence driven. |
| RULE-007 | platform | `scripts/policy/check-bench-regressions.sh`, `scripts/bench/check-regressions.py`, `scripts/bench/check-cost-sanity.py`, `bench/baseline/workflow-benchmarks.json` | benchmark, baseline-presence, performance-regression | 2026-02-22 | 30 | Performance regressions and missing baseline coverage must block merges. |
| RULE-008 | platform | `scripts/policy/check-tdd-phase.sh`, `.github/workflows/ci.yml`, `.github/pull_request_template.md`, `schemas/tdd-phase.schema.json`, `docs/domains/tdd-phases.md` | types-first, tests-first, phase-gate, feature-context, module-docs | 2026-02-23 | 30 | Types/tests/implementation phase ordering and reviewer feature context must be mechanically enforced. |
| RULE-009 | platform | `scripts/policy/check-test-layout.sh`, `scripts/policy/check-property-tests.sh`, `docs/domains/testing.md` | tests, unit-tests, integration-tests, property-tests, test-layout | 2026-02-23 | 30 | Test organization and core property coverage must be mechanically enforced. |
