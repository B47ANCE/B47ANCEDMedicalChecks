-- Offline workflow/storage fixtures. Never evidence of native packet enforcement.
local Store=require "B47ANCEDMedicalChecks/Store"
local Engine=require "B47ANCEDMedicalChecks/Engine"
local Coop=require "B47ANCEDMedicalChecks/Cooperative"
local function fixture()
 SandboxVars={B47ANCEDMedicalChecks={RequestCooldown=0}}
 local f={files={},players={},messages={},time=100,nonce=0}
 local io={reader=function(name,create)
  if create and f.files[name]==nil then f.files[name]="" end
  local s=f.files[name];if s==nil then return nil end
  local lines={};for line in s:gmatch("([^\n]*)\n") do lines[#lines+1]=line end
  local i=0;return {readLine=function() i=i+1;return lines[i] end,close=function() end}
 end,writer=function(name)
  if f.fail then return nil end
  return {write=function(_,text) f.files[name]=text end,close=function() end}
 end}
 f.io=io
 function f:player(id,name)
  local p={id=id,name=name,x=0,y=0,z=0}
  function p:getOnlineID() return self.id end
  function p:getX() return self.x end;function p:getY() return self.y end;function p:getZ() return self.z end
  function p:isDead() return self.dead or false end
  self.players[id]=p;return p
 end
 f.e=f:player(1,"examiner");f.p=f:player(2,"patient");f.other=f:player(3,"other")
 f.store=Store.open(io,"test");f.approvals=Store.open(io,"test","cooperative")
 f.engine=Engine.new({identity=function(p) return p.name end,find=function(id) return f.players[id] end,
  now=function() return f.time end,send=function(p,c,a) f.messages[#f.messages+1]={player=p,command=c,args=a} end},f.store)
 f.coop=Coop.new(f.engine,f.approvals);f.engine.coop=f.coop
 function f:command(p,c,a) self.time=self.time+1;a=a or {};a.protocol=3;self.engine:command(p,c,a) end
 function f:request(e,p) self.nonce=self.nonce+1;self:command(e or self.e,"CoopRequest",{target=(p or self.p).id,nonce=self.nonce}) end
 function f:count(c) local n=0;for _,m in ipairs(self.messages) do if m.command==c then n=n+1 end end;return n end
 function f:last(c) for i=#self.messages,1,-1 do if self.messages[i].command==c then return self.messages[i] end end end
 function f:onlyOnce() self:command(self.p,"Preference",{preference=2}) end
 function f:yes() local id=self:last("CoopPrompt").args.id;self:command(self.p,"CoopAnswer",{id=id,accept=true});return id end
 function f:confirm(id) self:command(self.e,"CoopConfirm",{id=id}) end
 return f
end
local t={}
function t.always_asks_each_time_and_consumes_once()
 local f=fixture();f:request();local id=f:yes();f:confirm(id);f:confirm(id)
 assert(f:count("CoopProceed")==1 and next(f.approvals.db.accounts)==nil)
 f:request();assert(f:count("CoopPrompt")==2)
end
function t.only_once_persists_directional_grant_and_reuses()
 local f=fixture();f:onlyOnce();f:request();f:confirm(f:yes())
 assert(Store.open(f.io,"test","cooperative").db.accounts.patient.grants.examiner)
 assert(not f.approvals.db.accounts.examiner)
 f:request();assert(f:count("CoopPrompt")==1 and f:last("CoopOffer").player==f.e)
end
function t.refusal_creates_no_grant_and_reprompts()
 local f=fixture();f:onlyOnce();f:request();f:command(f.p,"CoopAnswer",{id=f:last("CoopPrompt").args.id,accept=false})
 assert(f:last("CoopResult").args.reason=="Refused" and next(f.approvals.db.accounts)==nil)
 f:request();assert(f:count("CoopPrompt")==2)
end
function t.forged_patient_answer_is_ignored()
 local f=fixture();f:request();local id=f:last("CoopPrompt").args.id
 f:command(f.e,"CoopAnswer",{id=id,accept=true,owner="patient"});assert(f:count("CoopOffer")==0)
 f:yes();f:command(f.other,"CoopConfirm",{id=id});assert(f:count("CoopProceed")==0)
 f:confirm(id);assert(f:count("CoopProceed")==1)
end
function t.expiry_prevents_late_response()
 local f=fixture();f:request();local id=f:last("CoopPrompt").args.id;f.time=f.time+31
 f:command(f.p,"CoopAnswer",{id=id,accept=true});assert(f:count("CoopOffer")==0 and next(f.coop.pending)==nil)
end
function t.distance_floor_dead_or_disconnect_cancel()
 for _,mode in ipairs({"move","floor","dead","disconnect"}) do
  local f=fixture();f:request();local id=f:yes()
  if mode=="move" then f.p.x=10 elseif mode=="floor" then f.p.z=1 elseif mode=="dead" then f.p.dead=true else f.players[2]=nil end
  f:confirm(id);assert(f:count("CoopProceed")==0)
 end
end
function t.reconnect_object_cannot_answer_old_ticket()
 local f=fixture();f:request();local id=f:last("CoopPrompt").args.id
 local p=f:player(2,"patient");f:command(p,"CoopAnswer",{id=id,accept=true});assert(f:count("CoopOffer")==0)
end
function t.revocation_is_individual_and_cancels_offer()
 local f=fixture();f:onlyOnce();f:request();local id=f:yes()
 assert(f.coop:saveGrant(f.p,"other","other"))
 f:command(f.p,"RevokeApproval",{key="examiner"});f:confirm(id)
 assert(f:count("CoopProceed")==0 and not f.approvals.db.accounts.patient.grants.examiner and f.approvals.db.accounts.patient.grants.other)
 f:request();assert(f:count("CoopPrompt")==2)
end
function t.other_account_cannot_revoke_patient_grant()
 local f=fixture();f:onlyOnce();f:request();f:confirm(f:yes())
 f:command(f.other,"RevokeApproval",{key="examiner",owner="patient"})
 assert(f.approvals.db.accounts.patient.grants.examiner)
end
function t.force_always_ignores_remembered_grant()
 local f=fixture();f:onlyOnce();f:request();f:confirm(f:yes());SandboxVars.B47ANCEDMedicalChecks.Policy=2
 f:request();assert(f:count("CoopPrompt")==2)
end
function t.force_only_once_uses_remembered_grant()
 local f=fixture();SandboxVars.B47ANCEDMedicalChecks.Policy=3;f:request();f:confirm(f:yes());f:request()
 assert(f:count("CoopPrompt")==1)
end
function t.no_requests_and_disabled_have_explicit_results()
 local f=fixture();SandboxVars.B47ANCEDMedicalChecks.Policy=4;f:request();assert(f:last("CoopResult").args.reason=="PolicyDenied")
 SandboxVars.B47ANCEDMedicalChecks.CooperativeConsent=false;f:request();assert(f:last("CoopResult").args.reason=="Disabled")
 assert(f:count("CoopPrompt")==0)
end
function t.policy_or_preference_change_invalidates_offer()
 for _,mode in ipairs({"policy","preference","retention"}) do
  local f=fixture();f:request();local id=f:yes()
  if mode=="policy" then SandboxVars.B47ANCEDMedicalChecks.Policy=4
  elseif mode=="preference" then f:command(f.p,"Preference",{preference=2})
  else SandboxVars.B47ANCEDMedicalChecks.Retention=2 end
  f:confirm(id);assert(f:count("CoopProceed")==0)
 end
end
function t.session_retention_is_memory_only_and_disconnect_clears()
 local f=fixture();SandboxVars.B47ANCEDMedicalChecks.Retention=2;f:onlyOnce();f:request();f:confirm(f:yes());f:request()
 assert(f:count("CoopPrompt")==1 and next(f.approvals.db.accounts)==nil)
 f.coop.pending={};f.players[2]=nil;f.coop:tick();f.p=f:player(2,"patient");f:request()
 assert(f:count("CoopPrompt")==2)
end
function t.restart_clears_tickets_but_keeps_persistent_grants()
 local f=fixture();f:onlyOnce();f:request();f:yes()
 local restart=Coop.new(f.engine,Store.open(f.io,"test","cooperative"));f.coop=restart;f.engine.coop=restart
 assert(next(restart.pending)==nil);f:request();assert(f:count("CoopPrompt")==1 and f:count("CoopOffer")==2)
end
function t.legacy_inactive_grants_never_become_cooperative()
 local f=fixture();assert(f.store:save({schema=2,accounts={patient={preference=2,grants={examiner="examiner"}}}}))
 f:request();assert(f:count("CoopPrompt")==1 and f:count("CoopOffer")==0)
 assert(f.store.base~=f.approvals.base)
end
function t.storage_failure_does_not_offer_persistent_approval()
 local f=fixture();f:onlyOnce();f:request();f.fail=true;f:yes()
 assert(f:count("CoopOffer")==0 and f:last("CoopResult").args.reason=="StorageFailed")
end
function t.cooldown_and_patient_pending_cap_are_bounded()
 local f=fixture();SandboxVars.B47ANCEDMedicalChecks.RequestCooldown=10;f:request();f:request()
 assert(f:last("CoopResult").args.reason=="RateLimited")
 for i=4,12 do local p=f:player(i,"examiner"..i);f:request(p) end
 assert(f:count("CoopPrompt")==8 and f:last("CoopResult").args.reason=="Busy")
end
function t.protocol_and_malformed_requests_do_not_mutate()
 local f=fixture()
 for _,args in ipairs({{protocol=2,target=2,nonce=1},{protocol=3,target="2",nonce=1},{protocol=3,target=2,nonce=0/0}}) do
  f.engine:command(f.e,"CoopRequest",args)
 end
 assert(next(f.coop.pending)==nil and next(f.approvals.db.accounts)==nil)
end
function t.snapshots_still_never_claim_native_authority()
 local f=fixture();f:command(f.p,"Snapshot");assert(f:last("Snapshot").args.enforcement==false)
end
function t.fresh_approval_profile_seeds_both_slots_for_restart()
 local f=fixture();assert(not Store.open(f.io,"test","cooperative").recovered)
end
function t.corrupt_latest_revocation_never_reactivates_older_approval()
 local f=fixture();f:onlyOnce();f:request();f:confirm(f:yes());f:command(f.p,"RevokeApproval",{key="examiner"})
 local name=f.approvals.base.."_"..f.approvals.slot..".txt";f.files[name]="corrupt\n"
 local recovered=Store.open(f.io,"test","cooperative");assert(recovered.recovered)
 f.coop=Coop.new(f.engine,recovered);f.engine.coop=f.coop
 f:request();assert(f:last("CoopResult").args.reason=="Unavailable" and f.files[name]=="corrupt\n")
end
function t.revoking_own_record_does_not_reset_examiner_request_cooldown()
 local f=fixture();SandboxVars.B47ANCEDMedicalChecks.RequestCooldown=10
 f:request();f:confirm(f:yes());f.time=110
 f:command(f.e,"RevokeApproval",{key="other"});f:request()
 assert(f:count("CoopPrompt")==2)
end
function t.missing_latest_revocation_slot_never_reactivates_older_grant()
 local f=fixture();f:onlyOnce();f:request();f:confirm(f:yes());f:command(f.p,"RevokeApproval",{key="examiner"})
 local name=f.approvals.base.."_"..f.approvals.slot..".txt";f.files[name]=nil
 local recovered=Store.open(f.io,"test","cooperative")
 f.coop=Coop.new(f.engine,recovered);f.engine.coop=f.coop
 local before=f:count("CoopOffer");f:request()
 assert(f.coop.store==nil and f:count("CoopOffer")==before)
end
return t
