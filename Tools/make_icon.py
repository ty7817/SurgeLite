#!/usr/bin/env python3
"""纯标准库生成 1024x1024 App 图标（无第三方依赖，可在 CI 上直接跑）"""
import os, sys, zlib, struct

SIZE = 1024
SS = 2
W = SIZE * SS

TOP = (255, 152, 0)
BOTTOM = (232, 72, 26)

BOLT = [
    (0.60, 0.08),
    (0.26, 0.56),
    (0.46, 0.56),
    (0.40, 0.92),
    (0.74, 0.44),
    (0.54, 0.44),
]


def inside_polygon(px, py, pts):
    n = len(pts)
    j = n - 1
    inside = False
    for i in range(n):
        xi, yi = pts[i]
        xj, yj = pts[j]
        if ((yi > py) != (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi + 1e-12) + xi):
            inside = not inside
        j = i
    return inside


bolt = [(x * W, y * W) for x, y in BOLT]
rows = []
for y in range(W):
    t = y / (W - 1)
    r0 = int(TOP[0] + (BOTTOM[0] - TOP[0]) * t)
    g0 = int(TOP[1] + (BOTTOM[1] - TOP[1]) * t)
    b0 = int(TOP[2] + (BOTTOM[2] - TOP[2]) * t)
    row = bytearray()
    for x in range(W):
        if inside_polygon(x + 0.5, y + 0.5, bolt):
            row += bytes((255, 255, 255))
        else:
            row += bytes((r0, g0, b0))
    rows.append(row)

out = []
for y in range(SIZE):
    row = bytearray()
    for x in range(SIZE):
        ar = ag = ab = 0
        for dy in range(SS):
            line = rows[y * SS + dy]
            for dx in range(SS):
                i = (x * SS + dx) * 3
                ar += line[i]
                ag += line[i + 1]
                ab += line[i + 2]
        n = SS * SS
        row += bytes((ar // n, ag // n, ab // n))
    out.append(bytes(row))

raw = b"".join(b"\x00" + line for line in out)

def chunk(tag, data):
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

ihdr = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0)
idat = zlib.compress(raw, 9)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b"")

dst = sys.argv[1] if len(sys.argv) > 1 else "icon-1024.png"
os.makedirs(os.path.dirname(dst) or ".", exist_ok=True)
with open(dst, "wb") as f:
    f.write(png)
print("wrote", dst, len(png), "bytes")
