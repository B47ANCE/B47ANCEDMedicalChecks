-- In-memory file/event/transport adapters for isolated offline server tests only.
return function(options)
    options=options or {}
    local f={files={},players={},sent={},time=100,failWrites=false}
    SandboxVars={B47ANCEDMedicalChecks={RequestCooldown=0}}
    function getActivatedMods()
        local ids=options.mods or {}
        return {size=function() return #ids end,get=function(_,i) return ids[i+1] end}
    end
    function isServer() return true end
    function getServerName() return "workflow-fixture" end
    function getTimestampMs() return f.time*1000 end
    function getPlayerByOnlineID(id) return f.players[id] end
    function f:addPlayer(id,name)
        local p={id=id,name=name,x=0,y=0,z=0}
        function p:getOnlineID() return self.id end
        function p:getUsername() return self.name end
        function p:getX() return self.x end
        function p:getY() return self.y end
        function p:getZ() return self.z end
        function p:isDead() return self.dead==true end
        self.players[id]=p
    end
    function getFileReader(name,create)
        if create and f.files[name]==nil then f.files[name]="" end
        local text=f.files[name];if text==nil then return nil end
        local lines={};for line in text:gmatch("([^\n]*)\n") do lines[#lines+1]=line end
        local index=0
        return {readLine=function() index=index+1;return lines[index] end,close=function() end}
    end
    function getFileWriter(name)
        if f.failWrites then return nil end
        return {write=function(_,text) f.files[name]=text end,close=function() end}
    end
    function sendServerCommand(player,module,command,args)
        f.sent[#f.sent+1]={recipient=player:getOnlineID(),module=module,command=command,args=args}
    end
    Events={}
    for _,name in ipairs({"OnServerStarted","OnClientCommand","OnTick"}) do
        local event={callbacks={}}
        function event.Add(callback) event.callbacks[#event.callbacks+1]=callback end
        function event.fire(...) for _,callback in ipairs(event.callbacks) do callback(...) end end
        Events[name]=event
    end
    require "B47ANCEDMedicalChecks/Authority"
    function f:start() Events.OnServerStarted.fire() end
    function f:command(id,module,command,args) Events.OnClientCommand.fire(module,command,self.players[id],args) end
    function f:tick() Events.OnTick.fire() end
    return f
end
