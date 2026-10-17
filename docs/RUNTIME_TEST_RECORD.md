# Runtime test record template

Project Version: 0.3.0-dev.7

Status: NOT EXECUTED. This blank template is not evidence of any runtime pass.
Copy into an ignored local evidence folder for each actual run. Run hosted and
dedicated separately. Follow TESTING.md for setup and detailed procedures.

## Run identity

- Date/time and tester: TO RECORD
- Environment: player-hosted / dedicated (choose one)
- Actual PZ client/server versions and Steam build IDs: TO RECORD (target 42.21)
- Actual Medical Checks version, source commit and package SHA-256: TO RECORD
- Workshop subscription/download verification, if used: TO RECORD
- Server OS and disposable profile identifier (anonymized): TO RECORD
- Enabled Mod IDs/order and Health Care version, if used: TO RECORD
- Client roles: patient P, examiner A, second examiner B (three real accounts)
- Matching client/server files, protocol and server settings: TO RECORD
- Vanilla comparison run/version: TO RECORD
- Local raw log locations and anonymized evidence references: TO RECORD

Do not commit raw logs, account identifiers, IPs, credentials or real player saves.
Record the actual installed build; a successful upload or an offline fixture does
not satisfy any runtime row. Preserve original files before fault injection.

## Required results

Replace NOT TESTED only after observation, with PASS/FAIL, evidence reference and
notes. Record exactly which sandbox settings were active for each row.

| ID | Scenario and pass criteria | Result | Evidence / notes |
| --- | --- | --- | --- |
| R01 | Clean server startup, three joins, settings round-trip; no mod errors | NOT TESTED | |
| R02 | Player Choice/Always Ask: each request prompts; YES starts one vanilla check; NO and timeout start none | NOT TESTED | |
| R03 | Only Ask Once: P approves A; A skips later prompts, B still prompts, reverse direction prompts; denial remembers nothing | NOT TESTED | |
| R04 | All four policies: Player Choice, Force Always Ask, Force Only Ask Once, No Examination Requests; forced preferences cannot be edited | NOT TESTED | |
| R05 | Individual revoke retains other examiner; cancels pending offer; subsequent request prompts; already-open health panel remains vanilla | NOT TESTED | |
| R06 | Persistent approvals/settings survive either participant reconnect and server restart; new character/same account follows account identity | NOT TESTED | |
| R07 | Session approvals clear on either disconnect and restart; switching back to Persistent exposes prior saved approvals until revoked | NOT TESTED | |
| R08 | Movement, floor/death, object replacement, repeated clicks and delayed responses produce no stale prompt or duplicate action | NOT TESTED | |
| R09 | Backed-up disposable storage: unwritable, damaged/missing slots, torn writes, unsupported schema and profile isolation; no older revoked grant is restored | NOT TESTED | |
| R10 | CooperativeConsent disabled restores original context flow; mismatched/missing modded peer times out without unexpected action | NOT TESTED | |
| R11 | Mouse/keyboard, controller slots, combo/list/back navigation, prompt focus return and disconnect cleanup | NOT TESTED | |
| R12 | 640x360 split-screen and normal resolutions, small/large fonts, 29 locale fallbacks: readable controls and no clipping | NOT TESTED | |
| R13 | Vanilla comparison: First Aid duration/visibility, treatments, inventory, movement/vehicles and health-panel lifecycle | NOT TESTED | |
| R14 | Medical Checks alone and with unrelated mods: ordinary workflow still works | NOT TESTED | |
| R15 | Both Health Care mod orders after full restart: Medical Checks adds no settings, prompts, wrapper, handlers or file writes | NOT TESTED | |
| R16 | Remove Health Care and fully restart: Medical Checks resumes with preserved preferences/approvals; separately record replacement-feature parity in Health Care | NOT TESTED | |

R09 uses disposable copies only. Record errors and retain damaged slots before
recovery; do not experiment on a live profile. Review packet duplication/reordering
through the offline harness if no authorized runtime transport fixture exists;
mark those runtime observations NOT TESTED rather than fabricating a result.

## Outcome

- Observed failures and reproduction: NONE RECORDED (run not executed)
- Fix commit and targeted rerun, if needed: NOT APPLICABLE YET
- Hosted status: NOT TESTED
- Dedicated G7: BLOCKED / NOT TESTED
- Stable-release G8: BLOCKED

Review the complete dedicated evidence before changing G7. A partial run, hosted
pass, Workshop upload, offline suite or blank checklist cannot make G7 PASS.
