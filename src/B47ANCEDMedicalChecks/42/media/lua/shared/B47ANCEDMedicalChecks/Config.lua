B47MC = B47MC or {}
local C={version="0.3.0-dev.1",module="B47ANCEDMedicalChecks",schema=2,protocol=3,
    maxIdentifier=128,maxAccounts=4096,maxGrants=128,maxBytes=2097152}
B47MC.Config=C
local function enum(v,default,count)
    if type(v)=="number" and v==math.floor(v) and v>=1 and v<=count then return v end
    return default
end
local function bounded(v,default,minimum,maximum)
    if type(v)=="number" and v==math.floor(v) and v>=minimum and v<=maximum then return v end
    return default
end
function C.validString(v)
    return type(v)=="string" and #v>0 and #v<=C.maxIdentifier and not v:find("%c")
end
function C.options()
    local s=SandboxVars and SandboxVars.B47ANCEDMedicalChecks or {}
    return {policy=enum(s.Policy,1,4),defaultPreference=enum(s.DefaultPreference,1,2),
        retention=enum(s.Retention,1,2),debug=s.DebugLogging==true,cooperative=s.CooperativeConsent~=false,
        cooldown=bounded(s.RequestCooldown,10,0,600),timeout=bounded(s.RequestTimeout,30,5,120)}
end
function C.effective(preference,policy)
    if policy==2 then return 1 end
    if policy==3 then return 2 end
    if policy==4 then return 0 end
    return preference
end
return C
