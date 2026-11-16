--vFarmLayer.lua

require "vFieldImage"
require "vPlantArmture"
require "vFormatData"
require "vFarmUpDlg"
require "vPlantBagDlg"
require "vPlantSprite"

VFarmLayer = VClass("FarmLayer", VLayer)


_CellPtx = {
    [6] = {[1] = 64, [2] = 129, [3] = 187, [4] = 248, [5] = 306, [6] = 362, [7] = 422, [8] = 483},
    [5] = {[1] = 51, [2] = 120, [3] = 180, [4] = 242, [5] = 300, [6] = 360, [7] = 420, [8] = 485},
    [4] = {[1] = 44, [2] = 112, [3] = 176, [4] = 238, [5] = 297, [6] = 358, [7] = 420, [8] = 485},
    [3] = {[1] = 34, [2] = 105, [3] = 169, [4] = 231, [5] = 294, [6] = 357, [7] = 419, [8] = 484},
    [2] = {[1] = 25, [2] = 96, [3] = 160, [4] = 227, [5] = 291, [6] = 353, [7] = 418, [8] = 484},
    [1] = {[1] = 12, [2] = 84, [3] = 155, [4] = 222, [5] = 291, [6] = 352, [7] = 420, [8] = 487},
}

_CellPty = {
    [6] = {[1] = 249, [2] = 249, [3] = 249, [4] = 249, [5] = 249, [6] = 249, [7] = 249, [8] = 249},
    [5] = {[1] = 204, [2] = 204, [3] = 204, [4] = 204, [5] = 204, [6] = 204, [7] = 204, [8] = 204},
    [4] = {[1] = 159, [2] = 159, [3] = 159, [4] = 159, [5] = 159, [6] = 159, [7] = 159, [8] = 159},
    [3] = {[1] = 110, [2] = 110, [3] = 110, [4] = 110, [5] = 110, [6] = 110, [7] = 110, [8] = 110},
    [2] = {[1] = 62, [2] = 62, [3] = 62, [4] = 62, [5] = 62, [6] = 62, [7] = 62, [8] = 62},
    [1] = {[1] = 13, [2] = 13, [3] = 13, [4] = 13, [5] = 13, [6] = 13, [7] = 13, [8] = 13},
}

function VFarmLayer:Init( attr )
	-- body
    VFarmLayer.super.Init(self, attr)
    self:NeedEvent(Eff_onEnter);
    gFarm = self
    self.msgBoxCount = 0;   
    self.touchPos = {}
    self.selectedplant = nil;
end

function VFarmLayer:onPush()
	self:CreateMap()
end

function VFarmLayer:onForeground()
    for k,plant in pairs(self.plantImages) do
        plant:showStatus();
    end
end

function VFarmLayer:SetMap(userInfo)
    self:ClearUp()
    
    self.userInfo = userInfo;
    self.farmInfos = self.userInfo.manorInfo.farmInfos;
    self.isSelf = self.userInfo.isSelf;

--    for i = 0, 4 do
--        for j = 0, 6 do
--            local field = self.fieldImages[""..(j + 1)..(4 - i + 1)]
--            field.isSelf = self.userInfo.isSelf;
--        end     
--    end
    
    
    local extend_level = self.userInfo.manorInfo.extendLevel
    self:UpdataFieldLevel(extend_level)


    --添加田地植物        
    for key, var in pairs(self.farmInfos) do
        self:setPlantToField(var)
    end 
end

function VFarmLayer:ClearUp(parameters)
    for i = 1, 5 do
        for j = 1, 7 do
            local field = self.fields[""..(j)..(i)]
--            field.isSelf = nil
            field.free = true
            field.lock = true
        end     
    end
    
    if self.plantImages ~= nil then
        for key, var in pairs(self.plantImages) do
            
            var:ClearUpPlantStatus(key);
        end
    end
    
    self.plantImages = {}
end

function VFarmLayer:CreateMap(userInfo)
--    ClearUp()
--    self.userInfo = userInfo;
--    self.farmInfos = self.userInfo.manorInfo.farmInfos;

    -- body
    self.fields = self.fields or {}
    self.scales = 1.54
    
    for i = 1, 5 do
        for j = 1, 7 do
            self.fields[""..(j)..(i)] = {}
            self.fields[""..(j)..(i)].lock = true
            self.fields[""..(j)..(i)].free = true
        end     
    end
