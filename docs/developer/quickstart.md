# Build a native development environment

## Requirements

macOS 13 or later, Swift 5.8 or later through Xcode Command Line Tools, and Apple frameworks available through the SDK. The native app has no package-manager dependencies, runtime web backend or account service. It links AppKit, Foundation, CryptoKit, CoreServices, Quartz, QuickLookThumbnailing, Darwin, SQLite and zlib.

```sh
git clone https://github.com/madfam-org/konmagic.git
cd konmagic
/bin/zsh -f scripts/build.command
"$HOME/Library/Caches/KonMagic Build/KonMagic" --self-test
```

The build uses optimized whole-module compilation, Swift 5 language mode and the current machine architecture with a macOS 13 deployment target. The source fingerprint includes `Sources/*.swift` and `scripts/Info.plist`. Do not change those files while building: a before/after mismatch rejects installation freshness.

## Install the local bundle

```sh
/bin/zsh -f scripts/install.command
open "$HOME/Applications/KonMagic.app"
```

The installer checks the fingerprint, runs synthetic safety tests, packages code/icon/Info.plist, ad-hoc signs with hardened runtime, verifies the signature and retains any previous local bundle under a timestamped name. The Desktop link points at the installed app. The local ad-hoc signature is not Developer ID signing or notarization.

Do not replace a running app’s state or force-quit an active job. Private state lives under Application Support. Replacing code is separate from migrating user decisions.

## Iterate with isolated data

Use the synthetic documentation fixture for public-safe GUI work:

```sh
python3 scripts/docs/create-fixture.py
# Save the printed State path; it is a NEW private temporary fixture.
KONMAGIC_QA_STATE="<printed State path>" \
  "$HOME/Library/Caches/KonMagic Build/KonMagic" --documentation-capture
```

The capture flag rejects an ordinary workspace, requires the fixture marker, checks its catalogue/output roots and uses only invented content. Outputs stay under the fixture until deliberately reviewed and promoted. It never approves copying.

For a debug binary, adapt the build’s `swiftc` invocation to `-Onone` and a private output path. Do not check binaries, scan databases or normal GUI outputs into Git. See [testing](testing.md).

## Build this documentation

The docs toolchain is separate from the native runtime:

```sh
python3 -m venv .build/docs-venv
.build/docs-venv/bin/pip install -r scripts/docs/requirements.txt
.build/docs-venv/bin/python scripts/docs/generate-reference.py
.build/docs-venv/bin/mkdocs build --strict
.build/docs-venv/bin/python scripts/docs/check-site.py
.build/docs-venv/bin/mkdocs serve
```

Pinned docs dependencies are installed only into an isolated environment. GitHub Actions builds and publishes Pages from main. [Pipeline details](documentation.md).
