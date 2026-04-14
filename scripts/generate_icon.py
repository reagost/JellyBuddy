#!/usr/bin/env python3
"""Generate app icon for JellyBuddy.

Creates a 1024x1024 app icon with:
- Purple gradient background (#6C63FF to #9D97FF)
- Rounded corners (200px radius)
- Centered white circle with "JB" text

Also creates an adaptive icon foreground variant on transparent background.
"""

import os
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
CORNER_RADIUS = 200
CIRCLE_DIAMETER = 500

# Colors
COLOR_TOP_LEFT = (108, 99, 255)       # #6C63FF
COLOR_BOTTOM_RIGHT = (157, 151, 255)  # #9D97FF
WHITE = (255, 255, 255)


def create_gradient(size, color1, color2):
    """Create a diagonal gradient from top-left to bottom-right."""
    img = Image.new("RGBA", (size, size))
    pixels = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            r = int(color1[0] + (color2[0] - color1[0]) * t)
            g = int(color1[1] + (color2[1] - color1[1]) * t)
            b = int(color1[2] + (color2[2] - color1[2]) * t)
            pixels[x, y] = (r, g, b, 255)
    return img


def round_corners(img, radius):
    """Apply rounded corners to an image."""
    mask = Image.new("L", img.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle(
        [(0, 0), (img.size[0] - 1, img.size[1] - 1)],
        radius=radius,
        fill=255,
    )
    result = img.copy()
    result.putalpha(mask)
    return result


def find_font(size):
    """Try to find a bold system font, fallback to default."""
    font_paths = [
        "/System/Library/Fonts/SFNSRounded.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Bold.ttf",
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/SFNSDisplay.ttf",
    ]
    for path in font_paths:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()


def draw_jb_text(draw, cx, cy, font, color):
    """Draw 'JB' text centered at (cx, cy)."""
    text = "JB"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = cx - tw // 2 - bbox[0]
    ty = cy - th // 2 - bbox[1]
    draw.text((tx, ty), text, fill=color, font=font)


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    output_dir = os.path.join(project_root, "assets", "icon")
    os.makedirs(output_dir, exist_ok=True)

    font = find_font(220)
    cx, cy = SIZE // 2, SIZE // 2
    circle_r = CIRCLE_DIAMETER // 2

    # === App Icon (gradient background + rounded corners + white circle + JB) ===
    print("Creating app icon...")
    gradient = create_gradient(SIZE, COLOR_TOP_LEFT, COLOR_BOTTOM_RIGHT)
    icon = round_corners(gradient, CORNER_RADIUS)
    draw = ImageDraw.Draw(icon)
    draw.ellipse(
        [(cx - circle_r, cy - circle_r), (cx + circle_r, cy + circle_r)],
        fill=WHITE,
    )
    draw_jb_text(draw, cx, cy, font, COLOR_TOP_LEFT)

    icon_path = os.path.join(output_dir, "app_icon.png")
    icon.save(icon_path, "PNG")
    print(f"  Saved: {icon_path}")

    # === Adaptive Icon Foreground (transparent bg, content in center 66.67%) ===
    # Android adaptive icons: 108dp canvas, 72dp safe zone = 66.67% center area
    print("Creating adaptive icon foreground...")
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_fg = ImageDraw.Draw(fg)

    safe_ratio = 0.6667
    safe_circle_r = int(circle_r * safe_ratio)
    draw_fg.ellipse(
        [(cx - safe_circle_r, cy - safe_circle_r),
         (cx + safe_circle_r, cy + safe_circle_r)],
        fill=WHITE,
    )
    fg_font = find_font(int(220 * safe_ratio))
    draw_jb_text(draw_fg, cx, cy, fg_font, COLOR_TOP_LEFT)

    fg_path = os.path.join(output_dir, "app_icon_foreground.png")
    fg.save(fg_path, "PNG")
    print(f"  Saved: {fg_path}")

    print("Done!")


if __name__ == "__main__":
    main()
