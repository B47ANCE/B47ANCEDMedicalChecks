# Medical authority source audit — 2026-10-14

Baseline: project 0.2.0-dev.2, merged source e01f20dde6ea94185c0bdd7dda7c9e64c04d6c63.
Research amendment only; no runtime/version change, enforcement implementation or release authorization.

## Evidence scope and coordinates

[VERIFIED source] Primary evidence is the local installation's original
`projectzomboid.jar` and `media/lua` under the installed ProjectZomboid root.
`Core.<clinit>` initializes GameVersion(42,21,""). Existing baseline fingerprints
were rechecked with `scripts/audit_source.py`. The extended 44-file inventory is
`medical-authority-evidence.json`, including source and generated evidence SHA-256.

`scripts/audit_medical_source.py` reads class files using Python/Jawa 2.2.0; it
does not execute Java or send packets. Native references below are actual JAR
class/method plus bytecode instruction offset (BCI), with navigation lines in
`research/authority-audit-v3/<class>.bytecode.txt`. These are disassembly lines,
not original Java source lines. Lua references are installed file lines, relative
to `media/lua`. Regenerate local listings with the command in VALIDATION.md.
Full upstream listings remain ignored local evidence, not redistributed source.
Historical CFR listings were consulted but new findings use current JAR bytes.

[UNKNOWN effective runtime] Selected loose classes differ from the original JAR:
IsoPlayer, LuaEventManager and Event. This expands the earlier audit's warning;
it does not establish which classes the actual process would load. Findings apply
to the original 42.21 baseline, not to unverified injected installations or later builds.
No game/server, SP, hosted or dedicated test was executed.

## Request and approval lifecycle

1. Client `ISUI/ISWorldObjectContextMenu.lua:883–887` calls `requestMedicalCheck` at :885
   after `ISHealthPanel.canPerformMedicalCheck`. The latter is client Lua
   (`XpSystem/ISUI/ISHealthPanel.lua:1972`): privileged medical capability or
   walk adjacency / shared vehicle. This is cooperative interaction validation.
2. Exposed native `LuaManager$GlobalObject.requestMedicalCheck`, BCI 0–49,
   sends `RequestMedicalCheck` ASK for remote participants; otherwise emits a local
   event. `acceptMedicalCheck` uses the same path with ACCEPT. These methods
   submit intent/notifications; they do not install a server approval ledger.
3. Native packet dispatch `PacketTypes$PacketType.onServerPacket` parses,
   checks consistency, applies configured native anti-cheats and calls
   `processServer`. `PacketAuthorization.isAuthorized`, BCI 0–78, checks
   connection role/capability (LoginOnServer for these packets); it is not
   patient consent. No Lua consent callback occurs in this dispatch chain.
4. `RequestMedicalCheckPacket.parse` reads target/requester PlayerID fields.
   `PlayerID.parsePlayer`, BCI 0 onward (listing line 45), resolves a supplied
   nonnegative local index through the connection, but the -1 branch resolves
   an online ID from the global map. `isConsistent` only requires non-null players
   here. A resolved player is not proof that the connection owns that role.
   No ASK=requester-owner / ACCEPT=patient-owner assertion appears in this handler.
5. `RequestMedicalCheckPacket.processServer`, BCI 0–64 (listing line 95),
   selects the patient connection for ASK, examiner connection for ACCEPT;
   rejects missing destination or `isCheckForbidden` (absolute X/Y difference
   greater than two). It then forwards the packet. No outstanding-request,
   nonce, session, refusal, expiry, account-pair grant or Lua veto is consulted.
   Server identity spoofing/replay consequences remain runtime NOT TESTED.
6. `processClient` (listing line 72) emits `RequestMedicalCheck` or
   `AcceptedMedicalCheck`. `ISHealthPanel.lua:1942–1956` creates a YES/NO modal;
   YES calls acceptMedicalCheck. NO sends no refusal packet in this code.
   `:1958–1961` rechecks client interaction eligibility and queues
   `ISMedicalCheckAction`. These events are client notifications, not server vetoes.

