require "vPvpFriendCell"

VPvpFriendLayer = VClass("PvpFriendLayer", VLayer)

function VPvpFriendLayer:InitLayer(parameters)
    self.column = 2
    self.maxReq = 10
    self.maxFriend = 100
    self.maxShowCount = 4
    self.tbFriendDlg = self("tbFriendDlg")
    self.txTipFriendDlg = self("txTipFriendDlg")
    self:InitFriendData()
    self.visible = 1
end

function VPvpFriendLayer:ReqBattlingInfo( ... )
    -- body
    gReq:MsgReqBattlePlayerQuery(self, "ReqBattlingInfoBack")
end

function VPvpFriendLayer:ReqBattlingInfoBack( result, rsp, req )
    -- body
    if rsp then
        self.in_battle_targets = rsp.in_battle_targets
    end

    cclog("1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~CCCCCCCCCCCC")

    self.datas = {["hasDetailInfo"] = 0}

    if self.in_battle_targets then
        local count = self.in_battle_targets:Count()
        self.in_battle_targetsmap = {}
        if count and count >= 0 then
            for i = 0, count - 1 do
                local friendInfo = self:CreateFriendData({})
                friendInfo.userid = self.in_battle_targets[i]
                self.in_battle_targetsmap[friendInfo.userid] = friendInfo
                table.insert(self.datas, friendInfo)
            end
        end
    end

    local friendList = gData.userInfo.friendInfos.friends
    self:AddFriendData(friendList)

    self.in_battle_targets = nil
    self.in_battle_targetsmap = nil


    self:ReqFriendInfo()
    
end

function VPvpFriendLayer:HideLayer(parameters)
    self.visible = 0
end

function VPvpFriendLayer:onPush(parameters)

end

function VPvpFriendLayer:InitFriendData( ... )
    -- body
    self:ReqBattlingInfo()

end

function VPvpFriendLayer:AddFriendData(list)
    local listSort = {}
    for key, var in pairs(list) do
        local friendInfo = self:CreateFriendData(var)
--        friendInfo.newCount = self:GetMessageCountWithUserid(friendInfo.userid)
        if not self.in_battle_targetsmap or not self.in_battle_targetsmap[friendInfo.userid] then
            table.insert(self.datas, friendInfo)
        end
    end

--    table.sort(listSort,
--        function(a,b)
--            return a.newCount < b.newCount;
--        end);
--
--    local count = table.getn(listSort)
--
--    for var = 1, count do
--        table.insert(self.datas, listSort[var])
--    end
end

function VPvpFriendLayer:CreateFriendData(data)
    local SocietyData = {}
    SocietyData.userid = data.userid or data.fromId
    SocietyData.image = data.image
    SocietyData.level = data.level
    SocietyData.sex = data.sex
    SocietyData.nick = data.nick
    SocietyData.text = ""
    SocietyData.time = ""
    SocietyData.hasAdd = gData:isMyFriend(data.userid)

    return SocietyData
end

function VPvpFriendLayer:ReqFriendInfo()

    local startIndex = self.datas.hasDetailInfo + 1
    local count = table.getn(self.datas)
    cclog("count:"..count)
    

    self.reqUserids = {}

    local limit = math.min(count - self.datas.hasDetailInfo, self.maxReq) + startIndex - 1


    for var = startIndex, limit do
        cclog("reqUserids:"..self.datas[var].userid)
        table.insert(self.reqUserids, self.datas[var].userid)
    end
    
    if #self.reqUserids == 0 then
        if count == 0 then
            self:ReloadTable()
        end

        return
    end
    
    gData:userBriefBattleInfo(self, "RspFriendsInfo", self.reqUserids)

    gWindow:showWaitTip()
--    gReq:MsgReqBriefUserBattleInfoQuery()

--    gData:userBriefInfo(self.reqUserids, self, "RspFriendsInfo")
end

function VPvpFriendLayer:RspFriendsInfo(userBattleInfos)

    local friendList = gData.userInfo.friendInfos.friends
    local count = table.getn(self.reqUserids)
    local isFrist = true

    if self.datas.hasDetailInfo ~= 0 then
        isFrist = false
    end

    self.datas.hasDetailInfo = self.datas.hasDetailInfo + count

    for var = 1, count do
        
