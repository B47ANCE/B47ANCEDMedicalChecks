-- Cooperative client presentation only. Native packets can bypass this workflow.
local C=require "B47ANCEDMedicalChecks/Config"
if not C.runtimeEnabled() then return end
local Client=require "B47ANCEDMedicalChecks/PreferencesUI"
require "ISUI/ISModalRichText"
require "XpSystem/ISUI/ISHealthPanel"
local UI={awaiting={},prompts={},closed={},notices={},nonce=0}
local Modal=ISModalRichText:derive("B47MCExaminationModal")
function Modal:destroy()
    if self.b47mcClosed then return end
    self.b47mcClosed=true
    Client.detachFocus(self)
    local joypad=JoypadState and JoypadState.players[self.player+1]
    -- Vanilla destroy always restores prevFocus, including for a background window.
    -- Keep the current foreground focus while unlinking this closed return target.
    if joypad and joypad.focus~=self then self.prevFocus=joypad.focus end
    ISModalRichText.destroy(self)
end
local function integer(v) return type(v)=="number" and v==math.floor(v) and v>=1 and v<=2147483647 end
local function localPlayer(id)
    for i=0,getNumActivePlayers()-1 do local p=getSpecificPlayer(i);if p and p:getOnlineID()==id then return p end end
end
local function modal(player,text,yesno,callback)
    local n=player:getPlayerNum()
    local width=math.max(280,math.min(560,getPlayerScreenWidth(n)-40))
    local height=math.max(200,math.min(320,getPlayerScreenHeight(n)-60))
    local window=Modal:new(getPlayerScreenLeft(n)+20,getPlayerScreenTop(n)+20,width,height,text,yesno,nil,callback,n)
    window:initialise();window:addToUIManager();window:bringToTop()
    if JoypadState and JoypadState.players[n+1] then
        window.prevFocus=JoypadState.players[n+1].focus
        Client.focusWindows[window]=true
        setJoypadFocus(n,window)
    end
    return window
end
local function close(window) if window then window:destroy() end end
local function markClosed(key)
    UI.closed[key]=getTimestampMs()/1000
    local count,oldest,oldestTime=0,nil,math.huge
    for k,time in pairs(UI.closed) do count=count+1;if time<oldestTime then oldest,oldestTime=k,time end end
    if count>128 then UI.closed[oldest]=nil end
end
local reasons={Refused="UI_B47MC_ResultRefused",Expired="UI_B47MC_ResultExpired",Revoked="UI_B47MC_ResultRevoked",
    PolicyDenied="UI_B47MC_ResultPolicyDenied",Unavailable="UI_B47MC_ResultUnavailable",Busy="UI_B47MC_ResultBusy",
    RateLimited="UI_B47MC_ResultRateLimited",StorageFailed="UI_B47MC_ResultStorageFailed"}
local function notice(player,reason)
    if not reasons[reason] then reason="Unavailable" end
    local id=player:getOnlineID();close(UI.notices[id])
    UI.notices[id]=modal(player,getText(reasons[reason]).." <LINE> "..getText("UI_B47MC_CooperativeWarning"),false,function() UI.notices[id]=nil end)
end
function UI.begin(worldobjects,examiner,patient)
    if not isClient() or not examiner or not patient or not ISHealthPanel.canPerformMedicalCheck(patient,examiner) then return end
    local key=examiner:getOnlineID()
    if UI.awaiting[key] then return end
    UI.nonce=UI.nonce%2147483647+1
    local r={nonce=UI.nonce,target=patient:getOnlineID(),patient=patient,worldobjects=worldobjects,expires=getTimestampMs()/1000+125}
    UI.awaiting[key]=r
    r.window=modal(examiner,getText("UI_B47MC_Waiting").." <LINE> "..getText("UI_B47MC_CooperativeWarning"),false,function() r.window=nil end)
    Client.send(examiner,"CoopRequest",{target=patient:getOnlineID(),nonce=UI.nonce})
