# Requirements disposition

The user requested a Lua-only conversion, preservation of historical Java research,
all safely supported work, and explicit authority blockers. This authorizes source
changes, not insecure scope substitution, deployment, publication or game launch.

Implemented: server-owned saved preference metadata, all four configured-policy
diagnostics, individual inactive-record revocation, private persistent metadata,
protocol validation, owner-only synchronization, status/settings UI, localization,
Lua-only build/package preflight, regression tests and historical retention.

Blocked: operational Always Ask/Only Ask Once and all policy enforcement, grant
creation/reuse, medical-data session revocation, actual-exam denial cooldown/timeout,
session retention and security against raw subscription packets. None is activated.

Sandbox candidate assessment: keep the six established identifiers and defaults.
Policy/default preference affect settings only; retention/cooldown/timeout/debug
are labelled reserved/inactive. No new micro-settings or hardcoded gameplay rules
are introduced. Technical storage limits remain internal. Vanilla treatments,
First Aid gates and interaction restrictions are not changed.
