#!/usr/bin/env bash
set -euo pipefail

template_file=".github/pull_request_template.md"
if [ ! -f "$template_file" ]; then
  echo "Missing $template_file"
  exit 1
fi

required_tags=(
  "AGENT_BRIEF_V1"
  "AGENT_IMPLEMENTATION_REPORT_V1"
  "AGENT_REVIEW_CLAUDE_V1"
  "AGENT_REVIEW_GEMINI_V1"
  "AGENT_REVIEW_CODEX_V1"
  "AGENT_DECISION_PACKET_V1"
)

missing=0
for tag in "${required_tags[@]}"; do
  if ! grep -q "$tag" "$template_file"; then
    echo "Missing protocol tag in PR template: $tag"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "Protocol tag check passed."
