# Changelog

## [0.3.0-dev.3]

Replace the cooperative fresh-store next() dependency with a local pairs-based emptiness check. Preserve slot seeding, recovered/incomplete-store rejection and fail-closed writes. Add a missing-next host regression; PZ SP/dedicated runtime NOT TESTED, G7/stable G8 BLOCKED.

## [0.3.0-dev.2]

PR #4 review: reject incomplete cooperative approval storage after a missing slot, preventing older revoked grants from being reused. Recheck the patient object and vanilla eligibility before disabled-mode fallback. Added regression fixtures; cooperative-only scope and untested multiplayer remain explicit.

## [0.3.0-dev.1]

Add cooperative consent prompts, server-owned per-examiner convenience approvals and revocation. This guides ordinary clients only; native server medical authorization remains BLOCKED and dedicated multiplayer NOT TESTED. Approval records are stored separately from legacy inactive metadata.

## [0.2.0-dev.3]
- Add user-supplied fallback icon/thumbnail; preserve manually supplied artwork. Asset-only iteration; gameplay unchanged.
- Offline branding/version checks only; earlier validation remains historical at 0.2.0-dev.2. No new SP/dedicated MP evidence.

## [0.2.0-dev.2]

Research amendment (2026-10-14, no version increment): expanded original 42.21 medical authority audit, separate disclosure/treatment threat matrix, and read-only Python bytecode evidence tool. Server Lua complete callbacks are confirmed execution points; complete consent enforcement remains blocked, dedicated multiplayer NOT TESTED. Runtime source and persistence semantics unchanged.

PR #2 review: reject missing selected native methods instead of silently producing incomplete evidence; added optional Python/Jawa selector fixtures. Reproduced all original source/listing hashes. Research-only correction; version unchanged.

PR #1 review fixes: rapid metadata mutations return an explicit retry status and restore the saved selection; integer-valued floating-point preferences use canonical storage encoding. Added offline regressions and documented uncertain read-back failures. Consent enforcement remains BLOCKED; dedicated multiplayer NOT TESTED; stable G8 BLOCKED.

## [0.2.0-dev.1]

Lua-only conversion. Incompatible 0.x scope change: Java integration removed from active code/build/package paths; examination consent enforcement blocked rather than weakened. Existing agent properties are retained, not automatically imported.


## [0.1.0-dev.1]

Initial implementation of account consent, policy controls, permission management,
and a server packet guard. Dedicated runtime verification remains outstanding.
