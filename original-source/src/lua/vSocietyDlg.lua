require "vSocietyCell"
require "vWorldChatDlg"

VSocietyDlg= VClass("SocietyDlg", VMsgBox)

function VSocietyDlg:Init(attr)
    self.super.Init(self, attr)
    self.column = 2
    self.maxReq = 10
    self.maxFriend = 100
end

function VSocietyDlg:onPush()
	self:InitCustomData()
    self:ReloadTable()
    self:InitSocietyData()
    self:ReqSocietyInfo()
    gMainView("imgChatView").visible = 0
end

function VSocietyDlg:onCell(idx, t, cell)
    cell:Recover(self.column)
    cell:SetInfo(idx, self.column, self.datas)
end

function VSocietyDlg:InitCustomData( ... )
    -- body
    self.datas = {["hasDetailInfo"] = 0}

    local worldChat = {}
    worldChat.nick = "世界聊天频道"
    worldChat.userid = 1
    -- worldChat.image = data.image
    worldChat.text = ""
    worldChat.time = ""
    worldChat.flag = "WORLD"
    worldChat.newCount = self:GetMessageCountWithUserid(worldChat.userid)

    table.insert(self.datas, worldChat)

    local custom = {}
    custom.name = "官方客服"
    custom.userid = gGameMasterId
    -- custom.image = data.image
    custom.text = ""
    custom.time = ""
    custom.flag = "CUSTOM"
    custom.newCount = self:GetMessageCountWithUserid(custom.userid)

    table.insert(self.datas, custom)

    local friend = {}
    friend.nick = "好友列表"
    friend.userid = 2
    -- friend.image = data.image
    friend.text = ""
    friend.time = ""
    friend.flag = "LIST"
    friend.newCount = self:GetMessageCountWithUserid(friend.userid)

    table.insert(self.datas, friend)
end

function VSocietyDlg:InitSocietyData( ... )
	-- body
	

	-- local friendList = gData.userInfo.friendInfos.friends
	-- self:AddSocietyData(friendList)
    self:InitCustomData()
    
    local strangerList = gData.chatInfo:GetLastMessageList()
    if strangerList then 
        self:AddSocietyData(strangerList)
    end

end

function VSocietyDlg:AddSocietyData(list)
    local listSort = {}
    for key, var in pairs(list) do
        local friendInfo = self:CreateSocietyData(var)
        local newCount = self:GetMessageCountWithUserid(friendInfo.userid)
--        if newCount and newCount > 0 then
        if friendInfo.userid ~= gGameMasterId then
            friendInfo.newCount = newCount
            cclog(""..(var.lastTime or 0))
            friendInfo.lastTime = tonumber(var.lastTime) or 0
--            listSort[friendInfo.userid] = friendInfo
            table.insert(listSort, friendInfo)
--        end
        end
    end

    table.sort(listSort,                      ---------此处数据排序需求为消息时间,最近的排在最前面
        function(a,b)
            return tonumber(a.lastTime) > tonumber(b.lastTime);
        end);
        
    local count = table.getn(listSort)
    
    for key, var in pairs(listSort) do
        table.insert(self.datas, var)
    end
end

function VSocietyDlg:CreateSocietyData(data)
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

function VSocietyDlg:UpDataMessage(parameters)
    local count = table.getn(self.datas)
    for var = 1, count do
        local manager = gData.chatInfo:managerWithId(self.datas[var].userid)
        
        if manager and manager.newCount > 0 or self.datas[var].userid == 2 then
            local tbSociety = self("tbSociety");
            if tbSociety and tbSociety.visible then
               
                local cell = tbSociety:cellAtIndex(math.floor((var - 1) / 2))
                if cell then
                    local index = var % 2
                    
                    if index == 0 then
                        index = 2
                    end

                    cell:UpDataMessage(manager, index)
                end
            end
            
        end
    end
end

function VSocietyDlg:UpDataSocietyList( ... )
    -- body
    self:InitSocietyData()
    self:ReqSocietyInfo()
end

function VSocietyDlg:closeMessageView()
    gMainView("imgChatView").visible = 1
    self:doPop();
end

function VSocietyDlg:CheckUnReadMessage( userid )
    local count = table.getn(self.datas)

    for var = 1, count do
        if self.datas[var].userid == userid then
            local manager = gData.chatInfo:managerWithId(self.datas[var].userid)
        
            if manager and manager.newCount <= 0 then
                local tbSociety = self("tbSociety");
                if tbSociety and tbSociety.visible then
                   
                    local cell = tbSociety:cellAtIndex(math.floor((var - 1) / 2))
                    if cell then
                        local index = var % 2
                        
                        if index == 0 then
                            index = 2
                        end

                        cell:CheckUnReadMessage(index)
                    end
                end
                
            end
        end
    end
