
-- require "vMonsterEvolveDlg"
require "vComposeLvUpDlg"
require "vLvUpChangeDlg"

VLaboratoryDlg = VClass("LaboratoryDlg",VMsgBox)



function VLaboratoryDlg:onPush()
    self.datas = {{free = true}, {free = true}, {free = true}, {free = true}, {free = true}}

    self.lvUpLimit = gData.userInfo.manorInfo.lab_container_count
--    self("txNumLaboratoryD").text = self:GetCanUpCount()
    self("txLaboratoryD").text = gData:attrValue(AttrType.AttrTypeCurrency)
    self("titliText").image = "jiangshishengxingwenzi.png"
    self:ShowNotice()
    self:ShowLvingInfo()
    self:initUnlockTips()
end

function VLaboratoryDlg:ShowNotice(parameters)
	local levelFinishs = gData.userInfo.manorInfo.levelFinishs
    for key, var in pairs(levelFinishs) do
		if var.upType == LEVELUP_TYPE.LevelupMonster then
            local dlg = VNode("vLvUpChangeDlg.vui")
            local monsterInfo = gData.userInfo.monsterInfo.monsterInfos[var.id]
            dlg:SetInfo(monsterInfo)
            gView():Push(dlg)
            gData.userInfo.manorInfo:DelLevelUpFinishNotice(monsterInfo.id, LEVELUP_TYPE.LevelupMonster)
            gData.noticeManager:modify(NoticeType.finish_monster_star, -1)
		end
	end
end

function VLaboratoryDlg:GetCanUpCount(parameters)
    local count = 0
    local monsters = gData.userInfo.monsterInfo.monsterInfos or {}
    for i,v in pairs(monsters) do
        local t = {};
        if v.nextLevelId ~= 0 and not v.isLving then
            count = count + 1
        end
    end
    return count
end

function VLaboratoryDlg:ShowLvingInfo( ... )
	-- body
	self:InitLvingMonsterInfos()
	for i = 1, self.lvUpLimit do
		self:UpDataLvUpAtPos(i)
	end
end

function VLaboratoryDlg:InitLvingMonsterInfos(parameters)
    local time = 0
    local lvingInfo = nil
    local count = 1
    
    self.monsters = gData.userInfo.monsterInfo.monsterInfos or {};
    
    for key, var in pairs(self.monsters) do
        time = gData.userInfo.manorInfo:levelUpTime(var.id, LEVELUP_TYPE.LevelupMonster)
        if time > 0 then
            local levelUpInfo = gData.userInfo.manorInfo:levelUpInfo(var.id, LEVELUP_TYPE.LevelupMonster)
        	var.time = time
            local pos = levelUpInfo.pos
            self.datas[pos].info = var
            self.datas[pos].free = false


            -- var.time = time
            -- self.datas[count].info = var
            -- self.datas[count].free = false
            -- count = count + 1
        end
    end
end

function VLaboratoryDlg:UpDataLvUpAtPos( pos )
	-- body
	
    local info = self.datas[pos].info
	if info then
		self:UpDataLvUpAtPosFarm(pos, true)
	else
        self:UpDataLvUpAtPosFarm(pos, false)
	end
end

function VLaboratoryDlg:getAmtSpeedAndScale(image)
    local speed, scale;
    local acCsv = gData:readCsv("animation_creature.csv");
    scale = acCsv:lineDataWithKey(image,2)/ 100 or 1;
    speed = acCsv:lineDataWithKey(image,5)/100 or 1;
    return speed,scale;
end

function VLaboratoryDlg:UpDataLvUpAtPosFarm( pos, isUping )
	-- body
