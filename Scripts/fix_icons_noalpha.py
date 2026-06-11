#!/usr/bin/env python3
"""
修复图标: 去除 Alpha 通道, 压平到白底
iOS SpringBoard 要求图标必须是不透明 PNG, 不能有透明通道
"""
import os, sys
try:
    from PIL import Image
except ImportError:
    print("need Pillow")
    sys.exit(1)

ASSETS = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "ColorWorkshop", "Resources", "Assets.xcassets", "AppIcon.appiconset"
)

def strip_alpha(filepath):
    img = Image.open(filepath)
    if img.mode != "RGBA":
        print(f"  skip {os.path.basename(filepath)} (mode={img.mode})")
        return
    # 压平到白底
    bg = Image.new("RGB", img.size, (255, 255, 255))
    bg.paste(img, mask=img.split()[3])  # 用alpha做mask
    bg.save(filepath, "PNG")
    print(f"  fixed {os.path.basename(filepath)} ({img.size[0]}x{img.size[1]})")

def main():
    for f in sorted(os.listdir(ASSETS)):
        if f.endswith(".png"):
            strip_alpha(os.path.join(ASSETS, f))
    print("done - all icons flattened, no alpha")

if __name__ == "__main__":
    main()
