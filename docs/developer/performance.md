# Keep work bounded and keep AppKit responsive

The app is designed to observe large catalogues while holding bounded UI pages. Complete trees belong in SQLite, not one array of every path. This is an architectural strategy, not a promise that every query is instant on every Mac.

## Work placement

| Work | Execution strategy |
|---|---|
| Main source page | Dedicated catalogue queue, request generation and search debounce |
| Explorer pages | Background browsing queue, cancellation and generation guards |
| Explorer aggregates | Separate utility queue and private summary cache |
| Disk acquisition | Utility operations queue and streamed SQLite writer |
| Treemap layout | User-initiated background drawing queue |
| Preview/copy | Dedicated utility transfer queue |
| AppKit state | Main-thread updates only |
| Content gallery thumbnails | Explicit request, up to 24 files and three concurrent providers; update existing cards, cancel on context change |
| Content gallery cards | Only visible rows plus one adjacent row on either side; reuse unchanged cards, no hidden List-view gallery allocation |
| System icons and decorative artwork | Type icons from retained metadata; bounded page icon cache and shared bundled artwork |

A newer request cancels or supersedes old page/summary work. Results must match their generation before touching views. A background source completion must not overwrite the active transfer’s status. Keep cancellation checks inside long enumeration/streaming loops, not only at operation boundaries.

## Boundaries that matter

Tagged/direct-child lists are 200 rows. Comparison pages are 500. Verified inventory pages are 200 within the complete 5,000-entry plan. Saved knowledge stores, queries, decompression and database runtime are bounded. See [limits](../reference/limits.md) for the exact values and scopes.

Keyset paging keeps catalogue traversal stable under large record counts. Aggregate partitions conserve counts for every facet, including protection states. Query caches are invalidated by database/WAL identities and tag revisions. Native scan folding streams in reverse parent-first IDs.

Adaptive treemap grouping limits drawing complexity while the full retained tree stays available in lists/exports. Relationship diagrams intentionally show top groups instead of every possible edge.

## Measurement checklist

Measure the relevant path independently: cold database connect, first bounded page, warm summary, filter intersection, map layout, page transition, scan throughput, cancellation latency and peak resident memory. Record dataset size, logical/allocation weight, SDK/compiler, OS, architecture and whether caches were warm.

Use synthetic inputs for public benchmarks. Local large-catalogue smoke output is private and is not a portable performance claim. Do not quote timing without the tested scope. UI smoke timing can demonstrate a regression but does not measure input-to-paint latency under all loads.

## Known constraints

Some aggregation is inherently proportional to the retained catalogue. Prior groups are cleared while a new summary loads; the status explains that work without holding ordinary browsing. Rules are bounded proposals rather than streaming machine-wide execution. A saved scan refresh without live event history performs full enumeration.

Avoid broad repeated whole-machine scans for UI interactions. Keep expensive content inference out of hover handlers and folder selection. Do not weaken reserve/cancellation checks for a faster benchmark.

## Private real-catalogue benchmark

Run `python3 scripts/benchmark.py` after building the current code. The wrapper checks bounded, owned private app state, creates an isolated `/private/tmp/konmagic-benchmark-*` directory and copies decisions/cache into it. The working draft, tags and original catalogue remain untouched. It does not create the proposed output folder. Results, logs, machine context and the local HTML report stay private; never commit real runs.

`--benchmark-catalogue` measures process-cold connections, first/next pages, familiar-folder paging, metadata/FTS searches, an uncached full summary, cached summaries, facet intersections, disk-ledger paging and cancellation. Small queries use five samples; search/disk/cancellation use three; full aggregation uses one. Operating-system filesystem caches are not flushed. A held/timed-out query remains a held sample rather than an empty success.

`--journey-benchmark` measures the native display cycle for Content, metadata presentation, opening/cancelling classification, exact placement calculation, an isolated draft/Review handoff, Gallery rebuilds, semantic maps and cached page transitions. It requests no thumbnails, source previews, full hashes or approved copies. The classification open/cancel sample includes a fixed 400 ms cancellation timer; it is not an editor-open latency measurement. Storage page samples display controls without importing a whole-machine scan. Other view samples measure the native display cycle, not physical input-to-photon latency. Resident and peak resident memory include the process, SQLite, AppKit, artwork and decoding; peak is a cumulative high-water mark.

Both modes require an owned temporary benchmark state. The wrapper checks working decision hashes and input database identities before/after, and records machine load so background workload remains visible. Use `--skip-ui` for query-only measurements. Synthetic documentation captures remain a separate workflow and cannot be populated from these private runs.


`--storage-map-benchmark` measures native layout/display cycles against an existing read-only `.konmagic-scan`, including the whole-machine root. Set `KONMAGIC_QA_STATE` to a fresh owned `/private/tmp/konmagic-storage-wave-*/State` containing an isolated workspace and `KONMAGIC_BENCHMARK_SCAN` to the saved scan. It samples balanced, detailed and ultra fit views plus 4× ultra optical zoom. It reports recorded coverage, visible rectangle counts, display-cycle timing and process RSS. It does not perform a new scan, read source bodies or change the working draft; benchmark preferences and reports are written only to temporary state. Record input scan identities/hashes and working decision hashes before/after, and keep real reports outside Git. Samples include a 50 ms polling interval and the native display cycle; they do not measure physical input-to-photon latency or steady-state panning frame rate.

## Focused Content workspace

View changes reuse the current 200-row page and retained aggregate summary. Separate tree snapshots retain root objects, up to 256 expanded nodes, selected node identities and scroll origins. Dataset/scope changes, explicit refresh and changed tag stamps prevent stale authority. No visualization switch automatically requests source thumbnails or bodies. Gallery density changes recycle only visible/adjacent native cards; each page has at most 200 sources, at most 24 explicitly requested thumbnails and three requests in flight.

The private Content workspace benchmark measures initial all-content readiness, first gallery creation, density changes, map/tag switching and cached physical-tree restoration. It asserts page/summary query generations and the isolated draft remain unchanged through warm switching. Values are native layout/display-cycle samples on a retained real catalogue, not sustained frame-rate or input-to-photon claims; record warm/cold conditions and cumulative process peak RSS.

Rapid selection changes coalesce current-metadata checks with a 120 ms debounce and a generation ticket. Reading a retained excerpt remains a separate action. Inline Quick Look has an independent ticket so obsolete requests cannot bind to another selected source.
