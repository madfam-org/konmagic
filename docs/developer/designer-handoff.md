# Designer handoff: a friendly, expressive KonMagic

This brief describes KonMagic 0.5.1's implemented native macOS interface and the design work we want next. Proposed styling is identified as a recommendation. The [screenshot atlas](../reference/screenshots.md) shows actual AppKit screens in light and dark appearances, entirely with invented data.

## Product personality and journey

KonMagic helps someone understand a crowded Mac, recognize meaningful collections, design their preferred organization, and inspect an exact proposal before approving a copy. Its emotional promise is **“Make room for what matters. Keep control of every decision.”** The experience should feel curious, calm, warm and encouraging. A kawaii direction is welcome: soft shapes, restrained expressive illustrations, pleasing microinteractions and a friendly companion can make difficult organization feel approachable.

The app handles memories, creative work and administrative documents. Cuteness must coexist with precise explanations. “Magic” should mean helpful interactions and clear previews; it cannot imply that the app knows the correct destination or silently reorganizes sources. A wedding film and an entertainment film can share an extension while belonging to entirely different collections. Human decisions control placement.

| View | User's question | Outcome |
|---|---|---|
| Toolkit | Where should I begin, and what can this app do? | A useful next task |
| Storage | What occupies the disk, and where should I look? | A physical branch worth investigating |
| Content | What is this material, and what belongs together? | An understood collection, refined tags and a chosen destination |
| Structure | How do I want my information arranged? | A virtual hierarchy with manually assigned sources |
| Review | Exactly what would be created, and is it ready? | A checked proposal and a separately approved copy |

The rich source viewer, comparisons, duplicate evidence and volume context are supporting detail pages. Native file panels and confirmations preserve macOS conventions.

## Shared window shell

The persistent top strip contains Back/Forward, the five main destinations and **Open page in new window**. Beneath it, a title and short explanation orient the user; a contextual next-step button leads toward useful follow-up work. Pages retain their browsing context when visited again. Command-0 through Command-4 select the five main views. Help opens the public manual, the active page's guide or the developer handbook; the native welcome guide remains available.

Secondary windows own separate browsing controllers while sharing one draft and one set of private tag decisions. A destination edit therefore updates across windows. Opening a new window is optional. The foundation is native AppKit: system controls, focus rings, semantic colors, menus and keyboard behavior.

**Design direction:** give the shell an unmistakable home identity and current location. Consider compact stage icons, a gently colored active destination and breadcrumbs for detail pages. Keep Back distinct from ascending a physical folder. Main navigation should allow exploration in any order rather than looking like a mandatory checkout sequence.

Current designed page widths range from roughly 1,050 to 1,440 points, with scrolling at smaller window sizes. Propose explicit compact and wide arrangements rather than scaling everything down. Specify hover, focus, selected, disabled, loading and reduced-motion states. Playful transitions should explain location without delaying access to files.

## 1. Toolkit: the welcoming task hub

![Current Toolkit](../assets/screenshots/light-toolkit.png)

### Purpose and composition

Toolkit answers “What can I do here?” before presenting dense controls. It combines a grounded coverage summary with task cards and a suggestion based on the draft. It should feel like a thoughtful workbench, not a technical dashboard requiring interpretation.

The header contains KonMagic, its emotional promise, **Documentation**, **Welcome guide** and **Refresh overview**. A small privacy/original-retention statement follows. A left-hand glance card reports tagged observations, separate full/partial readings, recorded disk entries, exceptions and observation date. The illustrated hero keeps all headings and controls native. These evidence sets overlap; adding them into a fabricated “total files understood” would be misleading.

Four cards form a two-by-two grid:

- **Understand storage / Observe:** physical hierarchy, storage weights, scan changes and volume context; opens Storage.
- **Find & refine content / Discover:** files, tags, retained readings and familiar groups; opens Content.
- **Design your organization / Shape:** virtual destinations and manually assigned drops/buckets; opens Structure.
- **Preview every destination / Review:** exact paths, collisions and verification before copy approval; opens Review.

