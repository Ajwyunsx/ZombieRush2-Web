--vBattleInfo.lua

------------------------------------------------

VBattleRace = vclass("BattleRace")

function VBattleRace:initialize( unitProp, isAttack )
	self.unitCount = 0;
	self.basicProp = {};
	self.childUnit = {};
	self.childCount = {};
	self.unitLevel = {};

	if isAttack then
		local monsterTypeCsv = gData:readCsv("prop_monster_type.csv");
		local monsterTypeData = monsterTypeCsv:linesWithKeyRowValues(unitProp.classType, 1);

		self.basicProp.classType = unitProp.classType;
		self.basicProp.name = monsterTypeData.name;
		self.basicProp.image = monsterTypeData.image;
	else
		local plantTypeCsv = gData:readCsv("prop_plant_type.csv");
		local plantTypeData = plantTypeCsv:linesWithKeyRowValues(unitProp.classType, 1);

		self.basicProp.classType = unitProp.classType;
		self.basicProp.name = plantTypeData.name;
		self.basicProp.image = plantTypeData.image;
	end
end

function VBattleRace:addChildUnit( unitProp )
	if not self.childCount[unitProp.quality] then
		self.childCount[unitProp.quality] = 0;
		self.unitLevel[unitProp.quality] = {};
		table.insert(self.childUnit, unitProp);
	end
	table.insert(self.unitLevel[unitProp.quality], unitProp.level);
	self.childCount[unitProp.quality] = self.childCount[unitProp.quality] + 1;
	self.unitCount = self.unitCount + 1;
end

function VBattleRace:sortChildUnit( )
	if self.childUnit then
		table.sort(self.childUnit,
			function(a,b)
				if a.quality == b.quality then
					return a.level < b.level;
				else
					return a.quality < b.quality;
				end
			end);
	end
	for k,v in pairs(self.unitLevel) do
		table.sort(v,
			function (a,b)
				return a < b;
			end	);
	end
end

------------------------------------------------

VBattleCreature = vclass("BattleCreature")

function VBattleCreature:synWithPlantPbData(pbData)
	self.id = pbData.id;
	self.plantid = tostring(pbData.plantid);
	self.road = pbData.road;
	self.pos = pbData.pos;
	self.propid = pbData.propid;
	self.prop = gData:getBriefPlantCsvData(self.propid);

	self.keyValueInfos = {};
	if pbData.infos then
		local iter = VDataIter();
		while pbData.infos:Travel(iter) do
			local keyValue = iter:Data();
			self.keyValueInfos[keyValue.key] = keyValue.value;
		end
	end

	self.attrValueInfos = {};
	-- if pbData.attrs then
	-- 	local iter = VDataIter();
	-- 	while pbData.attrs:Travel(iter) do
	-- 		local attrValue = iter:Data();
	-- 		self.attrValueInfos[attrValue.id] = attrValue.value;
	-- 	end
	-- end
	
	if pbData.kill_ret then
		self.kill_ret = VReturnInfo:new();
		self.kill_ret:synWithPbData(pbData.kill_ret);
	end
	if pbData.die_ret then
		self.die_ret = VReturnInfo:new();
		self.die_ret:synWithPbData(pbData.die_ret);
	end
end

function VBattleCreature:synWithMonsterPbData( pbData )
	self.id = tostring(pbData.id);
	self.propid = pbData.propid;
	self.prop = gData:getBriefMonsterCsvData(self.propid);

	if pbData.kill_ret then
		self.kill_ret = VReturnInfo:new();
		self.kill_ret:synWithPbData(pbData.kill_ret);
	end
	if pbData.die_ret then
		self.die_ret = VReturnInfo:new();
		self.die_ret:synWithPbData(pbData.die_ret);
	end
end

function VBattleCreature:sysWithFarmPbData( pbData )
	self.id = pbData.info.bi.id;
	self.road = pbData.pos.y;
	self.pos = pbData.pos.x;
	self.propid = pbData.info.bi.thingid;
	self.keyValueInfos = {};
	self.attrValueInfos = {};

	self.prop = gData:getBriefPlantCsvData(self.propid);
end

function VBattleCreature:initWithEventData( battleEvent )
	self.id = battleEvent.params2[1];
	self.propid = battleEvent.propid;
	self.prop = gData:getBriefMonsterCsvData(self.propid);
end

function VBattleCreature:initWithVMonsterInfo( vMonsterInfo )
	self.id = tostring(vMonsterInfo.id);
	self.propid = vMonsterInfo.thingid;
	self.prop = gData:getBriefMonsterCsvData(self.propid);
end

function VBattleCreature:initWithFarmInfo( farmInfo, index )
	self.id = index;
	self.plantid = farmInfo.plantInfo.id;
	self.road = farmInfo.pos.y;
	self.pos = farmInfo.pos.x;
	self.propid = farmInfo.plantInfo.thingid;
	self.keyValueInfos = {};
	self.attrValueInfos = {};

	self.prop = gData:getBriefPlantCsvData(self.propid);
end

function VBattleCreature:initWithPlantInfo( plantInfo, index )
	self.id = index;
	self.plantid = plantInfo.id;
	self.road = 0;
	self.pos = 0;
	self.propid = plantInfo.thingid;
	self.keyValueInfos = {};
	self.attrValueInfos = {};
	self.prop = gData:getBriefPlantCsvData(self.propid);
end

function VBattleCreature:initWithCsvData( csvData, index )
	self.id = index;
	self.plantid = self.id;
	self.road = csvData[2];
	self.pos = csvData[1];
	self.propid = csvData[3];
	self.keyValueInfos = {};
	self.attrValueInfos = {};
end

function VBattleCreature:initWithVFarmInfo( indexId, vfarmInfo )
	self.id = indexId;
	self.road = vfarmInfo.pos.y;
	self.pos = vfarmInfo.pos.x;
	self.propid = vfarmInfo.plantInfo.thingid;
	self.keyValueInfos = nil;

	self.attrValueInfos = {};
	for k,v in pairs(vfarmInfo.plantInfo.intensifyInfo) do
		-- self.attrValueInfos[v.id] = v.value;
	end
end

function VBattleCreature:initWithSupport( id, index, isAttack )
	self.id = index;
	self.plantid = self.id;
	self.propid = id;
	if isAttack then
		self.prop = gData:getBriefMonsterCsvData(self.propid);
	else
		self.prop = gData:getBriefPlantCsvData(self.propid);
	end
end

function VBattleCreature:getResource( type )
	if self.keyValueInfos[type] then
		return self.keyValueInfos[type];
	else
		return 0;
	end
end

------------------------------------------------
EBattlePlayType = {
	PlayObserve = 0,
	PlayAttack = 1,
	PlayReplay = 2,
}

VBattleInfo = vclass("BattleInfo")

function VBattleInfo:initialize(pbData)
	if pbData then
		self:synWithPbData(pbData);
	end
end

