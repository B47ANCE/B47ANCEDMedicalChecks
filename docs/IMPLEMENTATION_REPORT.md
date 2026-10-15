# Cooperative implementation report

Project Version: 0.3.0-dev.2

Implemented the user-authorized cooperative convenience: ordinary-client approval
prompts, Always Ask and per-examiner Only Ask Once, four cooperative server policies,
server-owned directional approvals, persistence, individual revocation, request
cooldown/timeout, protocol 3, live-participant validation and one-time confirmation.
Settings and prompts explicitly disclose that modified clients can bypass this.

Native medical privacy enforcement remains BLOCKED. Treatment server complete()
remains PROVISIONAL as a possible separate validation point; no treatment wrapper
was implemented. Native requests, health data, packets and open panels are not secured.
All actual SP/dedicated behavior is NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

New source: shared/Cooperative.lua, client/CooperativeUI.lua. Updated settings engine,
server adapter, context integration, settings UI, sandbox/localization and regressions.
Original treatment actions, native events, First Aid, inactive metadata schema and
artwork bytes are preserved. Old records do not become approvals. New approval files
are a separate schema-2 domain; session retention is memory-only. See ARCHITECTURE.md
for uncertain write/recovery behavior and the exact cooperative trust boundary.

Offline checks and exact commands are in VALIDATION.md. Source identity is verified
against original 42.21; differing loose classes mean effective runtime is UNKNOWN.
No game/server was started, no deployment/publication/package occurred for
this implementation. PR #4 merge is separately authorized after review and checks. A feature-branch commit/push and draft PR are integration evidence
only. Historical Java and prior reports remain preserved and excluded from runtime.

PR #4 fixes: incomplete approval slot pairs disable cooperative access for review; disabled-mode fallback rechecks the current patient object and vanilla eligibility. Both regressions failed before correction and pass offline afterward. These fixes do not add native enforcement.
