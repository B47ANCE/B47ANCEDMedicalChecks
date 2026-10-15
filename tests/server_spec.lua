local function setup()
 local f={sent={}};local player={getUsername=function() return "account" end,getOnlineID=function() return 1 end}
 f.player=player;Events={}
 for _,name in ipairs({"OnServerStarted","OnClientCommand","OnTick"}) do
  local ev={};function ev.Add(cb) ev.callback=cb end;Events[name]=ev
 end
 function isServer() return true end
 function getServerName() return "test" end
 function getFileReader() return nil end
 function getFileWriter() return nil end
 function getTimestampMs() return 1000 end
 function sendServerCommand(p,m,c,a) f.sent[#f.sent+1]=a end
 require "B47ANCEDMedicalChecks/Authority"
 Events.OnServerStarted.callback()
 return f
end
return {
 headless_failure_is_explicit=function()
  local f=setup();Events.OnClientCommand.callback("B47ANCEDMedicalChecks","Snapshot",f.player,{protocol=3})
  assert(f.sent[1].settingsReady==false and f.sent[1].enforcement==false)
  assert(ISHealthPanel==nil and ISUI==nil and Events.OnTick.callback~=nil)
 end,
 other_modules_ignored=function()
  local f=setup();Events.OnClientCommand.callback("other","Snapshot",f.player,{protocol=3});assert(#f.sent==0)
 end,
}
