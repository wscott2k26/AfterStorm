#!/usr/bin/env bash
set -euo pipefail

printf '\n[0/6] Generate deterministic build assets\n'
python3 scripts/generate-assets.py

printf '\n[1/6] Swift core tests\n'
swift test

printf '\n[2/6] Native Swift syntax parse\n'
count=0
while IFS= read -r -d '' file; do
  swiftc -frontend -parse "$file" >/dev/null
  count=$((count + 1))
done < <(find AfterStormApp AfterStormWidget Shared -name '*.swift' -type f -print0 | sort -z)
echo "Parsed $count native Swift files"

printf '\n[3/6] Project YAML and target paths\n'
python - <<'PY'
from pathlib import Path
import yaml
with open('project.yml', encoding='utf-8') as handle:
    data = yaml.safe_load(handle)
assert set(data['targets']) == {'AfterStorm', 'AfterStormWidget'}
required = [
    'AfterStormApp/AfterStorm.entitlements',
    'AfterStormWidget/AfterStormWidget.entitlements',
    'AfterStormWidget/Info.plist',
    'AfterStormApp/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json',
]
for item in required:
    assert Path(item).exists(), item
for target_name, target in data['targets'].items():
    for source in target.get('sources', []):
        source_path = source['path'] if isinstance(source, dict) else source
        assert Path(source_path).exists(), f'{target_name}: missing source path {source_path}'
    for dependency in target.get('dependencies', []):
        if isinstance(dependency, dict) and 'target' in dependency:
            assert dependency['target'] in data['targets'], f'{target_name}: missing target dependency {dependency["target"]}'
print('YAML targets, source paths, dependencies, and required project files OK')
PY

printf '\n[4/6] JSON/plist/resource integrity\n'
python - <<'PY'
from pathlib import Path
import json, plistlib, wave
for path in Path('AfterStormApp/Resources/Assets.xcassets').rglob('Contents.json'):
    json.loads(path.read_text(encoding='utf-8'))
for plist_path in [
    'AfterStormWidget/Info.plist',
    'AfterStormApp/AfterStorm.entitlements',
    'AfterStormWidget/AfterStormWidget.entitlements',
]:
    with open(plist_path, 'rb') as handle:
        plistlib.load(handle)
for path in Path('AfterStormApp/Resources/Audio').glob('*.wav'):
    with wave.open(str(path), 'rb') as audio:
        assert audio.getframerate() == 44100
        assert audio.getnchannels() == 2
        assert audio.getsampwidth() == 2
print('Asset JSON, plists/entitlements, and audio files OK')
PY

printf '\n[5/6] Release-marker scan\n'
if grep -RniE 'TODO|TBD|fatalError|mock[ _-]?data|prototype-only' AfterStormApp AfterStormWidget Shared Sources Tests --include='*.swift' --exclude-dir='.build'; then
  echo 'Release-marker scan failed' >&2
  exit 1
fi
echo 'No forbidden release markers found'

printf '\n[6/6] Git diff hygiene\n'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git diff --check
  echo 'git diff --check clean'
else
  echo 'Git diff check skipped outside a Git worktree'
fi

printf '\nLOCAL AFTERSTORM VERIFICATION PASSED\n'
printf 'Note: this Linux check does not replace an Xcode/iOS SDK compile.\n'