No health body data is in ASK/ACCEPT. Blocking only those messages is nevertheless
insufficient: the separate subscription path below does not require either message.
The examined lifecycle has no server pending-consent timeout or refusal ledger.
Repeated requests can create repeated client modals; distance is not request deduplication.
Disconnect has no consent ticket to invalidate in this lifecycle. A native action
Reject state is distinct from patient refusal; it must not be treated as approval logic.

## Examination, disclosure and stop lifecycle

Client `TimedActions/ISMedicalCheckAction.lua:11–14` validates movement/vehicle or
privileged medical capability. `:37–75` opens/reuses a health panel, installs doctor
skill presentation, and calls `self.character:startReceivingBodyDamageUpdates`.
Duration at `:78–89` depends on First Aid. There is no server consent proof in
this client action. Never replace it as a claimed privacy boundary.

Exposed `IsoPlayer.startReceivingBodyDamageUpdates`, BCI 0–40 (listing line 4),
resets the remote damage state after client/local/remote-player checks and calls
`BodyDamageSync.startReceivingUpdates`. That client-only method creates and sends
BodyDamageUpdate START. The native packet's `setStart` uses local player slot zero;
split-screen correctness must not be assumed. STOP checks client/participant state
and submits a packet; it does not revoke an account authorization.

`BodyDamageUpdatePacket.processServer`, BCI 0–73 (listing line 279), branches:

| Operation | Server action | Consent boundary |
| --- | --- | --- |
| START | BCI 10–27 calls `BodyDamageSync.startSendingUpdates(remoteID,currentID)` | No Lua veto or consent lookup before registration |
| STOP | BCI 41–58 calls `stopSendingUpdates(remoteID,currentID)` | Removes the pair; not an enduring deny rule |
| UPDATE received by server | Returns | Do not misreport this as a client-upload treatment route |

The handler uses wire ID values for registration, not connection-derived consent
identity. PlayerID resolution alone does not authenticate both patient/examiner.
`INetworkPacket` inherits `INetworkPacketField.isConsistent` (listing line 8),
which returns constant true at BCI 0–1; BodyDamageUpdatePacket supplies no override.
It supplies no patient authorization. Default packet consistency and connection
login are not evidence of a session consent check.

`BodyDamageSync.startSendingUpdates`, BCI 0 onward (listing line 23), is server-only:
it resets an existing pair's sent snapshot or adds an updater for that pair, taking
the patient's server body damage. It does not call the approval lifecycle.
`BodyDamageSync.update` (listing line 174) runs the updaters. `BodyDamageSync$Updater.update`
(listing line 7) computes health/pain/infection and body-part differences, checks
that both mapped players and recipient connection exist and the connection is not
delayed-disconnecting, then sends BodyDamageUpdate UPDATE. This is the actual
disclosure boundary. No consent/session epoch is checked immediately before send.
Repeated START can reset sent state; STOP followed by another START is possible
in source. No packet manipulation or disclosure experiment was performed.

Client `BodyDamageUpdatePacket.processClient` (listing line 178) decodes health,
pain, infection and body-part fields into remote damage state. Cancelling UI after
this point cannot undo disclosure. `ISHealthPanel.lua:350–420` closes/stops for
window visibility, recreated remote player, movement and distance; these are
client cleanup paths, not default-deny server revocation. Server updater checks
on absent connections are not proof of reconnect/online-ID-reuse invalidation.
Updater removal on every disconnect path and ID reuse remains NOT VERIFIED.
Server restart creates fresh native memory, but does not create required consent
validation on the next START. Actual restart behavior is NOT TESTED.

## Treatment: client presentation versus server execution

