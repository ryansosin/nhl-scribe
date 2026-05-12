#!/usr/bin/env python3
"""
NHL Logo Fetcher for Hockey Scribe
Downloads SVG logos from the NHL CDN and installs them directly into the
Xcode asset catalog as vector imagesets named logo_{ABBREV}.

Usage:
    python3 fetch_logos.py

Requires:
    pip install requests
"""

import json
import os
import sys
import requests

NHL_SVG_URL = "https://assets.nhle.com/logos/nhl/svg/{abbr}_dark.svg"

TEAMS = [
    "ANA", "BOS", "BUF", "CAR", "CGY", "CHI", "COL", "CBJ",
    "DAL", "DET", "EDM", "FLA", "LAK", "MIN", "MTL", "NSH",
    "NJD", "NYI", "NYR", "OTT", "PHI", "PIT", "SEA", "SJS",
    "STL", "TBL", "TOR", "UTA", "VAN", "VGK", "WSH", "WPG",
]

ASSET_CATALOG = os.path.join(
    os.path.dirname(__file__),
    "Hockey Scribe",
    "Hockey Scribe",
    "Assets.xcassets",
)

CONTENTS_JSON = {
    "images": [
        {
            "filename": "",   # filled in per team
            "idiom": "universal",
        }
    ],
    "info": {
        "author": "xcode",
        "version": 1,
    },
    "properties": {
        "preserves-vector-representation": True,
    },
}


def install_logo(abbrev: str, svg_bytes: bytes) -> None:
    imageset_dir = os.path.join(ASSET_CATALOG, f"logo_{abbrev}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)

    svg_filename = f"logo_{abbrev}.svg"
    svg_path = os.path.join(imageset_dir, svg_filename)
    with open(svg_path, "wb") as f:
        f.write(svg_bytes)

    contents = dict(CONTENTS_JSON)
    contents["images"] = [{"filename": svg_filename, "idiom": "universal"}]
    contents_path = os.path.join(imageset_dir, "Contents.json")
    with open(contents_path, "w") as f:
        json.dump(contents, f, indent=2)


def main() -> None:
    if not os.path.isdir(ASSET_CATALOG):
        print(f"ERROR: Asset catalog not found at:\n  {ASSET_CATALOG}")
        sys.exit(1)

    success, failed = [], []

    for abbrev in TEAMS:
        url = NHL_SVG_URL.format(abbr=abbrev)
        print(f"[{abbrev}] ...", end=" ", flush=True)
        try:
            resp = requests.get(url, timeout=10)
            resp.raise_for_status()
        except Exception as e:
            print(f"DOWNLOAD FAILED: {e}")
            failed.append(abbrev)
            continue

        try:
            install_logo(abbrev, resp.content)
            print("OK")
            success.append(abbrev)
        except Exception as e:
            print(f"INSTALL FAILED: {e}")
            failed.append(abbrev)

    print(f"\n{len(success)}/{len(TEAMS)} logos installed to:\n  {ASSET_CATALOG}")
    if failed:
        print(f"Failed: {', '.join(failed)}")


if __name__ == "__main__":
    main()
