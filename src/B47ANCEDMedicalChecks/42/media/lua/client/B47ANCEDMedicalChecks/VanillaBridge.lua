-- Deliberately does not hook/replace vanilla medical callbacks, events or timed actions.
local C=require "B47ANCEDMedicalChecks/Config"
if B47MC.UIEventsRegistered then return end
local Client=require "B47ANCEDMedicalChecks/PreferencesUI"
require "ISUI/ISWorldObjectContextMenu"
local function onServerCommand(module,command,args)
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
    for _,window in pairs(Client.windows) do window:removeFromUIManager() end
    Client.windows={};Client.snapshots={}
end
Events.OnServerCommand.Add(onServerCommand)
Events.OnFillWorldObjectContextMenu.Add(menu)
Events.OnDisconnect.Add(disconnect)
B47MC.UIEventsRegistered=true