--    self.plantImages = self.plantImages or {}
    
    -- local image = VImage{name = "temField", image = "land.png"}
    -- self.fieldSize = image.size
    -- self.ratio = {}
    -- self.ratio.x = 0.74
    -- self.ratio.y = 0
    -- self.ratio.revisex = 4
    -- self.ratio.revisey = 0.1
    --添加田地图片
    
--    for i = 0, 4 do
--        for j = 0, 6 do
--            self.fieldImages[""..(j + 1)..(4 - i + 1)] = VFieldImage{["name"] = ""..(j + 1)..(4 - i + 1), ["image"] = "land.png", ["gray"] = 1}
--            local field = self.fieldImages[""..(j + 1)..(4 - i + 1)]
--            field:SetPos(i, j, self.ratio)
----            field.isSelf = self.userInfo.isSelf;                      
--            field.pos = {x = (j + 1), y = (4 - i + 1)}
--            self:Push(field)
--        end     
--    end
    
    self:CreateFieldImage()
    
--      --设置田地等级
----    
--    local extend_level = self.userInfo.manorInfo.extendLevel
--    self:UpdataFieldLevel(extend_level)
--    
--
--    --添加田地植物    	
--    for key, var in pairs(self.farmInfos) do
--        self:setPlantToField(var)
--	end	
end

function VFarmLayer:checkClick(touch)
--    for k,plant in pairs(self.plantImages) do
--        local touchType = plant:checkClick(touch);
--        if touchType then
--            return touchType;
--        end
--    end

--    for k,field in pairs(self.fieldImages) do
--        local touchType = field:checkClick(touch);
--        if touchType then
--           return touchType; 
--        end
--    end
    return self:onClick(touch)
end

function VFarmLayer:CreateFieldImage()
    local image1 = VImage{name = "field"..(1), image = "farmfield"..(3)..".png", layout="DownLeft", offset={13 * self.scales, -4 * self.scales}, visible = 0, scale = 1.54}
    self:Push(image1)

    local image2 = VImage{name = "field"..(2), image = "farmfield"..(3)..".png", layout="DownLeft", offset={13 * self.scales, -4 * self.scales}, visible = 0, scale = 1.54}
    self:Push(image2)

    local image3 = VImage{name = "field"..(3), image = "farmfield"..(3)..".png", layout="DownLeft", offset={13 * self.scales, -4 * self.scales}, visible = 0, scale = 1.54}
    self:Push(image3)

    local image4 = VImage{name = "field"..(4), image = "farmfield"..(4)..".png", layout="DownLeft", offset={222 * self.scales, -8 * self.scales}, visible = 0, scale = 1.54}
    self:Push(image4)

    local image5 = VImage{name = "field"..(5), image = "farmfield"..(5)..".png", layout="DownLeft", offset={292 * self.scales, -3 * self.scales}, visible = 0, scale = 1.54}
    self:Push(image5)
    
    local image6 = VImage{name = "field"..(6), image = "farmfield"..(6)..".png", layout="DownLeft", offset={353 * self.scales, -7 * self.scales}, visible = 0, scale = 1.54}
    self:Push(image6)
    
    local image7 = VImage{name = "field"..(7), image = "farmfield"..(7)..".png", layout="DownLeft", offset={419 * self.scales, -5 * self.scales}, visible = 0, scale = 1.54}
    self:Push(image7)
end

function VFarmLayer:UpdataFieldLevel(level, isExtend)
    local csvDataM = gData:readCsv("manor_field_point_level.csv"); ---------------初始数据田地等级数字为1

    local lineCount = csvDataM:lineCount();
    --    cclog("count = %d%d%d", str:Get(0), str:Get(1), str:Get(2));
    for var = 1, 7 do
        if var <= level then
            
            -- 扩地完成动画
            if var == level and isExtend then
                local runTime = 0.7;
                self("field"..var):RunAction{{"sequence", {"fadeTo", 0, 0}, {"show"}, {"repeat", 2, {"sequence", {"fadeTo", runTime, 255}, {"fadeTo", runTime, 80}}}, {"fadeTo", 1, 255}}};
            else
                self("field"..var).visible = 1
            end
        else
            self("field"..var).visible = 0
        end
    end
    
    for var = 0, lineCount - 1 do
        local lineData = csvDataM:lineData(var)
        if lineData:Get(2) == level then
            local x = lineData:Get(0)
            local y = lineData:Get(1)
            --            self.fieldImages[""..x..y].image = "xigua.png"
            self.fields[""..x..y].lock = false
        end
    end 
    
    self:SetManorExtendBoard(level)
