# Compatible catalogue adapters

Atlas is an input format, not a mandatory network service. KonMagic opens an existing catalogue folder read-only and layers personal decisions privately. It does not currently implement native whole-machine document-body ingestion.

## Tagged catalogue

`AtlasDatabase` opens bounded read-only SQLite connections with no-follow checks and cancellation support. `Catalog` implements page, summary, facet and retained-reading queries. `CatalogueSlice` carries folder/direct-child scope, literal search, content-search mode, facet intersections and a transient page cursor.

Pages are ordered by exact path using a keyset cursor, not a growing UI offset. The result requests one extra row to identify a next page. Bounded rows, decoded evidence, broad visual labels and tags become `CatalogItem` values.

The compatible schema has `roots`, `items` and FTS5 `content_index`. Items include source metadata, JSON classifications, state/barrier/confidence/provenance, optional compressed text and canonical shared-reading identity. See [formats](../reference/formats.md).

## Effective semantic tags

Corrections are materialized as temporary query overlays rather than writes into the input database. Effective owner/project/family/role/lifecycle values follow the private correction for the exact path when present. The immutable original tags and evidence remain available as provenance.

Summary cache stamps include the database identity, WAL identity when present, and the correction revision. A new tag stamp invalidates effective aggregates. Aggregate partitions conserve observation counts across each facet, including protected metadata.

## Retained readings

The original body is not opened by `storedReading`. It resolves an eligible cached or shared canonical reading, verifies compatible canonical/hash relationships, enforces credential/audit barriers and decompresses under a 640,000-byte bound. Presentation is bounded to 20,000 characters. Trailing compressed bytes, oversize expansion and incompatible shared references are refused.

Indexed search uses literal quoted tokens, up to twelve, with bound SQL parameters. It includes eligible shared references to canonical indexed bodies. Metadata search scans retained names/paths/tag text, not arbitrary SQL. Saved queries exclude transient pagination cursors and validate search/facet lengths.

## Whole-disk ledger

`DiskCatalogue` reads compressed UTF-8 path keys, compressed directory-entry blocks and aliases. Direct children are paged at 200 records. Roots, kind/boundary totals and exceptions are distinct interfaces. An unscanned directory is an error, not an empty verified folder. Cloud flags propagate explicit metadata-only holds.

Alias canonicalization avoids representing the same physical tree as independent source data. Ledger counts, tagged counts and native derived scan counts have different meanings; never assert their sum is a unique-machine count.

## Compatibility changes

A schema change requires a synthetic adapter fixture, bounded parsing and explicit migration/compatibility policy. Treat compatible data as untrusted input. Do not “repair” the original SQLite file in place. Missing tables, malformed compressed blocks or stale identities should produce a useful hold with no source writes.
