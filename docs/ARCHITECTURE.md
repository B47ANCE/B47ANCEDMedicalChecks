# Lua-only architecture

Project Version: 0.2.0-dev.2

Scope is server-owned settings metadata, not examination authorization. The client
submits protocol-2 Snapshot, Preference or Revoke intent. Vanilla OnClientCommand
derives its player argument from the authenticated connection; the server uses only
that player's unqualified getUsername() as account owner. Client owner, username,
patient or account fields never select the owner. Character/display renames do not
change that key. An actual login-account rename is a new identity; no guessed
migration or case normalization transfers approvals.

Snapshots go through targeted sendServerCommand(player,...), never a global
broadcast or requestable ModData table. They contain only that account's saved
preference, configured/effective policy diagnostics and inactive metadata records.
Every snapshot has enforcement=false. Request/Answer/Grant intents cannot create
authorization or a new record; no tickets, leases, sessions or medical hooks exist.
Malformed/old protocols cannot mutate metadata. Per-player weak-key throttling
bounds disk mutations and repeated reads. Throttled Preference/Revoke intents return
a private RateLimited snapshot so the UI restores the saved value and asks for retry;
these replies are not a network bandwidth limiter. There are no per-tick player/world scans.

Store.lua uses only exposed getFileReader/getFileWriter, readLine/write/close.
Two private ASCII snapshot files live in the server Lua cache, named
B47MC_<hex server profile>_a.txt and _b.txt. This intentionally stores account
metadata per server profile rather than character or world save. Back up both
files with server configuration. One process must exclusively own that cache/profile.
Another profile is isolated; a world reset under the same profile retains metadata.

Schema 2 records are P (preference) and G (inactive directional metadata). There
is no production grant-creation command. Existing record revocation is implemented
for valid schema-2 records, but the old agent properties are NOT imported and new
installs have empty lists. Tests use disposable trusted record fixtures, not grants
created by gameplay. Session retention cannot be represented as operational consent
and remains blocked, as do automatic reuse and denial/timeout handling.

Alternating-slot persistence writes only the inactive slot, closes it, reads it
back and validates a complete checksummed snapshot before acknowledging a change.
The previous committed slot remains available on partial writes. A damaged slot
can recover from the valid slot with a console diagnostic. Both invalid/unreadable
slots or a future schema disable mutations rather than resetting records. Equal
generation conflicts are rejected. Checksums detect incomplete writes, not hostile
server filesystem edits. No fsync/atomic-rename or sudden power-loss guarantee is
claimed for these exposed APIs. A complete disk write followed by a read-back failure
returns StorageFailed and retains the previous in-memory value, but restart can select
the newer complete slot. This is an uncertain outcome, not guaranteed rollback;
refresh after restart before retrying. Only inactive metadata is affected. Java-era properties and real player saves are untouched.

Policy (four enum values) and DefaultPreference (two) affect saved-settings
interpretation/presentation only. Forced choices disable the editor, but never
enforce health-data access. Retention, RequestCooldown, RequestTimeout and
DebugLogging keep their stable sandbox identifiers for compatibility and are
explicitly reserved/inactive. Removing Java also removes their execution paths;
their tooltips never claim enforcement. Invalid enum values fall back to safe
defaults rather than clamping to No Requests. Existing metadata retains saved choices.

Internal limits bound storage/protocol work: 128-byte identifiers, 4096 accounts,
128 inactive records per account, 2 MiB snapshots and 250 ms command cadence. These
are implementation limits, not balance settings. No treatment or skill settings are added.

The UI uses vanilla collapsing windows, labels, combo box, list and buttons. A
single deduplicated status/settings context entry adds no medical interaction.
Inactive status is always visible. Source medical callbacks and events are untouched.
All 29 installed vanilla locales receive matching English fallback JSON tables.
Actual font/resolution/controller use remains a runtime gate, not mock verification.
