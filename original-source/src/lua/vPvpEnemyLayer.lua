require "vPvpEnemyCell"

VPvpEnemyLayer = VClass("PvpEnemyLayer", VLayer)

function VPvpEnemyLayer:Init(attr)
    VPvpEnemyLayer.super.Init(self, attr)
    self:NeedEvent(Eff_onEnter+Eff_onExit);
end

function VPvpEnemyLayer:InitLayer(parameters)
    self.column = 2
    self.maxReq = 10
    self.maxEnemy = 100
    self.maxShowCount = 4
    self:ShowDefault()
    self:InitEnemyData()
    self:ReqEnemyInfo()
    self.visible = 1
end

function VPvpEnemyLayer:HideLayer(parameters)
    self.visible = 0
end

function VPvpEnemyLayer:onPush(parameters)

end

function VPvpEnemyLayer:ShowDefault(parameters)
    self.datas = {["hasDetailInfo"] = 0}

    local SocietyData = {}
    SocietyData.userid = -1

    table.insert(self.datas, SocietyData)
    
    self:ReloadTable()
end

function VPvpEnemyLayer:InitEnemyData( ... )
    -- body
    self.datas = {["hasDetailInfo"] = 0}

    local enemyList = gData.userInfo.enemyInfos.enemys
    
    self:AddEnemyData(enemyList)
    
    local SocietyData = {}
    SocietyData.userid = -1
    
    table.insert(self.datas, SocietyData)
end

function VPvpEnemyLayer:AddEnemyData(list)
    local listSort = {}
    for key, var in pairs(list) do
        local EnemyInfo = self:CreateEnemyData(var)
        --        EnemyInfo.newCount = self:GetMessageCountWithUserid(EnemyInfo.userid)
        table.insert(self.datas, EnemyInfo)
    end
end

function VPvpEnemyLayer:CreateEnemyData(data)
    local SocietyData = {}
    SocietyData.userid = data.userid or data.fromId
    SocietyData.image = data.image
    SocietyData.level = data.level
    SocietyData.sex = data.sex
    SocietyData.nick = data.nick
    SocietyData.text = ""
    SocietyData.time = ""

    return SocietyData
end

function VPvpEnemyLayer:ReqEnemyInfo()
    local startIndex = self.datas.hasDetailInfo + 1
    local count = table.getn(self.datas)
    cclog("count:"..count)
    if count == 0 or count < startIndex then
--        self:ReloadTable()
        return
    end

    self.reqUserids = {}

    local limit = math.min(count - self.datas.hasDetailInfo, self.maxReq) + startIndex - 1


    for var = startIndex, limit do
        cclog("reqUserids:"..self.datas[var].userid)
        if self.datas[var].userid ~= -1 then
            table.insert(self.reqUserids, self.datas[var].userid)
        end
    end
    
    if #self.reqUserids <= 0 then
        self:ReloadTable()
    else
        gData:userBriefBattleInfo(self, "RspEnemysInfo", self.reqUserids)
    end
end


function VPvpEnemyLayer:onTableLeave(vTable, leaveType)
    if ( self.datas.hasDetailInfo >= self.maxEnemy ) then
        self("tbFriendDlg"):cancelLoading();
    else
        self:ReqEnemyInfo();
    end
end

function VPvpEnemyLayer:RspEnemysInfo(userBattleInfos)

    local enemyList = gData.userInfo.enemyInfos.Enemys
    local count = table.getn(self.reqUserids)
    local isFrist = true

    if self.datas.hasDetailInfo ~= 0 then
        isFrist = false
    end

    self.datas.hasDetailInfo = self.datas.hasDetailInfo + count

    for var = 1, count do
        local userid = self.reqUserids[var]
        local info = userBattleInfos[userid]
        --      if enemyList[userid] then
        --         enemyList[userid]:synWithReqData(info)
        --      end

        local count = table.getn(self.datas)
        for var = 1, count do
            local enemyinfo = self.datas[var]
            if enemyinfo.userid == userid and info then
                enemyinfo.image = info.image
                enemyinfo.level = info.level
                enemyinfo.sex = info.sex
                enemyinfo.nick = info.nick
                enemyinfo.charge = info.charge
                enemyinfo.money = info.money
                enemyinfo.sunshine = info.sunshine
                enemyinfo.battle_infos = info.battle_infos
            end
        end 
    end

    if isFrist then
        self:ReloadTable()
    else
        self("tbEnemyDlg"):addCellNum(math.ceil(count / self.column))
    end

