#!/usr/bin/env python3
"""
注入去Alpha图标到App Bundle根目录
绕过actool编译, 直接放RGB扁平PNG
用法: python3 inject_icons.py <app_bundle_path>
"""
import sys, os
from PIL import Image

# App bundle中的关键图标文件名 -> 像素尺寸
ICONS = {
    "AppIcon60x60@2x.png":     120,
    "AppIcon60x60@3x.png":     180,
    "AppIcon76x76@2x~ipad.png": 152,
}

def flatten_rgba(img):
    """去除alpha通道, 压平到白底"""
    if img.mode == "RGBA":
        bg = Image.new("RGB", img.size, (255, 255, 255))
        bg.paste(img, mask=img.split()[3])
        return bg
    return img.convert("RGB")

def main():
    if len(sys.argv) < 2:
        print("Usage: inject_icons.py <app_bundle_path>")
        sys.exit(1)

    app_path = sys.argv[1]
    asset_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        "ColorWorkshop", "Resources", "Assets.xcassets", "AppIcon.appiconset"
    )

    # 从1024px源图生成所有尺寸
    src_path = os.path.join(asset_dir, "icon-ios-marketing@1x.png")
    if not os.path.exists(src_path):
        print(f"ERROR: source icon not found at {src_path}")
        sys.exit(1)

    src = flatten_rgba(Image.open(src_path))
    print(f"Source icon: {src.size[0]}x{src.size[1]} mode={src.mode}")

    for filename, px in ICONS.items():
        out_path = os.path.join(app_path, filename)
        icon = src.resize((px, px), Image.LANCZOS)
        # 确保RGB格式
        if icon.mode != "RGB":
            icon = icon.convert("RGB")
        icon.save(out_path, "PNG")
        # 验证
        verify = Image.open(out_path)
        print(f"  {filename} {px}x{px} mode={verify.mode} ok={verify.mode=='RGB'}")

    print(f"Done - {len(ICONS)} icons injected to app bundle root")

if __name__ == "__main__":
    main()
