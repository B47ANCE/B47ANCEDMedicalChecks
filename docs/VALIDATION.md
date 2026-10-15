# Current evidence - 2026-10-14

Project Version: 0.2.0-dev.3

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
The post-review current run passed 49 offline tests. Coverage includes
owner derivation, private snapshots, all-policy non-enforcement, preference persistence,
individual metadata revocation, write failures, partial writes, restart fixtures,
unsupported schema, profile isolation, client status UI, vanilla preservation,
localization key/value parity, package path checks and protected historical hashes.

Source audit: recorded original vanilla hashes match; effective loose LuaEventManager
override is UNKNOWN. This proves source identity, not clean or working native runtime.
Package command: STATIC PASS planned inputs only; no development ZIP generated.
No version --release PASS is claimed without an authorized current artifact.

PR #1 has no CI checks configured, no branch protection and no repository rulesets at review time; no required checks are bypassed. Local checks below are offline evidence only. GitHub backup only counts once final push
matches the local feature-branch SHA; that receipt is retained locally and reported
in the final response. No secrets/private diagnostics/generated files are intended
for the public commit. Historical local sources/artifacts remain excluded.

Actual SP/hosted/dedicated, Linux execution, rendering, live save/cache restart and
medical functionality: NOT TESTED. G7 and stable G8 remain BLOCKED by missing runtime
evidence and the unresolved server consent authority capability.

PR review regressions: rapid mutation feedback and floating-point preference storage
both failed before the fix and pass afterward. Client rejection restores the saved
selection. A complete write followed by failed read-back remains recoverable on
restart despite StorageFailed; this explicitly tests uncertain persistence rather
than claiming durable rollback. The previous 45-test run belongs to 0.2.0-dev.1.

## Medical authority research amendment — 2026-10-14

Baseline/source: 0.2.0-dev.2, merged main
e01f20dde6ea94185c0bdd7dda7c9e64c04d6c63. No automatic version increment:
research documents and read-only development tooling only. Production src/ and
metadata, schema/protocol, localization and protected artifacts are unchanged.
Research branch: research/medical-authority-audit, separate checkout from main.
Final research commit/push receipt is reported separately, not fabricated here.

[TESTED offline] Windows, bundled Python 3.12, Lupa 2.6; optional Jawa 2.2.0
for bytecode reading only (not a mod/runtime dependency). No JVM, custom Java,
game/server, packet experiment, local deploy, Workshop upload or new package.
Actual developer dependency install used the existing ignored .venv-test directory
in the original repository; PYTHONPATH pointed there for the separate checkout.
Portable reproduction can install requirements-dev.txt and jawa==2.2.0 in a
disposable Python virtual environment. The tool does not require installing Java.

Exact commands from the research checkout (Python path as above):

```powershell
# This machine's existing ignored development dependencies; not shipped in the mod.
$env:PYTHONPATH = (Resolve-Path ../B47ANCEDMedicalChecks/.venv-test).Path
& $py scripts/check_versions.py
& $py scripts/audit_source.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"
& $py scripts/audit_medical_source.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output research/authority-audit-v3
& $py scripts/audit_medical_source.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output research/authority-audit-v3-recheck
$first = Get-Content research/authority-audit-v3/evidence.json -Raw
$second = Get-Content research/authority-audit-v3-recheck/evidence.json -Raw
if ($first -cne $second) { throw "Evidence differs between runs" }
& $py scripts/build.py
git diff origin/main -- src VERSION version-inventory.json requirements-dev.txt
git diff --cached --check
```

The new source-audit output directory must not exist, and must be outside the game
installation. The initial discovery outputs were retained separately; the final
named v3 output is the document reference. Its hashes match the independent recheck.
44 original-JAR/Lua inputs, no missing selected class/file. Public hash-only evidence:
docs/medical-authority-evidence.json. Full bytecode and numbered upstream listings
are ignored local research, not distributed copyrighted source.

Results: Lua-only/case preflight PASS, version consistency PASS; offline suite
49 discovered, 48 PASS and one SKIP (private local historical manifest is absent
from this clean Git worktree). The earlier 49 PASS run was in the original checkout
with that fixture present; it is not relabelled as a new 49 PASS. Existing native
baseline fingerprints MATCH. All extended inputs and output hashes were rechecked.
src/ and version/metadata/dependency diff against origin/main is empty.
The original checkout's preservation manifest was also checked independently:
all 148 protected historical file SHA-256 values still match. Public staged-file
credential/path scan and whitespace checks passed; full upstream listings and
local installation details beyond hash identifiers are excluded from the commit.

The larger selection finds differing loose IsoPlayer, LuaEventManager and Event
classes. Effective loading is UNKNOWN; use an unmodified clean 42.21 installation
for future observations. Original JAR source identity is not effective-runtime proof.
The audit tool proves bytecode call sites and packet handling flags, not secure
native enforcement. No new --release result or distribution readiness is claimed.

[VERIFIED source] Medical complete is called on the server and its result is used;
BodyPartSync is client-handled (handlingType 2); native health START and sends lack
the required Lua veto. Health-command permission/target coverage remains a source
gap. Threats and all 15 required engine tests are in MEDICAL_SECURITY_MATRIX.md.

[RUNTIME GATE] Every security-matrix engine row, approved and denied examination,
first health disclosure, unauthorized treatment, spoof/replay/malformed traffic,
concurrency, expiry, revocation, disconnect/reconnect, ID reuse, restart and modified
client: NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. See the feasibility
document for the single overall conclusion and bounded next research step.

## PR #2 review amendment — 2026-10-14

At unchanged 0.2.0-dev.2, corrected the research tool to reject a missing selected
method explicitly rather than silently emit incomplete evidence. The fixture for
this failure failed before the fix, then passed; a second fixture verifies all
overloads are retained. No runtime source, existing regression, schema or metadata
behavior changed. These Python/Jawa tests are optional research tests, separate
from the Lupa runtime-mock suite; they do not execute a JVM.

Additional exact commands, using the same $py/PYTHONPATH above:

```powershell
& $py -m unittest discover -s tests -p test_audit_medical_source.py -v
& $py scripts/audit_medical_source.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output research/pr2-review
& $py scripts/build.py
```

[TESTED offline] Two research-tool fixtures PASS; standard suite 48 PASS, one
private-history SKIP; Lua-only/case and version checks PASS. Regenerated source
and listing hashes match all 44 original entries exactly. The evidence manifest
updates the tool hash and retains its previous hash and research revision;
source/output evidence and native line references are unchanged.

GitHub review found no configured checks, branch protection or repository rulesets;
no required checks are bypassed. Consent enforcement remains BLOCKED, server
treatment complete remains PROVISIONAL for consent validation, effective loose
overrides remain UNKNOWN, and dedicated multiplayer/all 15 engine security cases
remain NOT TESTED. G7 and stable G8 remain BLOCKED. Merge is research integration,
not deployment, a stable release or runtime evidence.
