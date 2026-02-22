#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import json
import sys


@dataclass(frozen=True)
class Proposal:
    target: str
    severity: str
    change: str
    evidence: list[str]
    risk: str
    rollback_condition: str


def build_proposals(signal: dict) -> list[Proposal]:
    proposals: list[Proposal] = []
    ci = signal.get("ci", {})
    reviews = signal.get("reviews", {})
    dead_rules = signal.get("dead_rules", [])

    failed_runs = int(ci.get("failed_runs", 0))
    failing_checks = ci.get("failing_checks", [])
    changes_requested = int(reviews.get("changes_requested", 0))
    recurring_findings = reviews.get("recurring_findings", [])

    if failed_runs > 0:
        proposals.append(
            Proposal(
                target=".github/workflows/ci.yml",
                severity="high" if failed_runs >= 3 else "medium",
                change=(
                    "Review top failing checks and tighten either flaky detection or "
                    "ownership/runbook entries for those checks."
                ),
                evidence=[
                    f"failed_runs={failed_runs}",
                    "failing_checks=" + ", ".join(failing_checks) if failing_checks else "failing_checks=none",
                ],
                risk="Overfitting CI policy to short-term noise.",
                rollback_condition="Revert if failure rate does not improve over 3 daily cycles.",
            )
        )

    if changes_requested > 0:
        proposals.append(
            Proposal(
                target="docs/domains/agentic-loop.md",
                severity="medium",
                change=(
                    "Update review guidance and PR contract examples for the most common "
                    "review rejection patterns."
                ),
                evidence=[
                    f"changes_requested={changes_requested}",
                    "recurring_findings="
                    + (", ".join(recurring_findings) if recurring_findings else "none"),
                ],
                risk="Can add process overhead if guidance grows without pruning.",
                rollback_condition="Revert if rejection rate stays unchanged after 5 policy PR cycles.",
            )
        )

    stale_dead_rules = [
        item for item in dead_rules if isinstance(item, dict) and int(item.get("age_days", 0)) >= 30
    ]
    if stale_dead_rules:
        rule_list = ", ".join(str(item.get("rule_id", "unknown")) for item in stale_dead_rules)
        proposals.append(
            Proposal(
                target="docs/policy/rules-catalog.md",
                severity="high",
                change="Refresh stale rules or remove dead checks that no longer provide signal.",
                evidence=[f"dead_rules={rule_list}"],
                risk="Removing a guardrail may allow regressions to slip through.",
                rollback_condition="Reinstate removed rule if regressions reappear within 14 days.",
            )
        )

    if not proposals:
        proposals.append(
            Proposal(
                target="docs/policy/changelog.md",
                severity="low",
                change="No rule changes proposed today; keep current policy set.",
                evidence=["No CI/review/dead-rule triggers crossed thresholds."],
                risk="Slow drift might be missed without threshold tuning.",
                rollback_condition="N/A",
            )
        )

    return proposals


def to_json(date_value: str, signal_path: Path, proposals: list[Proposal]) -> dict:
    return {
        "date": date_value,
        "source_signal_file": str(signal_path),
        "proposals": [
            {
                "id": f"POLICY-{date_value.replace('-', '')}-{index:02d}",
                "target": proposal.target,
                "severity": proposal.severity,
                "change": proposal.change,
                "evidence": proposal.evidence,
                "risk": proposal.risk,
                "rollback_condition": proposal.rollback_condition,
            }
            for index, proposal in enumerate(proposals, start=1)
        ],
    }


def write_markdown(path: Path, payload: dict) -> None:
    lines = [
        "# Daily Policy Change Proposal",
        "",
        f"- Date: `{payload['date']}`",
        f"- Source signal: `{payload['source_signal_file']}`",
        "",
        "## Proposed Changes",
        "",
    ]

    for proposal in payload["proposals"]:
        lines.extend(
            [
                f"### {proposal['id']}",
                f"- Target: `{proposal['target']}`",
                f"- Severity: `{proposal['severity']}`",
                f"- Change: {proposal['change']}",
                f"- Risk: {proposal['risk']}",
                f"- Rollback: {proposal['rollback_condition']}",
                "- Evidence:",
            ]
        )
        for evidence in proposal["evidence"]:
            lines.append(f"  - {evidence}")
        lines.append("")

    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "Usage: generate-daily-policy-proposal.py <signal-json> <proposal-json> <proposal-md>",
            file=sys.stderr,
        )
        return 1

    signal_path = Path(sys.argv[1])
    proposal_json_path = Path(sys.argv[2])
    proposal_md_path = Path(sys.argv[3])

    if not signal_path.exists():
        print(f"Signal file not found: {signal_path}", file=sys.stderr)
        return 1

    signal = json.loads(signal_path.read_text(encoding="utf-8"))
    date_value = signal.get("date")
    if not isinstance(date_value, str) or not date_value:
        print("Signal file missing valid 'date' field.", file=sys.stderr)
        return 1

    proposals = build_proposals(signal)
    payload = to_json(date_value, signal_path, proposals)

    proposal_json_path.parent.mkdir(parents=True, exist_ok=True)
    proposal_md_path.parent.mkdir(parents=True, exist_ok=True)

    proposal_json_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    write_markdown(proposal_md_path, payload)

    print(f"Wrote policy proposal JSON: {proposal_json_path}")
    print(f"Wrote policy proposal markdown: {proposal_md_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
