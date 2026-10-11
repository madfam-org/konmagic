# Native preview architecture

`SourcePreviewController` is a detail page with its own controller/view lifetime, embedded by `PageHostController.showDetail`. Content, Review and Disk Lens route an exact source path into it. A pop-out creates another controller using the same decision stores, never reparents the original Quick Look view.

## Metadata gate

`SourcePreviewSafety.inspect` uses the production ordinary-user-content eligibility policy, checks protected ancestry, opens the parent with no-follow descriptors, reads entry metadata without following links, refuses non-ordinary and cloud-only sources, and optionally compares a complete current `Identity`. It reads no file body.

The synthetic `allowFixture` is used only by documentation/native test entry points. Production launch buttons do not pass it. The tests cover eligible synthetic file/folder metadata, production refusal of test roots, leaf/ancestor symlinks, protected names, unchanged identity and changed identity.

## Two explicit content paths

**File viewing:** a background metadata check followed by an explicit `QLPreviewView.previewItem` request. Selecting a child only updates metadata; a file-view action rechecks the recorded identity and global transfer hold before requesting content. `autostarts` is disabled so a media provider does not deliberately start playback merely on navigation.

**Gallery thumbnails:** explicit request for the first 24 regular files on the current page, three in flight. Metadata/protection checks run on the viewer’s queue; native QuickLookThumbnailing generates a 130×80-point representation at scale two. Files over 128 MiB are skipped, unsupported representations retain icons, and a 15-second per-provider request timeout cancels outstanding generation. Images live in memory in this view, not a newly persisted app thumbnail database.

The system APIs are [QLThumbnailGenerator](https://developer.apple.com/documentation/quicklookthumbnailing/qlthumbnailgenerator) and its [Request](https://developer.apple.com/documentation/quicklookthumbnailing/qlthumbnailgenerator/request). The framework is an Apple dependency available on the supported macOS target, not a downloaded runtime package.

## Lifecycle and race limits

Generation counters discard superseded metadata results. Thumbnail tokens, request identities and cancellation prevent late callbacks from reintroducing cleared images or decrementing a new batch’s counters. Thumbnail completion updates AppKit only on the main queue. A Clear action cancels work and empties the embedded preview; navigating away clears body/thumbnail representations as well.

PageEntry includes the viewer’s activity in shared observation status and safe closure. Copy/verify state is checked before content requests and after asynchronous metadata checks. Source selection is resolved from the exact clicked row for double-clicks rather than a potentially stale inspector selection.

Quick Look and thumbnail providers receive URLs, not pinned descriptors. A filesystem race remains possible between checking metadata and the system provider opening the URL. Do not describe preview as full-hash proof, guaranteed isolation, a deletion check or a way to bypass cloud/managed barriers. The stronger copy verification path remains separate.

## Folder and draft visualization

The viewer browses current children through bounded `Catalog.liveFolder` pages, with a direct-name enumeration guard of 100,000. Icons are inexpensive system representations; body thumbnails require explicit action. Tree handoff uses the retained disk ledger; map handoff uses a fresh metadata scan. Neither manufactures a complete reading claim.

Virtual destination Structure and exact Review inventory remain the previsualization of organizational intent. A current source viewer never changes that intent. Changing tags/destinations or preparing a copy stays in the respective guarded workflow.
