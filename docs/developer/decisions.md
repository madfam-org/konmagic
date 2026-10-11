# Architecture decisions

These concise records explain the current implementation choices. They do not replace code or safety tests.

## ADR 01 — Native AppKit utility

**Decision:** Replace the local web filesystem organizer with a native Mac application. **Reason:** Direct system controls, local metadata/copy APIs, bounded background work, native panels/Quick Look and no privileged browser agent. **Tradeoff:** macOS-specific UI and more manual native layout. The docs remain a separate static web resource.

## ADR 02 — Observations and decisions are separate

**Decision:** Compatible Atlas inputs are read-only; personal corrections and draft intent use owned private stores. **Reason:** Retained evidence is not editable authority. **Tradeoff:** Query overlays/cache invalidation are necessary and path-based corrections can become stale after external changes.

## ADR 03 — Copy first, originals retained

**Decision:** No source move/delete primitive. Preview and copy are separately requested and checked. **Reason:** No data-loss assumption based on classification or duplicates. **Tradeoff:** Output requires additional capacity and reclamation remains a separate future workflow.

## ADR 04 — Reviewable bounded batches

**Decision:** Limit assignments, traversed records, bytes, decompression and UI pages. **Reason:** Complete verification and comprehension have practical limits. **Tradeoff:** Large collections must be split or narrowed; no one-click whole-machine application.

## ADR 05 — Stream full trees into SQLite

**Decision:** Parent-first inserts and reverse aggregation; bounded read views. **Reason:** Millions of observations cannot live as AppKit rows or one Swift array. **Tradeoff:** Derived storage and query cost remain, with explicit free-space/scan-size guards.

## ADR 06 — One shared draft, separate window controllers

**Decision:** One decision store shared across page hosts, distinct view objects per host. **Reason:** Prevent lost intent and view reparenting; support optional secondary/tertiary windows. **Tradeoff:** Mutation/activity propagation and global approval guards must stay centralized.

## ADR 07 — Static Pages documentation

**Decision:** Public Markdown, invented screenshot fixtures, strict validation and GitHub Actions deployment. **Reason:** Durable knowledge transfer alongside source without uploading private observations. **Tradeoff:** Manual screenshots/versioned explanations require ongoing review; the web manual is online rather than bundled offline.
