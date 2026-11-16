--vCsvData.lua

_CSVKeyRow = {
	["manor_field_point_level.csv"] = -1,
	["buff_effect.csv"] = -1,
	["skill_effect.csv"] = -1,

	["check_in.csv"] = -1,
	["quest_condition.csv"] = -1,
	["gamebarrier_rewards.csv"] = -1,
	["plunder_score.csv"] = -1,
	["plunder_attr.csv"] = -1,
	["quest_reward.csv"] = -1,
	-- ["plant_desc.csv"] = -1,
	-- ["plant_strengthen.csv"] = -1,
	["basecamp_plantlimit.csv"] = -1,
	-- ["monster_desc.csv"] = -1,

	-- ["monster_levelup.csv"] = -1,
	["name.csv"] = -1,
--	["plant_levelup.csv"] = -1,
	["suit_attrlimit.csv"] = -1,

	["basecamp_plantlimit_vip.csv"] = -1,
	["suit_compound.csv"] = 3,
	["image_creature_rank.csv"] = -1,
	["newbie_battle_event.csv"] = -1,
	["plunder_item_num.csv"] = -1,
	["monster_compose.csv"] = -1,
	["plant_compose.csv"] = -1,
	["prop_monster_type.csv"] = -1,
	["prop_plant_type.csv"] = -1,

	["action_effect.csv"] = -1,
	["dungeon_plant_config.csv"] = -1,
	["dungeon_monster_config.csv"] = -1,
	["prop_battle.csv"] = -1,
	["prop_dance.csv"] = -1,
	["banner_roulette.csv"] = 0,
    ["item_effect.csv"] = -1,
    ["banner_race.csv"] = 0,
	["attribute_restraint.csv"] = -1,
	["banner_common.csv"] = -1,
	["banner_attr.csv"] = 0,
	["banner_level.csv"] = 0,
	["banner_attribute_relation.csv"] = -1,
	["banner_levelup.csv"] = -1,
	["banner_action_effect.csv"] = -1,
	["banner_decompose.csv"] = -1,
	["dungeon_shop.csv"] = -1,
    ["dungeon_rewards.csv"] = -1,
	["box_effect.csv"] = -1,
	["advertisement.csv"] = -1,
	["dungeon_battleTip.csv"] = -1,
	["prop_time.csv"] = -1,
	["vip_address.csv"] = -1,
}

_CSVKeyRows = {
	-- ["monster_desc.csv"] = {0, 1},
	-- ["monster_levelup.csv"] = {0, 1},
	-- ["plant_strengthen.csv"] = {0, 1},
	-- ["prop_monster.csv"] = {1, 2, 3},
	-- ["prop_plant.csv"] = {1, 2, 3},
--	["plant_levelup.csv"] = {0,1},
	["suit_attrlimit.csv"] = {0,1},
	["basecamp_plantlimit_vip.csv"] = {0,1},

	["prop_monster_type.csv"] = {0, 1},
	["prop_plant_type.csv"] = {0, 1},
	["banner_attribute_relation.csv"] = {0, 1},
	["banner_levelup.csv"] = {0, 1},
	["banner_decompose.csv"] = {0, 1},
}

VCSVData = vclass("CSVData");

function VCSVData:initialize(name)
	self.csvFileName = name;
	self:initKeyRow();
end

function VCSVData:initKeyRow()
	local keyRow = nil;
	if self.csvFileName then
		keyRow = _CSVKeyRow[self.csvFileName];
	end
	
	if not keyRow then keyRow = 0 end;
	self.keyRow = keyRow;
end

function VCSVData:buildMultipleKeys()
	local keyRows = _CSVKeyRows[self.csvFileName];
	if not keyRows then return nil end;

	self.multipleKeyList = {};
	local iter = VDataIter()
	while self.var:Travel(iter) do
		local item = iter:Data();
		local keyString = "";
		for i,row in ipairs(keyRows) do
			local value = item[self:rowName(row)];
			if value then
				keyString = keyString..value;
			end
		end

		if keyString ~= "" then
			self.multipleKeyList[keyString] = item;
		end
	end
end

