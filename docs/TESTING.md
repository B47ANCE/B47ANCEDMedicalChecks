# Cooperative dedicated-server test handoff

Project Version: 0.3.0-dev.3

Offline: python scripts/build.py with requirements-dev.txt; optional research-tool
fixtures use python -m unittest discover -s tests -p test_audit_medical_source.py with
Jawa 2.2.0. python scripts/package.py validates inputs only; no package is generated.
These tests are Python/Lupa mocks, never native packet or multiplayer evidence.

For separately authorized actual testing, use clean 42.21 dedicated server/clients,
a disposable cache/profile/save and at least three normal accounts with matching
protocol 3. Preserve a vanilla comparison run. Do not enable historical Java agents.

1. Player Choice + Always Ask: every normal Medical Check prompts; YES queues one
   vanilla examination, NO/timeout queues none and creates no remembered approval.
2. Only Ask Once: approve examiner A; subsequent requests from A skip the prompt,
   B still prompts. Reverse direction must prompt independently. Denial never remembers.
3. Force Always Ask ignores stored approval; Force Only Ask Once remembers after
   YES; No Examination Requests refuses this context workflow. None protects native
   packets. Disable CooperativeConsent and verify the original vanilla flow returns.
4. Revoke A in settings: cancel A's pending offer/request, require A to ask again,
   retain B. Legacy inactive records remain separate. Already-open health panels
   remain vanilla; do not interpret this as native-session revocation.
5. Repeat clicks, duplicate/reordered responses, forged owner fields, wrong sender
   answers, movement/floor/death, timeout, disconnect/rejoin and object replacement:
   no extra cooperative Proceed, stale prompt or unintended action. Native adversarial
   packet tests remain outside this workflow's protection claims.
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
roles, settings, results and anonymized logs. A cooperative-flow PASS must not be
reported as native privacy PASS. MEDICAL_SECURITY_MATRIX.md's 15 security cases
remain NOT TESTED; G7 and stable G8 remain BLOCKED.