end

function VFarmLayer:SetManorExtendBoard(level)
    
    local board = self("board") 
    
    if board == nil then
        board = self:Push(VImage{name = "board", image = "kuodianniu.png", scale = 1.5, layout = "DownLeft" , offset = {(_CellPtx[1][7] + (_CellPtx[1][8] - _CellPtx[1][7]) / 2) * self.scales, -_CellPty[1][7] * self.scales - 10}})
    end
    
    local offsetX = board:getContentSize().width / 2
    
	if level == 1 then
        board.offset = {(_CellPtx[4][1] + (_CellPtx[4][2] - _CellPtx[4][1]) / 2) * self.scales - offsetX + 10, -_CellPty[4][1] * self.scales - 30}
        board.pos = "41"
    elseif level == 2 then
        board.offset = {(_CellPtx[5][1] + (_CellPtx[5][2] - _CellPtx[5][1]) / 2) * self.scales - offsetX + 10, -_CellPty[5][1] * self.scales - 30}
        board.pos = "51"
    elseif level == 3 then
        board.offset = {(_CellPtx[5][4] + (_CellPtx[5][5] - _CellPtx[5][4]) / 2) * self.scales - offsetX + 10, -_CellPty[5][4] * self.scales - 30}
        board.pos = "54"
    elseif level == 4 then
        board.offset = {(_CellPtx[5][5] + (_CellPtx[5][6] - _CellPtx[5][5]) / 2) * self.scales - offsetX + 10, -_CellPty[5][7] * self.scales - 30}
        board.pos = "55"
    elseif level == 5 then
        board.offset = {(_CellPtx[5][6] + (_CellPtx[5][7] - _CellPtx[5][6]) / 2) * self.scales - offsetX + 10, -_CellPty[5][7] * self.scales - 30}
        board.pos = "56"
    elseif level == 6 then
        board.offset = {(_CellPtx[5][7] + (_CellPtx[5][8] - _CellPtx[5][7]) / 2) * self.scales - offsetX + 10, -_CellPty[5][7] * self.scales - 30}
        board.pos = "57"
    elseif level == 7 then
        if board ~= nil then
            board.pos = "00"
            board:Delete()
        end
	end
end

function VFarmLayer:MouseToCell(point)
	local x, y = nil, nil
	for yy = 1, 5 do
		cclog("MouseToCell "..point.x..","..point.y);
	    for xx = 1, 7 do
            if point.y >= _CellPty[yy][xx] * self.scales and point.y < _CellPty[yy + 1][xx + 1] * self.scales then
                x1 = (_CellPtx[yy][xx] + _CellPtx[yy+1][xx]) / 2;
                x2 = (_CellPtx[yy][xx+1] + _CellPtx[yy+1][xx+1]) / 2;
                if point.x >= x1 * self.scales and point.x < x2 * self.scales then
		    		return xx, yy
		    	end
	    	end
	    end
	end
end

function VFarmLayer:didChoosed(target)
    local key = target:ReturnKey();
    local plant = self.plantImages[key];
    if plant then
        plant:didChoosed();
    end
end

function VFarmLayer:didUnChoose(target)
    local key = target:ReturnKey();
    local plant = self.plantImages[key];
    if plant then
        plant:didUnChoose();
    end
end

