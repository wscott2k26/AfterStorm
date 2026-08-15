#!/usr/bin/env python3
"""Stage AfterStorm's licensed real storm atmosphere texture for the app bundle.

The photograph provides real cloud structure. AfterStorm's SwiftUI visual system
adds the original reactive storm -> clearing -> afterglow grading, glow, mist,
rain, lightning and parallax on top.
"""
from __future__ import annotations

import shutil
import socket
import time
from pathlib import Path
from urllib.request import Request, urlopen

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
PEXELS_PAGE_URL = "https://www.pexels.com/photo/dramatic-sky-with-storm-clouds-15532423/"
PHOTOGRAPHER = "Tom Van Dyck"
REQUEST_HEADERS = {
    # images.pexels.com rejects Python's default urllib identity on hosted CI.
    # These normal browser request headers mirror the public download link.
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/131.0 Safari/537.36"
    ),
    "Accept": "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
    "Referer": PEXELS_PAGE_URL,
}


def validate_jpeg(path: Path) -> None:
    if not path.exists() or path.stat().st_size < 100_000:
        raise RuntimeError(f"Storm photograph is missing or unexpectedly small: {path}")

    with path.open("rb") as handle:
        start = handle.read(2)
        handle.seek(-2, 2)
        end = handle.read(2)

    if start != b"\xff\xd8" or end != b"\xff\xd9":
        raise RuntimeError("Downloaded StormAtmosphere payload is not a complete JPEG.")


def download_photo(destination: Path) -> None:
    request = Request(PEXELS_SOURCE_URL, headers=REQUEST_HEADERS)
    with urlopen(request, timeout=45) as response, destination.open("wb") as output:
        shutil.copyfileobj(response, output)


def generate_storm_atmosphere() -> Path:
    STORM_BG_DIR.mkdir(parents=True, exist_ok=True)
    temporary = STORM_BG_DIR / f"{OUTPUT_NAME}.download"
    temporary.unlink(missing_ok=True)

    socket.setdefaulttimeout(45)
    last_error: Exception | None = None

    for attempt in range(1, 4):
        try:
            print(f"Fetching licensed StormAtmosphere from Pexels (attempt {attempt}/3)…")
            download_photo(temporary)
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
