# Design destinations before changing files

The Structure page combines a virtual destination tree, a bounded source browser and a draft placement summary. Your destination folders do not have to exist yet. Editing this tree is a planning activity.

<figure markdown>
![Structure page with virtual destinations, synthetic source files and exact draft pane](../assets/screenshots/light-structure.png)
<figcaption>Left: the target hierarchy. Middle: source files and coherent buckets. Right: draft placements. None has moved.</figcaption>
</figure>

## A useful starting hierarchy

```text
00 Inbox
  To sort
10 Projects
  Organization / Active project
  Client work / Confirmed project
  Personal / Confirmed project
20 Areas
  Organization / Finance, Legal, Operations, Branding
  Personal / Administration, Finance, Health
30 Resources
  Research & Learning
  Books & Templates
  Design & Fabrication
  Personal collections / Cinema
40 Archive
  Organization / Closed project or past venture
  Personal / Family memories
90 Review
  Unclassified
  Collisions
  Reading exceptions
```

Projects have a defined outcome. Areas are continuing responsibilities. Resources are reusable knowledge or collections. Archive holds inactive work and preserved history. Inbox is genuinely undecided intake, not a dumping ground for every file with a certain format. Review holds decisions and exceptions requiring attention.

## Edit a virtual hierarchy

**New destination** offers an explicit parent selector and name. Rename updates the draft node while preserving its ID. Remove is held for nodes that still have children or assignments. Draft Undo is session-local and restores previous planning state.

<figure markdown>
![Native new virtual destination dialog with parent selector and name validation](../assets/screenshots/light-new-folder.png)
<figcaption>The dialog creates a draft node, not a filesystem directory. Case/Unicode sibling collisions are refused.</figcaption>
</figure>

Folder names cannot contain traversal, slash, colon or NUL characters. Sibling collisions are normalized for Unicode and case. Keep below 500 destinations and at most 100 assignments; this is an intentional reviewable planning surface.

## Drops and buckets

A **drop** is an individual source file. A **bucket** is a coherent source folder whose contents stay together. Drag a Finder file/folder onto the destination you know, or select a source and assign it to the highlighted node. Dragging a virtual node changes its parent within the draft only.

Manual assignment preserves the exact selected path. A source already assigned elsewhere is reassigned rather than duplicated; its chosen output name stays intact. Renaming the output affects the copy’s name, not the source. Parent/child overlap, unsafe paths, managed collections and destination collisions are held during verification.

Preserve repositories, application libraries and managed data in their operational structure. General file organization is not a migration tool for app internals or source workspaces. Whole folder coherence matters more than visually tidy categories.
