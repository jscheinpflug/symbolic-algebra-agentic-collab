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
- Benchmark regression checks are enforced via:
  - `scripts/policy/check-bench-regressions.sh`
  - `scripts/bench/run-benchmarks.sh`
  - `scripts/bench/check-regressions.py`
  - `bench/baseline/workflow-benchmarks.json`
- CI and local checks both run:
  - `./scripts/format-check.sh`
  - `./scripts/lint.sh`
  - `./scripts/policy/check-all.sh`

Benchmark regression threshold defaults to `10%` via `BENCH_REGRESSION_THRESHOLD_PERCENT`.
Benchmark runtime defaults to `1.0s` per scenario via `BENCHMARK_TIME_LIMIT`.
The regression gate only fails when slowdown exceeds threshold and the benchmark mean lower bound also exceeds the threshold.

Use `./scripts/format.sh` to rewrite files in place.

## Agentic Workflow Entry Points

- Issue template: `.github/ISSUE_TEMPLATE/agent_task.yml`
- PR contract: `.github/pull_request_template.md`
- CI policy checks: `.github/workflows/ci.yml`
- Issue governance loop: `.github/workflows/agent-loop.yml`
- Trusted local review loop: `.github/workflows/trusted-agent-review.yml`
- Trusted review comment-dispatch loop: `.github/workflows/trusted-review-dispatch.yml`
- Daily policy adaptation: `.github/workflows/policy-daily.yml`
- Reviewer policy: `.agent-reviewer-policy.json`
- Schemas: `schemas/`
- Protocol and architecture docs: `docs/`

## Multi-Agent Review Gate

- PR review artifacts are expected from three reviewers:
  - Claude
  - Gemini
  - Codex
- Aggregation gate requires:
  - valid artifacts from all available required reviewers,
  - at least `minimum_required_approvals` available reviewers from `.agent-reviewer-policy.json` (default `2`).
- Reviewer verdict outcomes are surfaced in the summary as:
  - `decision=approve|hold`
  - `strict_gate_passed=true|false`
  and do not hard-fail the infrastructure aggregate step.
- Standard trust split:
  - `pull_request` CI runs only on GitHub-hosted runners (`ubuntu-latest`), with no local model execution.
  - Local model reviews run only in manually dispatched trusted workflow.
- Trusted review workflow validates PR trust before self-hosted execution.
- Trusted review can be dispatched from PR comments by trusted users:
  - `/trusted-review`
  - `/trusted-review timeout=600`
  - `/trusted-review no-gemini`
  - `/trusted-review timeout=600 no-gemini`
- Reviewer baseline is loaded from `.agent-reviewer-policy.json` (default: `claude=on`, `gemini=off`, `codex=on`).
- Effective reviewers for a run are: `policy-enabled` AND `dispatch override` AND `health-check available`.
- Trusted workflow writes commit status context `trusted-agent-review/aggregate` on the PR head SHA.
- Local CLIs must be installed and authenticated on the runner account:
  - `claude`
  - `gemini`
  - `codex`
- Reviewer availability is probed first; unavailable reviewers are skipped automatically.
- Available reviewer count must still satisfy `minimum_required_approvals` from policy.
- For protected branches, require status checks:
  - `lint-format-build-test`
  - `trusted-agent-review/aggregate`
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
