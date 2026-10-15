-- Server-owned cooperative workflow. This NEVER authorizes native health access.
local C=require "B47ANCEDMedicalChecks/Config"
local Coop={};Coop.__index=Coop
function Coop.new(engine,store)
    -- Never reuse grants recovered from an older slot: a revocation may be missing.
    -- Seed both empty slots on a fresh cooperative profile so its first restart is healthy.
    if store and (store.recovered or (store.generation==1 and next(store.db.accounts)==nil and not store:save(store.db))) then store=nil end
    return setmetatable({e=engine,store=store,pending={},sequence=0,sessions={},
        lastRequest=setmetatable({},{__mode="k"}),lastRevoke=setmetatable({},{__mode="k"})},Coop)
end
function Coop:live(player)
    return player and self.e.a.find(player:getOnlineID())==player and C.validString(self.e.a.identity(player))
end
function Coop:near(examiner,patient)
    return self:live(examiner) and self:live(patient) and examiner~=patient and
        not examiner:isDead() and not patient:isDead() and
        math.abs(examiner:getX()-patient:getX())<=2 and math.abs(examiner:getY()-patient:getY())<=2 and
        math.abs(examiner:getZ()-patient:getZ())<0.5
end
function Coop:reply(player,command,args) self.e:reply(player,command,args) end
function Coop:result(player,nonce,reason)
    self:reply(player,"CoopResult",{nonce=nonce,reason=reason})
    if C.options().debug then print("[B47MC] Cooperative workflow: "..reason.."; native authority BLOCKED") end
end
function Coop:finish(id,reason)
    local r=self.pending[id];if not r then return end
    self.pending[id]=nil
    if self:live(r.patient) then self:reply(r.patient,"CoopClose",{id=id}) end
    if self:live(r.examiner) then self:result(r.examiner,r.nonce,reason) end
end
function Coop:allowed(patient,examiner)
    if C.options().retention==2 then
        local session=self.sessions[patient]
        return session and session[examiner]==true
    end
    local r=self.store and self.store.db.accounts[self.e.a.identity(patient)]
    return r and r.grants[self.e.a.identity(examiner)]~=nil
end
function Coop:saveGrant(patient,key,label,remove)
    if not self.store then return false end
    local owner=self.e.a.identity(patient);local db={schema=2,accounts={}}
    for k,v in pairs(self.store.db.accounts) do db.accounts[k]=v end
    local previous=db.accounts[owner];local r={preference=1,grants={}}
    if previous then for k,v in pairs(previous.grants) do r.grants[k]=v end end
    r.grants[key]=remove and nil or label
    db.accounts[owner]=r
    return self.store:save(db)
