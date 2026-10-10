# macOS alternatives and capability priorities

Checked 2026-10-10 against official vendor documentation and upstream projects.
This is a representative benchmark, not an exhaustive registry or proof of
identical behavior, performance or maturity. Alternatives were not installed or
measured on a common dataset. Advertised OS requirements are not independent
certification on a particular machine.

KonMagic's baseline is its native source, synthetic checks and documented
[GrandPerspective contract](GrandPerspective-capabilities.md). Copy verification
is not duplicate discovery; inode accounting is not content equality; metadata
comparison is not bytewise diff; draft undo is not filesystem rollback; original
retention is not an independently stored backup.

## Task-level comparison

| Job | Primary benchmarks | KonMagic overlap | Remaining capability |
| --- | --- | --- | --- |
| Disk observation | [GrandPerspective](https://grandperspectiv.sourceforge.net/), [DaisyDisk](https://daisydiskapp.com/specs/), [OpenDisk](https://github.com/137137137/OpenDisk), [Radix](https://github.com/colinvkim/Radix), [Neodisk](https://github.com/tkslucas/Neodisk) | Hierarchy treemap, size measures, packages, colors, filters/masks, scans and exports | Sunburst/icicle, foreign formats, all package declarations, translations and APFS accounting; source Trash held |
| Catalogue/retrieval | [NeoFinder](https://www.cdfinder.de/), [HoudahSpot](https://www.houdah.com/houdahSpot/), [TagSpaces](https://www.tagspaces.org/products/) | Retained catalogue, facets, tag tree, indexed content and relationships | Stable volume identity, editable portable tags, saved collections, galleries and maintained ingestion |
| Fresh content search | [Find Any File](https://findanyfile.app/), [Recoll](https://recoll.org/pages/recoll-macos.html), [DocFetcher](https://docfetcher.sourceforge.io/) | Native metadata browsing and retained full-text search | Fresh extractors, archive/email/OCR pipeline, fuzzy/proximity tools and persistent content refresh |
| Specialized libraries | [DEVONthink](https://www.devontechnologies.com/apps/devonthink), [Eagle](https://eagle.cool/), [Zotero](https://www.zotero.org/) | Tags, cached content, explicit previews and drafts | Notes/OCR/versioning, creative asset workflows and bibliographic/PDF annotations |
| File management | [Fileside](https://www.fileside.app/), [ForkLift](https://binarynights.com/), [Nimble Commander](https://magnumbytes.com/), [fman](https://github.com/mherrmann/fman) | Native browsing, assignment drafts, preview and verified copy | Saved physical panes, archive/remote clients, queues, rename recipes and filesystem undo |
| Organization rules | [Hazel](https://www.noodlesoft.com/), [Folder Tidy](https://www.tunabellysoftware.com/folder_tidy/), [organize](https://github.com/tfeldmann/organize) | Predicates, human-chosen destinations and exact previews | Reusable condition-to-proposal rules, explanations and simulations; unattended source mutation held |
| Naming | [A Better Finder Rename](https://www.publicspace.net/ABetterFinderRename/), [Name Mangler](https://manytricks.com/namemangler/), [Renamer](https://renamer.com/mac) | Manual output naming, stable destination IDs and collision checks | Chained transformations, metadata/CSV recipes, intermediate previews and companion-file naming |
| Duplicates | [dupeGuru](https://github.com/arsenetar/dupeguru), [Czkawka/Krokiet](https://github.com/qarmin/czkawka), [PhotoSweeper](https://overmacs.com/), [Gemini](https://macpaw.com/gemini) | Metadata evidence and copy hashes | Fresh hash/byte proof, keeper locks, perceptual similarity and library-aware review |
| Compare/sync | [FreeFileSync](https://freefilesync.org/faq.php), [ChronoSync](https://www.econtechnologies.com/product/chronosync/), [Beyond Compare](https://www.scootersoftware.com/), [Syncthing](https://syncthing.net/) | Metadata snapshot changes and manual verified copies | Paged all-changes UI, byte/content diff, sync/conflicts and scheduled versioned tasks |
| Uninstall inventory | [AppCleaner](https://freemacsoft.net/appcleaner/), [Pearcleaner](https://github.com/alienator88/Pearcleaner) | App/operational-collection protection | Reusable app/support-file ownership graph; one-off retirement scripts are not a shipped uninstaller |
| Storage accounting | [Apple Disk Utility](https://support.apple.com/guide/disk-utility/view-apfs-snapshots-dskuf82354dc/mac) | Capacity when observed, logical versus allocated metadata | Container/snapshot/shared-block/purgeable context; allocated blocks are not exact reclaimability |
| Backup/health | [Time Machine](https://support.apple.com/guide/mac-help/back-up-files-mh35860/mac), [CCC](https://bombich.com/), [restic](https://restic.net/), [DriveDx](https://binaryfruit.com/drivedx), [smartmontools](https://github.com/smartmontools/smartmontools) | Original retention, capacity guards and integrity checks | Independent versioned backup/restore and hardware telemetry belong to specialist engines |

## Licensing and availability distinctions

- Free proprietary, source-available and open source are separate labels.
  [TagSpaces](https://www.tagspaces.org/faq/) Lite is AGPL; Pro is closed source.
  [Pearcleaner](https://github.com/alienator88/Pearcleaner) uses Apache 2 plus
  Commons Clause terms and describes development on hold.
- [Czkawka's FAQ](https://github.com/qarmin/czkawka/blob/master/instructions/FAQ.md)
  separates MIT components from the complete GPL Krokiet GUI. Public visibility
  alone does not make source code compatible with an MIT application.
- [FreeFileSync's FAQ](https://freefilesync.org/faq.php) restricts its free
  official binaries to private personal use and requires Business licensing for
  commercial entities. Published source/GPL project branding is separate; the
  current source archive's complete terms were not re-audited here.
- [fman](https://github.com/mherrmann/fman) now publishes MIT source and current
  macOS fixes. [Spacedrive](https://github.com/spacedriveapp/spacedrive) is in a
  pre-release transition; upstream and its separately presented commercial
  rewrite are not one verified stable Mac product.
- Original [Disk Inventory X](https://www.derlien.com/) documents support through
  Catalina; community revivals do not certify the original. [Spacie](https://github.com/AlexGladkov/Spacie)
  is Apple Silicon-only with non-commercial source terms.
- [OnyX](https://titanium-software.fr/en/onyx.html) requires an exact OS-specific
  build. Recheck architecture, edition, terms and maintenance before adoption.

## Recommended sequence

1. Reconcile scope, exceptions, current identity and counts in every view.
2. Add a reversible human-tag overlay, provenance and saved collections.
3. Improve source shelves, destination completion, bucket review and recovery.
4. Add read-only APFS/snapshot context before estimating recovered space.
5. Build scoped duplicate proof and keeper review; separate similar media.
6. Add explainable rule simulations and copied-output naming recipes.
7. Add alternate maps/gallery/timeline over the same evidence and selection.
8. Close format/localization/accessibility gaps, then maintain Developer ID
   signing, notarization and trusted updates.
9. Integrate optional specialist status instead of recreating every backup,
   cleaner, hardware monitor, remote client and repair engine.

## Quantitative release evidence

Measure cold/warm queries, map first paint, cancellation, peak RSS, CPU, I/O,
index size and count/weight conservation on identical datasets. Include hard
links, sparse files, packages, placeholders, inaccessible parents with accessible
descendant roots, and concurrent changes. Report index storage separately from
the app bundle. No fastest/smallest/overall-parity percentage is asserted.

Validate accessibility, keyboard paths, multilingual text and the distinction
between draft undo and source rollback. Polish alone is not performance proof.
