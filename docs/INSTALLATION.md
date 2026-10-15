# Cooperative installation and migration

Project Version: 0.3.0-dev.1

For a future authorized isolated test, the installable source is
src/B47ANCEDMedicalChecks with common/ and 42/. Mod ID B47ANCEDMedicalChecks;
Build 42.21, no custom Java/agent/JAR. The operator must use an unmodified baseline
and remove historical agent launch settings separately; this task changes no launcher.
Server and every testing client need this version and protocol 3. SP convenience is
not enabled: the original context callback is left unchanged when not a client.

Use the normal Medical Check entry. A patient YES allows the cooperative flow;
NO refuses it. The right-click settings entry selects preferences and manages
remembered examiners. Legacy inactive rows remain distinctly labelled. Revoke affects
future checks/pending cooperative requests, not native panels already open.

Existing B47MC_ schema-2 files are unchanged. New B47MCCoop_ schema-2 files live in
the same server Lua cache, per server profile, and start with no approvals. Back up
both pairs together with server configuration. There is no properties import or
upgrade of inactive grants. An older-version downgrade will ignore cooperative files;
keep backups and restore matching source/configuration rather than delete newer data.
Unreadable/corrupt cooperative storage or prior-slot recovery disables this workflow
for review; preserve files. Never copy real player saves into destructive fixtures.
Read-back failures are uncertain writes, not promised durable rollback.

CooperativeConsent defaults true, including existing servers lacking the new option.
The prior six setting identifiers/defaults/bounds are preserved; retention, timing
and diagnostics now apply to the cooperative workflow. Retention changes do not erase
persisted records; switching back to Persistent reuses those records unless revoked.
Disabling CooperativeConsent restores the vanilla context flow after server response.
No setting can enforce native medical privacy or prevent modified-client access.

No deployment or launch occurred. Dedicated multiplayer NOT TESTED; G7/stable G8 BLOCKED.
