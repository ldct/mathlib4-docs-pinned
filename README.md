# mathlib4-docs-pinned

Version-pinned rendered HTML documentation for
[Mathlib 4](https://github.com/leanprover-community/mathlib4).

The [official Mathlib docs](https://leanprover-community.github.io/mathlib4_docs/)
track `master` and are rebuilt every few hours, so there is no way to browse
the documentation as it was at a specific release. This repository builds and
hosts frozen snapshots per release tag.

**Browse:** <https://ldct.github.io/mathlib4-docs-pinned/>

Each version lives under its own path, e.g.

- `https://ldct.github.io/mathlib4-docs-pinned/v4.31.0/Mathlib/Algebra/Group/Defs.html`
- `https://ldct.github.io/mathlib4-docs-pinned/v4.32.0-rc1-patch1/Mathlib/Algebra/Group/Defs.html`

Available versions are listed in [`versions.json`](versions.json) and on the
landing page.

## How it works

- Docs are generated with [doc-gen4](https://github.com/leanprover/doc-gen4),
  following the recipe of the
  [official docs workflow](https://github.com/leanprover-community/mathlib4_docs/blob/main/.github/workflows/docs.yaml):
  a dummy "workaround" project requires both mathlib (at the release tag, with
  prebuilt oleans from `lake exe cache get`) and doc-gen4 (at the matching
  release tag), then `lake build Mathlib:docs` (+ Batteries, Qq, Aesop,
  ProofWidgets, Archive, Counterexamples, docs) renders the HTML.
- The rendered HTML for each version is stored as `.tar.gz` assets on a
  GitHub release named `docs-<tag>` — it is never committed to git.
- The [deploy pages workflow](.github/workflows/deploy-pages.yaml) downloads
  those assets, assembles one site with a subdirectory per version, and
  publishes it with `actions/deploy-pages`.

No trimming is applied: each snapshot is the complete doc-gen4 output,
including search indexes (`declarations/`), source links, and the import
graph, so search and navigation work per version.

## Adding a new version

Locally (reliable path; needs ~25 GB disk and roughly an hour on a fast
machine, mostly in the doc render):

```sh
# doc-gen4 tag defaults to the mathlib tag; pass it explicitly when they
# differ (e.g. mathlib v4.32.0-rc1-patch1 uses toolchain/doc-gen4 v4.32.0-rc1)
bash scripts/build-docs.sh v4.33.0

gh release create docs-v4.33.0 --repo ldct/mathlib4-docs-pinned \
  --title "Rendered docs for v4.33.0" --notes "Rendered HTML docs for mathlib4 v4.33.0"
gh release upload docs-v4.33.0 --repo ldct/mathlib4-docs-pinned \
  build/mathlib4-docs-v4.33.0.tar.gz
# add the tag to versions.json, commit, then:
gh workflow run "deploy pages" --repo ldct/mathlib4-docs-pinned
```

Or in CI: run the **build pinned docs** workflow (`workflow_dispatch`) with
the tag as input, then add the tag to `versions.json` and run **deploy
pages**. Caveat: the official pipeline uses a dedicated large runner; on a
standard `ubuntu-latest` runner the build needs most of the disk and several
hours, and may hit the 6-hour job limit or run out of memory. Local builds
are the tested path.

## Licenses and attribution

The rendered documentation is generated from
[mathlib4](https://github.com/leanprover-community/mathlib4)
(copyright the Mathlib community, Apache License 2.0) using
[doc-gen4](https://github.com/leanprover/doc-gen4)
(copyright the doc-gen4 contributors, Apache License 2.0). The build recipe is
adapted from
[leanprover-community/mathlib4_docs](https://github.com/leanprover-community/mathlib4_docs)
(Apache License 2.0). The scripts in this repository are likewise released
under the Apache License 2.0 (see [LICENSE](LICENSE)).