`ISHealthPanel.lua:1147–1759` constructs bandaging, poultice, disinfecting,
stitching/removal, glass removal, splinting/removal, bullet removal and burn cleaning
actions; `:1801–1813` and `:1917–1930` enumerate the handler sets. No additional
cross-player treatment class was identified in these panel routes. Inventory transfer,
movement and self-use food/drugs are adjacent systems, not evidence that all game
health-changing paths have been exhaustively secured.

The shared medical classes contain real server execution functions. Blanket
classification of all timed actions as client-only would be incorrect for 42.21.

| `shared/TimedActions/` file | `isValid` | `complete` entry | `syncBodyPart` | Constructor |
| --- | ---: | ---: | ---: | ---: |
| ISApplyBandage.lua (apply/remove) | 5 | 101 | 148 | 173 |
| ISCleanBurn.lua | 5 | 59 | 75 | 94 |
| ISComfreyCataplasm.lua | 5 | 65 | 81 | 94 |
| ISDisinfect.lua | 5 | 68 | 92 | 111 |
| ISGarlicCataplasm.lua | 5 | 64 | 79 | 92 |
| ISPlantainCataplasm.lua | 5 | 65 | 82 | 95 |
| ISRemoveBullet.lua | 5 | 58 | 73 | 92 |
| ISRemoveGlass.lua | 5 | 56 | 77 | 100 |
| ISSplint.lua (apply/remove) | 5 | 87 | 125 | 140 |
| ISStitch.lua (apply/remove) | 5 | 84 | 130 | 155 |

The complete chain established by source/bytecode is:

1. Client `ISTimedActionQueue` queues the action; native `LuaTimedActionNew.start`,
   BCI 60–118 (listing around line 320), creates a net action through ActionManager.
   Local `isValid`/movement checks are not a sufficient malicious-client boundary.
2. `NetTimedAction.set` gathers constructor arguments. `NetTimedAction.parse`,
   BCI 0–233 (listing line 287), loads the action type/arguments, looks up its
   Lua constructor, and constructs a **server Lua action**. Constructor side effects
   and getDuration occur before complete; complete-only checks cannot guard those.
3. `Action.parse` and `PlayerID` resolve the actor. `PZNetKahluaTableImpl.load`
   overload (listing line 1071), BCI 149–176, resolves player arguments, and
   BCI 217–261 resolves body parts from supplied player/index. These arguments
   require actor/connection/patient/body-part consistency proof; object resolution
   is not authorization. NetTimedAction.isConsistent delegates to Action.isConsistent,
   which delegates to PlayerID.isConsistent; no consent check appears.
4. `NetTimedActionPacket.processServer`, BCI 0–196, accepts a consistent Request
   with non-null action, stops that player's previous action, starts the server
   action and returns Accept; malformed/nonconstructed actions receive Reject.
   `NetTimedAction.start` invokes optional Lua `serverStart` (e.g. the bandage
   manipulation-name lock). This lock serializes manipulation; it is not consent.
5. Server `ActionManager.update`, BCI 0–259 (listing line 87), waits for accepted
   action end time, calls `Action.perform` at BCI 73, sends Done on true or Reject
   on false and removes the completed action. `NetTimedAction.perform`, BCI 0–42
   (listing line 267), calls `action.complete` with protectedCallBoolean and
   returns the result; errors return false. `NetTimedAction.isValid` is constant
   false and `update` empty here. Do not assume the client's medical `isValid`
   is automatically re-run as a server policy gate.
6. The shared medical `complete` functions mutate server body parts, use/remove
   items and grant appropriate XP, then sync affected flags. `perform` commonly
   handles client animation/sounds/queue rather than authoritative treatment.
   Early return before calling the original complete would prevent that particular
   function's effects, but no such wrapper was implemented in this audit.
7. `LuaManager$GlobalObject.syncBodyPart`, BCI 0–50, is server-gated and sends
   BodyPartSync to the body's player. `BodyPartSyncPacket.parse` applies fields
   on receipt. Its annotation is **handlingType=2** (client handling only);
   `PacketTypes.onServerPacket` requires bit 1. Merely observing its parse mutation
   does not prove a client can inject it into server treatment state.

