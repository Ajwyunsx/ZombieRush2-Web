
VPlayerOperateDlg = VClass("PlayerOperateDlg", VMsgBox)

function VPlayerOperateDlg:onPush()
	self("artUp"):play("idle")
    self("txIDPlayerO").text = self.info.userid
	
    local enemyList = gData.userInfo.enemyInfos.enemys
    local friendList = gData.userInfo.friendInfos.friends
    
    if enemyList[self.info.userid] then
--        self("imgAddOrDelPlayerO").image = "shanchu.png"
            self("txAddOrDelPlayerO").text = "删除仇敌"
    elseif friendList[self.info.userid] then
--        self("imgAddOrDelPlayerO").image = "shanchu.png"
        self("txAddOrDelPlayerO").text = "删除好友"
    else
        if not self.type then
--        self("imgAddOrDelPlayerO").image = "jiaweihaoyou.png"
            self("txAddOrDelPlayerO").text = "设为仇敌"
            self("txLookFarmPlayerO").text = "设为好友"
            self("btnLookFarmPlayerO").onClick = "node:Parent(2):onAddOrDelClick()"
            self("btnAddOrDelPlayerO").onClick = "node:Parent(2):onAddOrDelClick('addEnemy')"
--        self("imgLookFarmPlayerO").image = "jiaweihaoyou.png"
        self("btnfwPlayerO").visible = 1
        elseif self.type == 1 then
--            self("imgAddOrDelPlayerO").image = "jiaweihaoyou.png"
            self("txAddOrDelPlayerO").text = "设为好友"
        elseif self.type == 2 then
--            self("imgAddOrDelPlayerO").image = "jiaweihaoyou.png"
        else
        end
    end
	
    local headImage = self("imgPlantDexPlayerO")
    -- self("imgPlantDexPlayerO").image = gData:headImage(self.info.userid, self.info.image)
    headImage:setHead(self.info.userid, self.info.image, nil, gData:GetVipLevel(self.info.charge or 0))
    
    headImage:SetHeadImageShader()
    self("txNamePlayerO").text = "昵称 : "..self.info.nick
    self("txSexPlayerO").text = "性别 : "..self:GetSexText(self.info.sex)
    self("txIDPlayerO").text = "ID     : "..self.info.userid
    self("txLevelPlayerO").text = "Lv"..self.info.level
end

function VPlayerOperateDlg:GetSexText(parameters)
	if self.info.sex ~= 2 then
	    return "女"
	else
	    return "男"
	end
end


---type参数说明,只在界面针对只能添加对方为好友(传1)或只能添加对方为仇敌(传2)时传,其余传nil
function VPlayerOperateDlg:SetUserInfo(info, type, delegate, callBack, ...)
    self.info = info
    self.delegate = delegate
    self.callBack = callBack
    self.type = type
    self.parm = {...}
end

function VPlayerOperateDlg:onChatClick()
    if gView()("imgDOpen") then
        gView()("imgDOpen").visible = 0
    end
    gMainView:openChatDlg(self.info.userid);
    self:onClick()
end

function VPlayerOperateDlg:onLookFarmClick()
--    gWindow:showTip("尽请期待...", 1)
    if self.flag then
        self:onAddOrDelClick(1)
    elseif gMainView then
        gMainView:jumpToOther(self.info.userid);
    end
    -- self:onClick()
end

function VPlayerOperateDlg:onAddOrDelClick(flag)
    local enemyList = gData.userInfo.enemyInfos.enemys
    local friendList = gData.userInfo.friendInfos.friends
    
    cclog("~~~~~~flag"..(flag or "nnnnnnnnnnnnnnn"))

    if enemyList[self.info.userid] then
        self.reqAction = 1

        local aParam = {}
        aParam.userid = self.info.userid
        -- aParam.extra = {}
        aParam.parm = self.parm

        gReq:MsgReqEnemyDel(self, "OpCallBack", aParam)
    elseif friendList[self.info.userid] then
        self.reqAction = 2

        local infos = {}
        table.insert(infos, self.info.userid)

        local pos = {}
        if self.info.pos then
            table.insert(pos, self.info.pos)
        end

        local aParam = {}
        aParam.userids = infos
        aParam.pos = pos

        aParam.parm = self.parm
        gReq:MsgReqFriendDel(self, "OpCallBack", aParam)
    elseif flag == "addEnemy" then
        self.reqAction = 3

        local aParam = {}
        aParam.userid = self.info.userid
        aParam.parm = self.parm
--        self.delegate:ReqEnemyAdd(self.info)
        
        if gData.userInfo.enemyInfos:EnemyCount() < gData.userInfo.enemyInfos.enemyLimit then
            gReq:MsgReqEnemyAdd(self, "OpCallBack", aParam)
        else
            gWindow:showTip("仇敌已达到上限,无法添加")
            return
        end
    else
        self.reqAction = 4

        local aParam = {}
        aParam.userid = self.info.userid
        aParam.nick = self.info.nick
        aParam.pos = self.info.pos
        aParam.parm = self.parm
--        self.delegate:ReqFriendAdd(self.info)
        if gData.userInfo.friendInfos:friendCount() < gData.userInfo.friendInfos.friendLimit then
            gReq:MsgReqFriendAdd(self, "OpCallBack", aParam)
        else
            gWindow:showTip("好友已达到上限,无法添加")
            return
        end
    end
    
    gWindow:showWaitTip()
    

end

function VPlayerOperateDlg:OpCallBack(result, rsp, req)
    gWindow:closeWaitTip()
    if result == 0 then
        -- local extra = req.extra
        if self.reqAction == 1 then
            gWindow:showNormalTip("删除仇人成功", "")
        elseif self.reqAction == 2 then
            gWindow:showNormalTip("删除好友成功", "")
        elseif self.reqAction == 3 then
            gWindow:showNormalTip("添加仇人成功", "")
        elseif self.reqAction == 4 then
            gWindow:showNormalTip("添加好友成功", "")
        end

        VCallBack(self.delegate, self.callBack, result, rsp, req)
        self:onChannelClick()
    end

--    gWindow:closeWaitTip()
    -- self:onChannelClick()
end

function VPlayerOperateDlg:onChannelClick()
    self:onClick()
end