end
function Coop:list(patient)
    local result={}
    if C.options().retention==2 then
        for examiner in pairs(self.sessions[patient] or {}) do
            if self:live(examiner) then result[#result+1]={key=self.e.a.identity(examiner),label=self.e.a.identity(examiner),cooperative=true} end
        end
    else
        local r=self.store and self.store.db.accounts[self.e.a.identity(patient)]
        for key,label in pairs(r and r.grants or {}) do result[#result+1]={key=key,label=label,cooperative=true} end
    end
    table.sort(result,function(a,b) return a.key<b.key end)
    return result
end
function Coop:tick()
    local now=self.e.a.now()
    for id,r in pairs(self.pending) do
        if now<r.created or now>=r.expires or not self:near(r.examiner,r.patient) then self:finish(id,"Expired") end
    end
    for patient,examiners in pairs(self.sessions) do
        if not self:live(patient) then self.sessions[patient]=nil else
            for examiner in pairs(examiners) do if not self:live(examiner) then examiners[examiner]=nil end end
        end
    end
end
function Coop:command(player,command,args)
    if command~="CoopRequest" and command~="CoopAnswer" and command~="CoopConfirm" and command~="RevokeApproval" then return false end
    if not self:live(player) or type(args)~="table" or args.protocol~=C.protocol then return true end
    self:tick()
    local o=C.options()
    if command=="RevokeApproval" then
        if not C.validString(args.key) then return true end
        local last=self.lastRevoke[player];local now=self.e.a.now()
        if last and now>=last and now-last<0.25 then self.e:snapshot(player,self.e.a.identity(player),"RateLimited");return true end
        self.lastRevoke[player]=now
        if not self:saveGrant(player,args.key,nil,true) then self.e:snapshot(player,self.e.a.identity(player),"StorageFailed");return true end
        for examiner in pairs(self.sessions[player] or {}) do if self.e.a.identity(examiner)==args.key then self.sessions[player][examiner]=nil end end
        for id,r in pairs(self.pending) do if r.patient==player and self.e.a.identity(r.examiner)==args.key then self:finish(id,"Revoked") end end
        self.e:snapshot(player,self.e.a.identity(player),"Saved");return true
    end
    if command=="CoopRequest" then
        if type(args.nonce)~="number" or args.nonce~=math.floor(args.nonce) or args.nonce<1 or args.nonce>2147483647 then return true end
        if not o.cooperative then self:result(player,args.nonce,"Disabled");return true end
        if type(args.target)~="number" or args.target~=math.floor(args.target) or args.target<0 or args.target>32767 then return true end
        local patient=self.e.a.find(args.target)
        if not self.e.store or not self.store or not self:near(player,patient) then self:result(player,args.nonce,"Unavailable");return true end
        local last=self.lastRequest[player];local now=self.e.a.now()
        if last and now>=last and now-last<math.max(0.25,o.cooldown) then self:result(player,args.nonce,"RateLimited");return true end
        self.lastRequest[player]=now
        local count,patientCount=0,0
        for _,r in pairs(self.pending) do
            count=count+1;if r.patient==patient then patientCount=patientCount+1 end
            if r.examiner==player then self:result(player,args.nonce,"Busy");return true end
        end
        if count>=128 or patientCount>=8 then self:result(player,args.nonce,"Busy");return true end
        local preference=C.effective(self.e:record(self.e.a.identity(patient)).preference,o.policy)
        if preference==0 then self:result(player,args.nonce,"PolicyDenied");return true end
        repeat self.sequence=self.sequence%2147483647+1 until not self.pending[self.sequence]
        local id=self.sequence
        local r={examiner=player,patient=patient,nonce=args.nonce,created=now,expires=now+o.timeout,
            policy=o.policy,preference=preference,retention=o.retention}
        self.pending[id]=r
        if preference==2 and self:allowed(patient,player) then
            r.approved=true;self:reply(player,"CoopOffer",{id=id,nonce=r.nonce,target=args.target})
        else
            self:reply(patient,"CoopPrompt",{id=id,examiner=self.e.a.identity(player),timeout=o.timeout,remember=preference==2})
        end
        return true
    end
    local r=self.pending[args.id];if not r then return true end
    local preference=C.effective(self.e:record(self.e.a.identity(r.patient)).preference,o.policy)
    if not o.cooperative or o.policy~=r.policy or preference~=r.preference or o.retention~=r.retention then self:finish(args.id,"Expired");return true end
    if command=="CoopAnswer" then
        if r.patient~=player or r.approved or type(args.accept)~="boolean" then return true end
        if not args.accept then self:finish(args.id,"Refused");return true end
        if preference==2 then
            if o.retention==2 then
                local count=0;for _ in pairs(self.sessions[player] or {}) do count=count+1 end
                if count>=C.maxGrants and not (self.sessions[player] or {})[r.examiner] then self:finish(args.id,"Busy");return true end
                self.sessions[player]=self.sessions[player] or {};self.sessions[player][r.examiner]=true
            elseif not self:saveGrant(player,self.e.a.identity(r.examiner),self.e.a.identity(r.examiner)) then self:finish(args.id,"StorageFailed");return true end
        end
        r.approved=true
        self:reply(player,"CoopClose",{id=args.id})
        self:reply(r.examiner,"CoopOffer",{id=args.id,nonce=r.nonce,target=r.patient:getOnlineID()})
        self.e:snapshot(player,self.e.a.identity(player),"Blocked")
    elseif r.examiner==player and r.approved then
        -- Consume once, after live participants/policy and patient response were rechecked.
        self.pending[args.id]=nil
        self:reply(player,"CoopProceed",{id=args.id,nonce=r.nonce,target=r.patient:getOnlineID()})
    end
    return true
end
return Coop
