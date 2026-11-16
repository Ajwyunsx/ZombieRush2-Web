--vManorInfo.lua

require "vLaboratoryInfo"
require "vStoreInfo"
require "vAltarInfo"

VLevelUpInfo = vclass("LevelUpInfo")

function VLevelUpInfo:synWithPbData(pbData)
	self.upType = pbData.type;
	self.value = pbData.value;
	self.time = pbData.time;
	self.level = pbData.level;
	self.pos = pbData.pos;
end

function VLevelUpInfo:cancelLevelUp()
	self.lastTime = self.time;
	cclog("~~~~~~~~~~~settime=0")
	self.time = 0;
end

function VLevelUpInfo:revertCancelLevelUp()
	self.time = self.lastTime or 0;
	self.lastTime = nil;
end

function VLevelUpInfo:leftTime()
	if self.time == 0 then return 0 end;
	local leftTime = self.time - gData:currentTime();
	if leftTime > 0 then
		return leftTime;
	end
	return 0;
end

function VLevelUpInfo:mergeWithNew(newInfo)
	if not self.level then
		self.level = newInfo.level;
	end
	if self.level == newInfo.level then
		self.time = newInfo.time;
	end
end

VBaseCampInfo = vclass("VBaseCampInfo")

function VBaseCampInfo:initialize(level)
	self.level = level or 1;
end

function VBaseCampInfo:synWithPbData(level)
	if self.level and self.level > level then return end;

	self.level = level or 1;
	self:loadCsvData();
end

function VBaseCampInfo:loadCsvData()
	local csv_pb = gData:readCsv("prop_basecamp.csv");
	local info_pb = csv_pb:lineDataWithKey(self.level);
	local info_pb_next = csv_pb:lineDataWithKey(self.level + 1);


	if info_pb then 
		self.userLevelLimit = info_pb.userLevelLimit;
		self.upgradeCoin = info_pb.upgradeCoin;
		self.upgradeSunshine = info_pb.upgradeSunshine;
		self.upgradeTime = info_pb.upgradeTime;
		self.userExp = info_pb.userExp;
		self.sunLimit = info_pb.sunLimit;
		self.coinLimit = info_pb.coinLimit;
	end
	if info_pb_next then
		self.nextLevel = self.level + 1;
		self.canUpdate = true;
		self.sunNextLimit = info_pb_next.sunLimit;
		self.coinNextLimit = info_pb_next.coinLimit;
	else
		self.canUpdate = false;
	end
    
    -- self:loadPlantLimitInfo();
    cclog("庄园信息发生变化")
    
 gData:RunTrainning()
end

function VBaseCampInfo:loadPlantLimitInfo()
	self.plantLimits = self:getPlantLimitInfo(self.level);
end

function VBaseCampInfo:getPlantLimitInfo(level)
	local plantLimits = {}
    
    local csv = gData:readCsv("basecamp_plantlimit.csv");
	local linesData = csv:linesWithRowValue(0, level);
	for i,v in ipairs(linesData) do
		local vipLevel = gData.userInfo.roleInfo.vipInfo[0];
		local t = v[1];
		local plantVipCsv = gData:readCsv("basecamp_plantlimit_vip.csv");
        local vipLineData = plantVipCsv:linesWithKeyRowValues(vipLevel,t);
		if vipLineData then
			plantLimits[t] = v[2] + vipLineData[2];
		else
			plantLimits[t] = v[2];
		end
	end
	return plantLimits;
end

function VBaseCampInfo:getPlantAddInfo()
	local info = {};
	local plantNextLimit = self:getPlantLimitInfo(self.level+1);
	for i,v in pairs(plantNextLimit) do
		local curCount = self.plantLimits[i] or 0;
		if v > curCount then
			local descCsv = gData:readCsv("plant_desc.csv");
		    local desc = descCsv:linesWithKeyRowValues(i, 1);
		    if not desc then 
		        gLog("vManorInfo plant_desc.csv miss ID:%d", self.thingid);
		        return;
		    end
		    local m = {};
		    m.image = desc.image;
			m.addCount = v - curCount;
			table.insert(info, m);
		end
	end
	return info;
