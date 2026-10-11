# Native interface and accessibility conventions

AppKit owns controls, tables, outlines, panels, popovers, text editing and window behavior. The app targets macOS 13 and retains compatible APIs for older toolchains; it does not claim the latest macOS visual style merely because it runs on a newer OS.

## Journey hierarchy

The Toolkit’s four cards explain Observe → Discover → Shape → Review. Each page has a persistent navigation/guidance header, a focused task surface and contextual help. Advanced Disk Lens actions are grouped in More tools. Keep destructive or privacy-relevant details at their actual decision point.

Prefer user language such as “exact destination” and “retained reading” to internal type names. Explain whether an operation observes, edits a private draft, reads bodies for proof, or creates output. Status labels must distinguish loading, historical data, protected holds, unverified assignments and verified plans.

## Controls and layout

Use native labels and system colors/fonts, SF Symbols with accessibility context, concise action titles, selectable full paths, and tooltips when text can truncate. Tables page rather than creating millions of rows. Outline nodes have stable IDs. Summary cards can wrap, while exact paths and hashes use readable monospace text.

Content filter chips remove one dimension at a time. Map views disable hidden list actions. Review uses a dedicated full inventory and visible output root; the verify/copy boundary must remain obvious. Folder editing includes explicit parent choice and feedback.

Minimum canvas sizes are per page. PageViewport preserves scrolling in compact windows; do not clip important controls or reset a cached page’s viewport. Screenshot validation should include compact and full-size layouts and both appearances.

## Accessibility

Native text fields/buttons retain keyboard focus and normal edit behavior. Important controls expose accessibility labels or tooltips. Full paths and inventory text are selectable. System colors follow Aqua/Dark Aqua. No meaning should rely solely on a treemap color.

These conventions do not constitute a completed VoiceOver or WCAG certification. Manual accessibility auditing remains a roadmap item: traversal order, announcement clarity, VoiceOver tree navigation, contrast under all palettes, increased contrast/reduced motion settings and every modal cancellation route need systematic review.

## Public visual evidence

The [screenshot atlas](../reference/screenshots.md) shows native views and dialogs using an isolated invented library. Its capture mode never reads the user’s real catalogue, never captures another application or the desktop, and never approves copying. Images are not visual mockups of features that do not exist.

[State ownership](navigation.md) explains multi-window constraints; [acceptance workflows](../UI-workflows.md) explain the required journeys.

## 0.5.0 visual system

`FriendlyUI.swift` centralizes appearance-aware ink, surfaces, pastel accents, native buttons, rounded panels, metrics and packaged illustrations. Text and file decisions remain AppKit controls; artwork is decorative and carries no labels, catalogue values or controls. Assets load locally from bundle resources (or the build resource directory for acceptance modes). There is no runtime asset fetch.

Toolkit separates coverage from task selection. Storage separates snapshot context, map controls and exact source detail. Content adds a page-bounded gallery and opt-in native thumbnails; `ContentGallery` updates image views in place rather than recreating every card per result. Structure preserves native split panes and stable destination identities. Review distinguishes verification, preview history and deliberate approval. Secondary windows retain independent browsing and one shared private draft.

Wide canvases remain scrollable in compact windows. Dense inspectors have their own scrolling/disclosure. Existing stored palette/color choices are not migrated automatically. Keyboard routes and native focus behavior are preserved; decorative motion is not added.

The primary action pills remain `NSButton` instances with normal target/action and native focus behavior. Decorative drawing changes their surface, not their source authority. Base palette calculations for white labels on the five light action fills yield contrast ratios of 4.80 (teal), 5.94 (violet), 4.56 (orange), 5.02 (green) and 5.58 (pink). Secondary ink on the white surface is 5.59; dark secondary ink on the dark surface is 7.82. These measurements cover the specified color pairs, not a certification of every rendered control, palette or accessibility setting.
