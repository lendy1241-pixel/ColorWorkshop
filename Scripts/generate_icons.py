#!/usr/bin/env python3
"""
调色工坊 App Icon 生成器
生成精美的程序化图标（无需设计工具）
需要: pip install Pillow
"""

import math
import os
import sys

try:
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
except ImportError:
    print("⚠️ Pillow 未安装。运行: pip install Pillow")
    print("使用纯色占位图标代替...")
    # 创建一个简单的纯色图标作为回退
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("❌ 无法生成图标，请安装 Pillow: pip install Pillow")
        sys.exit(0)

# 图标输出目录
OUTPUT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "ColorWorkshop", "Resources", "Assets.xcassets", "AppIcon.appiconset"
)

# 需要的图标尺寸
ICON_SIZES = {
    "iphone-20@2x": (40, 40),
    "iphone-20@3x": (60, 60),
    "iphone-29@2x": (58, 58),
    "iphone-29@3x": (87, 87),
    "iphone-40@2x": (80, 80),
    "iphone-40@3x": (120, 120),
    "iphone-60@2x": (120, 120),
    "iphone-60@3x": (180, 180),
    "ipad-20@1x": (20, 20),
    "ipad-20@2x": (40, 40),
    "ipad-29@1x": (29, 29),
    "ipad-29@2x": (58, 58),
    "ipad-40@1x": (40, 40),
    "ipad-40@2x": (80, 80),
    "ipad-76@1x": (76, 76),
    "ipad-76@2x": (152, 152),
    "ipad-83.5@2x": (167, 167),
    "ios-marketing@1x": (1024, 1024),
}


def draw_icon(size: int) -> Image.Image:
    """绘制精美的 App 图标"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === 1. 圆角矩形背景 ===
    corner_radius = int(size * 0.22)
    margin = 0

    # 渐变背景（用多个矩形模拟）
    for y in range(size):
        ratio = y / size
        # 从深紫到暖橙的渐变
        r = int(80 + ratio * 140)   # 80 -> 220
        g = int(20 + ratio * 55)    # 20 -> 75
        b = int(60 + (1-ratio) * 80)  # 140 -> 60
        draw.rectangle([margin, y, size - margin, y + 1], fill=(r, g, b))

    # === 2. 绘制色环 ===
    cx, cy = size // 2, size // 2
    ring_radius = int(size * 0.28)
    dot_radius = int(size * 0.085)
    ring_thickness = int(size * 0.06)

    # 色环底圈
    for angle_deg in range(360):
        hue = angle_deg / 360.0
        color = hsv_to_rgb(hue, 0.85, 0.9)

        # 外圈描边
        for t in range(ring_thickness):
            r = ring_radius + t
            x = cx + r * math.cos(math.radians(angle_deg - 90))
            y = cy + r * math.sin(math.radians(angle_deg - 90))
            draw.ellipse(
                [x - 0.5, y - 0.5, x + 0.5, y + 0.5],
                fill=color
            )

    # === 3. 六个彩色圆点（基础六色位置）===
    base_hues = [0.0, 0.0, 0.0, 0.6, 0.15, 0.3]  # R, W, Bk, B, Y, G
    base_sats = [0.9, 0.05, 0.0, 0.85, 0.9, 0.8]
    base_vals = [0.85, 0.95, 0.1, 0.7, 0.9, 0.65]
    base_angles = [0, 180, 270, 210, 60, 130]  # 六色在色环上的分布角度

    for i in range(6):
        angle = math.radians(base_angles[i])
        color = hsv_to_rgb(base_hues[i], base_sats[i], base_vals[i])

        dx = cx + (ring_radius + ring_thickness * 2) * math.cos(angle)
        dy = cy + (ring_radius + ring_thickness * 2) * math.sin(angle)

        # 光晕
        glow_radius = dot_radius + int(size * 0.03)
        for g in range(glow_radius, dot_radius, -1):
            alpha = int(30 * (1 - (g - dot_radius) / glow_radius))
            if alpha > 0:
                draw.ellipse(
                    [dx - g, dy - g, dx + g, dy + g],
                    fill=color + (alpha,)
                )

        # 圆点主体
        draw.ellipse(
            [dx - dot_radius, dy - dot_radius, dx + dot_radius, dy + dot_radius],
            fill=color
        )
        # 高光
        highlight_offset = int(dot_radius * 0.3)
        highlight_radius = int(dot_radius * 0.4)
        draw.ellipse(
            [
                dx - highlight_radius - highlight_offset,
                dy - highlight_radius - highlight_offset,
                dx + highlight_radius - highlight_offset,
                dy + highlight_radius - highlight_offset,
            ],
            fill=(255, 255, 255, 60)
        )

    # === 4. 中心调色板图标 ===
    center_radius = int(size * 0.12)
    # 白色圆底
    draw.ellipse(
        [cx - center_radius, cy - center_radius,
         cx + center_radius, cy + center_radius],
        fill=(255, 255, 255, 230)
    )

    # 调色板简化图形 - 几个小色块
    palette_colors = [
        (220, 60, 40),   # 红
        (240, 180, 20),  # 黄
        (30, 60, 180),   # 蓝
        (20, 140, 70),   # 绿
    ]
    small_dot_r = int(size * 0.025)
    for i, pc in enumerate(palette_colors):
        a = math.radians(i * 90 - 45)
        px = cx + center_radius * 0.55 * math.cos(a)
        py = cy + center_radius * 0.55 * math.sin(a)
        draw.ellipse(
            [px - small_dot_r, py - small_dot_r,
             px + small_dot_r, py + small_dot_r],
            fill=pc
        )

    # === 5. 整体柔光效果 ===
    img = img.filter(ImageFilter.GaussianBlur(radius=1))
    # 对于小尺寸不模糊
    if size < 40:
        img = img.filter(ImageFilter.GaussianBlur(radius=0))

    return img


def hsv_to_rgb(h: float, s: float, v: float) -> tuple:
    """HSV -> RGB (0-255)"""
    h = h % 1.0
    h6 = h * 6
    i = int(h6)
    f = h6 - i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)

    if i == 0:   r, g, b = v, t, p
    elif i == 1: r, g, b = q, v, p
    elif i == 2: r, g, b = p, v, t
    elif i == 3: r, g, b = p, q, v
    elif i == 4: r, g, b = t, p, v
    else:        r, g, b = v, p, q

    return (int(r * 255), int(g * 255), int(b * 255))


def generate_all_icons():
    """生成所有尺寸的图标"""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    largest_size = 1024
    print(f"🎨 正在生成主图标 ({largest_size}x{largest_size})...")
    master_icon = draw_icon(largest_size)

    for name, (w, h) in ICON_SIZES.items():
        if w == largest_size:
            resized = master_icon
        else:
            resized = master_icon.resize((w, h), Image.LANCZOS)

        filename = f"icon-{name}.png"
        filepath = os.path.join(OUTPUT_DIR, filename)
        resized.save(filepath, "PNG")
        print(f"  ✓ {filename} ({w}x{h})")

    print(f"\n✅ 所有图标已生成到: {OUTPUT_DIR}")
    print(f"   共 {len(ICON_SIZES)} 个文件")


if __name__ == "__main__":
    generate_all_icons()
