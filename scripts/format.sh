#!/usr/bin/env bash
set -euo pipefail

mapfile -t hs_files < <(find app bench src test -type f -name "*.hs" | sort)

if [ "${#hs_files[@]}" -eq 0 ]; then
  echo "No Haskell files found."
  exit 0
fi

fourmolu --mode inplace "${hs_files[@]}"
echo "Formatted ${#hs_files[@]} files."
