#!/bin/bash
# macOS-only regression test of the real player sleep assertion, sandboxed like
# the app. Uses only Xcode and macOS tools; never opens a stream or changes settings.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/lume-display-sleep.XXXXXX")"
trap 'rm -rf "$work"' EXIT
app="$work/PlayerDisplaySleepTests.app"
mkdir -p "$app/Contents/MacOS"
xcrun swiftc -swift-version 6 -default-isolation MainActor -parse-as-library \
    "$root/Lume/Views/Player/PlayerDisplaySleep.swift" \
    "$root/Scripts/Tests/PlayerDisplaySleepTests.swift" \
    -o "$app/Contents/MacOS/PlayerDisplaySleepTests"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>org.lume.PlayerDisplaySleepTests</string>
<key>CFBundleExecutable</key><string>PlayerDisplaySleepTests</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
</dict></plist>
PLIST
cat > "$work/test.entitlements" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>com.apple.security.app-sandbox</key><true/>
</dict></plist>
PLIST
/usr/bin/codesign --force --sign - --timestamp=none \
    --entitlements "$work/test.entitlements" "$app"
"$app/Contents/MacOS/PlayerDisplaySleepTests"