function VFarmLayer:onClick(touch)
--    if not self.isSelf then return end;
    
    local touchPoint = touch:getLocation()

    local locationInNode = self:convertToNodeSpace(touchPoint)
    local s = self:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)
    local x, y = self:MouseToCell(locationInNode)--cc.rectContainsPoint1(rect, locationInNode, gFarm.ratio, self.deviation)

    if x == nil or y == nil then
        return false
    end
    
    local isBoardCilck = nil
    if self("board") ~= nil then
        isBoardCilck = (self("board").pos == (y..x))
    end

    cclog("田地点击"..x..y)

    if self.fields[x..y].lock and self.isSelf and isBoardCilck then
        --功能开关：扩地
        if self.userInfo.roleInfo:isFunctionOpen(GameFunction.farm_plant) then
            gView():Push("vFarmUpDlg.vui")
        end
    elseif not self.fields[x..y].lock and self.fields[x..y].free and self.isSelf then
        --功能开关：种植
        if self.userInfo.roleInfo:isFunctionOpen(GameFunction.farm_plant) then
            self:SetCurrentTouchPos(x, y)
            local node = VNode("vPlantBagDlg.vui")
            node.DlgType = "ALLPLANT"
            gView():Push(node)
        end
    elseif not self.fields[x..y].free then
        
        local plant = self.plantImages[x..y]
        return plant:onClick()
    end
    
    return _VTouchType.Field
end

function VFarmLayer:immediatelyFinishLevelUpPlant(farmInfo)
    local plantArmature = self.plantImages[farmInfo:ReturnKey()];
    if plantArmature then
        plantArmature:levelUpStaffThing();
    end
end

------扩地
function VFarmLayer:ReqManorExtend(aParam)
--    self:UpdataFieldLevel(extend_level)    
    gReq:MsgReqManorExtend(self, "ManorExtendCallBack", aParam)
end


function VFarmLayer:ManorExtendCallBack(result, rsp, req)
    if result == 0 then
        self:ManorExtendSuccess(rsp)
    else
        self:ManorExtendUpFail();
    end
end

function VFarmLayer:ManorExtendSuccess(rsp)
    local rsp = VPb(rsp);
    local mi = rsp.mi;
    local bi = mi.bi;
    local extend_level = bi.extend_level;
    self.userInfo.manorInfo.extendLevel = extend_level
    self:UpdataFieldLevel(extend_level, true)
    gWindow:showTip("扩地成功", 1);
end

function VFarmLayer:ManorExtendUpFail()
--    local tip = gView():Push("vTipDlg.vui")
--    tip:ShowTip("REQFAIL");
    gWindow:showTip("扩地失败", 1);
end

------------end


function VFarmLayer:isLevelOping(farmInfo)
    local plant = self.plantImages[farmInfo:ReturnKey()];
    if plant then
        return plant:isLevelOping();
    end
    return false;
end

function VFarmLayer:setLevelOpreationWithId(plantID, isOp)
    for key, var in pairs(self.plantImages) do
        if var.farmInfo.plantInfo.id == plantID then
            var:setLevelOpreation(isOp);
            break
        end
    end
end


-----植物升级
function VFarmLayer:ReqPlantLvUp(farmInfo)
--    farmInfo:levelUp();

--    local plantArmture = self.plantImages[farmInfo:ReturnKey()];
--    if plantArmture then
--        plantArmture:setFarmInfo(farmInfo, true);
--    end
    
    
    local plant = self.plantImages[farmInfo:ReturnKey()];
    plant:setLevelOpreation(true);
    
    for key, var in pairs(farmInfo.plantInfo.effect) do
        gData.userInfo.roleInfo:addAttrValue(var.effectid, -math.abs(var.effectValue));
    end
--    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, -farmInfo.plantInfo.effect[1].effectValue);
--    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, -farmInfo.plantInfo.nextLevelCost.coinCost);
    farmInfo:LevelUpStart()
    plant:ShowNextLvUpTime()
    
    local aParam = {};
    aParam.plantid = farmInfo.plantInfo.id;
    aParam.pos = farmInfo:ReturnKey();
    gReq:MsgReqManorPlantLevelUp(self, "PlantLevelUpCallBack", aParam)
--    gWindow:showWaitTip("赵鹏")
end

function VFarmLayer:PlantLevelUpCallBack(result, rsp, req)
    if result == 0 then
        self:PlantLevelUpSuccess(rsp, req)
    else
        self:PlantLevelUpFail(result, rsp, req)
    end

    local pos = req.aParam.pos;
    local farmInfo = self.farmInfos[pos];
    local plant = self.plantImages[farmInfo:ReturnKey()];
    plant:setLevelOpreation(false);
end


function VFarmLayer:PlantLevelUpSuccess(rsp, req)
   
    local pos = req.aParam.pos;
    local farmInfo = self.farmInfos[pos];
    --    farmInfo:revertLevel();

    local plant = self.plantImages[farmInfo:ReturnKey()];
