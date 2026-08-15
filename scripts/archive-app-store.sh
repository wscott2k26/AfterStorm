#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

: "${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM to the Apple Developer Team ID before archiving.}"

XCODE_APP="${XCODE_APP:-/Applications/Xcode_26.3.app}"
if [[ ! -d "$XCODE_APP" ]]; then
  echo "Required Xcode not found: $XCODE_APP" >&2
  exit 1
fi

sudo xcode-select -s "$XCODE_APP/Contents/Developer"
python3 scripts/check-app-store-release.py
python3 scripts/generate-assets.py
python3 scripts/generate-storm-atmosphere.py

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen is required. Install it before archiving." >&2
  exit 1
fi

xcodegen generate
rm -rf build/AfterStorm.xcarchive
mkdir -p build

xcodebuild \
  -project AfterStorm.xcodeproj \
  -scheme AfterStorm \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/AfterStorm.xcarchive \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  CODE_SIGN_STYLE=Automatic \
  archive

test -f build/AfterStorm.xcarchive/Info.plist
test -f build/AfterStorm.xcarchive/Products/Applications/AfterStorm.app/Info.plist
test -f build/AfterStorm.xcarchive/Products/Applications/AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist

echo "Signed archive created: $ROOT/build/AfterStorm.xcarchive"
echo "Next: open the archive in Xcode Organizer, validate it, and distribute to App Store Connect."
