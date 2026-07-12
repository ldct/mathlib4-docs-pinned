#!/usr/bin/env bash
# Build rendered HTML docs for a pinned Mathlib 4 release tag.
#
# Follows the official recipe from
# https://github.com/leanprover-community/mathlib4_docs/blob/main/.github/workflows/docs.yaml
# but pins mathlib AND doc-gen4 to release tags instead of tracking master.
#
# Usage: build-docs.sh <mathlib-tag> [doc-gen4-tag] [workdir]
#   e.g. build-docs.sh v4.31.0
#        build-docs.sh v4.32.0-rc1-patch1 v4.32.0-rc1
#
# Output: $WORKDIR/mathlib4-docs-<tag>.tar.gz  (contents of .lake/build/doc)
set -euxo pipefail

MATHLIB_TAG=${1:?usage: build-docs.sh <mathlib-tag> [doc-gen4-tag] [workdir]}
DGTAG=${2:-$MATHLIB_TAG}
BASE=${3:-$PWD/build}
ML=$BASE/$MATHLIB_TAG-mathlib4
WA=$BASE/$MATHLIB_TAG-workaround
export PATH="$HOME/.elan/bin:$PATH"

mkdir -p "$BASE"
if [ ! -d "$ML" ]; then
  git clone --depth 1 --branch "$MATHLIB_TAG" https://github.com/leanprover-community/mathlib4 "$ML"
fi

# Get prebuilt oleans so mathlib itself is not compiled from scratch.
cd "$ML"
lake exe cache get
env LEAN_ABORT_ON_PANIC=1 lake build

# Dummy "workaround" project requiring mathlib + doc-gen4, so that adding
# doc-gen4 does not invalidate mathlib's build (same trick as the official CI).
mkdir -p "$WA"
cd "$WA"
cp "$ML/lean-toolchain" .
cat > lakefile.toml <<EOF
name = "workaround"
version = "0.1.0"
defaultTargets = ["workaround"]

[[lean_lib]]
name = "Workaround"

[[require]]
scope = "leanprover"
name = "doc-gen4"
rev = "$DGTAG"

[[require]]
name = "mathlib"
path = "../$MATHLIB_TAG-mathlib4"
EOF
echo 'def workaround := 0' > Workaround.lean
if [ ! -d .git ]; then
  git init -q
  git config user.email "docs@example.invalid"
  git config user.name "docs builder"
  git add .
  git commit -qm workaround
  # doc-gen4 expects a git repo with at least one commit and a github remote
  git remote add origin "https://github.com/leanprover-community/workaround"
fi

mkdir -p .lake/packages
cp -r "$ML/.lake/packages/"* .lake/packages/
lake update
# doc-gen4 lacks support for subproject references.bib; copy it over
mkdir -p docs
cp "$ML/docs/references.bib" docs/references.bib
lake build doc-gen4

# Import graph shown on the landing page of the docs
cd "$ML"
lake exe graph mathlib.html

# The actual render
cd "$WA"
lake build Batteries:docs Qq:docs Aesop:docs ProofWidgets:docs Mathlib:docs Archive:docs Counterexamples:docs docs:docs
lake build Mathlib:docsHeader

cp "$ML/docs/100.yaml" "$ML/docs/1000.yaml" "$ML/docs/overview.yaml" "$ML/docs/undergrad.yaml" .lake/build/doc/
cp "$ML/mathlib.html" .lake/build/doc/

cd "$BASE"
tar -C "$WA/.lake/build/doc" -czf "mathlib4-docs-$MATHLIB_TAG.tar.gz" .
echo "BUILD_DONE_$MATHLIB_TAG"
