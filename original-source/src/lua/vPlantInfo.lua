--vPlantInfo.lua
---------------------------------------------
--怪物强化属性
-- VIntensifyInfo = vclass("IntensifyInfo");
-- function VIntensifyInfo:synWithPbData(pbData)
--     self.id = pbData.id;
--     self.value = pbData.value;
-- end

-- function VIntensifyInfo:initFakeData(id)
--     self.id = id;
--     self.value = 0;
-- end
---------------------------------------------


VPlantInfo = vclass("PlantInfo")

-- function VPlantInfo:initFakeData(thingid)
--     self.id = "0";
--     self.thingid = thingid;
--     self.accelerateValue = 0;
--     self:loadCsvData();
-- end

function VPlantInfo:initialize()

end

function VPlantInfo:synWithPbData(pbData)
    local needUpdate = false;
    if self.thingid ~= pbData.bi.thingid then
        needUpdate = true;
    end

	self.id = pbData.bi.id;
	self.thingid = pbData.bi.thingid;
	self.accelerateValue = pbData.bi.accelerated_value;
    self.strengthenPoint = pbData.bi.strengthen_point or 0;

    local attr = pbData.bi.attr_infos;
    if attr then
        local iter = VDataIter();
        while attr:Travel(iter) do
            local attrInfo = iter:Data();
            if not self.intensifyInfo[attrInfo.id] then
                self.intensifyInfo[attrInfo.id] = VIntensifyInfo:new();
            end
            self.intensifyInfo[attrInfo.id]:synWithPbData(attrInfo);
        end
    end

    local resultInfo = pbData.bi.strengthen_infos;
    if resultInfo then
        local iter = VDataIter();
        while resultInfo:Travel(iter) do
            local ri = iter:Data();
            if not self.intensifyResultInfo[ri.id] then
                self.intensifyResultInfo[ri.id] = VIntensifyInfo:new();
            end
            self.intensifyResultInfo[ri.id]:synWithPbData(ri);
        end
    else
        self.intensifyResultInfo = {};
    end

    if needUpdate then
        self:loadCsvData();
    end
end

function VPlantInfo:loadCsvData()
    if not self.thingid then return end;
    
    self:loadBaseCsv();
    self:loadDescritionCsv();

    self.resType = self:GetPlantType()
    if self.resType == 0 then
        self.isWarPlant = true;
    end

    if not self.isWarPlant then
        self:loadProductCsv();
    end

    self:loadBattleCsv();

    self:loadDeComposeCsv();

    self:loadLvUpCsv()

    self:loadActionCsv()
    
    self:loadSkillchangeCsv()
end

function VPlantInfo.createPlantInfoById(id)
    local info = VPlantInfo:new();
    info.id = 0;
    info.thingid = id;

    info:loadBaseCsv();
    info:loadDescritionCsv();
    info.resType = info:GetPlantType()
    if info.resType == 0 then
        info.isWarPlant = true;
    end

    if not info.isWarPlant then
        info:loadProductCsv();
    end

    info:loadBattleCsv();

    info:loadDeComposeCsv();

    info:loadSkillchangeCsv();

    return info;
end

function VPlantInfo:loadBaseCsv()
    -- local plantOutCsv = gData:readCsv("prop_plant.csv");
    -- local plantOut = plantOutCsv:lineDataWithKey(self.thingid);
    -- if not plantOut then 
    --     gLog("prop_plant.csv miss ID:%d", self.thingid);
    --     return;
    -- end

    local prop_plant = gData:LoadPlantBaseCsv()

    local plantOut = prop_plant[""..self.thingid]

    if not plantOut then 
        gLog("prop_plant.csv miss ID:%d", self.thingid);
        return;
    end
    
    self.plantLevel = plantOut.level;
    self.classType = plantOut.classType;
    self.quality = plantOut.quality;
    self.sort = plantOut.sort;
    self.broadcast = plantOut.broadcast;
    self.scale = plantOut.scale;
    self.buyType = plantOut.type;
    self.buyPrice = plantOut.price;
    self.nextThingid = plantOut.nextThingid
    self.warType = plantOut.warType
end

