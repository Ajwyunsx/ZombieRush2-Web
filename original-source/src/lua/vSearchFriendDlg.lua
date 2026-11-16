require "vSearchCell"

VSearchFriendDlg = VClass("SearchFriendDlg", VMsgBox)

function VSearchFriendDlg:Init(attr)
    self.super.Init(self, attr)
    self.maxReq = 10
    self.maxFriend = 100
    self.sexChoise = 3
    self.column = 2
    self.searchList = {["type"] = "SEARCH"}
    self.searchListMap = {["count"] = 0}
end

function VSearchFriendDlg:onPush()
	self:ChoseSexBox(3)
end

function VSearchFriendDlg:ReloadTable( ... )
	-- body
    local tbFriend = self("tbSearchS")

	tbFriend.number = math.max(math.floor(table.getn(self.searchList) / 2), 1);
    if self.searchid then
        
        tbFriend.downLabel:setVisible(false);
    else
        
        tbFriend.downLabel:setVisible(true);
    end
    tbFriend.delegate = self;
    tbFriend:reloadData();
end

function VSearchFriendDlg:onCell(idx, t, cell)
    cell:Recover(self.column, self.managerType)
    cell:SetInfo(idx, self.column, self.searchList)
end

function VSearchFriendDlg:onTableLeave(vTable, leaveType)
    if vTable == self("tbSearchS") then
        if leaveType == _VTableViewLeave.Up then
            self:ReqSearchListInfo()
        elseif leaveType == _VTableViewLeave.Down then
            self:ReqSearchListInfo();
        end
    end
end

function VSearchFriendDlg:ChoseSexBox(sex)
    self("imgWanChatBg").visible = 0
    self("imgManChatBg").visible = 0
    self("imgNoneChatBg").visible = 0
    
	if sex == 1 then
        self("imgWanChatBg").visible = 1
	elseif sex == 2 then
        self("imgManChatBg").visible = 1
	else
        self("imgNoneChatBg").visible = 1
	end
end

function VSearchFriendDlg:UpdataSearchList(infos)
--    self.searchList = self.searchList or {}

    local count = infos:Count()

    local hasCount = table.getn(self.searchList)

    for i = 0, count - 1  do
        local data = VItemData:new()
        data:CreateWithFriendData(infos[i])

        if not self.searchListMap[data.userid] then
            self.searchListMap[data.userid] = data
            self.searchListMap.count = self.searchListMap.count + 1


            -- if not gData.userInfo.enemyInfos:isEnemy(data.userid) and 
                -- data.userid ~= gData.userInfo.userid then
                data.hasAdd = gData:isMyFriend(data.userid)
    --            data.pos = math.floor((hasCount + i) / 2)
                
                table.insert(self.searchList, data)
            -- end
        end
    end
end

function VSearchFriendDlg:onSexClick( sexChoise )
    -- body
    self:ChoseSexBox(sexChoise)
    self.sexChoise = sexChoise
end

function VSearchFriendDlg:ChangeLayer(layerType)
    if self.currentLayer == layerType then
        return
    end
    
    self.currentLayer = layerType
    
    if layerType == "SHOWFRRIEND" then
        self:ShowFriendListLayer(false)
        self:HideFindFriendLayer()
        self:HideSearchListLayer()
    elseif layerType == "FINDFRRIEND" then
        self:ShowFindFriendLayer()
        self:HideFriendListLayer()
        self:HideSearchListLayer()
    elseif layerType == "SHOWSEARCH" then
        self:ShowSearchListLayer(false)
        self:HideFindFriendLayer()
        self:HideFriendListLayer()
    end
--    self.searchList.infos = nil
--    self:ReloadTable(self("tbFriendl"))
end

function VSearchFriendDlg:ShowFriendListLayer(hasInfo)
    -- self("lyrShowFriend").visible = 1
    self("tbFriendl").visible = hasInfo
    self("txTipFChatBg").visible = not hasInfo
    if not hasInfo then
        self:InitFriendList()
        self:ReqFriendsInfo()
    end
