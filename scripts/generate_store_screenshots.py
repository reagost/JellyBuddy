#!/usr/bin/env python3
"""Generate marketing mockup screenshots for App Store / Google Play (1290x2796)."""

import os
from PIL import Image, ImageDraw, ImageFont

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
OUTPUT_DIR = os.path.join(PROJECT_DIR, "store", "screenshots")

WIDTH, HEIGHT = 1290, 2796

SCREENSHOTS = [
    {
        "emoji": "\U0001F3AE",
        "headline": "\u50CF\u73A9\u6E38\u620F\u4E00\u6837\u5B66\u7F16\u7A0B",
        "subtitle": "\u95EF\u5173\u3001\u7B54\u9898\u3001\u8D5A\u7ECF\u9A8C\u503C",
        "filename": "screenshot_01.png",
    },
    {
        "emoji": "\U0001F4DD",
        "headline": "4\u79CD\u9898\u578B",
        "subtitle": "\u9009\u62E9\u3001\u586B\u7A7A\u3001\u6392\u5E8F\u3001\u7F16\u7A0B",
        "filename": "screenshot_02.png",
    },
    {
        "emoji": "\U0001F916",
        "headline": "AI \u52A9\u624B\u968F\u65F6\u89E3\u7B54",
        "subtitle": "\u672C\u5730\u5927\u6A21\u578B\uFF0C\u9690\u79C1\u4FDD\u62A4",
        "filename": "screenshot_03.png",
    },
    {
        "emoji": "\U0001F319",
        "headline": "\u6DF1\u8272\u6A21\u5F0F",
        "subtitle": "\u4FDD\u62A4\u4F60\u7684\u773C\u775B",
        "filename": "screenshot_04.png",
    },
    {
        "emoji": "\U0001F4CA",
        "headline": "\u5B66\u4E60\u7EDF\u8BA1",
        "subtitle": "\u8FFD\u8E2A\u4F60\u7684\u8FDB\u6B65",
        "filename": "screenshot_05.png",
    },
    {
        "emoji": "\U0001F40D\u26A1\u2699\uFE0F",
        "headline": "\u4E09\u95E8\u8BFE\u7A0B",
        "subtitle": "Python \u00B7 JavaScript \u00B7 C++",
        "filename": "screenshot_06.png",
    },
]


def get_font(size):
    """Try to load a suitable CJK-capable font."""
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


def get_emoji_font(size):
    """Try to load Apple Color Emoji or fall back to text font."""
    emoji_paths = [
        "/System/Library/Fonts/Apple Color Emoji.ttc",
    ]
    for path in emoji_paths:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return get_font(size)


def draw_gradient(draw, width, height, color1, color2):
    """Draw a vertical gradient."""
    r1, g1, b1 = color1
    r2, g2, b2 = color2
    for y in range(height):
        ratio = y / height
        r = int(r1 + (r2 - r1) * ratio)
        g = int(g1 + (g2 - g1) * ratio)
        b = int(b1 + (b2 - b1) * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))


