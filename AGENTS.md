# AGENTS.md

This file is intentionally short. Use repository contracts instead of long prompt rules.

## Navigation

- Project map: `docs/index.md`
- Architecture boundaries: `docs/architecture/layers.md`
- Agentic workflow contract: `docs/domains/agentic-loop.md`
- Logging contract: `docs/domains/logging.md`
- Safety contract: `docs/domains/safety.md`
- Rules catalog: `docs/policy/rules-catalog.md`
- Policy changelog: `docs/policy/changelog.md`
- Schemas: `schemas/`
- Policy checks: `scripts/policy/check-all.sh`

## Required Local Checks Before PR

```bash
./scripts/format-check.sh
./scripts/lint.sh
./scripts/policy/check-all.sh
cabal test all
```

## Process Rule

If a rule is important, encode it in types, tests, schemas, templates, or CI checks.
