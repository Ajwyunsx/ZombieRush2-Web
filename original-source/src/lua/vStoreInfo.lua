VStoreInfo = vclass("StoreInfo")

function VStoreInfo:initialize()
    self.level = 0;
    self.baseCampLimit = 10;
    self.upgradeCoin = 0;
    self.upgradeSunshine = 0;
    self.upgradeTime = 0;
    self.sunshineMax = 0;
    self.coinMax = 0;
end

function VStoreInfo:synWithPbData(pbData)
    if not pbData then return end;
    if self.level < pbData.level then
        self.level = pbData.level;
    end
    
    self:Init();
end

function VStoreInfo:Init()
    self:loadCsvData();
end

function VStoreInfo:loadCsvData()
    local csv_pa = gData:readCsv("prop_store.csv");
    local info_pa = csv_pa:lineDataWithKey(self.level);
    local info_pa_next = csv_pa:lineDataWithKey(self.level + 1);
    if info_pa then
        self.baseCampLimit = info_pa.baseCampLimit;
        self.upgradeCoin = info_pa.upgradeCoin;
        self.upgradeSunshine = info_pa.upgradeSunshine;
        self.upgradeTime = info_pa.upgradeTime;
        self.sunshineMax = info_pa.sunshineMax;
        self.coinMax = info_pa.coinMax;
    end

    if info_pa_next then
        self.nextLevel = self.level + 1;
        self.canUpgrade = true;
        self.nextSunshineMax = info_pa_next.sunshineMax;
        self.nextCoinMax = info_pa_next.coinMax;
    else
        self.canUpgrade = false;
    end
end

function VStoreInfo:levelUp()
    local time = gData:currentTime() + self.upgradeTime;
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, -self.upgradeSunshine);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, -self.upgradeCoin);

    gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
    gData:enableStopUserSyn(true);

    gData.userInfo.manorInfo:setLevelUpInfo(BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding, time, self.nextLevel);
end

function VStoreInfo:levelUpFinish(isSelf)
    local levelUpInfo = gData.userInfo.manorInfo:levelUpInfo(BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
    if levelUpInfo then
        if self.level < levelUpInfo.level then
            self.level = levelUpInfo.level;
            self:loadCsvData();
        end
    end
    gData.userInfo.manorInfo:removeLevelUpInfo(BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
    gAudio:playEffect("levelup_armycamp.ogg");
end

function VStoreInfo:revertLevelUpFinish(isSelf)
    self.level = self.level - 1;
    self:loadCsvData();
end

function VStoreInfo:revertLevelUp()
    gData.userInfo.manorInfo:removeLevelUpInfo(BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, self.upgradeSunshine);
    gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, self.upgradeCoin);
end