end


function VBaseCampInfo:GetLimitInfo(classType)
    return self.plantLimits[classType]
end

function VBaseCampInfo:levelUp()
	local time = gData:currentTime() + self.upgradeTime;
    gData.userInfo.manorInfo:setLevelUpInfo(BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding, time, self.nextLevel);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, -self.upgradeSunshine);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, -self.upgradeCoin);

    gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
    gData:enableStopUserSyn(true);
end

function VBaseCampInfo:levelUpFinish(isSelf)
	local levelUpInfo = gData.userInfo.manorInfo:levelUpInfo(BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding);
	if levelUpInfo then
		if self.level < levelUpInfo.level then
			self.level = levelUpInfo.level;
			self:loadCsvData();
			local curlevel = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeLevel);
			gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeLevel, self.level-curlevel);
		end
	end
	gData.userInfo.manorInfo:removeLevelUpInfo(BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding);
	gAudio:playEffect("levleup_basecamp.ogg");
end

function VBaseCampInfo:revertLevelUpFinish(isSelf)
	self.level = self.level - 1;
	self:loadCsvData();
	if isSelf then
		-- gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeExp, -self.userExp);
	end
end

function VBaseCampInfo:revertLevelUp()
	gData.userInfo.manorInfo:removeLevelUpInfo(BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding);
	gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, self.upgradeSunshine);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, self.upgradeCoin);
end

VManorInfo = vclass("ManorInfo")

function VManorInfo:initialize()
	self.extendLevel = 0;
	self.workingFarmer = 0;
    self.storeInfo = VStoreInfo:new()
    self.altarInfo = VAltarInfo:new();
	-- self.armCamp = VArmyCampInfo:new();
	self.baseCampInfo = VBaseCampInfo:new();
	self.laboratory = VLaboratoryInfo:new();
	self.levelUpInfos = {};
	self.farmInfos = {};
	self.effects = {};
	self.farmerCount = 0;
	self.vipFarmerCount = 0;
	self.levelFinishs = {}
end

function VManorInfo:GetBuildingLevelInfo(buildingType)
    local levelInfo = {}

	if buildingType == BUILDING_TYPE.BuildingStore then
	    levelInfo.lv = self.storeInfo.level;
	    levelInfo.nameb = "金库";
	-- elseif buildingType == BUILDING_TYPE.BuildingArmycamp then
	-- levelInfo.lv = self.armCamp.level;
 	-- levelInfo.nameb = "驻兵所";
    elseif buildingType == BUILDING_TYPE.BuildingBasecamp then
        levelInfo.lv = self.baseCampInfo.level;
        levelInfo.nameb = "庄园";
    elseif buildingType == BUILDING_TYPE.BuildingLaboratory then
        levelInfo.lv = self.laboratory.level;
        levelInfo.nameb = "研究所";
    elseif buildingType == BUILDING_TYPE.BuildingAltar then
    	levelInfo.lv = self.altarInfo.level;
    	levelInfo.nameb = "太阳神殿";
    end
    
    return levelInfo
end

function VManorInfo:enableStopHeartBeatSyn(enable)
	self.stopHeartBeatSyn = enable
end

