# State ownership and single-window navigation

`KonMagicPage` defines the five primary pages and minimum canvas sizes. `KonMagicNavigation` coordinates a primary host and optional additional hosts. Each host caches controllers and owns a physical viewport, history and current page; all workspaces use the same `WorkspaceStore` and `KnowledgeStore` objects.

Never construct a second on-disk state store for another window. Never mount one `NSView` in two windows. Additional windows get separate controllers backed by shared decisions. These rules prevent lost writes, view reparenting and inconsistent approvals.

## Active command routing

The active host is the key window’s page host, then the main window’s host, then the primary host. This fallback matters while a native modal panel or Quick Look holds key-window status. File/Window/Help menu commands route through navigation to the active workspace instead of always acting on the original controller.

Content pop-outs clone dataset, folder, facets, query, search mode, visualization, dimension and metric. Storage pop-outs clone view preferences, store, mask and focus. Local Structure/Review search and selection are not comprehensively cloned; shared assignments and destination decisions are.

## Mutation propagation

`refreshDraft()` walks the hosts, invalidates plans whose workspace hash differs, refreshes draft UI and activity. `knowledgeChanged()` invalidates plans, refreshes effective tags and updates loaded explorers/source pages. `connectCatalogue()` gives each workspace the same compatible reader and refreshes loaded overview views.

`transferBusy` aggregates all workspaces; confirmation and execution recheck it. A secondary window cannot mutate the shared draft while another window’s transfer is active. `observationBusy` tracks scans and proof work for closure/termination handling.

## Selection and context

Destination IDs are stable through rename/reparent. `focusedDestinationID` carries an explicit destination between discovery, folder editing and review. Structure selection refresh guards prevent a background reload from overwriting that choice. Assignment handoff selects the same exact sources in Review.

`ExplorerDrillContext` retains the exact discovery state before map/tag drilling. Back to map restores it rather than rebuilding a vaguely similar query. Hidden list selections cannot act while maps are displayed.

## Viewport trap

`PageViewport` uses a flipped document with manual sizing and minimum canvas bounds. Preserve each cached viewport offset. Pinning a document’s top/leading edge to `NSClipView` with Auto Layout can reset scrolling; avoid reintroducing this regression. Toolkit has its own vertical scroll document.

Back/Forward history is bounded to 32 entries. Closing an additional host detaches its controller/window to break ownership cycles. Running jobs prevent unsafe closure. Dock reopen raises the primary window without resetting its page.

The [navigation UI checks](testing.md) cover host identity, secondary/tertiary windows, retained queries, global holds, invalidated plans and viewport scrolling.