end

function VSearchFriendDlg:HideFriendListLayer()
    -- self("lyrShowFriend").visible = 0
end

function VSearchFriendDlg:ShowFindFriendLayer()
    self.searchList = {["type"] = "SEARCH"}
    self.searchListMap = {["count"] = 0}
    self("edtIDChatBg").text = ""
    self("edtNameChatBg").text = ""
    self.sexChoise = 3
    self:ChoseSexBox(3)
    self("lyrFindFriend").visible = 1
    self("edtIDChatBg").visible = 1
    self("edtNameChatBg").visible = 1
    self("imgSearchTitleT").image = "chazhaowanjia.png"
end

function VSearchFriendDlg:HideFindFriendLayer(layerType)
    self("lyrFindFriend").visible = 0
    self("edtIDChatBg").visible = 0
    self("edtNameChatBg").visible = 0
    self("imgSearchTitleT").image = "chazhaojieguo.png"
end


function VSearchFriendDlg:ShowSearchListLayer(hasInfo)
    self("lyrShowSearch").visible = 1
    self("tbSearchS").visible = hasInfo
    self("txTipSChatBg").visible = not hasInfo
end

function VSearchFriendDlg:HideSearchListLayer(layerType)
    self("lyrShowSearch").visible = 0
end

function VSearchFriendDlg:ReqSearchListInfo()
    local aParam = {}
    aParam.start = self.searchListMap.count--table.getn(self.searchList)
    aParam.count = self.maxReq
    aParam.condition_nums = {}
    aParam.condition_strs = {}

    local numIndex = 1
    local strIndex = 1

    if self("edtIDChatBg"):getText() ~= "" then
        local condition_nums = {_pb = "ConditionNum"};
        condition_nums.value = tonumber(self("edtIDChatBg"):getText())
        if condition_nums.value == gData.userInfo.userid then
            gWindow:showTip("不能查询自己并添加为好友", 1)
            return
        end

        self.searchid = true

        condition_nums.field = 8;
        aParam.condition_nums[numIndex] = condition_nums
        numIndex = numIndex + 1
    end

    if self.sexChoise ~= 3 then
        local condition_nums = {_pb = "ConditionNum"};
        condition_nums.value = self.sexChoise
        condition_nums.field = 3;
        aParam.condition_nums[numIndex] = condition_nums
        numIndex = numIndex + 1
    end

    if  self("edtNameChatBg"):getText() ~= "" then
        local condition_strs = {_pb = "ConditionStr"};
        condition_strs.value = self("edtNameChatBg"):getText()
        condition_strs.field = 2;
        aParam.condition_strs[strIndex] = condition_strs
        strIndex = strIndex + 1
    end

    self:ReqUserSearch(aParam)
end

function VSearchFriendDlg:ReqUserSearch(aParam)
    gWindow:showWaitTip()
    gReq:MsgReqUserSearch(self, "ReqUserSearchCallBack", aParam)
end


function VSearchFriendDlg:ReqUserSearchCallBack(result, rsp, req)
    if result == 0 then
        self:ReqUserSearchSuccess(rsp, req)
    else
        self:ReqUserSearchFail()
    end

    gWindow:closeWaitTip()
end


function VSearchFriendDlg:ReqUserSearchSuccess(rsp, req)
    if rsp ~= nil and rsp.infos ~= nil then
        self:UpdataSearchList(rsp.infos)
    else
        gWindow:showTip("没有符合条件的好友", 1)
        return
    end
    
    self:ChangeLayer("SHOWSEARCH")

    if req.start == 0 then
        self:ReloadTable("SHOWSEARCH")
    else
        local count = rsp.infos:Count()
        self("tbSearchS"):addCellNum(math.ceil(count / 2));
    end

    self("tbSearchS").visible = true
    self("txTipSChatBg").visible = false
end


function VSearchFriendDlg:ReqUserSearchFail()

end