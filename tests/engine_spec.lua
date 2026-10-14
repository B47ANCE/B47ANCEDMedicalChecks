local Store=require "B47ANCEDMedicalChecks/Store"
local Engine=require "B47ANCEDMedicalChecks/Engine"
local function ioFixture()
 local f={files={}}
 f.io={reader=function(name,create)
  if f.unreadable then return nil end
  if not f.files[name] and create then f.files[name]="" end
  local text=f.files[name];if text==nil then return nil end
  local pos=1
  return {readLine=function()
   if f.readError then error("read") end
   if pos>#text then return nil end
   local a,b=text:find("\n",pos,true);local line=text:sub(pos,a and a-1 or #text);pos=b and b+1 or #text+1;return line
  end,close=function() end}
 end,writer=function(name)
  if f.writeError then return nil end
  local text=""
  return {write=function(_,value) text=text..value end,close=function()
   f.files[name]=f.torn and text:sub(1,#text-8) or text
  end}
 end}
 return f
end
local function fixture()
 SandboxVars={B47ANCEDMedicalChecks={}}
 local f=ioFixture();f.store=Store.open(f.io,"test-server");f.time=0;f.messages={}
 f.p={name="patient",id=1};f.e={name="examiner",id=2}
 for _,p in ipairs({f.p,f.e}) do function p:getOnlineID() return self.id end end
 f.a={identity=function(p) return p and p.name end,now=function() return f.time end,
  send=function(p,command,args) f.messages[#f.messages+1]={player=p,command=command,args=args} end}
 f.engine=Engine.new(f.a,f.store)
 function f:command(p,c,args) self.time=self.time+1;args=args or {};args.protocol=2;self.engine:command(p,c,args) end
 function f:last() return self.messages[#self.messages].args end
 function f:grantFixture()
  -- Trusted disposable metadata fixture, never a production grant API.
  assert(self.store:save({schema=2,accounts={patient={preference=2,grants={examiner="Examiner",other="Other"}}}}))
 end
 return f
end
local specs={}
function specs.bootstrap_and_restart()
 local f=fixture();assert(f.store.generation==1)
 f:command(f.p,"Preference",{preference=2})
 local reloaded=Store.open(f.io,"test-server");assert(reloaded.db.accounts.patient.preference==2)
end
function specs.authenticated_owner_not_client_field()
 local f=fixture();f:command(f.p,"Preference",{preference=2,owner="examiner",username="examiner",player=f.e})
 assert(f.store.db.accounts.patient.preference==2 and not f.store.db.accounts.examiner)
 assert(f.messages[#f.messages].player==f.p)
end
function specs.all_policies_remain_blocked()
 for policy=1,4 do local f=fixture();SandboxVars.B47ANCEDMedicalChecks.Policy=policy
  f:command(f.p,"Request",{target=2});assert(f:last().enforcement==false and f:last().reason=="Blocked")
  f:command(f.p,"Answer",{accept=true});assert(f:last().enforcement==false)
  f:command(f.p,"Grant",{key="examiner"});assert(not f.store.db.accounts.patient)
 end
end
function specs.policy_diagnostics_no_requests_is_not_authority()
 local f=fixture();SandboxVars.B47ANCEDMedicalChecks.Policy=4;f:command(f.p,"Snapshot")
 assert(f:last().effective==0 and not f:last().enforcement)
end
function specs.force_options_interpretation()
 local f=fixture()
 for policy=2,3 do SandboxVars.B47ANCEDMedicalChecks.Policy=policy;f:command(f.p,"Snapshot")
  assert(f:last().effective==policy-1)
  f:command(f.p,"Preference",{preference=2});assert(f:last().reason=="Invalid")
 end
end
function specs.only_once_preference_creates_no_grant()
 local f=fixture();f:command(f.p,"Preference",{preference=2})
 assert(next(f.store.db.accounts.patient.grants)==nil)
 f:command(f.p,"Request",{target=2});assert(next(f.store.db.accounts.patient.grants)==nil)
end
function specs.revoke_is_directional_and_persistent()
 local f=fixture();f:grantFixture();f:command(f.e,"Revoke",{key="examiner",owner="patient"})
 assert(f.store.db.accounts.patient.grants.examiner)
 f:command(f.p,"Revoke",{key="examiner"})
 local db=Store.open(f.io,"test-server").db
 assert(not db.accounts.patient.grants.examiner and db.accounts.patient.grants.other)
 assert(f:last().enforcement==false)
end
function specs.snapshot_does_not_disclose_other_accounts()
 local f=fixture();f:grantFixture();f:command(f.e,"Snapshot")
 assert(#f:last().grants==0 and f:last().player==2)
end
function specs.failed_write_rolls_back()
 local f=fixture();f:command(f.p,"Preference",{preference=1});f.writeError=true
 f:command(f.p,"Preference",{preference=2})
 assert(f:last().reason=="StorageFailed" and f.store.db.accounts.patient.preference==1)
end
function specs.partial_write_uses_previous_valid_slot()
 local f=fixture();f:command(f.p,"Preference",{preference=1});f.torn=true
 f:command(f.p,"Preference",{preference=2})
 assert(f:last().reason=="StorageFailed")
 local recovered=Store.open(f.io,"test-server");assert(recovered.db.accounts.patient.preference==1 and recovered.recovered)
end
function specs.repeated_load_is_idempotent()
 local f=fixture();f:command(f.p,"Preference",{preference=2});local generation=f.store.generation
 for i=1,4 do local s=Store.open(f.io,"test-server");assert(s.generation==generation and s.db.accounts.patient.preference==2) end
end
function specs.corrupt_both_slots_fails_without_replacement()
 local f=fixture();f.files[f.store.base.."_a.txt"]="corrupt\n";f.files[f.store.base.."_b.txt"]="corrupt\n"
 assert(not pcall(Store.open,f.io,"test-server"));assert(f.files[f.store.base.."_a.txt"]=="corrupt\n")
end
function specs.future_schema_is_not_downgraded()
 local f=fixture();f.files[f.store.base.."_b.txt"]="B47MC\t3\t2\nfuture\n"
 assert(not pcall(Store.open,f.io,"test-server"))
end
function specs.unreadable_storage_fails()
 local f=ioFixture();f.unreadable=true;assert(not pcall(Store.open,f.io,"test-server"))
 assert(next(f.files)==nil)
end
function specs.profiles_isolated_and_encoded()
 local f=fixture();f:command(f.p,"Preference",{preference=2})
 local other=Store.open(f.io,"../other/server");assert(next(other.db.accounts)==nil)
 for name in pairs(f.files) do assert(not name:find("/",1,true) and not name:find("..",1,true)) end
end
function specs.unicode_accounts_roundtrip()
 local f=fixture();f.p.name="patient_病人";f:command(f.p,"Preference",{preference=2})
 assert(Store.open(f.io,"test-server").db.accounts[f.p.name].preference==2)
end
function specs.invalid_and_duplicate_records_rejected()
 local f=fixture();local text=Store.encode({schema=2,accounts={patient={preference=1,grants={}}}},1)
 assert(not pcall(Store.decode,text:gsub("P\t","Q\t")))
 assert(not pcall(Store.encode,{schema=2,accounts={patient={preference=99,grants={}}}},1))
end
function specs.invalid_enum_defaults_without_prompt_bypass()
 local f=fixture();SandboxVars.B47ANCEDMedicalChecks={Policy=99,DefaultPreference=99}
 f:command(f.p,"Snapshot");assert(f:last().policy==1 and f:last().preference==1 and f:last().enforcement==false)
end
function specs.bad_protocol_and_nil_args_never_mutate()
 local f=fixture();f.engine:command(f.p,"Preference",{preference=2})
 assert(f:last().reason=="ProtocolMismatch" and not f.store.db.accounts.patient)
 f.time=2;f.engine:command(f.p,"Snapshot",nil);assert(not f:last().enforcement)
end
function specs.malformed_inputs_ignored_or_rejected()
 local f=fixture();f.engine:command(nil,"Snapshot",{});assert(#f.messages==0)
 f.engine:command(f.p,"Preference","bad");assert(#f.messages==0)
 f:command(f.p,"Preference",{preference="2"});assert(f:last().reason=="Invalid")
 f:command(f.p,"Revoke",{key={}});assert(f:last().reason=="Invalid")
end
function specs.rate_limited_and_no_per_tick_scan()
 local f=fixture();f:command(f.p,"Snapshot");local count=#f.messages
 f.engine:command(f.p,"Snapshot",{protocol=2});assert(#f.messages==count)
end
function specs.rapid_mutation_has_explicit_rejection()
 local f=fixture();f:command(f.p,"Snapshot");local count=#f.messages
 f.engine:command(f.p,"Preference",{protocol=2,preference=2})
 assert(#f.messages==count+1 and f:last().reason=="RateLimited")
 assert(not f.store.db.accounts.patient and f:last().preference==1)
 f:command(f.p,"Preference",{preference=2});assert(f:last().reason=="Saved")
end
function specs.floating_point_preference_roundtrips()
 local f=fixture();f:command(f.p,"Preference",{preference=2.0})
 assert(f:last().reason=="Saved")
 assert(Store.open(f.io,"test-server").db.accounts.patient.preference==2)
end
function specs.readback_failure_is_an_uncertain_write()
 local f=fixture();f:command(f.p,"Preference",{preference=1});f.readError=true
 f:command(f.p,"Preference",{preference=2})
 assert(f:last().reason=="StorageFailed" and f.store.db.accounts.patient.preference==1)
 f.readError=false
 -- A complete write can survive despite failed verification: no durable rollback claim.
 assert(Store.open(f.io,"test-server").db.accounts.patient.preference==2)
end
function specs.missing_store_refuses_mutations()
 local f=fixture();f.engine=Engine.new(f.a,nil);f:command(f.p,"Preference",{preference=2})
 assert(f:last().reason=="StorageFailed" and f:last().settingsReady==false)
end
function specs.saved_grants_never_authorize_exam()
 local f=fixture();f:grantFixture();f:command(f.p,"Request",{target=2})
 assert(f:last().reason=="Blocked" and f:last().enforcement==false)
end
function specs.account_character_change_retains_metadata()
 local f=fixture();f:command(f.p,"Preference",{preference=2})
 local newCharacter={name="patient",getOnlineID=function() return 9 end}
 f:command(newCharacter,"Snapshot");assert(f:last().preference==2 and f:last().player==9)
end
return specs