end

function VSocietyDlg:GetMessageCountWithUserid(userid)
    local manager = gData.chatInfo:managerWithId(userid)
    local count = 0
            
    if manager and manager.newCount > 0 then
        count = manager.newCount
    end
    
    return count
end

function VSocietyDlg:ReqSocietyInfo()
    local startIndex = self.datas.hasDetailInfo + 1
    local count = table.getn(self.datas)
	cclog("count:"..count)
    if count == 0 or count < startIndex then
        self:ReloadTable()
        return
    end
    
    self.reqUserids = {}
    
    local limit = math.min(count, self.maxReq) + startIndex - 1
    
    
    for var = startIndex, limit do
    	cclog("reqUserids:"..self.datas[var].userid)
    	table.insert(self.reqUserids, self.datas[var].userid)
    end
    gWindow:showWaitTip()
    gData:userBriefInfo(self.reqUserids, self, "RspFriendsInfo")
    
end

function VSocietyDlg:RspFriendsInfo()
    self:UpDataSocietyDlg()

    local friendManageDlg = gView()("friendManageDlg")
    if friendManageDlg then
        friendManageDlg:UpDataFriendManageDlg()
    end
    gWindow:closeWaitTip()
end

function VSocietyDlg:ReloadTable( ... )
	-- body
	local tbSociety = self("tbSociety")
	tbSociety.number = math.ceil(table.getn(self.datas) / 2);
    tbSociety.delegate = self;
    tbSociety:reloadData();
end

function VSocietyDlg:UpDataSocietyDlg( ... )
    -- body
    local friendList = gData.userInfo.friendInfos.friends
    local count = table.getn(self.reqUserids)
    local isFrist = true
    
    if self.datas.hasDetailInfo ~= 0 then
        isFrist = false
    end
    
    self.datas.hasDetailInfo = self.datas.hasDetailInfo + count
    
    for var = 1, count do
        local userid = self.reqUserids[var]
        local info = gData:briefCache(userid)
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
            end
        end 
    end

    if isFrist then
        self:ReloadTable()
    else
        self("tbSociety"):addCellNum(count)
    end

    self.reqUserids = {}
end


function VSocietyDlg:DelAllSocietyMsg(parameters)
    gWindow:showConfirmTip("确定要删除所有的聊天消息么?", "确定", "取消", self, "DelAllSocietyMsgBack", "", "",
        nil);
end

function VSocietyDlg:DelAllSocietyMsgBack(parameters)
    gData.chatInfo:DelAllMessage()

    self:InitSocietyData()
    self:ReqSocietyInfo()

    gMainView:checkUnReadMessage()
end


function VSocietyDlg:ReqFriendAdd(info)
    local aParam = {}
    aParam.userid = info.userid
    aParam.nick = info.nick
    aParam.pos = info.pos
    gReq:MsgReqFriendAdd(self, "ReqFriendAddCallBack", aParam)
end

function VSocietyDlg:ReqFriendAddCallBack(result, rsp, req)
    if result == 0 then
        self:ReqFriendAddSuccess(rsp, req)
    else
        self:ReqFriendAddFail()
    end
end

function VSocietyDlg:ReqFriendAddSuccess(rsp, req)
    gData.userInfo.friendInfos:AddFriend(req.userid)

    self:InitSocietyData()
    self:ReqSocietyInfo()
    
--    gWindow:showNormalTip(req.nick.."已成为你的好友", "添加成功")
    
    local tb = gView()("tbSearchS")
    if tb then
        local cell = tb:cellAtIndex(req.pos)
        
        if cell ~= nil then
            cell:UpDataCell(self.column, req.userid)
        end
    end
end

function VSocietyDlg:ReqFriendAddFail()

end

function VSocietyDlg:ReqFriendDel(infos)
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

function VSocietyDlg:ReqFriendDelCallBack(result, rsp, req)
    if result == 0 then
        self:ReqFriendDelSuccess(rsp, req)
    else
        self:ReqFriendDelFail()
    end
end


function VSocietyDlg:ReqFriendDelSuccess(rsp, req)
    for k, v in ipairs(req.userids) do
        gData.userInfo.friendInfos:DelFriend(v)
    end
    
    self:InitSocietyData()
    self:ReqSocietyInfo()
    
--    gWindow:showNormalTip("删除好友成功", "")
    
    local tb = gView()("tbSearchS")
    if tb then
        for key, var in pairs(req.userids) do
            local cell = tb:cellAtIndex(req.pos[key])

            if cell ~= nil then
                cell:UpDataCell(self.column, var)
            end
        end   
    end
    
end


function VSocietyDlg:ReqFriendDelFail()

end