--    farmInfo:LevelUpStart()
--    plant:ShowNextLvUpTime()
--    gWindow:closeWaitTip()
    plant:LevelUpStart()
--    gWindow:showTip("升级计时成功!", 1);
end

function VFarmLayer:PlantLevelUpFail(result, rsp, req)
--    gWindow:closeWaitTip()   
    
    local pos = req.aParam.pos;
    local farmInfo = self.farmInfos[pos];
--    farmInfo:revertLevel();

    local plant = self.plantImages[farmInfo:ReturnKey()];
    
    for key, var in pairs(farmInfo.plantInfo.effect) do
        gData.userInfo.roleInfo:addAttrValue(var.effectid, math.abs(var.effectValue));
    end
--    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, farmInfo.plantInfo.effect[1].effectValue);
    -- gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, farmInfo.plantInfo.nextLevelCost.coinCost);
    
    farmInfo:RemoveLevelUpStart()
    if plant then
        plant:ShowResource();
        plant:ReMoveNextLvUpTime()
    end
    
    
end
------------end


-------------植物取消升级
function VFarmLayer:ReqManorPlantLevelUpCancel(extand)
    local farmInfo = extand.farmInfo
    local mi = self.userInfo.manorInfo;
    local leftTime = mi:levelUpTime(farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant);
    if leftTime <= 0 then
        return;
    end

    local plant = self.plantImages[farmInfo:ReturnKey()];
    if plant and plant:isLevelOping() then
        gWindow:showTip("哎呀，操作太快了.");
        return;
    end
    plant:setLevelOpreation(true);

    gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
    gData:enableStopUserSyn(true);
    
    farmInfo:CancelLevelUp()
    plant:ReMoveNextLvUpTime()

    local aParam = {}
    aParam.plantid = farmInfo.plantInfo.id
    aParam.pos = farmInfo:ReturnKey();
    gReq:MsgReqLevelUpCancel(self, "ReqManorPlantLevelUpCancelBack", farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant, farmInfo:ReturnKey())
end

function VFarmLayer:ReqManorPlantLevelUpCancelBack(result, rsp, req)
    if result == 0 then
        self:ReqManorPlantLevelUpCancelSuccess(rsp, req)
    else
        self:ReqManorPlantLevelUpCancelFail(result, rsp, req)
    end
end


function VFarmLayer:ReqManorPlantLevelUpCancelSuccess(rsp, req)
--    gWindow:showTip("取消升级成功!", 1);
end

function VFarmLayer:ReqManorPlantLevelUpCancelFail(result, rsp, req)
    local pos = req.pos;
    local farmInfo = self.farmInfos[pos];
--    farmInfo:revertLevel();

    local plant = self.plantImages[farmInfo:ReturnKey()];
    
    farmInfo:RevertCancelLevelUp()
    if plant then
        plant:ShowResource();
        plant:ShowNextLvUpTime()
    end
end


function VFarmLayer:ReqLevelUpAccelerate(farmInfo)
    local mi = self.userInfo.manorInfo;
    local leftTime = mi:levelUpTime(farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant);
    if leftTime <= 0 then
        return;
    end

    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local timeSpace = gData.userInfo.manorInfo:levelUpTime(farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
    local cost = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupMonster, timeSpace, farmInfo.plantInfo.timeCost)
    if cost == 0 then
        return
    end

    if YB < cost then
        gWindow:showMoneyLackDlg(cost)
        return
    end

    local plant = self.plantImages[farmInfo:ReturnKey()];
    if plant and plant:isLevelOping() then
        gWindow:showTip("哎呀，操作太快了.");
        return;
    end
    plant:setLevelOpreation(true);
    
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeCurrency, -cost);
    
    gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
    gData:enableStopUserSyn(true);

    farmInfo:CancelLevelUp()
    plant:SetLvUpInfo()
      
    local aParam = {}
    aParam.plantid = farmInfo.plantInfo.id
    aParam.pos = farmInfo:ReturnKey();
    gReq:MsgReqLevelUpAccelerate(self, "ReqLevelUpAccelerateBack", farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant, farmInfo:ReturnKey(), nil, cost)
end

function VFarmLayer:ReqLevelUpAccelerateBack(result, rsp, req)
    if result == 0 then
        self:ReqLevelUpAccelerateSuccess(rsp, req)
    else
        self:ReqLevelUpAccelerateFail(result, rsp, req)
    end
