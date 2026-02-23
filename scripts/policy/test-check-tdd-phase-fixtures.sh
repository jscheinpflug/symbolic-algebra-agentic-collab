#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECK_SCRIPT="${ROOT_DIR}/scripts/policy/check-tdd-phase.sh"

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

fail() {
  echo "$1" >&2
  exit 1
}

init_repo() {
  local repo_dir="$1"
  mkdir -p "${repo_dir}"
  git -C "${repo_dir}" init -q
  git -C "${repo_dir}" config user.email "policy-tests@example.com"
  git -C "${repo_dir}" config user.name "Policy Fixture Tests"
  git -C "${repo_dir}" checkout -q -b main
}

write_feature_md() {
  local feature_id="$1"
  local repo_dir="$2"
  mkdir -p "${repo_dir}/artifacts/tdd/${feature_id}"
  cat > "${repo_dir}/artifacts/tdd/${feature_id}/FEATURE.md" <<'EOF'
## Problem

Fixture problem.

## Goal

Fixture goal.

## Non-Goals

Fixture non-goals.

## Public API Impact

Fixture API impact.

## Risks

Fixture risks.

## Acceptance Criteria

Fixture acceptance criteria.
EOF
}

write_module_doc() {
  local module_doc="$1"
  local content="$2"
  local repo_dir="$3"
  mkdir -p "${repo_dir}/docs/modules"
  cat > "${repo_dir}/docs/modules/${module_doc}" <<EOF
# ${module_doc}

${content}
EOF
}

write_types_json() {
  local feature_id="$1"
  local module_doc="$2"
  local repo_dir="$3"
  cat > "${repo_dir}/artifacts/tdd/${feature_id}/TYPES.json" <<EOF
{
  "feature_id": "${feature_id}",
  "phase": "TYPES",
  "feature_context": "artifacts/tdd/${feature_id}/FEATURE.md",
  "depends_on_pr": null,
  "module_docs": [
    "docs/modules/${module_doc}"
  ],
  "status": "ready",
  "updated_at": "2026-02-23"
}
EOF
}

write_tests_json() {
  local feature_id="$1"
  local module_doc="$2"
  local repo_dir="$3"
  cat > "${repo_dir}/artifacts/tdd/${feature_id}/TESTS.json" <<EOF
{
  "feature_id": "${feature_id}",
  "phase": "TESTS",
  "feature_context": "artifacts/tdd/${feature_id}/FEATURE.md",
  "depends_on_pr": "#1",
  "module_docs": [
    "docs/modules/${module_doc}"
  ],
  "status": "ready",
  "updated_at": "2026-02-23"
}
EOF
}

write_impl_json() {
  local feature_id="$1"
  local module_doc="$2"
  local depends_on_pr="$3"
  local repo_dir="$4"
  cat > "${repo_dir}/artifacts/tdd/${feature_id}/IMPL.json" <<EOF
{
  "feature_id": "${feature_id}",
  "phase": "IMPL",
  "feature_context": "artifacts/tdd/${feature_id}/FEATURE.md",
  "depends_on_pr": "${depends_on_pr}",
  "module_docs": [
    "docs/modules/${module_doc}"
  ],
  "status": "ready",
  "updated_at": "2026-02-23"
}
EOF
}

commit_all() {
  local message="$1"
  local repo_dir="$2"
  git -C "${repo_dir}" add .
  git -C "${repo_dir}" commit -q -m "${message}"
}

expect_pass() {
  local name="$1"
  local repo_dir="$2"
  if ! (cd "${repo_dir}" && "${CHECK_SCRIPT}" >/tmp/"${name}".out 2>&1); then
    cat /tmp/"${name}".out >&2
    fail "Expected pass but failed: ${name}"
  fi
}

expect_fail() {
  local name="$1"
  local repo_dir="$2"
  if (cd "${repo_dir}" && "${CHECK_SCRIPT}" >/tmp/"${name}".out 2>&1); then
    cat /tmp/"${name}".out >&2
    fail "Expected failure but passed: ${name}"
  fi
}

case_tests_phase_pass() {
  local repo_dir="${tmp_root}/case-tests-pass"
  init_repo "${repo_dir}"
  write_feature_md "demo-pass" "${repo_dir}"
  write_module_doc "demo-pass.md" "baseline doc" "${repo_dir}"
  write_types_json "demo-pass" "demo-pass.md" "${repo_dir}"
  commit_all "base" "${repo_dir}"

  git -C "${repo_dir}" checkout -q -b feature
  write_tests_json "demo-pass" "demo-pass.md" "${repo_dir}"
  printf '\nupdated in tests phase\n' >> "${repo_dir}/docs/modules/demo-pass.md"
  mkdir -p "${repo_dir}/test"
  echo "test-only change" > "${repo_dir}/test/tests-phase.txt"
  commit_all "tests phase" "${repo_dir}"

  expect_pass "case_tests_phase_pass" "${repo_dir}"
}

