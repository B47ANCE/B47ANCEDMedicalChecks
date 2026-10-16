-- Offline active-mod-list and entry-point fixtures; no game runtime is asserted.
local function active(ids)
    function getActivatedMods()
        return {size=function() return #ids end,get=function(_,index) return ids[index+1] end}
    end
end
local function allowed(ids)
    active(ids)
    return require("B47ANCEDMedicalChecks/Config").runtimeEnabled()
end
local specs={}
function specs.standalone_remains_enabled() assert(allowed({})) end
function specs.unrelated_mods_remain_enabled() assert(allowed({"OtherMod","B47ANCEDMedicalChecks"})) end
function specs.health_care_disables_runtime() assert(allowed({"B47ANCEDHealthCare"})==false) end
function specs.leading_separator_is_recognized() assert(allowed({"\\B47ANCEDHealthCare"})==false) end
function specs.similar_ids_do_not_disable_runtime()
    assert(allowed({"B47ANCEDHealthCareExtra","NotB47ANCEDHealthCare","b47ancedhealthcare"}))
end
function specs.workshop_number_is_not_a_mod_id() assert(allowed({"3788592396"})) end
function specs.missing_api_does_not_start_unchecked_runtime()
    getActivatedMods=nil
    assert(require("B47ANCEDMedicalChecks/Config").runtimeEnabled()==false)
end
function specs.missing_list_does_not_start_unchecked_runtime()
    function getActivatedMods() return nil end
    assert(require("B47ANCEDMedicalChecks/Config").runtimeEnabled()==false)
end
local function inactiveEntry(module)
    active({"B47ANCEDMedicalChecks","B47ANCEDHealthCare"})
    -- No Health Care globals, events or UI libraries exist yet: script order is irrelevant.
    B47ANCEDHealthCare=nil;Events=nil
    function getFileReader() error("Disabled Medical Checks opened storage") end
    function getFileWriter() error("Disabled Medical Checks wrote storage") end
    function sendClientCommand() error("Disabled Medical Checks sent client command") end
    function sendServerCommand() error("Disabled Medical Checks sent server command") end
    local original=function() end
    ISWorldObjectContextMenu={onMedicalCheck=original}
    require(module)
    assert(ISWorldObjectContextMenu.onMedicalCheck==original)
    assert(B47MC.UIEventsRegistered==nil and B47MC.AuthorityRegistered==nil)
    if module~="B47ANCEDMedicalChecks/CooperativeUI" then assert(package.loaded["B47ANCEDMedicalChecks/CooperativeUI"]==nil) end
    assert(package.loaded["B47ANCEDMedicalChecks/Store"]==nil)
end
function specs.client_defers_before_ui_hooks() inactiveEntry("B47ANCEDMedicalChecks/VanillaBridge") end
function specs.server_defers_before_events_and_storage() inactiveEntry("B47ANCEDMedicalChecks/Authority") end
function specs.preferences_remain_inert_before_ui_requires() inactiveEntry("B47ANCEDMedicalChecks/PreferencesUI") end
function specs.prompts_remain_inert_before_ui_requires() inactiveEntry("B47ANCEDMedicalChecks/CooperativeUI") end
return specs
