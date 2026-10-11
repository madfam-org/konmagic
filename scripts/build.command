#!/bin/zsh -f
set -eu
konmagic_source="${0:A:h:h}"
konmagic_build="$HOME/Library/Caches/KonMagic Build"
mkdir -p "$konmagic_build/module-cache"
chmod 700 "$konmagic_build"
/usr/bin/shasum -a 256 "$konmagic_source"/Sources/*.swift "$konmagic_source/scripts/Info.plist" "$konmagic_source"/Resources/Artwork/*.png > "$konmagic_build/source-before.sha256"
/usr/bin/xcrun swiftc -O -whole-module-optimization -swift-version 5 \
  -module-cache-path "$konmagic_build/module-cache" \
  -target "$(/usr/bin/uname -m)-apple-macosx13.0" \
  "$konmagic_source"/Sources/*.swift \
  -framework AppKit -framework CryptoKit -framework CoreServices -framework Quartz -framework QuickLookThumbnailing -lsqlite3 -lz -o "$konmagic_build/KonMagic"
/usr/bin/shasum -a 256 "$konmagic_source"/Sources/*.swift "$konmagic_source/scripts/Info.plist" "$konmagic_source"/Resources/Artwork/*.png > "$konmagic_build/source.sha256"
if ! /usr/bin/cmp -s "$konmagic_build/source-before.sha256" "$konmagic_build/source.sha256"; then
  /bin/rm "$konmagic_build/source.sha256"
  print -u2 'Source changed during compilation. Rebuild the final source before installation.'
  exit 1
fi
mkdir -p "$konmagic_build/Resources/Artwork"
cp "$konmagic_source"/Resources/Artwork/*.png "$konmagic_build/Resources/Artwork/"
print "Built native binary: $konmagic_build/KonMagic"
