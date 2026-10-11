# Your first session

## Before starting

KonMagic is a native macOS 13+ application. The repository currently supplies a source build and local ad-hoc installation, not a notarized downloadable release. Follow the [developer quickstart](../developer/quickstart.md) to build it. A local installation creates `~/Applications/KonMagic.app` and a Desktop shortcut while retaining an older bundle.

You can browse ordinary folders without an Atlas catalogue. To use retained tags, readings and whole-disk observations, choose **File → Connect catalogue…** and select a compatible folder containing `catalog.sqlite3`; the recorded disk adapter expects `disk-coverage.sqlite3` beside it. These databases are opened read-only. Connecting a folder does not create a new body-ingestion pipeline.

The application needs whatever filesystem access macOS permits. A denied folder becomes a hold or coverage exception. Do not grant broad access simply to bypass an operational or credential hold: those rules are independent of macOS permissions.

## Start with a familiar collection

1. Open **Toolkit** with ⌘0. Check whether the catalogue is available and when the disk observation was recorded.
2. Open **Content** with ⌘2. Select a known folder or All retained content, then search or choose a facet.
3. Read the selected observation’s tags, provenance and barriers. Use **Correct tags…** if the personal context is wrong.
4. Open **Structure** with ⌘3. Create or refine a virtual destination under Projects, Areas, Resources or Archive.
5. Return to Content and choose that destination. Check the proposed full path before assigning a file or a whole folder.
6. Open **Review** with ⌘4. Confirm each source → destination pair and the output name. No source has moved.
7. Choose a local output folder with sufficient capacity. **Verify exact preview** checks current sources, collisions, hashes and capacity without creating destination folders.
8. Inspect the verified inventory. Only **Review & copy** and its separate confirmation authorize creation of output copies.

<figure markdown>
![Toolkit overview with coverage and four workflow stages](../assets/screenshots/light-toolkit.png)
<figcaption>Use the stages or keyboard routes. The guidance strip changes with your current page and draft context.</figcaption>
</figure>

## Keep the distinctions visible

**Recorded** means an observation from a prior scan. **Tagged** means a catalogue classification with provenance, possibly overridden by a private personal correction. **Assigned** means a draft placement. **Verified** means a complete bounded source inventory and hashes were checked at a particular time. **Copied** means a separately approved output operation has a receipt. None of these states implies that an original is safe to delete.

The structure is virtual until approved copying. Undo draft edits changes your decisions, not the filesystem. Corrections do not rename files or write Finder tags. Exported plans and scans can contain private paths: store them privately.

## Getting help

Use **Tips** for a short explanation in the app, the **Welcome guide** for its eight-page introduction, and **Help → Help for This Page** for this illustrated manual. Web documentation requires network access; the native guide remains local.
