#!/usr/bin/env bash
# Build the KDE Store upload: dist/koma-workspace-indicator-<version>.plasmoid (a zip of the package).
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
version=$(python3 -c 'import json; print(json.load(open("metadata.json"))["KPlugin"]["Version"])')
out="dist/koma-workspace-indicator-$version.plasmoid"
mkdir -p dist
rm -f "$out"
# only what the package needs, as tracked by git (no dev files, no stray edits)
git ls-files -- metadata.json contents LICENSE NOTICE.md | zip -q -X "$out" -@
echo "$out ($(du -h "$out" | cut -f1))"
