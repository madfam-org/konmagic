# Compare observations and inspect duplicate evidence

## Scan comparisons

Choose **More tools → Compare scans…** with two saved observations of a matching root. KonMagic compares retained metadata and exposes added, removed and changed records in stable 500-row pages. Export complete TSV to inspect every change, not just the current page.

A removal in a comparison means “not present in this observation”; exclusions, access gaps or partial scans may explain it. A comparison does not open or verify every source body. Preserve the scan root, status, filters and observation times with any conclusion.

<figure markdown>
![Synthetic complete scan comparison with added observations](../assets/screenshots/light-comparison.png)
<figcaption>The comparison acceptance fixture intentionally has 601 invented added records to demonstrate complete paging beyond 500 rows.</figcaption>
</figure>

## Duplicate candidates versus proof

**Duplicate evidence…** first groups eligible regular files by equal logical size. Equal size is only a candidate signal. Repeated hard links and cloud placeholders are excluded from independent-file candidate groups.

<figure markdown>
![Synthetic equal-size duplicate candidate review](../assets/screenshots/light-duplicates.png)
<figcaption>This synthetic candidate group is intentionally larger than the hash-verification bound, so automatic hashing stays disabled.</figcaption>
</figure>

Full proof requires a separately selected group of 2–100 ordinary files, at most 100 GiB, and fresh identity checks before complete hashes. Cancellation stops the proof without changing files. Changed, linked, protected or cloud-only sources remain held.

Equal data-fork hashes at one time do not establish equality of resource forks, extended attributes, metadata, provenance or all application semantics. The app never chooses a keeper or authorizes deletion, and it does not calculate exact reclaimable APFS bytes.

## Volume context

Volume & snapshots is read-only diagnostic context. It runs bounded `diskutil` queries, reports the volume/container relationship and reported snapshot names, and distinguishes unavailable metadata. It never invokes `sudo`, mounts a snapshot, disables protection or purges storage.

Do not treat logical size, allocation or duplicate data size as guaranteed free-space recovery. See [limits](../reference/limits.md) and the [disk engine](../developer/scanning.md).
