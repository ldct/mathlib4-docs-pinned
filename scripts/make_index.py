#!/usr/bin/env python3
"""Generate the landing index.html from versions.json."""
import json
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent
versions = json.loads((root / "versions.json").read_text())

items = "\n".join(
    f'      <li><a href="./{v}/">{v}</a> &mdash; '
    f'<a href="./{v}/Mathlib.html">module index</a></li>'
    for v in versions
)

print(f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Pinned Mathlib 4 docs</title>
<style>
  body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
         max-width: 44rem; margin: 3rem auto; padding: 0 1rem; line-height: 1.55;
         color: #1a1a1a; background: #fff; }}
  a {{ color: #0b5fa5; }}
  li {{ margin: .4rem 0; }}
  footer {{ margin-top: 3rem; font-size: .85rem; color: #666; }}
  @media (prefers-color-scheme: dark) {{
    body {{ color: #ddd; background: #16181d; }}
    a {{ color: #7cb8e8; }}
    footer {{ color: #999; }}
  }}
</style>
</head>
<body>
  <h1>Pinned Mathlib 4 documentation</h1>
  <p>Rendered HTML documentation for specific <a
  href="https://github.com/leanprover-community/mathlib4">Mathlib 4</a> release
  tags. Unlike the <a
  href="https://leanprover-community.github.io/mathlib4_docs/">official docs</a>,
  which track <code>master</code> and are rebuilt every few hours, these pages
  are frozen at the tagged release.</p>
  <h2>Available versions</h2>
  <ul>
{items}
  </ul>
  <footer>
    <p>Built with <a href="https://github.com/leanprover/doc-gen4">doc-gen4</a>.
    Mathlib and doc-gen4 are Apache-2.0 licensed by their respective
    contributors. Sources and build scripts:
    <a href="https://github.com/ldct/mathlib4-docs-pinned">ldct/mathlib4-docs-pinned</a>.</p>
  </footer>
</body>
</html>""")
