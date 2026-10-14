local C=require "B47ANCEDMedicalChecks/Config"
if B47MC.AuthorityRegistered then return end
local Store=require "B47ANCEDMedicalChecks/Store"
local Engine=require "B47ANCEDMedicalChecks/Engine"
local authority
local function initialise()
    if not isServer() or authority then return end
    local ok,store=pcall(Store.open,{reader=getFileReader,writer=getFileWriter},getServerName())
    if not ok then store=nil;print("[B47MC] Settings storage unavailable; preserving data; mutations disabled") end
    if store and store.recovered then print("[B47MC] Recovered previous valid metadata slot; inspect damaged slot before relying on latest settings") end
    authority=Engine.new({
        identity=function(player) return player and player:getUsername() end,
        now=function() return getTimestampMs()/1000 end,
        send=function(player,command,args) sendServerCommand(player,C.module,command,args) end,
    },store)
    print("[B47MC] Lua-only settings loaded. BLOCKED: server examination consent cannot be enforced. Vanilla remains active.")
end
local function onCommand(module,command,player,args)
    if module~=C.module or not isServer() then return end
    if not authority then initialise() end
    -- Vanilla OnClientCommand derives player from the authenticated sending connection.
    authority:command(player,command,args)
end
Events.OnServerStarted.Add(initialise)
Events.OnClientCommand.Add(onCommand)
B47MC.AuthorityRegistered=true
