local C=require "B47ANCEDMedicalChecks/Config"
if B47MC.AuthorityRegistered then return end
local Store=require "B47ANCEDMedicalChecks/Store"
local Engine=require "B47ANCEDMedicalChecks/Engine"
local Coop=require "B47ANCEDMedicalChecks/Cooperative"
local authority
local function initialise()
    if not isServer() or authority then return end
    local ok,store=pcall(Store.open,{reader=getFileReader,writer=getFileWriter},getServerName())
    if not ok then store=nil;print("[B47MC] Settings storage unavailable; preserving data; mutations disabled") end
    if store and store.recovered then print("[B47MC] Recovered previous valid metadata slot; inspect damaged slot before relying on latest settings") end
    authority=Engine.new({
        identity=function(player) return player and player:getUsername() end,
        now=function() return getTimestampMs()/1000 end,
        find=function(id) return getPlayerByOnlineID(id) end,
        send=function(player,command,args) sendServerCommand(player,C.module,command,args) end,
    },store)
    local approvalOK,approvals=pcall(Store.open,{reader=getFileReader,writer=getFileWriter},getServerName(),"cooperative")
    if not approvalOK then approvals=nil;print("[B47MC] Cooperative approval storage unavailable; no persistent approvals can be created/reused") end
    authority.coop=Coop.new(authority,approvals)
    if approvals and not authority.coop.store then print("[B47MC] Cooperative storage requires recovery review; workflow disabled to avoid reusing a possibly revoked approval. Files preserved.") end
    print("[B47MC] Cooperative workflow loaded. Native server examination consent remains BLOCKED; modified clients can bypass this UI.")
end
local function onCommand(module,command,player,args)
    if module~=C.module or not isServer() then return end
    if not authority then initialise() end
    -- Vanilla OnClientCommand derives player from the authenticated sending connection.
    authority:command(player,command,args)
end
local nextTick=0
local function tick()
    if not authority then return end
    local now=getTimestampMs()/1000
    if now>=nextTick or now<nextTick-2 then nextTick=now+1;authority.coop:tick() end
end
Events.OnServerStarted.Add(initialise)
Events.OnClientCommand.Add(onCommand)
Events.OnTick.Add(tick)
B47MC.AuthorityRegistered=true
