# Health Care compatibility

Project Version: 0.3.0-dev.6

Medical Checks remains an independent standalone project and Workshop item
3820690174. The owner plans to absorb all of its features into Health Care,
identified by Mod ID B47ANCEDHealthCare and owner-supplied Workshop ID 3788592396.
This change implements the Medical Checks side of that relationship; it does not
implement or verify feature absorption in Health Care.

When Health Care is in the engine's activated-mod list, Medical Checks leaves its
client presentation, examination wrapper and server handlers inactive. Both can
remain selected in the launcher; Medical Checks does not rewrite the mod list.
The result is one active feature provider, with Health Care taking priority.
There is no dependency on Health Care for standalone use.

Detection uses the exact case-sensitive Mod ID, not the Workshop number, display
name, installed folders or Health Care Lua globals. One leading backslash is
accepted as an alternate separator spelling; substring or case-insensitive matches
are not used. No Health Care script has to run first. The installed getActivatedMods
API returns the engine's mod-ID list, iterated using vanilla size()/get(i) calls.
If that API/list is unavailable, Medical Checks stays inactive and logs the reason
instead of starting without a compatibility check. Changing the enabled mod set
requires a full game/server restart; hot toggling is not supported.

The shared Config helper is checked at the beginning of Authority, VanillaBridge,
PreferencesUI and CooperativeUI. Server handlers are not registered, stores are
not opened and client UI dependencies/wrappers are not installed on the inactive
path. Other shared modules may define their own namespace/functions; no gameplay
handler, network command or storage mutation is started by them alone.

Existing Medical Checks files are preserved. This does not copy approvals into
Health Care, change on-disk schema 2, or authorize Health Care to interpret them.
Returning to Medical Checks after a full restart without Health Care resumes its
own existing storage and settings. No files are deleted and no automatic migration
is promised. Health Care owns its own replacement behavior and integration work.

Server/client active-mod configuration is the compatibility input; player settings
and mod commands cannot override it. Existing sandbox options are ignored while
Medical Checks is inactive. A toggle to force both implementations on would defeat
the owner's exclusivity rule, so no additional sandbox option is added. Mod IDs and
module-startup decisions are implementation details, not player preferences.

[VERIFIED source] Installed Steam build 25485521, original 42.21 JAR:
LuaManager$GlobalObject.getActivatedMods BCI 0-6 returns ZomboidFileSystem.getModIDs.
Vanilla client ISPauseModListUI.lua lines 19-21 demonstrates size()/get(i).
See health-care-api-evidence.json for source hashes. No direct vanilla server Lua
caller was found in the bounded search; dedicated startup timing/availability is
a runtime gate. Health Care is not installed locally, and its implementation was
not inspected, copied or changed. Its identity was supplied directly by the owner.

[TESTED - offline Lua fixtures] Standalone, unrelated/near-match IDs, the exact
Health Care ID, leading separator, incorrect Workshop-number use, missing API/list,
client modules before UI imports, and headless server before events/storage are
covered. Existing standalone consent/storage/UI regressions still run.
[RUNTIME GATE] Actual player-hosted/dedicated standalone and co-enabled behavior,
real script order and Health Care feature parity are NOT TESTED. G7 BLOCKED / NOT
TESTED; stable G8 BLOCKED. No deployment or publication is part of this change.