case_tests_phase_forbids_scripts() {
  local repo_dir="${tmp_root}/case-tests-forbids-scripts"
  init_repo "${repo_dir}"
  write_feature_md "demo-forbid-scripts" "${repo_dir}"
  write_module_doc "demo-forbid-scripts.md" "baseline doc" "${repo_dir}"
  write_types_json "demo-forbid-scripts" "demo-forbid-scripts.md" "${repo_dir}"
  commit_all "base" "${repo_dir}"

  git -C "${repo_dir}" checkout -q -b feature
  write_tests_json "demo-forbid-scripts" "demo-forbid-scripts.md" "${repo_dir}"
  printf '\nupdated in tests phase\n' >> "${repo_dir}/docs/modules/demo-forbid-scripts.md"
  mkdir -p "${repo_dir}/test" "${repo_dir}/scripts"
  echo "test change" > "${repo_dir}/test/tests-phase.txt"
  echo "implementation leak" > "${repo_dir}/scripts/should-not-change.sh"
  commit_all "tests phase with illegal scripts change" "${repo_dir}"

  expect_fail "case_tests_phase_forbids_scripts" "${repo_dir}"
}

case_missing_base_ref_in_pr_context() {
  local repo_dir="${tmp_root}/case-missing-base-ref"
  init_repo "${repo_dir}"
  write_feature_md "demo-no-base" "${repo_dir}"
  write_module_doc "demo-no-base.md" "baseline doc" "${repo_dir}"
  write_types_json "demo-no-base" "demo-no-base.md" "${repo_dir}"
  commit_all "base" "${repo_dir}"

  git -C "${repo_dir}" checkout -q -b feature
  write_tests_json "demo-no-base" "demo-no-base.md" "${repo_dir}"
  printf '\nupdated in tests phase\n' >> "${repo_dir}/docs/modules/demo-no-base.md"
  mkdir -p "${repo_dir}/test"
  echo "test change" > "${repo_dir}/test/tests-phase.txt"
  commit_all "tests phase" "${repo_dir}"

  if (
    cd "${repo_dir}" \
      && GITHUB_EVENT_NAME="pull_request" TDD_PHASE_BASE_REF="does-not-exist" "${CHECK_SCRIPT}" >/tmp/case_missing_base_ref.out 2>&1
  ); then
    cat /tmp/case_missing_base_ref.out >&2
    fail "Expected failure but passed: case_missing_base_ref_in_pr_context"
  fi
}

case_bootstrap_reuse_blocked() {
  local repo_dir="${tmp_root}/case-bootstrap-reuse"
  init_repo "${repo_dir}"
  write_feature_md "policy-tdd-phase-gate" "${repo_dir}"
  write_module_doc "scripts.check-tdd-phase.md" "baseline module doc" "${repo_dir}"
  mkdir -p "${repo_dir}/scripts/policy" "${repo_dir}/docs/domains" "${repo_dir}/schemas"
  echo "rolled out" > "${repo_dir}/scripts/policy/check-tdd-phase.sh"
  echo "rolled out" > "${repo_dir}/docs/domains/tdd-phases.md"
  echo "{}" > "${repo_dir}/schemas/tdd-phase.schema.json"
  commit_all "base with rollout files" "${repo_dir}"

  git -C "${repo_dir}" checkout -q -b feature
  write_impl_json "policy-tdd-phase-gate" "scripts.check-tdd-phase.md" "bootstrap-initial" "${repo_dir}"
  printf '\nupdated in impl phase\n' >> "${repo_dir}/docs/modules/scripts.check-tdd-phase.md"
  mkdir -p "${repo_dir}/scripts"
  echo "impl change" > "${repo_dir}/scripts/impl-change.sh"
  commit_all "attempted bootstrap reuse" "${repo_dir}"

  expect_fail "case_bootstrap_reuse_blocked" "${repo_dir}"
}

case_bootstrap_first_rollout_allowed() {
  local repo_dir="${tmp_root}/case-bootstrap-first-rollout"
  init_repo "${repo_dir}"
  write_feature_md "policy-tdd-phase-gate" "${repo_dir}"
  write_module_doc "scripts.check-tdd-phase.md" "baseline module doc" "${repo_dir}"
  commit_all "base without rollout files" "${repo_dir}"

  git -C "${repo_dir}" checkout -q -b feature
  write_impl_json "policy-tdd-phase-gate" "scripts.check-tdd-phase.md" "bootstrap-initial" "${repo_dir}"
  printf '\nupdated in impl phase\n' >> "${repo_dir}/docs/modules/scripts.check-tdd-phase.md"
  mkdir -p "${repo_dir}/scripts" "${repo_dir}/scripts/policy" "${repo_dir}/docs/domains" "${repo_dir}/schemas"
  echo "rollout" > "${repo_dir}/scripts/impl-change.sh"
  echo "rollout" > "${repo_dir}/scripts/policy/check-tdd-phase.sh"
  echo "rollout" > "${repo_dir}/docs/domains/tdd-phases.md"
  echo "{}" > "${repo_dir}/schemas/tdd-phase.schema.json"
  commit_all "first bootstrap rollout" "${repo_dir}"

  expect_pass "case_bootstrap_first_rollout_allowed" "${repo_dir}"
}

case_tests_phase_pass
case_tests_phase_forbids_scripts
case_missing_base_ref_in_pr_context
case_bootstrap_reuse_blocked
case_bootstrap_first_rollout_allowed

echo "TDD phase fixture tests passed."