function VPlantInfo:loadDescritionCsv(  )
    -- local descCsv = gData:readCsv("prop_plant_type.csv");
    -- local desc = descCsv:linesWithKeyRowValues(self.classType, self.quality);
    -- if not desc then 
    --     return;
    -- end

    local descCsv = gData:LoadPlantDescritionCsv()
    local desc = descCsv[self.classType..self.quality]

    self.plantName = desc.name;
    self.plantImage = desc.image;
    self.atkMode = desc.atkMode;
end

function VPlantInfo:loadProductCsv()
    -- local productCsv = gData:readCsv("plant_product.csv");
    -- local product = productCsv:lineDataWithKey(self.thingid);

    local productCsv = gData:LoadPlantProductCsv()
    local product = productCsv[""..self.thingid]

    if not product then return end;
    self.growSpeedHour = product.produceSpeed
    self.growSpeedSec = product.produceSpeed/3600;
    self.growMax = product.produceMax;     
end

function VPlantInfo:loadBattleCsv()
    -- local plantWarCsv = gData:readCsv("prop_creature_plant.csv");
    -- local plantWar = plantWarCsv:lineDataWithKey(self.thingid);

    local plantWarCsv = gData:LoadPlantBattleCsv()
    local plantWar = plantWarCsv[""..self.thingid]

    if not plantWar then
        gLog("prop_creature_plant.csv miss ID:%d", self.thingid);
        return;
    end
    self.plantLife = plantWar.hp;
    self.plantAtc = plantWar.atk;
    self.plantDef = plantWar.def;
    self.plantAspd = plantWar.aspd;
    self.atkRange = plantWar.atkRange;
    self.consume = plantWar.consume;
end

function VPlantInfo:loadDeComposeCsv()
    -- local decomposeCsv = gData:readCsv("plant_decompose.csv");
    -- local lineData = decomposeCsv:lineDataWithKey(self.thingid);
    local decomposeCsv = gData:LoadPlantDeComposeCsv()
    local lineData = decomposeCsv[""..self.thingid]

    if not lineData then
        gLog("plant_decompose.csv miss ID:%d", self.thingid);
        return;
    end
    self.decomposeInfo = {};
    self.decomposeInfo.type = lineData.type;
    self.decomposeInfo.effectId = lineData.effectId;
    self.decomposeInfo.effectValue = lineData.effectValue;
    self.decomposeInfo.description = lineData.description;
    self.decomposeInfo.limit = lineData.limit;
end

function VPlantInfo:loadLvUpCsv()
    -- body
    -- local csv = gData:readCsv("plant_levelup.csv");
    -- local lineData = csv:lineDataWithKey(self.thingid);

     local csv = gData:LoadPlantLvUpCsv()
    local lineData = csv[""..self.thingid]

    if not lineData then 
        return;
    end
    self.labLevel = lineData.levelLimit;
    self.timeCost = lineData.timeCost;
    self.action = lineData.action;

    
end

function VPlantInfo:loadActionCsv( ... )
    -- body
    -- local csv = gData:readCsv("action_effect.csv");
    -- local lineData = csv:linesWithRowValue(0, self.action);

    local csv = gData:LoadActionCsv()

    if not self.action then
        return
    end

    local lineData = csv[""..self.action]

    if not lineData then 
        return;
    end

    local count = table.getn(lineData)

    self.effect = {}

    for var=1, count do
        local effect = {}
        effect.effectType = lineData[var].effectType;
        effect.effectid = lineData[var].effectid;
        effect.effectValue = lineData[var].effectValue;
        effect.effectAddtion = lineData[var].effectAddtion
        table.insert(self.effect, effect)
    end
end

function VPlantInfo:loadSkillchangeCsv()
    -- local skillchange = gData:readCsv("plant_upstar_skillchange.csv");
    -- local skill = skillchange:lineDataWithKey(self.thingid);

    local skillchange = gData:LoadPlantSkillchangeCsv()
    local skill = skillchange[""..self.thingid]


    cclog("self.thingid"..self.thingid)
    if not skill then
        return
    end
    
    
    self.skillDesc = skill[1]
    self.plantDesc = skill[2];
end


