# B47ANCE'd Medical Checks

## Overview
Medical examination approval prompts and remembered examiner choices for Project Zomboid Build 42.21 multiplayer.

## Features
- Always Ask: approve each examination request.
- Only Ask Once Per Player: remember approved examiners individually.
- Declining a request does not remember an approval.
- Manage remembered examiners and revoke individual approvals through Medical Checks settings.
- Server-managed account-based approvals, request timing and approval retention.
- Vanilla treatment, First Aid requirements and examination actions remain unchanged.

## Compatibility & Requirements
Project Zomboid Build 42.21. Mod ID: B47ANCEDMedicalChecks. Lua-only; no additional mod dependencies. Install the same version on the server and participating clients.

MP testing build - dedicated multiplayer NOT TESTED
Player-hosted multiplayer and in-game UI rendering are also NOT TESTED. Offline checks use Python/Lupa fixtures; they do not establish runtime behavior.

Medical Checks remains standalone. Health Care is planned to include these
features; when B47ANCEDHealthCare is enabled, Medical Checks leaves its own
features inactive to avoid duplicate behavior. Existing saved data is preserved.

## Configuration
Server sandbox settings select Player Choice, Force Always Ask, Force Only Ask Once, or No Examination Requests. Configure the default player preference, approval retention, request cooldown, response timeout and diagnostic logging.

Players can select Always Ask or Only Ask Once Per Player when Player Choice is enabled. Revocation affects pending requests and future examinations; it does not close already-open health panels.

## Source Code & Development
GitHub: https://github.com/B47ANCE/B47ANCEDMedicalChecks

## Known Issues
This development build awaits in-game multiplayer validation. Back up server configuration and approval files before testing. Returning from session retention to Persistent reuses stored approvals until revoked.

## Credits & Permissions
Developed by B47ANCE'd Workshop. Uses the project artwork supplied by its owner. Project Zomboid is developed by The Indie Stone.