end


function VFarmLayer:ReqLevelUpAccelerateSuccess(rsp, req)
    local pos = req.pos;
    local farmInfo = self.farmInfos[pos];
    farmInfo:RemoveLevelUpStart();
--    gWindow:showTip("加速升级成功!", 1);
end

function VFarmLayer:ReqLevelUpAccelerateFail(result, rsp, req)
    local pos = req.pos;
    local farmInfo = self.farmInfos[pos];
    farmInfo:revertLevel();

    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeCurrency, req.cost);
    
    local plant = self.plantImages[farmInfo:ReturnKey()];

    farmInfo:RevertCancelLevelUp()
    if plant then
        plant:ShowResource();
        plant:ShowNextLvUpTime()
    end
end

----------植物种植和回收

function VFarmLayer:ReqManorPlantPlaceToFarm(attr)
    
    -- local plantLimits = gData.userInfo.manorInfo.baseCampInfo.plantLimits
    
    -- if gData.userInfo.manorInfo:CheckPlantLimit(attr) then
    --     if (plantLimits[attr.classType] or 0) ~= 0 then
            
    --         gWindow:showTip("只能种植"..(plantLimits[attr.classType] or "0").."颗"..attr.name.."，请提升庄园等级", 1)
    --     else
    --         gWindow:showTip("还不能种植"..attr.name.."，请提升庄园等级", 1)
    --     end
    -- 	return
    -- end
    
    local manorInfo = self.userInfo.manorInfo;
    local plantManager = self.userInfo.plantInfos;

    local plantInfo = plantManager:plantWithId(attr.id)
    local farmInfo = manorInfo:createFakeFarmInfo(plantInfo, cc.p(self.touchPos.x, self.touchPos.y));
    self:setPlantToField(farmInfo);

    plantManager:updatePlant(attr.id, nil, -1);

    local aParam = {}
    aParam.x = self.touchPos.x
    aParam.y = self.touchPos.y
    aParam.plantid = attr.id;
    aParam.pos = farmInfo:ReturnKey();

    gReq:MsgReqManorPlantPlace(self, "ManorPlantPlaceToFarmCallBack", aParam)
end

function VFarmLayer:ManorPlantPlaceToFarmCallBack(result, rsp, req)
    if result == 0 then
        self:ManorPlantPlaceToFarmSuccess(rsp, req)
    else
        self:ManorPlantPlaceToFarmFail(rsp, req)
    end
end

function VFarmLayer:ManorPlantPlaceToFarmSuccess(rsp, req)
    gData.userInfo.manorInfo:SaveFarmNoticeInfo()
end

function VFarmLayer:ManorPlantPlaceToFarmFail(rsp, req)
    local pos = req.aParam.pos;
    local farmInfo = self.farmInfos[pos];
    self:PutPlantToBag(farmInfo);
    self.farmInfos[pos] = nil;
end

function VFarmLayer:ReqManorPlantPlaceToBag(farmInfo)
    self:PutPlantToBag(farmInfo);

    local aParam = {}
    aParam.plantid = farmInfo.plantInfo.id;
    aParam.x = 0
    aParam.y = 0
    aParam.pos = farmInfo:ReturnKey();

    gReq:MsgReqManorPlantPlace(self, "ManorPlantPlaceToBagCallBack", aParam)
end

function VFarmLayer:ManorPlantPlaceToBagCallBack(result, rsp, req)
    if result == 0 then
        self:ManorPlantPlaceToBagSuccess(rsp, req)
    else
        self:ManorPlantPlaceToBagFail(rsp, req)
    end
end

function VFarmLayer:ManorPlantPlaceToBagSuccess(rsp, req)
    local plantid = req.plantid:String();
    local plantManager = self.userInfo.plantInfos;
    plantManager:updatePlant(plantid, nil, -1);
    
    gData.userInfo.manorInfo:removeFarmInfo(req.aParam.pos)
    gData.userInfo.manorInfo:SaveFarmNoticeInfo()
end

function VFarmLayer:ManorPlantPlaceToBagFail(rsp, req)
    local pos = req.aParam.pos;
    local farmInfo = self.farmInfos[pos];
    self:setPlantToField(farmInfo);

    local plantManager = self.userInfo.plantInfos;
    plantManager:updatePlant(farmInfo.plantInfo.id, farmInfo.plantInfo.thingid, -1);