function VPlantInfo:GetPlantType()
    -- local productCsv = gData:readCsv("plant_product.csv");
    -- local product = productCsv:lineDataWithKey(self.thingid);
    local productCsv = gData:LoadPlantProductCsv()
    local product = productCsv[""..self.thingid]
    
    if not product then 
        return 0
    else
        return product.produceType
    end
end

function VPlantInfo:levelUp()
    self.lastThingid = self.thingid;
    self.thingid = self.nextThingid;
    self:loadCsvData();
    gAudio:playEffect("sys_plant_levelup.ogg");
end

function VPlantInfo:revertLevel()
    if self.lastThingid then
        self.thingid = self.lastThingid;
        self:loadCsvData();
        self.lastThingid = nil;
    end
end

function VPlantInfo:GetGrowSpeedWithScale(vaule)
    return math.ceil(self.growSpeedHour * vaule / 100)
end

-- --获取当前强化值
-- function VPlantInfo:getAllIntensifyValue()
--     local value = 0;
--     for i,v in ipairs(self.intensifyInfo) do
--         value = value + v.value;
--     end
--     return value;
-- end




VPlantManager = vclass("PlantManager")

function VPlantManager:initialize()
	self.plants = {};
	self.newPlantCount = {}
	self.newCount = 0
end

function VPlantManager:synWithPbData(pbData)
	local infos = pbData.infos;
	local iter = VDataIter();
    while infos:Travel(iter) do
    	local exPlant = iter:Data();
    	if exPlant.ctrl.op == _VCtrlOP.None or 
    		exPlant.ctrl.op == _VCtrlOP.Rep or
    		exPlant.ctrl.op == _VCtrlOP.Add then
    		if not self.plants[exPlant.info.bi.id] then
    			self.plants[exPlant.info.bi.id] = VPlantInfo:new();
    		end
    		self.plants[exPlant.info.bi.id]:synWithPbData(exPlant.info);
    	elseif exPlant.ctrl.op == _VCtrlOP.Del then
    		self.plants[exPlant.info.bi.id] = nil;
    	end
    end
    
end

function VPlantManager:synWithOtherPbData(pbData)
    local iter = VDataIter();
    while pbData:Travel(iter) do
        local plant = iter:Data();
        if not self.plants[plant.bi.id] then
            self.plants[plant.bi.id] = VPlantInfo:new()
        end
        self.plants[plant.bi.id]:synWithPbData(plant);
    end
end

function VPlantManager:RemovePlant(id)
    self.plants[id] = nil
end

function VPlantManager:GetSortPlant(parameters)
    
 
    local plantBag = {}
    
    for key, var in pairs(self.plants) do
        table.insert(plantBag, var)
    end
    
    table.sort(plantBag,
        function(a,b)
            return a.sort < b.sort;
        end);
    
    
    return plantBag
end

function VPlantManager:InsertPlant(id, thingid, isManorPlant)
    local plant = self.plants[id];
    if not plant then
        plant = VPlantInfo:new();
        plant.accelerateValue = 0;
        self.plants[id] = plant;
    end
    plant.id = id
    plant.thingid = thingid
    plant:loadCsvData();
    
    self:AddNewPlant(id,thingid,isManorPlant)
end

function VPlantManager:AddNewPlant(id, thingid, isManorPlant)
    if not isManorPlant then
        self.newCount = self.newCount + 1

        if not self.newPlantCount[id] then
            self.newPlantCount[id] = 1
        else
            self.newPlantCount[id] = self.newPlantCount[id] + 1
        end
    end
    
    if gMainView then
        gMainView:CheckNewBagItem()
    end
end

function VPlantManager:DeleteNewItem(id)
    if self.newPlantCount[id] then
        self.newPlantCount[id] = nil
        self.newCount = self.newCount - 1
    end
end

function VPlantManager:updatePlant(id, thingid, count, isManorPlant)
    if count > 0 then
        self:InsertPlant(id, thingid, isManorPlant);
    else
        self:RemovePlant(id);
    end
end

function VPlantManager:plantWithId(id)
    return self.plants[id];
end

function VPlantManager:PlantCount()
	local count = 0;
	for k,v in pairs(self.plants) do
		count = count + 1;
	end
	return count;
end