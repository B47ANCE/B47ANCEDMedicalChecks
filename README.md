# B47ANCE'd Medical Checks

Project Version: 0.3.0-dev.5

Medical examination approval prompts and remembered examiner choices for Project
Zomboid Build 42.21 multiplayer. Canonical Mod ID: `B47ANCEDMedicalChecks`.

Use the normal Medical Check context action. Choose **Always Ask** to approve each
examination, or **Only Ask Once Per Player** to remember examiners individually.
Declining a request does not remember an approval. Open Medical Checks settings
from the context menu to change your preference or revoke an examiner.

Server sandbox settings choose Player Choice, Force Always Ask, Force Only Ask Once,
or No Examination Requests, plus approval retention and request timing. The server
validates requests and stores directional, account-based preferences and approvals.
Treatment, First Aid requirements and the vanilla examination action are unchanged.
Revocation applies to pending requests and future checks; it does not close an
already-open health panel.

Authoritative source: src/B47ANCEDMedicalChecks (common/ and 42/). Lua-only runtime.
Server and clients need matching versions. See [installation](docs/INSTALLATION.md),
[implementation report](docs/IMPLEMENTATION_REPORT.md), and [test instructions](docs/TESTING.md).
Player-hosted and dedicated multiplayer are intended targets; actual multiplayer
runtime is **NOT TESTED**. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

[Public source repository](https://github.com/B47ANCE/B47ANCEDMedicalChecks).
Project thumbnail: supplied Medical Checks artwork in [thumbnail.png](thumbnail.png).
See [branding provenance](docs/BRANDING.md); mod icon and poster retain their existing artwork.
