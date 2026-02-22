#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
from typing import Any


REQUIRED_REVIEWERS = ("claude", "gemini", "codex")


def fail(message: str) -> int:
    print(message, file=sys.stderr)
    return 1


def validate_review(review: dict[str, Any], expected_role: str) -> str | None:
    required_keys = {
        "task_id",
        "agent_role",
        "verdict",
        "severity",
        "blocking",
        "confidence",
        "findings",
        "required_changes",
    }
    missing = required_keys - review.keys()
    if missing:
        return f"{expected_role}: missing keys {sorted(missing)}"

    if review["agent_role"] != expected_role:
        return f"{expected_role}: agent_role mismatch ({review['agent_role']})"

    if review["verdict"] not in {"approve", "request_changes"}:
        return f"{expected_role}: invalid verdict {review['verdict']}"

    if review["severity"] not in {"low", "medium", "high", "critical"}:
        return f"{expected_role}: invalid severity {review['severity']}"

    if not isinstance(review["blocking"], bool):
        return f"{expected_role}: blocking must be boolean"

    return None


def load_review(artifacts_dir: Path, reviewer: str) -> dict[str, Any]:
    path = artifacts_dir / reviewer / f"{reviewer}.json"
    if not path.exists():
        raise FileNotFoundError(f"Missing reviewer artifact: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"Reviewer artifact root must be object: {path}")
    return data


def build_summary(reviews: dict[str, dict[str, Any]]) -> dict[str, Any]:
    approvals = 0
    blocking_reviewers = []
    critical_reviewers = []

    for reviewer, review in reviews.items():
        if review["verdict"] == "approve":
            approvals += 1
        if review["blocking"]:
            blocking_reviewers.append(reviewer)
        if review["severity"] == "critical":
            critical_reviewers.append(reviewer)

    passed = approvals >= 2 and not blocking_reviewers and not critical_reviewers
    return {
        "approvals": approvals,
        "total_reviewers": len(reviews),
        "blocking_reviewers": blocking_reviewers,
        "critical_reviewers": critical_reviewers,
        "gate_passed": passed,
        "decision": "approve" if passed else "hold",
    }


def write_summary_markdown(path: Path, reviews: dict[str, dict[str, Any]], summary: dict[str, Any]) -> None:
    lines = [
        "# Agent Review Summary",
        "",
        f"- Decision: `{summary['decision']}`",
        f"- Gate passed: `{summary['gate_passed']}`",
        f"- Approvals: `{summary['approvals']}/{summary['total_reviewers']}`",
        f"- Blocking reviewers: `{', '.join(summary['blocking_reviewers']) if summary['blocking_reviewers'] else 'none'}`",
        f"- Critical reviewers: `{', '.join(summary['critical_reviewers']) if summary['critical_reviewers'] else 'none'}`",
        "",
        "## Reviewer Verdicts",
        "",
    ]

    for reviewer in REQUIRED_REVIEWERS:
        review = reviews[reviewer]
        lines.extend(
            [
                f"### {reviewer}",
                f"- verdict: `{review['verdict']}`",
                f"- severity: `{review['severity']}`",
                f"- blocking: `{review['blocking']}`",
                f"- confidence: `{review['confidence']}`",
            ]
        )
        findings = review.get("findings", [])
        if findings:
            lines.append("- findings:")
            for finding in findings:
                lines.append(f"  - {finding}")
        lines.append("")

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Aggregate Claude/Gemini/Codex review artifacts.")
    parser.add_argument("--artifacts-dir", required=True)
    parser.add_argument("--output-json", required=True)
    parser.add_argument("--output-md", required=True)
    args = parser.parse_args()

    artifacts_dir = Path(args.artifacts_dir)
    output_json = Path(args.output_json)
    output_md = Path(args.output_md)

    reviews: dict[str, dict[str, Any]] = {}
    validation_errors: list[str] = []

    for reviewer in REQUIRED_REVIEWERS:
        try:
            review = load_review(artifacts_dir, reviewer)
        except (FileNotFoundError, ValueError, json.JSONDecodeError) as exc:
            validation_errors.append(str(exc))
            continue

        validation_error = validate_review(review, reviewer)
        if validation_error:
            validation_errors.append(validation_error)
        reviews[reviewer] = review

    if validation_errors:
        for item in validation_errors:
            print(item, file=sys.stderr)
        return 1

    summary = build_summary(reviews)
    payload = {"summary": summary, "reviews": reviews}

    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    write_summary_markdown(output_md, reviews, summary)

    if not summary["gate_passed"]:
        return fail("Agent review gate failed.")

    print("Agent review gate passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
