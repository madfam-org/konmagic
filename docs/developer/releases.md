# Builds, installation and release claims

The app version is `CFBundleShortVersionString`; the build is `CFBundleVersion` in `scripts/Info.plist`. The current interface release is **0.5.2 / build 11**. The deployment target is macOS 13. Source compatibility is Swift 5.8+ with Swift 5 language mode in the build script.

## Local build lifecycle

`build.command` records source/Info.plist hashes before and after optimized whole-module compilation. A changed fingerprint invalidates freshness. The binary, module cache and icon remain outside the repository in Library/Caches.

`install.command` verifies freshness and synthetic tests, creates a staged bundle, copies Info.plist/code/icon, ad-hoc signs with hardened runtime, verifies the signature, retains the old local bundle and publishes the new one under the user’s Applications directory. It creates a Desktop symlink if absent. It never migrates or clears the private catalogue/draft as part of installation.

An unsigned cached binary and an ad-hoc signed installed Mach-O have different hashes because signing modifies the binary. Compare the appropriate fingerprint and signature rather than asserting they must be byte-identical.

## Distribution boundary

The current installer provides a local build. No Developer ID notarized universal distribution is established. Do not advertise Gatekeeper-trusted downloads, a universal binary, automatic updates or notarization until those artifacts actually exist and are verified.

A future release needs Apple Silicon/Intel architecture strategy, current SDK testing, entitlements, Developer ID signing, notarization, stapling and Gatekeeper verification; updater signing/rollback and privacy-preserving diagnostics need separate design. Preserve user state through upgrades and plan explicit versioned migrations before changing stored schemas.

## Release checklist

- Confirm source and Info.plist are final before optimized build.
- Run native safety checks and relevant synthetic GUI journeys in both appearances.
- Inspect public screenshot provenance and documentation links.
- Confirm shared WorkspaceStore/KnowledgeStore compatibility and unchanged originals.
- Verify strict bundle signature and Desktop shortcut.
- Commit public code/docs only; push and verify native CI and Pages deployment.
- Report the actual signing/distribution status and remaining limits.

GitHub Pages publication is separate from native code installation. A successful docs workflow does not prove a Mac binary was tested or notarized.
