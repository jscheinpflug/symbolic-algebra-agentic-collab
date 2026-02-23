#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "test/Spec.hs" ]; then
  echo "Missing test runner: test/Spec.hs"
  exit 1
fi

if [ -f "test/Main.hs" ]; then
  echo "Legacy test/Main.hs should not exist once structured test layout is enabled."
  exit 1
fi

if [ ! -d "test/Unit" ]; then
  echo "Missing unit test directory: test/Unit"
  exit 1
fi

if [ ! -d "test/Integration" ]; then
  echo "Missing integration test directory: test/Integration"
  exit 1
fi

collect_changed_files() {
  local -a working staged untracked combined
  mapfile -t working < <(git diff --name-only)
  mapfile -t staged < <(git diff --cached --name-only)
  mapfile -t untracked < <(git ls-files --others --exclude-standard)

  combined=("${working[@]}" "${staged[@]}" "${untracked[@]}")

  if [ "${#combined[@]}" -eq 0 ] && git rev-parse --verify origin/main >/dev/null 2>&1; then
    local base
    base="$(git merge-base HEAD origin/main)"
    mapfile -t combined < <(git diff --name-only "${base}...HEAD")
  fi

  printf '%s\n' "${combined[@]}" | awk 'NF {seen[$0]=1} END {for (k in seen) print k}' | sort
}

mapfile -t changed_files < <(collect_changed_files)
types_phase_active=0
declare -A changed_src=()
for path in "${changed_files[@]}"; do
  if [[ "${path}" =~ ^artifacts/tdd/[^/]+/TYPES\.json$ ]]; then
    types_phase_active=1
  fi

  if [[ "${path}" =~ ^src/.*\.hs$ ]]; then
    changed_src["${path}"]=1
  fi
done

mapfile -t src_files < <(find src -type f -name '*.hs' | sort)
if [ "${#src_files[@]}" -eq 0 ]; then
  echo "No source files found under src/."
  exit 1
fi

declare -a missing_unit=()
for src_file in "${src_files[@]}"; do
  relative_path="${src_file#src/}"
  expected_unit="test/Unit/${relative_path%.hs}Test.hs"
  if [ ! -f "${expected_unit}" ]; then
    if [ "${types_phase_active}" -eq 1 ] && [ "${changed_src["${src_file}"]+set}" = "set" ]; then
      # During TYPES phase, new source files are allowed to land before mirrored tests.
      continue
    fi
    missing_unit+=("${expected_unit}")
  fi
done

if [ "${#missing_unit[@]}" -ne 0 ]; then
  echo "Missing mirrored unit tests for source files:"
  for path in "${missing_unit[@]}"; do
    echo "- ${path}"
  done
  exit 1
fi

mapfile -t unit_files < <(find test/Unit -type f -name '*.hs' | sort)

declare -a bad_unit_names=()
declare -a orphan_unit_tests=()
for unit_file in "${unit_files[@]}"; do
  if [[ "${unit_file}" != *Test.hs ]]; then
    bad_unit_names+=("${unit_file}")
  fi

  relative_unit="${unit_file#test/Unit/}"
  expected_src="src/${relative_unit%Test.hs}.hs"
  if [ ! -f "${expected_src}" ]; then
    orphan_unit_tests+=("${unit_file} -> ${expected_src}")
  fi
done

if [ "${#bad_unit_names[@]}" -ne 0 ]; then
  echo "Unit test files must end with Test.hs:"
  for path in "${bad_unit_names[@]}"; do
    echo "- ${path}"
  done
  exit 1
fi

if [ "${#orphan_unit_tests[@]}" -ne 0 ]; then
  echo "Unit tests must map to a source file under src/:"
  for mapping in "${orphan_unit_tests[@]}"; do
    echo "- ${mapping}"
  done
  exit 1
fi

mapfile -t integration_files < <(find test/Integration -type f -name '*.hs' | sort)
if [ "${#integration_files[@]}" -eq 0 ]; then
  echo "Integration test directory must contain at least one *.hs file."
  exit 1
fi

declare -a bad_integration_names=()
for integration_file in "${integration_files[@]}"; do
  if [[ "${integration_file}" != *Test.hs ]]; then
    bad_integration_names+=("${integration_file}")
  fi
done

if [ "${#bad_integration_names[@]}" -ne 0 ]; then
  echo "Integration test files must end with Test.hs:"
  for path in "${bad_integration_names[@]}"; do
    echo "- ${path}"
  done
  exit 1
fi

echo "Test layout check passed."
