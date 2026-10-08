#!/usr/bin/env bash
# Fail if any QML/QML-JS file differs from qmlformat's output (config: .qmlformat.ini).
#   qmlformat-check.sh        check
#   qmlformat-check.sh --fix  rewrite files in place
set -euo pipefail
qmlformat="${QT_BIN:-/usr/lib/qt6/bin}/qmlformat"  # Qt 6; the plain name on PATH may be Qt 5
mapfile -t files < <(git ls-files --cached --others --exclude-standard -- '*.qml' 'contents/*.js' 'tests/*.qml')
[[ ${#files[@]} -eq 0 ]] && exit 0
if [[ "${1:-}" == "--fix" ]]; then
  "$qmlformat" -i "${files[@]}"
  exit 0
fi
bad=0
for f in "${files[@]}"; do
  if ! diff -q <("$qmlformat" "$f") "$f" >/dev/null; then
    echo "needs qmlformat: $f"
    bad=1
  fi
done
exit $bad
