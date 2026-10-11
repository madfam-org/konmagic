# Native metadata scanning and retained trees

`LensScanner` traverses local metadata through no-follow directory descriptors or imports a compressed historical ledger. `LensWriter` streams nodes into a newly created owned private SQLite file; `LensStore` exposes bounded read APIs, snapshots and exports.

## Live traversal

The scanner opens the selected root with `SafeFS.openDirectory`. It enumerates direct entries, uses `fstatat(..., AT_SYMLINK_NOFOLLOW)`, classifies regular files/directories/links/other entries, and records sizes, allocation, dates, device/inode, link count, flags and package status. Child directory descriptors are checked against enumerated identities.

Links are recorded but never followed. Cloud directories are held rather than hydrated. Repeated directory identities prevent recursion and duplicate representation. A directory changing during enumeration becomes an explicit issue. The active private snapshot directory is excluded to avoid self-ingestion.

Inclusion filters test files while traversal can continue through parent directories. Exclusions can skip files or entire directory subtrees. Coverage and excluded counts are part of the observation.

## Writer and aggregation

Nodes are inserted parent-first. The writer uses explicit transactions, full synchronous SQLite mode, bounded cache and file-backed temporary storage. It periodically commits and checks cancellation/capacity. Device/inode deduplication suppresses repeated regular-file contribution without discarding the row.

A reverse ID fold accumulates child logical bytes, allocated bytes and tally into parents. This conserves totals without retaining millions of nodes in Swift arrays. Completion is not reported if the fold fails. Snapshot metadata stores root, source, status, filters/exclusions, times and limitations.

## Recorded import

Ledger import decodes directory blocks, resolves aliases and synthesizes missing structural ancestors when needed. It records whether dates and link counts are known. This is a derived historical observation, not a fresh whole-disk scan or body read. Original and derived exception counts can differ because they represent different traversal concepts.

## Event refresh

`LensWatcher` receives FSEvents during the current session. A compatible root/filter baseline plus intact event history can reuse unaffected cached subtrees and rescan changed folders. Event gaps and loaded historical observations require a full rescan. Do not claim a persisted event journal or permanent background monitoring.

## Map and exports

`DiskLensMap` computes bounded adaptive proportional layouts off the main thread. Very small branches become grouped virtual tiles; zero-weight entries remain list/export records. Package boundaries and display modes determine representation.

Map export recalculates the focused hierarchy and mask for current display pixels, 4K or 8K PNG/TIFF, with a 32-megapixel raw-surface bound. Layout and source queries run off the main thread; bounded native image drawing/encoding currently run on the main thread after an explicit export request. TSV export streams the complete retained rows with selected properties. Saved scans and notes create separate private files. Root-matched comparison uses stable 500-row pages and complete streaming export.

Limits: 25 million entries, 256 levels, 3 GiB per derived snapshot and a 10 GiB free-space reserve. Stop or any traversal/storage bound retains explicitly partial coverage.

## Map workspace and level of detail

`LensViewport` wraps the vector-drawn canvas in native `NSScrollView` magnification (1–8×). It retains one document coordinate space, redraws on Retina displays and rebuilds detail after a magnification gesture or debounced resize. `LensMapBuilder` applies strict tile budgets and reserves capacity for unvisited siblings; overflow becomes an explicit weighted aggregate. Each child query is capped at 5,000 with a weighted remainder. Metadata traversal remains cancellable and read-only.

`PageHostController` temporarily collapses its navigation header and uses a smaller viewport minimum in map focus; leaving the Storage page restores navigation. The optional side inspector remains a native accessible equivalent to the spatial map. Optical magnification, physical folder history and window full-screen mode are distinct states.
