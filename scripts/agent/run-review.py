#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess
from typing import Any


def failure_artifact(task_id: str, agent: str, reason: str) -> dict[str, Any]:
    return {
        "task_id": task_id,
        "agent_role": agent,
        "verdict": "request_changes",
        "severity": "high",
        "blocking": True,
        "confidence": 1.0,
        "findings": [reason],
        "required_changes": [
            f"Configure review command for {agent} and rerun review workflow."
        ],
    }


def validate_artifact(artifact: dict[str, Any], expected_agent: str) -> dict[str, Any]:
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
    missing = required_keys - artifact.keys()
    if missing:
        return failure_artifact(
            task_id=str(artifact.get("task_id", "missing-task-id")),
            agent=expected_agent,
            reason=f"Reviewer output missing required keys: {sorted(missing)}",
        )

    artifact["agent_role"] = expected_agent
    if artifact["verdict"] not in {"approve", "request_changes"}:
        return failure_artifact(
            task_id=str(artifact.get("task_id", "missing-task-id")),
            agent=expected_agent,
            reason=f"Invalid verdict from reviewer: {artifact['verdict']}",
        )
    if artifact["severity"] not in {"low", "medium", "high", "critical"}:
        return failure_artifact(
            task_id=str(artifact.get("task_id", "missing-task-id")),
            agent=expected_agent,
            reason=f"Invalid severity from reviewer: {artifact['severity']}",
        )

    return artifact


def command_env_var(agent: str) -> str:
    return f"{agent.upper()}_REVIEW_COMMAND"


def run_agent_command(
    task_id: str, agent: str, pr_number: str, head_sha: str
) -> dict[str, Any]:
    env_var = command_env_var(agent)
    command = os.getenv(env_var)
    if not command:
        return failure_artifact(
            task_id=task_id,
            agent=agent,
            reason=f"Missing environment variable: {env_var}",
        )

    env = os.environ.copy()
    env["TASK_ID"] = task_id
    env["AGENT_ROLE"] = agent
    env["PR_NUMBER"] = pr_number
    env["HEAD_SHA"] = head_sha

    completed = subprocess.run(
        command, shell=True, capture_output=True, text=True, env=env
    )
    if completed.returncode != 0:
        stderr = completed.stderr.strip() or "No stderr output"
        return failure_artifact(
            task_id=task_id,
            agent=agent,
            reason=f"{agent} reviewer command failed: {stderr[:500]}",
        )

    stdout = completed.stdout.strip()
    if not stdout:
        return failure_artifact(
            task_id=task_id,
            agent=agent,
            reason=f"{agent} reviewer command produced no output",
        )

    try:
        parsed = json.loads(stdout)
    except json.JSONDecodeError as exc:
        return failure_artifact(
            task_id=task_id,
            agent=agent,
            reason=f"{agent} reviewer output is not valid JSON: {exc}",
        )

    if not isinstance(parsed, dict):
        return failure_artifact(
            task_id=task_id,
            agent=agent,
            reason=f"{agent} reviewer output JSON root must be an object",
        )

    return validate_artifact(parsed, expected_agent=agent)


def main() -> int:
    parser = argparse.ArgumentParser(description="Run one agent reviewer command.")
    parser.add_argument("--task-id", required=True)
    parser.add_argument("--agent", required=True, choices=["claude", "gemini", "codex"])
    parser.add_argument("--pr-number", required=True)
    parser.add_argument("--head-sha", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    artifact = run_agent_command(
        task_id=args.task_id,
        agent=args.agent,
        pr_number=args.pr_number,
        head_sha=args.head_sha,
    )

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(artifact, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote reviewer artifact: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