The adjacent native `character/PlayerDamagePacket` and `PlayerInjuriesPacket`
were inspected as alternative health synchronization paths. Both annotations
also specify handlingType=2 (their listings line 3); parse applies client state,
not a newly established client-to-server treatment bypass. This does not make
those server-originated disclosures subject to a mod consent policy. Protection
of every unrelated player-state broadcast is outside what the current scaffold
can claim.

`ActionManager.disconnectPlayer`, BCI 0–83 (listing line 639), marks matching
actor actions Reject. This is native action cleanup, not a patient-consent ledger;
patient-as-target disconnect and subscription cleanup are different obligations.
`NetTimedAction.forceComplete` only sets endTime to server time; it does not itself
provide patient authorization. Replayed/out-of-order action IDs and constructor
arguments must remain explicit runtime security gates, not inferred safe from
the existence of Accept/Reject/Done states.

`LuaManager$Exposer.exposeAll` lists IsoPlayer, NetTimedAction and its packet class.
Lua action tables and complete functions are addressable, but exposed classes do
not turn private native fields, wire dispatch or Java virtual methods into Lua
authorization hooks. The trusted actor-to-connection comparison available to a
Lua wrapper, arbitrary action types/constructors, first-effect coverage, cleanup,
and other health-change routes still require investigation/runtime proof.

## Other server command route and event semantics

Native `GameServer.receiveClientCommand` (new listing line 3; historical CFR
2360–2392) derives the player from the connection's local slot, decodes the table
and emits OnClientCommand. Its CCFilter block controls logging, not medical denial.
`server/ClientCommands.lua:1296–1307` dispatches through a local Commands table.
Adding another subscriber cannot prevent this existing subscriber from executing.

The separate `player.onHealthCheat` route at `:474–479` checks UseHealthCheat before
sending a client command. However the adjacent `onHealthCheatCurrentPlayer`
function at `:481–627` selects args.id/bodyPartIndex and mutates body state without
an equivalent visible permission or sender==patient guard in that function;
the generic Lua dispatcher also has no such check. [VERIFIED source gap], not a
confirmed live exploit: installation overrides, effective loading and any outside
mitigations were not runtime tested. No invocation utility or live attack was built.
Any future treatment security claim must cover this distinct command route too.
Removing/replacing the entire vanilla dispatcher is broad compatibility work,
not an established narrow medical interception API or an approved implementation.

`LuaEventManager.triggerEvent` overloads return void and discard Event.trigger's
Boolean. `Event.trigger`, BCI 89 and 276, calls protectedCallVoid for each callback;
its Boolean indicates callback presence/dispatch, not a veto from callback returns.
Returning false cannot cancel the native medical handlers or another event listener.
Mutating notification arguments cannot establish pre-disclosure default denial.
No verified medical-specific server event precedes START or updater transmission.
`LuaEventManager.AddEvents` registers the two medical event names (listing lines
1768–1772); registration alone supplies no authorization semantics.
`LuaEventManager.reroute` (listing line 2001) replaces matching event callback
closures by prototype; it does not reroute native packet handlers or add a veto.

## Decision and remaining proof

**C. LUA-ONLY SERVER ENFORCEMENT BLOCKED** for the requested combined privacy and
treatment contract on the audited vanilla 42.21 paths. This is a bounded source
finding: no sufficient Lua-accessible default-deny authorization boundary was found,
not a theorem about all engine versions or every unknown API.

The server complete callback is a useful **PROVISIONAL** treatment-only candidate,
not verified secure coverage and not a solution to health disclosure. A native
pre-START AND pre-send authorization seam, authenticated actor binding, and complete
treatment-route coverage are needed. No client-only wrapper, post-send stop loop,
role removal, Java replacement, active grant import or new gameplay code is proposed.
Keep the current inactive metadata/status infrastructure. See feasibility and
security matrices and VALIDATION.md for outstanding clean dedicated tests.
