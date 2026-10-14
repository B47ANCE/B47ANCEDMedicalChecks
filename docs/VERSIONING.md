# Version and artifact inventory

Project Version: 0.2.0-dev.2

Root VERSION remains authoritative. PR review advances 0.2.0-dev.1 to
0.2.0-dev.2 for PATCH-compatible fixes within the existing development scope;
no schema or protocol change, stable release, or runtime validation is implied. This is an initial 0.x MINOR development
iteration with explicitly incompatible scope: the agent dependency and active
examination protocol are withdrawn; old properties are not automatically migrated.
Metadata schema/protocol 2 are separate from project SemVer and PZ 42.21.

version-inventory.json lists current metadata, Lua config, docs and changelog mirrors.
The historical native constant/JAR and dist/current Java-era ZIP retain their actual
old versions and hashes; they are not current mirrors. Historical reports were
copied before editing, not relabelled as current test evidence. No artifact was deleted.

New artifacts, only on explicit request, use dist/lua-only-current/. Old folders
are preserved even where their names say current. Active packaging inputs exclude
native, history, research, old artifacts, private diagnostic snapshots and handoff.
Package checks validate traversal, duplicates, case collisions, CRC/data, expected
members, per-file SHA-256, versions and exact source parity. No ZIP is built by the
normal build command. --release must check actual authorized artifacts before G8.

GitHub iteration source is on feature/lua-only-conversion in the verified public
B47ANCE/B47ANCEDMedicalChecks repository. PR #1 is reviewed and merged only after applicable checks pass under explicit
user authorization. Commit/push verification is reported with the
final iteration SHA; no stable tag, force push or deployment is authorized.