--    self("txNumLaboratoryD").text = self:GetCanUpCount()
    self("txLaboratoryD").text = gData:attrValue(AttrType.AttrTypeCurrency)
    
	local item = self("imgLvUpbg"..pos)
    item("txLockLaboratoryD").visible = false
    item("lyStar").visible = isUping
    item("imgComposebg").visible = isUping
    item("imgCompose").visible = isUping
    item("txtime").visible = isUping
    item("lyCountLaboratoryD").visible = isUping
    local speBtn = item("speBtn")
    item.image = "shengjiguanzi.png"
    local artUp = item("artUp")
    if isUping then
        local amtCompose = item("amtCompose")

        if amtCompose == nil then
            local lyc = item("lyc")
            
            amtCompose = VArmature{name = "amtCompose", jsonName = self.datas[pos].info.image, animation="idle", layout="Down"};
            local speed,scale = self:getAmtSpeedAndScale(self.datas[pos].info.image)
            cclog("scale"..scale)
            amtCompose.scale = scale
            lyc:Push(amtCompose);
        end
        -- local timeSpace = gData.userInfo.manorInfo:levelUpTime(self.datas[pos].info.id, LEVELUP_TYPE.LevelupMonster)
        -- item("txLaboratoryD").text = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupMonster, timeSpace, self.datas[pos].info.timeCost)
        artUp:play("guanzi");
        artUp.visible = 1
        speBtn.image = "anniu12.png"
        item("imgSpe").image = "likewancheng.png"
        speBtn.onClick="node:Parent(2):onbtnAccelerateClick("..pos..")"
        item.touch = 0
    else
        local amtCompose = item("amtCompose")
        if amtCompose then
            amtCompose:doPop()
        end
        
        artUp.visible = 0
        speBtn.image = "anniu11.png"
        item("imgSpe").image = "tianjiajiangshi.png"
        speBtn.onClick="node:Parent(2):OpenlvUpDlg("..pos..")"
        item.touch = 1
    end
    speBtn.visible = true
    
    local txtime = item("txtime")
    if isUping then
        local count = self.datas[pos].info.level + 1
        -- for var = 1, count do
        --     local star = item("imgStar"..var)
        --     star.visible = 1
        -- 	if var == count then
        --         star:RunAction{{"sequence", {"repeat", -1, {"sequence", {"fadeTo", 0.5, 255}, {"fadeTo", 0.5, 80}}}, {"fadeTo", 1, 255}}};
        -- 	end
        -- end
        item("lyStar").visible=1
        item("txlevel").text = count
        item("imgStar"):RunAction{{"sequence", {"repeat", -1, {"sequence", {"fadeTo", 0.5, 255}, {"fadeTo", 0.5, 80}}}, {"fadeTo", 1, 255}}};
        
        local time = gData.userInfo.manorInfo:levelUpTime(self.datas[pos].info.id, LEVELUP_TYPE.LevelupMonster)
        
        txtime.time = time
        txtime:startCountDown()
        item("txLaboratoryD").text = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupMonster, time, self.datas[pos].info.timeCost)
        if self.datas[pos].schedulerUp == nil then
        self.datas[pos].schedulerUp = gDtr:getScheduler():scheduleScriptFunc( 
            function () VCallBack(self, "UpDataTimeCost", pos); end, 1, false);
        end
--        self:StartTimer("LevelUpFinish", time);
        self.datas[pos].currentLv = self.datas[pos].info.level
        self.datas[pos].free = false
    else
        -- for var = 1, 5 do
        --     local star = item("imgStar"..var)
        --     star.visible = 0
        --     star:stopAllActions()
        -- end
        item("lyStar").visible=0

        txtime:stopCountDown()
        
        if self.datas[pos].info and self.datas[pos].schedulerUp then
            gDtr:getScheduler():unscheduleScriptEntry(self.datas[pos].schedulerUp)
            self.datas[pos].schedulerUp = nil;
        end
        
        self.datas[pos].info = nil
        self.datas[pos].currentLv = nil
        self.datas[pos].free = true
    end
end

function VLaboratoryDlg:UpDataTimeCost(pos)
    if self.datas[pos].info then
        local timeSpace = gData.userInfo.manorInfo:levelUpTime(self.datas[pos].info.id, LEVELUP_TYPE.LevelupMonster)
        if timeSpace <= 0 then
            self:LevelUpFinish(pos)
            local info = gData.userInfo.monsterInfo:GetMonsterWithid(self.datas[pos].info.id)
            info:RemoveLevelUpStart();
            gData.userInfo.manorInfo:DelLevelUpFinishNotice(self.datas[pos].info.id, LEVELUP_TYPE.LevelupMonster)
        else
            local item = self("imgLvUpbg"..pos)
            item("txLaboratoryD").text = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupMonster, timeSpace, self.datas[pos].info.timeCost)
        end
--    elseif self.datas[pos].info and self.datas[pos].schedulerUp then
--        gDtr:getScheduler():unscheduleScriptEntry(self.datas[pos].schedulerUp)
--        self.datas[pos].schedulerUp = nil;
    end
end

function VLaboratoryDlg:LevelUpFinish(pos)
    local info = self.datas[pos].info

    info:CancelLevelUp()

    info:UpDataLevelInfo()
    
    self:ShowLvUpChange(pos)
    
    self:UpDataLvUpAtPosFarm(pos, false)
end


-----打开选择僵尸升星的界面
function VLaboratoryDlg:OpenlvUpDlg(pos)
    self.posChoise = pos
    local composeLvUpDlg = VNode("vComposeLvUpDlg.vui")
    gView():Push(composeLvUpDlg)
end

function VLaboratoryDlg:ReqManorPlantLevelUp(info)
    local dlg = gView()("composeLvUpDlg")
    
    if dlg then
        dlg:onClick()
    end
    
   

    if self:isLevelOping(self.posChoise) then
        return
    end

    for key, var in pairs(info.effect) do
        gData.userInfo.roleInfo:addAttrValue(var.effectid, -math.abs(var.effectValue));
    end
    
