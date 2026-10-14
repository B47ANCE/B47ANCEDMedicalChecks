# Validation and dedicated test handoff

Project Version: 0.2.0-dev.2

From the project root, using a Python environment with requirements-dev.txt:

```text
python -m pip install --only-binary=:all: -r requirements-dev.txt
python scripts/build.py
python scripts/audit_source.py --game "<installed PZ root>"
python scripts/package.py
```

build.py performs Lua-only preflight, canonical version checks, syntax and offline
regressions. package.py without --development verifies input planning only and does
not create an artifact. No custom Java is built or invoked. --release version checks
remain blocked/deferred when there is no current authorized Lua-only package.

Actual dedicated tests, only with separate launch/deploy authorization: use a clean
isolated 42.21 server, disposable cache/profile and at least two separate accounts.
Verify no custom agent remains enabled; require the explicit BLOCKED console message.
Open status UI, edit saved preferences, reconnect/restart and verify the record.
Forge owner/username/patient fields and ensure only sender-owned metadata can change.
Test all four policies: diagnostics must change, vanilla consent must remain unchanged.
New requests/acceptance must create no grants. Test revocation only against trusted
disposable metadata fixtures; do not mistake it for revoking engine access.

Test read/write permissions, one corrupted slot, two corrupted slots, schema rejection,
restart recovery and profile isolation. Preserve both slot files before experiments.
Test legacy client protocol rejection, out-of-order snapshots, disconnect cleanup,
font/resolution/controller readability and headless startup. Check actual Windows
and Linux path case and exposed APIs separately. No offline check is Linux proof.

Compare original vanilla Medical Check, patient prompt, health panel, action duration,
First Aid visibility, treatment inputs and inventory restrictions. Direct raw medical
subscription behavior is an unresolved vanilla boundary, not a test the scaffold
claims to secure. G7 stays BLOCKED; do not mark gameplay/privacy functional.
