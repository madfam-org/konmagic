# Documentation as a maintained product

The site uses MkDocs Material, source Markdown under `docs/`, a pinned docs-only Python environment and GitHub Pages. It is independent of the native app runtime. No analytics, remote font dependency or personal catalogue integration is configured. Browser search indexes the public documentation only.

## Site layout

| Path | Purpose |
|---|---|
| `mkdocs.yml` | Navigation, theme, local font stack, search and build output |
| `docs/guide/` | Illustrated task walkthroughs and troubleshooting |
| `docs/developer/` | Architecture, data boundaries, development and operations |
| `docs/reference/` | Formats, limits, symbols, gallery and capability status |
| `docs/assets/screenshots/` | Reviewed synthetic native screenshots and hash manifest |
| `scripts/docs/` | Pinned requirements, fixture creation, generated references and validation |
| `.github/workflows/docs.yml` | Build/validate and GitHub Pages deployment |

Build output goes into ignored `.build/docs-site`; generated site files are not committed. `generate-reference.py` creates source-linked declaration indexes and the screenshot atlas from current sources/manifest. It is a declaration index, not a compiler-derived public API or call graph.

## Public-safe visual workflow

Read [testing and captures](testing.md). Every published image must be generated from invented fixture data, visually inspected and hashed in the manifest. The allowlisted directory exception in AGENTS/.gitignore applies only to those assets. Normal local screenshots remain prohibited.

Caption each screenshot with task, dataset and safety state. Alt text describes the control/view, not every visible word. Full-size images open in a keyboard-accessible dialog; Escape closes it and focus returns to the image button. Ordinary Markdown remains readable on GitHub.

## Desktop routes

`Sources/Documentation.swift` holds one fixed HTTPS base and a fixed route per `KonMagicPage`. `NSWorkspace` opens the user’s browser only on an explicit action. Help menu commands resolve the active page host; the Toolkit links to Getting started. The welcome guide explains these options.

Never append a query, source path, catalogue identifier, receipt or diagnostic to the URL. The native guide is local; web documentation requires network access. The app does not embed an untrusted web document in its privileged filesystem context.

## Deployment

The Pages build installs the pinned requirements, regenerates references, runs a strict site build and checks local links, anchors, assets/privacy and app route contracts. Pull requests build but do not deploy. Main pushes and manual workflow dispatch publish the static artifact through official GitHub Pages actions.

The deploy job uses the `github-pages` environment, `pages: write` and `id-token: write`, and depends on the successful build job. Pages is configured for GitHub Actions rather than a source branch. See [GitHub’s custom-workflow documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

Review a change through the local preview and CI. Check the live home page, a deep guide URL, an image and search after publication. Set the repository homepage to the deployed site. If Pages access/policy prevents deployment, preserve the source/artifact and report the actual restriction; do not claim it is live.