--    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, -info.effect[1].effectValue);
--    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, -info.effect);
    
    
    info:LevelUpStart()
--    Show
    self.datas[self.posChoise].info = info
    self.datas[self.posChoise].free = false

    self:UpDataLvUpAtPosFarm(self.posChoise, true)
    
    
    self:setLevelOpreation(self.posChoise)

    gData.userInfo.manorInfo:SetMonsterLvUpPos(info.id, self.posChoise)
    
    local param = {}
    param.id = info.id
    param.pos = self.posChoise
    gReq:MsgReqMonsterLevelUp(self, "ReqManorPlantLevelUpBack", param)
end

function VLaboratoryDlg:ReqManorPlantLevelUpBack(result, rsp, req)
    if result == 0 then
        self:ReqManorPlantLevelUpSuccess(rsp, req)
    else
        self:ReqManorPlantLevelUpFail(result, rsp, req)
    end
    
    self:levelOpreationTimeOut(req.pos)
end

function VLaboratoryDlg:ReqManorPlantLevelUpSuccess(rsp, req)
    
end

function VLaboratoryDlg:ReqManorPlantLevelUpFail(result, rsp, req)
    local info = self.datas[req.pos].info

    for key, var in pairs(info.effect) do
        gData.userInfo.roleInfo:addAttrValue(var.effectid, math.abs(var.effectValue));
    end

	info:RemoveLevelUpStart()
    self:UpDataLvUpAtPosFarm(req.pos, false)
end

function VLaboratoryDlg:onbtnLvUpCancel(pos)
    local aParma = {}
    aParma.pos = pos
    aParma.title = "停止升级吗?"
    local itemCommon = gData:LoadItemCommon()
    aParma.content =  "停止升级只会返还"..itemCommon.retResScale.."%费用"

    gWindow:showConfirmTip("停止升级只会返还"..itemCommon.retResScale.."%费用", "确定", "取消", self, "ReqLevelUpCancel", "", "停止升级吗?",
        aParma);
end

function VLaboratoryDlg:ReqLevelUpCancel(aParma)
    local pos = aParma.pos
    
    if self:isLevelOping(pos) then
        return
    end

    self:setLevelOpreation(pos)

    local info = self.datas[pos].info
    
    info:CancelLevelUp()

    self:UpDataLvUpAtPosFarm(pos, false)
    
    gReq:MsgReqLevelUpCancel(self, "ReqLevelUpCancelBack", info.id, LEVELUP_TYPE.LevelupMonster, pos)
end

function VLaboratoryDlg:ReqLevelUpCancelBack(result, rsp, req)
    if result == 0 then
        self:ReqLevelUpCancelSuccess(rsp, req)
    else
        self:ReqLevelUpCancelFail(result, rsp, req)
    end
    
    self:levelOpreationTimeOut(req.pos)
end


function VLaboratoryDlg:ReqLevelUpCancelSuccess(rsp, req)
--    gWindow:showTip("取消升级成功!", 1);
    local pos = req.pos;
    local info = gData.userInfo.monsterInfo:GetMonsterWithid(req.id:String())
    info:RemoveLevelUpStart();
end

function VLaboratoryDlg:ReqLevelUpCancelFail(result, rsp, req)
    local info = gData.userInfo.monsterInfo:GetMonsterWithid(req.id:String())
    
    self.datas[req.pos].info = info
    
    info:RevertCancelLevelUp()
    
    self:UpDataLvUpAtPosFarm(req.pos, true)
end

function VLaboratoryDlg:onbtnAccelerateClick(pos)
    local timeSpace = gData.userInfo.manorInfo:levelUpTime(self.datas[pos].info.id, LEVELUP_TYPE.LevelupMonster)
    local cost = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupMonster, timeSpace, self.datas[pos].info.timeCost)

    gWindow:showPayTip2("立刻完成升级吗？", "立刻完成需要消耗"..cost.."钻石", cost, self, "ReqLevelUpAccelerate", pos, cost);
end

function VLaboratoryDlg:ReqLevelUpAccelerate(pos, cost)
    if self:isLevelOping(pos) then
        return
    end
    
    local info = self.datas[pos].info
    
    local mi = gData.userInfo.manorInfo;
    local leftTime = mi:levelUpTime(info.id, LEVELUP_TYPE.LevelupMonster);
    if leftTime <= 0 then
        return;
    end

    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local timeSpace = gData.userInfo.manorInfo:levelUpTime(self.datas[pos].info.id, LEVELUP_TYPE.LevelupMonster)
    local cost = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupMonster, timeSpace, self.datas[pos].info.timeCost)
    if cost == 0 then
        return
    end

    if YB < cost then
        gWindow:showMoneyLackDlg(cost)
        return
    end

    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeCurrency, -math.abs(cost));
    
    self:setLevelOpreation(pos)   
    
    self:LevelUpFinish(pos)
    
    gReq:MsgReqLevelUpAccelerate(self, "ReqLevelUpAccelerateBack", info.id, LEVELUP_TYPE.LevelupMonster, pos)