function VCSVData:LoadCsvFile()
	if self.csvFileName then
		gLog("load csv %s ", self.csvFileName);
		self.var = Var();
		local ret = nil;
		local propTable = _CsvProp[self.csvFileName];
		if propTable then
			ret = self.var:FromCsvFile(self.csvFileName, self.keyRow, false, propTable);
		else
			ret = self.var:FromCsvFile(self.csvFileName, self.keyRow);
		end

		if ret then
			self:lineCount();
			self:buildMultipleKeys();
		else
			gLog("csv file %s load failed", self.csvFileName)
		end
	end
end

function VCSVData:LoadCsvString(aString)
	if aString then
		self.var = Var();
		local ret = self.var:FromCsvString(aString, self.keyRow);
		if ret then
			self:lineCount();
		else
			gLog("csv string %s load failed", aString)
		end
	end
end

--行数
function VCSVData:lineCount()
	if not self.count then self.count = self.var:Count() end;
	return self.count;
end

--查询第line行的列数, line为空,返回0
function VCSVData:rowCount(line)
    if not line then return 0 end
	local data = self:lineData(line);
	if data then
		return data:Count();
	end
	return 0;
end

--取第line行，第row列的数据，
--line为空时，返回空。
--row为空时，返回整行数据。
function VCSVData:lineData(line, row)
    if not line then return nil end
	local data = nil;
	if self.keyRow == -1 then
		if line < self.count then
			data = self.var[line];
		else
			gLog("can not find the line \"%d\" in CSV \"%s\"!", line, self.csvFileName);
		end
	else
		if line < self.count then
			data = self.var:ObjectData(line);
		else
			gLog("can not find the line \"%d\" in CSV \"%s\"!", line, self.csvFileName);
		end
	end

	if row and data then
		local count = data:Count();
		if row < count then
			return data[self:rowName(row)];
		else
			gLog("can not find the line \"%d\" at row \"%d\" in CSV \"%s\"!", line, row, self.csvFileName);
			return nil;
		end
	end
	return data;
end

--返回关键列中 值 等于key的数据，限于keyRow~=-1的情况。
--row为空，返回整行数据。
function VCSVData:lineDataWithKey(key, row)
	if self.keyRow == -1 then return nil end;
	key = tostring(key);

	local data = nil;
	data = self.var:GetByName(key);
	if row and data then
		local count = data:Count();
		if row < count then
			return data[self:rowName(row)];
		else
			gLog("can not find the key \"%s\" at row \"%d\" in CSV \"%s\"!", key, row, self.csvFileName);
			return nil;
		end
	end
	if not data then
		gLog("can not find the key \"%s\" in CSV \"%s\"!", key, self.csvFileName);
	end
	return data;
end

--返回所有数据
function VCSVData:allData()
	local data = {};
	local iter = VDataIter()
    while self.var:Travel(iter) do
    	local item = iter:Data();
    	if item then
    		table.insert(data, item);
    	end
    end
    return data;
end

--返回第keyRow列中 所有 等于 keyValue的行数据。
function VCSVData:linesWithRowValue(keyRow, keyValue)
	local data = {};
	local iter = VDataIter()
    while self.var:Travel(iter) do
    	local item = iter:Data();
    	if item and item[self:rowName(keyRow)] == keyValue then
			table.insert(data, item);
    	end
    end
    return data;
end

--返回第keyRow列的 所有值。含重复
function VCSVData:rowsWithkeyRow(keyRow)
	local data = {};
	local iter = VDataIter()
    while self.var:Travel(iter) do
    	local item = iter:Data();
    	if item and item[self:rowName(keyRow)] then
			table.insert(data, item[self:rowName(keyRow)]);
    	end
    end
    return data;
end

--返回第keyRow列的 所有值。不重复
function VCSVData:unionRowsWithKeyRow(keyRow)
	local data = {};
	local tempKey = {};
	local iter = VDataIter()
    while self.var:Travel(iter) do
    	local item = iter:Data();
    	local value = item[self:rowName(keyRow)];
    	if item and value then
    		if not tempKey[value] then
    			table.insert(data, value);
    			tempKey[value] = true;
    		end
    	end
    end
    tempKey = nil;
    return data;
end