end
function UI.receive(command,args)
    if type(command)~="string" or command:sub(1,4)~="Coop" then return false end
    if type(args)~="table" or args.protocol~=C.protocol then return true end
    local player=localPlayer(args.player);if not player then return true end
    if command=="CoopPrompt" then
        if not integer(args.id) or not C.validString(args.examiner) or not integer(args.timeout) or args.timeout<5 or args.timeout>120 or type(args.remember)~="boolean" then return true end
        local key=string.format("%.0f:%.0f",player:getOnlineID(),args.id)
        if UI.prompts[key] or UI.closed[key] then return true end
        local count=0;for _ in pairs(UI.prompts) do count=count+1 end;if count>=32 then return true end
        local name=args.examiner:gsub("<","["):gsub(">","]")
        local text=getText("UI_B47MC_AllowExaminer",name).." <LINE> "..getText(args.remember and "UI_B47MC_RememberApproval" or "UI_B47MC_AskEveryTime").." <LINE> "..getText("UI_B47MC_CooperativeWarning")
        local r={player=player,expires=getTimestampMs()/1000+args.timeout}
        UI.prompts[key]=r
        r.window=modal(player,text,true,function(_,button)
            if UI.prompts[key]~=r then return end
            UI.prompts[key]=nil
            markClosed(key)
            Client.send(player,"CoopAnswer",{id=args.id,accept=button.internal=="YES"})
        end)
    elseif command=="CoopClose" then
        if not integer(args.id) then return true end
        local key=string.format("%.0f:%.0f",player:getOnlineID(),args.id);local r=UI.prompts[key]
        markClosed(key)
        if r then UI.prompts[key]=nil;close(r.window) end
    else
        local r=UI.awaiting[args.player]
        if not r or args.nonce~=r.nonce then return true end
        if command=="CoopResult" then
            UI.awaiting[args.player]=nil
            close(r.window)
            if args.reason=="Disabled" and UI.original then
                local patient=getPlayerByOnlineID(r.target)
                if patient==r.patient and ISHealthPanel.canPerformMedicalCheck(patient,player) then
                    UI.original(r.worldobjects,player,patient)
                else notice(player,"Unavailable") end
            else notice(player,args.reason) end
        elseif integer(args.id) and args.target==r.target then
            if command=="CoopOffer" and not r.id then
                r.id=args.id;Client.send(player,"CoopConfirm",{id=args.id})
            elseif command=="CoopProceed" and r.id==args.id then
                UI.awaiting[args.player]=nil
                close(r.window)
                local patient=getPlayerByOnlineID(r.target)
                if patient==r.patient and ISHealthPanel.canPerformMedicalCheck(patient,player) then
                    -- The original callback queues the vanilla action; treatment stays vanilla.
                    ISHealthPanel.AcceptedMedicalCheck(patient,player)
                end
            end
        end
    end
    return true
end
function UI.tick()
    local now=getTimestampMs()/1000
    for key,time in pairs(UI.closed) do if now<time or now-time>125 then UI.closed[key]=nil end end
    for key,r in pairs(UI.prompts) do if now>=r.expires then UI.prompts[key]=nil;markClosed(key);close(r.window) end end
    for key,r in pairs(UI.awaiting) do
        if now>=r.expires then UI.awaiting[key]=nil;close(r.window);local p=localPlayer(key);if p then notice(p,"Expired") end end
    end
end
function UI.disconnect()
    for _,r in pairs(UI.prompts) do close(r.window) end
    for _,r in pairs(UI.awaiting) do close(r.window) end
    for _,window in pairs(UI.notices) do close(window) end
    UI.prompts={};UI.awaiting={};UI.closed={};UI.notices={}
end
function UI.install()
    if not isClient() then return end
    UI.original=ISWorldObjectContextMenu.onMedicalCheck
    ISWorldObjectContextMenu.onMedicalCheck=UI.begin
end
return UI
