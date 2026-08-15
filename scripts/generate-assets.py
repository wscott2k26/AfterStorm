#!/usr/bin/env python3
"""Generate AfterStorm's original launch icon sizes and synthetic audio cues.

No third-party packages are required. Assets are deterministic so a clean checkout
can recreate the exact build inputs used by CI.
"""
from __future__ import annotations

import math
import random
import struct
import wave
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ICON_DIR = ROOT / "AfterStormApp/Resources/Assets.xcassets/AppIcon.appiconset"
AUDIO_DIR = ROOT / "AfterStormApp/Resources/Audio"
SAMPLE_RATE = 44_100


def clamp(v: float, lo: float = 0.0, hi: float = 255.0) -> int:
    return int(max(lo, min(hi, round(v))))


def blend(dst: tuple[int, int, int], src: tuple[int, int, int], alpha: float) -> tuple[int, int, int]:
    a = max(0.0, min(1.0, alpha))
    return tuple(clamp(d * (1 - a) + s * a) for d, s in zip(dst, src))


def point_in_polygon(x: float, y: float, pts: list[tuple[float, float]]) -> bool:
    inside = False
    j = len(pts) - 1
    for i, (xi, yi) in enumerate(pts):
        xj, yj = pts[j]
        if ((yi > y) != (yj > y)) and (x < (xj - xi) * (y - yi) / ((yj - yi) or 1e-9) + xi):
            inside = not inside
        j = i
    return inside


def distance_to_segment(px: float, py: float, ax: float, ay: float, bx: float, by: float) -> float:
    dx, dy = bx - ax, by - ay
    denom = dx * dx + dy * dy
    if denom == 0:
        return math.hypot(px - ax, py - ay)
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / denom))
    return math.hypot(px - (ax + t * dx), py - (ay + t * dy))


def render_icon(size: int = 1024) -> bytes:
    w = h = size
    pixels = bytearray(w * h * 3)
    cloud_circles = [
        (0.38, 0.46, 0.135),
        (0.53, 0.40, 0.155),
        (0.67, 0.47, 0.125),
        (0.31, 0.51, 0.095),
        (0.70, 0.52, 0.085),
    ]
    bolt = [(0.525, 0.488), (0.635, 0.488), (0.572, 0.596), (0.677, 0.596),
            (0.453, 0.833), (0.522, 0.676), (0.434, 0.676)]
    rain = [((0.173, 0.157), (0.151, 0.241)),
            ((0.802, 0.200), (0.779, 0.273)),
            ((0.136, 0.677), (0.114, 0.740)),
            ((0.836, 0.705), (0.814, 0.789))]

    for y in range(h):
        fy = y / (h - 1)
        for x in range(w):
            fx = x / (w - 1)
            # Deep navy -> wet blue gradient with a restrained afterglow near the lower-right.
            t = 0.56 * fy + 0.18 * fx
            base = (
                7 + 22 * t,
                18 + 54 * t,
                34 + 70 * t,
            )
            glow = max(0.0, 1.0 - math.hypot(fx - 0.70, fy - 0.70) / 0.52)
            color = (
                clamp(base[0] + 38 * glow),
                clamp(base[1] + 42 * glow),
                clamp(base[2] + 20 * glow),
            )

            # Subtle perimeter glass line.
            edge = min(fx, fy, 1 - fx, 1 - fy)
            if 0.020 < edge < 0.024:
                color = blend(color, (115, 143, 169), 0.28)

            # Cloud: circles + central body. Soft halo first.
            cloud_d = min(math.hypot(fx - cx, fy - cy) - r for cx, cy, r in cloud_circles)
            body_inside = (0.24 <= fx <= 0.76 and 0.43 <= fy <= 0.61)
            if cloud_d < 0.02 or body_inside:
                alpha = 1.0 if cloud_d <= 0 or body_inside else max(0.0, 1.0 - cloud_d / 0.02) * 0.35
                cloud_shade = 238 - 18 * max(0.0, min(1.0, (fy - 0.36) / 0.30))
                color = blend(color, (clamp(cloud_shade), clamp(cloud_shade + 4), 246), alpha)

            # Lightning shadow and bolt.
            if point_in_polygon(fx - 0.012, fy - 0.018, bolt):
                color = blend(color, (13, 18, 24), 0.28)
            if point_in_polygon(fx, fy, bolt):
                # Warm gold with a tiny vertical gradient.
                gold = (255, clamp(211 - 18 * (fy - 0.48)), 74)
                color = blend(color, gold, 1.0)

            # Rain streaks.
            for (a, b) in rain:
                d = distance_to_segment(fx, fy, a[0], a[1], b[0], b[1])
                if d < 0.0042:
                    alpha = max(0.0, 1.0 - d / 0.0042)
                    color = blend(color, (203, 239, 255), 0.88 * alpha)

            idx = (y * w + x) * 3
            pixels[idx:idx+3] = bytes(color)
    return bytes(pixels)