--返回多关键列的数据。限于_CSVKeyRows中指明的表
--参数为顺序的关键列 的 值。
function VCSVData:linesWithKeyRowValues(...)
	if not self.multipleKeyList then return nil end;
	
	local args = {...}
	local keyString = ""
	for i,v in ipairs(args) do
		keyString = keyString..v;
	end
	return self.multipleKeyList[keyString];
end

--返回列对应的属性名，若无，则返回列号。
function VCSVData:rowName(row)
	local propTable = _CsvProp[self.csvFileName];
	if propTable then
		local propName = propTable[row+1];
		if propName then
			return propName;
		end
	end
	return row;
end

_Csvprop_plant = {
    [1] = "thingid",
    [2] = "classType",
    [3] = "level",
    [4] = "nextThingid",
    [5] = "quality",
    [6] = "broadcast",
    [7] = "scale",
    [8] = "sort",
    [9] = "description",
    [10] = "warType",
}


_Csvplant_product = {
    [1] = "thingid",
    [2] = "produceSpeed",
    [3] = "produceMax",
    [4] = "produceType",
}

_CsvProp_plant_type = {
    [1] = "classType",
    [2] = "quality",
    [3] = "name",
    [4] = "image",
    [5] = "description",
    [6] = "atkMode",
}


_Csvplant_levelup = {
    [1] = "thingid",
    [2] = "levelLimit",
    [3] = "timeCost",
    [4] = "action",
}

_Csvitem_common = {    
    [1] = "shopRefreshTime",
    [2] = "retResScale",
    [3] = "buildSpe",
    [4] = "plantSpe",
    [5] = "monsterSpe",
    [6] = "diamondRatio1",
    [7] = "diamondRatio2",
    [8] = "nickCost",
    [9] = "worldChatCost",
    [10] = "reviveWaterTime",
    [11] = "reviveWaterid",
    [12] = "plantSpeTime",
    [13] = "bagSize",
    [14] = "bagExraSize",
    [15] = "plantCardLimit",
    [16] = "monsterCardLimit",
    [17] = "bagSizeTip",
}
_CsvProp_baseCamp = {
	[1] = "level",
	[2] = "userLevelLimit",
	[3] = "upgradeCoin",
	[4] = "upgradeSunshine",
	[5] = "upgradeTime",
	[6] = "userExp",
}


--太阳神殿
_CsvProp_store = {
    [1] = "level",
    [2] = "baseCampLimit",
    [3] = "upgradeCoin",
    [4] = "upgradeSunshine",
    [5] = "upgradeTime",
    [6] = "sunshineMax",
    [7] = "coinMax",
}