Each card has a numbered stage, SF Symbol, title, short explanation and one action. Current accents are teal, violet, orange and green; cards use rounded pastel surfaces, code-native smiling illustrations, and a minimum height of 200 points. A pink recommendation banner shows **Your next step**, counts of destinations/assignments/corrections/collections and shortcut reminders.

### States and redesign opportunities

Connecting coverage must not freeze the cards. Unavailable catalogue data should explain reconnecting while leaving live browsing usable. An empty draft recommends recognizing a collection; an assigned draft recommends exact Review. Busy work elsewhere needs context without turning the home into an alarm.

Use distinct restrained illustrations—a storage garden, discovery lens, folder workshop and careful checklist, for example. A companion could indicate the recommended task. Make a card's interactive area and button share one clear action. Separate the warm invitation from the evidence summary; give details on demand. Avoid cleanliness scores or streaks that pressure people to delete data.

## 2. Storage: physical disk observation

The 0.5.2 map-focus variant temporarily removes the surrounding navigation and coverage chrome. Compact controls remain above an edge-to-edge map; the source path and scan status remain below it. The inspector can be restored beside the map. Preserve the difference between optical zoom/pan, physical folder exploration, map history, page history and native window full screen. Large records must remain inspectable and compact groups must disclose their aggregate status. See the [focused workspace walkthrough](../guide/storage.md#navigate-and-customize).


![Current Storage](../assets/screenshots/light-storage.png)

### Layout and information hierarchy

Storage, also called Disk Lens, explains physical hierarchy and recorded storage weights. A large nested rectangle map dominates the center; a right column connects the map to exact names, metadata, preview actions and draft assignment. This is an investigation workspace.

Top rows contain current-folder scan, recorded-machine import, recent scans, refresh, saved-scan loading and **More tools**. Parent and Zoom selection sit near the current path. The visible measure chooses logical bytes, allocated blocks or unique counted files. **Customize view** reveals display, color, palette, depth, units and volume settings.

A coverage summary describes the snapshot source, status, entries, logical/allocated totals, exceptions, cloud entries and repeated hard links. The map legend explains area, color, zero-area entries and compact groups. Small branches can be grouped for legibility while complete scan search/export remains available.

The independently scrollable right column contains scan-wide name search, a paged source list, selectable metadata, Open/Quick Look/Reveal, destination choice, assignment, cleanup handoff to Finder, notes and the rich viewer. Keep the map visually dominant while preserving readable details.

### Interactions and evidence

Hover inspects; clicking locks selection; double-clicking zooms into directory context. Parent ascends physical ancestry. Keyboard navigation and Space preview are available. Selection needs an outline and text, not color alone. A virtual aggregate tile is a grouping rather than an assignable source.

Masks hide detail while retaining area; scan filters affect what a new scan records. Design them as distinct concepts. Retained scans without live event history require a fresh observation to update. More tools includes filters, masks, comparison, volume/snapshot context, duplicate evidence, notes and image/text exports.

### States and design direction

Cover no scan, scanning, stopped/partial scan, map layout in progress, file/folder selection, aggregates, zero-area entries, stale coverage and access barriers. Show counts and Stop during observation; avoid invented completion percentages. A held/cloud/changed source needs an explanation before content requests.

Allocated bytes cannot promise reclaimed APFS space: snapshots, clones and shared containers complicate it. Never turn a large tile into a “safe to remove” badge.

Use calm palettes, precise hover cards, strong selection outlines and beginner-friendly explanations of area/color. Breadcrumbs or a miniature overview could support deep zooming. Keep search and map selection coordinated, and distinguish current-folder scope from whole-scan scope. Decorative characters belong in empty/loading explanations rather than over data.

## 3. Content: semantic discovery and classification

![Current Content](../assets/screenshots/light-content-list.png)

### Purpose and composition

Content connects files with meaning: owner, project, family/type, role and lifecycle. It helps users recognize collections, inspect retained evidence, correct classification, save a view and propose placement.

The illustrated header chooses **Content & tags**, **Recorded disk** or **Access exceptions** and explains coverage. The left sidebar includes familiar places, content-family shortcuts with retained counts, and complete facet groups. The query row has familiar places, search, search mode, Clear filters, Refresh, Collections and Rules. Search matches names/paths/tags or already indexed content; it does not ingest original bodies on demand.

Three columns divide the work:

- **Left, about 245 points:** dimension chooser and facet groups/counts; selecting a group narrows the slice.
- **Center, flexible:** visualization switch, measure, filter context/chips, path/Parent, results, paging and status.
- **Right, about 340 points:** evidence inspector, retained excerpt, current source viewer, tag correction, Finder reveal, chosen draft destination, proposed placement and assignment.

### Six visualizations

| Mode | Meaning | Required design distinction |
|---|---|---|
| Gallery | Exact observations as selectable cards; thumbnails only on explicit request | Selecting shares source authority with List |
| List | Exact observations, tags, reading status and size | Scannable rows with full paths accessible |
| Folder tree | Recorded physical parent-child relationships | Physical folders are real sources |
| Tag tree | Semantic facet intersections | Group nodes filter; they are not physical source folders |
| Treemap | Relative counts or logical bytes of semantic groups | Explain aggregation and drill-down |
| Connections | Relationships among grouped dimensions | Readable labels and an obvious return to exact results |

Activating a semantic group filters into a list. **Back to map** or **Back to tag tree** restores the prior query/presentation; global Back is a separate action. Individual filter chips can be removed. Switching to a map clears hidden list-selection authority.

### Decisions and supporting tools

A retained reading is previously extracted catalogue text; opening the native viewer is an explicit new source-content request. Their presentation must distinguish them. Real folders can become buckets; semantic groups cannot impersonate physical folders.

Tag correction offers owner/project/family/role/lifecycle and a note. Blank fields keep decisions; “Unassigned” clears a category. Corrections stay private and preserve original evidence. A folder correction affects that exact path, so an active child project need not inherit a historic parent's archive lifecycle.

Collections save a semantic query/presentation without duplicating data. Rules save a proposal query with a chosen destination and optional output-name change. Rules run only on request, show exact pairs/held items, and do not override manual assignments or silently copy.

### States and design opportunities

Specify loading, unavailable dataset, no matches, restrictive filters, multiple selection, missing/partial reading, protected observations, no chosen destination and held source actions. Empty results must distinguish an empty catalogue from an overly narrow intersection. Mixed tags should be presented honestly for multiselection.

Reduce density through clear grouping and selective disclosure. Give tags a consistent pill vocabulary with readable labels; a human-decision marker could distinguish corrections from inference. Reading status and confidence should be understandable without filling rows with raw metadata. Maps need equivalent keyboard/list/tree paths. Keep the proposed destination immediately beside the action using it.

## 4. Structure: the organization workshop

![Current Structure](../assets/screenshots/light-structure.png)

### Purpose and panels

Structure is a virtual workbench. Users experiment with names, hierarchy and assignments before creating output. Changes affect a private draft while original files remain where they are.

The header explains the task with Tips/Guide. A resizable split workspace contains the destination outline, source browsing and draft/context:

- **Destination tree:** marked “Virtual until you approve a copy,” with New, Rename, Remove and Undo draft edit.
- **Sources:** familiar/chosen/catalogue scopes, search, source location, paged rows and assignment controls.
- **Draft/context:** chosen destination/output context, assignments, counts and inspection; detailed Review is the next dedicated page.

Nodes have stable identities. Renaming/reparenting changes the proposed path while retaining assignments to that node. New-folder dialogs choose a parent or top level and hold invalid names or duplicate siblings.

### Drops, buckets and authority

A **drop** assigns an individual file. A **bucket** assigns a physical folder with its internal hierarchy intact. Sources can be dragged to a destination or assigned through explicit selection controls. Dragging destination nodes reparents the virtual tree; the two drag types need different feedback.

Assignments store exact source paths and destination identities. Output names can change independently of source names in Review. Draft Undo reverses decisions and does not promise filesystem rollback.

### States and design opportunities

Show no destination, selected branch, valid/invalid drag target, duplicate sibling, cyclic reparenting, empty/populated draft, missing output and invalidated verification. Invalid edits need local explanations. A selected destination should expose its full proposed path; a drag hover should show count, bucket meaning and exact target.

This is the strongest setting for an organizing-workshop aesthetic: friendly folders, subtle branch colors, generous targets and an optional companion. Keep existing/proposed paths distinct. Make parent choice and reparenting understandable without drag-and-drop. Consider a compact breadcrumb and an assignment tray explaining “these sources will be copied here,” while retaining native outlines and keyboard efficiency.

## 5. Review: exact proposal and approval

![Current verified Review](../assets/screenshots/light-review-verified.png)

### Purpose and hierarchy

Review is the trust center. It turns decisions into exact source-to-destination pairs and separates an unverified draft from a checked copy proposal. Warmth is welcome, but data/action hierarchy must be precise.

The central summary reports assignments and verification state, while a separate right-hand column explains verification, preview history, output context and deliberate copy approval. The searchable left list shows output names and virtual destinations. Main details show **source retained** and **proposed destination** as side-by-side selectable full-path cards. The manifest inspector explains unverified folder contents or displays checked records in pages of 200, including full paths and SHA-256 values.

Actions edit structure, rename output, remove an assignment, view the source, choose output, verify, export the complete manifest, open receipts and **Review & copy**. Removing a draft row does not delete a source.

### Verification versus copying

Verification traverses eligible sources, checks full hashes, collisions, destination suitability and capacity. It creates no approved output. Copy approval is a separate confirmation, repeats current checks and records a durable receipt. Originals remain intact. Publication is per verified bucket rather than a whole-batch rollback transaction.

Design distinct states for empty draft, filtered-out results, unverified, verifying, held/failed, verified, invalidated, copying, completed and interrupted/recoverable. A green badge must state its verification meaning rather than simply saying “safe.” Draft changes invalidate previous verification.

### Design direction

Make the progression from selection to proposed output to verified evidence obvious. Use a source/destination comparison pattern with full readable paths and persistent counts. Long paths need selection, wrapping or deliberate expansion, not unrecoverable ellipsis.

Show what verification is checking. Explain disabled actions where they occur. Keep deliberate copy approval separate from draft edits. A charming completed state is appropriate only after the receipt proves completion; it cannot imply deletion of originals or an independent backup.

## 6. Rich file/folder viewer: contextual inspection

![Current folder viewer](../assets/screenshots/light-folder-viewer.png)

![Current thumbnail gallery](../assets/screenshots/light-folder-thumbnails.png)

This detail page receives one exact source from Content, Storage or Review. It has the shared shell, heading/path, utility row, left browser and right read-only metadata plus native Quick Look. It never changes placement intent.

For folders, the browser switches between paged list and gallery, with local name filtering, Parent and paging. Initial browsing reads metadata and uses system icons. **Load up to 24 thumbnails** explicitly requests content, three at a time. Held, unsupported or oversized sources keep icons.

The inspector shows current type, logical size, identity and modified date, then **View file contents** and the macOS provider. Selecting a child reads metadata; explicit opening previews a file or enters a folder. Supported PDF/image/text/office/audio/video formats depend on system providers. Quick Look is viewing, not a universal editor or redaction engine.

Utilities refresh metadata, map the folder, open the recorded tree, clear contents and reveal in Finder. Leaving clears content representations while retaining navigation context. Map handoff observes metadata; the tree handoff uses retained evidence.

Design a generous preview surface and useful held/unsupported placeholders. Distinguish metadata from body content and selected from hovered cards. A compact single-file layout should avoid wasting half a window on an empty folder list. Charming type illustrations may explain missing previews, but must communicate actual limitations.

## Supporting surfaces

| Surface | Contents | Design emphasis |
|---|---|---|
| Scan comparison | Two retained snapshots and complete paged metadata changes | Clear baseline/current; no byte-difference claims |
| Duplicate evidence | Equal-size candidates and explicit bounded proof | Candidate versus proven equality; no automatic deletion |
| Volume context | APFS/container and snapshot observations | Totals differ from reclaimable capacity |
| Scan filters / masks | New-scan inclusion versus existing-map visibility | Omitted records differ from hidden areas |
| Tag correction | Five semantic fields, rationale, reset/undo | Mixed values; blank versus cleared |
| Collections | Save, open or remove a query/presentation | No source duplication or movement |
| Rules | Save query/destination and preview exact proposal | Requested execution; human decisions prevail |
| New folder | Parent picker and validated name | Virtual status and proposed path |
| Preferences | Landing page and scan/navigation defaults | Group by user intent; reversible changes |
| Welcome guide | Eight pages explaining authority/evidence/drops/buckets/copying | Short illustrated concepts and visible navigation |
| Copy confirmation | Exact approved plan and retained-source explanation | Deliberate approval and accessible Cancel |

## Visual system and further design deliverables

Version 0.5.1 ships shared pastel surfaces, rounded panels, system typography, local kitten illustrations and clearer five-page layouts. Build on those native components. The following recommendations extend the system across more states and interactions; they are not a claim that every detail already ships:

- Quiet neutrals with soft teal/lavender/apricot accents; status needs text and contrast in both appearances.
- Consistent radius/spacing tokens; preserve recognizable native fields, menus and file panels.
- Readable system typography; monospace for paths/hashes/identity, with technical depth on demand.
- One restrained companion vocabulary for onboarding, empty and completed states; crisp data surfaces.
- Short orientation-preserving motion with Reduce Motion alternatives; no fake progress or blocking animations.
- Concrete action verbs—Browse, Inspect, Assign, Verify, Copy—and friendly explanations at decision points.

Deliver annotated wide/compact layouts for all five views and the rich viewer; a component/state library; light/dark tokens; focus/keyboard specifications; reduced-motion behavior; and an illustrated first-collection journey. Include missing data, access barriers, changed sources and partial operations, not only ideal populated screens.

Evaluate whether a first-time user can choose a tool, identify evidence freshness, find a family collection, correct context, choose a destination, edit a virtual hierarchy, return from a preview, read exact paths and explain verification versus approval. Repeat using keyboard navigation and compact layout. Measure completion, wrong-action attempts, context-recovery time, path-reading accuracy and perceived confidence. Establish a baseline before setting numerical targets. Validate VoiceOver, contrast and focus; existing native labels are a foundation rather than an accessibility certification.

The desired result is a lovable tool whose kindness comes from clarity and control as much as visual charm.

The discovery journey now keeps the destination/Review actions visible below scrolling evidence. Classification refresh retains matching selections and explicit destination choices. Loading, no-match and held views are first-class states; the complete pre-assignment destinations dialog belongs to this journey. Preserve these states when refining the visual design.

## Content focus variant

The compact top bar keeps six visualization choices, density/Fit when applicable, Preview, Sources, Inspector, focus exit and native full screen. Below it, the dataset and retained-search controls stay present, followed by scope, removable filters, results and bounded paging. The optional Sources rail exposes familiar scopes and semantic dimensions. The optional Inspector rail combines exact source, explicit Quick Look, retained evidence, human classification, chosen draft destination and exact placement actions. A Storage handoff strip carries one explicitly chosen source independently of a page; its label must never imply that a hidden semantic group is an assignable folder. Loading/error states distinguish unavailable observations from empty successful results.

Visual balance comes from the current content itself. Focus suppresses decorative page chrome to maximize usable area while maintaining navigation and trust controls. Dense galleries use smaller cards; large cards increase their preview region. Physical and semantic map contexts remain distinct, and copying remains a separate Review approval.
