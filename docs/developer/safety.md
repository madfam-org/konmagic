# Filesystem safety contract

Safety is enforced below the UI. `SafeFS` separates metadata inspection, preview and approved copy execution. A disabled button is helpful, but never the sole protection.

## Invariants

| Invariant | Mechanism |
|---|---|
| Originals are retained | No source move/delete operation in the copy path |
| No linked traversal | Descriptor-based ancestor traversal with `O_NOFOLLOW` and no-follow entry metadata |
| Exact sources remain identifiable | Device/inode, type/mode, byte length, mtime/ctime seconds and nanoseconds |
| No overwrite | Case/Unicode collision checks and exclusive create/publication |
| No silent cloud downloads | Placeholder flags and protected/managed boundaries are held |
| No stale approval | Workspace fingerprint, output anchor and current identities/hashes rechecked |
| Review stays bounded | Assignment, entry, byte and reserve limits |
| Interrupted work is visible | Durable receipt with completed outputs and retained stages |

## Eligibility before content reads

Production source policy permits ordinary data under standard user-content roots: Desktop, Documents, Downloads, Pictures, Music and Movies. It also checks names and ancestor collection markers. Repositories, managed libraries, credentials, app/package data and operational projects stay in place even when macOS allows access.

Examples of held boundaries include `.git`, `.ssh`, `.gnupg`, `.aws`, `.kube`, `node_modules`, virtual environments, CloudStorage/Mobile Documents, application/photo/music libraries, private keys, keychains, recovery material and project manifests. This is conservative policy, not a universal sensitive-content detector.

Cloud flags, non-ordinary types and symlinked ancestors are refused. Classification corrections cannot erase these boundaries.

## Preview sequence

`preview` validates the draft, anchors the output root, enumerates eligible metadata, checks relationships/collisions and capacity before full-body reads, then hashes complete regular files. The plan stores per-entry identities and hashes, per-bucket exact destinations, total bytes and a workspace hash. Verification creates no destination directory.

The `allowFixture` parameter is confined to explicit synthetic tests/capture calls. UI production verification uses the normal policy. Never expose this switch as an end-user preference or fallback after a hold.

## Race resistance

Open an ancestor descriptor, inspect an entry without following it, open the entry exclusively/no-follow where appropriate, and compare the opened identity to the inspected identity. Recheck at execution and after body reads. Pin the existing output anchor’s device/inode. Before publication, re-enumerate the source and test the destination again.

These checks reduce filesystem races; they do not claim universal hostile-filesystem security or complete preservation of every external app’s database semantics. Keep uncertain managed collections outside the copy workflow.

## Privacy versus preservation

Metadata itself can be sensitive. JSON/SQLite state and receipts are private local files with owned paths and restrictive permissions. Public documentation uses generated invented fixtures. Native help links contain no private query/path. See [privacy reference](../reference/privacy.md).

The [synthetic tests](testing.md) exercise refused links, credentials, source changes, case/Unicode collisions, capacity-before-body order, hashes, empty directories, exclusive publication and retained originals.
