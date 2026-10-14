# Current evidence - 2026-10-14

Project Version: 0.2.0-dev.1

Environment: Windows offline, Python 3.12 with Lupa 2.6 in an ignored local
.venv-test dependency directory. The original 42.21 JAR and installed Lua are
read-only source evidence. No game/server or custom Java is executed.

Exact commands from the project root (the commands below resolve the same bundled Python used for this run):

```powershell
$py = Join-Path $env:USERPROFILE ".cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe"
& $py scripts/build.py
& $py scripts/audit_source.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"
& $py scripts/package.py
git diff --cached --check
git status --short
```

The build command runs scripts/preflight.py, scripts/check_versions.py --root <root>,
and scripts/test.py. Results: STATIC PASS Lua-only active source/require case;
version consistency PASS with no current artifact deferred; OFFLINE regression PASS.
The final current run passed 45 offline tests. Coverage includes
owner derivation, private snapshots, all-policy non-enforcement, preference persistence,
individual metadata revocation, write failures, partial writes, restart fixtures,
unsupported schema, profile isolation, client status UI, vanilla preservation,
localization key/value parity, package path checks and protected historical hashes.

Source audit: recorded original vanilla hashes match; effective loose LuaEventManager
override is UNKNOWN. This proves source identity, not clean or working native runtime.
Package command: STATIC PASS planned inputs only; no development ZIP generated.
No version --release PASS is claimed without an authorized current artifact.

CI is not configured by this iteration. GitHub backup only counts once final push
matches the local feature-branch SHA; that receipt is retained locally and reported
in the final response. No secrets/private diagnostics/generated files are intended
for the public commit. Historical local sources/artifacts remain excluded.

Actual SP/hosted/dedicated, Linux execution, rendering, live save/cache restart and
medical functionality: NOT TESTED. G7 and stable G8 remain BLOCKED by missing runtime
evidence and the unresolved server consent authority capability.
