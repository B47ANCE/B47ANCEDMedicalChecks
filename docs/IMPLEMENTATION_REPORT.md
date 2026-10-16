# Medical Checks implementation report

Project Version: 0.3.0-dev.5

Implemented: examination prompts, Always Ask, per-examiner Only Ask Once, four server
policies, server-owned directional approvals, persistence, individual revocation,
request cooldown/timeout, live-participant validation and one-time confirmation.
Protocol 3 and storage schema 2 are unchanged.

The server validates requests and persists approvals; the examiner client calls the
original vanilla examination callback after confirmation. Treatment actions, First
Aid requirements and vanilla interaction eligibility remain unchanged. Revocation
cancels pending requests and affects future checks; open health panels remain vanilla.
Legacy inactive records do not become approvals. New approval files use a separate
storage domain; session retention is memory-only. See ARCHITECTURE.md for details.

0.3.0-dev.5 is a PATCH-compatible wording iteration. README, current feature overviews,
mod description, Workshop changenote, UI labels, prompts and sandbox tooltips now
focus on normal mod use. No policy, approval, request, synchronization or storage
logic changed. Translation keys, option identifiers, defaults and bounds are preserved.
The supplied thumbnail, mod icon and poster remain byte-for-byte unchanged.

Validation commands and results are recorded in VALIDATION.md. Current actual
player-hosted/dedicated behavior and visual rendering are NOT TESTED.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No packaging, deployment, game/server
launch or Workshop publication occurred. Historical audits, Java research and prior
reports retain their original evidence and are not promoted to current runtime proof.
