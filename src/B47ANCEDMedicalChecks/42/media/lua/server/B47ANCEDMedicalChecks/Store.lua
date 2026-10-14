-- Private server metadata, not global ModData and never examination authority.
local C=require "B47ANCEDMedicalChecks/Config"
local Store={};Store.__index=Store
local function hex(s) return (s:gsub(".",function(c) return string.format("%02x",string.byte(c)) end)) end
local function unhex(s)
    if #s%2~=0 or s:find("[^0-9a-f]") then error("invalid encoding") end
    return (s:gsub("..",function(c) return string.char(tonumber(c,16)) end))
end
local function checksum(s)
    local a,b=1,0
    for i=1,#s do a=(a+s:byte(i))%65521;b=(b+a)%65521 end
    return b*65536+a
end
local function sorted(t) local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
local function encode(db,generation)
    assert(type(db)=="table" and db.schema==C.schema and type(db.accounts)=="table","schema")
    local lines={"B47MC\t2\t"..string.format("%.0f",generation)}
    local keys=sorted(db.accounts);assert(#keys<=C.maxAccounts,"account limit")
    for _,key in ipairs(keys) do
        assert(C.validString(key),"account")
        local r=db.accounts[key]
        assert(r.preference==1 or r.preference==2,"preference")
        lines[#lines+1]="P\t"..hex(key).."\t"..string.format("%.0f",r.preference)
        local grants=sorted(r.grants);assert(#grants<=C.maxGrants,"grant limit")
        for _,examiner in ipairs(grants) do
            assert(C.validString(examiner) and C.validString(r.grants[examiner]),"grant")
            lines[#lines+1]="G\t"..hex(key).."\t"..hex(examiner).."\t"..hex(r.grants[examiner])
        end
    end
    local body=table.concat(lines,"\n").."\n"
    local text=body.."END\t"..string.format("%.0f",checksum(body)).."\n"
    assert(#text<=C.maxBytes,"file limit")
    return text
end
local function decode(text)
    assert(#text<=C.maxBytes,"file limit")
    local body,digest=text:match("^(.*\n)END\t(%d+)\n$")
    assert(body and tonumber(digest)==checksum(body),"incomplete/checksum")
    local generation=body:match("^B47MC\t2\t(%d+)\n")
    generation=tonumber(generation)
    assert(generation and generation>=1 and generation<=9007199254740990,"generation/schema")
    local db={schema=2,accounts={}}
    local first=true
    for line in body:gmatch("([^\n]+)\n") do
        if first then first=false else
            local user,pref=line:match("^P\t([0-9a-f]+)\t([12])$")
            if user then
                user=unhex(user);assert(not db.accounts[user],"duplicate account")
                db.accounts[user]={preference=tonumber(pref),grants={}}
            else
                local patient,examiner,label=line:match("^G\t([0-9a-f]+)\t([0-9a-f]+)\t([0-9a-f]+)$")
                assert(patient,"record")
                patient,examiner,label=unhex(patient),unhex(examiner),unhex(label)
                local account=db.accounts[patient];assert(account and not account.grants[examiner],"grant owner/duplicate")
                account.grants[examiner]=label
            end
        end
    end
    assert(encode(db,generation)==text,"noncanonical/invalid data")
    return db,generation
end
local function read(io,name,create)
    local reader=io.reader(name,create)
    if not reader then return nil end
    local ok,text=pcall(function()
        local lines,total={},0
        while true do
            local line=reader:readLine();if line==nil then break end
            total=total+#line+1;assert(total<=C.maxBytes,"file limit")
            lines[#lines+1]=line
        end
        if #lines==0 then return "" end
        return table.concat(lines,"\n").."\n"
    end)
    local closed=pcall(function() reader:close() end)
    assert(ok and closed,"read failed")
    return text
end
function Store.open(io,profile)
    assert(C.validString(profile),"invalid server profile")
    local self=setmetatable({io=io,base="B47MC_"..hex(profile),generation=0},Store)
    local valid,missing,invalid={},0,0
    for _,slot in ipairs({"a","b"}) do
        local name=self.base.."_"..slot..".txt"
        local text=read(io,name,false)
        if text==nil then
            -- createIfNull=true distinguishes a missing file from an unreadable file.
            text=read(io,name,true);assert(text~=nil,"storage unreadable")
            if text=="" then missing=missing+1 else invalid=invalid+1 end
        end
        if text~="" then
            local schema=text:match("^B47MC\t(%d+)\t")
            assert(not schema or schema=="2","unsupported future/legacy schema; do not downgrade")
            local ok,db,generation=pcall(decode,text)
            if ok then valid[#valid+1]={db=db,generation=generation,text=text,slot=slot} else invalid=invalid+1 end
        elseif missing==0 then invalid=invalid+1 end
    end
    table.sort(valid,function(a,b) return a.generation>b.generation end)
    if #valid>0 then
        if #valid==2 and valid[1].generation==valid[2].generation and valid[1].text~=valid[2].text then error("conflicting generations") end
        self.db,self.generation,self.slot=valid[1].db,valid[1].generation,valid[1].slot
        self.recovered=invalid>0
    else
        assert(missing==2 and invalid==0,"no valid consent metadata; preserve files for recovery")
        self.db={schema=2,accounts={}}
        assert(self:save(self.db),"initial storage write failed")
    end
    return self
end
function Store:save(db)
    local ok=pcall(function()
        local generation=self.generation+1
        local text=encode(db,generation)
        local slot=self.slot=="a" and "b" or "a"
        local name=self.base.."_"..slot..".txt"
        local writer=self.io.writer(name,true,false);assert(writer,"writer unavailable")
        local wrote,err=pcall(function() writer:write(text) end)
        local closed=pcall(function() writer:close() end)
        assert(wrote and closed,err or "close failed")
        assert(read(self.io,name,false)==text,"write read-back failed")
        local checked,sequence=decode(text)
        self.db,self.generation,self.slot=checked,sequence,slot
    end)
    return ok
end
Store.encode,Store.decode=encode,decode
return Store
