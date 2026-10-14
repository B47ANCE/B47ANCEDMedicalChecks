# Medical security and required test matrix — 2026-10-14

Baseline: 0.2.0-dev.2, source e01f20dde6ea94185c0bdd7dda7c9e64c04d6c63.
This is a source threat model and test handoff, not penetration-test evidence.
Native methods/offsets and Lua coordinates: MEDICAL_AUTHORITY_AUDIT.md.

## Boundaries and attack paths

| Boundary / intent | Identity evidence | First protected effect | Denial / revocation coverage |
| --- | --- | --- | --- |
| Mod settings Preference/Revoke | GameServer derives sender from connection; client owner fields ignored | Private metadata write | Existing server validation and two-slot storage; records remain inactive, not engine authorization |
| Native ASK / ACCEPT | Login capability; PlayerID has connection-index and global-ID branches; no role ownership assertion identified in handler | Modal/event, later client action | Distance/null checks only; no server pending ticket or refusal ledger; replay/forged-role denial NOT VERIFIED |
| Native START | Wire current/remote IDs; no patient consent lookup in handler | Registers/reset server updater | No established pre-registration Lua rejection; direct path bypasses ASK and mod command workflow |
| Native health UPDATE send | Mapped participants and recipient connection checked | Health/pain/infection/body-part bytes sent | No consent epoch/expiry immediately before send; UI close/reactive STOP cannot undo first disclosure |
| STOP / window close | Client-issued pair unsubscribe; client movement/visibility cleanup | Pair removal | No durable deny; another START can register it again; not session/account revocation |
| Normal treatment action | Server reconstructs Lua action, but supplied actor/patient/body-part require consistency/connection proof | Constructor/serverStart can run before complete; complete mutates body/items/XP | Real server complete callback returns Boolean; prospective wrapper still PROVISIONAL, no implementation |
| BodyPartSync | Server-gated syncBodyPart; packet handlingType=2 | Applies synchronized fields on client | Not a server-handled injection route in this dispatcher; no packet consent API |
| Alternate vanilla health command | OnClientCommand sender authenticated; arguments select target | Server health mutation in onHealthCheatCurrentPlayer | No equivalent permission/owner check visible there; earlier onHealthCheat checks capability; actual exploit NOT TESTED |
| Disconnect / reconnect / simultaneous sessions | Native updater pairs use online IDs, not mod account/session nonces | Potential subsequent updater sends | Connection absence checks exist; updater cleanup and online-ID reuse safety NOT VERIFIED; no mod active sessions exist |
| Restart | Native memory is process-local; saved metadata per profile | Fresh native START still unchecked for consent | No unintended mod active approvals (none created); actual native startup/restart NOT TESTED |

Default-deny consent, operation scoping, pair scoping, one-use/session nonces,
expiry, generation invalidation and active revocation are **not implemented**.
Schema-2 inactive records must not be reused as approvals. Denials must never become
grants in a future design. Metadata tests do not prove health or treatment security.
Do not conflate native action byte IDs with authenticated, replay-resistant consent.

## Required engine matrix

Every row below is **NOT TESTED — dedicated runtime required**. Expected outcomes
are requirements for a future secure implementation, not claims about this scaffold.

| Test | Required secure outcome | Current source finding / coverage gap |
| --- | --- | --- |
| Approved examination | Allowed | Vanilla YES flow identified; mod has no operational authorization |
| Unapproved examination | Denied before disclosure | START and updater send have no consent veto |
| Explicit refusal | Denied | Modal NO sends no denial ledger update; direct START independent |
| Revoked approval | Subsequent access denied | Inactive record deletion is not native-session revocation |
| Expired approval | Denied | Native subscription path has no mod session expiry |
| Unauthorized treatment | Denied before first effect | complete is a candidate; identity, early effects and other command route unresolved |
| Forged patient identity | Denied | PlayerID/global lookup and body-part constructor arguments require validation |
| Forged requester identity | Denied | Role ownership not established by generic consistency checks |
| Replayed approval | Denied | ASK/ACCEPT has no consent nonce/pending ledger in inspected handler |
| Concurrent examination requests | Independently authorized | Native updater keyed by IDs, no independent mod consent epochs |
| Patient disconnect | Active authorization invalidated | No mod sessions; native cleanup/reuse remains unproven |
| Requester disconnect | Active authorization invalidated | Same; test client cleanup separately from native send behavior |
| Dedicated-server restart | No unintended active authorization | No mod active grants; native reconnect/restart NOT TESTED |
| Malformed native request | Cannot bypass authorization | Native parsing/consistency is not proof of patient consent; no fuzzing performed |
| Modified client | Cannot bypass authorization | Separate START does not consult the cooperative approval path |

## Controlled future execution protocol

Separate authorization is required to deploy or launch. Use an isolated original
42.21 dedicated server and clean clients, disposable cache/profile/save, two normal
accounts plus a third for concurrent cases. Add a privileged-role case separately;
do not confuse administrator powers with ordinary consent policy. Preserve both
metadata slots before storage experiments. Record exact game/class/source/package
hashes, account roles (anonymized), connection/local-slot mapping and server logs.

For every row distinguish health bytes delivered, body/item/XP mutations, UI state,
and server decision timing. Test reconnect with new online IDs, ID reuse, both
disconnect directions, restart, delayed/reordered decisions and two examiners on
one patient. Include split-screen local slots and distances/Z/vehicle transitions.
No raw-packet tool is supplied or authorized by this audit. Native bypass validation
requires a separately approved controlled method; do not infer PASS from UI denial.

Keep G7 BLOCKED / NOT TESTED and stable G8 BLOCKED until the actual security
boundaries exist and dedicated evidence satisfies them. Merely running this
scaffold's vanilla UI successfully cannot pass the missing consent requirements.
