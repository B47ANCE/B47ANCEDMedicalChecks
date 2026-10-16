-- Replaces the ordinary context entry callback only; never a native authorization hook.
local C=require "B47ANCEDMedicalChecks/Config"
local enabled,reason=C.runtimeEnabled()
if not enabled then print("[B47MC] Medical Checks inactive: "..reason);return end
if B47MC.UIEventsRegistered then return end
local Client=require "B47ANCEDMedicalChecks/PreferencesUI"
require "ISUI/ISWorldObjectContextMenu"
local CooperativeUI=require "B47ANCEDMedicalChecks/CooperativeUI"
CooperativeUI.install()
local function onServerCommand(module,command,args)
    if module==C.module and CooperativeUI.receive(command,args) then return end
    if module~=C.module or command~="Snapshot" or type(args)~="table" or args.protocol~=C.protocol then return end
    if type(args.serial)~="number" or args.serial<1 or args.enforcement~=false or
            type(args.policy)~="number" or args.policy~=math.floor(args.policy) or args.policy<1 or args.policy>4 or
            (args.preference~=1 and args.preference~=2) or type(args.grants)~="table" then return end
    for i=0,getNumActivePlayers()-1 do
        local player=getSpecificPlayer(i)
        if player and player:getOnlineID()==args.player then
            local old=Client.snapshots[args.player]
            if old and old.serial>=args.serial then return end
            Client.snapshots[args.player]=args
            local window=Client.windows[args.player];if window then window:apply(args) end
        end
    end
end
local function menu(index,context,worldobjects,test)
    if not isClient() then return end
    local player=getSpecificPlayer(index);if not player then return end
    if test then return ISWorldObjectContextMenu.setTest() end
    for _,option in ipairs(context.options) do if option.b47mcSettings then return end end
    local option=context:addOption(getText("UI_B47MC_Settings"),player,Client.open)
    option.b47mcSettings=true
end
local function disconnect()
    CooperativeUI.disconnect()
    for _,window in pairs(Client.windows) do window:removeFromUIManager() end
    Client.windows={};Client.snapshots={}
end
Events.OnServerCommand.Add(onServerCommand)
Events.OnFillWorldObjectContextMenu.Add(menu)
Events.OnDisconnect.Add(disconnect)
local nextTick=0
Events.OnTick.Add(function()
    local now=getTimestampMs()/1000
    if now>=nextTick or now<nextTick-2 then nextTick=now+1;CooperativeUI.tick() end
end)
B47MC.UIEventsRegistered=true