function VManorInfo:synWithPbData(pbData, isHeartBeat, synFlag)
    if not pbData or not pbData.bi then return end;
    if isHeartBeat and self.stopHeartBeatSyn then return end;
    if pbData.bi.extend_level and self.extendLevel ~= pbData.bi.extend_level then
    	self.extendLevel = pbData.bi.extend_level;
    	self:loadFarmFiledInfo();
    end

	self.farmerCount = pbData.bi.farmer_count or 0;
	self.lab_container_count = pbData.bi.lab_container_count or 1;
	self.vipFarmerCount = pbData.bi.vip_farmer_count or 0;

	if pbData.bi.levelup_infos then
		--升级信息
		if not isHeartBeat and synFlag and synFlag == 0 then
            --非心跳，并且是全量同步
			gLog("manorInfo levelupInfo synFlag all");
			self.levelUpInfos = {};
			local iter = VDataIter();
		    while pbData.bi.levelup_infos:Travel(iter) do
		        local levelUp = iter:Data();
	        	local levelUpInfo = VLevelUpInfo:new();
		        levelUpInfo:synWithPbData(levelUp);
		        local leftTime, isPass = levelUpInfo:leftTime();
		        if leftTime > 0 and not isPass then
		        	self.levelUpInfos[levelUp.value..levelUp.type] = levelUpInfo;
		        end
		    end
		else
			for k,oldLevelUpInfo in pairs(self.levelUpInfos) do
		    	local newLevelUpInfo = nil;
		    	local iter = VDataIter();
		    	while pbData.bi.levelup_infos:Travel(iter) do
		    		local levelUp = iter:Data();
		    		if oldLevelUpInfo.upType == levelUp.type and 
		    			oldLevelUpInfo.value == levelUp.value then
		    			newLevelUpInfo = levelUp;
		    			break;
		    		end
			    end

			    if newLevelUpInfo then
			    	oldLevelUpInfo:mergeWithNew(newLevelUpInfo);
			    else
			    	oldLevelUpInfo.needCheck = true;
			    end
		    end
		    self:checkLevelUpInfo(pbData);
		end
	else
		if not isHeartBeat and synFlag and synFlag == 0 then
		else
			for k,oldLevelUpInfo in pairs(self.levelUpInfos) do
			    oldLevelUpInfo.needCheck = true;
		    end
		    self:checkLevelUpInfo(pbData);
		end
	end
	self:checkWorkingFarmer();


	--同步建筑信息
	self.baseCampInfo:synWithPbData(pbData.bi.basecamp_level, isHeartBeat);
	
    self.storeInfo:synWithPbData(pbData.bi.store_info, isHeartBeat);

    self.altarInfo:synWithPbData(pbData.bi.altar_info, isHeartBeat);
	-- self.armCamp:synWithPbData(pbData.bi.armycamp_info, isHeartBeat);
	self.laboratory:synWithPbData(pbData.bi.laboratory_info, isHeartBeat);

	if pbData.bi.farm_infos then
		local iter = VDataIter();
		while pbData.bi.farm_infos:Travel(iter) do
	        self:updateFarmInfo(iter:Data())
	    end
	end

    self.effects = {};
    if pbData.bi.effect_infos then
    	local iter = VDataIter();
    	while pbData.bi.effect_infos:Travel(iter) do
	    	table.insert(self.effects, iter:Data());
	    end
    end
end