end

function VLaboratoryDlg:ReqLevelUpAccelerateBack(result, rsp, req)
    if result == 0 then
        self:ReqLevelUpAccelerateSuccess(rsp, req)
    else
        self:ReqLevelUpAccelerateFail(result, rsp, req)
    end
    
    self:levelOpreationTimeOut(req.pos)
end


function VLaboratoryDlg:ReqLevelUpAccelerateSuccess(rsp, req)
    local pos = req.pos;
    local info = gData.userInfo.monsterInfo:GetMonsterWithid(req.id:String())
    info:RemoveLevelUpStart();
    
--    gWindow:showTip("加速升级成功!", 1);
end

function VLaboratoryDlg:ReqLevelUpAccelerateFail(result, rsp, req)
    local info = gData.userInfo.monsterInfo:GetMonsterWithid(req.id:String())

    self.datas[req.pos].info = info
    
    info:RevertLevel();
    info:RevertCancelLevelUp()

    self:UpDataLvUpAtPosFarm(req.pos, true)
end

function VLaboratoryDlg:isLevelOping(pos)
    return self.datas[pos].scheduler
end

function VLaboratoryDlg:ShowLvUpChange(pos)
	local dlg = VNode("vLvUpChangeDlg.vui")
    dlg:SetInfo(self.datas[pos].info)
    gView():Push(dlg)
end

function VLaboratoryDlg:setLevelOpreation(pos) --防止升级操作过于频繁

--    if not free then
        self.datas[pos].scheduler = gDtr:getScheduler():scheduleScriptFunc( 
                function () VCallBack(self, "levelOpreationTimeOut", pos); end, 20, false);
--    else
--        gDtr:getScheduler():unscheduleScriptEntry(self.datas[pos].scheduler)
--                self.datas[pos].scheduler = nil;
--    end
end

function VLaboratoryDlg:levelOpreationTimeOut(pos)
    gDtr:getScheduler():unscheduleScriptEntry(self.datas[pos].scheduler)
                self.datas[pos].scheduler = nil;
end

function VLaboratoryDlg:initUnlockTips( )
    -- local csv = gData:readCsv("prop_laboratory.csv");
    -- local data = csv:allData();
    -- local data_Level = {};
    -- for i,v in ipairs(data) do 
    --     data_Level[v.monsterLimit] = data_Level[v.monsterLimit] or v.level;
    -- end
    -- for i = 1, 5 do
    --     self("imgLvUpbg"..i)("txLockLaboratoryD").text = string.format("研究所%s级解锁",tostring(data_Level[i]));
    -- end
    local startPos = self.lvUpLimit + 1

    local csv = gData:readCsv("prop_lab_container.csv");
    local data = csv:lineDataWithKey(startPos)

    

    local item = self("imgLvUpbg"..startPos)

    if not item then
        return
    end

    item("txLockLaboratoryD").visible = false   -----解锁条件的文字
    local speBtn = item("speBtn")
    speBtn.image = "anniu12.png"
    speBtn.visible = 1

    item("imgSpe").image = "jiesuozi.png"
    speBtn.onClick="node:Parent(2):ReqLabContainerAdd("..startPos..")"
    item("txLaboratoryD").text = data.cost
    item("lyCountLaboratoryD").visible = 1

    for i = startPos + 1, 5 do
        self("imgLvUpbg"..i)("txLockLaboratoryD").text = string.format("需拥有"..(i - 1).."升星器");
    end
end


----发送添加升星器请求
function VLaboratoryDlg:ReqLabContainerAdd( pos )
    -- body
    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local csv = gData:readCsv("prop_lab_container.csv");
    local data = csv:lineDataWithKey(pos)
    if data.cost > YB then
        gWindow:showMoneyLackDlg(data.cost)
        return
    end

    gReq:MsgReqLabContainerAdd(self, "ReqLabContainerAddBack", 1, pos)
    gWindow:showWaitTip()
    -- self:ReqLabContainerAddBack()
end

function VLaboratoryDlg:ReqLabContainerAddBack( result, rsp, req )
    -- body
    if result == 0 then
        self.lvUpLimit = gData.userInfo.manorInfo.lab_container_count
        self:UpDataLvUpAtPosFarm(req.pos, false)
        self:initUnlockTips()
    end
    gWindow:closeWaitTip()
end

