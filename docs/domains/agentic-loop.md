# Agentic Loop Contract

## Flow

1. Issue is opened with template and label `agent-task`.
2. Brief is posted (`AGENT_BRIEF_V1`) and approved.
3. Implementation proceeds type-first, test-first, then code.
4. Reviews are posted (`AGENT_REVIEW_CLAUDE_V1`, `AGENT_REVIEW_GEMINI_V1`, `AGENT_REVIEW_CODEX_V1`).
5. Final packet is posted (`AGENT_DECISION_PACKET_V1`) for human decision.

## Required PR Sections

- Type Changes
- Tests Added
- Benchmark Impact
- Known Risks
- Source Provenance

## Retry/Dispute Policy

- Auto-revision cap is 2.
- Conflicts that survive tie-break escalate to a human decision.

## Reviewer Gate

- Three independent reviewer artifacts are required: Claude, Gemini, and Codex.
- Aggregation policy:
  - At least 2 of 3 verdicts must be `approve`.
  - No reviewer may mark `blocking=true`.
  - No reviewer may report `severity=critical`.
- If gate fails, PR remains blocked until a new revision cycle produces passing reviewer artifacts.
- Reviewer jobs run on a self-hosted Linux runner.
- A safety gate blocks self-hosted reviewer jobs for fork or untrusted PR authors.
- Local reviewer CLIs must exist and be authenticated on that runner:
  - `claude`
  - `gemini`
  - `codex`

## Policy Adaptation Governance

- Daily policy adaptation PRs are generated automatically.
- Reviewer-agent approval is required before human final approve/hold.
- Policy changes remain auditable through `docs/policy/changelog.md`.
