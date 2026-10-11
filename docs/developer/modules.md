# Source module map

This inventory follows the current source tree. Links point to public generic implementation; private runtime data is never embedded.

| Module | Responsibility |
|---|---|
| [App.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift) | Application startup, menus, Structure, source browser and preview/copy commands. |
| [Catalog.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift) | Live bounded source metadata and compatible tagged observation adapter. |
| [CatalogueDatabase.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift) | Read-only SQLite, compression, query slices, partitions, FTS and tag overlay queries. |
| [CatalogueExplorer.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift) | Dataset/query/facet/list/tree/map controls, evidence and exact destination handoff. |
| [CatalogueTests.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueTests.swift) | Synthetic verification and native UI acceptance checks. |
| [CatalogueVisuals.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift) | Content treemap and bounded semantic relationship drawing. |
| [ContextHelp.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift) | Native contextual explanations and popover guidance. |
| [DiskCatalogue.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift) | Compressed whole-disk ledger, aliases, exceptions and stamped aggregate caches. |
| [DiskLensController.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift) | Storage controls, selection/current checks, observation work and destination handoff. |
| [DiskLensExports.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift) | Complete export, root-matched metadata difference paging and image export support. |
| [DiskLensFilters.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift) | Native compound filter editor and type-color customization. |
| [DiskLensMap.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift) | Proportional adaptive layout and native canvas interaction. |
| [DiskLensModel.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift) | Scan nodes/snapshots/totals, metrics/display/colors, filters and preferences. |
| [DiskLensScan.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift) | Current metadata traversal, historical ledger import and filtered derived observations. |
| [DiskLensStore.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift) | Private SQLite writer, parent folding and bounded retained tree reader. |
| [DiskLensTests.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift) | Synthetic verification and native UI acceptance checks. |
| [DiskLensWatcher.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWatcher.swift) | Current-session FSEvents history and gap-aware refresh decisions. |
| [Documentation.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/Documentation.swift) | Fixed public HTTPS routes and active-page native Help actions. |
| [DocumentationCapture.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DocumentationCapture.swift) | Restricted generated fixture validation and owned synthetic window screenshot workflow. |
| [DuplicateReview.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift) | Size candidates, bounded explicit complete-hash proof and no-delete evidence UI. |
| [Filesystem.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift) | Descriptor identity, eligibility, no-follow traversal, full hashing, copy plans and durable publication. |
| [InspectorTypography.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/InspectorTypography.swift) | Native path/evidence text and dialog layout helpers. |
| [JourneyTestsUI.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneyTestsUI.swift) | Synthetic verification and native UI acceptance checks. |
| [Knowledge.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift) | Exact-path human corrections, saved collections/rules, naming and draft proposal semantics. |
| [KnowledgeTests.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeTests.swift) | Synthetic verification and native UI acceptance checks. |
| [KnowledgeUI.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift) | Native classification, collection and proposal dialogs. |
| [MetadataLabels.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/MetadataLabels.swift) | Human-readable retained metadata labels. |
| [Model.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift) | Validated virtual nodes, exact assignments, workspace persistence and session draft undo. |
| [Navigation.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift) | Five-page cached hosts, viewport/history, shared decisions, active routing and additional windows. |
| [NavigationTestsUI.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/NavigationTestsUI.swift) | Synthetic verification and native UI acceptance checks. |
| [ReorganizationReviewUI.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift) | Exact path review, assignment search, verified child paging and complete manifest export. |
| [ReviewTestsUI.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift) | Synthetic verification and native UI acceptance checks. |
| [ScanComparisonUI.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift) | Paged complete metadata comparison and full text export. |
| [SourcePreview.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift) | Embedded native file Quick Look, paged folder list/gallery, explicit bounded thumbnails and metadata-only tree/map handoff. |
| [SourcePreviewTests.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreviewTests.swift) | Synthetic preview identity, link, protected name and changed-source refusal checks. |
| [Tests.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/Tests.swift) | Synthetic verification and native UI acceptance checks. |
| [ToolkitTestsUI.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitTestsUI.swift) | Synthetic verification and native UI acceptance checks. |
| [ToolkitUI.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift) | Four-stage overview, private coverage summary and public documentation entry. |
| [VolumeContext.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift) | Bounded read-only diskutil volume/container/snapshot context. |
| [main.swift](https://github.com/madfam-org/konmagic/blob/main/Sources/main.swift) | Explicit diagnostic dispatch and native application entry point. |

## Where to start

| Change | Read first |
|---|---|
| Destination hierarchy | Model → App → Review |
| Search/facets/readings | CatalogueDatabase → Catalog → CatalogueExplorer → Knowledge |
| Scan size/coverage/maps | DiskLensModel → Scan → Store → Map → Controller |
| Copy or recovery behavior | Filesystem → App → Review → Tests |
| Another page/window | Navigation → page controller → NavigationTestsUI |
| Public manual link | Documentation → App/ToolkitUI → docs route validation |
| Screenshot workflow | DocumentationCapture → scripts/docs → manifest/gallery |

[Complete declaration index](../reference/symbols.md). This index lists source declarations; it is not a compiler-generated call graph or a stable external API.
