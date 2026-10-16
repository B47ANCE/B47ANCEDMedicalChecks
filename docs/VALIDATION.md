# Cooperative validation â€” 2026-10-14

Project Version: 0.3.0-dev.6

## Current Health Care compatibility iteration — 2026-10-16

Baseline main bb9562a45485e73123e292c64623af809e52eb27, version 0.3.0-dev.5.
Target 0.3.0-dev.6: PATCH-compatible startup guard for owner-specified Mod ID
B47ANCEDHealthCare (Workshop identity supplied as 3788592396). Installed source
API evidence and its client/server limits are in health-care-api-evidence.json and
COMPATIBILITY.md. Health Care code is not installed/inspected or changed.

[TESTED - offline Windows/Python/Lupa] `python scripts/build.py`: 97 run, 96 passed,
one historical-fixture skip. Twelve compatibility fixtures cover exact, unrelated,
near-match and separator IDs, unavailable API/list, and client/server entry points
before UI/events/storage. Existing standalone request/policy/storage/UI tests pass.
All 12 compatibility scenarios also PASS on the offline Lupa Lua 5.1 host;
this is not a native Kahlua/PZ runtime test. Translation keys remain stable across the 29 fallback locales. Script/module
startup order is represented by no Health Care globals being present in fixtures.
`python scripts/check_versions.py`, `python scripts/package.py` (plan only),
and `git diff --check` PASS for this iteration; no package or --release claim is made without artifacts.
Historical .5 publication, its original package and receipt remain unchanged.

[RUNTIME GATE] Actual standalone/co-enabled player-hosted and dedicated behavior,
native active-mod-list startup timing, Health Care feature parity, UI and save
reactivation are NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
No game/server launch, deployment, Workshop upload or Health Care data migration.

## Historical wording iteration — 2026-10-16

0.3.0-dev.4 -> 0.3.0-dev.5 is PATCH-compatible presentation/documentation work.
Request handling, server-owned state, persistence, policy, protocol/schema and
artwork remain unchanged. Historical sections below retain their original findings.

[TESTED - offline Windows/Python/Lupa] `python scripts/build.py` PASS: 84 tests
run, 83 passed, one skipped because the local historical preservation fixture is
not distributed. This covers Lua syntax, localization, request behavior, policies,
storage and package fixtures. `python scripts/package.py` PASS (input plan only).
`python scripts/check_versions.py` PASS; `git diff --check` PASS. Direct baseline
comparisons confirm unchanged runtime logic and sandbox configuration, stable
translation keys/placeholders across 29 fallback locales, unchanged artwork and
historical audit files, and verified pre-edit snapshot hashes. No new tests were
added for text replacement.
Player-hosted/dedicated multiplayer and visual rendering remain NOT TESTED.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No current artifact was generated.

## Historical API correction: 0.3.0-dev.3

PATCH-compatible development iteration from ab9363df4b6f0aa7820768503f19cb076f0f6d73.
Replace only the fresh-store emptiness check with a local pairs loop. No global
shim, protocol/schema change, grant migration or native medical authority change.
The inspected Steam build 25485521 Kahlua bootstrap registers pairs and global
unpack; global next is not registered there or added by the inspected root
stdlib.lua. This is bounded source evidence, not an observed game failure.

[TESTED offline] The missing-next regression fails against the original module
and passes with the correction under Windows host Lua 5.1 (Lupa). It exercises
fresh slot seeding, a populated store, failed writes, recovered and incomplete
stores. `python scripts/build.py`: 84 discovered, 83 PASS, one historical-fixture
SKIP. `python -m unittest discover -s tests -p test_audit_medical_source.py -v`
with the existing ignored Jawa dependencies: two PASS. `python scripts/check_versions.py`:
PASS. No package was built. SP/dedicated NOT TESTED; G7/stable G8 BLOCKED.

## Historical cooperative validation: 0.3.0-dev.2

The report below records earlier runs; it is not current-version runtime proof.

Baseline: main 85e29ca811ae70ed08bb75613cf4892837a3c867 (0.2.0-dev.3).
Target 0.3.0-dev.2: MINOR cooperative feature plus PATCH-compatible PR review fixes; protocol 3, storage schema 2.
Prior reports are preserved in Git at the baseline and locally in
history/pre-cooperative-0.2.0-dev.3 with SHA-256. Prior medical research remains
pinned to its actual source revision, not upgraded to current runtime evidence.

Environment: Windows offline, bundled Python 3.12, Lupa 2.6. Optional source-tool
fixtures use Jawa 2.2.0. PYTHONPATH points to the original checkout's ignored
.venv-test developer dependencies; none is a mod/runtime dependency.

