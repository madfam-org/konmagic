# GrandPerspective capability contract

KonMagic implements disk analysis independently. It does not contain
GrandPerspective source code, palettes, icons or other assets. KonMagic remains
MIT licensed. GrandPerspective is a separate project with its own licence.

This checklist uses the [official feature list](https://grandperspectiv.sourceforge.net/)
and official help. It is a coverage contract, not a claim that two applications
have identical interfaces, file formats, performance or protection policies.
Unverified or intentionally limited behavior stays visible below.

| Capability | KonMagic surface | Behavior and limits |
| --- | --- | --- |
| Hierarchical disk-size rectangles | Disk Lens | Files remain grouped by their physical parent folders. File areas use recorded weights. Tiny branches collapse and can be zoomed; zero-weight entries have zero area and stay in the list/export. |
| Logical, physical and tally measures | Measure menu | Logical bytes, allocated `st_blocks × 512` bytes, unique-file tally. Inodes are counted once; APFS shared blocks and retained snapshots are not an estimate of reclaimable space. |
| Files, package/file and package/folder views | Display menu | Expand packages, collapse recognized packages, or group direct files by folder. Package recognition uses a documented common-extension list rather than every third-party package declaration. |
| Name, extension, type, parent, top folder, depth, size and three dates | Color menu | Twelve schemes, including protection. Original Atlas observations lack creation/access dates; these are Unknown until a live metadata scan. Type filters support system UTI conformance. |
| Palettes and type categories | Palette / File-type colors | Six independent palettes; user extension-to-category overrides persist privately. No GrandPerspective assets are reused. |
| Display depth and entire-volume context | Depth / Show volume context | Adaptive detail with full retained data. Volume context requires a live volume-capacity observation. Shared/unknown/other accounting is labelled. |
| Hover, lock, focus and zoom | Canvas / toolbar | Hover inspects, click locks/unlocks, double-click zooms. Parent and focus controls navigate independently. |
| Keyboard and scroll navigation | Canvas | Spatial arrow selection, Return zoom, Space preview, Command +/- zoom, Command [/] and scroll change focus, Escape unlocks. Native source list provides equivalent access. |
| Default-app opening, Finder reveal, Quick Look | Inspector actions | Opening/previewing requires current regular-source identity, dates and size to match. Symlinks, cloud placeholders and protected collections are held. These actions are explicit; scanning never opens source bodies. |
| Delete / folder Trash action | Review cleanup in Finder | **Intentional protection difference:** KonMagic does not move or delete source data. It shows the exact source and hands review to Finder. This repository's source-preservation contract takes precedence over destructive parity. Filtering cannot conceal this difference. |
| Name search | Disk Lens source list / Atlas Explorer | Search recorded names across a scan. Tagged Explorer additionally searches paths, tags and retained indexed content. Disk Lens lists use 200-row pages; full rows remain in saved scans and text export. |
| Compound metadata tests | Filter editor | ALL, ANY, or include-any-positive/exclude-all-negated logic; name/path/extension/UTI/kind/size/dates/link/package/cloud tests. Flat logic plus OR-of-AND compound groups, inverted groups and folder-ancestor exclusions. Up to eight groups and 64 subtests. |
| Mask versus filter | Mask / Filter view | Masks leave hidden areas in place. Filtering creates a separate retained observation and recomputes totals; the source snapshot stays intact. |
| Scan exclusions and defaults | Scan filters | Inclusion applies to files; exclusion matches can prune directory subtrees. Private named filters support reuse, editing and removal. Scan filters are explicit in snapshot metadata. |
| Full scans, scoped scans and current-session refresh | Scan folder / Rescan / Refresh | Metadata only, no source-body reads or symlink following. FSEvents tracks changed folders. Unchanged subtrees reuse cached metadata. Dropped history or loaded scans cause a full rescan. |
| Duplicate and synchronized views | Duplicate / Twin | Independent display choices over the same immutable scan; twins synchronize hierarchy navigation. Refresh retains the prior database even when the current window changes observation. |
| Hard links and backup inspection | Scanner / protection inspector | Unique regular-file device/inode pairs avoid duplicate accounting. Repeated directory identities are held. Already-mounted, accessible backup folders can be scanned; KonMagic neither mounts nor deletes Time Machine snapshots. APFS shared blocks remain unresolved. |
| Remote/cloud metadata | Scanner / cloud filter | Logical and allocated sizes can be inspected without hydration. Dataless directories remain explicit coverage exceptions. |
| Save, load and annotations | Save scan / Load scan / Scan notes | Complete private SQLite observations, independent of current focus or mask. Notes create a separate saved snapshot. This is KonMagic's own format; GrandPerspective gzip/XML interoperability is **not implemented**. |
| Image and property-selected text export | PNG / TIFF / Text | Export the current map or all retained rows as escaped TSV. Property selection, exclusive output creation and private permissions; no silent overwrite. |
| Compare before/after observations | Compare | Added/changed/removed metadata for matching roots. First 500 changes in the window; complete scans can be exported. Scan exceptions and exclusions remain relevant; metadata cannot prove byte equality. |
| Preferences | KonMagic Preferences / display menus / scan filters / saved filters | Persist display, size units, filters, type categories and recent scans privately. Configure last-window welcome/quit/stay behavior and prior-view retention. Destructive deletion settings stay unavailable. |
| Background work and footprint | Native AppKit / bounded SQLite | Metadata scans, queries, aggregation, layout and exports run off the UI thread. No Electron, server, listener or downloaded package runtime. Scan storage stops at 3 GiB or 10 GiB free. Partial coverage remains explicitly partial. Brief drawing crossfades respect Reduce Motion. |
| Internationalization | Native macOS panels | System panels follow macOS language. App-authored text currently uses English; GrandPerspective's full translation set is **not implemented**. |

Sources: [sizes](https://grandperspectiv.sourceforge.net/HelpDocumentation/FileSizes.html),
[display](https://grandperspectiv.sourceforge.net/HelpDocumentation/ViewDisplayPanel.html),
[navigation](https://grandperspectiv.sourceforge.net/HelpDocumentation/NavigatingViews.html),
[filters](https://grandperspectiv.sourceforge.net/HelpDocumentation/MasksAndFilters.html),
[test editing](https://grandperspectiv.sourceforge.net/HelpDocumentation/EditingFilterTests.html),
[refresh](https://grandperspectiv.sourceforge.net/HelpDocumentation/RefreshAndRescan.html),
[saving/export](https://grandperspectiv.sourceforge.net/HelpDocumentation/SavingViewContents.html),
[backup accounting](https://grandperspectiv.sourceforge.net/HelpDocumentation/HowToAnalyseTimeMachineBackups.html).

## Release gates

- Synthetic tests conserve file weights through hierarchy, packages, masks and
  filtered views, including sparse files and repeated hard links.
- Read-only snapshot connections refuse mutations. Atlas databases and source
  bodies are never modified by disk analysis.
- Scan cancellation retains a partial observation; storage/depth/access gaps
  cannot be reported as complete coverage.
- Before opening, previewing or verified copying, a saved observation must be
  reconciled with the real source. No hidden automatic cleanup is allowed.
- Local catalogue counts, user paths, screenshots and receipts never enter Git.

Remaining compatibility gaps above are separate work items. They must not be
described as completed or as grounds to uninstall GrandPerspective yet.