end
------------end

function VFarmLayer:ReqPlantAccelerate(farmInfo)
    local plantSprite = self.plantImages[farmInfo:ReturnKey()];
    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local timeSpace = farmInfo:GetProduceSpace()
    local cost = plantSprite:getTimeAccelerateCost(timeSpace)
    

    
    if cost == 0 then
        return
    end

    if YB < cost then
        gWindow:showMoneyLackDlg(cost)
        return
    end
    
    
    farmInfo:setPlantFull()
    farmInfo:enableStopStatusSyn(PLANT_STATUS.PlantStatusProduce, true);
    
    if plantSprite then
        plantSprite:setFarmInfo(farmInfo, true, self.scales);
    end

    local aParam = {}
    aParam.plantid = farmInfo.plantInfo.id;
    aParam.pos = farmInfo:ReturnKey();
    gReq:MsgReqManorPlantAccelerate(self, "PlantAccelerateCallBack", aParam)
end

function VFarmLayer:PlantAccelerateCallBack(result, rsp, req)
    local pos = req.aParam.pos;
    local farmInfo = self.farmInfos[pos];
    farmInfo:enableStopStatusSyn(PLANT_STATUS.PlantStatusProduce, false);
    if result == 0 then

    else
        self:PlantReceiveFail(result, rsp, req)
    end
end

-------植物收获
function VFarmLayer:ReqPlantReceive(farmInfo)
    local aParam = {}
    aParam.plantid = farmInfo.plantInfo.id;
    aParam.pos = farmInfo:ReturnKey();
    if farmInfo.plantInfo.resType == 1 then
        aParam.resType = AttrType.AttrTypeSunshine
    else
        aParam.resType = AttrType.AttrTypeMoney
    end
    gReq:MsgReqManorPlantReceive(self, "PlantReceiveCallBack", aParam)
end

function VFarmLayer:PlantReceiveCallBack(result, rsp, req)
    if result == 0 then
        self:PlantReceiveSuccess(rsp, req)
    else
        self:PlantReceiveFail(result, rsp, req)
    end
end


function VFarmLayer:PlantReceiveSuccess(rsp, req)
end


function VFarmLayer:PlantReceiveFail(result, rsp, req)
    local pos = req.aParam.pos;
    local farmInfo = self.farmInfos[pos];
    farmInfo:revertTime(PLANT_STATUS.PlantStatusProduce);
    local plant = self.plantImages[farmInfo:ReturnKey()];
    if plant then
        plant:ShowResource();
    end
end

-------------end


------------好友帮忙
function VFarmLayer:ReqManorPlantHelp(farmInfo)
    local aParam = {}
    aParam.plantid = farmInfo.plantInfo.id
    aParam.target = self.userInfo.userid
    aParam.pos = farmInfo:ReturnKey();
    gReq:MsgReqManorPlantHelp(self, "ReqManorPlantHelpCallBack", aParam)
end

function VFarmLayer:ReqManorPlantHelpCallBack(result, rsp, req)
    if result == 0 then
        self:ReqManorPlantHelpSuccess(rsp, req)
    else
        self:ReqManorPlantHelpFail(result, rsp, req)
    end
end


function VFarmLayer:ReqManorPlantHelpSuccess(rsp, req)
    local pos = req.pos;
    local farmInfo = self.farmInfos[pos];

    local plant = self.plantImages[farmInfo:ReturnKey()];
    local ri = rsp.ri;
    local userid = ri.userid;
    local fi = rsp.fi;
    local infos = fi.infos
    local data = {}
    
    local iter = VDataIter();
    if infos then
        while infos:Travel(iter) do
            local item = iter:Data();
            if item.id == PLANT_STATUS.PlantStatusHelp then
                data = item
                break
            end
        end
        plant:SetHelp(true, data)
    end
end


function VFarmLayer:ReqManorPlantHelpFail(result, rsp, req)
    
end
-------------end
--读取动画播放速度和动画缩放比例
function VFarmLayer:getPlantAmtSpeedAndScale(image)
    local speed, scale;
    local acCsv = gData:readCsv("animation_creature.csv");
    scale = acCsv:lineDataWithKey(image,4)/ 100 or 1;
    speed = acCsv:lineDataWithKey(image,5)/100 or 1;
    return speed,scale;
