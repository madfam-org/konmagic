# Review exact paths before approved copying

Review is a dedicated page, not a transient dialog. Its searchable assignment list and selectable full paths make every decision inspectable. The verified child inventory is paged separately from the assignment list.

<figure markdown>
![Unverified reorganization review showing a complete synthetic source and destination pair](../assets/screenshots/light-review-unverified.png)
<figcaption>An assignment is a proposal. Unverified contents remain explicit and copying stays disabled.</figcaption>
</figure>

## Review the draft

Select an assignment and compare the full source and destination. Confirm the correct destination node, output root and output name. Filter assignments by text, rename a copied drop/bucket, remove an assignment, or return to Structure to edit its destination. These actions change private planning state only.

Selecting an assignment preserves the exact chosen destination context when you return to folder editing. Changing a draft invalidates prior verified plans across open windows.

## Verify current sources

Choose a local output root and click **Verify exact preview**. The worker checks the complete bounded set, validates sources and directory relationships, tests destination collisions and available capacity before hashing bodies, and computes complete SHA-256 hashes for eligible regular files. It creates no destination directory.

<figure markdown>
![Verified exact review with complete source and destination and SHA-256 child inventory](../assets/screenshots/light-review-verified.png)
<figcaption>This preview was actually verified against a small temporary synthetic file using the test-fixture allowance. Capture never approves a copy.</figcaption>
</figure>

The inventory includes full child source and destination paths, hashes and empty directories. It uses 200-row pages, within the 5,000-entry plan bound. Exporting a verified manifest includes the complete plan rather than only the visible page. The manifest contains private paths and should be treated as private data.

## Approve separately

**Review & copy** opens a separate confirmation. Acceptance is followed by fresh checks of the shared draft, source identities and hashes, destination anchor, collisions and capacity. KonMagic copies through private sibling stages and publishes exclusively only after verification. It preserves originals and macOS metadata through `fcopyfile`.

A multi-bucket batch is not one global transaction: earlier published buckets can remain if a later one fails. The private receipt records completed destinations, retained staging paths and failure details. Do not assume the entire batch rolled back.

## After an interruption

Open **Receipts & recovery** and inspect the recorded exact paths. Keep original sources, completed copies and retained stages intact until reconciliation. Do not delete staging folders merely because their names begin with a dot. Do not rerun a plan with an existing receipt; create a fresh preview after reviewing recovery state.

Copying increases storage usage while originals remain. It is not a space reclamation operation. Moving, deletion and deduplication need a separate preservation/removal design and are currently unavailable.

[Engineering copy lifecycle](../developer/copy-lifecycle.md) · [Safety invariants](../developer/safety.md).