function VBattleInfo:synWithPbData(pbData)
	if pbData.bi then
		pbData.info = pbData.bi;				-- 关卡返回bi
	end
	if pbData.battle_info then
		pbData.info = pbData.battle_info;		-- 团战返回battle_info
	end
	if not pbData.info then return end;

	self.playType = EBattlePlayType.PlayAttack;
	self.attackType = pbData.info.type;								-- 战斗类型
	self.groupBattleId = pbData.info.group_battle;						-- 团战id
	if self.attackType == BattleType.BattleTypeEvp then
		self.stars = 3;
	else
		self.stars = 0;
	end

	self.attacker = VBriefUserInfo:new();							-- 进攻方
	self.attacker:synWithPbData(pbData.info.attacker);
	if self.attacker.userid then
		gData:addBriefUserInfo(self.attacker);
	end
	self.defender = VBriefUserInfo:new();							-- 防守方
	self.defender:synWithPbData(pbData.info.defender);
	if self.defender.userid then
		gData:addBriefUserInfo(self.defender);
	end
	
	self.road = {};													-- 场地宽度
	local tempRoad = {};
	if pbData.info.road then
		local iter = VDataIter();
		while pbData.info.road:Travel(iter) do
			table.insert(self.road, iter:Data());
			tempRoad[iter:Data()] = iter:Data();
		end
	end
	table.sort(self.road,
		function(a,b)
			return a < b;
		end);

	self.len = pbData.info.len;										-- 场地长度
	if pbData.info.extend_level then
		self.fieldLevel = pbData.info.extend_level;					-- 土地等级
	else
		local fieldCsv = gData:readCsv("manor_field_point_level.csv");
		local lineCount = fieldCsv:lineCount();

		for i=0,lineCount-1 do
			local fieldData = fieldCsv:lineData(i);
			if fieldData:Get(0) == self.len and fieldData:Get(1) == self.road[1] then
				self.fieldLevel = fieldData:Get(2);
				break;
			end
		end
	end

	self.seed = pbData.info.seed;									-- 随机数种子
	self.time = pbData.info.time;									-- 最大时间
	self.inerval = pbData.info.interval;								-- 逻辑运算时间间隔
	self.index = pbData.info.index;									-- 怪物索引
	self.pop = pbData.info.pop;									-- 最大僵尸人口
	self.temple = pbData.info.temple;								-- 太阳祭坛等级
	
	self.events = {};													-- 用户操作信息
	if pbData.info.infos then
		local iter = VDataIter();
		while pbData.info.infos:Travel(iter) do
			local event = BattleEvent:new();
			event:synWithPbData(iter:Data());
			table.insert(self.events, event);
		end
	end

	local gold = 0;													-- 保存植物身上的总金币总阳光
	local sunshine = 0;
	self.plants = {};													-- 植物信息
	self.plants64 = {};
	if pbData.info.plants then
		local iter = VDataIter();
		while pbData.info.plants:Travel(iter) do
			local plant = VBattleCreature:new();
			plant:synWithPlantPbData(iter:Data());
			local addPlant = false;
			if self.attackType == BattleType.BattleTypeEvp then
				addPlant = true;
			elseif tempRoad[plant.road] then 
				addPlant = true;
			end

			if addPlant then
				gold = gold + plant:getResource(AttrType.AttrTypeMoney);
				sunshine = sunshine + plant:getResource(AttrType.AttrTypeSunshine);
				-- cclog("***** plant.id = %f, road = %d, pos = %d, gold = %f, sunshine = %f", plant.id, plant.road, plant.pos, plant:getResource(AttrType.AttrTypeMoney), plant:getResource(AttrType.AttrTypeSunshine));
				self.plants[plant.id] = plant;
				self.plants64[plant.plantid] = plant;
			end
		end
	end

	self.monsters = {};												-- 怪物信息
	if pbData.info.monsters then
		local iter = VDataIter();
		while pbData.info.monsters:Travel(iter) do
			local monster = VBattleCreature:new();
			monster:synWithMonsterPbData(iter:Data());
			self.monsters[monster.id] = monster;
		end
	end

	-- 设置操作列表数据
	self:setBattleOperationUnitData();

	if self.attackType == BattleType.BattleTypePve then
		self.dungeonId = pbData.info.defender.id;
	elseif self.attackType == BattleType.BattleTypeEvp then
		self.dungeonId = pbData.info.attacker.id;
	end

	if self.dungeonId then
		-- 获取关卡援军
		self:getSupportBattleUnit();
		-- 读取大波僵尸进攻时间
		self:getZombieWaveTimeFromCsv(self.dungeonId);
	end

	-- 掠夺物
	self.spoils = VBattleSpoils:new(pbData.info.spoils);
	self.spoils:setMaxItemCount(self.attackType);
	local roadGold = self.spoils.gold;-- - gold;
	local roadSunshine = self.spoils.sunshine;-- - sunshine;
	-- cclog("******* self.spoils.gold = %d, self.spoils.sunshine = %d, gold = %d, sunshine = %d", self.spoils.gold, self.spoils.sunshine, gold, sunshine);
	-- cclog("******* self.spoils.gold = %d, self.spoils.sunshine = %d, roadGold = %d, roadSunshine = %d", self.spoils.gold, self.spoils.sunshine, roadGold, roadSunshine);

	-- 每条道路掠夺阳光和金币
	local roadRemainGold = roadGold;
	local roadRemainSunshine = roadSunshine;
	self.roadResource = {};
	self.roadResource[AttrType.AttrTypeMoney] = {};
	self.roadResource[AttrType.AttrTypeSunshine] = {};
	local resourceCsv = gData:readCsv("plunder_attr.csv");
	local csvLine = resourceCsv:lineCount();
	for i=0,csvLine-1 do
		local roadCount = resourceCsv:lineData(i,0);
		if roadCount == #self.road then
			local roadIndex = resourceCsv:lineData(i,1);
			local roadPre = resourceCsv:lineData(i,2);
			if roadIndex > 1 then
				roadPre = roadPre - resourceCsv:lineData(i-1,2);
			end
			if roadIndex == roadCount then
				self.roadResource[AttrType.AttrTypeMoney][roadIndex] = roadRemainGold
				self.roadResource[AttrType.AttrTypeSunshine][roadIndex] = roadRemainSunshine;
			else
				self.roadResource[AttrType.AttrTypeMoney][roadIndex] = math.floor(roadGold * roadPre / 100);
				self.roadResource[AttrType.AttrTypeSunshine][roadIndex] = math.floor(roadSunshine * roadPre / 100);
				roadRemainGold = roadRemainGold - self.roadResource[AttrType.AttrTypeMoney][roadIndex];
				roadRemainSunshine = roadRemainSunshine - self.roadResource[AttrType.AttrTypeSunshine][roadIndex];
			end
			-- cclog("***** AttrType.AttrTypeMoney[%d] = %d,  AttrType.AttrTypeMoney[%d] = %d ", roadIndex, self.roadResource[AttrType.AttrTypeMoney][roadIndex], roadIndex, self.roadResource[AttrType.AttrTypeSunshine][roadIndex]);
		end
	end

	-- 每条道路掠夺积分
	self.roadResource[AttrType.AttrTypeBattleScore] = {};
	local scoreCsv = gData:readCsv("plunder_score.csv");
	csvLine = scoreCsv:lineCount();
	if self.spoils.score == 0 then
		for i=1,5 do
			self.roadResource[AttrType.AttrTypeBattleScore][i] = 0;
		end
	else
		for i=0,csvLine-1 do
			local roadCount = scoreCsv:lineData(i,0);
			if roadCount == #self.road then
				local allScore = scoreCsv:lineData(i,1);
				if allScore == self.spoils.score then
					for n=2,6 do
						if n > 2 and scoreCsv:lineData(i,n) ~= 0 then
							self.roadResource[AttrType.AttrTypeBattleScore][n-1] = scoreCsv:lineData(i,n) - scoreCsv:lineData(i,n-1);
						else
							self.roadResource[AttrType.AttrTypeBattleScore][n-1] = scoreCsv:lineData(i,n);
						end
					end
				end
			end
		end
	end

	-- 每条道路掠夺物品数量
	self.roadResource[RES_DATA_TYPE.ResDataTypeItem] = {};
	local itemCsv = gData:readCsv("plunder_item_num.csv");
	csvLine = itemCsv:lineCount();

	if self.spoils.itemCount == 0 then
		for i=1,5 do
			self.roadResource[RES_DATA_TYPE.ResDataTypeItem][i] = 0;
		end
	else
		if isDungeonBattle(self.attackType) then
			for i=1,#self.road do
				if i == #self.road then
					self.roadResource[RES_DATA_TYPE.ResDataTypeItem][i] = self.spoils.itemCount;
				else
					self.roadResource[RES_DATA_TYPE.ResDataTypeItem][i] = 0;
				end
			end
		else
			for i=0,csvLine-1 do
				local roadCount = itemCsv:lineData(i,0);
				if roadCount == #self.road then
					local allCount = itemCsv:lineData(i,1);
					if allCount == self.spoils.itemCount then
						for n=2,6 do
							if n > 2 and itemCsv:lineData(i,n) ~= 0 then
								self.roadResource[RES_DATA_TYPE.ResDataTypeItem][n-1] = itemCsv:lineData(i,n) - itemCsv:lineData(i,n-1);
							else
								self.roadResource[RES_DATA_TYPE.ResDataTypeItem][n-1] = itemCsv:lineData(i,n);
							end
						end
					end
				end
			end
		end
	end
	--战旗
	self.attacker_banner = VBannerInfo:new();
	if pbData.info.attacker_banner then
		self.attacker_banner:update(pbData.info.attacker_banner);
	end
	self.defender_banner = VBannerInfo:new();
	if pbData.info.defender_banner then
		self.defender_banner:update(pbData.info.defender_banner);
	end
