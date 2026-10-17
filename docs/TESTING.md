# Cooperative dedicated-server test handoff

Project Version: 0.3.0-dev.7

Offline: python scripts/build.py with requirements-dev.txt; optional research-tool
fixtures use python -m unittest discover -s tests -p test_audit_medical_source.py with
Jawa 2.2.0. python scripts/package.py validates inputs only; no package is generated.
These tests are Python/Lupa mocks, never native packet or multiplayer evidence.
The build includes test_workflow_integration.py: isolated server/three-client Lua
states, copied protocol payloads, a deterministic message queue and mocked
file/event/UI adapters. It runs the real Authority, Store, Engine, Cooperative,
VanillaBridge, PreferencesUI and CooperativeUI modules. Duplicate/lost messages,
in-flight revocation, all policies, restart/reconnect and both Health Care mod-list
orders are covered without opening network sockets or launching PZ.

Run both supported offline hosts (requirements-dev.txt installs Lupa):

```powershell
python scripts/build.py
$env:B47MC_TEST_LUA = 'lua51'
python scripts/build.py
Remove-Item Env:B47MC_TEST_LUA
```

Default is lua54; any other host name is rejected. Lua 5.1 host success is useful
compatibility evidence, not a native Kahlua run. Neither host proves installed PZ
APIs, rendering, real file durability or actual network behavior.
GitHub Actions runs both hosts on Ubuntu for PRs/main. Its token has contents:read,
checkout does not persist credentials, official actions are SHA-pinned and it has
no publication/deployment/server steps or credentials. The workflow does not alter
branch protection and is not dedicated-server G7 evidence.

For separately authorized actual testing, use clean 42.21 dedicated server/clients,
a disposable cache/profile/save and at least three normal accounts with matching
protocol 3. Preserve a vanilla comparison run. Do not enable historical Java agents.

1. Player Choice + Always Ask: every normal Medical Check prompts; YES queues one
   vanilla examination, NO/timeout queues none and creates no remembered approval.
2. Only Ask Once: approve examiner A; subsequent requests from A skip the prompt,
   B still prompts. Reverse direction must prompt independently. Denial never remembers.
3. Force Always Ask ignores stored approval; Force Only Ask Once remembers after
   YES; No Examination Requests refuses this context workflow. Disable
   CooperativeConsent and verify the original vanilla flow returns.
4. Revoke A in settings: cancel A's pending offer/request, require A to ask again,
   retain B. Legacy inactive records remain separate. Already-open health panels
   remain vanilla.
5. Repeat clicks, duplicate/reordered responses, forged owner fields, wrong sender
   answers, movement/floor/death, timeout, disconnect/rejoin and object replacement:
   no extra Proceed, stale prompt or unintended action.
6. Test account/character changes, persistent approvals over reconnect/server restart,
   and session retention clearing on patient OR examiner disconnect and restart.
   Changing retention back to Persistent exposes the old stored records until revoked.
7. Back up both slot pairs; use disposable fixtures for unwritable storage, torn writes,
   missing newest/older slots, corrupted newest/older/both slots, schema rejection and profile isolation. Prior-slot
   recovery of approval data must disable requests for review, never reuse a possibly
   revoked older grant. New healthy profiles must restart normally. Confirm uncertain
   read-back failure handling; do not claim durable rollback.
8. Test all 29 English fallbacks/key presence, small/large fonts, resolutions, mouse,
   keyboard/controller focus, split-screen slots, prompt duplicate/timeout cleanup,
   client/server mismatches, absent modded peer and headless startup. No private data
   should be broadcast to other players. Inspect server/client errors and timing.
9. Compare examination duration, health visibility at each First Aid level, treatment,
   inventories, movement/vehicle restrictions and health panel behavior to vanilla.
   The client calls the original examination callback; native runtime equivalence
   still requires observation. No server treatment wrapper was added.

Every actual row is currently NOT TESTED. Record exact source/package/class hashes,
roles, settings, results and anonymized logs. Repeat the applicable scenarios on
player-hosted multiplayer and record that result separately from dedicated tests.
G7 and stable G8 remain BLOCKED until their required runtime evidence exists.
Copy RUNTIME_TEST_RECORD.md to an ignored local evidence directory for each run.
Complete hosted and dedicated records separately and preserve raw logs locally;
only reviewable anonymized summaries belong in Git. The .7 candidate is not a
Workshop upload: record which exact source/package is actually installed before
testing and never use older .6 subscription results as proof for .7 UI changes.

## Health Care combinations

For both player-hosted and dedicated tests, record the exact enabled mod IDs and
Health Care version. Begin with disposable profiles and matching client/server mod
sets. Test Medical Checks alone and with unrelated mods: prompts, policies,
preferences, revocation, reconnect and restart must retain their prior behavior.
Then enable B47ANCEDHealthCare and fully restart server/clients. Medical Checks
must add no settings context entry, prompt, wrapper or server handlers and must
leave its existing files unchanged; Health Care must own the replacement features.
Repeat with both script orders where the test setup supports it. Disable Health
Care, restart, and verify Medical Checks resumes with its original preferences and
approvals. Verify its inactive sandbox tooltips and console notice. Do not infer
Health Care feature parity from silence in Medical Checks. All these runtime
combinations remain NOT TESTED; source/offline results are not G7 evidence.

## Controller and viewport regression reproduction

In a second split-screen slot with a controller, open Medical Checks settings.
Navigate the preference, examiner list, revoke and refresh controls. A enters the
list; B returns to the window. With the preference combo expanded, B must dismiss
the combo before closing the window on the next B. Closing via B/title button and
disconnecting must release settings focus. While settings own focus, receive an
examination prompt and answer or let it expire: focus should return to settings.
Repeat on the first local slot and confirm no focus is assigned to the other slot.

At a 640x360 per-player viewport, the initial settings rectangle must remain within
that player's screen. Inspect text/list/button clipping with small/large fonts,
and repeat at normal full-screen resolution. Offline arithmetic/focus regressions
pass; actual controller/viewport rendering remains NOT TESTED.