function VManorInfo:checkLevelUpInfo(manorPbData)
	for k,levelUpInfo in pairs(self.levelUpInfos) do
		if levelUpInfo.needCheck then
			levelUpInfo.needCheck = false;
			if levelUpInfo.upType == LEVELUP_TYPE.LevelupBuilding then
				local builingType = tonumber(levelUpInfo.value);
				if builingType == BUILDING_TYPE.BuildingStore then
                    local currentLevel = manorPbData.bi.store_info.level;-- self.storeInfo.level;
					if currentLevel == levelUpInfo.level then
						self.levelUpInfos[k] = nil;
						gLog("BuildingStore finish up early");
						if gMainView then
					        gMainView:refreshBuilding(builingType, true);
					    end
					end
				elseif builingType == BUILDING_TYPE.BuildingArmycamp then
					local currentLevel = manorPbData.bi.armycamp_infos.level;-- self.armCamp.level;
					if currentLevel == levelUpInfo.level then
						self.levelUpInfos[k] = nil;
						gLog("BuildingArmycamp finish up early");
						if gMainView then
					        gMainView:refreshBuilding(builingType, true);
					    end
					end
				elseif builingType == BUILDING_TYPE.BuildingLaboratory then
					local currentLevel = manorPbData.bi.laboratory_info.level;-- self.laboratory.level;
					if currentLevel == levelUpInfo.level then
						self.levelUpInfos[k] = nil;
						gLog("BuildingLaboratory finish up early");
						if gMainView then
					        gMainView:refreshBuilding(builingType, true);
					    end
					end
				elseif builingType == BUILDING_TYPE.BuildingBasecamp then
					local currentLevel = manorPbData.bi.basecamp_level;--self.baseCampInfo.level;
					if currentLevel == levelUpInfo.level then
						self.levelUpInfos[k] = nil;
						gLog("BuildingBasecamp finish up early");
						if gMainView then
					        gMainView:refreshBuilding(builingType, true);
					    end
					end
				end
			elseif levelUpInfo.upType == LEVELUP_TYPE.LevelupPlant then
				local farmInfo = nil;
				if manorPbData.bi.farm_infos then
					local iter = VDataIter();
					while manorPbData.bi.farm_infos:Travel(iter) do
						local pbFarmInfo = iter:Data();
						if pbFarmInfo.info.bi.id == levelUpInfo.value then
							farmInfo = VFarmInfo:new();
							farmInfo:synWithPbData(pbFarmInfo);
							break;
						end
				    end
				end

				if farmInfo then
					local currentLevel = farmInfo.plantInfo.plantLevel;
					if currentLevel == levelUpInfo.level then
						self.levelUpInfos[k] = nil;
						gLog("plant finish up early");
						if gMainView then
							gMainView.manorView.farmLayer:immediatelyFinishLevelUpPlant(farmInfo);
					    end
					end
				end
			elseif levelUpInfo.upType == LEVELUP_TYPE.LevelupMonster then
                local monsterInfo = nil;
                local monsterInfos = gData.userInfo.monsterInfo.monsterInfos
                if monsterInfos then
                    for k,vMonsterInfo in pairs(monsterInfos) do
                        if vMonsterInfo.id == levelUpInfo.value then
                            monsterInfo = vMonsterInfo
                            break
                        end
                    end
                end

                if monsterInfo then
                    local currentLevel = monsterInfo.level;
                    if currentLevel == levelUpInfo.level then
                        self.levelUpInfos[k] = nil;
                        if not gView()("laboratoryDlg") then
                            self:SetLevelUpFinishNotice(monsterInfo.id, LEVELUP_TYPE.LevelupMonster)
                        end
                        gLog("monster finish up early");
                    end
                end
			end
		end
	end
end

-----------------------------------------------------------------
--field info
-----------------------------------------------------------------
function VManorInfo:loadFarmFiledInfo()
	local csvData = gData:readCsv("manor_field_point_level.csv");
    if not csvData then
    	gLog("manor_field_point_level.csv is missing");
        return
    end

    self.fieldInfo = {};
    self.nextFieldInfo = {};

    local iter = VDataIter()
    while csvData.var:Travel(iter) do
    	local item = iter:Data();
    	if item[2] == self.extendLevel then
    		local pos = cc.p(item[0], item[1]);
    		table.insert(self.fieldInfo, pos);
    	end
    	if item[2] == self.extendLevel+1 then
			local pos = cc.p(item[0], item[1]);
    		table.insert(self.nextFieldInfo, pos);
    	end
    end

    self.fieldCount = #self.fieldInfo;
    self.nextFiledCount = #self.nextFieldInfo;

    local tempTab = {};
    for i,pos in ipairs(self.fieldInfo) do
    	tempTab[pos.y] = 1;
    end
    self.defendLine = getMapCount(tempTab);

    tempTab = {}
    for i,pos in ipairs(self.nextFieldInfo) do
    	tempTab[pos.y] = 1;
    end
    self.nextDefendLine = getMapCount(tempTab);

    -- cclog("self.fieldCount = %d", self.fieldCount);
    -- cclog("self.nextFiledCount = %d", self.nextFiledCount);
    -- cclog("self.defendLine = %d", self.defendLine);
    -- cclog("self.nextDefendLine = %d", self.nextDefendLine);

    csvData = gData:readCsv("manor_field_extend_level.csv");
    if not csvData then
        gLog("manor_field_extend_level.csv is missing");
        return
    end

    local lineData = csvData:lineDataWithKey(self.extendLevel);
    if lineData then
    	self.filedMaxLevel = nil;
    	self.upBaseCampLevel = lineData[1];
    	self.levelupGold = lineData[2] or 0;
    	self.levelupCurr = lineData[3] or 0;
    	self.levelupVip = lineData[4] or 0;
    else
    	self.filedMaxLevel = true;
    	self.levelupGold = 0;
    	self.levelupCurr = 0;
    	self.levelupVip = 0;
    end
