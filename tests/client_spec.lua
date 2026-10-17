-- Focused UI lifecycle mocks, not rendered UI or engine proof.
local setup=require "client_fixture"

local specs={}
local function snapshot(serial)
 return {protocol=3,player=1,serial=serial or 1,reason="Blocked",settingsReady=true,enforcement=false,policy=1,preference=1,retention=1,grants={}}
end
function specs.vanilla_events_are_preserved()
 local f=setup();assert(#Events.RequestMedicalCheck.callbacks==1 and #Events.AcceptedMedicalCheck.callbacks==1)
 assert(type(ISWorldObjectContextMenu.onMedicalCheck)=="function")
 assert(#Events.OnTick.callbacks==1 and ISMedicalCheckAction.perform~=nil)
end
function specs.settings_entry_deduplicates_without_medical_entry()
 local f=setup();local menu={options={}}
 function menu:addOption(text,player,callback) local option={text=text};self.options[#self.options+1]=option;return option end
 Events.OnFillWorldObjectContextMenu.fire(0,menu,{},true);assert(f.menuTest and #menu.options==0)
 Events.OnFillWorldObjectContextMenu.fire(0,menu,{},false);Events.OnFillWorldObjectContextMenu.fire(0,menu,{},false)
 assert(#menu.options==1)
end
function specs.settings_edit_uses_versioned_intent()
 local f=setup();B47MC.Client.open(f.player);f:server("Snapshot",snapshot())
 local window=B47MC.Client.windows[1];window.preference.selected=2;window:onPreference()
 assert(f.sent[#f.sent].command=="Preference" and f.sent[#f.sent].args.protocol==3)
end
function specs.forced_policy_disables_editor()
 local f=setup();B47MC.Client.open(f.player);local s=snapshot();s.policy=3;f:server("Snapshot",s)
 assert(B47MC.Client.windows[1].preference.enabled==false)
end
function specs.rate_rejection_restores_saved_selection_and_explains_retry()
 local f=setup();B47MC.Client.open(f.player);f:server("Snapshot",snapshot())
 local w=B47MC.Client.windows[1];w.preference.selected=2;w:onPreference()
 local s=snapshot(2);s.reason="RateLimited";f:server("Snapshot",s)
 assert(w.preference.selected==1 and w.status.name=="UI_B47MC_RateLimited")
end
function specs.approval_record_revoke_is_owner_intent_only()
 local f=setup();B47MC.Client.open(f.player);local s=snapshot();s.grants={{key="examiner",label="Examiner"}};f:server("Snapshot",s)
 B47MC.Client.windows[1]:onRevoke();local last=f.sent[#f.sent]
 assert(last.command=="Revoke" and last.args.key=="examiner" and last.args.owner==nil)
end
function specs.stale_snapshot_cannot_undo_editor()
 local f=setup();local s=snapshot(4);s.preference=2;f:server("Snapshot",s);f:server("Snapshot",snapshot(1))
 assert(B47MC.Client.snapshots[1].preference==2)
end
function specs.legacy_authorized_command_cannot_open_panel()
 local f=setup();f:server("Authorized",{target=2,id="old"});assert(f.vanillaActions==0)
end
function specs.disconnect_closes_settings()
 local f=setup();B47MC.Client.open(f.player);local w=B47MC.Client.windows[1];Events.OnDisconnect.fire()
 assert(w.visible==false and next(B47MC.Client.snapshots)==nil)
end
function specs.invalid_snapshots_ignored()
 local f=setup();local s=snapshot();s.serial=nil;f:server("Snapshot",s)
 assert(B47MC.Client.snapshots[1]==nil)
 s=snapshot();s.enforcement=true;f:server("Snapshot",s);assert(B47MC.Client.snapshots[1]==nil)
end
function specs.repeated_module_execution_does_not_duplicate_events()
 local f=setup();local before=#Events.OnServerCommand.callbacks
 package.loaded["B47ANCEDMedicalChecks/VanillaBridge"]=nil
 require "B47ANCEDMedicalChecks/VanillaBridge"
 assert(#Events.OnServerCommand.callbacks==before)
end
function specs.cooperative_roundtrip_queues_vanilla_once()
 local f=setup();ISWorldObjectContextMenu.onMedicalCheck({},f.player,f.patient)
 local request=f.sent[#f.sent];assert(request.command=="CoopRequest" and f.vanillaActions==0)
 f:server("CoopProceed",{protocol=3,id=4,nonce=request.args.nonce,target=2});assert(f.vanillaActions==0)
 f:server("CoopOffer",{protocol=3,id=4,nonce=request.args.nonce,target=2})
 assert(f.sent[#f.sent].command=="CoopConfirm")
 f:server("CoopProceed",{protocol=3,id=4,nonce=request.args.nonce,target=2})
 f:server("CoopProceed",{protocol=3,id=4,nonce=request.args.nonce,target=2})
 assert(f.vanillaActions==1 and not f.originalCalled)
end
function specs.refusal_never_opens_panel()
 local f=setup();ISWorldObjectContextMenu.onMedicalCheck({},f.player,f.patient)
 f:server("CoopResult",{protocol=3,nonce=f.sent[#f.sent].args.nonce,reason="Refused"})
 assert(f.vanillaActions==0 and #f.modals==2 and not f.originalCalled)
end
function specs.disabled_mode_uses_original_context_callback()
 local f=setup();ISWorldObjectContextMenu.onMedicalCheck({},f.player,f.patient)
 f:server("CoopResult",{protocol=3,nonce=f.sent[#f.sent].args.nonce,reason="Disabled"})
 assert(f.originalCalled and f.vanillaActions==0)
end
function specs.prompt_yes_and_no_are_explicit_intents()
 local f=setup()
 for i,answer in ipairs({"YES","NO"}) do
  f:server("CoopPrompt",{protocol=3,id=9+i,examiner="other",timeout=30,remember=true})
  local m=f.modals[#f.modals];m.onclick(nil,{internal=answer})
  assert(f.sent[#f.sent].command=="CoopAnswer" and f.sent[#f.sent].args.accept==(answer=="YES"))
 end
end
function specs.unsolicited_offer_and_stale_protocol_ignored()
 local f=setup();f:server("CoopOffer",{protocol=3,id=1,nonce=1,target=2});assert(#f.sent==0)
 ISWorldObjectContextMenu.onMedicalCheck({},f.player,f.patient);local n=#f.sent
 f:server("CoopOffer",{protocol=2,id=1,nonce=1,target=2});assert(#f.sent==n and f.vanillaActions==0)
end
function specs.prompt_timeout_disconnect_and_duplicate_are_bounded()
 local f=setup();local s={protocol=3,id=3,examiner="other",timeout=5,remember=false}
 f:server("CoopPrompt",s);f:server("CoopPrompt",s);assert(#f.modals==1)
 f.time=f.time+6000;Events.OnTick.fire();assert(not f.modals[1].visible and #f.sent==0)
 s.id=4;f:server("CoopPrompt",s);Events.OnDisconnect.fire();assert(not f.modals[2].visible)
end
function specs.cooperative_revocation_uses_distinct_command()
 local f=setup();B47MC.Client.open(f.player);local s=snapshot();s.grants={{key="other",label="other",cooperative=true}};f:server("Snapshot",s)
 B47MC.Client.windows[1]:onRevoke();assert(f.sent[#f.sent].command=="RevokeApproval")
end
function specs.single_player_context_callback_is_unchanged()
 local f=setup(false);ISWorldObjectContextMenu.onMedicalCheck({},f.player,f.patient)
 assert(f.originalCalled and #f.sent==0)
end
function specs.closed_prompt_cannot_reopen_from_reordered_message()
 local f=setup();local s={protocol=3,id=5,examiner="other",timeout=30,remember=true}
 f:server("CoopClose",{protocol=3,id=5.0});f:server("CoopPrompt",s);assert(#f.modals==0)
 s.id=6;f:server("CoopPrompt",s);local m=f.modals[1];m.onclick(nil,{internal="NO"})
 f:server("CoopPrompt",s);assert(#f.modals==1)
end
function specs.disabled_fallback_rejects_replaced_patient_object()
 local f=setup();ISWorldObjectContextMenu.onMedicalCheck({},f.player,f.patient)
 local nonce=f.sent[#f.sent].args.nonce
 f.patient={id=2,getOnlineID=function() return 2 end}
 f:server("CoopResult",{protocol=3,nonce=nonce,reason="Disabled"})
 assert(not f.originalCalled and f.vanillaActions==0)
end
function specs.controller_settings_focus_and_close_restore_previous_focus()
 local f=setup(true,{controller=true,slot=1})
 B47MC.Client.open(f.player)
 local window=B47MC.Client.windows[1]
 assert(JoypadState.players[2].focus==window and window.preference.joypadFocused)
 assert(#window.joypadButtonsY==3 and window.joypadButtonsY[2][1]==window.list)
 assert(window.list.joypadParent==window and window.list.stealJoypadFocusFromParent==false)
 window:onJoypadDown(Joypad.BButton,JoypadState.players[2])
 assert(not window.visible and JoypadState.players[2].focus==f.previousFocus)
end
function specs.controller_back_collapses_combo_before_closing_settings()
 local f=setup(true,{controller=true});B47MC.Client.open(f.player)
 local window=B47MC.Client.windows[1];window.preference.expanded=true
 window:onJoypadDown(Joypad.BButton,JoypadState.players[1])
 assert(window.visible and not window.preference.expanded and JoypadState.players[1].focus==window)
end
function specs.prompt_returns_controller_focus_to_settings()
 local f=setup(true,{controller=true});B47MC.Client.open(f.player)
 local window=B47MC.Client.windows[1]
 f:server("CoopPrompt",{protocol=3,id=6,examiner="other",timeout=30,remember=true})
 assert(JoypadState.players[1].focus==f.modals[1])
 f:server("CoopClose",{protocol=3,id=6})
 assert(JoypadState.players[1].focus==window)
end
function specs.settings_fit_small_split_screen_viewport()
 local f=setup(true,{width=640,height=360,left=640,top=360,slot=1});B47MC.Client.open(f.player)
 local w=B47MC.Client.windows[1]
 assert(w.x>=640 and w.y>=360 and w.x+w.width<=1280 and w.y+w.height<=720)
end
function specs.disconnect_releases_controller_settings_focus()
 local f=setup(true,{controller=true});B47MC.Client.open(f.player)
 Events.OnDisconnect.fire()
 assert(JoypadState.players[1].focus==f.previousFocus)
end
function specs.background_prompt_expiry_keeps_newer_prompt_focus()
 local f=setup(true,{controller=true})
 f:server("CoopPrompt",{protocol=3,id=11,examiner="one",timeout=5,remember=false})
 f:server("CoopPrompt",{protocol=3,id=12,examiner="two",timeout=30,remember=false})
 local newer=f.modals[2]
 f.time=7000;Events.OnTick.fire()
 assert(JoypadState.players[1].focus==newer and newer.visible)
 f:server("CoopClose",{protocol=3,id=12})
 assert(JoypadState.players[1].focus==f.previousFocus)
end
function specs.closing_settings_behind_prompt_removes_hidden_focus_target()
 local f=setup(true,{controller=true});B47MC.Client.open(f.player)
 f:server("CoopPrompt",{protocol=3,id=11,examiner="one",timeout=30,remember=false})
 B47MC.Client.windows[1]:close()
 assert(JoypadState.players[1].focus==f.modals[1])
 f:server("CoopClose",{protocol=3,id=11})
 assert(JoypadState.players[1].focus==f.previousFocus)
end
function specs.disconnect_unlinks_multiple_prompt_focus_targets()
 local f=setup(true,{controller=true});B47MC.Client.open(f.player)
 for id=11,12 do f:server("CoopPrompt",{protocol=3,id=id,examiner="one",timeout=30,remember=false}) end
 Events.OnDisconnect.fire()
 assert(JoypadState.players[1].focus==f.previousFocus)
end
function specs.repeated_prompt_destroy_does_not_steal_restored_focus()
 local f=setup(true,{controller=true})
 f:server("CoopPrompt",{protocol=3,id=11,examiner="one",timeout=30,remember=false})
 local older=f.modals[1]
 f:server("CoopClose",{protocol=3,id=11})
 f:server("CoopPrompt",{protocol=3,id=12,examiner="two",timeout=30,remember=false})
 older:destroy()
 assert(JoypadState.players[1].focus==f.modals[2])
end
return specs