Exact commands from this feature checkout:

```powershell
$py = Join-Path $env:USERPROFILE ".cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe"
$env:PYTHONPATH = (Resolve-Path ../B47ANCEDMedicalChecks/.venv-test).Path
& $py scripts/write_localization.py
& $py scripts/build.py
& $py -m unittest discover -s tests -p test_audit_medical_source.py -v
& $py scripts/audit_source.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"
& $py scripts/package.py
& $py scripts/check_versions.py
 git diff --cached --check
```

[TESTED offline] Main suite: 83 discovered, 82 PASS, one SKIP because private
historical fixture files are not distributed into the clean worktree. Two optional
research-tool tests PASS separately. Lua-only/case, syntax, 29-locale fallback/key
parity, version consistency and package-input planning PASS. No ZIP generated.
Native source fingerprints MATCH; the known loose overrides leave effective
runtime UNKNOWN. See cooperative-api-baseline.json for the additional UI API
source fingerprints and exact method/line references.

Coverage: every cooperative policy/preference, refusal without grants, directional
persistence, no legacy grant activation, participant/owner spoof rejection in mod
intents, one-time confirmation, repeated/out-of-order client messages, prompt cleanup,
cooldown and pending caps, policy/preference/retention changes, movement/death/floor,
disconnect object replacement, session cleanup, restart fixtures, revocation and
corrupt-slot recovery blocking. Client mocks prove only the intended callback and
messages; they do not execute vanilla timed actions or a native server.

No runtime wrapper for treatment was added. Native events, timed actions, medical
packets and engine data subscriptions remain unchanged; only the ordinary client
context callback is wrapped, with SP left alone and explicit disabled-mode fallback.
Artwork and protected historical artifacts are hash-checked; original Java research
is preserved, never executed, built, shipped or activated.

[RUNTIME GATE] Actual dedicated/SP/hosted play, UI rendering, keyboard/controller,
split-screen, exposed engine I/O, Linux execution, native treatments/First Aid,
real reconnect/restart and mixed-client behavior: NOT TESTED. The 15 native security
matrix rows remain NOT TESTED. Cooperative convenience does not satisfy the native
security contract. Native server consent BLOCKED; treatment consent validation
PROVISIONAL and unimplemented; G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

No automatic game/server launch, deployment, package, Workshop upload, stable tag
or merge. Current source belongs on a public feature branch/draft PR for review;
final commit/push receipt is reported separately. Public-file scans exclude private
cache data/logs, historical full source listings, generated dependencies and artifacts.

PR #4 review: missing-slot recovery could reuse an older cooperative grant after a
newer revocation slot disappeared, and disabled-mode fallback could call vanilla
with a stale patient object. Both new fixtures failed before the fixes and pass
afterward. Store exposes fresh/missing-slot diagnostics without changing schema,
legacy settings recovery, or the two-slot codec. Cooperative existing profiles
with a missing slot are disabled for review; fresh empty profiles still seed both
slots. Fallback now rechecks object identity and vanilla eligibility.

GitHub has no configured status checks, branch protection or rulesets at review
time; no required checks are bypassed. Merge authorization is for PR #4 integration
only, not release readiness. Cooperative-only limitations, provisional treatment
finding and NOT TESTED multiplayer remain unchanged. Prior 80-pass results belong
to 0.3.0-dev.1; the 82-pass result above is the post-review run.

## Thumbnail iteration — 2026-10-15

0.3.0-dev.3 -> 0.3.0-dev.4 is a PATCH-compatible artwork/packaging-input iteration.
The gameplay results above remain historical to their stated versions. Current
thumbnail checks: supplied PNG signature, all chunk CRCs, dimensions (1254x1254),
exact byte copy and SHA-256 PASS. Icon/poster and fallback asset hashes remain
unchanged. Version checks and package-input planning pass; no ZIP is generated.
Native authority/cooperative limitations and all NOT TESTED runtime gates persist.
Exact commands: python scripts/check_versions.py; python scripts/package.py;
git diff --cached --check. Source-to-thumbnail and planned package thumbnail bytes
were compared directly in offline Python; no game/Workshop rendering proof is claimed.

## Workshop distribution evidence — 2026-10-16

Published 0.3.0-dev.5 to public item 3820690174 from source commit
b79913450f70134c5e5545be3de32128c1b54a5f. `python scripts/build.py`: 83 passed and one
historical-fixture skipped. `python scripts/package.py --development` and
`python scripts/check_versions.py --release` passed on the exact committed
snapshot. All 71 staged runtime files matched source hashes.

