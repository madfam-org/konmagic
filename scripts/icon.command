#!/bin/zsh -f
set -eu
konmagic_source="${0:A:h:h}"
konmagic_build="$HOME/Library/Caches/KonMagic Build"
mkdir -p "$konmagic_build/KonMagic.iconset"
/usr/bin/xcrun swiftc "$konmagic_source/scripts/Icon.swift" -o "$konmagic_build/draw-icon"
"$konmagic_build/draw-icon" "$konmagic_build/master.png"
for konmagic_size in 16 32 128 256 512; do
  /usr/bin/sips -z "$konmagic_size" "$konmagic_size" "$konmagic_build/master.png" --out "$konmagic_build/KonMagic.iconset/icon_${konmagic_size}x${konmagic_size}.png" >/dev/null
  konmagic_double=$(( konmagic_size * 2 ))
  /usr/bin/sips -z "$konmagic_double" "$konmagic_double" "$konmagic_build/master.png" --out "$konmagic_build/KonMagic.iconset/icon_${konmagic_size}x${konmagic_size}@2x.png" >/dev/null
done
/usr/bin/iconutil -c icns "$konmagic_build/KonMagic.iconset" -o "$konmagic_build/KonMagic.icns"
print 'Built original KonMagic app icon.'
