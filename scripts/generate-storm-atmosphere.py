#!/usr/bin/env python3
"""Stage AfterStorm's licensed real storm atmosphere texture for the app bundle.

The photograph provides real cloud structure. AfterStorm's SwiftUI visual system
adds the original reactive storm -> clearing -> afterglow grading, glow, mist,
rain, lightning and parallax on top.
"""
from __future__ import annotations

import socket
import time
from pathlib import Path
from urllib.request import urlretrieve

ROOT = Path(__file__).resolve().parents[1]
STORM_BG_DIR = ROOT / "AfterStormApp/Resources/Assets.xcassets/StormAtmosphere.imageset"
OUTPUT_NAME = "storm-atmosphere.jpg"
OUTPUT_PATH = STORM_BG_DIR / OUTPUT_NAME

# Pexels photo 15532423 — Tom Van Dyck.
# License/provenance is recorded in docs/quality/third-party-asset-attributions.md.
PEXELS_SOURCE_URL = (
    "https://images.pexels.com/photos/15532423/pexels-photo-15532423.jpeg"
    "?cs=srgb&dl=pexels-tom-van-dyck-423949093-15532423.jpg&fm=jpg"
)
PHOTOGRAPHER = "Tom Van Dyck"


def validate_jpeg(path: Path) -> None:
    if not path.exists() or path.stat().st_size < 100_000:
        raise RuntimeError(f"Storm photograph is missing or unexpectedly small: {path}")

    with path.open("rb") as handle:
        start = handle.read(2)
        handle.seek(-2, 2)
        end = handle.read(2)

    if start != b"\xff\xd8" or end != b"\xff\xd9":
        raise RuntimeError("Downloaded StormAtmosphere payload is not a complete JPEG.")


def generate_storm_atmosphere() -> Path:
    STORM_BG_DIR.mkdir(parents=True, exist_ok=True)
    temporary = STORM_BG_DIR / f"{OUTPUT_NAME}.download"
    temporary.unlink(missing_ok=True)

    socket.setdefaulttimeout(45)
    last_error: Exception | None = None

    for attempt in range(1, 4):
        try:
            print(f"Fetching licensed StormAtmosphere from Pexels (attempt {attempt}/3)…")
            urlretrieve(PEXELS_SOURCE_URL, temporary)
            validate_jpeg(temporary)
            temporary.replace(OUTPUT_PATH)
            return OUTPUT_PATH
        except Exception as error:  # CI should fail rather than silently ship fake-looking art.
            last_error = error
            temporary.unlink(missing_ok=True)
            if attempt < 3:
                time.sleep(2 * attempt)

    raise RuntimeError(f"Unable to stage StormAtmosphere from Pexels: {last_error}")


def main() -> None:
    output = generate_storm_atmosphere()
    print(
        "Staged licensed real AfterStorm storm atmosphere "
        f"by {PHOTOGRAPHER}: {output.relative_to(ROOT)} ({output.stat().st_size:,} bytes)"
    )


if __name__ == "__main__":
    main()
