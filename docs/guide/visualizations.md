# Slice the same evidence in different ways

A physical hierarchy describes storage location. A tag hierarchy describes meaning. A treemap emphasizes weight. A relationship map describes intersections. Each is useful for a different question; none can infer the meaning of a file solely from its extension.

## Physical folder tree

<figure markdown>
![Content Explorer physical folder tree for the invented source library](../assets/screenshots/light-content-folder-tree.png)
<figcaption>Expand retained roots and directories lazily. Folder-tree scope is physical; semantic intersections apply to lists and maps.</figcaption>
</figure>

Physical folders are loaded from retained metadata, not recursively materialized in RAM. Select a real source to inspect it; open a folder to list its children. A folder bucket preserves its internal cohesion when explicitly assigned.

## Semantic tag tree

<figure markdown>
![Content Explorer owner-to-project-to-family semantic hierarchy](../assets/screenshots/light-content-tag-tree.png)
<figcaption>Owner → project → family describes context independently of physical location. Group nodes are queries; they are not source folders.</figcaption>
</figure>

Double-click a group to list its real source observations. Choose those real files/folders for assignment. The application does not copy a category label or fabricate a folder from a tag node.

## Content treemap

<figure markdown>
![Content Explorer semantic treemap grouped by owner](../assets/screenshots/light-content-treemap.png)
<figcaption>Choose a facet dimension and weight by entries or logical file bytes. Drill into a tile and use Back to map to restore the exact prior context.</figcaption>
</figure>

The saved drill context includes folder, query, search mode, filters, view, facet dimension and metric. Changing to a map disables hidden list-selection actions until a real source is selected again.

## Connections

<figure markdown>
![Content Explorer connections between owner, project and content family](../assets/screenshots/light-content-connections.png)
<figcaption>The relationship view uses the top twelve groups on each axis; complete categories remain in the facet list.</figcaption>
</figure>

Edges count matching retained observations, not causal relationships or verified ownership. Use them to discover intersections, then narrow the real source list and inspect provenance. Do not mistake this bounded diagram for an exhaustive knowledge graph.

## Choose a view deliberately

| Question | Useful view |
|---|---|
| Where is a known collection physically stored? | Folder tree |
| How do owner/project/type classifications intersect? | Tag tree or Connections |
| Which semantic category contains the most records or bytes? | Content treemap |
| What dominates allocation under a physical root? | Disk Lens |
| What exactly will be copied? | Review inventory |

See [native UI design](../developer/ui.md) and [query conservation](../developer/performance.md).

## Gallery

The sixth Content visualization presents exact observations as cards. System icons require no thumbnail request; **Load 24 thumbnails** is an explicit bounded content action. Selection shares the same authority as List. Full current-source inspection remains available in the [native viewer](previews.md).
