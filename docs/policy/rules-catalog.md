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
