
VSystemNoticeLayer = VClass("SystemNoticeLayer", VLayer)

function VSystemNoticeLayer:Init(attr)
    VSystemNoticeLayer.super.Init(self, attr)
    self:NeedEvent(Eff_onEnter+Eff_onExit);
    self.start = false
end

function VSystemNoticeLayer:onPush()
    self.texSystemNotice = self("texSystemNotice");
    if not gData.offlineData:isOffline() then
        self:StartShow();
    end
end

function VSystemNoticeLayer:StartShow()
    if self.start then return end
    self.visible = true
    self.start = true
    self:ShowNotifyInfo();
end

function VSystemNoticeLayer:StopShow()
    self.start = false
    self.visible = false
end

function VSystemNoticeLayer:StartRun(notify)
    self.texSystemNotice:setString(notify.context);
    local contextSize = self.texSystemNotice:getContentSize();
    local layerSize = self("laySystemNoticeLayer"):getContentSize();
    
    local l =  contextSize.width + layerSize.width + 20;
    local speed = l/30;
    self.texSystemNotice:ReLayout();
    self.texSystemNotice:RunAction{{"moveBy", speed, -l, 0},
                                    {self, "ShowNotifyInfo"}};
end

function VSystemNoticeLayer:ShowNotifyInfo()
    if not gData.notifyInfo then return end;
    local notify = gData.notifyInfo:nextNotify()
    if notify == nil then
        self:StopShow()
    else       
        self:StartRun(notify);
    end
end