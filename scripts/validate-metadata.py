#!/usr/bin/env python3
"""Release checks for metadata.json: required keys, id convention, and the
version agreeing with package.json and the top CHANGELOG entry."""

import json
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
errors = []
md = json.loads((root / "metadata.json").read_text())
kp = md.get("KPlugin", {})
for key in ("Id", "Name", "Description", "Version", "License", "Icon", "Authors", "Category"):
    if not kp.get(key):
        errors.append(f"metadata.json: KPlugin.{key} is missing")
if not re.fullmatch(r"kde-desktop\.workspaces", kp.get("Id", "")):
    errors.append(f"metadata.json: Id {kp.get('Id')!r} must stay kde-desktop.workspaces (existing panels refer to it)")
if md.get("KPackageStructure") != "Plasma/Applet":
    errors.append("metadata.json: KPackageStructure should be Plasma/Applet")
version = kp.get("Version", "")
if not re.fullmatch(r"\d+\.\d+(\.\d+)?", version):
    errors.append(f"metadata.json: Version {version!r} is not N.N or N.N.N")
pkg_version = json.loads((root / "package.json").read_text()).get("version", "")
if pkg_version.removesuffix(".0") != version.removesuffix(".0"):
    errors.append(f"package.json version {pkg_version} != metadata.json {version}")
changelog = (root / "CHANGELOG.md").read_text() if (root / "CHANGELOG.md").exists() else ""
m = re.search(r"^## \[?(\d+\.\d+(?:\.\d+)?)", changelog, re.M)
if not m or m.group(1).removesuffix(".0") != version.removesuffix(".0"):
    errors.append(f"CHANGELOG.md: top entry {m and m.group(1)} != metadata.json {version}")
for e in errors:
    print(e, file=sys.stderr)
sys.exit(1 if errors else 0)