--        local infos = rsp.infos[var - 0]
        
        local userid = self.reqUserids[var]
        
        local info = userBattleInfos[userid]
--        local info = rsp.infos[var - 0]
        --      if friendList[userid] then
        --         friendList[userid]:synWithReqData(info)
        --      end

        local count = table.getn(self.datas)
        for var = 1, count do
            local friendinfo = self.datas[var]
            if friendinfo.userid == userid and info then
                friendinfo.image = info.image
                friendinfo.level = info.level
                friendinfo.sex = info.sex
                friendinfo.nick = info.nick
                friendinfo.charge = info.charge
                friendinfo.battle_infos = info.battle_infos
            end
        end 
    end

    if isFrist then
        self:ReloadTable()
    else
        self("tbFriendDlg"):addCellNum(math.ceil(count / self.column))
    end

    gWindow:closeWaitTip()

end

function VPvpFriendLayer:onTableLeave(vTable, leaveType)
    if ( self.datas.hasDetailInfo >= self.maxFriend ) then
        self("tbFriendDlg"):cancelLoading();
    else
        self:ReqFriendInfo();
    end
end

function VPvpFriendLayer:ReloadTable( ... )
    -- body
    local count = self.datas.hasDetailInfo
    
    if count and count ~= 0 then
        
        self.tbFriendDlg.visible = 1
        self("bfTip").visible = 0;
    else
        
        self.tbFriendDlg.visible = 0
        self("bfTip").visible = 1;
    end
    
    local tbFriend = self("tbFriendDlg")
    tbFriend.number = math.ceil(count / self.column);
    
    if tbFriend.number < 5 then
        tbFriend.downLabel:setVisible(false);
    else
        tbFriend.downLabel:setVisible(true);
    end
    
    tbFriend.delegate = self;
    tbFriend:reloadData();
end

function VPvpFriendLayer:onCell(idx, t, cell)

    cell:Recover(self.column, self.managerType)
    cell:SetInfo(idx, self.column, self.datas)
end

function VPvpFriendLayer:ReqFriendDel(infos)
    local userids = {}
    local pos = {}

    for k, v in pairs(infos) do
        table.insert(userids, v.userid)
        table.insert(pos, v.pos)
    end

    local aParam = {}
    -- aParam.userid = info.userid
    -- aParam.nick = info.nick
    -- aParam.pos = info.pos
    aParam.userids = userids
    aParam.pos = pos
    gReq:MsgReqFriendDel(self, "ReqFriendDelCallBack", aParam)
end

function VPvpFriendLayer:ReqFriendDelCallBack(result, rsp, req)
    if result == 0 then
        self:ReqFriendDelSuccess(rsp, req)
    else
        self:ReqFriendDelFail()
    end
end


function VPvpFriendLayer:ReqFriendDelSuccess(rsp, req)
    for k, v in ipairs(req.userids) do
        gData.userInfo.friendInfos:DelFriend(v)
    end

    self:InitFriendData()
    -- self:ReqFriendInfo()

--    gWindow:showNormalTip("删除好友成功", "")
end


function VPvpFriendLayer:ReqFriendDelFail()
    
end

function VPvpFriendLayer:ReqBattleInfo(userids, idx)
    gData:userBriefBattleInfo(self, "RspBattleInfo", userids, idx)
end

function VPvpFriendLayer:RspBattleInfo(userBattleInfos, idx)
    cclog("~~~~~~~~~~~idx~~~~~~~~~~~"..idx)
    for key, var in pairs(userBattleInfos) do
        local info = var
        local count = table.getn(self.datas)
        for var = 1, count do
            local friendinfo = self.datas[var]
            if friendinfo.userid == info.id then
                friendinfo.image = info.image
                friendinfo.level = info.level
                friendinfo.sex = info.sex
                friendinfo.nick = info.nick
                friendinfo.battle_infos = info.battle_infos
            end
        end 
	end 
	
    local startPosidx = math.min(idx - self.maxShowCount, 0)

    cclog("startPosidx"..startPosidx)
    for var = startPosidx, idx + self.maxShowCount do
        local cell = self.tbFriendDlg:cellAtIndex(var)
        if cell then
            self:onCell(var, self.tbFriendDlg, cell)
        end
        
    end
end