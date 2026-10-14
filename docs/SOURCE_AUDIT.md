# Lua authority audit - 2026-10-14

[VERIFIED source] scripts/audit_source.py rechecks the installed original vanilla
JAR/Lua fingerprints against docs/api-baseline.json. Core's audited initializer is
GameVersion(42,21,""); this is exact 42.21 source evidence. The hash manifest separates
upstream evidence from project versioning. No Java code is compiled or executed.
The local installation has an unverified loose LuaEventManager override; actual
effective runtime is UNKNOWN. Use a clean isolated baseline for native observations.

Exact vanilla evidence (Java coordinates are historical CFR output from the original
JAR, retained locally; these are decompiled-bytecode coordinates, not shipped source):

| Capability | Source and conclusion |
| --- | --- |
| Initial medical intent | media/lua/client/ISUI/ISWorldObjectContextMenu.lua:883 calls requestMedicalCheck after canPerformMedicalCheck |
| Patient approval UI | media/lua/client/XpSystem/ISUI/ISHealthPanel.lua:1942-1961 uses RequestMedicalCheck/AcceptedMedicalCheck and queues the vanilla timed action |
| Panel and subscription | media/lua/client/TimedActions/ISMedicalCheckAction.lua:37-74 opens the vanilla health panel and starts receiving body-damage updates |
| Server request routing | RequestMedicalCheckPacket.processServer, CFR:70-76 forwards ASK/ACCEPT after target/distance checks; no Lua veto/authoritative pending consent ledger |
| Server health subscription | BodyDamageUpdatePacket.processServer, CFR:125-140 calls BodyDamageSync.startSendingUpdates directly for START; consent is not consulted |
| Medical Lua events | LuaEventManager, CFR:836-837 registers the two medical events; RequestMedicalCheckPacket.processClient, CFR:57-67 emits them on clients |
| Authenticated sender | GameServer.receiveClientCommand, CFR:2360-2392 resolves the sending connection's player before OnClientCommand; untrusted owner fields are unnecessary |
| Private reply | GameServer.sendServerCommand(IsoPlayer,...), CFR:3538-3547 selects that player's connection |
| Account key | IsoPlayer.getUsername(), CFR:6240-6265 uses false,false and preserves account username, separate from display/character names |
| Server profile | LuaManager.GlobalObject.getServerName, CFR:1530-1537 returns the server's configured name on the server |
| Lua reader | LuaManager.GlobalObject.getFileReader, CFR:2837-2860 returns UTF-8 BufferedReader in Lua cache, with createIfNull; vanilla ISLayoutManager.lua:127 uses reader/readLine/close |
| Lua writer | LuaManager.GlobalObject.getFileWriter, CFR:3468-3505 returns LuaFileWriter, validates relative paths/extensions; vanilla PZAPI/ModOptions.lua:260 uses writer/write/close |
| Stable layout/locales | Installed 42.21 has the 29 locale identifiers enumerated by the audit; UI/Sandbox are JSON. Existing source common/42 layout and canonical Mod ID are retained |

[VERIFIED source] The audited medical handlers do not call a Lua authorization veto.
[UNKNOWN] No safely exposed pre-subscription veto was established. An event after
receiving health data, client-only modal, or polling stop cannot guarantee that data
was never delivered. None is substituted for server authority. Claims are scoped
to the audited surface, not an assertion about all future Build 42 versions.

Required features BLOCKED: mandatory per-check consent, persistent auto-approval,
four-policy enforcement, authorized session validation/revocation, denial/timeout
anti-spam for actual examinations, and stopping medical-data delivery on reconnect.
Stored preference/metadata behavior does not satisfy those gameplay requirements.

Lua-only alternative implemented: retain the complete vanilla request/approval,
health panel and treatment flow; expose honest server-owned saved intent/status.
Optional future cooperative UI convenience could be designed as expressly
non-authoritative, but is not implemented or represented as privacy/security.
A future vanilla exposed server veto would require a new source audit and tests.

[RUNTIME GATE] No current PZ, SP, hosted or dedicated execution occurred. Historic
Java-era successes/failures are historical only, not Lua-only runtime evidence.
