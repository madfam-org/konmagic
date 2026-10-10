# KonMagic

A native macOS utility for organizing files with a structure you control.
Create destinations, drag individual **drops** or whole **buckets** onto them,
inspect exact paths, and apply a verified copy while keeping originals intact.

KonMagic is an independent MADFAM open-source project. The name pays an informal
tribute to Marie Kondo. It has no affiliation with Marie Kondo or KonMari.

## Build and run

Requires macOS 13 or later and Apple Command Line Tools with Swift 5.8 or later.
Uses AppKit, Foundation, CryptoKit, CoreServices, Quartz, Darwin and system SQLite/zlib; no
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

## Atlas Explorer

**Atlas Explorer** connects the complete tagged catalogue and its optional
whole-disk metadata ledger without modifying either database. Choose their
folder through **File → Connect catalogue** if access is needed. When a retained
catalogue is available, the explorer opens alongside the destination workspace.
Native live-folder browsing remains available without any catalogue.

- **List:** all tagged observations, including protected metadata, with bounded
  keyset pages. Intersect owner, project, family, purpose, lifecycle, reading
  status, protection, file kind, extension, modification year, size, confidence
  and reading method. Search names/paths/tags or the existing full-text index.
- **Folder tree:** load actual recorded roots and children lazily. Whole-disk
  browsing decodes bounded compressed metadata blocks and retained volume
  aliases; it does not rescan or follow source symlinks. Tree navigation displays
  physical hierarchy; semantic filters apply to lists and maps.
- **Tag tree:** owner → project → family. Double-click a virtual group to list
  its real sources. Virtual groups are filters, not physical source buckets.
- **Treemap:** partition complete matching aggregates by a chosen dimension,
  weighted by entries or logical regular-file bytes. Small categories roll into
  an explicitly labelled Other tile and remain in the complete facet list.
  Zero-byte groups have a minimum hit area. Disk maps use recorded boundary
  counts; no global byte total is invented for the compressed disk ledger.
- **Connections:** owner → project, or project → family when Project is selected.
  Edges count real matching observations. Show the top 12 groups per axis; the
  complete categories remain available in the facet list.

The inspector carries Atlas tags, confidence, manual-review status, evidence,
broad visual labels, reading exceptions and dates. A fresh metadata check shows
whether a source is unavailable or differs in size/time; full byte verification
still belongs to the separate copy preview. Modified year is UTC filesystem
metadata, not an inferred event date. Inferred visual labels can overlap.

Content search reuses canonical indexed readings and their validated shared
aliases. **Show retained content excerpt** reads only an eligible cached body,
validates a shared canonical hash/extension, bounds decompression to 640,000
bytes and displays at most 20,000 characters. It does not open the original file.
Protected bodies remain inaccessible. Partial readings remain labelled partial.

Select real files or folders from the explorer, choose a destination and assign
them to the same organizational draft. Its exact source/destination preview
appears immediately. Editing the destination tree updates assignments by stable
identity. Browse, filter, map and assign actions never apply filesystem changes.

Aggregates are cached privately and invalidated by catalogue/WAL identity.
Counts reconcile to each catalogue separately; disk metadata overlaps tagged
observations and their counts must not be added. Logical bytes include duplicate
files and represent neither allocated storage nor reclaimable space. These are
retained, point-in-time observations of a changing machine, with explicit access
exceptions and reading limits. Query cancellation discards superseded searches;
aggregation, queries, decoding and hashing run away from the main UI thread.

Connected catalogue access, aggregate caches, workspace settings and receipts
stay in private application support, outside Git. No index is rebuilt, no full
text is duplicated, and no service or network listener is needed.

## Disk Lens

Open **File → Disk Lens** (Command-D) for independent native disk analysis.
**Atlas recorded folder** builds a derived snapshot from retained whole-disk
metadata. **Scan folder** reads current filesystem metadata without opening file
bodies, following symlinks, or downloading placeholders. A scan is an observation
of a changing filesystem, with explicit coverage exceptions.

The hierarchy-preserving map offers logical, allocated or unique-file tally
weights; file/package/folder display modes; twelve color schemes; six palettes;
custom file-type categories; depth control; volume context; mouse, keyboard and
scroll navigation. Small branches collapse adaptively and can be zoomed. True
zero-weight entries have no area and remain in lists and complete exports.
Device/inode identity avoids hard-link double counting. APFS shared blocks,
clones, snapshots and directory overhead prevent a reclaimable-space estimate.

Masks hide drawings while retaining area. Compound metadata filters support
ALL, ANY, include-any/exclude-all logic and compound groups with folder-ancestor exclusions. Filtered views are separate retained
snapshots. Scan inclusion tests files; exclusions can skip entire directory
subtrees. Named filters, size units, appearance choices, type colors and recent
scans persist privately. Saved scans do not imply current source identity.

Save/load complete scans, attach notes, compare matching roots, export current
maps as PNG/TIFF, or export every retained row with selected TSV properties.
Duplicate views vary display independently; twins synchronize folder navigation.
Current-session FSEvents permits incremental refresh of changed folders, with
full rescans after event gaps or for loaded observations. Preferences control
last-window behavior and retention of prior-view windows.

The inspector joins an exact source path back to retained Atlas tags and evidence.
Assign the selected real file/folder to an explicit draft destination and inspect
the same exact preview used by the workspace. Opening or Quick Look is explicit
and checks current identity; protected/cloud/linked sources are held. Cleanup
review reveals the exact source in Finder and never trashes data automatically.

Derived scans live privately under application support. Work streams through
SQLite and background queues, with a 3 GiB per-scan limit, 25 million-entry bound,
256-level depth limit and 10 GiB free-space reserve. Stop retains explicit partial
coverage. The visible list uses 200-row pages; complete data remains in the
scan and export. A comparison window shows the first 500 changes, with limitations
stated. Global tagged facets and full-text search remain in Atlas Explorer.

See the [GrandPerspective capability contract](docs/GrandPerspective-capabilities.md)
for the complete comparison and remaining compatibility gaps. This is an
independent implementation; no GrandPerspective GPL code or assets are embedded.

The [macOS alternatives survey](docs/macOS-alternatives.md) compares the related
catalogue, search, organization, duplicate and file-management workflows, with
explicit remaining gaps and a focused development sequence.

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
compatible catalogue. `--explorer-smoke` verifies full aggregate conservation,
tag decoding and native compressed disk browsing. `--ui-smoke` renders the
workspace; `--explorer-ui-smoke` renders the app's own explorer with isolated QA
state; image and state paths are specified through `KONMAGIC_QA_IMAGE` and
`KONMAGIC_QA_STATE`. Set `KONMAGIC_QA_APPEARANCE=dark` for a dark-mode check.
Choose an explorer view with `KONMAGIC_QA_VIEW` (`list`, `foldertree`, `tagtree`,
`treemap`, `connections` or `disk`). Never publish those local outputs.

`--lens-recorded-smoke` imports a bounded recorded folder into private QA state.
`--lens-ui-smoke` renders an isolated saved scan selected with `KONMAGIC_QA_SCAN`.
Synthetic Disk Lens checks cover sparse allocation, hard links, symlink holds,
package maps, proportional/zero-area layout, masks, filter conservation,
scan exclusions, save/reload, export refusal, comparisons and refresh.

Synthetic catalogue checks cover read-only connections, complete keyset pages,
count conservation, literal FTS terms, shared canonical content resolution,
protected-body refusals, compression bounds, cancellation and byte-identical
disk metadata browsing. Synthetic fixtures never become an actual source plan.

Licensed under [MIT](LICENSE).
