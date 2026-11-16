VWorldChatNoticeLayer = VClass("WorldChatNoticeLayer", VLayer)

function VWorldChatNoticeLayer:Init(attr)
    VWorldChatNoticeLayer.super.Init(self, attr)
    self:NeedEvent(Eff_onEnter+Eff_onExit);
    self.start = false
end

function VWorldChatNoticeLayer:onPush()
    self.texWorldChatNotice = self("texWorldChatNotice");
    if not gData.offlineData:isOffline() then
        self:StartShow();
    end
end

function VWorldChatNoticeLayer:StartShow()
    if self.start then return end
    self.visible = true
    self.start = true
    self:ShowNotifyInfo();
end

function VWorldChatNoticeLayer:StopShow()
    self.start = false
    self.visible = false
end

function VWorldChatNoticeLayer:StartRun(notify)
    self.texWorldChatNotice:setString(notify.nick..":"..notify.msg);
    local contextSize = self.texWorldChatNotice:getContentSize();
    local layerSize = self("layWorldChatNoticeLayer"):getContentSize();
    
    local l =  contextSize.width + layerSize.width + 20;
    local speed = l/30;
    self.texWorldChatNotice:ReLayout();
    self.texWorldChatNotice:RunAction{{"moveBy", speed, -l, 0},
                                    {self, "ShowNotifyInfo"}};
end

function VWorldChatNoticeLayer:ShowNotifyInfo()
    if not gData.chatNotifyInfo then return end;
   
    local notify = gData.chatNotifyInfo:nextNotify()
    if notify == nil then
    	
        self:StopShow()
    else
    	
        self:StartRun(notify);
    end
end