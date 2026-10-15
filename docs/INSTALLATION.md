# Installation and migration limits

Project Version: 0.2.0-dev.3

This is a settings/status scaffold, not a functioning consent-security mod.
Do not deploy or publish it as examination protection. No deployment or launch was
performed. A future explicitly authorized isolated test uses only the
src/B47ANCEDMedicalChecks directory with common/ and 42/; enable the canonical Mod ID.
No custom Java component is permitted. Do not use the historical agent or its launch
configuration. Any previously configured agent must be removed by the operator
before testing the Lua-only source; this conversion did not edit external launchers.

Clients and server must both use the current Lua source and protocol 2. Old client
wrappers are unsupported; do not overlay a partial update that leaves old owned
files active. Single-player has no active metadata editor; vanilla stays unchanged.

Right-click in multiplayer to open Medical consent status and saved preferences.
The interface states that enforcement is blocked. Preference changes save only
inactive intent. Revoke removes only an existing stored metadata record, not engine
access. No saved record authorizes an examination.

New metadata is stored in the server Lua cache, per getServerName(), in two
B47MC_<hex profile> snapshot files. Missing storage is initialized through the
exposed APIs; unreadable/corrupt storage disables changes. Back up both slots.
No old Java .properties file is read, changed, renamed or imported. Schema 1 -> 2
authorization migration is deliberately unsupported. Restore historical evidence
only for inspection; it is not a currently permitted runtime rollback path.

Do not run multiple servers against the same cache/profile. A new profile starts
separate metadata. Sudden power loss, permissions, actual cache location and native
read/write semantics need dedicated runtime tests before persistence claims.
