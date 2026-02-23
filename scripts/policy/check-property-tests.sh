#!/usr/bin/env bash
set -euo pipefail

required_property_files=(
  "test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/TermTest.hs"
  "test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/PatternTest.hs"
  "test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/RuleTest.hs"
)

missing=0
for file in "${required_property_files[@]}"; do
  if [ ! -f "${file}" ]; then
    echo "Missing required property test file: ${file}"
    missing=1
  fi
done

if [ "${missing}" -ne 0 ]; then
  exit 1
fi

for file in "${required_property_files[@]}"; do
  if ! rg -q '^prop_[A-Za-z0-9_]+\s*::\s*Property' "${file}"; then
    echo "Property declaration missing in ${file}. Expected at least one 'prop_* :: Property' declaration."
    exit 1
  fi

  if ! rg -q 'Test\.Hspec\.QuickCheck|Test\.QuickCheck' "${file}"; then
    echo "QuickCheck integration missing in ${file}."
    exit 1
  fi
done

echo "Property test coverage check passed."
