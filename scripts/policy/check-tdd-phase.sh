#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Iterable

PHASE_RE = re.compile(r"^artifacts/tdd/([^/]+)/(TYPES|TESTS|IMPL)\.json$")
REQUIRED_FEATURE_HEADINGS = {
    "## Problem",
    "## Goal",
    "## Non-Goals",
    "## Public API Impact",
    "## Risks",
    "## Acceptance Criteria",
}


def run_git(args: list[str]) -> str:
    result = subprocess.run(["git", *args], capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or f"git {' '.join(args)} failed")
    return result.stdout


def lines(output: str) -> list[str]:
    return [line.strip() for line in output.splitlines() if line.strip()]


def unique(items: Iterable[str]) -> list[str]:
    return sorted(set(items))


def detect_local_changes() -> list[str]:
    working = lines(run_git(["diff", "--name-only"]))
    staged = lines(run_git(["diff", "--cached", "--name-only"]))
    untracked = lines(run_git(["ls-files", "--others", "--exclude-standard"]))
    return unique(working + staged + untracked)


def detect_commit_range_changes() -> list[str]:
    base_ref = os.getenv("TDD_PHASE_BASE_REF") or os.getenv("GITHUB_BASE_REF") or "main"

    base_commit = None
    if subprocess.run(["git", "rev-parse", "--verify", f"origin/{base_ref}"], capture_output=True).returncode == 0:
        base_commit = lines(run_git(["merge-base", "HEAD", f"origin/{base_ref}"]))
        if base_commit:
            base_commit = base_commit[0]
    elif subprocess.run(["git", "rev-parse", "--verify", "HEAD~1"], capture_output=True).returncode == 0:
        base_commit = "HEAD~1"

    if base_commit is None:
        return []

    return lines(run_git(["diff", "--name-only", f"{base_commit}...HEAD"]))


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise ValueError(f"Invalid JSON in {path}: {exc}") from exc


def validate_artifact_shape(payload: dict, path: Path) -> None:
    required = {
        "feature_id",
        "phase",
        "feature_context",
        "depends_on_pr",
        "module_docs",
        "status",
        "updated_at",
    }
    missing = sorted(required - set(payload))
    if missing:
        raise ValueError(f"{path}: missing required keys: {', '.join(missing)}")

    feature_id = payload["feature_id"]
    phase = payload["phase"]
    feature_context = payload["feature_context"]
    depends_on_pr = payload["depends_on_pr"]
    module_docs = payload["module_docs"]
    status = payload["status"]
    updated_at = payload["updated_at"]

    if not isinstance(feature_id, str) or not re.match(r"^[a-z0-9][a-z0-9-]{2,63}$", feature_id):
        raise ValueError(f"{path}: feature_id must match ^[a-z0-9][a-z0-9-]{{2,63}}$")

    if phase not in {"TYPES", "TESTS", "IMPL"}:
        raise ValueError(f"{path}: phase must be one of TYPES|TESTS|IMPL")

    expected_context = f"artifacts/tdd/{feature_id}/FEATURE.md"
    if feature_context != expected_context:
        raise ValueError(f"{path}: feature_context must be {expected_context}")

    if phase in {"TESTS", "IMPL"}:
        if not isinstance(depends_on_pr, str) or not depends_on_pr.strip():
            raise ValueError(f"{path}: depends_on_pr must be non-empty for phase {phase}")
    else:
        if depends_on_pr is not None and not isinstance(depends_on_pr, str):
            raise ValueError(f"{path}: depends_on_pr must be string or null")

    if status not in {"draft", "ready"}:
        raise ValueError(f"{path}: status must be draft|ready")

    if not isinstance(updated_at, str) or not re.match(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$", updated_at):
        raise ValueError(f"{path}: updated_at must match YYYY-MM-DD")

    if not isinstance(module_docs, list) or not module_docs:
        raise ValueError(f"{path}: module_docs must be a non-empty array")

    for doc in module_docs:
        if not isinstance(doc, str) or not re.match(r"^docs/modules/.+\.md$", doc):
            raise ValueError(f"{path}: invalid module_docs path: {doc}")


def validate_path_consistency(path: str, payload: dict) -> None:
    match = PHASE_RE.match(path)
    if match is None:
        raise ValueError(f"Invalid phase artifact path: {path}")

    path_feature = match.group(1)
    path_phase = match.group(2)

    if path_feature != payload["feature_id"]:
        raise ValueError(f"{path}: path feature id '{path_feature}' != payload feature_id '{payload['feature_id']}'")

    if path_phase != payload["phase"]:
        raise ValueError(f"{path}: path phase '{path_phase}' != payload phase '{payload['phase']}'")


def validate_feature_context(path: Path) -> None:
    if not path.exists():
        raise ValueError(f"Missing feature context file: {path}")

    text = path.read_text(encoding="utf-8")
    missing = sorted([heading for heading in REQUIRED_FEATURE_HEADINGS if heading not in text])
    if missing:
        raise ValueError(f"{path}: missing required headings: {', '.join(missing)}")


def check_phase_paths(phase: str, changed: list[str]) -> None:
    def any_prefix(prefixes: list[str]) -> bool:
        return any(any(item.startswith(prefix) for prefix in prefixes) for item in changed)

    def fail_if_prefix(prefixes: list[str]) -> None:
        violations = [item for item in changed if any(item.startswith(prefix) for prefix in prefixes)]
        if violations:
            joined = "\\n  - ".join(violations)
            raise ValueError(f"Phase {phase} forbids changes in these paths:\\n  - {joined}")

    if phase == "TYPES":
        fail_if_prefix(["test/", "app/", "bench/"])

    elif phase == "TESTS":
        if not any(item.startswith("test/") for item in changed):
            raise ValueError("Phase TESTS requires at least one changed file under test/")
        fail_if_prefix(["src/", "app/", "bench/baseline/"])

    elif phase == "IMPL":
        if not any_prefix(["src/", "app/", "scripts/"]):
            raise ValueError("Phase IMPL requires at least one changed file under src/, app/, or scripts/")
        fail_if_prefix(["test/"])


def main() -> int:
    changed = detect_local_changes()
    if not changed:
        changed = detect_commit_range_changes()

    if not changed:
        print("No changed files detected; skipping TDD phase check.")
        return 0

    phase_artifacts = [path for path in changed if PHASE_RE.match(path)]
    if len(phase_artifacts) != 1:
        print("Expected exactly one changed phase artifact under artifacts/tdd/<feature-id>/<PHASE>.json")
        if phase_artifacts:
            print("Detected phase artifacts:")
            for item in phase_artifacts:
                print(f"- {item}")
        return 1

    artifact_path = Path(phase_artifacts[0])
    payload = load_json(artifact_path)

    try:
        validate_artifact_shape(payload, artifact_path)
        validate_path_consistency(str(artifact_path), payload)
        validate_feature_context(Path(payload["feature_context"]))

        module_docs = payload["module_docs"]
        missing_docs = [path for path in module_docs if not Path(path).exists()]
        if missing_docs:
            raise ValueError(f"Module docs do not exist: {', '.join(missing_docs)}")

        stale_docs = [path for path in module_docs if path not in changed]
        if stale_docs:
            raise ValueError(f"Module docs must be updated in this PR: {', '.join(stale_docs)}")

        if payload["feature_context"] not in changed:
            raise ValueError("Feature context file must be updated in the same PR")

        check_phase_paths(payload["phase"], changed)
    except ValueError as err:
        print(f"TDD phase check failed: {err}")
        return 1

    print("TDD phase check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
PY
