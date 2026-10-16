# Workshop publishing

The canonical description is docs/WORKSHOP_DESCRIPTION.md. The canonical change
note is WORKSHOP_CHANGE_NOTE.txt. Use the shared Build-WorkshopDescription.py
renderer to generate Steam BBCode; preserve real line breaks and the public
GitHub source link. Generated VDF, staging, upload logs and local credentials
are not source files and must not be committed.

The owner explicitly authorized creation of a new public item for this project.
The created public item is 3820690174. WORKSHOP_ID.txt is the canonical destination
for later updates. Never recreate an item because an update fails. Inspect the
VDF after any uncertain result and reuse a returned ID. Public visibility is 0;
App ID is 108600 and Mod ID is B47ANCEDMedicalChecks.

Prepare an exact committed-source snapshot with LF text, run scripts/build.py,
then scripts/package.py --development and scripts/check_versions.py --release.
Keep prior packages and provenance immutable. Stage only src/B47ANCEDMedicalChecks
under Contents/mods/B47ANCEDMedicalChecks; compare all staged bytes to the snapshot.
Preserve the supplied thumbnail.png as original artwork. SteamCMD rejected the
1,566,119-byte PNG because its preview must be less than 1 MB. The first upload
uses a same-dimension 1254x1254 JPEG quality-95 encoding (263,082 bytes) instead;
no redraw or project thumbnail replacement occurred. Reuse an upload-compatible
encoding of the selected artwork and bind its hash in provenance.

Before upload, bind Git commit, project version, package SHA-256, per-file staging
hashes, description/change-note/preview hashes, target game build and validation
status in a local provenance manifest. For initial creation record item ID pending;
after SteamCMD assigns it, bind the actual ID to the same upload attempt.
Check credentials/private-data exclusion, Lua-only source, Linux filename case,
current versions and fresh source ancestry. No password or token belongs in an
argument, log report or repository. Use the verified local SteamCMD and cached
account with workshop_build_item; never commit machine-specific auth settings.

This is a development MP testing upload, not stable-release approval. Description
and change note must include: MP testing build - dedicated multiplayer NOT TESTED
Actual player-hosted/dedicated runtime and rendering remain NOT TESTED.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED until required runtime evidence exists.

Verify SteamCMD success, the assigned ID, App ID, public visibility, title and
canonical description through Steam's published-file API or public page. Record
the publication result separately from subscription/download/runtime verification.
After a confirmed upload, gracefully restart the verified Steam desktop client
under the owner's standing preference. Do not launch a game/server, deploy locally
or change server files as part of publication.
