#!/bin/zsh -f
set -eu
konmagic_source="${0:A:h:h}"
konmagic_build="$HOME/Library/Caches/KonMagic Build"
konmagic_app="$HOME/Applications/KonMagic.app"
konmagic_stage="$HOME/Applications/.KonMagic-build-$$.app"
if [[ ! -x "$konmagic_build/KonMagic" || ! -f "$konmagic_build/source.sha256" ]] || ! /usr/bin/shasum -a 256 -c "$konmagic_build/source.sha256" >/dev/null 2>&1; then
  /bin/zsh -f "$konmagic_source/scripts/build.command"
fi
"$konmagic_build/KonMagic" --self-test
if [[ ! -f "$konmagic_build/KonMagic.icns" ]]; then
  /bin/zsh -f "$konmagic_source/scripts/icon.command"
fi
mkdir -p "$konmagic_stage/Contents/MacOS" "$konmagic_stage/Contents/Resources"
cp "$konmagic_build/KonMagic" "$konmagic_stage/Contents/MacOS/KonMagic"
cp "$konmagic_source/scripts/Info.plist" "$konmagic_stage/Contents/Info.plist"
mkdir -p "$konmagic_stage/Contents/Resources/Artwork"
cp "$konmagic_build/Resources/Artwork/"*.png "$konmagic_stage/Contents/Resources/Artwork/"
if [[ -f "$konmagic_build/KonMagic.icns" ]]; then
  cp "$konmagic_build/KonMagic.icns" "$konmagic_stage/Contents/Resources/KonMagic.icns"
fi
/usr/bin/codesign --force --sign - --options runtime "$konmagic_stage"
/usr/bin/codesign --verify --strict "$konmagic_stage"
if [[ -e "$konmagic_app" ]]; then
  konmagic_previous="$HOME/Applications/KonMagic-previous-$(/bin/date -u +%Y%m%dT%H%M%SZ).app"
  mv "$konmagic_app" "$konmagic_previous"
  print "Previous local app retained: $konmagic_previous"
fi
mv "$konmagic_stage" "$konmagic_app"
if [[ ! -e "$HOME/Desktop/KonMagic.app" && ! -L "$HOME/Desktop/KonMagic.app" ]]; then
  ln -s "$konmagic_app" "$HOME/Desktop/KonMagic.app"
fi
print "Installed locally signed native app: $konmagic_app"
print 'Desktop shortcut available. User source files were not changed.'
