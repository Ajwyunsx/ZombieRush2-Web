--vFarmInfo.lua

require "vPlantInfo"

VStatusInfo = vclass("StatusInfo");

function VStatusInfo:initialize(id, time)
	self.id = id;
	self.value = 0;
	self.time = time or 0;
	self.startValue = 0;
end

function VStatusInfo:synWithPbData(pbData)
	self.id = pbData.id;
	self.value = pbData.value;
	self.time = pbData.time;
	self.startValue = pbData.start_value;
end

function VStatusInfo:backUpTime()
	self.lastTime = self.time;
end

function VStatusInfo:revertTime()
	if self.lastTime then
		self.time = self.lastTime;
		self.lastTime = nil;
	end
end

function VStatusInfo:isHelpPass()
	if self:helpTimeLeft() > 0 then
		return true;
	end
	return false;
end

function VStatusInfo:helpTimeLeft()
	return 3600 - (gData:currentTime() - self.time);
end

function VStatusInfo:passTime()
	return self.time - gData:currentTime();
end


VFarmInfo = vclass("FarmInfo");

function VFarmInfo:initFakeData(plantInfo, pos)
	if plantInfo then
		self.plantInfo = plantInfo;
	end
	self.pos = cc.p(pos.x, pos.y);
	self.statusInfo = {};
	self:resetPlantTime()
end

function VFarmInfo:initialize()
	self.plantInfo = VPlantInfo:new();
	self.statusInfo = {};
	self.stopSynStatus = {};
end

function VFarmInfo:synWithPbData(pbData)
	self.plantInfo:synWithPbData(pbData.info);
	self.pos = cc.p(pbData.pos.x, pbData.pos.y);

	local needKeep = {}
	for k,v in pairs(self.stopSynStatus) do
		needKeep[k] = self.statusInfo[k];
	end

	self.statusInfo = {};
	if pbData.infos then
		local iter = VDataIter();
	    while pbData.infos:Travel(iter) do
	    	local statusInfo = VStatusInfo:new();
	    	statusInfo:synWithPbData(iter:Data());
	    	if needKeep[statusInfo.id] then
	    		self.statusInfo[statusInfo.id] = needKeep[statusInfo.id];
	    	else
	    		self.statusInfo[statusInfo.id] = statusInfo;
	    	end
	    end
	end
end

function VFarmInfo:enableStopStatusSyn(id, enable)
	if enable then
		self.stopSynStatus[id] = enable;
	else
		self.stopSynStatus[id] = nil;
	end
end

function VFarmInfo:LevelUpStart()
--    cclog("发送消息时升级剩余时间"..self.plantInfo.nextLevelCost.timeSpace)
    cclog("发送消息时id:"..self.plantInfo.id.."时间:"..self.plantInfo.timeCost.."类型"..LEVELUP_TYPE.LevelupPlant)
    gData.userInfo.manorInfo:setLevelUpInfo(self.plantInfo.id, LEVELUP_TYPE.LevelupPlant, 
        gData:currentTime() + self.plantInfo.timeCost, self.plantInfo.plantLevel+1)

    gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
    gData:enableStopUserSyn(true);
end

