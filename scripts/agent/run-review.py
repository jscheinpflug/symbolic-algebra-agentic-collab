#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
from typing import Any

ALLOWED_COMMAND_PREFIXES: dict[str, list[str]] = {
    "claude": ["claude", "-p"],
    "gemini": ["gemini"],
    "codex": ["codex", "exec"],
}

REQUIRED_KEYS = {
    "task_id",
    "agent_role",
    "verdict",
    "severity",
    "blocking",
    "confidence",
    "findings",
    "required_changes",
}


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
            f"Ensure local {agent} CLI is installed and authenticated on the self-hosted runner.",
            "Rerun the agent-loop workflow after fixing local reviewer execution.",
        ],
    }


def validate_artifact(artifact: dict[str, Any], expected_agent: str) -> dict[str, Any]:
    missing = REQUIRED_KEYS - artifact.keys()
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


def build_review_prompt(
    task_id: str, agent: str, pr_number: str, head_sha: str
) -> str:
    return f"""
You are a code reviewer agent ({agent}) in a CI gate.
Review the checked-out repository and the current PR state.

Context:
- task_id: {task_id}
- pr_number: {pr_number}
- head_sha: {head_sha}
- required_agent_role: {agent}

Return only a JSON object with exactly these keys:
- task_id (string)
- agent_role (string, must be "{agent}")
- verdict ("approve" | "request_changes")
- severity ("low" | "medium" | "high" | "critical")
- blocking (boolean)
- confidence (number from 0.0 to 1.0)
- findings (array of strings)
- required_changes (array of strings)

Do not include markdown or surrounding text.
""".strip()


def extract_json_object(raw_output: str) -> dict[str, Any]:
    text = raw_output.strip()
    if not text:
        raise ValueError("Reviewer output was empty")

    candidates: list[str] = [text]
    fenced_blocks = re.findall(
        r"```(?:json)?\s*(\{.*?\})\s*```",
        text,
        flags=re.DOTALL | re.IGNORECASE,
    )
    candidates.extend(fenced_blocks)

    start_index = text.find("{")
    end_index = text.rfind("}")
    if start_index != -1 and end_index != -1 and end_index > start_index:
        candidates.append(text[start_index : end_index + 1])

    for candidate in candidates:
        try:
            parsed = json.loads(candidate)
        except json.JSONDecodeError:
            continue
        if isinstance(parsed, dict):
            return parsed

    preview = text[:400].replace("\n", " ")
    raise ValueError(f"Could not parse reviewer JSON output. Preview: {preview}")


def ensure_cli_available(agent: str) -> str | None:
    command_prefix = ALLOWED_COMMAND_PREFIXES[agent]
    executable = command_prefix[0]
    path = shutil.which(executable)
    return path


def run_agent_command(
    task_id: str, agent: str, pr_number: str, head_sha: str, timeout_seconds: int
) -> dict[str, Any]:
    executable_path = ensure_cli_available(agent)
    if executable_path is None:
        return failure_artifact(
            task_id=task_id,
            agent=agent,
            reason=f"Missing local CLI executable: {ALLOWED_COMMAND_PREFIXES[agent][0]}",
        )

    command_prefix = ALLOWED_COMMAND_PREFIXES[agent]
    prompt = build_review_prompt(
        task_id=task_id, agent=agent, pr_number=pr_number, head_sha=head_sha
    )
    command = [*command_prefix, prompt]

    env = os.environ.copy()
    env["TASK_ID"] = task_id
    env["AGENT_ROLE"] = agent
    env["PR_NUMBER"] = pr_number
    env["HEAD_SHA"] = head_sha

    try:
        completed = subprocess.run(
            command,
            capture_output=True,
            text=True,
            env=env,
            timeout=timeout_seconds,
        )
    except subprocess.TimeoutExpired:
        return failure_artifact(
            task_id=task_id,
            agent=agent,
            reason=(
                f"{agent} reviewer command timed out after "
                f"{timeout_seconds}s (executable: {executable_path})"
            ),
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
        parsed = extract_json_object(stdout)
    except ValueError as exc:
        return failure_artifact(
            task_id=task_id,
            agent=agent,
            reason=f"{agent} reviewer output is not valid JSON object: {exc}",
        )

    return validate_artifact(parsed, expected_agent=agent)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run one agent reviewer using local allowlisted CLI commands."
    )
    parser.add_argument("--task-id", required=True)
    parser.add_argument("--agent", required=True, choices=["claude", "gemini", "codex"])
    parser.add_argument("--pr-number", required=True)
    parser.add_argument("--head-sha", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--timeout-seconds", type=int, default=300)
    args = parser.parse_args()

    artifact = run_agent_command(
        task_id=args.task_id,
        agent=args.agent,
        pr_number=args.pr_number,
        head_sha=args.head_sha,
        timeout_seconds=args.timeout_seconds,
    )

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(artifact, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote reviewer artifact: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
