local C=require "B47ANCEDMedicalChecks/Config"
require "ISUI/ISCollapsableWindow"
require "ISUI/ISComboBox"
require "ISUI/ISButton"
require "ISUI/ISScrollingListBox"
require "ISUI/ISLabel"
B47MC.Client=B47MC.Client or {snapshots={},windows={}}
local Client=B47MC.Client
function Client.send(player,command,args)
    if not isClient() or not player then return end
    args=args or {};args.protocol=C.protocol
    sendClientCommand(player,C.module,command,args)
end
local function text(key) return getText("UI_B47MC_"..key) end
local Window=ISCollapsableWindow:derive("B47MCPreferencesWindow")
function Window:createChildren()
    ISCollapsableWindow.createChildren(self)
    local pad=12
    local line=getTextManager():getFontHeight(UIFont.Small)+8
    self.status=ISLabel:new(pad,36,line,text("Loading"),1,1,1,1,UIFont.Small,true)
    self:addChild(self.status)
    self.policy=ISLabel:new(pad,36+line,line,text("Blocked"),1,0.8,0.4,1,UIFont.Small,true)
    self:addChild(self.policy)
    self.preference=ISComboBox:new(pad,44+line*2,self.width-pad*2,line,self,Window.onPreference)
    self.preference:initialise()
    self.preference:addOption(text("AlwaysAsk"))
    self.preference:addOption(text("OnlyOnce"))
    self:addChild(self.preference)
    self.preference:setEnabled(false)
    self.explanation=ISLabel:new(pad,48+line*3,line,text("Draft"),0.8,0.8,0.8,1,UIFont.Small,true)
    self:addChild(self.explanation)
    self.list=ISScrollingListBox:new(pad,56+line*4,self.width-pad*2,self.height-(56+line*4)-64)
    self.list:initialise(); self.list:instantiate(); self.list.itemheight=line
    self:addChild(self.list)
    local y=self.height-50
    self.revoke=ISButton:new(pad,y,self.width/2-pad-3,28,text("Revoke"),self,Window.onRevoke)
    self.revoke:initialise(); self:addChild(self.revoke)
    self.revoke:setEnable(false)
    self.refreshButton=ISButton:new(self.width/2+3,y,self.width/2-pad-3,28,text("Refresh"),self,Window.onRefresh)
    self.refreshButton:initialise(); self:addChild(self.refreshButton)
    self:apply(Client.snapshots[self.player:getOnlineID()])
end
function Window:apply(snapshot)
    self.snapshot=snapshot
    if not self.preference then return end
    self.list:clear()
    if not snapshot then self.status:setName(text("Loading")); return end
    local reason=snapshot.reason
    if reason~="Saved" and reason~="Invalid" and reason~="ProtocolMismatch" and reason~="StorageFailed" then reason="Blocked" end
    self.status:setName(text(snapshot.settingsReady and reason or "StorageFailed"))
    self.policy:setName(text("Policy"..snapshot.policy))
    self.preference.selected=snapshot.policy==2 and 1 or (snapshot.policy==3 and 2 or snapshot.preference)
    self.preference:setEnabled(snapshot.settingsReady==true and snapshot.policy==1)
    self.revoke:setEnable(snapshot.settingsReady==true and #(snapshot.grants or {})>0)
    for _,grant in ipairs(snapshot.grants or {}) do self.list:addItem(grant.label,grant) end
    if #self.list.items==0 then self.list:addItem(text("NoApprovals"),{empty=true}) end
end
function Window:onPreference()
    if self.snapshot and self.snapshot.settingsReady and self.snapshot.policy==1 then
        Client.send(self.player,"Preference",{preference=self.preference.selected})
    end
end
function Window:onRevoke()
    local row=self.list.items[self.list.selected]
    if row and not row.item.empty then Client.send(self.player,"Revoke",{key=row.item.key}) end
end
function Window:onRefresh() Client.send(self.player,"Snapshot") end
function Window:new(player)
    local width=math.max(620,getTextManager():MeasureStringX(UIFont.Small,text("Draft"))+32)
    local height=430
    local n=ISCollapsableWindow.new(self,getPlayerScreenLeft(player:getPlayerNum())+60,getPlayerScreenTop(player:getPlayerNum())+60,width,height)
    n.player=player; n.title=text("Settings"); n.resizable=false
    return n
end
function Client.open(player)
    local id=player:getOnlineID()
    local window=Client.windows[id]
    if not window then
        window=Window:new(player); window:initialise(); window:instantiate(); Client.windows[id]=window
    end
    window:addToUIManager(); window:setVisible(true); window:bringToTop()
    Client.send(player,"Snapshot")
end
return Client
