#!/bin/zsh
# Build Bro.app and install it to /Applications.
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

APP=".build/bundle/Bro.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Bro "$APP/Contents/MacOS/Bro"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Bro</string>
    <key>CFBundleIdentifier</key>
    <string>com.brandonhull.bro</string>
    <key>CFBundleName</key>
    <string>Bro</string>
    <key>CFBundleDisplayName</key>
    <string>Bro</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"

if [[ "${1:-}" == "--install" ]]; then
    osascript -e 'tell application "Bro" to quit' 2>/dev/null || true
    sleep 0.5
    rm -rf "/Applications/Bro.app"
    cp -R "$APP" "/Applications/Bro.app"
    echo "Installed to /Applications/Bro.app"
    open "/Applications/Bro.app"
else
    echo "Built $APP (use ./build.sh --install to install and launch)"
fi
