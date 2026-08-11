#!/usr/bin/env bash
set -euo pipefail
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Xcode project generation/build verification must run on macOS." >&2
  exit 2
fi
python3 scripts/generate-assets.py
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Install XcodeGen first (for example: brew install xcodegen)." >&2
  exit 2
fi
xcodegen generate
printf 'Generated %s/AfterStorm.xcodeproj\n' "$PWD"
