------------------------------------------------------------------
---VMonsterInfo
VMonsterInfo = vclass("MonsterInfo");
function VMonsterInfo:initialize()
	self.id = 0;
	self.thingid = 0;
    self.reTime = 0;
end

function VMonsterInfo:synWithPbData(pbData)
    local needUpdata = false;
    if self.thingid ~= pbData.bi.thingid then
        needUpdata = true; 
    end
	self.id = pbData.bi.id;
	self.thingid = pbData.bi.thingid;
    self.reTime = pbData.bi.time or 0;
    if needUpdata then
        self:loadCsvData();
    end
end 


function VMonsterInfo:loadCsvData()
    self:loadBaseCsv();
    self:loadBattleCsv();
    self:loadDecomposeCsv();
    self:loadLvUpCsv()
    self:loadActionCsv()
    self:loadMonsterTypeCsv();
    self:loadSkillchangeCsv();
end

function VMonsterInfo:loadDecomposeCsv()
    -- local decomposeCsv = gData:readCsv("monster_decompose.csv");
    -- local decomposeLine = decomposeCsv:lineDataWithKey(self.thingid);

    local decomposeCsv = gData:LoadMonsterDeComposeCsv()

    local decomposeLine = decomposeCsv[""..self.thingid]

    if not decomposeLine then
        return;
    end
    self.decomposeInfo = {};
    self.decomposeInfo.type = decomposeLine.type;
    self.decomposeInfo.effectId = decomposeLine.effectId;
    self.decomposeInfo.effectValue = decomposeLine.effectValue;
    self.decomposeInfo.limit = decomposeLine.limit;
end

function VMonsterInfo:loadBattleCsv()
    -- local battleCsv = gData:readCsv("prop_creature_monster.csv");
    -- local battleLineData = battleCsv:lineDataWithKey(self.thingid);

    local battleCsv = gData:LoadMonsterBattleCsv()

    local battleLineData = battleCsv[""..self.thingid]

    if not battleLineData then
        return;
    end
    self.hp = battleLineData.hp;
    self.def = battleLineData.def;
    self.atk = battleLineData.atk;
    self.speed = battleLineData.speed;
    self.consume = battleLineData.consume;
    self.atkTime = battleLineData.atkTime;
    -- self.population = battleLineData.population;
    -- self.atkRange = battleLineData.atkRange;
end

function VMonsterInfo:loadBaseCsv()
    -- local csv = gData:readCsv("prop_monster.csv");
    -- local lineData = csv:lineDataWithKey(self.thingid);

    local csv = gData:LoadMonsterBaseCsv()

    local lineData = csv[""..self.thingid]


    if not lineData then 
        return;
    end
    self.monsterClass = lineData.monsterClass;
    self.level = lineData.level;
    self.nextLevelId = lineData.nextLevelId;
    self.quality = lineData.quality;
    self.broadcast = lineData.broadcast;
    self.scale = lineData.scale;
    -- self.description = lineData.description;
    self.type = lineData.type;
    self.price = lineData.price;
    self.reviveTime = lineData.reviveTime;
end

function VMonsterInfo:loadLvUpCsv()
    -- body
    -- local csv = gData:readCsv("monster_levelup.csv");
    -- local lineData = csv:lineDataWithKey(self.thingid);

    local csv = gData:LoadMonsterLvUpCsv()

    local lineData = csv[""..self.thingid]

    if not lineData then 
        return;
    end
    self.labLevel = lineData.labLevel;
    self.timeCost = lineData.timeCost;
    self.action = lineData.action;
end

function VMonsterInfo:loadActionCsv( ... )
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

function VMonsterInfo:loadMonsterTypeCsv(  )
    -- body
    -- local csv = gData:readCsv("prop_monster_type.csv");
    -- local lineData = csv:linesWithKeyRowValues(self.monsterClass, self.quality);

    local csv = gData:LoadMonsterDescritionCsv()

    local lineData = csv[self.monsterClass..self.quality]

    if not lineData then 
        return;
    end
    self.name = lineData.name;
    self.image = lineData.image;
    self.atkMode = lineData.atkMode;
end

