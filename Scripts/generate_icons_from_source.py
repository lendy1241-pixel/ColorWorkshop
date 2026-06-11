#!/usr/bin/env python3
"""
从用户提供的图标源文件生成所有 iOS App 图标尺寸
"""

import os
import sys

try:
    from PIL import Image
except ImportError:
    print("❌ 需要 Pillow: pip install Pillow")
    sys.exit(1)

# 源图标
SOURCE = os.path.join(os.environ.get("USERPROFILE", ""), "Downloads", "调色盘图标生成 (1).png")

# 输出目录
OUTPUT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "ColorWorkshop", "Resources", "Assets.xcassets", "AppIcon.appiconset"
)

# iOS 需要的所有图标尺寸 (idiom, size, scale → pixel size)
SIZES = [
    ("iphone-20@2x",       40),
    ("iphone-20@3x",       60),
    ("iphone-29@2x",       58),
    ("iphone-29@3x",       87),
    ("iphone-40@2x",       80),
    ("iphone-40@3x",      120),
    ("iphone-60@2x",      120),
    ("iphone-60@3x",      180),
    ("ipad-20@1x",         20),
    ("ipad-20@2x",         40),
    ("ipad-29@1x",         29),
    ("ipad-29@2x",         58),
    ("ipad-40@1x",         40),
    ("ipad-40@2x",         80),
    ("ipad-76@1x",         76),
    ("ipad-76@2x",        152),
    ("ipad-83.5@2x",      167),
    ("ios-marketing@1x", 1024),
]


def generate():
    if not os.path.exists(SOURCE):
        print(f"❌ 源文件未找到: {SOURCE}")
        print("请确认下载目录中有 '调色盘图标生成 (1).png'")
        sys.exit(1)

    os.makedirs(OUTPUT, exist_ok=True)

    print(f"[Icon] Loading source: {SOURCE}")
    src = Image.open(SOURCE).convert("RGBA")
    print(f"   原始尺寸: {src.size[0]}x{src.size[1]}")

    # 取较大边做正方形裁剪
    w, h = src.size
    size = min(w, h)
    left = (w - size) // 2
    top = (h - size) // 2
    src = src.crop((left, top, left + size, size))

    # 更新 Contents.json
    images_entries = []

    for name, px in SIZES:
        filename = f"icon-{name}.png"
        filepath = os.path.join(OUTPUT, filename)

        if px == size:
            resized = src
        else:
            resized = src.resize((px, px), Image.LANCZOS)

        resized.save(filepath, "PNG")
        print(f"  ✓ {filename} ({px}x{px})")

        # 构建 Contents.json 条目
        parts = name.split("-")
        idiom_part = parts[0]
        scale_part = parts[1] if len(parts) > 1 else "1x"

        idiom = "iphone" if idiom_part == "iphone" else "ipad" if idiom_part == "ipad" else "ios-marketing"
        scale = scale_part.replace("@", "")

        # ios-marketing 特殊处理
        if idiom_part == "ios-marketing":
            images_entries.append({
                "idiom": "ios-marketing",
                "scale": "1x",
                "size": "1024x1024",
                "filename": filename,
            })
            continue

        # size 映射
        size_map = {
            20: "20x20", 29: "29x29", 40: "40x40",
            60: "60x60", 76: "76x76", 83: "83.5x83.5",
        }
        actual_size = None
        for k, v in size_map.items():
            if name.startswith(f"{idiom_part}-{k}"):
                actual_size = v
                break
        # fallback
        if actual_size is None:
            if "83" in name:
                actual_size = "83.5x83.5"
            elif "76" in name:
                actual_size = "76x76"
            elif "60" in name:
                actual_size = "60x60"
            elif "40" in name:
                actual_size = "40x40"
            elif "29" in name:
                actual_size = "29x29"
            elif "20" in name:
                actual_size = "20x20"

        images_entries.append({
            "idiom": idiom,
            "scale": scale,
            "size": actual_size,
            "filename": filename,
        })

    # 写入 Contents.json
    import json
    contents = {
        "images": images_entries,
        "info": {
            "author": "xcode",
            "version": 1,
        },
    }
    contents_path = os.path.join(OUTPUT, "Contents.json")
    with open(contents_path, "w", encoding="utf-8") as f:
        json.dump(contents, f, indent=2, ensure_ascii=False)
    print(f"\n✅ Contents.json 已更新")
    print(f"✅ 共生成 {len(SIZES)} 个图标文件")


if __name__ == "__main__":
    generate()
