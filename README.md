# B47ANCE'd Medical Checks

Project Version: 0.2.0-dev.2

Lua-only development scaffold for Build 42.21, canonical Mod ID
`B47ANCEDMedicalChecks`. **Examination consent enforcement is BLOCKED.**

The server can persist each authenticated account's saved preference, report the
configured policy, and remove individual saved approval metadata records. Settings
and records are clearly labelled inactive. This build creates no approval grants,
does not bypass requests, and does not replace vanilla medical events, actions,
panels, treatment mechanics or First Aid visibility. Vanilla examination requests
remain unchanged under every configured policy.

The audited native subscription handler has no verified Lua consent veto. Client
UI wrappers or stopping updates after subscription cannot provide the required
server-authoritative protection, so those workarounds are not implemented.

Authoritative runtime source: `src/B47ANCEDMedicalChecks/42` (plus `common/`).
No custom Java, agent, bridge, JAR or native loader is an active dependency.
Existing Java-era research/artifacts remain local, ignored and excluded from builds.

[Source repository](https://github.com/B47ANCE/B47ANCEDMedicalChecks).
See [implementation](docs/IMPLEMENTATION_REPORT.md), [authority blocker](docs/SOURCE_AUDIT.md),
[testing](docs/TESTING.md), [installation limits](docs/INSTALLATION.md), and
[historical preservation](docs/HISTORY.md).

Offline checks are not PZ evidence. SP and dedicated runtime are NOT TESTED;
G7 and stable-release G8 are BLOCKED. No Workshop item is assigned.
