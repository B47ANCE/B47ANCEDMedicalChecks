# Version and artifact inventory

Project Version: 0.3.0-dev.7

Root VERSION is canonical. Baseline main 85e29ca is 0.2.0-dev.3. This additive
cooperative feature is a 0.x MINOR development iteration to 0.3.0-dev.2. PR #4 review advances 0.3.0-dev.1 to 0.3.0-dev.2 for PATCH-compatible
correctness fixes within that feature. Protocol 3
is separate from project SemVer; both storage domains retain schema 2. Existing
current mirrors are synchronized via version-inventory.json and changelog.

Historical Java evidence, packages, audit reports and prior validation retain their
actual versions/hashes. Pre-cooperative current reports were preserved locally and
in Git at 85e29ca before replacement; none of their test evidence becomes current
proof. No old artifact is deleted, renamed or rebuilt. Research reports pinned to
0.2.0-dev.2 remain historical source findings, not current runtime validation.

The earlier implementation did not authorize publication. The owner's subsequent
explicit publish request produced public Workshop item 3820690174. The immutable
receipt in PUBLICATION-0.3.0-dev.5.json identifies its actual source and package.
Distribution is separate from runtime verification; G7/stable G8 remain BLOCKED.

Artwork iteration 0.3.0-dev.4 advances 0.3.0-dev.3 for the custom thumbnail and
its package-input selection only. No gameplay behavior, protocol or storage change.

Wording iteration 0.3.0-dev.5 advances 0.3.0-dev.4 with PATCH-compatible text
changes only. UI/localization and package status text change; gameplay, public
identifiers, protocol 3, storage schema 2, option defaults and artwork stay unchanged.

PR #8 review keeps version 0.3.0-dev.5: this corrects publication metadata and
its offline gate only; no runtime or published package changes. The single current
ZIP family uses dist/*-current/*.zip, covering both the developer package and any
Workshop publication copy. scripts/package.py --development may produce the sole
current ZIP in a clean checkout. Every additional matched ZIP is still checked for
canonical version and required members; a stale Workshop copy fails. No output is
deleted or moved. --release validates package versions, not stable-release G8.

0.3.0-dev.5 -> 0.3.0-dev.6 is a PATCH-compatible duplicate-feature prevention
update for the owner-specified Health Care relationship. Medical Checks remains
standalone; co-enabling Health Care makes it inactive. Public Mod/Workshop IDs,
protocol 3, schema 2 and existing sandbox identifiers/defaults/bounds are unchanged.
The initial implementation created no .6 artifact; after explicit merge/publish
authorization, merged source 10702b7 was packaged and published to existing item
3820690174. PUBLICATION-0.3.0-dev.6.json binds that exact distribution. The immutable
.5 receipt remains pinned to its original .5 source, package and evidence.

0.3.0-dev.6 -> 0.3.0-dev.7 is a PATCH-compatible validation and documentation
checkpoint with client controller/focus/viewport fixes. Gameplay behavior, public identifiers, protocol 3, schema 2,
sandbox settings and supplied artwork are preserved. The published .6 distribution
and its receipt remain historical and unchanged; this iteration does not publish.
