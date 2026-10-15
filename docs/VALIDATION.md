# Cooperative validation â€” 2026-10-14

Project Version: 0.3.0-dev.1

Baseline: main 85e29ca811ae70ed08bb75613cf4892837a3c867 (0.2.0-dev.3).
Target 0.3.0-dev.1: additive MINOR cooperative feature; protocol 3, storage schema 2.
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

[TESTED offline] Main suite: 81 discovered, 80 PASS, one SKIP because private
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