def write_png(path: Path, width: int, height: int, rgb: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = b"".join(b"\x00" + rgb[y * width * 3:(y + 1) * width * 3] for y in range(height))

    def chunk(kind: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def resize_box(src: bytes, src_size: int, dst_size: int) -> bytes:
    if src_size == dst_size:
        return src
    out = bytearray(dst_size * dst_size * 3)
    scale = src_size / dst_size
    for dy in range(dst_size):
        sy0 = int(dy * scale)
        sy1 = max(sy0 + 1, int((dy + 1) * scale))
        for dx in range(dst_size):
            sx0 = int(dx * scale)
            sx1 = max(sx0 + 1, int((dx + 1) * scale))
            r = g = b = n = 0
            for sy in range(sy0, min(sy1, src_size)):
                row = sy * src_size * 3
                for sx in range(sx0, min(sx1, src_size)):
                    i = row + sx * 3
                    r += src[i]; g += src[i+1]; b += src[i+2]; n += 1
            i = (dy * dst_size + dx) * 3
            out[i:i+3] = bytes((r // n, g // n, b // n))
    return bytes(out)


def generate_icons() -> None:
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    master_size = 1024
    master = render_icon(master_size)
    specs = {
        "AppIcon-1024.png": 1024,
        "AppIcon-20@2x.png": 40,
        "AppIcon-20@3x.png": 60,
        "AppIcon-29@2x.png": 58,
        "AppIcon-29@3x.png": 87,
        "AppIcon-40@2x.png": 80,
        "AppIcon-40@3x.png": 120,
        "AppIcon-60@2x.png": 120,
        "AppIcon-60@3x.png": 180,
    }
    for name, size in specs.items():
        write_png(ICON_DIR / name, size, size, resize_box(master, master_size, size))


def fade(i: int, total: int, attack: float = 0.04, release: float = 0.16) -> float:
    a = min(1.0, i / max(1, int(total * attack)))
    r = min(1.0, (total - 1 - i) / max(1, int(total * release)))
    return max(0.0, min(a, r))


def write_wav(name: str, seconds: float, sample_fn, loop_fade: bool = False) -> None:
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    frames = int(SAMPLE_RATE * seconds)
    rng = random.Random(0xA57E + sum(ord(c) for c in name))
    with wave.open(str(AUDIO_DIR / f"{name}.wav"), "wb") as out:
        out.setnchannels(2)
        out.setsampwidth(2)
        out.setframerate(SAMPLE_RATE)
        buf = bytearray()
        for i in range(frames):
            t = i / SAMPLE_RATE
            left, right = sample_fn(t, i, frames, rng)
            if loop_fade:
                # Keep endpoints near zero so looping ambience does not click.
                e = min(1.0, i / 1200, (frames - 1 - i) / 1200)
                left *= e; right *= e
            li = int(max(-1.0, min(1.0, left)) * 32767)
            ri = int(max(-1.0, min(1.0, right)) * 32767)
            buf += struct.pack("<hh", li, ri)
        out.writeframes(buf)


def generate_audio() -> None:
    def storm(t, i, n, rng):
        env = fade(i, n, 0.02, 0.28)
        low = math.sin(2 * math.pi * 54 * t) * math.exp(-1.25 * t)
        rumble = (rng.random() * 2 - 1) * 0.18 * math.exp(-0.65 * t)
        rain = (rng.random() * 2 - 1) * 0.035
        v = (0.58 * low + rumble + rain) * env
        return v, v * 0.94

    def complete(t, i, n, rng):
        env = fade(i, n, 0.015, 0.30)
        v = (0.34 * math.sin(2 * math.pi * 659.25 * t) +
             0.28 * math.sin(2 * math.pi * 830.61 * t) +
             0.18 * math.sin(2 * math.pi * 987.77 * t)) * math.exp(-2.6 * t) * env
        return v, v * 0.98

    def restore(t, i, n, rng):
        env = fade(i, n, 0.01, 0.22)
        impact = 0.60 * math.sin(2 * math.pi * (82 - 24 * min(t, 1)) * t) * math.exp(-2.0 * t)
        shimmer = 0.12 * math.sin(2 * math.pi * 1046.5 * t) * math.exp(-1.25 * max(0, t - 0.18)) if t > 0.18 else 0
        noise = (rng.random() * 2 - 1) * 0.08 * math.exp(-2.4 * t)
        v = (impact + shimmer + noise) * env
        return v, v * 0.96

    def unlock(t, i, n, rng):
        env = fade(i, n, 0.01, 0.25)
        notes = (523.25, 659.25, 783.99)
        v = 0.0
        for k, f in enumerate(notes):
            start = 0.10 * k
            if t >= start:
                v += 0.20 * math.sin(2 * math.pi * f * (t - start)) * math.exp(-3.1 * (t - start))
        return v * env, v * env

    def rain(t, i, n, rng):
        # Low, non-distracting rain bed with slightly different stereo noise.
        l = (rng.random() * 2 - 1) * 0.055 + 0.010 * math.sin(2 * math.pi * 73 * t)
        r = (rng.random() * 2 - 1) * 0.055 + 0.010 * math.sin(2 * math.pi * 79 * t)
        return l, r

    def afterglow(t, i, n, rng):
        lfo = 0.72 + 0.28 * math.sin(2 * math.pi * 0.08 * t)
        base = (0.035 * math.sin(2 * math.pi * 196.0 * t) +
                0.026 * math.sin(2 * math.pi * 293.66 * t) +
                0.020 * math.sin(2 * math.pi * 392.0 * t)) * lfo
        return base, base * 0.96

    write_wav("storm-intro", 2.15, storm)
    write_wav("quest-complete", 1.25, complete)
    write_wav("restoration-impact", 1.80, restore)
    write_wav("unlock", 1.15, unlock)
    write_wav("world-rain", 6.0, rain, loop_fade=True)
    write_wav("world-afterglow", 6.0, afterglow, loop_fade=True)


def main() -> None:
    generate_icons()
    generate_audio()
    print("Generated AfterStorm app icons and six original WAV cues.")


if __name__ == "__main__":
    main()
