-- Settings authority. Cooperative workflow state is delegated; native access stays unprotected.
local C=require "B47ANCEDMedicalChecks/Config"
local Engine={};Engine.__index=Engine
function Engine.new(adapter,store)
    return setmetatable({a=adapter,store=store,serial=0,last=setmetatable({},{__mode="k"})},Engine)
end
function Engine:reply(player,command,args)
    self.serial=self.serial+1
    args.protocol=C.protocol;args.player=player:getOnlineID();args.serial=self.serial
    self.a.send(player,command,args)
end
function Engine:record(key)
    return self.store and self.store.db.accounts[key] or {preference=C.options().defaultPreference,grants={}}
end
function Engine:snapshot(player,key,reason)
    local o=C.options();local r=self:record(key);local grants={}
    for examiner,label in pairs(r.grants) do grants[#grants+1]={key=examiner,label=label} end
    if self.coop then for _,grant in ipairs(self.coop:list(player)) do grants[#grants+1]=grant end end
    table.sort(grants,function(a,b) return a.key<b.key end)
    self:reply(player,"Snapshot",{settingsReady=self.store~=nil,enforcement=false,reason=reason or "Blocked",
        preference=r.preference,effective=C.effective(r.preference,o.policy),policy=o.policy,retention=o.retention,
        cooperative=o.cooperative,approvalStorageReady=self.coop and self.coop.store~=nil or false,grants=grants})
end
function Engine:command(player,command,args)
    local key=self.a.identity(player)
    if not C.validString(key) then return end
    if args==nil then args={} end
    if type(args)~="table" then return end
    if self.coop and self.coop:command(player,command,args) then return end
    local now=self.a.now();local last=self.last[player]
    if last and now>=last and now-last<0.25 then
        -- Never silently leave the editor showing an uncommitted selection.
        -- Reads remain suppressed; rejected mutations only return private metadata.
        if command=="Preference" or command=="Revoke" then return self:snapshot(player,key,"RateLimited") end
        return
    end
    self.last[player]=now
    if args.protocol~=C.protocol then return self:snapshot(player,key,"ProtocolMismatch") end
    if command=="Snapshot" then return self:snapshot(player,key) end
    if command=="Request" or command=="Answer" or command=="Grant" then return self:snapshot(player,key,"Blocked") end
    if command~="Preference" and command~="Revoke" then return end
    if not self.store then return self:snapshot(player,key,"StorageFailed") end
    local old=self:record(key)
    local record={preference=old.preference,grants={}}
    for k,v in pairs(old.grants) do record.grants[k]=v end
    if command=="Preference" then
        if (args.preference~=1 and args.preference~=2) or C.options().policy~=1 then return self:snapshot(player,key,"Invalid") end
        record.preference=args.preference
    else
        if not C.validString(args.key) or not record.grants[args.key] then return self:snapshot(player,key,"Invalid") end
        record.grants[args.key]=nil
    end
    local db={schema=C.schema,accounts={}}
    for k,v in pairs(self.store.db.accounts) do db.accounts[k]=v end
    db.accounts[key]=record
    if not self.store:save(db) then return self:snapshot(player,key,"StorageFailed") end
    return self:snapshot(player,key,"Saved")
end
B47MC.Engine=Engine
return Engine
