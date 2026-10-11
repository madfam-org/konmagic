# Bounds and invariants

Limits are implemented to keep observation, parsing and review finite. They are not invitations to override guards in local scripts.

| Scope | Current bound | Source |
|---|---:|---|
| Virtual destination nodes | 500 | Workspace.validate |
| Draft assignments | 100 | Workspace.validate |
| Draft undo | 50 session edits | WorkspaceStore.change |
| Source plan entries | 5,000 | SafeFS.fileLimit |
| Source plan logical data | 100 GiB | SafeFS.byteLimit |
| Required remaining output free space | Strictly greater than 10 GiB | SafeFS.reserve |
| Folder/file output name | 240 UTF-8 bytes | Workspace.checkName |
| Workspace JSON | 2 MiB | WorkspaceStore.init |
| Knowledge JSON | 8 MiB | KnowledgeStore |
| Corrections | 5,000 paths | Knowledge.validate |
| Correction undo | 64 | Knowledge.validate |
| Saved collections / rules | 64 each | Knowledge.validate |
| Selected correction paths | 200 | KnowledgeStore/UI |
| Rule initial matches | First 200 | Catalogue page / DraftProposal |
| Explorer/source/inventory page | 200 | Native controllers |
| Scan comparison page | 500 | LensDifferencePage |
| Retained reading expansion | 640,000 bytes | Catalog.storedReading |
| Retained reading presentation | 20,000 characters | Catalog.storedReading |
| Saved query search | 300 characters / 1,200 UTF-8 bytes | CatalogueSlice.validate |
| Indexed query tokens | First 12 literal tokens | CatalogueSlice.predicate |
| Native scan records | 25 million | LensWriter.check |
| Native snapshot storage | 3 GiB | LensWriter.check |
| Native scan/tree depth | 256 | LensScanner |
| Copy bucket nesting | 48 | SafeFS.inspect |
| Duplicate hash group | 2–100 regular files, ≤100 GiB | LensStore.proveDuplicates |
| Volume subprocess | 12 seconds, 16 MiB output | VolumeContext.command |
| Interactive direct folder names | 100,000 | SafeFS.names |
| Requested gallery thumbnails | First 24 regular files / 3 concurrent | SourcePreviewController |
| Thumbnail source size | At most 128 MiB | SourcePreviewController |
| Thumbnail provider timeout | 15 seconds per request | SourcePreviewController |
| Navigation history | 32 entries | PageHostController |
| Relationship diagram | Top 12 groups per axis | CatalogueVisuals |

No source move/delete, symlink following, destination overwrite or automatic cloud hydration is offered. Manual assignments remain authoritative. Credentials, operational projects and managed libraries stay held. Verification and copying are separate explicit actions. A receipt describes per-bucket progress; it is not a global rollback guarantee.

Allocated bytes are not guaranteed reclaimable APFS space. Historical observations are not current identity checks. Tagged, disk and derived scan coverage must not be added together as a unique-machine count.
