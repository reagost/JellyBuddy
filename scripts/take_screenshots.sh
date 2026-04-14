#!/bin/bash
# Take App Store screenshots using iOS Simulator
#
# Requires: Xcode with iOS Simulators installed
# Devices: iPhone 16 Pro Max (6.9"), iPhone 16 Pro (6.3"), iPad Pro 13"
#
# Usage: ./scripts/take_screenshots.sh

SCREENSHOTS_DIR="store/screenshots"
mkdir -p "$SCREENSHOTS_DIR"

# List of simulator device types
DEVICES=(
  "iPhone 16 Pro Max"
  "iPhone 16 Pro"
  "iPad Pro 13-inch (M4)"
)

for DEVICE in "${DEVICES[@]}"; do
  echo "Taking screenshots on: $DEVICE"

  # Boot simulator
  UDID=$(xcrun simctl list devices | grep "$DEVICE" | grep -o '[A-F0-9-]\{36\}' | head -1)
  if [ -z "$UDID" ]; then
    echo "  Device not found: $DEVICE, skipping"
    continue
  fi

  xcrun simctl boot "$UDID" 2>/dev/null

  # Install and launch app
  # flutter run -d $UDID would work but takes too long
  # Instead, just provide instructions

  SAFE_NAME=$(echo "$DEVICE" | tr ' ' '_')

  # Take screenshot
  xcrun simctl io "$UDID" screenshot "$SCREENSHOTS_DIR/${SAFE_NAME}_screenshot.png"

  echo "  Saved: ${SAFE_NAME}_screenshot.png"
done

echo ""
echo "Screenshots saved to: $SCREENSHOTS_DIR/"
echo ""
echo "Manual steps:"
echo "  1. Run 'flutter run -d <simulator>' to launch app"
echo "  2. Navigate to each screen manually"
echo "  3. Run this script to capture each screen"
echo "  4. Add text overlays using Figma/Canva per store/screenshots.md"
