# Version and artifact inventory

Project Version: 0.3.0-dev.5

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

This task authorizes implementation and feature-branch review, not packaging,
deployment, game/server launch or Workshop publication. PR #4 merge is separately
authorized after review and applicable checks. No current artifact
exists for this version. scripts/check_versions.py passes current mirrors; --release
cannot be claimed without a requested artifact. G7/stable G8 remain BLOCKED.

Artwork iteration 0.3.0-dev.4 advances 0.3.0-dev.3 for the custom thumbnail and
its package-input selection only. No gameplay behavior, protocol or storage change.

Wording iteration 0.3.0-dev.5 advances 0.3.0-dev.4 with PATCH-compatible text
changes only. UI/localization and package status text change; gameplay, public
identifiers, protocol 3, storage schema 2, option defaults and artwork stay unchanged.