end


-----------------------------------------------------------------
--farm info
-----------------------------------------------------------------
function VManorInfo:updateFarmInfo(pbFarmInfo)
	if not pbFarmInfo then return end;

	local key = (pbFarmInfo.pos.x)..(pbFarmInfo.pos.y);
	local farmInfo = self.farmInfos[key];
	if not farmInfo then
		farmInfo = VFarmInfo:new()
	end
	farmInfo:synWithPbData(pbFarmInfo);
	local oldFarmInfo = self.farmInfos[farmInfo:ReturnKey()];
	if oldFarmInfo and oldFarmInfo.plantInfo.plantLevel and farmInfo.plantInfo.plantLevel then
		if oldFarmInfo.plantInfo.plantLevel <= farmInfo.plantInfo.plantLevel then
			self.farmInfos[farmInfo:ReturnKey()] = farmInfo;
		end	
	else
		self.farmInfos[farmInfo:ReturnKey()] = farmInfo;
	end
end

function VManorInfo:DeleteFarmInfo(farmInfo)
	self.farmInfos[farmInfo:ReturnKey()] = nil
end

function VManorInfo:createFakeFarmInfo(plantInfo, pos)
	local farmInfo = VFarmInfo:new();
	farmInfo:initFakeData(plantInfo, pos);
	self.farmInfos[farmInfo:ReturnKey()] = farmInfo;
	return farmInfo;
end

function VManorInfo:removeFarmInfo(key)
	self.farmInfos[key] = nil;
end

function VManorInfo:farmInfoWithId(id)
	for k,farmInfo in pairs(self.farmInfos) do
		if farmInfo.plantInfo.id == id then
			return farmInfo;
		end
	end
	return nil;
end

function VManorInfo:GetPlantCountWithClass(classType)
    local count = 0
    
    for k,farmInfo in pairs(self.farmInfos) do
        if farmInfo.plantInfo.classType == classType then
            count = count + 1;
        end
    end
    
    return count;
end

function VManorInfo:CheckPlantLimit(plantInfo)
    local count = 0
    for key, var in pairs(self.farmInfos) do
    	if var.plantInfo.classType == plantInfo.classType then
    	   count = count + 1
    	end
    end
    
    cclog("植物类型"..plantInfo.classType)
    if self.baseCampInfo.plantLimits[plantInfo.classType] == nil or count >= self.baseCampInfo.plantLimits[plantInfo.classType] then
        return true
    else
        return false
    end
end

-----------------------------------------------------------------
--level up info
-----------------------------------------------------------------
function VManorInfo:levelUpInfo(id, upType)
	id = tostring(id);
	local key = id..upType;
	local levelup = self.levelUpInfos[key];
	return levelup;
end

function VManorInfo:levelUpTime(id, upType)
	id = tostring(id);
	local levelUp = self:levelUpInfo(id, upType);
	if levelUp then
		return levelUp:leftTime();
	end
	return 0;
end

function VManorInfo:removeLevelUpInfo(id, upType)
	id = tostring(id);
	local key = id..upType;
    cclog("~~~~~~~~~~~~removeLevelUpInfo")
	self.levelUpInfos[key] = nil;
	self:checkWorkingFarmer();
end

function VManorInfo:setLevelUpInfo(id, upType, time, level)
	id = tostring(id);
	local levelUp = self:levelUpInfo(id, upType);
	if not levelUp then
		levelUp = VLevelUpInfo:new();
		self.levelUpInfos[id..upType] = levelUp;
	end
	levelUp.upType = upType;
	levelUp.value = id;
	levelUp.time = time;
	levelUp.level = level;

	self:checkWorkingFarmer();
end

