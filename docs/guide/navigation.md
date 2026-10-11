# One window, with independent views when useful

The primary window hosts Toolkit, Storage, Content, Structure and Review. The page header offers Back, Forward and Open page in new window. Navigation caches page controllers so searching, selection and drill context can survive a round trip through another stage.

Additional windows share the same private draft and knowledge decisions. Their controllers and physical views are separate; their queries and storage focus can be independent. Content and Storage copy their relevant discovery context when opened separately. Structure and Review share decisions, but not every local selection or search is cloned.

## Keyboard routes

| Shortcut | Action |
|---|---|
| ⌘0 | Toolkit |
| ⌘1 | Storage |
| ⌘2 or ⌘E | Content Explorer |
| ⌘3 | Structure |
| ⌘4 | Review |
| ⌘D | Disk Lens |
| ⌘[ / ⌘] | Back / Forward |
| ⇧⌘N | Open current page in another window |
| ⌘O | Choose a source folder |
| ⌘P | Verify exact preview |
| ⌘Z | Undo draft edit |
| ⌘, | Preferences |
| ⇧⌘/ | Web help for the current page |
| ⌘M / ⌘Q | Minimize / Quit |

Space in Disk Lens requests checked Quick Look. Native text fields support normal editing commands. A keyboard route that changes the draft is held during an active transfer. Navigation into another view does not cancel or conceal a running job; the shared activity strip leads back to its page.

## Preferences

<figure markdown>
![Native KonMagic preferences for last-window behavior and prior-view retention](../assets/screenshots/light-preferences.png)
<figcaption>Preferences are stored privately. Appearance follows native AppKit; screenshots demonstrate both Aqua and Dark Aqua.</figcaption>
</figure>

Choose whether closing the last window quits, presents the welcome guide, or keeps the app running. Choose whether a rescan retains a separate prior-view window. Closing or terminating a running scan/transfer is held so partial observations and copy receipts can be handled deliberately.

Large workspaces retain a minimum internal page canvas. Smaller windows expose scroll navigation rather than crushing controls. The Toolkit owns a vertical scroll surface; other pages preserve their viewport positions per host.

For implementation ownership and invariants, see [state and navigation](../developer/navigation.md).
