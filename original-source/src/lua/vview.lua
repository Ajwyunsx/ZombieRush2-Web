--vview.lua

VView = VClass("View", VNode)

function VView:onCreate(attr)
    return VLayer.onCreate(self, attr);
end

function VView:Init(attr)
    VNode.Init(self, attr);
    if not attr.size then self.size = {800,450}; end
    if not attr.fit then self.fit = _VLayout.Fill; end
    self:NeedEvent(Eff_onEnter+Eff_onExit);
    if gWindow.needAction then
        self.pushAction = {{"stepTo",0,1,0},{"show"},{"stepTo",0.2,0,0}};
        self.popAction = {"stepTo",0.2,1,0};
        self.showAction = {"stepTo",0.2,0,0};
        self.hideAction = {"stepTo",0.2,-1,0};
        self.stopEventTime = 0.3;
    end
end

function VView:onForeground()
    for i=0,self:Count()-1 do
        local node = self(i);
        if node and node.isMsgBox and node["onForeground"] then
            node["onForeground"](node)
        end
    end
end

function VView:hasMsgBox()
    for i=0,self:Count()-1 do
        local node = self(i);
        if node and node.isMsgBox then
            return true;
        end
    end
    return false;
end

function VView:CloseAllMsgBox()
    local msgBoxList = {}
    for i=0, self:Count()-1 do
        local node = self(i);
        if node and node.isMsgBox then
            table.insert(msgBoxList, node)
        end
    end
    for k, v in pairs(msgBoxList) do
        cclog("CloseAllMsgBox~~~"..v.name)
        v:doPop()
        cclog("finish~~~")
    end
end

function VView:onKeyBack()
	local node = self(-1);
	if node and node.isMsgBox then
		self:Pop()
		return true;
	end
end
function VView:onPushBase()
    -- if gWindow:Count() > 1 then
    --     gWindow(-2):onHideBase();
    if gWindow:viewCount() > 1 then
        gWindow:view(-2):onHideBase();
    else
        self.pushAction = nil;
        self.popAction = nil;
    end
    VNode.onPushBase(self);
end
function VView:doPop(func)
    -- if gWindow:Count() > 1 then
    --     gWindow(-2):onShowBase();
    if gWindow:viewCount() > 1 then
        gWindow:view(-2):onShowBase();
        return VNode.doPop(self, func);
    end
    self:exitGame()
    -- gDtr:endToLua();
end

function VView:exitGame()
    -- local tip = self("exitTip");
    -- if tip then 
    --     if self == gMainView or self == gBattleView then
    --         gData.offlineData:saveOfflineData();
    --     end
    --     if gPackage == 1000 then
    --         gSys:preExitGame();
    --         return;
    --     end
    --     gDtr:endToLua();
    --     return
    -- end

    -- tip = VNode("<File=\"exitTip\", fileName=\"vshowtip.vui\">")
    -- tip("texShowTip").text = "再按一次退出游戏";
    -- self:Push(tip);
    local ct = gView()("confirmtip");
    if ct then ct:doPop(); return; end
    local extend = {}
    extend.title = "提示" 
    extend.content = "是否退出游戏!"
    -- commonMsgDlg:ShowCommMsgBox("FREE", self, "exitGame", extend)
    gAudio:playEffect("sys_exitGame.ogg");

    gWindow:showConfirmTip("是否退出游戏!", "确定", "取消", self, "endToLua", "", "提示",
        extend);
end

function VView:endToLua(  )
    if gPackage == 1003 or gPackage == 1020 then
        gSys:preExitGame();
        return;
    end
    gDtr:endToLua();
end

function VView:onShowBase()
    self.visible = true;
    if self.showAction then
        self:RunAction{self.showAction,{"@onShow"}}
    else
        if self.onShow then self:onShow() end
    end
end
function VView:onHideBase()
    if self.hideAction then
        self:RunAction{self.hideAction,{"hide"},{"@onHide"}}
    else
        self.visible = false;
        if self.onHide then self:onHide() end
    end
end

