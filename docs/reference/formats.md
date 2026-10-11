# Stored and exchanged data formats

These are current internal/compatible formats, not a stable third-party API promise. Treat all exports as private when they contain actual paths. JSON examples below are invented and omit optional fields for readability.

## Workspace JSON

`workspace.json` is at most 2 MiB, owned/private, decoded and validated before use. `Workspace` fields include version, nodes, assignments, output, optional output/catalogue security bookmarks and paths, welcome state and guide page. `version` increments with draft edits; it is a revision counter rather than a fixed schema version.

```json
{
  "version": 1,
  "nodes": [{"id": "example-node", "name": "30 Resources"}],
  "assignments": [{
    "id": "example-assignment", "source": "/example/source/Notes.txt",
    "node": "example-node", "outputName": "Notes.txt"
  }],
  "output": "/example/output", "welcomed": true, "guidePage": 0
}
```

`FolderNode` has stable id, optional parent and name. `Assignment` has stable id, exact source, destination node, outputName and optional bookmark. The full destination is derived from output + node ancestry + outputName. Bookmarks encode Codable data; do not hand-edit them. Undo history lives in memory for the session.

## Knowledge JSON

`knowledge.json` is a bounded 8 MiB owned regular file. `Knowledge.version` currently equals 1. Fields: tagStamp, corrections keyed by exact path, correction undo records, saved collections and proposal rules. A correction has tags, note and Date. Only owner/project/family/role/lifecycle are mutable; reading/protection evidence is not.

`SavedCollection` retains id/name, `CatalogueSlice`, visualization mode, dimension and metric. `ProposalRule` retains id/name, query slice, destination node and `NameRecipe` prefix/suffix/find/replacement. Queries cannot persist transient page cursors.

## Compatible Atlas schema

| Table | Important fields |
|---|---|
| roots | path, label, purpose |
| items | id, path, name, kind, size, tags JSON, state, barrier, confidence, evidence, reason, mtime_ns, seen, manual, extension, parent_path, shared_text_id, hash, compressed text |
| content_index | FTS5 item_id and body |

The adapter’s synthetic tests are executable compatibility examples. Extra columns can exist; missing required columns or malformed bodies are not silently repaired. Shared readings must resolve to compatible canonical content.

## Compressed disk ledger

Tables: `meta(key,value)`, `roots(path,status)`, `directories(path BLOB,metadata,total,boundary)`, `blocks(path BLOB,part,entries BLOB)`, `aliases(path BLOB,canonical BLOB)`, `issues(path,reason)`.

Path BLOBs are zlib-compressed UTF-8. Each compressed entry block is JSON rows of:

```text
[name, kind, logicalBytes, allocatedBytes, mtimeNanoseconds, device, inode, flags]
```

Kinds include file/directory/link/other. Metadata keys describe overall counts/status/time/kind/boundary partitions. Canonical aliases avoid duplicate physical hierarchies. Decode only within documented size bounds.

## Native `.konmagic-scan`

A private SQLite database with `meta`, `nodes`, `identities` and indexes. Nodes include parent/name/kind/relative, own sizes/dates/device/inode/link/flags/package/duplicate/error/depth and folded `tb/ta/tc` totals. Parent IDs precede children. Snapshot metadata is Codable JSON stored under meta keys and includes status/root/source/times/filters/exclusions/comments/coverage.

Filename UUID and snapshot ID are separate identifiers and need not match. Saved observation identity is not current source verification. Scan copy/notes/export must preserve the original snapshot and not write back into Atlas.

## Plans and receipts

`CopyPlan`: id, prepared Date, workspaceHash, output, OutputAnchor, buckets, bytes. Anchor: exact existing path, device/inode. Bucket: assignment, exact destination, records, bytes. Record: relative path, directory bool, Identity and optional SHA-256 hash.

Identity: device, inode, bytes, mode, modified/modifiedNano, changed/changedNano. Dates use the default Swift Codable Date representation (seconds from Foundation’s 2001 reference date), not automatically ISO 8601; metadata text in compatible inputs can use other explicitly named formats.

Receipts include the plan plus status/completed/retainedStages/message. [Copy lifecycle](../developer/copy-lifecycle.md) defines their meaning. A verified plan export is complete; the UI’s current inventory page is only a view.

## Preferences and caches

`disk-lens-preferences.json` retains display/filters/recent scans/window policies. `catalogue-summary.json` is derived, stamped by catalogue/WAL identity and tag revision. `instance.lock` coordinates one process per state directory. `Journal/` and `Disk Lens Scans/` are private evidence/observations. None belongs in public Git.
