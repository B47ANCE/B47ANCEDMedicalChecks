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
    function c:close() self.visible=false end
    function c:insertNewLineOfButtons(...)
        self.joypadButtonsY=self.joypadButtonsY or {}
        self.joypadButtonsY[#self.joypadButtonsY+1]={...}
    end
    function c:getVisibleChildren(row) return self.joypadButtonsY[row] end
    function c:setJoypadFocused(focused) self.joypadFocused=focused end
    function c:onGainJoypadFocus(data) self.joyfocus=data end
    function c:onJoypadDown(button)
        local child=self:getVisibleChildren(self.joypadIndexY)[self.joypadIndex]
        if button==Joypad.BButton and child.isCombobox and child.expanded then child.expanded=false end
    end
    function c:addOption(v) self.options[#self.options+1]=v end
    function c:clear() self.items={} end
    function c:addItem(label,item) self.items[#self.items+1]={text=label,item=item} end
    return c
end
local function setup(client, options)
    options=options or {}
    local f={sent={},time=1000,vanillaActions=0,performed=0,stopped=0}
    function getActivatedMods()
        local ids=options.mods or {}
        return {size=function() return #ids end,get=function(_,i) return ids[i+1] end}
    end
    Events={}
    for _,name in ipairs({"OnGameStart","OnCreatePlayer","OnServerCommand","OnFillWorldObjectContextMenu","OnTick","OnDisconnect","RequestMedicalCheck","AcceptedMedicalCheck"}) do
        local ev={callbacks={}}
        function ev.Add(cb) ev.callbacks[#ev.callbacks+1]=cb end
        function ev.Remove(cb) for i,v in ipairs(ev.callbacks) do if v==cb then table.remove(ev.callbacks,i);return end end end
        function ev.fire(...) for _,cb in ipairs(ev.callbacks) do cb(...) end end
        Events[name]=ev
    end
    for _,name in ipairs({"ISCollapsableWindow","ISCollapsableWindowJoypad","ISComboBox","ISButton","ISScrollingListBox","ISLabel","ISModalDialog","ISModalRichText"}) do _G[name]=class() end
    ISComboBox.isCombobox=true
    Joypad={AButton=1,BButton=2}
    f.previousFocus={}
    if options.controller then
        JoypadState={players={[1+(options.slot or 0)]={focus=f.previousFocus}}}
    end
    function setJoypadFocus(slot,window)
        local data=JoypadState.players[slot+1]
        data.focus=window
        if window and window.onGainJoypadFocus then window:onGainJoypadFocus(data) end
    end
    local modalNew=ISModalRichText.new
    f.modals={}
    function ISModalRichText:new(x,y,w,h,text,yesno,target,onclick,player)
        local o=modalNew(self,x,y,w,h);o.text=text;o.onclick=onclick;o.target=target;o.yesno=yesno;o.player=player
        f.modals[#f.modals+1]=o;return o
    end
    function ISModalRichText:destroy()
        self.visible=false
        if JoypadState and JoypadState.players[self.player+1] then setJoypadFocus(self.player,self.prevFocus) end
    end
    UIFont={Small=1}
    function getText(key,name) return key..(name and (":"..name) or "") end
    function getTextManager() return {getFontHeight=function() return 16 end,MeasureStringX=function(_,_,s) return #s*7 end} end
    function isClient() return client~=false end
    function getTimestampMs() return f.time end
    function getPlayerScreenLeft() return options.left or 0 end
    function getPlayerScreenTop() return options.top or 0 end
    function getPlayerScreenWidth() return options.width or 1280 end
    function getPlayerScreenHeight() return options.height or 720 end
    f.player={id=options.id or 1}; f.patient={id=options.target or 2}
    function f.player:getOnlineID() return self.id end
    function f.player:getPlayerNum() return options.slot or 0 end
    function f.patient:getOnlineID() return self.id end
    function f.patient:getBodyDamageRemote() return {RestoreToFullHealth=function() f.cacheCleared=true end} end
    function getSpecificPlayer(index) if index==(options.slot or 0) then return f.player end end
    function getNumActivePlayers() return (options.slot or 0)+1 end
    function getPlayerByOnlineID(id) if id==f.patient.id then return f.patient elseif id==f.player.id then return f.player end end
    function sendClientCommand(player,module,command,args) f.sent[#f.sent+1]={player=player,command=command,args=args} end
    ISWorldObjectContextMenu={onMedicalCheck=function() f.originalCalled=true end}
    function ISWorldObjectContextMenu.setTest() f.menuTest=true;return true end
    ISHealthPanel={canPerformMedicalCheck=function() return f.eligible~=false end,ReceiveMedicalCheckRequest=function() end,
        AcceptedMedicalCheck=function() f.vanillaActions=f.vanillaActions+1 end,
        tryStopReceivingBodyDamageUpdates=function(panel) panel.otherPlayer=nil end}
    ISBaseTimedAction={perform=function() f.baseCompleted=true end}
    ISMedicalCheckAction={HealthWindows={},perform=function() f.performed=f.performed+1 end,stop=function() f.stopped=f.stopped+1 end}
    function ISMedicalCheckAction.getHealthWindowForPlayer(p) return ISMedicalCheckAction.HealthWindows[p] end
    Events.RequestMedicalCheck.Add(ISHealthPanel.ReceiveMedicalCheckRequest)
    Events.AcceptedMedicalCheck.Add(ISHealthPanel.AcceptedMedicalCheck)
    for _,name in ipairs({"ISUI/ISCollapsableWindow","ISUI/ISCollapsableWindowJoypad","ISUI/ISComboBox","ISUI/ISButton","ISUI/ISScrollingListBox","ISUI/ISLabel","ISUI/ISModalDialog","ISUI/ISModalRichText","ISUI/ISWorldObjectContextMenu","XpSystem/ISUI/ISHealthPanel","TimedActions/ISMedicalCheckAction"}) do package.loaded[name]=true end
    require "B47ANCEDMedicalChecks/VanillaBridge"
    Events.OnGameStart.fire()
    function f:server(command,args) args.player=args.player or 1;Events.OnServerCommand.fire("B47ANCEDMedicalChecks",command,args) end
    return f
end

return setup