function VMonsterInfo:loadSkillchangeCsv()
    -- local skillchange = gData:readCsv("monster_upstar_skillchange.csv");
    -- local skill = skillchange:lineDataWithKey(self.thingid);

    local skillchange = gData:LoadMonsterSkillchangeCsv()

    local skill = skillchange[""..self.thingid]

    cclog("self.thingid"..self.thingid)
    if not skill then
        return
    end


    self.skillDesc = skill[1];
    self.description = skill[2];
end

function VMonsterInfo:UpDataLevelInfo(level)
--    if level and level > self.level then
        self.lastThingid = self.thingid;
        self.thingid = self.nextLevelId
        self:loadCsvData();
        gAudio:playEffect("sys_plant_levelup.ogg");
--    end
end

function VMonsterInfo:RevertLevel(parameters)
    if self.lastThingid then
        self.thingid = self.lastThingid;
        self:loadCsvData();
        self.lastThingid = nil;
    end
end

function VMonsterInfo:LevelUpStart()
    self.isLving = true
    gData.userInfo.manorInfo:setLevelUpInfo(self.id, LEVELUP_TYPE.LevelupMonster, 
        gData:currentTime() + self.timeCost, self.level+1)
end

function VMonsterInfo:RemoveLevelUpStart()
    self.isLving = false
    gData.userInfo.manorInfo:removeLevelUpInfo(self.id, LEVELUP_TYPE.LevelupMonster)
end

function VMonsterInfo:CancelLevelUp(parameters)
    self.isLving = false
    gData.userInfo.manorInfo:cancelLevelUp(self.id, LEVELUP_TYPE.LevelupMonster)
end

function VMonsterInfo:RevertCancelLevelUp(parameters)
    self.isLving = true
    gData.userInfo.manorInfo:revertCancelLevelUp(self.id, LEVELUP_TYPE.LevelupMonster)
end

function VMonsterInfo.createMonsterInfoById(id)
    local info = VMonsterInfo:new();
    info.id = 0;
    info.thingid = id;
    info.reTime = 0;
    info:loadBaseCsv();
    info:loadBattleCsv();
    info:loadDecomposeCsv();
    info:loadMonsterTypeCsv();
    info:loadSkillchangeCsv();
    return info;
end

------------------------------------------------------------------
---VMonsterInfos

VMonsterInfos = vclass("MonsterInfos");

function VMonsterInfos:initialize()
	self.monsterInfos = {};
end

function VMonsterInfos:synWithPbData(pbData)
	local infos = pbData.infos;
	local iter = VDataIter();
    while infos:Travel(iter) do
    	local exMonsters = iter:Data();
    	if exMonsters.ctrl.op == _VCtrlOP.None or 
    		exMonsters.ctrl.op == _VCtrlOP.Rep or
    		exMonsters.ctrl.op == _VCtrlOP.Add then
    		
    		if not self.monsterInfos[exMonsters.info.bi.id] then
    			self.monsterInfos[exMonsters.info.bi.id] = VMonsterInfo:new();
    		end
    		self.monsterInfos[exMonsters.info.bi.id]:synWithPbData(exMonsters.info);
    	elseif exMonsters.ctrl.op == _VCtrlOP.Del then
    		self.monsterInfos[exMonsters.info.bi.id] = nil;
    	end
    end
end 

function VMonsterInfos:addMonster(id, thingid, count)
    if count == -1 then 
        self:removeMonster(id);
        return;
    end
    if count == 1 then
        local monster = self.monsterInfos[id];
        if not monster then
            monster = VMonsterInfo:new();
            monster.id = id;
            monster.thingid = thingid;
            monster.isNew = true;
            monster:loadCsvData();
            
            self.monsterInfos[id] = monster
        end
    end
end

function VMonsterInfos:removeMonster(id)
    self.monsterInfos[id] = nil;
end

function VMonsterInfos:GetMonsterWithid(id)
	return self.monsterInfos[id]
end

function VMonsterInfos:updateMonsterReliveTime( idMap )
    if idMap and type(idMap) == "table" then 
        for i,v in ipairs(idMap) do 
            local monster = self.monsterInfos[v];
            if monster then
                monster.reTime = gData:currentTime() + monster.reviveTime;
            else
                gLog(string.format("can not find id:%d in self monsterInfos", v));
            end
        end
    end
end

