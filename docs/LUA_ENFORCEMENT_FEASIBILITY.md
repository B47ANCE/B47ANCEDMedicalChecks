# Lua enforcement feasibility — 2026-10-14

Research baseline: 0.2.0-dev.2 at e01f20dde6ea94185c0bdd7dda7c9e64c04d6c63.
No version bump: source research/tooling only, no runtime or persistence change.

Classifications apply to a specified boundary, never the whole mod by implication:
VERIFIED FEASIBLE requires the mechanism's claimed scope to be established;
PROVISIONAL means a real execution point exists but security proof is incomplete;
BLOCKED means the audited path lacks a required seam or has an unclosed bypass;
NOT VERIFIED means required evidence is absent. Runtime remains NOT TESTED in all rows.
Exact methods, BCI and file lines are in MEDICAL_AUTHORITY_AUDIT.md.

| Candidate | Classification | Interception / response lifecycle | Coverage and failure |
| --- | --- | --- | --- |
| A. Reuse patient modal / acceptMedicalCheck | BLOCKED for authorization | Client YES emits ACCEPT; server forwards; client queues examination | NO is silence; no server pending/refusal/expiry ledger; direct START bypasses modal |
| B. Return false from medical events | BLOCKED | processClient emits RequestMedicalCheck/AcceptedMedicalCheck | Wrong execution side; Event calls protectedCallVoid and native trigger discards result; not cancellable |
| B. Generic server event before health access | NOT VERIFIED | No such callback found in START registration or update send | No identified default-deny location; discovery must supply an actual caller that honors rejection |
| C. OnClientCommand for mod-owned workflow | VERIFIED FEASIBLE for own metadata only | Native connection-derived sender -> Lua intent -> own validated state -> private snapshot | Existing scaffold uses this; it never intercepts native medical packets or authorizes vanilla access |
| C. Additional OnClientCommand listener as native firewall | BLOCKED | Separate native packet dispatch never enters this event | Other vanilla listener still executes; false is not cancellation; health debug command is another route |
| D. Client isValid / panel / queue wrapper | BLOCKED for security | Cooperative client can omit queue or UI checks | Does not prevent START or independently establish server treatment identity |
| D. Shared medical complete wrapper on server | PROVISIONAL treatment-only | NetTimedAction.parse constructs server action; ActionManager invokes complete and handles Boolean result | Real server callback; early rejection can avoid original complete effects, but constructors/serverStart precede it; actor binding, replay, body-part integrity and alternate routes unproved; no disclosure coverage |
| E. startReceivingBodyDamageUpdates | BLOCKED as authorization seam | Exposed player method submits native START | Caller can reach native path separately; callable method is not a veto |
| E. stopReceivingBodyDamageUpdates / stopSendingUpdates | BLOCKED as default-deny revocation | Local unsubscribe or native pair removal | Does not prevent first send or renewed START; direct Lua exposure of BodyDamageSync singleton not established; no reliance on it |
| E. Packet role/capability restrictions | BLOCKED for patient policy | Native dispatcher requires LoginOnServer and configured anti-cheats | Login/role is not directional patient consent; removing login rights breaks ordinary gameplay; no native method monkey-patching assumed |
| E. syncBodyPart / BodyPartSync | VERIFIED FEASIBLE for vanilla server synchronization only | Server complete sends fields to patient; packet is client-handled | Not an approval API; no server injection bypass claimed solely from parse method |
| F. Lua-owned approvals delegating to vanilla medical actions | BLOCKED for combined contract | New UI/intent could issue its own decisions | Unapproved native START can skip Lua-owned ledger; treatment command routes need independent proof |
| F. Wholly custom opt-in medical presentation | NOT VERIFIED; different scope | Could present only server-selected mod data | Cannot prevent native disclosure; replacing gameplay is outside this audit and requires separate design approval |

The strongest new result is server-side **complete**, not a medical privacy hook.
Do not promote it to VERIFIED FEASIBLE treatment consent until the caller/actor,
patient/body-part, operation/session, first side effect, denial cleanup and every
native/Lua alternate route are proven. A mock returning false proves only the mock.

No safely sufficient combined mechanism was established. The one final decision
is **C. LUA-ONLY SERVER ENFORCEMENT BLOCKED**, scoped to audited vanilla 42.21.
The unresolved effective loose overrides are an additional runtime uncertainty,
not permission to rely on Java injection or an excuse to weaken authorization.

Recommended next step: retain inactive settings/status and seek an upstream,
supported Lua server veto before subscription registration and every health send,
plus trustworthy actor binding for treatment callbacks. If treatment-only research
is separately approved, first prove those identities and close command/constructor
coverage on a clean disposable dedicated server. Do not enable approvals merely
because a complete callback can return false. No implementation plan is authorized
or proposed for full consent enforcement under the present evidence.
