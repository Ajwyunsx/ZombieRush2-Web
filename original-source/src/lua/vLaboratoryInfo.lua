VLaboratoryInfo = vclass("LaboratoryInfo")

function VLaboratoryInfo:initialize()
	self.level = 1;
end

function VLaboratoryInfo:synWithPbData(pbData)
	if pbData then
		if self.level <= pbData.level then
			self.level = pbData.level;
			self:loadCsvData();
		end
	end
end

function VLaboratoryInfo:loadCsvData()
	local csv = gData:readCsv("prop_laboratory.csv");
	local lineData = csv:lineDataWithKey(self.level);
	if not lineData then
		return
	end
	local nextLevelData = csv:lineDataWithKey(self.level+1);
	self.baseCampLimit = lineData.baseCampLimit;
	self.upgradeCoin = lineData.upgradeCoin;
	self.upgradeSunshine = lineData.upgradeSunshine;
	self.upgradeTime = lineData.upgradeTime;
	self.userExp = lineData.userExp;
	self.monsterLimit = lineData.monsterLimit

	if nextLevelData then
		self.nextLevel = self.level + 1;
		self.nextMonsterLimit = nextLevelData.monsterLimit;
		self.canUpgrade = true;
	else
		self.canUpgrade = false;
	end
end

function VLaboratoryInfo:revertLevelUp()
	gData.userInfo.manorInfo:removeLevelUpInfo(BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding);
end

function VLaboratoryInfo:levelUp()
	local time = gData:currentTime() + self.upgradeTime;
    gData.userInfo.manorInfo:setLevelUpInfo(BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding, time, self.nextLevel);

    gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
    gData:enableStopUserSyn(true);

    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, -self.upgradeSunshine);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, -self.upgradeCoin);
end

function VLaboratoryInfo:levelUpFinish(isSelf)
	local levelUpInfo = gData.userInfo.manorInfo:levelUpInfo(BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding);
	if levelUpInfo then
		if self.level < levelUpInfo.level then
			self.level = levelUpInfo.level;
			self:loadCsvData();
		end
	end
	gData.userInfo.manorInfo:removeLevelUpInfo(BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding);
	gAudio:playEffect("levelup_laboratory.ogg");
end

function VLaboratoryInfo:revertLevelUpFinish(isSelf)
	self.level = self.level - 1;
	self:loadCsvData();
	if isSelf then 
		-- gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeExp, -self.userExp);
	end
end