def create_screenshot(data, index):
    """Create a single mockup screenshot."""
    img = Image.new("RGB", (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(img)

    # Gradient backgrounds - vary by screenshot
    gradients = [
        ((0x6C, 0x63, 0xFF), (0x9D, 0x97, 0xFF)),  # purple
        ((0x43, 0xA0, 0x47), (0x66, 0xBB, 0x6A)),  # green
        ((0x15, 0x65, 0xC0), (0x42, 0xA5, 0xF5)),  # blue
        ((0x37, 0x47, 0x4F), (0x54, 0x6E, 0x7A)),  # dark gray
        ((0xE6, 0x51, 0x00), (0xFF, 0x8A, 0x65)),  # orange
        ((0x6C, 0x63, 0xFF), (0xE9, 0x1E, 0x63)),  # purple-to-pink
    ]
    grad = gradients[index % len(gradients)]
    draw_gradient(draw, WIDTH, HEIGHT, grad[0], grad[1])

    # White phone frame (rounded rect) in center
    frame_margin_x = 120
    frame_margin_top = 500
    frame_margin_bottom = 400
    frame_rect = [
        frame_margin_x,
        frame_margin_top,
        WIDTH - frame_margin_x,
        HEIGHT - frame_margin_bottom,
    ]
    draw.rounded_rectangle(frame_rect, radius=50, fill=(255, 255, 255))

    # Inner "screen" area (slightly darker)
    screen_margin = 20
    screen_rect = [
        frame_rect[0] + screen_margin,
        frame_rect[1] + screen_margin,
        frame_rect[2] - screen_margin,
        frame_rect[3] - screen_margin,
    ]
    draw.rounded_rectangle(screen_rect, radius=35, fill=(245, 245, 245))

    # Draw a simple UI mockup inside the screen
    inner_x = screen_rect[0] + 40
    inner_y = screen_rect[1] + 60
    inner_w = screen_rect[2] - screen_rect[0] - 80

    # Status bar mockup
    small_font = get_font(28)
    draw.text((inner_x, inner_y), "9:41", fill=(100, 100, 100), font=small_font)

    # App name bar
    bar_y = inner_y + 60
    bar_font = get_font(36)
    draw.text((inner_x, bar_y), "JellyBuddy", fill=(0x6C, 0x63, 0xFF), font=bar_font)

    # Content area placeholder bars
    content_y = bar_y + 80
    for i in range(5):
        bar_width = inner_w - (i % 3) * 80
        draw.rounded_rectangle(
            [inner_x, content_y, inner_x + bar_width, content_y + 24],
            radius=12,
            fill=(220, 220, 230),
        )
        content_y += 50

    # Card placeholder
    card_y = content_y + 30
    draw.rounded_rectangle(
        [inner_x, card_y, inner_x + inner_w, card_y + 200],
        radius=20,
        fill=(230, 230, 240),
    )

    # Emoji at the top of the image (above the phone frame)
    emoji_font = get_font(120)
    emoji_text = data["emoji"]
    try:
        bbox = draw.textbbox((0, 0), emoji_text, font=emoji_font)
        emoji_w = bbox[2] - bbox[0]
    except Exception:
        emoji_w = 120
    emoji_x = (WIDTH - emoji_w) // 2
    emoji_y = 120
    draw.text((emoji_x, emoji_y), emoji_text, fill="white", font=emoji_font)

    # Headline text (below the phone frame)
    headline_font = get_font(48)
    headline_text = data["headline"]
    try:
        bbox = draw.textbbox((0, 0), headline_text, font=headline_font)
        hl_w = bbox[2] - bbox[0]
    except Exception:
        hl_w = len(headline_text) * 48
    hl_x = (WIDTH - hl_w) // 2
    hl_y = HEIGHT - frame_margin_bottom + 80
    draw.text((hl_x, hl_y), headline_text, fill="white", font=headline_font)

    # Subtitle text
    subtitle_font = get_font(28)
    subtitle_text = data["subtitle"]
    try:
        bbox = draw.textbbox((0, 0), subtitle_text, font=subtitle_font)
        st_w = bbox[2] - bbox[0]
    except Exception:
        st_w = len(subtitle_text) * 28
    st_x = (WIDTH - st_w) // 2
    st_y = hl_y + 80
    # 70% opacity white => draw with a lighter color on the gradient
    draw.text((st_x, st_y), subtitle_text, fill=(255, 255, 255, 180), font=subtitle_font)

    return img


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    for i, data in enumerate(SCREENSHOTS):
        img = create_screenshot(data, i)
        output_path = os.path.join(OUTPUT_DIR, data["filename"])
        img.save(output_path, "PNG")
        print(f"Screenshot saved: {output_path}")

    print(f"\nAll {len(SCREENSHOTS)} screenshots saved to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