_CsvProp_creature_monster = {
	[1] = "id",						-- 僵尸ID
	[2] = "name",					-- 名称
	[3] = "length",					-- 长度（1-20）（1大格为10，这里是占位信息）
	[4] = "height",					-- 高度（具体规则待定）
	[5] = "hp",						-- 血量
	[6] = "atk",						-- 攻击
	[7] = "def",						-- 防御
	[8] = "speed",					-- 移动速度（移动速度值=参数*速度）
	[9] = "moveType",			-- 移动类型(1 地 2 空 3 空地）
	[10] = "moveAI",				-- 移动AI
	[11] = "atkTime",				-- 攻击间隔（毫秒）
	[12] = "beforeShake",			-- 攻击前摇（毫秒）
	[13] = "afterShake",			-- 攻击后摇（毫秒）
	[14] = "atkType",				-- 攻击类型（1 地 2 空 3 两者 4 地表）（多系相加）
	[15] = "atkAI",					-- 攻击AI
	[16] = "bullet",					-- 子弹（bullet_prop）
	[17] = "atkRange",				-- 攻击范围（从最靠前点开始，近身为1）
	[18] = "damageType",			-- 攻击类型（1平射、2抛射、3陷阱、4肉搏、5爆破）
	[19] = "damageRace",			-- 伤害类型（1物理、2元素、3神圣、4化学）
	[20] = "skill",					-- 技能
	[21] = "firstTime",				-- 首次释放时间（秒）
	[22] = "skillCD",				-- 技能CD（毫秒）
	[23] = "skillCount",				-- 技能释放次数
	[24] = "skillAI",					-- 技能AI
	[25] = "modle",					-- 模型（0.生物1.物体）
	[26] = "consume",				-- 战场消耗阳光
	[27] = "shield",					-- 盾牌
	[28] = "helmet",				-- 头盔
	[29] = "shoes",					-- 鞋子
	[30] = "hardSkin",				-- 石肤
	[31] = "explosionProof",		-- 防爆
	[32] = "sunshineSpeed",		-- 资源植物 阳光速率(小偷 攻击次数）
	[33] = "sunshineValue",		-- 阳光数值
	[34] = "combat",				-- 战斗力
	[35] = "block",					-- 是否被补种的植物阻挡（0不阻挡，1阻挡）
}

_Csvprop_creature_plant = {
	[1] = "id",						-- 植物ID
	[2] = "name",					-- 名称
	[3] = "length",					-- 长度（1-20）（1大格为10，这里是占位信息）
	[4] = "height",					-- 高度（具体规则待定）
	[5] = "hp",						-- 血量
	[6] = "atk",						-- 攻击
	[7] = "def",						-- 防御
	[8] = "speed",					-- 移动速度（移动速度值=参数*速度）
	[9] = "moveType",			-- 移动类型(1 地 2 空 3 空地）
	[10] = "moveAI",				-- 移动AI
	[11] = "aspd",					-- 攻速值（攻速系数/攻击间隔）
	[12] = "beforeShake",			-- 攻击前摇（毫秒）
	[13] = "afterShake",			-- 攻击后摇（毫秒）
	[14] = "atkType",				-- 攻击类型（1 地 2 空 3 两者 4 地表）（多系相加）
	[15] = "atkAI",					-- 攻击AI
	[16] = "bullet",					-- 子弹（bullet_prop）
	[17] = "atkRange",				-- 攻击范围（从最靠前点开始，近身为1）
	[18] = "damageType",			-- 攻击类型（平射、抛射、陷阱、肉搏）
	[19] = "damageRace",			-- 伤害类型（物理、元素、神圣、化学）
	[20] = "skill",					-- 技能
	[21] = "firstTime",				-- 首次释放时间（秒）
	[22] = "skillCD",				-- 技能CD（毫秒）
	[23] = "skillCount",				-- 技能释放次数
	[24] = "skillAI",					-- 技能AI
	[25] = "modle",					-- 模型（0.生物1.物体）
	[26] = "shield",					-- 盾牌
	[27] = "helmet",				-- 头盔
	[28] = "shoes",					-- 鞋子
	[29] = "hardSkin",				-- 石肤
	[30] = "explosionProof",		-- 防爆	
	[31] = "consume",				-- 战场消耗阳光
	[32] = "sunshineSpeed",		-- 资源植物 阳光速率(小偷 攻击次数）
	[33] = "sunshineValue",		-- 阳光数值
	[34] = "combat",				-- 战斗力
}

_CsvProp_object = {
	[1] = "id",						-- 物体ID
	[2] = "name",					-- 名称
	[3] = "length",					-- 长度（1-20）（1大格为10，这里是占位信息）
	[4] = "atk",						-- 攻击
	[5] = "atkAI",					-- 攻击AI
	[6] = "atkTime",				-- 攻击间隔（毫秒）
	[7] = "beforeShake",			-- 攻击前摇（毫秒）
	[8] = "afterShake",				-- 攻击后摇（毫秒）
	[9] = "atkType",				-- 攻击类型（1 地 2 空 3 两者 4 地表）（多系相加）
	[10] = "atkRange",				-- 攻击范围（从最靠前点开始，近身为1）
	[11] = "skill",					-- 技能
	[12] = "firstTime",				-- 首次释放时间（秒）
	[13] = "skillCD",				-- 技能CD（毫秒）
	[14] = "skillCount",				-- 技能释放次数
	[15] = "modle",					-- 模型（0.生物1.物体2.死亡后放技能的生物）
	[16] = "skillAI",					-- 技能AI
	[17] = "image",					-- 图片
}

_CsvProp_monster = {
	[1] = "id",
	[2] = "monsterClass",
	[3] = "level",
	[4] = "nextLevelId",
	[5] = "quality",
	[6] = "broadcast",
	[7] = "scale",
	[8] = "description",
	[9] = "reviveTime",
}

_CsvProp_monster_type = {
	[1] = "monsterType",
	[2] = "quality",
	[3] = "name",
	[4] = "image",
	[5] = "description",
	[6] = "atkMode",
}

_Csvmonster_levelup = {
	[1] = "thingid",
    [2] = "labLevel",
    [3] = "timeCost",
    [4] = "action",
}

_Csvprop_laboratory = {
	[1] = "level",
    [2] = "baseCampLimit",
    [3] = "upgradeCoin",
    [4] = "upgradeSunshine",
    [5] = "upgradeTime",
    [6] = "monsterLimit"
}

_Csvsuit_attrlimit = {
    [1] = "thingid",
    [2] = "quality",
    [3] = "name",
    [4] = "maxHp",
    [5] = "maxAtc",
    [6] = "maxDef",
    [7] = "maxSpeed",
}

_Csvprop_trainning = {
    [1] = "id",
    [2] = "limitid",
    [3] = "limitLevel",
    [4] = "limitRes1",
    [5] = "resCount1",
    [6] = "limitRes2",
    [7] = "resCount2",
    [8] = "otherLimit",
    [9] = "place",
    [10] = "farmx",
    [11] = "farmy",
    [12] = "scale",
    [13] = "dafuPlace",
    [14] = "dafuText",
    [15] = "corpsePlace",
    [16] = "corpseText",
    [17] = "retiveArea",
    [18] = "x",
    [19] = "y",
    [20] = "width",
    [21] = "height",
    [22] = "btName",
    [23] = "arrow",
    [24] = "save",
    [25] = "action",
}

_Csvmonster_decompose = 
{
	[1] = "id",
	[2] = "type",
	[3] = "effectId",
	[4] = "effectValue",
	[5] = "description",
	[6] = "limit"
}

_Csvmonster_compose = {
	[1] = "mid",
	[2] = "type",
	[3] = "effectId",
	[4] = "effectValue",
	[5] = "effectAddtion";
}

_Csvplant_compose = {
	[1] = "pid",
	[2] = "type",
	[3] = "effectId",
	[4] = "effectValue",
	[5] = "effectAddtion";
}

_Csvplant_decompose = {
	[1] = "id",
	[2] = "type",
	[3] = "effectId",
	[4] = "effectValue",
	[5] = "description",
	[6] = "limit",
}

_Csvaction_effect = {
	[1] = "id",
	[2] = "effectType",
	[3] = "effectid",
	[4] = "effectValue",
	[5] = "effectAddtion",
}

_Csvbox_effect = {
	[1] = "id",
	[2] = "count",
	[3] = "effectType",
	[4] = "effectId",
	[5] = "effectCount",
	[6] = "probability",
	[7] = "nextProbability",
}

_CsvUser_common = {
	[1] = "refreshCost",
	[2] = "refreshTime",
	[3] = "storeLimit",
	[4] = "friendLimit",
	[5] = "enemyLimit",
	[6] = "eventOpen",
}

_CsvProp_item = {
    [1] = "id",
    [2] = "name",
    [3] = "image",
    [4] = "coutLimit",
    [5] = "serverResType",
    [6] = "isUse",
    [7] = "clientResType",
    [8] = "sellType",
    [9] = "sell",
    [10] = "costType",
    [11] = "cost",
    [12] = "desc",
    [13] = "quality",
    [14] = "isBroadcast",
    [15] = "levelLimit",
    [16] = "sort",
    [17] = "isShow",
}

--活动相关
_CsvProp_activity = {
	[1] = "id",
	[2] = "type",
	[3] = "timeSchema",
	[4] = "image",
	[5] = "sequence",
	[6] = "url",
	[7] = "propTimeId",
	[8] = "nameImage",
	[9] = "cost",
	[10] = "desc",
	[11] = "minVip"
}

--战旗相关
_CsvProp_banner_roulette = {
	[1] = "id",
	[2] = "costType",
	[3] = "costId",
	[4] = "costAmount",
}

_CsvBanner_race = {
	[1] = "id",
	[2] = "image",
	[3] = "name",
	[4] = "raceType",
}

_CsvBanner_common = {
	[1] = "openLevel",
	[2] = "maxBanners",
}

_CsvBanner_attr = {
	[1] = "id",
	[2] = "name",
}

_CscBanner_level = {
	[1] = "level",
	[2] = "addition"
}


_CsvBanner_attribute_relation = {
	[1] = "attr",
	[2] = "atkOrDef",
	[3] = "restrain1",
	[4] = "restrainExt1",
	[5] = "star1",
	[6] = "restrain2",
	[7] = "restrainExt2",
	[8] = "star2",
	[9] = "restrain3",
	[10] = "restrainExt3",
	[11] = "star3",
}

_CsvBanner_levelup = {
	[1] = "attr",
	[2] = "levelTo",
	[3] = "costScheme",
}

_CsvBanner_action_effect = {
	[1] = "scheme",
	[2] = "eType",
	[3] = "eId",
	[4] = "eCount",
}

_CsvBanner_decompose = {
	[1] = "id",
	[2] = "level",
	[3] = "gainScheme",
}


_CsvProp_altar = {
    [1] = "level",
    [2] = "upgradeCoin",
    [3] = "upgradeSunshine",
    [4] = "upgradeTime",
    [5] = "sunshinePeriod",
    [6] = "sunshineCount",
    [7] = "darkSunshinePeriod",
    [8] = "darkSunshineCount",
	[9] = "baseCampLimit",
}

_Csv_Advertisement = {
	[1] = "id",
	[2] = "sortLevel",
	[3] = "itemType",
	[4] = "itemid",
	[5] = "firstTip",
	[6] = "secondTip",
	[7] = "canClick",
}

_CsvProp_lab_container = {
	[1] = "pos",
	[2] = "cost",
}
_CsvProp = {
	["prop_plant.csv"] = _Csvprop_plant,

	["plant_product.csv"] = _Csvplant_product,
	["prop_creature_plant.csv"] = _Csvprop_creature_plant,
	["prop_plant_type.csv"] = _CsvProp_plant_type,
	["plant_levelup.csv"] = _Csvplant_levelup,
	["item_common.csv"] = _Csvitem_common,
	["prop_basecamp.csv"] = _CsvProp_baseCamp,

	["prop_creature_monster.csv"] = _CsvProp_creature_monster,
	["prop_monster.csv"] = _CsvProp_monster,

	["monster_levelup.csv"] = _Csvmonster_levelup,
	["prop_laboratory.csv"] = _Csvprop_laboratory,
	["suit_attrlimit.csv"] = _Csvsuit_attrlimit,
	["prop_trainning.csv"] = _Csvprop_trainning,

	["monster_decompose.csv"] = _Csvmonster_decompose,
	["monster_compose.csv"] = _Csvmonster_compose,
	["prop_store.csv"] = _CsvProp_store,
	["plant_compose.csv"] = _Csvplant_compose,
	["plant_decompose.csv"] = _Csvplant_decompose,
	["prop_monster_type.csv"] = _CsvProp_monster_type,
	["box_effect.csv"] = _Csvbox_effect,
	["action_effect.csv"] = _Csvaction_effect,
	["prop_object.csv"] = _CsvProp_object,
	["user_common.csv"] = _CsvUser_common,
    ["prop_item.csv"] = _CsvProp_item,
	["prop_activity.csv"] = _CsvProp_activity,
	["banner_roulette.csv"] = _CsvProp_banner_roulette,
    ["prop_altar.csv"] = _CsvProp_altar,
    ["banner_race.csv"] = _CsvBanner_race,
    ["banner_common.csv"] = _CsvBanner_common,
    ["banner_attr.csv"] = _CsvBanner_attr,
    ["banner_level.csv"] = _CscBanner_level,
    ["banner_attribute_relation.csv"] = _CsvBanner_attribute_relation,
    ["banner_levelup.csv"] = _CsvBanner_levelup,
    ["banner_action_effect.csv"] = _CsvBanner_action_effect,
    ["banner_decompose.csv"] = _CsvBanner_decompose,
    ["advertisement.csv"] = _Csv_Advertisement,
    ["prop_lab_container.csv"] = _CsvProp_lab_container,
}











