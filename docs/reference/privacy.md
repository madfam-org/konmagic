# Security, privacy and preservation

KonMagic’s native storage/organization features are local. There is no configured account, backend upload, telemetry service, login item or remote sorting agent. Public documentation is a static separate website with local fonts and a browser-side public-doc search index.

Opening Help launches a fixed HTTPS documentation URL through the default browser. The route depends only on the current page. It contains no filename, source path, query, catalogue record or receipt. Your browser still performs an ordinary network request and GitHub may log hosting access under its own policies; “local app” does not mean web help is offline.

Explicit native file/thumbnail viewing uses macOS preview providers. Support and any provider-specific behavior depend on the user’s system. Metadata selection does not request bodies; thumbnail generation and file viewing are separate explicit actions. Preview does not replace verified copy safety.

## What stays private

User workspaces, knowledge corrections, catalogue summaries, scan databases, saved queries, security bookmarks, complete plan exports and receipts can reveal sensitive structure or names. They stay in owned local directories with restrictive file modes. Permission modes are not encryption; protect the account/disk/backups appropriately.

The public repo’s ignore rules exclude normal JSON/database/log/screenshot/binary outputs. The only screenshot exception is the reviewed synthetic documentation asset directory. Never attach a normal catalogue or screenshot to a public issue.

## What protections do and do not mean

A barrier blocks content access or copying within its scope. Corrected semantic tags cannot remove barriers. Current source eligibility is conservative and checks known sensitive/operational paths; it is not semantic proof that every allowed document is non-sensitive.

Historical metadata may be incomplete. Complete data-fork hashes identify bytes at verification time but do not establish all resource forks/extended attributes/provenance are interchangeable. macOS copy metadata APIs are used for approved copies; managed collections remain outside general reorganization.

## Backups and cleanup

Current KonMagic retains originals and performs no source deletion. It needs extra capacity for output. iCloud sync, a Git remote and a saved scan are different preservation mechanisms; none alone is a full backup of arbitrary local data. The app does not automatically validate backup coverage or remote repository completeness.

A future deletion/move workflow requires its own evidence, reversible recovery design and separately reviewed authorization. Do not infer permission to remove originals from a successful copy or equal hash group.
