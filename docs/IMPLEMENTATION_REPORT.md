# Lua-only conversion report - 2026-10-14

Project Version: 0.2.0-dev.3

Completed the safely supported conversion scope. Active runtime is Lua-only; active
build/test tooling is Python with Lupa. No custom Java was implemented, compiled,
loaded or packaged during this conversion. Native research/artifacts remain local
historical evidence with protected hashes. Authoritative source path and Mod ID stay unchanged.

Implemented: authenticated server-owned saved preferences; four-policy diagnostics;
private schema-2, two-slot metadata persistence with read-back verification and prior-slot recovery; individual
inactive-record revocation; owner-only snapshots; protocol/malformed-input protection;
deduplicated vanilla-style settings/status UI; English fallback JSON for all 29
observed vanilla locales; Lua-only source/package preflight and focused regressions.

IMPORTANT: this is not a functioning examination-consent mod. Saved settings and
records are inactive. There is no production approval creation, auto-approval, prompt
bypass, medical callback/event wrapper, timed-action replacement, health-data session
or post-subscription stop loop. Vanilla examinations and treatment remain active.

SOURCE BLOCKER: the audited RequestMedicalCheck and BodyDamageUpdate server handlers
have no verified Lua authorization veto. A client wrapper or reactive stop would
not establish server authority. Required operational consent, policy enforcement,
medical session revocation, timing/retention and raw-packet protection are blocked.
The implemented Lua-only alternative is unchanged vanilla plus honest metadata/status.
See SOURCE_AUDIT.md for exact methods and evidence distinctions.

Migration: the old properties schema is preserved but not imported. New Lua metadata
is per server profile in the server Lua cache, not world/character data. Actual engine
restart, durability, cache permissions and account identity behavior remain runtime gates.

GitHub was created PUBLIC at the user's approved B47ANCE/B47ANCEDMedicalChecks identity.
PR #1 review fixes are recorded in CHANGELOG.md. Merge is authorized after review
and passing applicable checks. Final merge/commit SHAs are verified through GitHub
and reported separately; merge grants no stable-release, deployment or runtime claim.
No stable tag, Workshop upload, deployment or game/server launch is included.

Current offline validation passed 49 tests, Lua-only preflight, version consistency and package-input planning; exact commands/results are in VALIDATION.md. Historical Java-era results were
preserved, not promoted to current evidence. G6/SP: NOT TESTED. G7 dedicated:
BLOCKED / NOT TESTED. Stable G8: BLOCKED. No new distribution ZIP was requested for
this conversion, so the package plan was checked without replacing historical ZIPs.

Persistence limitation: failed read-back after a complete write is an uncertain outcome. The old in-memory value remains, but restart can load the newer disk value; durable rollback is not claimed. See ARCHITECTURE.md and the disposable regression fixture.
