#!/usr/bin/env python3
"""Generate AfterStorm's original deterministic storm atmosphere texture.

The texture is deliberately neutral/cool so SwiftUI can tint it from storm blue
through teal and warm afterglow as restoration progresses. No third-party
packages or external image licenses are required.
"""
from __future__ import annotations

import math
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STORM_BG_DIR = ROOT / "AfterStormApp/Resources/Assets.xcassets/StormAtmosphere.imageset"
OUTPUT_NAME = "storm-atmosphere.png"
WIDTH = 640
HEIGHT = 1386


def clamp(value: float, lo: float = 0.0, hi: float = 255.0) -> int:
    return int(max(lo, min(hi, round(value))))


def mix(a: float, b: float, t: float) -> float:
    t = max(0.0, min(1.0, t))
    return a + (b - a) * t


def smoothstep(edge0: float, edge1: float, value: float) -> float:
    if edge0 == edge1:
        return 0.0
    t = max(0.0, min(1.0, (value - edge0) / (edge1 - edge0)))
    return t * t * (3.0 - 2.0 * t)


def lattice(ix: int, iy: int, seed: int) -> float:
    n = ix * 374761393 + iy * 668265263 + seed * 69069
    n = (n ^ (n >> 13)) * 1274126177
    n ^= n >> 16
    return (n & 0xFFFFFFFF) / 0xFFFFFFFF


def value_noise(x: float, y: float, frequency: float, seed: int) -> float:
    px = x * frequency
    py = y * frequency
    x0 = math.floor(px)
    y0 = math.floor(py)
    tx = px - x0
    ty = py - y0
    sx = tx * tx * (3.0 - 2.0 * tx)
    sy = ty * ty * (3.0 - 2.0 * ty)

    n00 = lattice(x0, y0, seed)
    n10 = lattice(x0 + 1, y0, seed)
    n01 = lattice(x0, y0 + 1, seed)
    n11 = lattice(x0 + 1, y0 + 1, seed)
    top = mix(n00, n10, sx)
    bottom = mix(n01, n11, sx)
    return mix(top, bottom, sy)


def fbm(x: float, y: float, seed: int = 57) -> float:
    total = 0.0
    amplitude = 0.54
    norm = 0.0
    for octave, frequency in enumerate((1.7, 3.4, 6.8, 13.6, 27.2)):
        total += value_noise(x, y, frequency, seed + octave * 19) * amplitude
        norm += amplitude
        amplitude *= 0.52
    return total / norm


def blend_rgb(base: tuple[float, float, float], overlay: tuple[float, float, float], amount: float) -> tuple[float, float, float]:
    t = max(0.0, min(1.0, amount))
    return tuple(mix(a, b, t) for a, b in zip(base, overlay))


def render_storm_atmosphere(width: int = WIDTH, height: int = HEIGHT) -> bytes:
    pixels = bytearray(width * height * 3)

    for y in range(height):
        fy = y / max(1, height - 1)
        for x in range(width):
            fx = x / max(1, width - 1)

            # Slightly warped coordinates keep cloud bands from looking like noise tiles.
            warp = value_noise(fx, fy, 2.1, 901) - 0.5
            nx = fx + warp * 0.055
            ny = fy + (value_noise(fx, fy, 2.7, 313) - 0.5) * 0.035
            cloud_noise = fbm(nx * 1.12, ny * 0.92)
            detail = fbm(nx * 2.4 + 0.31, ny * 2.0 + 0.17, seed=149)

            # Cloud concentration is heavier in the upper/mid sky and opens slightly lower down.
            vertical_mass = 0.13 * (1.0 - fy) + 0.08 * math.exp(-((fy - 0.33) / 0.20) ** 2)
            density = smoothstep(0.43, 0.72, cloud_noise + vertical_mass)
            billow = smoothstep(0.38, 0.78, detail)
            density = min(1.0, density * 0.78 + billow * 0.30)

            # Deep navy base with a subtle wet-blue horizon.
            base_t = 0.56 * fy + 0.12 * fx
            color: tuple[float, float, float] = (
                6 + 14 * base_t,
                14 + 31 * base_t,
                29 + 53 * base_t,
            )

            # Cloud bodies retain blue-gray color instead of becoming flat monochrome gray.
            light_from_right = max(0.0, 1.0 - math.hypot(fx - 0.78, fy - 0.18) / 0.68)
            cloud_light = 0.28 + 0.48 * light_from_right + 0.16 * billow
            cloud_rgb = (
                48 + 76 * cloud_light,
                61 + 91 * cloud_light,
                82 + 100 * cloud_light,
            )
            color = blend_rgb(color, cloud_rgb, density * 0.78)

            # Dense pockets add realistic dark undersides.
            underside = smoothstep(0.58, 0.84, cloud_noise + (0.10 if fy > 0.18 else 0.0))
            color = blend_rgb(color, (14, 22, 37), underside * density * 0.42)

            # Electric-blue backlight breaking through the cloud deck.
            glow = max(0.0, 1.0 - math.hypot(fx - 0.76, fy - 0.18) / 0.46)
            glow = glow * glow * (0.42 + (1.0 - density) * 0.58)
            color = blend_rgb(color, (86, 165, 224), glow * 0.38)

            # Cool mist at the lower horizon creates depth behind glass surfaces.
            mist = smoothstep(0.58, 0.96, fy) * (0.48 + 0.52 * value_noise(fx, fy, 5.0, 777))
            color = blend_rgb(color, (70, 111, 139), mist * 0.19)

            # Gentle vignette keeps foreground text and glass readable near edges.
            edge_x = abs(fx - 0.5) / 0.5
            edge_y = abs(fy - 0.48) / 0.58
            vignette = smoothstep(0.58, 1.16, max(edge_x, edge_y))
            color = blend_rgb(color, (3, 8, 18), vignette * 0.31)

            # Tiny luminance variation prevents large smooth areas from feeling synthetic.
            grain = (lattice(x, y, 1217) - 0.5) * 4.0
            color = tuple(channel + grain for channel in color)

            index = (y * width + x) * 3
            pixels[index:index + 3] = bytes(clamp(channel) for channel in color)

    return bytes(pixels)


def write_png(path: Path, width: int, height: int, rgb: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = b"".join(b"\x00" + rgb[y * width * 3:(y + 1) * width * 3] for y in range(height))

    def chunk(kind: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(kind + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", crc)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def generate_storm_atmosphere() -> Path:
    STORM_BG_DIR.mkdir(parents=True, exist_ok=True)
    output = STORM_BG_DIR / OUTPUT_NAME
    write_png(output, WIDTH, HEIGHT, render_storm_atmosphere())
    return output


def main() -> None:
    output = generate_storm_atmosphere()
    print(f"Generated deterministic AfterStorm storm atmosphere: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
