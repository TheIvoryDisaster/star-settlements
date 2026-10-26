# Plugin working area

The **original authored** `SCS_*.esm` can eventually be committed here as the authoritative CK plugin (the repository explicitly exempts it from `.gitignore`). Do not commit Bethesda-owned originals or other authors' plugins. Record compatible CK/game versions and serialize binary plugin editing: only one branch/person should alter a particular `.esm` at a time. Consider Git LFS for large plugin history after confirming every contributor has Git LFS installed.

Generated deployment `.ba2`, compiled `.pex`, installer packages, and other release outputs belong in CI/release artifacts rather than Git. No authored `.esm` is present in the feasibility scaffold.
