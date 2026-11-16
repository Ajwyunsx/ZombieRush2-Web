--vAltarInfo.lua
VAltarInfo = vclass("AltarInfo")

function VAltarInfo:initialize()
    self.level = 0;
    self.upgradeCoin = 0;
    self.upgradeSunshine = 0;
    self.upgradeTime = 0;
    self.sunshinePeriod = 0;
    self.sunshineCount = 0;
    self.darkSunshinePeriod = 0;
    self.darkSunshineCount = 0;
end

function VAltarInfo:synWithPbData(pbData)
    -- if not pbData then return end;
    -- if self.level < pbData.level then
    --     self.level = pbData.level;
    -- end
    if pbData then
        if self.level < pbData.level then
            self.level = pbData.level;
        end
    end

    self:loadCsvData();
end

function VAltarInfo:setLevel(level)
    if self.level ~= level then
        self.level = level;
        self:loadCsvData();
    end
end

function VAltarInfo:loadCsvData()
	local csv_pa = gData:readCsv("prop_altar.csv");
    local info_pa = csv_pa:lineDataWithKey(self.level);
    local info_pa_next = csv_pa:lineDataWithKey(self.level + 1);
    if info_pa then
        self.baseCampLimit = info_pa.baseCampLimit;
        self.upgradeCoin = info_pa.upgradeCoin;
        self.upgradeSunshine = info_pa.upgradeSunshine;
        self.upgradeTime = info_pa.upgradeTime;
        self.sunshinePeriod = info_pa.sunshinePeriod;
        self.sunshineCount = info_pa.sunshineCount;
        self.darkSunshinePeriod = info_pa.darkSunshinePeriod;
        self.darkSunshineCount = info_pa.darkSunshineCount;
    end

    if info_pa_next then
        self.nextLevel = self.level + 1;
        self.canUpgrade = true;
        self.nextSunshinePeriod = info_pa_next.sunshinePeriod;
        self.nextSunshineCount = info_pa_next.sunshineCount;
        self.nextDarkSunshinePeriod = info_pa_next.darkSunshinePeriod;
        self.nextDarkSunshineCount = info_pa_next.darkSunshineCount;
    else
        self.canUpgrade = false;
    end
end

function VAltarInfo:levelUp()
    local time = gData:currentTime() + self.upgradeTime;
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, -self.upgradeSunshine);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, -self.upgradeCoin);

    gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
    gData:enableStopUserSyn(true);

    gData.userInfo.manorInfo:setLevelUpInfo(BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding, time, self.nextLevel);
end

function VAltarInfo:levelUpFinish(isSelf)

    local levelUpInfo = gData.userInfo.manorInfo:levelUpInfo(BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
    if levelUpInfo then
        if self.level < levelUpInfo.level then
            self.level = levelUpInfo.level;
            self:loadCsvData();
        end
    end
    gData.userInfo.manorInfo:removeLevelUpInfo(BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
    gAudio:playEffect("levelup_armycamp.ogg");
end

function VAltarInfo:revertLevelUpFinish(isSelf)
    self.level = self.level - 1;
    self:loadCsvData();
end

function VAltarInfo:revertLevelUp()
    gData.userInfo.manorInfo:removeLevelUpInfo(BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, self.upgradeSunshine);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, self.upgradeCoin);
end