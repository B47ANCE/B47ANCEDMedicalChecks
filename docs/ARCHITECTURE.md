# Cooperative workflow architecture

Project Version: 0.3.0-dev.3

This implements the user's explicitly selected cooperative convenience. It does
not implement secure medical consent, a packet firewall, treatment validation or
native-session revocation. The prior native audit and provisional treatment finding
remain applicable. All snapshots retain enforcement=false.

Server owns saved preferences, cooperative records and short-lived request state.
OnClientCommand supplies the authenticated sender; untrusted owner/requester fields
never choose that identity. The patient is resolved through getPlayerByOnlineID;
responses must come from the exact patient object captured for that request.
Both participants must still resolve to their original live objects, be alive,
within two tiles in X/Y and on the same floor. These conservative convenience checks
do not substitute for the vanilla client eligibility check, or prove native security.

Flow: context callback -> CoopRequest(target, client nonce) -> patient CoopPrompt ->
CoopAnswer -> examiner CoopOffer -> CoopConfirm -> one consumed CoopProceed -> original
ISHealthPanel.AcceptedMedicalCheck(patient, examiner). The original callback queues
ISMedicalCheckAction; no timed action, medical event, treatment or native packet is
replaced. The client only accepts Offer/Proceed for its own outstanding nonce,
matching target and current patient object; unsolicited/replayed results do not queue
another action. This is cooperative correctness, not protection against modified clients.

Always Ask prompts every time and creates no grant. Only Ask Once creates a directional
patient-account -> examiner-account record only after YES. NO/timeout create none.
Policies 2/3 force the effective preference; policy 4 refuses cooperative requests.
Policy/preference/retention changes invalidate an outstanding response/confirmation.
Disabling CooperativeConsent explicitly restores the original context callback after
a server response; missing/incompatible peers time out without a native fallback.
Unmodified or other-mod entry points still use their vanilla behavior.

One request per examiner, eight per patient and 128 total are internal workload
limits. RequestCooldown bounds sender request cadence; RequestTimeout bounds prompts
and offers. A one-second OnTick handler scans only bounded mod state, never the world
or every player. Live object checks discard disconnected/replaced participants.
After confirmation there is no mod-owned active native session. Approval revocation
cancels pending requests/offers and affects future cooperative checks only. Request,
response and confirmation replay/malformed cases have offline coverage, not native
packet security proof. Vanilla networking remains the connection trust boundary.

Storage: existing B47MC_<hex profile>_a/b.txt retains schema 2 preferences and legacy
inactive grants. New B47MCCoop_<hex profile>_a/b.txt uses the same validated two-slot
codec solely for cooperative records. There is no legacy/property import or grant
activation. Fresh cooperative profiles seed both slots. Recovery of an older approval
slot, including a missing slot on an existing profile, disables cooperative requests for operator review instead of reusing potentially
revoked approvals. Files are preserved. Legacy settings prior-slot recovery is unchanged.
A complete write followed by failed read-back is still an uncertain result; restart may
load that complete write. No durable rollback, fsync or sudden-power-loss claim is made.

Retention 1 persists until revoked, across character/reconnect/restart under the same
account/profile. Retention 2 uses only memory, invalidated on either participant's
object disconnect; it ignores persisted grants. Switching back to retention 1 makes
its stored approvals visible/usable again. Changing Ask preference does not erase
approvals; Always Ask ignores them. Revoke removes the selected cooperative key from
both disk and current memory after a successful write. Settings UI labels legacy rows
inactive and sends their original Revoke command; cooperative rows use RevokeApproval.
Account rename is a new identity; no case/display-name normalization transfers consent.

Server authoritative sandbox settings: CooperativeConsent (new boolean, default true),
Policy, DefaultPreference, Retention, RequestCooldown, RequestTimeout and DebugLogging.
Identifiers/defaults/bounds of the six prior settings remain intact. The former reserved
settings now govern this workflow; debug emits reason codes, not private account data.
Storage/protocol/workload limits and UI coordinates remain internal technical constants.
Protocol is 3; on-disk schema remains 2. Mixed protocol clients are unsupported.

Client presentation: one wrapped Medical Check callback, deduplicated settings entry,
vanilla ISModalRichText YES/NO prompts with cooperative limitation/remembering text,
vanilla settings controls, timeout/disconnect cleanup and English fallback for 29 locales.
Both server and client handlers are registered once. Rich-text account labels are
sanitized for angle-bracket markup. First Aid duration and treatment restrictions
remain in vanilla. Rendering, controller focus, split-screen, file API behavior and
actual dedicated synchronization are runtime gates.

Historical decisions/source findings are retained in Git at 85e29ca and research
reports pinned to their original revisions; pre-feature reports also have local
hash-preserved copies. G7 and stable G8 stay BLOCKED; dedicated multiplayer NOT TESTED.
