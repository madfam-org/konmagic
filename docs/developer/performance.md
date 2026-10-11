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

A newer request cancels or supersedes old page/summary work. Results must match their generation before touching views. A background source completion must not overwrite the active transfer’s status. Keep cancellation checks inside long enumeration/streaming loops, not only at operation boundaries.

## Boundaries that matter

Tagged/direct-child lists are 200 rows. Comparison pages are 500. Verified inventory pages are 200 within the complete 5,000-entry plan. Saved knowledge stores, queries, decompression and database runtime are bounded. See [limits](../reference/limits.md) for the exact values and scopes.

Keyset paging keeps catalogue traversal stable under large record counts. Aggregate partitions conserve counts for every facet, including protection states. Query caches are invalidated by database/WAL identities and tag revisions. Native scan folding streams in reverse parent-first IDs.

Adaptive treemap grouping limits drawing complexity while the full retained tree stays available in lists/exports. Relationship diagrams intentionally show top groups instead of every possible edge.

## Measurement checklist

Measure the relevant path independently: cold database connect, first bounded page, warm summary, filter intersection, map layout, page transition, scan throughput, cancellation latency and peak resident memory. Record dataset size, logical/allocation weight, SDK/compiler, OS, architecture and whether caches were warm.

Use synthetic inputs for public benchmarks. Local large-catalogue smoke output is private and is not a portable performance claim. Do not quote timing without the tested scope. UI smoke timing can demonstrate a regression but does not measure input-to-paint latency under all loads.

## Known constraints

Some aggregation is inherently proportional to the retained catalogue. Displayed prior groups may remain briefly while a new summary loads; the loading status must make that visible. Rules are bounded proposals rather than streaming machine-wide execution. A saved scan refresh without live event history performs full enumeration.

Avoid broad repeated whole-machine scans for UI interactions. Keep expensive content inference out of hover handlers and folder selection. Do not weaken reserve/cancellation checks for a faster benchmark.
