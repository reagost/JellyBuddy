# JellyBuddy App Icon Specification

---

## Icon Concept

A friendly jelly/slime character with coding elements -- combining approachability with a programming learning identity.

### Primary Design

- **Character**: A rounded, friendly jelly/slime creature (soft blob shape) with a cheerful face (simple dot eyes and a small smile)
- **Coding Element**: Code brackets `< >` or `{ }` subtly integrated into the character design -- either as a pattern on the body, as "arms", or floating around the character
- **Academic Touch**: A small graduation cap tilted playfully on top of the jelly character
- **Expression**: Friendly, approachable, and encouraging -- the character should feel like a supportive study buddy

### Color Palette

- **Primary**: Purple gradient (#6C63FF to #5A52D5)
- **Accent**: Light purple/lavender (#A29BFE) for highlights and glow effects
- **Background**: Solid or subtle gradient background using lighter purple tones (#EDE9FF to #F5F3FF) or pure white
- **Character**: The jelly character itself uses the primary purple gradient with translucent/glossy highlights
- **Details**: White (#FFFFFF) for the face, graduation cap tassel, and code brackets

### Style Guidelines

- Flat or semi-flat design with subtle gradients (no heavy 3D effects)
- Rounded corners as per platform requirements
- Clear silhouette that is recognizable at small sizes (16x16)
- No text in the icon
- The character should be centered with adequate padding from edges
- Glossy/translucent quality to convey the "jelly" nature

---

## Required Sizes

### iOS (App Store & Devices)

| Size | Usage | Format |
|------|-------|--------|
| 1024x1024 | App Store listing | PNG (no alpha) |
| 180x180 | iPhone (@3x) | PNG |
| 120x120 | iPhone (@2x) | PNG |
| 167x167 | iPad Pro (@2x) | PNG |
| 152x152 | iPad (@2x) | PNG |
| 76x76 | iPad (@1x) | PNG |
| 80x80 | Spotlight (@2x) | PNG |
| 120x120 | Spotlight (@3x) | PNG |
| 58x58 | Settings (@2x) | PNG |
| 87x87 | Settings (@3x) | PNG |
| 40x40 | Spotlight (@1x) | PNG |
| 60x60 | iPhone (@1x, CarPlay) | PNG |

**Note**: The App Store icon (1024x1024) must not have an alpha channel or transparency.

### Android (Google Play & Devices)

| Size | Usage | Format |
|------|-------|--------|
| 512x512 | Google Play Store listing | PNG |
| 192x192 | xxxhdpi | PNG |
| 144x144 | xxhdpi | PNG |
| 96x96 | xhdpi | PNG |
| 72x72 | hdpi | PNG |
| 48x48 | mdpi | PNG |

**Adaptive Icon (Android 8.0+)**:

| Layer | Size | Description |
|-------|------|-------------|
| Foreground | 108x108 dp (432x432 px @xxxhdpi) | The jelly character with code elements and graduation cap |
| Background | 108x108 dp (432x432 px @xxxhdpi) | Solid purple (#6C63FF) or subtle purple gradient |

- The foreground character should fit within the safe zone (72x72 dp center area)
- Both layers must be 108x108 dp to allow for various mask shapes (circle, squircle, rounded square, etc.)

### macOS

| Size | Usage | Format |
|------|-------|--------|
| 1024x1024 | App Store | PNG |
| 512x512 | Finder (@2x) | PNG |
| 256x256 | Finder (@1x) | PNG |
| 128x128 | Dock, Finder | PNG |
| 64x64 | Dock, Finder | PNG |
| 32x32 | Finder list | PNG |
| 16x16 | Finder, menu | PNG |

**Note**: macOS icons should include the rounded rectangle shape within the image (not applied by the system).

---

## File Delivery

### iOS

Place the icon in the Xcode asset catalog:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

Include an updated `Contents.json` referencing all required sizes.

### Android

Place icons in the appropriate resource directories:
```
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

Adaptive icon resources:
```
android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
android/app/src/main/res/drawable/ic_launcher_foreground.xml (or PNG)
android/app/src/main/res/values/ic_launcher_background.xml
```

### macOS

Place the icon in the Xcode asset catalog:
```
macos/Runner/Assets.xcassets/AppIcon.appiconset/
```

---

## Design Variations

Provide the following variations for potential future use:

1. **Standard Icon**: Full jelly character with graduation cap and code brackets
2. **Notification Icon** (Android): Simplified silhouette version in white (for status bar)
3. **Monochrome** (Android 13+): Single-color adaptation following dynamic theming

---

## Notes for Designer

- Test the icon at all sizes to ensure readability, especially at 16x16 and 32x32
- The jelly character's face should remain recognizable even at the smallest sizes
- Avoid fine details that disappear at small sizes
- Ensure sufficient contrast between the character and background
- The graduation cap should be simple enough to read at small sizes -- consider removing it for sizes below 48x48
- Provide source files in vector format (SVG or AI) for future modifications
