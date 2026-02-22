# symbolic-algebra-agentic-collab

Haskell scaffold for a symbolic algebra project with an agentic development loop.

## Quickstart

```bash
cabal build all
cabal test all
./scripts/format-check.sh
./scripts/lint.sh
./scripts/policy/check-all.sh
```

## Formatting and Linting Policy

- Formatting is enforced with `fourmolu` using `.fourmolu.yaml`.
- Linting is enforced with `hlint` using `.hlint.yaml`.
- Partial-function bans are enforced by `scripts/policy/check-no-partials.sh`.
- `String`/`[Char]` are banned in Haskell source via `scripts/policy/check-no-string.sh`.
- Rule freshness, policy coverage, and dead-rule checks are enforced via:
  - `scripts/policy/check-rule-freshness.sh`
  - `scripts/policy/check-policy-coverage.sh`
  - `scripts/policy/check-dead-rules.sh`
- CI and local checks both run:
  - `./scripts/format-check.sh`
  - `./scripts/lint.sh`
  - `./scripts/policy/check-all.sh`

Use `./scripts/format.sh` to rewrite files in place.

## Agentic Workflow Entry Points

- Issue template: `.github/ISSUE_TEMPLATE/agent_task.yml`
- PR contract: `.github/pull_request_template.md`
- CI policy checks: `.github/workflows/ci.yml`
- Agent loop trigger: `.github/workflows/agent-loop.yml`
- Daily policy adaptation: `.github/workflows/policy-daily.yml`
- Schemas: `schemas/`
- Protocol and architecture docs: `docs/`

## Multi-Agent Review Gate

- PR review artifacts are expected from three reviewers:
  - Claude
  - Gemini
  - Codex
- Aggregation gate requires:
  - at least 2 of 3 approvals,
  - no `blocking=true`,
  - no `critical` severity findings.
- Reviewer jobs are executed on a self-hosted Linux runner.
- Local CLIs must be installed and authenticated on the runner account:
  - `claude`
  - `gemini`
  - `codex`
- Local CLI availability check:
  - `./scripts/agent/check-cli-health.sh`
  - Per-agent check: `./scripts/agent/check-cli-health.sh --agent claude`
  - Optional non-interactive probe: `./scripts/agent/check-cli-health.sh --probe --timeout 60`

## Daily Policy Adaptation

- A scheduled workflow collects CI + review signals every day.
- It generates:
  - `artifacts/policy-signals/YYYY-MM-DD.json`
  - `artifacts/policy-proposals/YYYY-MM-DD.{json,md}`
- It opens/updates a daily policy PR for human final approval.

## Logging Defaults

- `APP_ENV=prod`: no-op logging by default.
- `APP_ENV=dev` or `APP_ENV=ci`: info-level logging to stderr by default.
- Optional overrides:
  - `LOG_LEVEL=debug|info|warn|error`
  - `LOG_SINK=stderr|noop|file:/tmp/app.log`
