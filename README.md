# B47ANCE'd Medical Checks

Project Version: 0.3.0-dev.3

Lua-only cooperative examination convenience for Project Zomboid 42.21.
Canonical Mod ID: `B47ANCEDMedicalChecks`.

**This is not medical privacy protection. Modified clients and native medical
packets can bypass the workflow. Native server consent enforcement remains BLOCKED.**

Ordinary modded clients use the standard Medical Check context action. The patient
can approve each examination or remember an examiner separately. Server-owned
sandbox options choose Player Choice, Force Always Ask, Force Only Ask Once or No
Examination Requests **within this cooperative UI workflow only**. Right-click to
open settings and revoke individual approvals for future cooperative checks.

The server validates cooperative intents, participant identities, proximity,
responses, expiration and policy, and persists preferences/approvals. On completion
the examiner client calls the vanilla examination callback. Treatment, First Aid,
health panels and native subscriptions remain vanilla. Revocation does not close
an already-open native health panel or stop native data access.

Authoritative source: src/B47ANCEDMedicalChecks (common/ and 42/). No Java, agent,
JAR dependency or injected hook. All participants need the same current protocol.
Existing schema-2 inactive records are never activated; new cooperative approvals
use a separate storage domain. Historical Java research/artifacts remain preserved.

SP and dedicated runtime: **NOT TESTED**. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
See [architecture](docs/ARCHITECTURE.md), [implementation report](docs/IMPLEMENTATION_REPORT.md),
[test instructions](docs/TESTING.md), [validation](docs/VALIDATION.md), and the
[unchanged native authority audit](docs/MEDICAL_AUTHORITY_AUDIT.md).
[Public source repository](https://github.com/B47ANCE/B47ANCEDMedicalChecks).
