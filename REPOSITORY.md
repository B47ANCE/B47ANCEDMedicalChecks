# Repository ownership and provenance

Canonical identity: B47ANCE/B47ANCEDMedicalChecks (public), Mod ID
`B47ANCEDMedicalChecks`. Root VERSION is authoritative. `src/` is authoritative
runtime source. `Contents/` inside generated archives is not source.

This repository was onboarded from an existing local development project at the
owner's request. The initial setup commit contains governance files only; legacy
runtime files are converted on a feature branch before being added to Git.

Current policy is Lua-only. Existing native/, research/, dist/ and history/ data
are retained locally as historical evidence, ignored by Git and excluded from
active Lua-only build inputs. No historical Java source, binaries or launch
instructions are an active dependency or authorization. No cleanup is implicit.

Workshop item 3820690174 is public; WORKSHOP_ID.txt is the canonical destination
for future updates. Public GitHub backup is separate from deployment,
Workshop distribution and runtime validation. G7 dedicated evidence and stable
G8 remain blocked until actual supported gameplay is established.

Publication inputs: docs/WORKSHOP_DESCRIPTION.txt (owner-preserved Steam BBCode)
and WORKSHOP_CHANGE_NOTE.txt.
Generated publication artifacts: dist/workshop-current/; local staging/logs remain
ignored. docs/PUBLICATION-0.3.0-dev.5.json records the exact published source and
hashes. The earlier dist/lua-only-current/ candidate is a separate pre-publication
snapshot from main 8bdb876 and is preserved without replacement.
