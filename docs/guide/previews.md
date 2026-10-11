# Rich native file and folder viewers

Use **View file / folder…** in Content, **View source…** in Review, or **File & folder viewer…** in Disk Lens. The viewer opens as an embedded page; Back restores your previous discovery or exact-review context. Open page in new window gives it an independent native surface.

The viewer inspects **current sources** rather than only retained observations. It is separate from a verified copy plan and never assigns, moves, renames or deletes data.

## Explore a folder

<figure markdown>
![Native folder viewer with paged source list, metadata and content controls](../assets/screenshots/light-folder-viewer.png)
<figcaption>Current folder children are metadata only by default. Selection exposes exact current identity without opening a file body.</figcaption>
</figure>

Browse 200-entry pages, search names within the current folder, use Parent, or double-click a folder to drill into it. A selected child shows its path, type, logical bytes, device/inode and modification time. The list is bounded; direct-directory enumeration itself has a 100,000-entry guard.

## Icon gallery and content thumbnails

<figure markdown>
![Native folder icon gallery for an invented project collection](../assets/screenshots/light-folder-gallery.png)
<figcaption>The default gallery uses system file icons. It does not silently generate original-content thumbnails.</figcaption>
</figure>

**Load up to 24 thumbnails** is an explicit original-content request. Eligible regular files on the current page are checked before macOS Quick Look Thumbnailing generates representations. At most three requests run concurrently; each generation request has a 15-second timeout. Files over 128 MiB, protected sources and cloud placeholders are held from thumbnail generation. Unsupported formats retain a system icon.

<figure markdown>
![Native gallery with explicitly requested synthetic file-content thumbnails](../assets/screenshots/light-folder-thumbnails.png)
<figcaption>The generated library includes a real invented PNG so content thumbnails can be inspected. Other example media/model files are synthetic placeholders and may retain icons.</figcaption>
</figure>

The gallery is not an exhaustive media index or perceptual classifier. **Clear contents** cancels outstanding requests and releases this view’s content representations. Leaving the viewer also clears previews/thumbnails while retaining navigation context.

## View a file

<figure markdown>
![Embedded native Quick Look viewer for an invented design brief](../assets/screenshots/light-file-viewer.png)
<figcaption>An explicit file-view action requests the original through macOS Quick Look after fresh no-follow identity/protection checks.</figcaption>
</figure>

<figure markdown>
![Embedded native image preview for a generated example PNG](../assets/screenshots/light-image-viewer.png)
<figcaption>This image is entirely generated fixture data. The available preview controls depend on the system provider and file type.</figcaption>
</figure>

Mac preview providers support many common image, PDF, text, office, audio and video formats. Actual support depends on the OS, installed providers and the file. Unsupported or malformed content can show an icon or unavailable preview. Quick Look is a viewer, not a universal editor, redaction engine or assurance that a document is semantically safe.

Selecting a folder child does not load its body. Double-clicking a file, pressing **View file contents**, or explicitly opening a file viewer does. The source is checked again against the selected current identity before a request. A changed source is held until you refresh current metadata. Thumbnail and full-file preview requests wait during verification/copy work.

These checks do not confer the descriptor-pinned, full-hash guarantee of copying: system preview providers receive a URL and can open it after the check. Previewing does not verify data hashes or approve reorganization.

## Tree and map handoff

**Recorded folder tree** carries the current physical folder into Content’s recorded dataset. Its coverage may be historical or absent. **Map this folder** launches a new bounded metadata-only Disk Lens scan. Neither action asks to read all original bodies or copy the folder.

Managed repositories/application libraries, sensitive ancestry, symlinked paths and cloud-only content remain held. Broader macOS privileges do not override this policy. [Preview implementation and safety](../developer/previews.md).

## Inline Content previews

Content’s **Preview** / **Preview here** action explicitly requests one eligible current file in its Inspector rail. Quick Look playback does not auto-start. Folders open the full metadata/folder viewer. Changing source, hiding the inspector, clearing previews or leaving Content releases obsolete inline representations. Retained excerpts remain a separate bounded catalogue read. Preview providers determine format support; viewing never establishes a full hash proof or approves a transfer.