end

function VBattleInfo:initWithOtherUserInfo( pbData )
	if not pbData then
		return;
	end

	if gBattleResource == nil then
		gBattleResource = BattleResource:new();
		gBattleResource:Create();
	end

	self.playType = EBattlePlayType.PlayObserve;
	self.attackType = BattleType.BattleTypePlunder;

	if self.attackType == BattleType.BattleTypeEvp then
		self.stars = 3;
	else
		self.stars = 0;
	end

	self.attacker = VBriefUserInfo:new();
	self.attacker:loadByUserInfo(gData.userInfo);
	if self.attacker.userid then
		gData:addBriefUserInfo(self.attacker);
	end

	self.defender = VBriefUserInfo:new();
	local defUserInfo = VOtherUserInfo:new();
	defUserInfo:initUserInfo(pbData);
	self.defender:loadByUserInfo(defUserInfo);
	if self.defender.userid then
		gData:addBriefUserInfo(self.defender);
	end

	self.seed = -1;
	self.time = gBattleResource:ObserveTimeParam();--读配置
	self.inerval = -1;
	self.index = -1;
	self.events = {};

	self:setFieldDataWithFieldLevel(pbData.mi.bi.extend_level);

	local roadMap = {};
	for i,v in ipairs(self.road) do
		roadMap[v] = v;
	end
	self.plants = {};
	if pbData.mi.bi.farm_infos then
		local iter = VDataIter();
		while pbData.mi.bi.farm_infos:Travel(iter) do
			local plant = VBattleCreature:new();
			plant:sysWithFarmPbData(iter:Data());
			if roadMap[plant.road] then
				table.insert(self.plants, plant);
			end
		end
	end

	-- 获取自己全部僵尸
	self:getMonsterDataFromUserInfo();
	-- 设置操作列表数据
	self:setBattleOperationUnitData();
	-- 怪物索引
	self.index = getMapCount(self.plants) + 1;

	self.spoils = VBattleSpoils:new();
	self.spoils:initWithOtherUserInfo(pbData);
	self.spoils:setMaxItemCount(self.attackType);
end

function VBattleInfo:appendTargetInfo( targetInfo )
	if targetInfo.roads then
		self.road = targetInfo.roads;
	end
	if targetInfo.plants then
		self.plants = targetInfo.plants;
	end
	self.spoils:appendTargetResource(targetInfo);
end

