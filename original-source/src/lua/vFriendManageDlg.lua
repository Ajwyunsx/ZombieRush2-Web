require "vFriendCell"
require "vSearchFriendDlg"


VFriendManageDlg = VClass("FriendManageDlg", VMsgBox)

function VFriendManageDlg:Init(attr)
    self.super.Init(self, attr)
    self.column = 2
    self.maxReq = 10
    self.maxFriend = gData.userInfo.friendInfos.friendLimit
    self:InitFriendData()
    self.deleteChoise = {}
    -- self:ReqFriendInfo()
end

function VFriendManageDlg:onPush()
    local hasFriend = gData.userInfo.friendInfos:friendCount() or 0
    self("txYuanbaolSocietyL").text = hasFriend.."/"..self.maxFriend

    self:ReqFriendInfo()
end

function VFriendManageDlg:onCell(idx, t, cell)
    cell:Recover(self.column, self.managerType)
    cell:SetInfo(idx, self.column, self.datas, self.managerType)
end

function VFriendManageDlg:onTableLeave(vTable, leaveType)
--    if vTable == self("tbSearchS") then
--        if leaveType == _VTableViewLeave.Up then
--            self:ReqFriendInfo()
--        elseif leaveType == _VTableViewLeave.Down then
--            self:ReqFriendInfo();
--        end
--    end
    if ( self.datas.hasDetailInfo >= self.maxFriend ) then
        self("tbFriendDlg"):cancelLoading();
    else
        self:ReqFriendInfo();
    end
end

function VFriendManageDlg:InitFriendData( ... )
	-- body
	self.datas = {["hasDetailInfo"] = 0}

	local friendList = gData.userInfo.friendInfos.friends
	self:AddFriendData(friendList)

end

function VFriendManageDlg:onClose(parameters)
    local societyDlg = gView()("societyDlg");
    if societyDlg then
        
        if societyDlg.isActivity == 0 then
            societyDlg:closeMessageView()
            self:doPop()
            return
        end
    end
    
	self:doPop()
end

function VFriendManageDlg:AddFriendData(list)
    local listSort = {}
    for key, var in pairs(list) do
        local friendInfo = self:CreateFriendData(var)
        friendInfo.newCount = self:GetMessageCountWithUserid(friendInfo.userid)
        table.insert(listSort, friendInfo)
    end
    --根据新聊天消息数量进行排序
    table.sort(listSort,
        function(a,b)
            return a.newCount < b.newCount;
        end);
        
    local count = table.getn(listSort)
        
    for var = 1, count do
        table.insert(self.datas, listSort[var])
    end
end

function VFriendManageDlg:CreateFriendData(data)
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

function VFriendManageDlg:UpDataMessage(parameters)
    local count = table.getn(self.datas)
    for var = 1, count do
        local manager = gData.chatInfo:managerWithId(self.datas[var].userid)
        
        if manager and manager.newCount > 0 then
            local tbFriendl = self("tbFriendDlg");
            if tbFriendl and tbFriendl.visible then
               
                local cell = tbFriendl:cellAtIndex(math.floor((var - 1) / 2))
                if cell then
                    index = var % 2
                    
                    if index == 0 then
                        index = 2
                    end

                    cell:UpDataMessage(manager, index)
                end
            end
            
        end
    end
end

--取新聊天消息数量
function VFriendManageDlg:GetMessageCountWithUserid(userid)
    local manager = gData.chatInfo:managerWithId(userid)
    local count = 0
            
    if manager and manager.newCount > 0 then
        count = manager.newCount
    end
    
    return count
end

function VFriendManageDlg:ReqFriendInfo()
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
    
    gData:userBriefInfo(self.reqUserids, self, "RspFriendsInfo")
end

function VFriendManageDlg:RspFriendsInfo()
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
--    	if friendList[userid] then
--    	   friendList[userid]:synWithReqData(info)
--    	end

        local count = table.getn(self.datas)
        for var = 1, count do
            local friendinfo = self.datas[var]
            if friendinfo.userid == userid and info then
                friendinfo.image = info.image
                friendinfo.level = info.level
                friendinfo.sex = info.sex
                friendinfo.nick = info.nick
                friendinfo.charge = info.charge
                friendinfo.last_login_time = info.last_login_time
            end
        end 
    end
    
    if isFrist then
        self:ReloadTable()
    else
        self("tbFriendDlg"):addCellNum(math.ceil(count / 2))
    end
end

function VFriendManageDlg:UpDataFriendManageDlg( ... )
    -- body
    self:InitFriendData()
    self:ReqFriendInfo()

    local hasFriend = gData.userInfo.friendInfos:friendCount() or 0
    self("txYuanbaolSocietyL").text = hasFriend.." / "..self.maxFriend
end

function VFriendManageDlg:ReloadTable( ... )
	-- body
    self("tbFriendDlg").visible = 1
    self("txTipFriendDlg").visible = 0
    
    local tbFriend = self("tbFriendDlg")
    tbFriend.number = math.ceil(self.datas.hasDetailInfo / 2);
    if tbFriend.number < 5 then
        tbFriend.downLabel:setVisible(false);
    else
        tbFriend.downLabel:setVisible(true);
    end
    tbFriend.delegate = self;
    tbFriend:reloadData();
end

function VFriendManageDlg:AddManage( ... )
    -- body
    local searchFriendDlg = VNode("vSearchFriendDlg.vui");
    gView():Push(searchFriendDlg);
end

function VFriendManageDlg:DeleteManage()
    -- body
    local hasFriend = gData.userInfo.friendInfos:friendCount()

    if hasFriend == 0 then
        return
    end
    
    

    self:ChageManageLayer("DELET")

    self:ReloadTable()
end

function VFriendManageDlg:ChageManageLayer( managerType )
    -- body
    self.managerType = managerType

    if managerType == "DELET" then
        self("btnDeletManage").visible = false
        self("btnAddManage").visible = false
        self("lyrDeletChose").visible = true
    else
        self("btnDeletManage").visible = true
        self("btnAddManage").visible = true
        self("lyrDeletChose").visible = false
    end
end


function VFriendManageDlg:CloseDeletManage( ... )
    -- body
    self:ChageManageLayer()

    self:ReloadTable()
end

function VFriendManageDlg:DeletChoise( info )
    -- body
    -- table.insert(self.deleteChoise, info)
    self.deleteChoise[info.userid] = info
end

function VFriendManageDlg:GetDeletChoise(parameters)
    return self.deleteChoise
end

function VFriendManageDlg:DeletUnChoise( info )
    -- body
    self.deleteChoise[info.userid] = nil
end
 
function VFriendManageDlg:DeletFriends( ... )
    -- body
    local hasAddDel = false
    for key, var in pairs(self.deleteChoise) do
    	hasAddDel = true
    	break
    end
    
    if hasAddDel then
        gView()("societyDlg"):ReqFriendDel(self.deleteChoise)
        self.deleteChoise = {}
        self:ChageManageLayer()
    else
        gWindow:showTip("请选择要删除的好友", 1)
    end
end

