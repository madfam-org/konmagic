# Testing, fixtures and visual knowledge transfer

## Native safety checks

`--self-test` runs temporary synthetic model, filesystem, knowledge, catalogue and Disk Lens cases. The foundation has 135 checks, plus eight preview identity/protection checks in 0.4.2. Treat the reported runtime count as the authority after changes, rather than embedding a stale count in assertions.

Coverage includes folder validation/cohesion, authoritative assignments and Undo, source changes, links/sensitive boundaries, capacity before body reads, case/Unicode collisions, complete hashes, empty folders and metadata, exclusive copies, retained originals and durable receipts. Catalogue tests cover read-only input, keyset pages, aggregate conservation, literal FTS, canonical readings, barriers, compression and cancellation. Disk Lens tests cover allocation/hard links/packages, proportional/zero-area maps, masks, exclusions, persistence, export, comparisons and refresh.

The GitHub native workflow builds on `macos-latest` and runs these checks. UI render tests require an interactive Mac session and are not currently run by the headless Linux Pages job.

## UI acceptance modes

| Mode | Purpose |
|---|---|
| `--navigation-ui-smoke` | Five stages in one host, Back/Forward, cached views, shared decisions, pop-outs, viewport and global holds |
| `--classification-ui-smoke` | Synthetic editor save, selection/destination retention, loading/empty states and held transfers |
| `--journey-ui-smoke` | Exact assignment handoff, recycled gallery end-of-page selection, retained cards, Review empty/filtered states, output rename, map-return/chips, inventory paging and transfer holds |
| `--toolkit-ui-smoke` | Balanced cards and stage/keyboard routes |
| `--explorer-ui-smoke` | Dataset/list/tree/map views and exact assignment preview |
| `--lens-ui-smoke` | Own-view render, bounded rows and proportional map conservation |
| `--knowledge-ui-smoke` | Tag, collection, rule and preferences dialogs, cancellation and preservation |
| `--review-ui-smoke` | 601-row synthetic comparison, size-candidate review and disabled automatic hashing |
| `--ui-smoke` | Structure layout and held unverified copying |

Ordinary QA can connect real local observations. Its outputs are **always private** and must never be promoted into public docs.

## Documentation fixture

`python3 scripts/docs/create-fixture.py` creates a new owned `/private/tmp/konmagic-documentation-*` root with invented source files, an output directory, a compatible tagged catalogue, compressed disk ledger and private WorkspaceStore JSON. Media/model/image examples are explicitly synthetic placeholder data; sparse logical sizes make proportional views legible without filling a disk.

`--documentation-capture` validates the fixture marker, root, catalogue path, output and assignment sources before initializing the app. It composites only this process’s owned synthetic windows, including native alerts and Quick Look layers; it never captures the desktop or another app. Older local SDKs use the owned-window Core Graphics API, while modern toolchains use macOS screencapture with that exact window number. Capture can be unavailable under macOS privacy restrictions; the workflow fails rather than publishing an empty view. It does not change permissions. It traverses the invented source metadata, reads synthetic cached text, verifies one small synthetic plan using the explicit fixture allowance, cancels native editing dialogs, and walks all eight welcome pages. It cancels copy confirmation and never invokes approved copying. The viewer examples explicitly request only invented file/thumbnail content.

The workflow also checks folder metadata without body requests, bounded gallery/thumbnail requests, clearing then reopening native previews, and clearing stale Storage selection summaries on navigation. It captures 43 owned views per appearance, including Content before and after an explicit thumbnail request. It activates its owned window, forces display/flush, and rejects identical compositor frames for the distinct Structure and Recorded disk pages. The output folder must be new. Create a separate fixture for each appearance or rerun. The app’s production source eligibility and current-state guards are not relaxed.

## Refresh public screenshots

```sh
python3 scripts/docs/create-fixture.py
KONMAGIC_QA_STATE="<new printed State path>" \
  "$HOME/Library/Caches/KonMagic Build/KonMagic" --documentation-capture
# Capture stdout/stderr to capture-light.log in the fixture root.
# Repeat with a new fixture and KONMAGIC_QA_APPEARANCE=dark; use capture-dark.log.
python3 scripts/docs/promote-screenshots.py "<fixture root>" --appearance light --reviewed
python3 scripts/docs/generate-reference.py
mkdocs build --strict
python3 scripts/docs/check-site.py
```

Inspect every output for legibility and private-data leaks. Promote only this workflow’s images into `docs/assets/screenshots/`, recording hashes, fixture origin, view, appearance, app version and caption in `manifest.json`. Do not reuse the normal QA screenshots. Comparison/duplicate acceptance captures use a separate synthetic fixture and a clearly described 601-record metadata dataset.

`generate-reference.py` rebuilds the gallery/source symbol index. `check-site.py` checks manifest hashes, image provenance fields, local links/anchors, declared app help routes and prohibited private path strings. Visual inspection remains required; a text scanner cannot prove screenshot privacy or usability on its own.

Modal capture timers run in `.modalPanel` run-loop mode so they execute inside AppKit modal loops. A dispatched main-queue timer alone can stall behind `runModal`. Capture owned view caches rather than the entire desktop; newer Swift SDKs remove older window-capture APIs.