function VManorInfo:cancelLevelUp(id, upType)
	id = tostring(id);
    cclog("cancelLevelUp~~~~~~~~~~id:"..id.."~~~~~~upType"..upType)
	local levelUp = self:levelUpInfo(id, upType);
	if levelUp then
		levelUp:cancelLevelUp();
	end
	self:checkWorkingFarmer();
end

function VManorInfo:revertCancelLevelUp(id, upType)
	id = tostring(id);
    cclog("revertCancelLevelUp~~~~~~~~~~id:"..id.."~~~~~~upType"..upType)
	local levelUp = self:levelUpInfo(id, upType);
	if levelUp then
		levelUp:revertCancelLevelUp();
	end
	self:checkWorkingFarmer();
end

function VManorInfo:SetLevelUpFinishNotice(id, upType)
    local finishInfo = {}
    finishInfo.id = id
    finishInfo.upType = upType
    self.levelFinishs[id..upType] = finishInfo
    gData.noticeManager:modify(NoticeType.finish_monster_star, 1)
end

function VManorInfo:DelLevelUpFinishNotice(id, upType)
	self.levelFinishs[id..upType] = nil
end

function VManorInfo:SetMonsterLvUpPos( id, pos )
	-- body
	local upType = LEVELUP_TYPE.LevelupMonster
	id = tostring(id);
	local levelUp = self:levelUpInfo(id, upType);
	if levelUp then
		levelUp.pos = pos;
	end
end

-----------------------------------------------------------------
--farmer count
-----------------------------------------------------------------
function VManorInfo:checkWorkingFarmer()
	local farmer = 0;
	for k,levelUp in pairs(self.levelUpInfos) do
        if levelUp.upType == LEVELUP_TYPE.LevelupPlant or
            levelUp.upType == LEVELUP_TYPE.LevelupBuilding then
			if levelUp:leftTime() > 0 then
                farmer = farmer + 1;
			end
		end
	end

	if self.workingFarmer ~= farmer then
		self.workingFarmer = farmer;
	end
	if gMainView then
		gMainView:refreshFarmerValue();
	end
end

function VManorInfo:addFarmer(count)
	self.farmerCount = self.farmerCount + count;
	-- if self.farmerCount < 0 then
	-- 	self.farmerCount = 0;
	-- end
end

function VManorInfo:idleFarmer()
	local count = self.farmerCount - self.workingFarmer;
	if count < 0 then
		count = 0;
	end
	return count;
end

function VManorInfo:farmerNextCost()
	local csv = gData:readCsv("prop_farmer.csv");
	local nextCount = (self.farmerCount - self.vipFarmerCount) + 1;
	local cost = csv:lineDataWithKey(nextCount,1);
	return cost;
end

function VManorInfo:SaveFarmNoticeInfo(parameters)
    local notices = {}
    notices.plant = {}
    local minTime = nil
    local maxTime = nil
    
    for key, var in pairs(self.farmInfos) do
        
        if not var.plantInfo.isWarPlant then
            local harvestTime, maxLeftTime = var:timeForHarvest();
            minTime = minTime or maxLeftTime
            maxTime = maxTime or maxLeftTime
            if harvestTime ~= 0 or (harvestTime == 0 and maxLeftTime ~= 0) then
                if minTime > maxLeftTime then
                    minTime = maxLeftTime
                end
                if maxTime < maxLeftTime then
                    maxTime = maxLeftTime
                end
            end
        end
    end
    
    if minTime and maxTime then
        local notice = {}
        notice.time = gData:currentTime() + maxTime
        notice.msg = "农场中所有植物产量都已达上限，请去收获"
        table.insert(notices.plant, notice)
        
        if maxTime - minTime >= 10 then 
            notice = {}
            notice.time = gData:currentTime() + minTime
            notice.msg = "农场中有植物产量已达上限，请去收获"
            table.insert(notices.plant, notice)
        end
    end

    local noticesVar = Var(notices);
    
    gSys:setLocalNotifyCheckInfo(gZoneid, gData.userInfo.userid, noticesVar:ToString())
end