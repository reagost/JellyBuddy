#!/usr/bin/env python3
"""Generate a feature graphic for Google Play Store (1024x500)."""

import os
from PIL import Image, ImageDraw, ImageFont

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
OUTPUT_PATH = os.path.join(PROJECT_DIR, "store", "feature_graphic.png")
ICON_PATH = os.path.join(PROJECT_DIR, "assets", "icon", "app_icon.png")

WIDTH, HEIGHT = 1024, 500


def get_font(size, bold=False):
    """Try to load a suitable font, fall back to default."""
    # macOS system fonts that support CJK
    font_paths = [
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/STHeiti Medium.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/Library/Fonts/Arial Unicode.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for path in font_paths:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()


def main():
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

    img = Image.new("RGB", (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(img)

    # Purple gradient background (#6C63FF to #9D97FF)
    for y in range(HEIGHT):
        ratio = y / HEIGHT
        r = int(0x6C + (0x9D - 0x6C) * ratio)
        g = int(0x63 + (0x97 - 0x63) * ratio)
        b = int(0xFF + (0xFF - 0xFF) * ratio)
        draw.line([(0, y), (WIDTH, y)], fill=(r, g, b))

    # Title text on the left side
    title_font = get_font(64, bold=True)
    subtitle_font = get_font(32)

    title_x = 80
    title_y = 170
    draw.text((title_x, title_y), "JellyBuddy", fill="white", font=title_font)
    draw.text(
        (title_x, title_y + 90),
        "AI \u7f16\u7a0b\u5b66\u4e60\u52a9\u624b",
        fill="white",
        font=subtitle_font,
    )

    # App icon on the right side
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA")
        icon = icon.resize((200, 200), Image.LANCZOS)

        # Create a circular mask
        mask = Image.new("L", (200, 200), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.rounded_rectangle([0, 0, 200, 200], radius=40, fill=255)

        # Paste icon with mask
        icon_x = WIDTH - 200 - 100
        icon_y = (HEIGHT - 200) // 2
        img.paste(icon, (icon_x, icon_y), mask)
    else:
        # Placeholder circle if icon not found
        icon_x = WIDTH - 200 - 100
        icon_y = (HEIGHT - 200) // 2
        draw.rounded_rectangle(
            [icon_x, icon_y, icon_x + 200, icon_y + 200],
            radius=40,
            fill=(255, 255, 255, 50),
        )

    img.save(OUTPUT_PATH, "PNG")
    print(f"Feature graphic saved to: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
