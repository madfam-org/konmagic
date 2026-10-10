# KonMagic

A native macOS utility for organizing files with a structure you control.
Create destinations, drag individual **drops** or whole **buckets** onto them,
inspect exact paths, and apply a verified copy while keeping originals intact.

KonMagic is an independent MADFAM open-source project. The name pays an informal
tribute to Marie Kondo. It has no affiliation with Marie Kondo or KonMari.

## Build and run

Requires macOS 13 or later and Apple Command Line Tools with Swift 5.8 or later.
Uses AppKit, Foundation, CryptoKit, Darwin and the system SQLite library; no
package downloads, browser, Python service, Electron or network listener.

```sh
/bin/zsh -f scripts/build.command
"$HOME/Library/Caches/KonMagic Build/KonMagic" --self-test
/bin/zsh -f scripts/install.command
open "$HOME/Applications/KonMagic.app"
```

The installer creates a locally ad-hoc signed app in `~/Applications` and a
Desktop shortcut. It does not install privileged helpers or login items.
Ad-hoc signing is for local development; this is not a Developer ID notarized
distribution. Public binary distribution needs a separately maintained Apple
Developer signing and notarization process.

Stable AppKit APIs support current macOS while keeping older compatible Macs
usable. Building with an older SDK does not adopt SDK-specific macOS 26 Liquid
Glass controls. Use a current Xcode toolchain when extending the app with those
APIs. [Apple's macOS 26 release notes](https://developer.apple.com/go/?id=macos-26-rn)
describe SDK and runtime compatibility.

## Your workflow

1. **Shape the tree.** New, Rename, Remove and destination drag/reparent edit a
   virtual structure. Numbered Inbox, Projects, Areas, Resources, Archive and
   Review sections are a starting template, not a classification rule.
2. **Choose sources.** Native folder browsing and current-folder name search
   read metadata in bounded pages, without requiring an existing catalogue.
   Hidden entries can be included through File. Drag directly from Finder, or select items in the
   library. Whole folders preserve their internal hierarchy, including empty
   folders and saved-webpage companions.
3. **Assign deliberately.** Drop onto the destination you know is right. Manual
   assignments control placement; inferred metadata cannot override them.
   Renaming a destination updates its draft assignments by stable identity.
   Undo draft edits without altering original files.
4. **Review exact paths.** The draft shows every source and chosen target before
   verification. Choose a local output folder and generate a complete-hash
   preview. Export its manifest if helpful.
5. **Apply a copy.** A separate confirmation rechecks the entire batch. Files
   are copied with macOS metadata, SHA-256 verified and published exclusively.
   Originals stay intact. A durable receipt records completed targets and
   retained stages if interrupted. Batches are not global transactions.

An optional compatible Workstation Atlas catalogue can provide retained
filename/path observations through the **All catalogue** source. It is opened read-only; its extracted bodies are
not read, reindexed or duplicated. Choose its folder through **File → Connect
catalogue** if access is needed. Native live-folder browsing works without a
catalogue. Connected catalogue access is retained in private workspace settings.
Queries and hashing run away from the main UI thread.

## Preservation boundaries

- No move, delete, automatic deduplication or privileged filesystem action.
- No overwrites, symlink following, cloud placeholder hydration or cloud output.
- Credentials, app/library packages, recognized source projects and operational
  collections remain held. Ordinary buckets are copied as coherent units.
- Overlapping source buckets and nested target collisions are refused.
- Up to 100 assignments, 5,000 entries and 100 GiB per batch. Capacity is checked
  using metadata before expensive hashing; the output must retain 10 GiB free.
  A large video collection can therefore require an external output drive.
- Empty staging directories and failed staged bytes remain for inspection.
  Receipts provide explicit recovery paths. There is no automatic deletion or
  speculative crash rollback.
- File and directory metadata use `fcopyfile`; byte hashes independently verify
  file data. This is not forensic proof of every extended metadata property.
- Filesystem access follows the macOS account and privacy permissions. Native
  panels and bookmarks retain selected folder access; the app grants no TCC
  permissions and does not bypass macOS protections. It is a local nonsandboxed
  development utility, not an App Store sandboxed application.

Workspace settings and receipts live privately in
`~/Library/Application Support/KonMagic`, outside this repository. Personal
catalogues, document bodies, names, source paths, snapshots, build caches and
screenshots must never enter Git.

## Verification

`--self-test` uses temporary synthetic files to exercise structure validation,
manual assignment, draft undo, folder cohesion, source identity changes,
capacity checks before body reads, symlink and credential refusals, Unicode/case
collisions, complete hashes, empty folders, directory attributes, exclusive
copies, retained originals and durable receipts. No user file is reorganized.

`--catalog-smoke` optionally measures bounded read-only queries against a local
compatible catalogue. `--ui-smoke` renders the app's own window with isolated QA
state; image and state paths are specified through `KONMAGIC_QA_IMAGE` and
`KONMAGIC_QA_STATE`. Set `KONMAGIC_QA_APPEARANCE=dark` for a dark-mode check.
Never publish those local outputs.

Licensed under [MIT](LICENSE).