end


function VFarmLayer:setPlantToField(farmInfo)
    if not farmInfo.plantInfo.plantImage then return end;

    local speed, scale = self:getPlantAmtSpeedAndScale(farmInfo.plantInfo.plantImage);

    
    
    local plantArmture = VPlantArmture{name = "plant", jsonName = farmInfo.plantInfo.plantImage, scaleN = scale, layout = "DownLeft"};
    
    local x = plantArmture:getAnchorPoint().x
    local y = plantArmture:getAnchorPoint().y
    local w = plantArmture:getContentSize().width
    local h = plantArmture:getContentSize().height
    -- {plantArmture:getContentSize().width, plantArmture:getContentSize().height}
    local plant = VPlantSprite{name = "plant"..farmInfo:ReturnKey(), scale = scale, size = {w, h}, layout = "DownLeft", level = 6 - farmInfo.pos.y}
--    plant:setAnchorPoint(cc.p(0,0));
    local imageName = "battleStart.png"

    if farmInfo.plantInfo.plantLevel == 0 then
        imageName = "battleStartBlack.png"
    end

    local imglevel = VImage{name = "imglevel", image=imageName, layout="Down", offset={-26,3}, scale=1.5};

    local txlevel = VText{name = "txlevel", text = farmInfo.plantInfo.plantLevel, layout="Center", font="cardNumber.fnt", offset={0,3}, scale=0.5}

    plantArmture:setSpeedScale(speed);
    imglevel:Push(txlevel)
    plant:Push(plantArmture)

    plant:Push(imglevel)
    

    -- plant:setAnchorPoint(cc.p(0, 0))

    plant:setFarmInfo(farmInfo, self.userInfo.isSelf, self.scales);
    plant:LevelUpStart()
    self:Push(plant);
    


    plant:SetPos(self.scales);
    -- plantArmture:setPosition(cc.p(300,0));

    plantArmture.offset = {w/2 - x * w,  - y * h -10}
    -- imglevel.offset = {w/2 - x * w,  - y * h -10}
    -- plant:ReLayout()
    plantArmture:delayStay()
    
    self.plantImages[farmInfo:ReturnKey()] = plant;
--    self.plantImages[farmInfo:ReturnKey()] = plantLayer;
    self.fields[farmInfo:ReturnKey()].free = false
end

function VFarmLayer:PutPlantToBag(farmInfo)
    local plant = self.plantImages[farmInfo:ReturnKey()];
    if not plant then return end;

    plant:Delete();
    self.plantImages[farmInfo:ReturnKey()] = nil;
    self.fields[farmInfo:ReturnKey()].free = true;

    local plantManager = self.userInfo.plantInfos;
    gLog("fake plantid = %s", farmInfo.plantInfo.id);
    plantManager:updatePlant(farmInfo.plantInfo.id, farmInfo.plantInfo.thingid, 1, true);
end

function VFarmLayer:DeletPlantSprite(plantID)

    for key, var in pairs(self.plantImages) do
        if var.farmInfo.plantInfo.id == plantID then
		    var:ClearUpPlantStatus()
		    self.plantImages[var.farmInfo:ReturnKey()] = nil;
            self.fields[var.farmInfo:ReturnKey()].free = true;
            gData.userInfo.manorInfo:DeleteFarmInfo(var.farmInfo)
            break
        end
	end
end

function VFarmLayer:SetCurrentOperatItem(id, thingid)

    self.operatid = id
    self.operatidthing = thingid
end

function VFarmLayer:SetCurrentTouchPos(posx, posy)
    self.touchPos.x = posx
    self.touchPos.y = posy
end

function VFarmLayer:ShowOperationLay(buttons, title, tab, Otype)
    -- gFarm.selectedplant = self;
    gMainView:ShowOperationLay(buttons, title, tab, Otype);
end

function VFarmLayer:MsgCallBack( node, vuiName, expand)
--    if self.msgBoxCount ~= 0 then
--        self:getView():Pop(); 
--    end
--    if expand then
--      self.operatid = expand.id
--      self.operatidthing = expand.thingid
--    end
--    self.msgBox = self:Push(vuiName)
    gView():Push(vuiName)
--    self.msgBoxCount = self.msgBoxCount + 1
end