end

function VPvpEnemyLayer:ReloadTable( ... )
    -- body
    self("tbEnemyDlg").visible = 1
    self("txTipEnemyDlg").visible = 0

    local tbEnemy = self("tbEnemyDlg")
    tbEnemy.number = math.ceil((self.datas.hasDetailInfo + 1) / self.column);
    tbEnemy.delegate = self;
    tbEnemy:reloadData();
end

function VPvpEnemyLayer:onCell(idx, t, cell)

    cell:Recover(self.column, self.managerType)
    cell:SetInfo(idx, self.column, self.datas)
end

function VPvpEnemyLayer:ReqEnemyAdd(aParam)
    gReq:MsgReqEnemyAdd(self, "ReqEnemyAddBack", aParam)
end

function VPvpEnemyLayer:ReqEnemyAddBack(result, rsp, req)
    if result == 0 then
        self:ReqEnemyAddSuccess(rsp, req)
    else
        self:ReqEnemyAddFail()
    end
end


function VPvpEnemyLayer:ReqEnemyAddSuccess(rsp, req)
    cclog("添加仇人成功")
    gData.userInfo.enemyInfos:AddEnemy(req.userid)

    self:InitEnemyData()
    self:ReqEnemyInfo()

    gWindow:showNormalTip("添加仇人成功", "")
end


function VPvpEnemyLayer:ReqEnemyAddFail()

end

function VPvpEnemyLayer:ReqEnemyDel(aParam)
    gReq:MsgReqEnemyDel(self, "ReqEnemyDelBack", aParam)
    --    self:InitEnemyInfos()
end

function VPvpEnemyLayer:ReqEnemyDelBack(result, rsp, req)
    if result == 0 then
        self:ReqEnemyDelSuccess(rsp, req)
    else
        self:ReqEnemyDelFail()
    end
end


function VPvpEnemyLayer:ReqEnemyDelSuccess(rsp, req)
    gData.userInfo.enemyInfos:DelEnemy(req.userid)
    
    self:InitEnemyData()
    self:ReqEnemyInfo()

--    gWindow:showNormalTip("删除仇人成功", "")
end


function VPvpEnemyLayer:ReqEnemyDelFail()

end

function VPvpEnemyLayer:ReqBattleInfo(userids, idx)
    gData:userBriefBattleInfo(self, "RspBattleInfo", userids, idx)
end

function VPvpEnemyLayer:RspBattleInfo(userBattleInfos, idx)
    cclog("~~~~~~~~~~~idx~~~~~~~~~~~"..idx)
    for key, var in pairs(userBattleInfos) do
        local info = var
        local count = table.getn(self.datas)
        for var = 1, count do
            local enemyinfo = self.datas[var]
            if enemyinfo.userid == info.id then
                enemyinfo.image = info.image
                enemyinfo.level = info.level
                enemyinfo.sex = info.sex
                enemyinfo.nick = info.nick
                enemyinfo.battle_infos = info.battle_infos
            end
        end 
    end 
    
    local startPosidx = math.min(idx - self.maxShowCount, 0)

    cclog("startPosidx"..startPosidx)
    local tbEnemyDlg = self("tbEnemyDlg")
    for var = startPosidx, idx + self.maxShowCount do
        local cell = tbEnemyDlg:cellAtIndex(var)
        if cell then
            self:onCell(var, tbEnemyDlg, cell)
        end
        
    end
end