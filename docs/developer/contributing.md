# Contribute without exposing personal content

Read the repository’s [AGENTS.md](https://github.com/madfam-org/konmagic/blob/main/AGENTS.md) before editing. Public code, examples and tests must use generic synthetic data. Real catalogues, paths, filenames, body text, receipts, staff identities, credentials and normal local screenshots never belong in Git or public issues.

## A useful change sequence

1. Identify the owner and trust boundary in the [module map](modules.md).
2. Write down the resulting behavior and which safety invariant could change.
3. Implement the smallest cohesive change, preserving shared state and existing user intent.
4. Run meaningful synthetic checks for any filesystem/data behavior change. Use relevant UI modes for navigation/layout changes.
5. Update the manual, limits/reference and synthetic screenshots where behavior changed.
6. Build the documentation strictly and validate links/privacy/assets.
7. Review the actual diff, staging only public code and reviewed invented assets.

Never fix a hold by weakening no-follow traversal, source barriers, collision checks, hash completeness or capacity reserve. Do not add native/CLI/GUI backdoors that bypass the production verification path. Treat test-only allowances as restricted synthetic scaffolding.

## Commit and PR information

Use the project’s generic contributor identity for local commits and include the required Codex/session trailers when applicable. A description should lead with the concrete problem and resulting behavior, then relevant tests and remaining limits. Do not attach raw local evidence to a public PR.

Scope capability claims to implemented behavior. A partial contract is not a complete commercial parity claim; a local ad-hoc build is not a notarized release. Separate plans from execution and observed evidence from inferred classification.

## New dependencies

Native runtime currently uses only Apple/system libraries. A docs-only Python environment does not become an app dependency. Justify runtime dependencies by a real capability or maintenance benefit, verify licenses and platform support, and avoid introducing background services without a reviewed design.

## Sensitive reports

Do not put credentials or a user’s catalogue in a public security report. There is currently no separately advertised private security intake in this repository; coordinate a private reporting channel before sharing details. Public reproductions should be synthetic and omit exact personal paths.
