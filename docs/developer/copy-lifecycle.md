# Copy plans, publication and recovery

## State machine

```text
Draft ── explicit Verify ──► Verified CopyPlan
  │                              │
  └─ any draft change ◄───────────┘ invalidates plan
                                 │
                   separate Review & copy confirmation
                                 ▼
                 whole-batch fresh preflight
                                 ▼
                     receipt: started
                                 ▼
      per bucket: private stage → copy + metadata → hashes + source recheck
                                 ▼
                     receipt: publishing
                                 ▼
           exclusive rename into exact destination + parent fsync
                                 ▼
           append completed destination; receipt: copying
                                 ▼
                   all buckets: completed

Any failure → receipt: failed, completed destinations + retained stages survive
```

`CopyPlan` is a Codable value, not authority independent of the current workspace. It includes an ID/time, workspace fingerprint, output path/anchor, buckets and total bytes. Each `BucketPlan` carries its assignment, exact destination, complete `FileRecord` array and bytes. Records include relative path, directory flag, `Identity` and optional complete SHA-256 data hash.

## Preflight before writing output

`copy` compares the current workspace hash, validates the output anchor, fully re-inspects every bucket and compares it to the verified inventory, checks each destination is clear, and ensures the reserve still holds. Only then does it create the private journal and initial receipt. Reusing a plan with an existing receipt is refused.

The UI also rechecks global busy state and workspace fingerprint after modal confirmation because another window may have changed intent while the confirmation was visible.

## Stage and publish one bucket

A new `.atlas-stage-UUID` sibling directory is created privately beneath the exact destination parent. Its path is appended to the receipt before content work. Regular source files are opened no-follow, identities compared, output files created exclusively and copied with `fcopyfile(COPYFILE_ALL)`. Destination bytes and source bytes are fully hashed again; source identity is checked after reading.

Directories are created through descriptor traversal. Directory metadata is copied in reverse record order after children are written, preserving ACLs, extended attributes and stat metadata through the supported macOS copy API. The complete source bucket is re-inspected before publication.

`renameatx_np(..., RENAME_EXCL)` publishes only if the final name remains absent. Parent `fsync` makes publication durable; the destination is then recorded as completed. Empty private staging directories intentionally remain because the workflow has no data-removal primitive.

## Failure semantics

A batch is a sequence of per-bucket publications, not one all-or-nothing filesystem transaction. An error in bucket two does not erase a verified published bucket one. Source data remains intact, and failed stages remain recorded for reconciliation.

Receipt fields are `plan`, `status`, `completed`, `retainedStages` and `message`. Status can be started, publishing, copying, completed or failed. A failure between publication and receipt persistence may require checking the exact final path as well as the stage. Never infer absence of a published output solely from an incomplete receipt entry.

## Recovery policy for contributors

Preserve evidence. Do not auto-remove stages, retry a receipt ID, overwrite a final destination or mark originals redundant. A future recovery UI must reconcile exact current identities and hashes with the plan/receipt, present ambiguity, and require a separately reviewed action. Current recovery opens the private journal for inspection; it does not implement automatic rollback or removal.