-- 设置单机战场数据
function VBattleInfo:initSingleGame( dungeonId )
	self.playType = EBattlePlayType.PlayAttack;

	-- 读配置表获取战场基本数据
	local campaignCsv = gData:readCsv("prop_campaign.csv");
	local campaignData = campaignCsv:lineDataWithKey(dungeonId);

	self.dungeonId = dungeonId;
	self.attackType = campaignData:Get(3);						-- 战斗类型
	-- 设置土地等级、宽度、长度
	self:setFieldDataWithFieldLevel(campaignData:Get(4));
	self.rewardList = {};
	for i=1,3 do
		self.rewardList[i] = campaignData:Get(5+i);
	end
	-- 读取大波僵尸进攻时间
	self:getZombieWaveTimeFromCsv(dungeonId);

	-- self.seed = pbData.info.seed;								-- 随机数种子

	self.attacker = VBriefUserInfo:new();							-- 进攻方
	self.defender = VBriefUserInfo:new();							-- 防守方

	-- 进攻PVE
	if self.attackType == BattleType.BattleTypePve then
		self.stars = 0;

		self.attacker:synWithPbData(gData.userInfo);
		if self.attacker.userid then
			gData:addBriefUserInfo(self.attacker);
		else
			self.attacker.userid = gData.userInfo.userid;
			self.attacker.nick = gData.userInfo.roleInfo.nick;
			self.attacker.level = gData.userInfo.roleInfo.level;
			self.attacker.vipInfo = {};
			self.attacker.vipInfo[0] = gData.userInfo.roleInfo.vipInfo[0]; 
		end

		self.defender.userid = dungeonId;
		self.defender.nick = "对不起我是NPC";
		self.defender.level = 1;
		self.defender.vipInfo = {};
		self.defender.vipInfo[0] = 0; 

		-- 事件操作信息 操作列表空
		self.events = {};	
		-- 植物从关卡配置读取
		self:getPlantDataFromCsv();
		-- 获取关卡援军
		self:getSupportBattleUnit();
		-- 获取自己全部僵尸
		self:getMonsterDataFromUserInfo();
		-- 设置操作列表数据
		self:setBattleOperationUnitData();
		-- 怪物索引
		self.index = getMapCount(self.plants);
	
		-- 防守PVE
	elseif self.attackType == BattleType.BattleTypeEvp then
		self.stars = 3;

		self.attacker.userid = dungeonId;
		self.attacker.nick = "对不起我是NPC";
		self.attacker.level = 1;
		self.attacker.vipInfo = {};
		self.attacker.vipInfo[0] = 0; 

		self.defender:synWithPbData(gData.userInfo);
		if self.defender.userid then
			gData:addBriefUserInfo(self.defender);
		else
			self.defender.userid = gData.userInfo.userid;
			self.defender.nick = gData.userInfo.roleInfo.nick;
			self.defender.level = gData.userInfo.roleInfo.level;
			self.defender.vipInfo = {};
			self.defender.vipInfo[0] = gData.userInfo.roleInfo.vipInfo[0]; 
		end

		-- 事件操作列表 从配置读取
		self:getBattleEventFromCsv();
		-- 僵尸列表空，防守战场无僵尸(事件内是释放僵尸)
		self:getMonsterDataFromEventData();
		-- 获取自己全部植物
		self:getAllPlantDataFromUserInfo();
		-- 设置操作列表数据
		self:setBattleOperationUnitData();
		-- 获取关卡援军
		self:getSupportBattleUnit();
		-- 怪物索引
		self.index = getMapCount(self.monsters) + getMapCount(self.supportList);
	end

	self.inerval = gBattleResource:Interval();						-- 逻辑运算时间间隔
	local battleProp = gBattleResource:GetBattleProp(self.attackType, #self.road, self.fieldLevel);
	if battleProp then
		self.time = battleProp.time * 1000;								-- 最大时间
	else
		self.time = 120 * 1000;								-- 最大时间
	end

	-- 战场资源暂时设定为空
	self.spoils = VBattleSpoils:new();
	self.spoils.gold = 0;
	self.spoils.sunshine = 0;
	self.spoils.score = 0;

	self.roadResource = {};
	self.roadResource[AttrType.AttrTypeMoney] = {};
	self.roadResource[AttrType.AttrTypeSunshine] = {};
	self.roadResource[AttrType.AttrTypeBattleScore] = {};

	for i,v in ipairs(self.road) do
		self.roadResource[AttrType.AttrTypeMoney][v] = 0;
		self.roadResource[AttrType.AttrTypeSunshine][v] = 0;
		self.roadResource[AttrType.AttrTypeBattleScore][v] = 0;
	end
	--太阳祭坛
	self.temple = gData.userInfo.manorInfo.altarInfo.level;
	--战旗相关
	--玩家战旗
	local userBannerId = gData.userInfo.roleInfo.activeBanner.id;
	local userBanner = gData.userInfo.bannerInfos.bannerInfos[userBannerId];
	--关卡战旗
	local dungeonBanner = VBannerInfo:new();
	local dungeonBannerId = campaignData:Get(13);
	local dungeonBannerCsv = gData:readCsv("banner_init_scheme.csv");
	local dungeonBannerData = campaignCsv:lineDataWithKey(dungeonBannerId);
	if dungeonBannerData then
		dungeonBanner.attackAttr = VBannerAttr:new(dungeonBannerData:Get(3), dungeonBannerData:Get(2), dungeonBannerData:Get(1));
		dungeonBanner.defendAttr = VBannerAttr:new(dungeonBannerData:Get(6), dungeonBannerData:Get(5), dungeonBannerData:Get(4));
		dungeonBanner.plants = {};
		dungeonBanner.monsters = {};
		for i = 7, 11 do
			if dungeonBannerData:Get(i) and tonumber(dungeonBannerData:Get(i)) and tonumber(dungeonBannerData:Get(i)) > 0 then
				table.insert(dungeonBanner.plants, tonumber(dungeonBannerData:Get(i)));
				table.insert(dungeonBanner.monsters, tonumber(dungeonBannerData:Get(i)));
			end
		end
	end
	if self.attackType == BattleType.BattleTypePve then
		self.attacker_banner = userBanner;
		self.defender_banner = dungeonBanner;
	elseif self.attackType == BattleType.BattleTypeEvp then
		self.attacker_banner = dungeonBanner;
		self.defender_banner = userBanner;
	end
end

function VBattleInfo:initForNewbie( )
	local userInfo = gData.userInfo;
	self.playType = EBattlePlayType.PlayReplay;
	self.attackType = BattleType.BattleTypePlunder;				-- 战斗类型

	self.attacker = VBriefUserInfo:new();							-- 进攻方
	self.attacker.id = 1;
	self.attacker.nick = "僵尸";
	self.attacker.level = 1;
	self.attacker.vipInfo = {};
	self.attacker.vipInfo[0] = 0; 
	
	self.defender = VBriefUserInfo:new();							-- 防守方
	self.defender:loadByUserInfo(gData.userInfo);

	self.fieldLevel = userInfo.manorInfo.extendLevel;				-- 土地等级
	self.road = {};													-- 场地宽度
	self.len = 0;													-- 场地长度
	local fieldCsvData = gData:readCsv("manor_field_point_level.csv");
	local lineCount = fieldCsvData:lineCount();
	for i=0,lineCount - 1 do
		local lineData = fieldCsvData:lineData(i);
		if self.fieldLevel == lineData:Get(2) then
			if lineData:Get(0) > self.len then
				self.len = lineData:Get(0);
			end

			local haveRoad = false;
			for j,v in ipairs(self.road) do
				if v == lineData:Get(1) then
					haveRoad = true;
				end
			end
			if not haveRoad then
				table.insert(self.road, lineData:Get(1));
			end
		end
	end

	local commonCsv = gData:readCsv("battle_common.csv");
	self.time = commonCsv:lineData(0,1) * 1000;					-- 最大时间
	self.inerval = commonCsv:lineData(0,0);						-- 逻辑运算时间间隔

	local gold = 0;													-- 保存植物身上的总金币总阳光
	local sunshine = 0;
	self.plants = {};													-- 植物信息
	local indexId = 1;
	for k,v in pairs(userInfo.manorInfo.farmInfos) do
		local plant = VBattleCreature:new();
		plant:initWithVFarmInfo(indexId,v);
		indexId = indexId + 1;
		table.insert(self.plants, plant);
	end

	self.index = indexId;											-- 怪物索引
	local tempMonsterDic = {};
	self.events = {};												-- 用户操作信息
	self.monsterTechs = {};										-- 怪物母体
	local newbieBattleCsv = gData:readCsv("newbie_battle_event.csv");
	local eventInfo = newbieBattleCsv:allData();
	for i,v in ipairs(eventInfo) do 
		local event = BattleEvent:new();
		event:initWithCsvData(v);
		if not tempMonsterDic[v[4]] then
			tempMonsterDic[v[4]] = 0;
		end 
		tempMonsterDic[v[4]] = tempMonsterDic[v[4]] + 1;

		self.monsterTechs[v[4]] = VArmyTechInfo:new();
		self.monsterTechs[v[4]].armyid = v[3];
		self.monsterTechs[v[4]].classType = v[4];
		self.monsterTechs[v[4]].suitInfo.thingid = v[5];
		self.monsterTechs[v[4]].suitInfo:loadDynamicCsvData();

		local csv_md = gData:readCsv("monster_desc.csv");
		local monster_desc = csv_md:linesWithKeyRowValues(v[4], 1);
		self.monsterTechs[v[4]].name = monster_desc.name;
		self.monsterTechs[v[4]].image = monster_desc.image;
		table.insert(self.events, event);
	end

	-- self.monsters = VTroopInfo:new();							-- 怪物信息
	for k,v in pairs(tempMonsterDic) do
		local armyInfo = VArmInfo:new(k);
		armyInfo:addCount(v);
		table.insert(self.monsters.armies, armyInfo);
	end
	self.monsters:sortWithArmId();

	self.spoils = VBattleSpoils:new();
	self.spoils.gold = userInfo.roleInfo:attrValue(AttrType.AttrTypeMoney);
	self.spoils.sunshine = userInfo.roleInfo:attrValue(AttrType.AttrTypeSunshine);
	self.spoils.score = 1;
	local roadGold = self.spoils.gold - gold;
	local roadSunshine = self.spoils.sunshine - sunshine;

	self.roadResource = {};
	self.roadResource[AttrType.AttrTypeMoney] = {};
	self.roadResource[AttrType.AttrTypeSunshine] = {};
	local resourceCsv = gData:readCsv("plunder_attr.csv");
	local csvLine = resourceCsv:lineCount();
	for i=0,csvLine-1 do
		local roadCount = resourceCsv:lineData(i,0);
		if roadCount == #self.road then
			local roadIndex = resourceCsv:lineData(i,1);
			self.roadResource[AttrType.AttrTypeMoney][roadIndex] = math.floor(roadGold * resourceCsv:lineData(i,2) / 100);
			self.roadResource[AttrType.AttrTypeSunshine][roadIndex] = math.floor(roadSunshine * resourceCsv:lineData(i,2) / 100);
		end
	end

	self.roadResource[AttrType.AttrTypeBattleScore] = {};
	local scoreCsv = gData:readCsv("plunder_score.csv");
	csvLine = scoreCsv:lineCount();

	if self.spoils.score == 0 then
		for i=1,5 do
			self.roadResource[AttrType.AttrTypeBattleScore][i] = 0;
		end
	else
		for i=0,csvLine-1 do
			local roadCount = scoreCsv:lineData(i,0);
			if roadCount == #self.road then
				local allScore = scoreCsv:lineData(i,1);
				if allScore == self.spoils.score then
					for n=2,6 do
						if n > 2 and scoreCsv:lineData(i,n) ~= 0 then
							self.roadResource[AttrType.AttrTypeBattleScore][n-1] = scoreCsv:lineData(i,n) - scoreCsv:lineData(i,n-1);
						else
							self.roadResource[AttrType.AttrTypeBattleScore][n-1] = scoreCsv:lineData(i,n);
						end
					end
				end
			end
		end
	end
	
	self.temple = userInfo.manorInfo.altarInfo.level;
end

function VBattleInfo:isDungeonBattle( )
	if self.attackType == BattleType.BattleTypePve or self.attackType == BattleType.BattleTypeEvp then
		return true;
	end
	return false;
end

-- 从配置读取大波僵尸进攻时间
function VBattleInfo:getZombieWaveTimeFromCsv( dungeonId )
	local campaignCsv = gData:readCsv("prop_campaign.csv");
	local campaignData = campaignCsv:lineDataWithKey(dungeonId);

	self.waveTime = {};
	for i=0,1 do
		if campaignData then
			local eventTime = campaignData:Get(15+i);
			if eventTime and eventTime ~= -1 then
				self.waveTime[i+1] = eventTime;
			end
		end
	end
end

-- 从配置读取土地数据
function VBattleInfo:setFieldDataWithFieldLevel( fieldLevel )
	self.fieldLevel = fieldLevel;
	self.road = {};
	self.len = 0;
	local fieldCsvData = gData:readCsv("manor_field_point_level.csv");
	local lineCount = fieldCsvData:lineCount();
	for i=0,lineCount - 1 do
		local lineData = fieldCsvData:lineData(i);
		if self.fieldLevel == lineData:Get(2) then
			if lineData:Get(0) > self.len then
				self.len = lineData:Get(0);
			end

			local haveRoad = false;
			for j,v in ipairs(self.road) do
				if v == lineData:Get(1) then
					haveRoad = true;
				end
			end
			if not haveRoad then
				table.insert(self.road, lineData:Get(1));
			end
		end
	end
	table.sort(self.road,
		function(a,b)
			return a < b;
		end);
end

-- 配置表读取事件列表
function VBattleInfo:getBattleEventFromCsv( )
	self.events = {};													-- 用户操作信息
	local dungeonMonsterCsv = gData:readCsv("dungeon_monster_config.csv");
	local csvLine = dungeonMonsterCsv:lineCount();

	local indexId = 0;
	for i=0,csvLine-1 do
		local data = dungeonMonsterCsv:lineData(i);
		if data:Get(0) == self.attacker.userid then
			indexId = indexId + 1;
			local event = BattleEvent:new();
			event:initWithCsvData(data, indexId);
			table.insert(self.events, event);
		end
	end

	table.sort(self.events,
		function (a,b)
			return a.time < b.time;
		end);

	for i,v in ipairs(self.events) do
		v.params2[1] = i;
	end
end

-- 设置操作列表数据
function VBattleInfo:setBattleOperationUnitData( )
	self.battleUnitMap = {};			-- for Data
	self.battleUnitList = {};			-- for TableVIew

	-- 防守模式 操作列表设置为植物，其他为僵尸
	local data = self.monsters;
	local isAttack = true;
	if self.attackType == BattleType.BattleTypeEvp then
		data = self.plants;
		isAttack = false;
	end

	if not data then
		return;
	end

	local tempUnitMap = {};
	for k,battleCreature in pairs(data) do
		local prop = battleCreature.prop;
		if prop then
			if not self.battleUnitMap[prop.classType] then
				self.battleUnitMap[prop.classType] = {};
				tempUnitMap[prop.classType] = VBattleRace:new(prop, isAttack);
			end
			if not self.battleUnitMap[prop.classType][prop.quality] then
				self.battleUnitMap[prop.classType][prop.quality] = {};
			end
			tempUnitMap[prop.classType]:addChildUnit(prop);
			table.insert(self.battleUnitMap[prop.classType][prop.quality], battleCreature);
		end
	end

	for k,v in pairs(tempUnitMap) do
		v:sortChildUnit();
		table.insert(self.battleUnitList, v);
	end

	if self.battleUnitList then
		table.sort(self.battleUnitList,
			function(a,b)
				return a.basicProp.classType < b.basicProp.classType;
			end);
	end
end

-- 从配置表获取关卡植物
function VBattleInfo:getPlantDataFromCsv( )
	-- 植物信息
	self.plants = {};
	local dungeonPlantCsv = gData:readCsv("dungeon_plant_config.csv");
	local csvLine = dungeonPlantCsv:lineCount();

	local index = 1;
	for i=0,csvLine-1 do
		local data = dungeonPlantCsv:lineData(i);
		if data:Get(0) == self.defender.userid then
			local plant = VBattleCreature:new();
			plant:initWithCsvData(data, index);
			self.plants[plant.id] = plant;
			index = index + 1;
		end
	end
end

-- 获取自己的所有植物(背包+农场)
function VBattleInfo:getAllPlantDataFromUserInfo( )
	-- 植物信息
	local index = 1;
	self.plants = {};
	for k,v in pairs(gData.userInfo.plantInfos.plants) do
		local plant = VBattleCreature:new();
		plant:initWithPlantInfo(v, index);
		self.plants[plant.id] = plant;
		index = index + 1;
	end

	for k,v in pairs(gData.userInfo.manorInfo.farmInfos) do
		local plant = VBattleCreature:new();
		plant:initWithFarmInfo(v, index);
		self.plants[plant.id] = plant;
		index = index + 1;
	end
end

-- 获取自己的所有僵尸
function VBattleInfo:getMonsterDataFromUserInfo( )
	-- 怪物信息
	self.monsters = {};
	if gData.userInfo.monsterInfo.monsterInfos then
		for k,vMonsterInfo in pairs(gData.userInfo.monsterInfo.monsterInfos) do
			if gData:currentTime() > vMonsterInfo.reTime then
				local monster = VBattleCreature:new();
				monster:initWithVMonsterInfo(vMonsterInfo);
				self.monsters[monster.id] = monster;
			end
		end
	end
end

function VBattleInfo:getMonsterDataFromEventData( )
	self.monsters = {};												-- 怪物信息
	if self.events then
		for i,v in ipairs(self.events) do
			local monster = VBattleCreature:new();
			monster:initWithEventData(v);
			self.monsters[monster.id] = monster;			
		end
	end
end

-- 获取关卡援军
function VBattleInfo:getSupportBattleUnit( )
	local campaignCsv = gData:readCsv("prop_campaign.csv");
	local campaignData = campaignCsv:lineDataWithKey(self.dungeonId);
	if not campaignData then
		return;
	end

	local unitId = campaignData:Get(10);
	local unitCount = campaignData:Get(11);

	self.supportList = {};
	if self.attackType == BattleType.BattleTypePve then
		local index = getMapCount(self.monsters);
		for i=1,unitCount do
			local monster = VBattleCreature:new();
			monster:initWithSupport(unitId, index+i, true);
			self.supportList[monster.id] = monster;
		end
	elseif self.attackType == BattleType.BattleTypeEvp then
		local index = getMapCount(self.plants);
		for i=1,unitCount do
			local plant = VBattleCreature:new();
			plant:initWithSupport(unitId, index+i, false);
			self.supportList[plant.id] = plant;
		end		
	end
end

-- 获取操作单位数量
function VBattleInfo:getBattleOperationUnitCount( monsterClass, quality )
	if not monsterClass then return 0; end

	if quality then
		return #self.battleUnitMap[monsterProp.monsterClass][monsterProp.quality];
	else
		local count = 0;
		for k,v in pairs(self.battleUnitMap[monsterProp.monsterClass]) do
			count = count + #v;
		end
		return count;
	end
end

function VBattleInfo:setReplayPlayType( )
	self.playType = EBattlePlayType.PlayReplay;
end

function VBattleInfo:getBattleUnitCount( )
	local count = 0;
	for i,battleUnit in ipairs(self.battleUnitList) do
		count = count + battleUnit.unitCount;
	end

	return count;
end

function VBattleInfo:removeBattleUnit( classType, quality )
	if not quality then
		-- 找出最高品质
		for k,v in pairs(self.battleUnitMap[classType]) do
			if not quality then
				if #self.battleUnitMap[classType][k] > 0 then
					quality = k;
				end
			else
				if k > quality and #self.battleUnitMap[classType][k] > 0 then
					quality = k;
				end
			end	
		end
	end

	if self.battleUnitMap[classType][quality] then
		-- 取出该种类、该品质的最高等级单位
		local battleUnitId = nil;
		local maxLevel = -1;

		local index = -1;
		for i,v in ipairs(self.battleUnitMap[classType][quality]) do
			if v.prop.level > maxLevel then
				maxLevel = v.prop.level;
				battleUnitId = v.id;
				index = i;
			end
		end

		if not battleUnitId then
			return nil;
		end
		if index > 0 then
			table.remove(self.battleUnitMap[classType][quality], index);
		end

		for i,v in ipairs(self.battleUnitList) do
			if v.basicProp.classType == classType then
				v.unitCount = v.unitCount - 1;
				v.childCount[quality] = v.childCount[quality] - 1; 
				local index = -1;
				for i,v in ipairs(v.unitLevel[quality]) do
					if v == maxLevel then
						index = i;
						break;
					end
				end
				table.remove(v.unitLevel[quality], index);
			end
		end

		return battleUnitId;
	else
		return nil;
	end
end

-- 怪物获取徽章相关信息
function VBattleInfo:getInsigniaInfo( )
	if gBattleResource then
		for k,v in pairs(self.monsters.armies) do
			local monster = v;
			local armTech = self.monsterTechs[monster.id];
			-- armTech.monsterId, monster.id
			local pMonsterProp = gBattleResource:GetMonsterProp(armTech.monsterId);
			assert(pMonsterProp ~= nil, "VBattleInfo:getInsigniaInfo Error pMonsterProp = nil, armTech.monsterId = "..armTech.monsterId);

			local pMonster = BattleCreature:new(pMonsterProp);
			if armTech then
				pMonster:InitMonster(armTech, true);
			end
			v.level = pMonster.m_level;
			v.insigniaImage = pMonster.insigniaImage;
		end
	end
end

------------------------------------------------

VBattleReturnItemInfo = vclass("BattleReturnItemInfo")

function VBattleReturnItemInfo:initialize(thingInfo)
	if not thingInfo then return; end

	self.id = thingInfo.thingid;
	self.count = thingInfo.count;
	self.type = thingInfo.type;

	if thingInfo.type == ThingType.ThingTypeItem then
		local itemInfo = gData:itemInfo(self.id);
		if itemInfo then
			self.name = itemInfo.name;
			self.image = itemInfo.image;
			-- cclog("********  self.name = %s,  self.image = %s", self.name, self.image);
		end

	elseif thingInfo.type == ThingType.ThingTypePlant then
		local plantCsv = gData:readCsv("prop_plant.csv");
		local propPlant = plantCsv:lineDataWithKey(self.id);		
		if propPlant then
			local plantDescCsv = gData:readCsv("prop_plant_type.csv");
			local descPlant = plantDescCsv:linesWithKeyRowValues(propPlant.classType, propPlant.quality);
			if descPlant then
				self.name = descPlant.name;
				self.image = descPlant.image.."S.png";
				-- cclog("******** plant  self.name = %s,  self.image = %s", self.name, self.image);
			end
		end

	elseif thingInfo.type == ThingType.ThingTypeArm then
		local monsterCsv = gData:readCsv("prop_monster.csv");
		local propMonster = monsterCsv:lineDataWithKey(self.id);
		if propMonster then
			local monsterDescCsv = gData:readCsv("prop_monster_type.csv");
			local descMonster = monsterDescCsv:linesWithKeyRowValues(propMonster.monsterClass, propMonster.quality);
			if descMonster then
				self.name = descMonster.name;
				self.image = descMonster.image.."S.png";
				-- cclog("******** monster  self.name = %s,  self.image = %s", self.name, self.image);
			end
		end
	end
end

function VBattleReturnItemInfo:initWithValueAndAttrType( value, itemType )
	self.id = -1;
	self.count = value;
	self.attrType = itemType;

	if itemType == AttrType.AttrTypeMoney then
		self.image = "qianbi.png";
		self.name = "金币";
	elseif itemType == AttrType.AttrTypeSunshine then
		self.image = "yangguang.png";
		self.name = "阳光";
	elseif itemType == AttrType.AttrTypeBattleScore then
		-- self.image = 
		-- self.name = "积分";
	end
end

------------------------------------------------

VBattleSpoils = vclass("BattleSpoils")

-- @Param ReturnInfo
function VBattleSpoils:initialize(pbData)

	-- 总量
	self.gold = 0;
	self.sunshine = 0;
	self.score = 0;

	-- 已被掠夺
	self.spoilsGold = 0;
	self.spoilsSunshine = 0;
	self.spoilsScore = 0;

	self.attrInfos = {};
	self.itemInfos = {};
	self.spoilsItemInfos = {};
	self.itemCount = 0;
	self.spoilsItemCount = 0;

	if pbData then
		self:synWithPbData(pbData);
	end
end

function VBattleSpoils:convert2VData()
	local dataTable = {};
	dataTable.gold = self.gold;
	dataTable.sunshine = self.sunshine;

	dataTable.itemCount = self.itemCount;
	
	return Var(dataTable);
end

function VBattleSpoils:loadFromVar( var )
	if not var then return; end
	self.gold = var.gold;
	self.sunshine = var.sunshine;
	self.itemCount = var.itemCount;
end


function VBattleSpoils:synWithRepeatedInfo(pbData)
	if pbData then
		local iter = VDataIter();
		while pbData:Travel(iter) do
			local data = iter:Data();
			if data and data.userid and data.userid == gData.userInfo.userid then
				self:synWithPbData(data);
			end
		end
	end
end

-- @Param ReturnInfo
function VBattleSpoils:synWithPbData(pbData)
	if not pbData then
		return;
	end
	-- ReturnThingInfo
	if pbData.rtis then
		local iter = VDataIter();
		while pbData.rtis:Travel(iter) do
			local item = iter:Data();
			if item.type == ThingType.ThingTypeItem or item.type == ThingType.ThingTypePlant or item.type == ThingType.ThingTypeArm then
				local thingInfo = VBattleReturnItemInfo:new(item);
				self.itemCount = self.itemCount + thingInfo.count;
				table.insert(self.itemInfos, thingInfo);
			end
		end
	end

	-- ReturnAttrInfo
	if pbData.rais then
		local iter = VDataIter();
		while pbData.rais:Travel(iter) do
			local item = iter:Data();
			if item.type == AttrType.AttrTypeMoney then
				self.gold = self.gold + item.value;
			elseif item.type == AttrType.AttrTypeSunshine then
				self.sunshine = self.sunshine + item.value;
			elseif item.type == AttrType.AttrTypeBattleScore then
				self.score = self.score + item.value;
			end
		end
	end
	local goldInfo = VBattleReturnItemInfo:new();
	goldInfo:initWithValueAndAttrType(self.gold, AttrType.AttrTypeMoney);
	table.insert(self.attrInfos, goldInfo);

	local sunshineInfo = VBattleReturnItemInfo:new();
	sunshineInfo:initWithValueAndAttrType(self.sunshine, AttrType.AttrTypeSunshine);
	table.insert(self.attrInfos, sunshineInfo);

	local scoreInfo = VBattleReturnItemInfo:new();
	scoreInfo:initWithValueAndAttrType(self.score, AttrType.AttrTypeBattleScore);
	table.insert(self.attrInfos, scoreInfo);
end

function VBattleSpoils:initWithOtherUserInfo( pbData )
	if pbData.ui.infos then
		local iter = VDataIter();
		while pbData.ui.infos:Travel(iter) do
			local item = iter:Data();
			if item.type == AttrType.AttrTypeMoney then
				self.gold = item.value * gBattleResource:SpoilParam();
			elseif item.type == AttrType.AttrTypeSunshine then
				self.sunshine = item.value * gBattleResource:SpoilParam();
			end
		end
	end

	if pbData.mi.bi.farm_infos then
		local iter = VDataIter();
		while pbData.mi.bi.farm_infos:Travel(iter) do
			local farmInfo = VFarmInfo:new();
			farmInfo:synWithPbData(iter:Data());
			local value, attrType = farmInfo:produceValue();
			if attrType == AttrType.AttrTypeMoney then
				self.gold = value * gBattleResource:SpoilPlantParam();
			elseif attrType == AttrType.AttrTypeSunshine then
				self.sunshine = value * gBattleResource:SpoilPlantParam();
			end
		end
	end
end

-- 设置最大掠夺数
function VBattleSpoils:setMaxItemCount( battleType )
	if not (battleType == BattleType.BattleTypePve or battleType == BattleType.BattleTypeEvp) then
		if gBattleResource then
			if self.itemCount >= gBattleResource:SpoilItemsParam() then
				self.itemCount = gBattleResource:SpoilItemsParam();	
			end
		end
	end
end

function VBattleSpoils:reduceResource( resource, roads )
	local allValue = 0;
	if roads then
		if resource[AttrType.AttrTypeMoney] then
			for k,v in pairs(resource[AttrType.AttrTypeMoney]) do
				-- cclog("*********** AttrTypeMoney k = %d, v = %d", k, v);
				if k == roads then
					-- cclog("*********** AttrTypeMoney reduce k = %d, v = %d", k, v);
					self.gold = self.gold - v;
					self.spoilsGold = self.spoilsGold + v;
					allValue = allValue + v;
				end
			end
		end
		if resource[AttrType.AttrTypeSunshine] then
			for k,v in pairs(resource[AttrType.AttrTypeSunshine]) do
				-- cclog("*********** AttrTypeSunshine k = %d, v = %d", k, v);
				if k == roads then
					-- cclog("*********** AttrTypeSunshine reduce k = %d, v = %d", k, v);
					self.sunshine = self.sunshine - v;
					self.spoilsSunshine = self.spoilsSunshine + v;
					allValue = allValue + v;
				end
			end
		end
	else
		for k,v in pairs(resource) do
			if k == AttrType.AttrTypeMoney then
				-- cclog("*********** not roads AttrTypeMoney k = %d, v = %d", k, v);
				self.gold = self.gold - v;
				self.spoilsGold = self.spoilsGold + v;
				allValue = allValue + v;
			elseif k == AttrType.AttrTypeSunshine then
				-- cclog("*********** not roads AttrTypeSunshine k = %d, v = %d", k, v);
				self.sunshine = self.sunshine - v;
				self.spoilsSunshine = self.spoilsSunshine + v;
				allValue = allValue + v;
			end
		end
	end

	if allValue > 0 then
		return true;
	else
		return false;
	end
end

function VBattleSpoils:reduceScore( score )
	-- assert(score ~= nil, "VBattleSpoils:reduceScore Error score = nil. 停止游戏, 把vLog拿来看看");
	if score then
		self.score = self.score - score;
		self.spoilsScore = self.spoilsScore + score;
	end
end

function VBattleSpoils:reduceItem( reduceItemCount )
	-- assert(reduceItemCount ~= nil, "VBattleSpoils:reduceItem Error reduceItemCount = nil. 停止游戏, 把vLog拿来看看");
	if reduceItemCount then
		self.itemCount = self.itemCount - reduceItemCount;
		self.spoilsItemCount = self.spoilsItemCount + reduceItemCount;
	end
	-- cclog("****  #self.itemInfos = %d,  #self.spoilsItemInfos = %d  ", #self.itemInfos, #self.spoilsItemInfos);
end

function VBattleSpoils:spoilAllResource( )
	local allValue = 0;
	self.spoilsGold = self.spoilsGold + self.gold;
	allValue = allValue + self.gold;
	self.gold = 0;
	self.spoilsSunshine = self.spoilsSunshine + self.sunshine;
	allValue = allValue + self.sunshine;
	self.sunshine = 0;
	self.spoilsScore = self.spoilsScore + self.score;
	self.score = 0;
	self.spoilsItemCount = self.spoilsItemCount + self.itemCount;
	self.itemCount = 0;

	if allValue > 0 then
		return true;
	else
		return false;
	end
end

function VBattleSpoils:addItem( bIsAttack, addItemCount )
	if not addItemCount then
		return;
	end
	if bIsAttack then
		self.spoilsItemCount = self.spoilsItemCount + addItemCount;
	else
		--通路之后还有掠夺碎片的逻辑，若是在这里将对方在战斗中获
		--得的掉落碎片加上去会导致结算的时候碎片的实际获得和客户端显示不一致
		--self.itemCount = self.itemCount + addItemCount;
	end
end

function VBattleSpoils:appendTargetResource( targetInfo )
	if targetInfo.money then
		self.gold = targetInfo.money;
	end
	if targetInfo.sunshine then
		self.sunshine = targetInfo.sunshine;
	end
end

------------------------------------------------

VBattleDieCreature = vclass("BattleDieCreature")

-- @Param ReturnInfo
function VBattleDieCreature:initialize( prop )
	self.classType = prop.classType;
	self.quality = prop.quality;

	self.name = prop.name;
	self.image = prop.image;
	self.count = 0;
end

function VBattleDieCreature:addCount( )
	self.count = self.count + 1;
end

------------------------------------------------
VBattleResult = vclass("BattleResult")

function VBattleResult:initialize(pbData)
	if pbData then
		self:synWithPbData(pbData);
	else
		self.victor = -1;
		self.record = -1;
		self.roads = {};
		self.breakRoads = {};
		self.monsters = {};
		self.plants = {};
		self.dieMonsterList = {};
		self.diePlantList = {};
		self.stars = 0;
		self.spoils = VBattleSpoils:new();
	end
end

function VBattleResult:synWithPbData(pbData)
	self.victor = pbData.victor;
	self.record = pbData.record;
	if pbData.stars then
		self.stars = pbData.stars;
	else
		self.stars = 0;
	end

	self.roads = {};
	if pbData.roads then
		local iter = VDataIter();
		while pbData.roads:Travel(iter) do
			local value = iter:Data();
			table.insert(self.roads, value);
		end
	end

	self.breakRoads = {};
	if pbData.break_roads then
		local iter = VDataIter();
		while pbData.break_roads:Travel(iter) do
			local value = tostring(iter:Data());
			table.insert(self.breakRoads, value);
		end
	end

	self.monsters = {};
	if pbData.monsters then
		local iter = VDataIter();
		while pbData.monsters:Travel(iter) do
			table.insert(self.monsters, iter:Data());
		end
	end

	self.plants = {};
	if pbData.plants then
		local iter = VDataIter();
		while pbData.plants:Travel(iter) do
			table.insert(self.plants, iter:Data());
		end
	end

	self.spoils = VBattleSpoils:new();
	self.spoils:synWithRepeatedInfo(pbData.spoils);
end

function VBattleResult:setDeathDataInfo( battleInfo )
	-- 合并僵尸
	local monsterMap = {};
	for i,v in ipairs(self.monsters) do
		local monsterCreature = battleInfo.monsters[v];
		if monsterCreature then
			if not monsterCreature.prop then
				monsterCreature.prop = gData:getBriefPlantCsvData(monsterCreature.propid);
			end
			local classType = monsterCreature.prop.classType;
			local quality = monsterCreature.prop.quality;

			if not monsterMap[classType] then
				monsterMap[classType] = {};
			end
			if not monsterMap[classType][quality] then
				monsterMap[classType][quality] = VBattleDieCreature:new(monsterCreature.prop);
			end
			local dieCreature = monsterMap[classType][quality];
			dieCreature:addCount();
		end
	end

	-- 排序
	self.dieMonsterList = {};
	for class,qualityTable in pairs(monsterMap) do
		for quality,dieCreature in pairs(qualityTable) do
			table.insert(self.dieMonsterList, dieCreature);
		end
	end
	table.sort(self.dieMonsterList,
		function(a,b)
			if a.classType == b.classType then
				return a.quality < b.quality;
			else
				return a.classType < b.classType;
			end
		end);

	-- 合并植物
	local plantMap = {};
	for i,v in ipairs(self.plants) do
		local plantCreature = battleInfo.plants[v];
		if plantCreature then
			if not plantCreature.prop then
				plantCreature.prop = gData:getBriefPlantCsvData(plantCreature.propid);
			end
			local classType = plantCreature.prop.classType;
			local quality = plantCreature.prop.quality;

			if not plantMap[classType] then
				plantMap[classType] = {};
			end
			if not plantMap[classType][quality] then
				plantMap[classType][quality] = VBattleDieCreature:new(plantCreature.prop);
			end
			local dieCreature = plantMap[classType][quality];
			dieCreature:addCount();
		end
	end

	-- 排序
	self.diePlantList = {};
	for class,qualityTable in pairs(plantMap) do
		for quality,dieCreature in pairs(qualityTable) do
			table.insert(self.diePlantList, dieCreature);
		end
	end
	table.sort(self.diePlantList,
		function(a,b)
			if a.classType == b.classType then
				return a.quality < b.quality;
			else
				return a.classType < b.classType;
			end
		end);
end

function VBattleResult:initSingleGameResult( battle, battleInfo )
	--突破的道路  
	for k,v in pairs(battle:GetGround():GetRoads()) do
		if v:GetValid() then
			table.insert(self.roads, k);
		else
			table.insert(self.breakRoads, k);
		end
	end

	-- 死亡的僵尸
	local iDeadMonsterCount = 0;
    local tableTemp = {};

	for key, value in pairs(battle.m_allAttacker) do
        table.insert(tableTemp,value:GetExtra());
		if battle.m_beginAttackers[value:GetExtra()] then
			if value:IsDead() then
				iDeadMonsterCount = iDeadMonsterCount + 1;
				if value:GetDeadWay() ~= EDeadWay.DEAD_SUICIDE then
					table.insert(self.monsters, value:GetExtra());
				end
			end
		end
	end

	-- 死亡的植物
	local shovelNum = 0;
	for key, value in pairs(battle.m_allDefender) do
		if battle.m_beginDefenders[value:GetId()] then
			if value:IsDead() then
				if battleInfo.m_shovelPlantNum and shovelNum <= battleInfo.m_shovelPlantNum then
					if not battle.m_shovelDeadList[value:GetId()] then
						table.insert(self.plants, value:GetId());
					else
						shovelNum = shovelNum + 1;
					end
				else
					table.insert(self.plants, value:GetId());
				end
			end
		end
	end
	
	--*调整进攻关卡星级评价设定：1星调整为突破一条道路、2星调整为突破一半以上道路、3星调整为突破所有道路；
	--*调整防守关卡星级评价设定：1星维持现状、2星修改为被杀死5个植物、3星维持现状；
	--胜负标示
	if battleInfo.attackType == BattleType.BattleTypePve then
		local record = #self.breakRoads / (#self.breakRoads + #self.roads);
		if #self.breakRoads > 0 then
			self.record = 1;
			self.victor = battleInfo.attacker.userid;
		else
			self.record = 2;
			self.victor = battleInfo.defender.userid;
		end

		if #self.roads == 0 then
			self.stars = 3;
		elseif #self.breakRoads > #self.roads then
			self.stars = 2;
		elseif #self.breakRoads > 0 then
			self.stars = 1;
		else
			self.stars = 0;
		end
	elseif battleInfo.attackType == BattleType.BattleTypeEvp then
		cclog("###########################01")
		if battle.m_isTimeOut then
			cclog("###########################02")
			self:checkEvpBattleStars(battleInfo);
		else
			cclog("###########################03 iDeadMonsterCount = " .. iDeadMonsterCount)
			cclog("###########################03 totalCount = " .. getMapCount(battle.m_beginAttackers))
			if iDeadMonsterCount ~= getMapCount(battle.m_beginAttackers) then
				cclog("###########################04")
				self.record = 1;
				self.victor = battleInfo.attacker.userid;
				self.stars = 0;
			else
				cclog("###########################05")
				self:checkEvpBattleStars(battleInfo);
			end
		end

	end
end

function VBattleResult:checkEvpBattleStars( battleInfo )
	if #self.breakRoads ~= 0 then
		self.record = 1;
		self.victor = battleInfo.attacker.userid;
		self.stars = 0;
	elseif #self.breakRoads == 0 then
		self.record = 2;
		self.victor = battleInfo.defender.userid;

		if #self.plants == 0 then
			self.stars = 3;
		elseif #self.plants <= 5 then
			self.stars = 2;
		else
			self.stars = 1;
		end
	end
end

function VBattleResult:initSingleGameRewards( battleInfo )
	if gData.offlineData:isOffline() then
		local dungeonId = battleInfo.attacker.userid;
		if battleInfo.attackType == BattleType.BattleTypePve then
			dungeonId = battleInfo.defender.userid;
		end

		local finishStars = gData.userInfo.dungeonInfo:GetLevelRecord(dungeonId);
		for k,v in pairs(battleInfo.rewardList) do
			if self.stars >= k and self.stars > finishStars then
				local rewardDatas = gData.userInfo.dungeonInfo.dungeon_rewards[v];
				if rewardDatas then
					for k,v in pairs(rewardDatas) do
						if v.type == 1 then
							if v.effect_id == AttrType.AttrTypeCurrency then
							
							elseif v.effect_id == AttrType.AttrTypeMoney then
								self.spoils.gold = self.spoils.gold + v.effect_value;
							elseif v.effect_id == AttrType.AttrTypeSunshine then
								self.spoils.sunshine = self.spoils.sunshine + v.effect_value;
							end
						elseif v.type == ThingType.ThingTypeItem or
								v.type == ThingType.ThingTypePlant or 
									v.type == ThingType.ThingTypeArm then
										local item = {};
										item.type = v.type;
										item.thingid = v.effect_id;
										item.count = v.effect_value;
										
										local thingInfo = VBattleReturnItemInfo:new(item);
										self.spoils.itemCount = self.spoils.itemCount + thingInfo.count;
										table.insert(self.spoils.itemInfos, thingInfo);
						end
					end
				end
			end
		end
	end
end

function VBattleResult:initForNewbie( road, monsters, techInfos )
	self.victor = gData.userInfo.roleInfo.id;
	self.record = 2;
	self.roads = road;
	self.breakRoads = {};
	-- self.monsters = VTroopInfo:new();
	for i,v in ipairs(monsters.armies) do
		local id = 0;
		for k,value in pairs(techInfos) do
			if value.classType == v.id then
				id = value.armyid;
			end
		end
		local armyInfo = VArmInfo:new(id);
		armyInfo:addCount(v.count);
		table.insert(self.monsters.armies, armyInfo);
	end
	self.monsters:sortWithArmId();
	self.spoils = VBattleSpoils:new();
end

------------------------------------------------

VBattleLogInfo = vclass("BattleLog")

function VBattleLogInfo:initialize(pbData)
	if pbData then
		self:synWithPbData(pbData);
	end
end

function VBattleLogInfo:synWithPbData(pbData)
	self.id = pbData.id;
	self.version = pbData.version;
	self.battleInfo = VBattleInfo:new(pbData);
	self.resultInfo = VBattleResult:new(pbData.result);
end

------------------------------------------------

VBriefBattleLogInfo = vclass("BriefBattleLogInfo")

function VBriefBattleLogInfo:initialize(pbData)
    if pbData then
        self:synWithPbData(pbData);
    end
end

function VBriefBattleLogInfo:synWithPbData(pbData)
    self.id = pbData.id
    self.attacker = VBriefUserInfo:new();
    self.attacker:synWithPbData(pbData.attacker);
    self.defender = VBriefUserInfo:new();
    self.defender:synWithPbData(pbData.defender);
    self.monsters = pbData.monsters
    self.plants = pbData.plants
    self.result = pbData.result
    self.time = pbData.time
    -- self.spoils = VBattleSpoils:new(pbData.spoils);


	self.spoils = VBattleSpoils:new();
	self.spoils:synWithRepeatedInfo(pbData.spoils);
end

function VBriefBattleLogInfo:loadFromVar( pbData )
	self.id = pbData.id
    self.attacker = VBriefUserInfo:new();
    self.attacker:synWithPbData(pbData.attacker);
    self.defender = VBriefUserInfo:new();
    self.defender:synWithPbData(pbData.defender);
    self.monsters = pbData.monsters
    self.plants = pbData.plants
    self.result = pbData.result or 1;
    self.time = pbData.time or 0;
    -- self.spoils = VBattleSpoils:new(pbData.spoils);


	self.spoils = VBattleSpoils:new();
	self.spoils:loadFromVar(pbData.spoils);
end

function VBriefBattleLogInfo:convert2VData()
	local dataTable = {};
	dataTable.id = self.id;
	dataTable.attacker = self.attacker:convert2VData();
	dataTable.defender = self.defender:convert2VData();
	dataTable.result = self.result;
	dataTable.monsters = self.monsters
	dataTable.time = self.time;
	dataTable.spoils = self.spoils:convert2VData();

	return Var(dataTable);
end

------------------------------------------------

VBattleBarrierInfo = vclass("BattleBarrierInfo")
-- 关卡数据
function VBattleBarrierInfo:initialize( )
	self.barrierList = {};	
	if true then --没有prop_gamebarrier.csv了
		return;
	end;									-- 关卡

	local propCsv = gData:readCsv("prop_gamebarrier.csv");
	local count = propCsv:lineCount()
	for i=0,count-1 do
		local prop = propCsv:lineData(i);
		self.barrierList[prop[0]] = prop;
	end

	self.barrierRewardList = {};								-- 关卡奖励

	local rewardsCsv = gData:readCsv("gamebarrier_rewards.csv");
	local count = rewardsCsv:lineCount()
	for i=0,count-1 do
		local rewards = rewardsCsv:lineData(i);
		local rewardList = nil;
		if self.barrierRewardList[rewards[0]] then
			rewardList = self.barrierRewardList[rewards[0]];
		else
			rewardList = {};
		end

		table.insert(rewardList, rewards);
		self.barrierRewardList[rewards[0]] = rewardList;
	end
end
