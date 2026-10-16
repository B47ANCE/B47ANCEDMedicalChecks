-- Focused UI lifecycle mocks, not rendered UI or engine proof.
local function class()
    local c={};c.__index=c
    function c:derive() local n={};n.__index=n;return setmetatable(n,{__index=self}) end
    function c:new(x,y,w,h) return setmetatable({x=x,y=y,width=w or 500,height=h or 400,items={},selected=1,children={},options={}},self) end
    function c:initialise() end
    function c:instantiate() if self.createChildren then self:createChildren() end end
    function c:createChildren() end
    function c:addChild(child) self.children[#self.children+1]=child end
    function c:addToUIManager() self.visible=true end
    function c:removeFromUIManager() self.visible=false end
    function c:bringToTop() end
    function c:setVisible(v) self.visible=v end
    function c:setEnabled(v) self.enabled=v end
    function c:setEnable(v) self.enabled=v end
    function c:setName(v) self.name=v end
    function c:destroy() self.visible=false end
    function c:addOption(v) self.options[#self.options+1]=v end
    function c:clear() self.items={} end
    function c:addItem(label,item) self.items[#self.items+1]={text=label,item=item} end
    return c
end
local function setup(client)
    local f={sent={},time=1000,vanillaActions=0,performed=0,stopped=0}
    function getActivatedMods() return {size=function() return 0 end} end
    Events={}
    for _,name in ipairs({"OnGameStart","OnCreatePlayer","OnServerCommand","OnFillWorldObjectContextMenu","OnTick","OnDisconnect","RequestMedicalCheck","AcceptedMedicalCheck"}) do
        local ev={callbacks={}}
        function ev.Add(cb) ev.callbacks[#ev.callbacks+1]=cb end
        function ev.Remove(cb) for i,v in ipairs(ev.callbacks) do if v==cb then table.remove(ev.callbacks,i);return end end end
        function ev.fire(...) for _,cb in ipairs(ev.callbacks) do cb(...) end end
        Events[name]=ev
    end
    for _,name in ipairs({"ISCollapsableWindow","ISComboBox","ISButton","ISScrollingListBox","ISLabel","ISModalDialog","ISModalRichText"}) do _G[name]=class() end
    local modalNew=ISModalRichText.new
    f.modals={}
    function ISModalRichText:new(x,y,w,h,text,yesno,target,onclick,player)
        local o=modalNew(self,x,y,w,h);o.text=text;o.onclick=onclick;o.target=target
        f.modals[#f.modals+1]=o;return o
    end
    UIFont={Small=1}
    function getText(key,name) return key..(name and (":"..name) or "") end
    function getTextManager() return {getFontHeight=function() return 16 end,MeasureStringX=function(_,_,s) return #s*7 end} end
    function isClient() return client~=false end
    function getTimestampMs() return f.time end
    function getPlayerScreenLeft() return 0 end
    function getPlayerScreenTop() return 0 end
    function getPlayerScreenWidth() return 1280 end
    function getPlayerScreenHeight() return 720 end
    f.player={id=1}; f.patient={id=2}
    function f.player:getOnlineID() return self.id end
    function f.player:getPlayerNum() return 0 end
    function f.patient:getOnlineID() return self.id end
    function f.patient:getBodyDamageRemote() return {RestoreToFullHealth=function() f.cacheCleared=true end} end
    function getSpecificPlayer() return f.player end
    function getNumActivePlayers() return 1 end
    function getPlayerByOnlineID(id) if id==2 then return f.patient end end
    function sendClientCommand(player,module,command,args) f.sent[#f.sent+1]={player=player,command=command,args=args} end
    ISWorldObjectContextMenu={onMedicalCheck=function() f.originalCalled=true end}
    function ISWorldObjectContextMenu.setTest() f.menuTest=true;return true end
    ISHealthPanel={canPerformMedicalCheck=function() return true end,ReceiveMedicalCheckRequest=function() end,
        AcceptedMedicalCheck=function() f.vanillaActions=f.vanillaActions+1 end,
        tryStopReceivingBodyDamageUpdates=function(panel) panel.otherPlayer=nil end}
    ISBaseTimedAction={perform=function() f.baseCompleted=true end}
    ISMedicalCheckAction={HealthWindows={},perform=function() f.performed=f.performed+1 end,stop=function() f.stopped=f.stopped+1 end}
    function ISMedicalCheckAction.getHealthWindowForPlayer(p) return ISMedicalCheckAction.HealthWindows[p] end
    Events.RequestMedicalCheck.Add(ISHealthPanel.ReceiveMedicalCheckRequest)
    Events.AcceptedMedicalCheck.Add(ISHealthPanel.AcceptedMedicalCheck)
    for _,name in ipairs({"ISUI/ISCollapsableWindow","ISUI/ISComboBox","ISUI/ISButton","ISUI/ISScrollingListBox","ISUI/ISLabel","ISUI/ISModalDialog","ISUI/ISModalRichText","ISUI/ISWorldObjectContextMenu","XpSystem/ISUI/ISHealthPanel","TimedActions/ISMedicalCheckAction"}) do package.loaded[name]=true end
    require "B47ANCEDMedicalChecks/VanillaBridge"
    Events.OnGameStart.fire()
    function f:server(command,args) args.player=args.player or 1;Events.OnServerCommand.fire("B47ANCEDMedicalChecks",command,args) end
    return f
end

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
return specs
