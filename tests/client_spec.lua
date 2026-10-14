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
    function c:addOption(v) self.options[#self.options+1]=v end
    function c:clear() self.items={} end
    function c:addItem(label,item) self.items[#self.items+1]={text=label,item=item} end
    return c
end
local function setup()
    local f={sent={},time=1000,vanillaActions=0,performed=0,stopped=0}
    Events={}
    for _,name in ipairs({"OnGameStart","OnCreatePlayer","OnServerCommand","OnFillWorldObjectContextMenu","OnTick","OnDisconnect","RequestMedicalCheck","AcceptedMedicalCheck"}) do
        local ev={callbacks={}}
        function ev.Add(cb) ev.callbacks[#ev.callbacks+1]=cb end
        function ev.Remove(cb) for i,v in ipairs(ev.callbacks) do if v==cb then table.remove(ev.callbacks,i);return end end end
        function ev.fire(...) for _,cb in ipairs(ev.callbacks) do cb(...) end end
        Events[name]=ev
    end
    for _,name in ipairs({"ISCollapsableWindow","ISComboBox","ISButton","ISScrollingListBox","ISLabel","ISModalDialog"}) do _G[name]=class() end
    UIFont={Small=1}
    function getText(key,name) return key..(name and (":"..name) or "") end
    function getTextManager() return {getFontHeight=function() return 16 end,MeasureStringX=function(_,_,s) return #s*7 end} end
    function isClient() return true end
    function getTimestampMs() return f.time end
    function getPlayerScreenLeft() return 0 end
    function getPlayerScreenTop() return 0 end
    f.player={id=1}; f.patient={id=2}
    function f.player:getOnlineID() return self.id end
    function f.player:getPlayerNum() return 0 end
    function f.patient:getOnlineID() return self.id end
    function f.patient:getBodyDamageRemote() return {RestoreToFullHealth=function() f.cacheCleared=true end} end
    function getSpecificPlayer() return f.player end
    function getNumActivePlayers() return 1 end
    function getPlayerByOnlineID(id) if id==2 then return f.patient end end
    function sendClientCommand(player,module,command,args) f.sent[#f.sent+1]={player=player,command=command,args=args} end
    ISWorldObjectContextMenu={}
    function ISWorldObjectContextMenu.setTest() f.menuTest=true;return true end
    ISHealthPanel={canPerformMedicalCheck=function() return true end,ReceiveMedicalCheckRequest=function() end,
        AcceptedMedicalCheck=function() f.vanillaActions=f.vanillaActions+1 end,
        tryStopReceivingBodyDamageUpdates=function(panel) panel.otherPlayer=nil end}
    ISBaseTimedAction={perform=function() f.baseCompleted=true end}
    ISMedicalCheckAction={HealthWindows={},perform=function() f.performed=f.performed+1 end,stop=function() f.stopped=f.stopped+1 end}
    function ISMedicalCheckAction.getHealthWindowForPlayer(p) return ISMedicalCheckAction.HealthWindows[p] end
    Events.RequestMedicalCheck.Add(ISHealthPanel.ReceiveMedicalCheckRequest)
    Events.AcceptedMedicalCheck.Add(ISHealthPanel.AcceptedMedicalCheck)
    for _,name in ipairs({"ISUI/ISCollapsableWindow","ISUI/ISComboBox","ISUI/ISButton","ISUI/ISScrollingListBox","ISUI/ISLabel","ISUI/ISModalDialog","ISUI/ISWorldObjectContextMenu","XpSystem/ISUI/ISHealthPanel","TimedActions/ISMedicalCheckAction"}) do package.loaded[name]=true end
    require "B47ANCEDMedicalChecks/VanillaBridge"
    Events.OnGameStart.fire()
    function f:server(command,args) args.player=args.player or 1;Events.OnServerCommand.fire("B47ANCEDMedicalChecks",command,args) end
    return f
end

local specs={}
local function snapshot(serial)
 return {protocol=2,player=1,serial=serial or 1,reason="Blocked",settingsReady=true,enforcement=false,policy=1,preference=1,retention=1,grants={}}
end
function specs.vanilla_events_are_preserved()
 local f=setup();assert(#Events.RequestMedicalCheck.callbacks==1 and #Events.AcceptedMedicalCheck.callbacks==1)
 assert(ISWorldObjectContextMenu.onMedicalCheck==nil)
 assert(#Events.OnTick.callbacks==0)
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
 assert(f.sent[#f.sent].command=="Preference" and f.sent[#f.sent].args.protocol==2)
end
function specs.forced_policy_disables_editor()
 local f=setup();B47MC.Client.open(f.player);local s=snapshot();s.policy=3;f:server("Snapshot",s)
 assert(B47MC.Client.windows[1].preference.enabled==false)
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
return specs