function VFarmInfo:RemoveLevelUpStart()
    cclog("RemoveLevelUpStart")
    gData.userInfo.manorInfo:removeLevelUpInfo(self.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
end

function VFarmInfo:CancelLevelUp(parameters)
    cclog("CancelLevelUp")
    gData.userInfo.manorInfo:cancelLevelUp(self.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
end

function VFarmInfo:RevertCancelLevelUp(parameters)
    cclog("RevertCancelLevelUp")
    gData.userInfo.manorInfo:revertCancelLevelUp(self.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
end

function VFarmInfo:levelUp()
	self.plantInfo:levelUp();
end

function VFarmInfo:revertLevel()
	self.plantInfo:revertLevel();
end

function VFarmInfo:ReturnKey()
    return (self.pos.x)..(self.pos.y)
end

function VFarmInfo:statusInfoWithId(id)
	return self.statusInfo[id];
end

function VFarmInfo:AddHelpStatus(id, data)
    -- local statusInfo = VStatusInfo:new();
    -- statusInfo:synWithPbData(data)
    -- self.statusInfo[id] = statusInfo
end

function VFarmInfo:removeStatus(id)
	self.statusInfo[(id or 0)] = nil;
end

function VFarmInfo:helpTimeLeft()
	local statusInfo = self.statusInfo[PLANT_STATUS.PlantStatusHelp];
	if statusInfo then
		return statusInfo:helpTimeLeft();
	end
	return 0;
end

function VFarmInfo:isHelp()
	-- local statusInfo = self.statusInfo[PLANT_STATUS.PlantStatusHelp];
	-- if statusInfo and statusInfo:isHelpPass() then
	-- 	return true;
	-- end
	return false;
end

function VFarmInfo:setStatusInfoTime(id, time)
	local statusInfo = self.statusInfo[id];
	if statusInfo then
		statusInfo.time = time;
	else
		statusInfo = VStatusInfo:new(id, time);
		self.statusInfo[id] = statusInfo;
	end
end

function VFarmInfo:backUpTime(id)
	local statusInfo = self:statusInfoWithId(id);
	if statusInfo then
		statusInfo:backUpTime();
	end
end

function VFarmInfo:revertTime(id)
	local statusInfo = self:statusInfoWithId(id);
	if statusInfo then
		statusInfo:revertTime();
	end
end

function VFarmInfo:resetPlantTime()
	self:backUpTime(PLANT_STATUS.PlantStatusProduce);
    local growSpeed = self.plantInfo.growSpeedSec or 1;
    local maxGrow = self.plantInfo.growMax or 0;
    local maxGrowTime = maxGrow/growSpeed;
    self:setStatusInfoTime(PLANT_STATUS.PlantStatusProduce, gData:currentTime() + maxGrowTime);
end

function VFarmInfo:setPlantFull()
	self:backUpTime(PLANT_STATUS.PlantStatusProduce);
--	local growSpeed = self.plantInfo.growSpeedSec;
--	local maxGrow = self.plantInfo.growMax;
--	local maxGrowTime = maxGrow/growSpeed;
--	self:setStatusInfoTime(PLANT_STATUS.PlantStatusProduce, gData:currentTime() - maxGrowTime);
    self:setStatusInfoTime(PLANT_STATUS.PlantStatusProduce, gData:currentTime());
end

function VFarmInfo:produceValue()
    cclog("produceValue")
    if self.plantInfo.isWarPlant then
        return -1, -1
    end
	local growInfo = self:statusInfoWithId(PLANT_STATUS.PlantStatusProduce);----------------服务器给具体数值是下一次成熟时间
	if not growInfo then return 0 end;

	local plantTime = growInfo.time;
	gLog("plantTime = %d", plantTime);
	gLog("currentTime = %d", gData:currentTime());
--	local grawTime = gData:currentTime() - plantTime;
    local grawTimeSpace = math.min(plantTime - gData:currentTime(), plantTime);
    gLog("grawTimeSpace = %d", grawTimeSpace);
    if grawTimeSpace < 0 then grawTimeSpace = 0 end;

	local growSpeed = self.plantInfo.growSpeedSec;
	local maxGrow = self.plantInfo.growMax;
	if not growSpeed then growSpeed = 0 end;

    local produceValue = maxGrow - growSpeed * grawTimeSpace;
--	if produceValue > maxGrow then produceValue = maxGrow end;
    if produceValue < 0 then produceValue = 0 end

	produceValue = math.floor(produceValue);
	
	local vipInfo = gData.userInfo.roleInfo.vipInfo
    local produceValueVip = 0
	
	if vipInfo[1] ~= 0 then
        produceValueVip = math.floor(0 * produceValue / 100)
	end
	
	local resLimit = 0
	local resType = nil
	
	if self.plantInfo.resType == 1 then
	    
        local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
        resLimit = gData.userInfo.manorInfo.storeInfo.sunshineMax - sunShine;
        resType = AttrType.AttrTypeSunshine
	else
        local coin = gData:attrValue(AttrType.AttrTypeMoney)
        resLimit = gData.userInfo.manorInfo.storeInfo.coinMax - coin;
        resType = AttrType.AttrTypeMoney
	end
	
    if resLimit < 0 then
        resLimit = 0
    end
    cclog("produceValue~~~~~~end")
    return math.min(produceValue, resLimit), resType;
end 

function VFarmInfo:GetProduceSpace(parameters)
    local growInfo = self:statusInfoWithId(PLANT_STATUS.PlantStatusProduce);----------------服务器给具体数值是下一次成熟时间
    if not growInfo then return 0 end;

    local plantTime = growInfo.time;
--    local grawTime = gData:currentTime() - plantTime;
    local grawTimeSpace = math.min(plantTime - gData:currentTime(), plantTime);
    -- cclog("grawTime = %d", grawTime);
    if grawTimeSpace < 0 then grawTimeSpace = 0 end;
    
--    local growSpeed = self.plantInfo.growSpeedSec;
--    local maxGrow = self.plantInfo.growMax;
--    if not growSpeed then return 0 end;
--
--    local maxGrowTime = maxGrow/growSpeed;
--    cclog("plantTime = %d", plantTime);
--    cclog("grawTime = %d", grawTime);
--    cclog("maxGrowTime = %d", maxGrowTime);
--    cclog("currentTime = %d", gData:currentTime());
--    return math.max(maxGrowTime - grawTime, 0)
    return math.max(grawTimeSpace, 0)
end

function VFarmInfo:timeForHarvest()
    cclog("timeForHarvest")
	local growInfo = self:statusInfoWithId(PLANT_STATUS.PlantStatusProduce);
	if not growInfo then return 0 end;

	local plantTime = growInfo.time;
	 cclog("plantTime = %d", plantTime);
	 cclog("currentTime = %d", gData:currentTime());
--	local grawTime = gData:currentTime() - plantTime;
    local grawTimeSpace = math.min(plantTime - gData:currentTime(), plantTime);
    cclog("grawTimeSpace = %d", grawTimeSpace);
    if grawTimeSpace < 0 then grawTimeSpace = 0 end;

	local growSpeed = self.plantInfo.growSpeedSec;
	local maxGrow = self.plantInfo.growMax;
	if not growSpeed then return 0 end;

	local maxGrowTime = maxGrow/growSpeed;
--	local harvestTime = math.floor(maxGrowTime/100 - grawTime);
    local harvestTime = math.floor(grawTimeSpace - maxGrowTime * 99 / 100);
    cclog("maxGrowTime = %d", maxGrowTime);
	if harvestTime < 0 then harvestTime = 0 end;
	if harvestTime == 0 then
		self.canHarvest = true;
	else
		self.canHarvest = false;
	end

--	local maxLeftTime = math.floor(maxGrowTime-grawTime);
    local maxLeftTime = math.floor(grawTimeSpace)
	if maxLeftTime < 0 then maxLeftTime = 0 end;
    
    cclog("harvestTime, maxLeftTime"..harvestTime.."~~~~~~~~~~~~"..maxLeftTime)
    cclog("timeForHarvest~~~~~~~~end")
	return harvestTime, maxLeftTime;
end

