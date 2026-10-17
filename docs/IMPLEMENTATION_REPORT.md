# Medical Checks implementation report

Project Version: 0.3.0-dev.7

Current validation/UI update: settings use vanilla controller navigation, return
focus when closed/disconnected, retain focus across examination prompts and fit a
640x360 split-screen viewport in offline layout fixtures. The test harness routes
messages across isolated server/three-client Lua states. These are mocked host
tests, not rendered UI, native packets, player-hosted or dedicated-server evidence.
PR review also corrects overlapping prompt/background settings closure: closed
Medical Checks windows are removed from return-focus links and cannot steal
foreground focus or be restored after they close. Four offline regressions cover
expiry, hidden settings, multi-window disconnect and repeated modal destruction.

Medical Checks remains standalone and defers to
Health Care when B47ANCEDHealthCare is active. Config checks the engine list;
Authority, VanillaBridge, PreferencesUI and CooperativeUI return before runtime
registration or UI/storage imports. No Health Care code is required or changed.
Saved approvals/preferences are not migrated or deleted. Full absorption of the
features into Health Care is planned, not implemented or verified by this change.

Implemented: examination prompts, Always Ask, per-examiner Only Ask Once, four server
policies, server-owned directional approvals, persistence, individual revocation,
request cooldown/timeout, live-participant validation and one-time confirmation.
Protocol 3 and storage schema 2 are unchanged.

The server validates requests and persists approvals; the examiner client calls the
original vanilla examination callback after confirmation. Treatment actions, First
Aid requirements and vanilla interaction eligibility remain unchanged. Revocation
cancels pending requests and affects future checks; open health panels remain vanilla.
Legacy inactive records do not become approvals. New approval files use a separate
storage domain; session retention is memory-only. See ARCHITECTURE.md for details.

Historical 0.3.0-dev.5 was a PATCH-compatible wording iteration. README, current feature overviews,
mod description, Workshop changenote, UI labels, prompts and sandbox tooltips now
focus on normal mod use. No policy, approval, request, synchronization or storage
logic changed. Translation keys, option identifiers, defaults and bounds are preserved.
The supplied thumbnail, mod icon and poster remain byte-for-byte unchanged.

Validation commands and results are recorded in VALIDATION.md. Current actual
player-hosted/dedicated behavior, both-mod compatibility and visual rendering are NOT TESTED.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Implementation/PR-review tests are
offline; any later authorized distribution is recorded separately in publication
provenance and does not change these runtime results. The earlier .6 build was packaged and
published after explicit owner authorization; PUBLICATION-0.3.0-dev.6.json records
that distribution only. Historical audits, Java research and prior
reports retain their original evidence and are not promoted to current runtime proof.
