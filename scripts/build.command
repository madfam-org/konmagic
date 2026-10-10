#!/bin/zsh -f
set -eu
konmagic_source="${0:A:h:h}"
konmagic_build="$HOME/Library/Caches/KonMagic Build"
mkdir -p "$konmagic_build/module-cache"
chmod 700 "$konmagic_build"
/usr/bin/xcrun swiftc -O -whole-module-optimization -swift-version 5 \
  -module-cache-path "$konmagic_build/module-cache" \
  -target "$(/usr/bin/uname -m)-apple-macosx13.0" \
  "$konmagic_source"/Sources/*.swift \
  -framework AppKit -framework CryptoKit -lsqlite3 -o "$konmagic_build/KonMagic"
/usr/bin/shasum -a 256 "$konmagic_source"/Sources/*.swift "$konmagic_source/scripts/Info.plist" > "$konmagic_build/source.sha256"
print "Built native binary: $konmagic_build/KonMagic"
