# Architecture and trust boundaries

KonMagic is a native AppKit process. It separates observations, private decisions and approved filesystem execution. There is no hosted backend, embedded web filesystem agent, login item or background sorting service. Public documentation is static and opened in the user’s browser.

## End-to-end flow

```text
Atlas catalogue (read-only) ──► Catalog / AtlasDatabase ──► Content views
Compressed disk ledger ──────► DiskCatalogue ────────────► Recorded hierarchy
Live metadata / ledger ──────► LensScanner ─► LensWriter ─► LensStore ─► Disk Lens
                                           private SQLite snapshot

WorkspaceStore ─► virtual nodes + explicit assignments ─────────► Structure / Review
KnowledgeStore ─► corrections + collections + proposal rules ───► effective tags

Explicit Verify ─► SafeFS.preview ─► complete bounded CopyPlan
Separate approval ─► SafeFS.copy ─► sibling stage ─► exclusive publish + durable receipt

Original sources remain intact; no source move/delete primitive is offered.
```

## Ownership map

| Owner | Responsibility | Boundary |
|---|---|---|
| `KonMagicDelegate` | App startup, menus, instance lock, termination | Selects normal versus isolated QA state |
| `KonMagicNavigation` | Shared state refresh, activity, active host | Owns coordination across page windows |
| `PageHostController` | Page cache/history/viewport and guidance | One host per window, no view attached twice |
| `KonMagicController` | Structure, source browsing, verification/copy commands | Uses shared store and background queues |
| `WorkspaceStore` | Validated draft and session undo | Owned local JSON, atomic writes |
| `KnowledgeStore` | Human corrections and saved knowledge | Separate from immutable observations |
| `Catalog` / `DiskCatalogue` | Compatible retained observations | Read-only SQLite connections |
| `LensScanner` / `LensWriter` | Bounded metadata acquisition and folding | New private derived snapshots only |
| `SafeFS` | Identity, capacity, collision, hash and publication checks | Descriptor-based no-follow traversal |

## Four kinds of truth

1. **Historical evidence:** catalogue rows and saved scans, possibly stale or incomplete.
2. **Personal intent:** virtual folders, selected assignments, private corrections and naming choices.
3. **Verified current state:** a bounded plan with identities/hashes, an output anchor and a workspace fingerprint.
4. **Execution receipt:** what was staged/published, including failures and retained stages.

A UI selection must never collapse these into one state. A saved scan cannot authorize a copy. A tag cannot remove a barrier. A plan cannot survive an unrelated draft change. A receipt cannot imply every original is redundant.

## Concurrency model

AppKit views are updated on the main thread. Bounded pages, summaries, scans, layout and transfer work use dedicated background queues with cancellation/generation guards where appropriate. SQLite owns complete retained trees; controllers own bounded rows and summaries. Shared draft mutations and transfers are coordinated across all hosts.

Read [module map](modules.md), [navigation](navigation.md), [filesystem safety](safety.md) and [performance](performance.md) before changing these boundaries.