Initial creation succeeded, then SteamCMD rejected the oversized PNG preview.
The same assigned item was retried with a JPEG encoding of the supplied artwork;
SteamCMD exited 0 and reported Committing update...Success. Steam API verified
App ID 108600, public visibility 0, expected title and exact canonical description.
The verified Steam desktop executable exited gracefully and restarted; its process
was observed. See PUBLICATION-0.3.0-dev.5.json for package/preview/source hashes.

No game/server was launched or modified. Subscription/download, rendering and
actual player-hosted/dedicated behavior remain NOT TESTED. Public-page browser
rendering was unavailable; public API metadata verification passed. Distribution
evidence does not change G7 BLOCKED / NOT TESTED or stable G8 BLOCKED.

## PR #8 review — 2026-10-16

[TESTED - offline Windows/Python/Lupa] A clean-fixture release check reproduced
an inventory defect: the documented development package command generated only
dist/lua-only-current/, but two separate required artifact rules demanded a
Workshop copy as well. The added regression failed before correction with
No current package matches dist/workshop-current/*.zip. One current ZIP family,
dist/*-current/*.zip, now accepts the development output alone and continues to
reject stale Workshop copies. No archive is moved, replaced or recreated.

Exact checks: `python scripts/test.py Structure.test_release_check_accepts_development_zip_and_rejects_stale_workshop_zip`
PASS after failure before the inventory fix; `python scripts/build.py` PASS:
85 run, 84 passed, one historical-preservation fixture skipped.
`python scripts/check_versions.py --release`, `python scripts/package.py`
(input plan only), and `git diff --check` PASS. Canonical description rendering
was checked with Build-WorkshopDescription.py --check. Direct comparisons verify
all 71 published runtime hashes against both their recorded source commit and
current Git source, ZIP CRC/member/path/case/hash integrity, package/source-tar/
preview/description/changenote hashes, and the unchanged immutable receipt.
No runtime/artwork/version change or Workshop upload occurred during review.

[VERIFIED - current Steam API metadata] Item 3820690174 remains public under
App ID 108600 with the expected title and recorded content manifest. Its current
description differs from the exact text verified at publication time. The initial
all-fields live comparison therefore did not pass description equality; the
follow-up confirms text drift with unchanged content identity. Those live edits
are preserved, and future publishing instructions require comparison/reconciliation.
The original receipt remains an accurate upload-time record, not a current-page
text assertion. No later page edit is copied over or silently overwritten.

Player-hosted/dedicated multiplayer, subscription/download and in-game rendering
remain NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Source metadata/test
correction only: published 0.3.0-dev.5 and its immutable package remain unchanged.

## PR #9 publication preparation

Review kept runtime changes intact after 97 offline tests (96 PASS, one historical
fixture SKIP). Canonical publication text is now WORKSHOP_DESCRIPTION.txt in raw
Steam BBCode, preserving the current owner-edited live description and formatting.
Only the No Examination Requests policy phrase is corrected, plus the new Health
Care note, required MP-testing label and credits. The previous Markdown draft is
retained, explicitly retired, and is not a publish input. This is source preparation,
not evidence of an upload. In-game/dedicated gates remain NOT TESTED / BLOCKED.

## Version 0.3.0-dev.6 Workshop distribution — 2026-10-16

PR #9 merged as 10702b71fe1ee3ba810cd50e757c9641008b1993. The exact committed
snapshot passed `python scripts/build.py` (97 run: 96 passed, one historical
fixture skipped), `python scripts/package.py --development` and
`python scripts/check_versions.py --release`. Staged/runtime/source hashes,
archive CRC/member safety, case checks, Lua-only payload and canonical text passed.
The Windows checkout's CRLF bytes were compared against committed LF text for
canonical description/change-note parity; no source content was changed.

SteamCMD updated existing public item 3820690174, exited 0 and reported
Committing update...Success. Steam API confirms App ID 108600, public visibility 0,
expected title and exact canonical BBCode description. Content manifest changed
from the .5 value to 6314809169805698450; reported content size is 224421 bytes.
The same accepted preview encoding was reused; original artwork is unchanged.
The Steam desktop client exited gracefully and restarted; process startup observed.
See PUBLICATION-0.3.0-dev.6.json for source/package/staging/preview/text hashes.

This records distribution success. No local mod deployment, game/server launch,
Health Care modification or cleanup occurred. Actual standalone/co-enabled
player-hosted/dedicated behavior, subscription/download, Health Care feature parity
and rendering remain NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
