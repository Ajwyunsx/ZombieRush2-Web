--vBattle.lua
require "vBattleGround"

---------------------------------------  RoadPre  ---------------------------------------
RoadPre = vclass("RoadPre");

-- @Param 
-- @Return void
function RoadPre:initialize( )
	self.m_nTimeLastActive = 0;
	self.m_array = {};					-- vector<CBattleCreature*>
end

---------------------------------------  PlantPre  ---------------------------------------
PlantPre = vclass("PlantPre");

-- @Param 
-- @Return void
function PlantPre:initialize( pCreature, time )
	if pCreature then
		self.m_nPlantCreaure = pCreature;
	else
		self.m_nPlantCreaure = nil;					-- CBattleCreature*
	end

	if time then
		self.m_nTimePre = time;
	else
		self.m_nTimePre = self.m_nTimeEnd;
	end
end

---------------------------------------  CreatureReturnInfo  ---------------------------------------
CreatureReturnInfo = vclass("CreatureReturnInfo");

-- @Param 
-- @Return void
function CreatureReturnInfo:initialize( )
	self.prop = 0;						-- int
	self.kill = nil;						-- ReturnInfo
	self.die = nil;						-- ReturnInfo
end
---------------------------------------  BattleBanner  ---------------------------------------
BattleBanner = vclass("BattleBanner");

-- @Param 
-- @Return void
function BattleBanner:initialize( )
	self.iAttackAttrType = 0;		--战旗攻击属性类型
	self.iAttackAttrLevel = 1;		--战旗攻击属性等级
	self.iDefendAttrType = 0;		--战旗防守属性类型
	self.iDefendAttrLevel = 1;		--战旗防守属性等级
	self.vecBannerCreatures = {};	--战旗统率生物
end
---------------------------------------  Battle  ---------------------------------------
Battle = vclass("Battle");

-- @Param 
-- @Return void
function Battle:initialize( )
	self.m_bIsOver = false;									-- 战斗是否结束 bool  
	self.m_type = 0;										-- 1 防守战 2 进攻战  
	self.m_nTimeMax = 0;									-- 最大结束时间（毫秒）int
	self.m_nTimeEnd = 0;									-- 实际结束时间（毫秒）int
	self.m_nTimeUnit = 0;									-- 时间间隔（毫秒）int
	self.m_nTimeLastActive = 0;							-- 上次释放怪的时间  
	self.m_nCreatureIndex = 0;								-- 生物索引  
	self.m_nBulletIndex = 0;								-- 子弹索引
	self.m_bAutoPickupSunshine = false;					-- 自动拾取阳光  
	self.m_nSunshineNum = 0;								-- 阳光数量  
	self.m_nSunshineSpeed = 0;							-- 阳光掉落速度  
	self.m_nSunshineUnit = 0;								-- 单个阳光的数值  
	self.m_nSunshineLastTime = 0;							-- 上次刷新阳光的时间  
	self.m_nSunshineIndex = 0;							-- 阳光索引  
	self.m_nAttackDeadCombat = 0;						-- 进攻方死亡的战斗力  
	self.m_nDefendDeadCombat = 0;						-- 防守方死亡的战斗力  

	self.m_randFac = nil;									-- 随机数RandomFac
	self.m_ground = nil;									-- 场地信息BattleGround

	self.m_pBattleProp = BattleProp:new();					-- BattleProp*
	-- 苏醒相关  
	self.m_nWakeUpInterval = 0;							-- 第一阶段苏醒间隔  
	self.m_nWakeUpLastTime = 0;							-- 第一阶段上次苏醒时间  
	self.m_nWakeUpNum = 0;								-- 第一阶段苏醒数量  
	self.wakeUpDefenders = {};								-- 第一阶段苏醒的植物 set<int>  
 
	self.m_events = {};										-- 操作序列vector CBattleMessage
	self.m_bullets = {};										-- 子弹序列vector CBattleBullet
	self.m_activeAttackers = {};								-- vector CBattleCreature	活动的进攻者
	self.m_activeDefenders = {}; 							-- vector CBattleCreature	活动的防御者
	self.m_activeAttackObjects = {};						-- vector CBattleCreature	进攻方的物体
	self.m_activeDefendObjects = {}; 						-- vector CBattleCreature	防守方的物体
	
	self.m_PrePlants = {};									-- vector PlantPre 预备植物队列
	self.m_roadPres = {};									-- map<int, RoadPre>	预备队列
	for i=1,5 do
		self.m_roadPres[i] = RoadPre:new();
	end
	self.m_allAttacker = {};									-- map<int, CBattleCreature
	self.m_allDefender = {};									-- map<int, CBattleCreature
	self.m_beginAttackers = {};								-- map<int64, CreatureReturnInfo> 进攻方进场部队  
	self.m_livingAttackers = {};								-- map<int64, int> 剩余的进攻方部队  
	self.m_beginDefenders = {};							-- map<int64, CreatureReturnInfo> 防守方进场部队  
	self.m_livingDefenders = {};								-- map<int64, int> 剩余的防守方部队  
	self.m_sunshines = {};									-- vector<sunshineData> 阳光  
	self.m_attackSpoils = nil;								-- ReturnInfo 进攻方掉落  
	self.m_defendSpoils = nil;								-- ReturnInfo 防守方掉落  
	self.m_shovelList = {};									-- 铲子上的预备植物列表
	self.m_shovelDeadList = {};								-- 铲掉植物列表

	-- 客户端使用
	self.m_tempAttacker = {};
	--战旗
	self.m_pAttackBanner = nil;
	self.m_pDefendBanner = nil;
end

---------------------------------------  public  ---------------------------------------

-- @Param int, int, int, set<int>&, int, int, bool, int, int, int
-- @Return bool
function Battle:Create( battleType, nRandSeed, nTimeUnit, nTimeMax, roads, nRoadLen, index, bAutoPickupSunshine, nSunshineNum, nSunshineSpeed, nSunshineUnit, nFiledLevel)
	self.m_bIsOver = false;
	self.m_type = battleType;
	self.m_nTimeMax = nTimeMax;
	self.m_nTimeEnd = 0;
	self.m_nTimeUnit = nTimeUnit;
	self.m_nTimeLastActive = 0;
	self.m_nCreatureIndex = index;
	self.m_nBulletIndex = 0;

	self.m_bAutoPickupSunshine = bAutoPickupSunshine;
	if gBattleViewTest and gForceOffline then
		self.m_nSunshineNum = 4000;
	else
		self.m_nSunshineNum = nSunshineNum;
	end
	self.m_nSunshineSpeed = nSunshineSpeed;
	self.m_nSunshineUnit = nSunshineUnit;
	self.m_nSunshineLastTime = 0;
	self.m_nSunshineIndex = 0;
	self.m_nWakeUpLastTime = 0;
	self.m_nAttackDeadCombat = 0;
	self.m_nDefendDeadCombat = 0;

	self.m_randFac = VBattleRandom:new(nRandSeed)
	-- self.m_randFac.SetRandNumber(nRandSeed);

	self.m_ground = BattleGround:new();
	if not self.m_ground:Create(nRoadLen, roads, self) then
		return false;
	end

	self.m_pBattleProp = gBattleResource:GetBattleProp(self.m_type, getMapCount(roads), nFiledLevel);
	if not self.m_pBattleProp then
		return false;
	end
	
	return true;
end

-- @Param
-- @Return void
function Battle:SetBattleBanner( battleInfo )
	self.m_pAttackBanner = BattleBanner:new();
	if battleInfo and battleInfo.attacker_banner then
		if battleInfo.attacker_banner.attackAttr and battleInfo.attacker_banner.attackAttr.level and battleInfo.attacker_banner.attackAttr.value then
			self.m_pAttackBanner.iAttackAttrType = battleInfo.attacker_banner.attackAttr.value;
			self.m_pAttackBanner.iAttackAttrLevel = battleInfo.attacker_banner.attackAttr.level + 1;
		end
		if battleInfo.attacker_banner.defendAttr and battleInfo.attacker_banner.defendAttr.level and battleInfo.attacker_banner.defendAttr.value then
			self.m_pAttackBanner.iDefendAttrType = battleInfo.attacker_banner.defendAttr.value;
			self.m_pAttackBanner.iDefendAttrLevel = battleInfo.attacker_banner.defendAttr.level + 1;
		end
		if battleInfo.attacker_banner.monsters then
			for key, value in pairs(battleInfo.attacker_banner.monsters) do
				table.insert(self.m_pAttackBanner.vecBannerCreatures, value);
			end
		end
	end

	self.m_pDefendBanner = BattleBanner:new();
	if battleInfo and battleInfo.defender_banner then
		if battleInfo.defender_banner.attackAttr and battleInfo.defender_banner.attackAttr.level and battleInfo.defender_banner.attackAttr.value then
			self.m_pDefendBanner.iAttackAttrType = battleInfo.defender_banner.attackAttr.value;
			self.m_pDefendBanner.iAttackAttrLevel = battleInfo.defender_banner.attackAttr.level + 1;
		end
		if battleInfo.defender_banner.defendAttr and battleInfo.defender_banner.defendAttr.level and battleInfo.defender_banner.defendAttr.value then
			self.m_pDefendBanner.iDefendAttrType = battleInfo.defender_banner.defendAttr.value;
			self.m_pDefendBanner.iDefendAttrLevel = battleInfo.defender_banner.defendAttr.level + 1;
		end
		if battleInfo.defender_banner.plants then
			for key, value in pairs(battleInfo.defender_banner.plants) do
				table.insert(self.m_pDefendBanner.vecBannerCreatures, value);
			end
		end
	end
	-----------------------------------------------------------------------------------------------
	--[[
	cclog("################## AttackBanner Info ####################")
	cclog("AttackBanner.iAttackAttrType = " .. tostring(self.m_pAttackBanner.iAttackAttrType))
	cclog("AttackBanner.iAttackAttrLevel = " .. tostring(self.m_pAttackBanner.iAttackAttrLevel))
	cclog("AttackBanner.iDefendAttrType = " .. tostring(self.m_pAttackBanner.iDefendAttrType))
	cclog("AttackBanner.iDefendAttrLevel = " .. tostring(self.m_pAttackBanner.iDefendAttrLevel))
	local strContext = "{";
	for key,value in pairs(self.m_pAttackBanner.vecBannerCreatures) do
		strContext = strContext .. value .. ",";
	end
	strContext = strContext  .. "}";
	cclog("AttackBanner.Creatures = " .. tostring(strContext))
	cclog("################## DefendBanner Info ####################")
	cclog("DefendBanner.iAttackAttrType = " .. tostring(self.m_pDefendBanner.iAttackAttrType))
	cclog("DefendBanner.iAttackAttrLevel = " .. tostring(self.m_pDefendBanner.iAttackAttrLevel))
	cclog("DefendBanner.iDefendAttrType = " .. tostring(self.m_pDefendBanner.iDefendAttrType))
	cclog("DefendBanner.iDefendAttrLevel = " .. tostring(self.m_pDefendBanner.iDefendAttrLevel))
	local strContext = "{";
	for key,value in pairs(self.m_pDefendBanner.vecBannerCreatures) do
		strContext = strContext .. value .. ",";
	end
	strContext = strContext  .. "}";
	cclog("DefendBanner.Creatures = " .. tostring(strContext))
	--]]
	-----------------------------------------------------------------------------------------------
end

function Battle:addShovelPlantList( creatureid )
	self.m_shovelList[creatureid] = creatureid;
end

function Battle:SetBattleZombieWave( waveTime )
	if waveTime then
		self.waveTime = waveTime;
	else
		self.waveTime = {};
	end
end

-- @Param
-- @Return void
function Battle:Close( )
	-- 清理子弹
	self.m_bullets = {};
	-- 清理进攻方
	self.m_allAttacker = {};
	-- 清理进攻方的物体
	self.m_activeAttackObjects = {};
	-- 清理防守方
	self.m_allDefender = {};
	-- 清理防守方的物体
	self.m_activeDefendObjects = {};
	-- 清理进攻方进场部队
	self.m_beginAttackers = {};
	-- 清理防守方进场部队
	self.m_beginDefenders = {};
end

function Battle:GetNewCreatureId( )
	self.m_nCreatureIndex = self.m_nCreatureIndex + 1;
	return self.m_nCreatureIndex;
end

function Battle:GetNewBulletId( )
	self.m_nBulletIndex = self.m_nBulletIndex + 1;
	return self.m_nBulletIndex;
end

-- @Param 
-- @Return int
function Battle:GetType( )
	return self.m_type;
end

-- @Param 
-- @Return int
function Battle:GetCurrentTime( )
	return self.m_nTimeEnd;
end

-- @Param 
-- @Return int
function Battle:GetUnitTime( )
	return self.m_nTimeUnit;
end

-- @Param 
-- @Return int
function Battle:GetRandom( min, max )
	return self.m_randFac:RandBetween(min, max);
end

-- @Param int
-- @Return
function Battle:SetAttackDeadCombat( val )
	self.m_nAttackDeadCombat = self.m_nAttackDeadCombat + val;
end

-- @Param 
-- @Return int
function Battle:GetAttackDeadCombat( )
	return self.m_nAttackDeadCombat;
end

-- @Param int
-- @Return
function Battle:SetDefendDeadCombat( val )
	self.m_nDefendDeadCombat = self.m_nDefendDeadCombat + val;
end

-- @Param 
-- @Return int
function Battle:GetDefendDeadCombat( )
	return self.m_nDefendDeadCombat;
end

-- @Param 
-- @Return bool
function Battle:IsOver( )
	return self.m_bIsOver;
end

-- @Param long long
-- @Return void
function Battle:Update( time )
	if self:IsOver() then
		return;
	end

	local nRunTimes = 0;
	--  首次运行
	if self.m_nTimeEnd == 0 then
		self.m_nTimeEnd = time;
		nRunTimes = 1;
	else
		nRunTimes = (time - self.m_nTimeEnd) / self.m_nTimeUnit;
	end

	for i=1,nRunTimes do
		self.m_nTimeEnd = self.m_nTimeEnd + self.m_nTimeUnit;

		if self:IsOver() then
			return;
		end

		self:_UpdateOnce();

		if self.m_nTimeEnd >= self.m_nTimeMax then
			self:_BattleEnd(true);
			return;
		end
	end
end

-- @Param int
-- @Return BattleCreature *
function Battle:GetAttackCreature( id )
	return self.m_allAttacker[id];
end

-- @Param int
-- @Return BattleCreature *
function Battle:GetDefendCreature( id )
	return self.m_allDefender[id];
end

-- @Param int, int
-- @Return BattleCreature *
function Battle:GetCreature( bAttack, id )
	if bAttack then
		return self.m_allAttacker[id];
	else
		return self.m_allDefender[id];
	end
end

-- @Param BattleCreature *
-- @Return bool
function Battle:AddCreatureToMgr( pCreature, isSummon )
	if pCreature:GetIsAttack() then
		self.m_allAttacker[pCreature:GetId()] = pCreature;
		if self:GetType() ~= BattleType.BattleTypeEvp then
			if isSummon then
				return true;
			end
			self:ReduceSunshineValue(pCreature);
		end
	else
		self.m_allDefender[pCreature:GetId()] = pCreature;
		if self:GetType() == BattleType.BattleTypeEvp then
			self:ReduceSunshineValue(pCreature);
		end
	end
	
	return true;
end

-- @Param CBattleCreature*, int, int, bool
-- @Return bool

function Battle:ActiveCreature( pCreature, road, pos, bMoveAction)
	if pCreature == nil then
		return false;
	end

	if pCreature:GetMode() == EUnitType.TYPE_CREATURE then
		if not self.m_ground:AddUnit(road, pos, pCreature) then
			return false;
		end
		
		if pCreature:GetIsAttack() then
			self.m_activeAttackers[pCreature:GetId()] = pCreature;
		else
			self.m_activeDefenders[pCreature:GetId()] = pCreature;
		end
	elseif pCreature:GetMode() == EUnitType.TYPE_CREATURE_OBJECT then
		if not pCreature:isInstanceOf(BattleObject) then 
			return false;
		end

		if not self.m_ground:AddUnit(road, pos, pCreature) then
			return false;
		end

		if pCreature:GetIsAttack() then
			self.m_activeAttackObjects[pCreature:GetId()] = pCreature;
		else
			self.m_activeDefendObjects[pCreature:GetId()] = pCreature;
		end
	end

	if bMoveAction == nil then
		bMoveAction = true;
	end

	if bMoveAction then
		pCreature:SetAction(ECreatureAction.ACTION_MOVE);
	end

	if pCreature:isInstanceOf(BattleObject) then
		pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_ACTIVE_TIME, 0);
	elseif pCreature:isInstanceOf(BattleCreature) then
		pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_ACTIVE_TIME, self:GetCurrentTime());
	end

	return true;
end

-- @Param int, int
-- @Return bool
function Battle:AddPreAttacker( id, road )
	local pCreature = self:GetAttackCreature(id);
	if pCreature == nil then
		return false;
	end
	pCreature:SetRoad(road);

	if #self.m_roadPres[road].m_array == 0 then
		self.m_roadPres[road].m_nTimeLastActive = self.m_nTimeEnd;
	end
	table.insert(self.m_roadPres[road].m_array, pCreature);

	return true;
end

function Battle:AddPreDefender( id, time )
	local pCreature = self:GetDefendCreature(id);
	if pCreature == nil then
		return false;
	end

	local preData = PlantPre:new(pCreature, time);
	self.m_PrePlants[id] = preData;

	return true;
end

function Battle:AddTempAttack( pCreature )
	self.m_tempAttacker[pCreature:GetId()] = pCreature;
end

function Battle:GetAttackObject( id )
	return self.m_activeAttackObjects[id];
end

function Battle:GetDefendObject( id )
	return self.m_activeDefendObjects[id];
end

-- @Param int, int, vector<int>&
-- @Return void
function Battle:GetAttackByPos( road, pos, objs )
	-- body
end

-- @Param int, int, vector<int>&
-- @Return void
function Battle:GetDefendByPos( road, pos, objs )
	-- body
end

-- @Param CBattleBullet* 
-- @Return void
function Battle:ActiveBullet( pBullet )
	self.m_bullets[pBullet:GetId()] = pBullet;
	-- table.insert(self.m_bullets, pBullet);
end

-- @Param 
-- @Return CBattleGround &
function Battle:GetGround( )
	return self.m_ground;
end

-- @Param 
-- @Return int
function Battle:GetSunshineValue( )
	return self.m_nSunshineNum - gBattleView.PrepareSunshine;
end

-- @Param CBattleCreature* 
-- @Return void
function Battle:ReduceSunshineValue( pCreature )
	local iNeedSunshine = pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_COST);
	
	if pCreature:GetIsAttack() then
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_SUNSHINE_CONSUME, pCreature, self.m_nSunshineNum,iNeedSunshine);
	end
	
	gBattleView:reducePrepareSunshine(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_COST));
	self.m_nSunshineNum = self.m_nSunshineNum - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_COST);
end

-- @Param int
-- @Return 
function Battle:AddSunshine( val, time, pCreature )
	local data = SunshineData:new();
	data.id = self.m_nSunshineIndex;
	data.time = time;
	data.value = val;

	table.insert(self.m_sunshines, data);
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_NEW_SUNSHINE, pCreature, data);

	self.m_nSunshineIndex = self.m_nSunshineIndex + 1;
end

-- @Param SunshineData&
-- @Return 
function Battle:PickupSunshine( data )
	self.m_nSunshineNum = self.m_nSunshineNum + data.value;
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_SUNSHINE, data, self.m_nSunshineNum);
end

-- @Param int, int, int, vector<int>&
-- @Return void
function Battle:AddEvent( event )
	-- event.params 保存的僵尸id号 现在暂时没用，暂时先留着
	-- event.params2 保存int64的唯一id
	if event then
		table.insert(self.m_events, event);
	end
end

function Battle:UpdateAttackers( k, v )
	local pAttacker = v;
	if pAttacker:GetValid() then
		pAttacker:Update(self.m_nTimeEnd, self);
	end

	if pAttacker:IsDead() then
		self:GetGround():DelUnit(pAttacker);
		-- 添加事件
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DEATH, pAttacker);
	end

	if not pAttacker:GetValid() then
		--cclog("*********** Battle:UpdateAttackers k = "..k);
		--cclog("***** not valid pAttacker GetExtra = "..pAttacker:GetExtra());
		if self.m_livingAttackers then
			--cclog("******  self.m_livingAttackers = nil");
			self.m_livingAttackers[pAttacker:GetExtra()] = nil;
		end
		if self.m_activeAttackers then
			self.m_activeAttackers[k] = nil;
		end
	end
end

-- function Battle:AddTroop( id, num )
-- 	-- 逻辑
-- 	if not self.m_livingMonsters[id] then
-- 		self.m_livingMonsters[id] = 0;
-- 	end
-- 	self.m_livingMonsters[id] = self.m_livingMonsters[id] + num;
-- 	-- 界面
-- 	gBattleView.validTroopCount = gBattleView.validTroopCount + num;
-- end

function Battle:CheckPostion(road, pos)
	if (road == -1) or (pos == -1) then
		return false;
	end

	if not self:GetGround():HasRoad(road) then
		return false;
	end

	if (pos > self:GetGround():GetLen()) or (pos <= 0) then
		return false;
	end

	return true;
end

function Battle:AddAttacker( battleMonster )
	-- BattleMonster模型 int64唯一id是key，value是属性propid
	-- cclog("********* Battle:AddAttacker  battleMonster.id = "..battleMonster.id);
	self.m_livingAttackers[battleMonster.id] = battleMonster.propid;
	
	local pCreatureInfo = CreatureReturnInfo:new();
	pCreatureInfo.prop = battleMonster.propid;
	pCreatureInfo.kill = battleMonster.kill_ret;
	pCreatureInfo.die = battleMonster.die_ret;
	self.m_beginAttackers[battleMonster.id] = pCreatureInfo;
	-- 界面
	gBattleView.validTroopCount = gBattleView.validTroopCount + 1;
	self:_preoadResources(true,battleMonster.propid);
end

function Battle:AddLivingAttackers( id, propId )
	-- cclog("********* Battle:AddLivingAttackers  id = "..id);
	self.m_livingAttackers[id] = propId;
	-- 界面
	-- gBattleView.validTroopCount = gBattleView.validTroopCount + 1;
end

function Battle:AddDefender( battlePlant )
	self.m_livingDefenders[battlePlant.id] = battlePlant.propId;

	local pCreatureInfo = CreatureReturnInfo:new();
	pCreatureInfo.prop = battlePlant.propid;
	pCreatureInfo.kill = battlePlant.kill_ret;
	pCreatureInfo.die = battlePlant.die_ret;
	self.m_beginDefenders[battlePlant.id] = pCreatureInfo;
	self:_preoadResources(false,battlePlant.propid);
end

-- @Param bool, int64
-- @Return CreatureReturnInfo
function Battle:GetCreatureReturnInfo( bAttack, id )
	if bAttack then
		return self.m_beginAttackers[id];
	else
		return self.m_beginDefenders[id];
	end
end

function Battle:GetSpoils( bAttack )
	if bAttack then
		return self.m_attackSpoils;
	else
		return self.m_defendSpoils;
	end
end

function Battle:GetReplantPlantCount()
	return self.m_ground:GetReplantPlantCount();
end

--获取生物战旗属性
function Battle:GetCreatureBannerAttr( bIsAttack, iRace )
	local iAttackAttrType = 0;
	local iAttackAttrLevel = 1;
	local iDefendAttrType = 0;
	local iDefendAttrLevel = 1;

	local battleBanner = nil;
	if bIsAttack then
		battleBanner = self.m_pAttackBanner;
	else
		battleBanner = self.m_pDefendBanner;
	end
	
	for key,value in pairs(battleBanner.vecBannerCreatures) do
		if tonumber(iRace) == tonumber(value) then
			iAttackAttrType = battleBanner.iAttackAttrType;
			iAttackAttrLevel = battleBanner.iAttackAttrLevel;
			iDefendAttrType = battleBanner.iDefendAttrType;
			iDefendAttrLevel = battleBanner.iDefendAttrLevel;
			break;
		end
	end
	
	return iAttackAttrType,iAttackAttrLevel,iDefendAttrType,iDefendAttrLevel;
end
---------------------------------------  private  ---------------------------------------

-- @Param 
-- @Return void
function Battle:_UpdateOnce( )
	-- 处理铲子挖植物
	self:_UpdateShovel();

	-- 处理大波僵尸时间
	self:_UpdateWaveTime();

	-- 处理阳光
	self:_UpdateSunshine();

	-- 植物惊醒处理  
	self:_UpdateWakeUp();

	-- 操作消息处理
	self:_UpdateEvent();

	-- 植物预备队列处理
	for k,v in pairs(self.m_PrePlants) do
		if self.m_nTimeEnd > v.m_nTimePre then
			self:ActiveCreature(v.m_nPlantCreaure, v.m_nPlantCreaure:GetRoad(), v.m_nPlantCreaure:GetPos());
			self.m_PrePlants[k] = nil;
		end
	end

	-- 怪物预备队列处理
	for k,v in pairsByKeys(self.m_roadPres) do
		if #v.m_array ~= 0 and v.m_nTimeLastActive ~= 0 and self.m_nTimeEnd - v.m_nTimeLastActive >= 1520 then
			local pCreature = v.m_array[1];
			self:ActiveCreature(pCreature, pCreature:GetRoad(), self.m_ground:GetLen());
			table.remove(v.m_array, 1);
			if #v.m_array ~= 0 then
				v.m_nTimeLastActive = self.m_nTimeEnd;
			else
				v.m_nTimeLastActive = 0;
			end
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ZOMBIE_ACTIVE, pCreature);
		end
	end

	-- 子弹处理
	for k,v in pairsByKeys(self.m_bullets) do
		local bullet = v;
		bullet:Update(self.m_nTimeEnd, self);

		if not bullet:GetValid() then
			self.m_bullets[k] = nil;
		end
	end

	-- 防守方处理
	for k,v in pairsByKeys(self.m_activeDefenders) do
		local pDefender = v;
		if pDefender:GetValid() then		
			pDefender:Update(self.m_nTimeEnd, self);
		end

		if not pDefender:GetValid() then

			self:GetGround():DelUnit(pDefender);
			
			-- 添加事件
			if pDefender:IsDead() then
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DEATH, pDefender);
			end

			self.m_activeDefenders[k] = nil;
		end
	end

	-- 防守方物体处理
	for k,v in pairsByKeys(self.m_activeDefendObjects) do
		local pObject = v;
		pObject:Update(self.m_nTimeEnd, self);

		if not pObject:GetValid() then
			self:GetGround():DelUnit(pObject);
			-- 添加事件
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DEATH, pObject);
			self.m_activeDefendObjects[k] = nil;
		end
	end

	-- 进攻方处理
	for k,v in pairsByKeys(self.m_activeAttackers) do
		self:UpdateAttackers(k, v);
	end

	-- 召唤怪物第一次处理 
	for k,v in pairsByKeys(self.m_tempAttacker) do
		self:UpdateAttackers(k, v);
		-- 召唤怪第一次处理完 从临时列表中删除
		self.m_tempAttacker[k] = nil;
	end

	-- 进攻方物体处理
	for k,v in pairsByKeys(self.m_activeAttackObjects) do
		local pObject = v;
		pObject:Update(self.m_nTimeEnd, self);

		if not pObject:GetValid() then			
			self:GetGround():DelUnit(pObject);
			-- 添加事件
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DEATH, pObject);
			self.m_activeAttackObjects[k] = nil;
		end
	end

	-- 道路是否被打通
	for k,v in pairs(self.m_ground:GetRoads()) do
		if v:GetValid() then
			local obj = {};
			v:GetAllCreature(true, obj);
			for kk,pCreature in pairs(obj) do
				assert(pCreature ~= nil, "Battle:_UpdateOnce( ) Error pCreature = nil");
				if pCreature:GetPos() == 0 then
					v:SetValid(false);
					break;
				end
			end
		end
	end

	-- 判断是否结束
	self:_BattleEnd(false);
end

-- @Param bool
-- @Return void
function Battle:_BattleEnd( bTimeout )
	if self.m_bIsOver then
		return;
	end
	-- 1.超时
	-- 2.所有路被突破
	-- 3.所有怪物被消灭

	if bTimeout then
		-- 添加事件
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_BATTLE_END);
		self.m_isTimeOut = true;
		self.m_bIsOver = true;
		return;
	end

	local bOver = false;
	repeat
		-- 怪物死亡 战斗结束
		-- cclog("*********** getMapCount(self.m_livingAttackers) = "..getMapCount(self.m_livingAttackers));
		bOver = (getMapCount(self.m_livingAttackers) == 0);

		if bOver then
			break;
		end

		-- 道路打通，战斗结束
		local isAllRoadBreak = true;
		local hasRoadBeenBreak = false;
		for k,v in pairs(self.m_ground:GetRoads()) do
			if v:GetValid() then
				isAllRoadBreak = false;
			else
				hasRoadBeenBreak = true;
			end
		end
		if isAllRoadBreak then
			bOver = true;
			gBattleView.isAllRoadBreak = true;
		end
		if hasRoadBeenBreak and gBattleView.battleInfo.attackType == BattleType.BattleTypeEvp then
			bOver = true;
		end
	until true

	if bOver then
		-- 添加事件
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_BATTLE_END);
		self.m_bIsOver = true;
		
		self.m_nTimeEnd = self.m_nTimeEnd + 960;
		if self.m_nTimeEnd >= self.m_nTimeMax then
			self.m_nTimeEnd = self.m_nTimeMax;
		end
		if gBattleView.battleInfo.attackType == BattleType.BattleTypeEvp then
			gBattleView:battleEvpViewIsOver();
		end
	end
end

-- @Param CBattleEvent
-- @Return void
function Battle:_EventAddMonster( event )
	if #event.params2 == 0 then
		cclog("Battle:_EventAddMonster Error #event.params2 == 0");
		return;
	end

	-- 检查怪物是否存在  
	local monster64Id = event.params2[1];
	local pCreatureInfo = self.m_beginAttackers[monster64Id];
	if not pCreatureInfo then
		cclog("Battle:_EventAddMonster Error pCreatureInfo = nil");
		cclog("Battle:_EventAddMonster Error monster64Id = "..monster64Id);
		return;
	end

	-- 怪物属性  
	local pMonsterProp = gBattleResource:GetMonsterProp(pCreatureInfo.prop);
	if pMonsterProp == nil then
		cclog("Battle:_EventAddMonster Error pMonsterProp = nil");
		return;
	end

	-- 创建怪物对象  
	local pMonster = BattleCreature:new(pMonsterProp);
	if not pMonster then
		cclog("Battle:_EventAddMonster Error pMonster = nil");
		return;
	end

	-- 初始化怪物  
	if not pMonster:Create(true, self:GetNewCreatureId(), self, monster64Id) then
		cclog("Battle:_EventAddMonster Error pMonster Create false");
		return;
	end
	pMonster:InitMonster();
	----测试：阳光不足上报服务器客户端实时数据----
	if #event.params == 5 then
		table.insert(event.params,self.m_nSunshineNum);
	end
	----------------------------------------------
	-- 添加到对象管理
	if not self:AddCreatureToMgr(pMonster) then
		cclog("Battle:_EventAddMonster AddCreatureToMgr Error");		
		return;
	end

	-- 添加到预备队列
	self:AddPreAttacker(pMonster:GetId(), event.road);
	event:setTime(self:GetCurrentTime());

	pMonster.isReadyEnter = true;
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ZOMBIE_ENTER, pMonster, event.time);
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ADD_UNIT, pMonster, event.time);

	-- 回调
	gBattleView:addEventReadySendRequest(event);
end

-- @Param 
-- @Return void
function Battle:_EventAddSunshine( event )
	for i,v in ipairs(event.params2) do
		for j=1,#self.m_sunshines do
			local data = self.m_sunshines[j];
			if tonumber(v) == data.id then
				self:PickupSunshine(data);
				table.remove(self.m_sunshines, j);

				event.time = self:GetCurrentTime();
				-- 回调
				gBattleView:addEventReadySendRequest(event);
				break;
			end
		end
	end
end

-- @Param 
-- @Return void
function Battle:_UpdateSunshine( )
	-- 处理超时的阳光
	for i=#self.m_sunshines,1,-1 do
		local data = self.m_sunshines[i];
		local timeout = self:GetCurrentTime() - data.time;
		if timeout >= gBattleResource:SunshineTimeoutParam()  then
			if self.m_bAutoPickupSunshine then
				self:PickupSunshine(data);
			end
			table.remove(self.m_sunshines, i);
		end
	end

	-- 刷新
	local interval = self:GetCurrentTime() - self.m_nSunshineLastTime;
	if interval <= self.m_nSunshineSpeed then
		return;
	end

	self.m_nSunshineLastTime = self.m_nSunshineLastTime + self.m_nSunshineSpeed;
	self:AddSunshine(self.m_nSunshineUnit, self.m_nSunshineLastTime);
end

-- @Param 
-- @Return void
function Battle:_UpdateEvent( )
	-- 操作消息处理
	local deleteList = {};
	for i=1,#self.m_events do
		local event = self.m_events[i];
		if self.m_nTimeEnd >= event.time then
			-- 添加怪物到预备队列  
			if event.type == EBattleLogEvent.LOG_EVENT_ADD_UNIT then
				self:_EventAddMonster(event);
				table.insert(deleteList, i);
			elseif event.type == EBattleLogEvent.LOG_EVENT_SUNSHINE then
				self:_EventAddSunshine(event);
				table.insert(deleteList, i);
			end
		end
	end

	table.sort(deleteList,
		function(a,b)
			return a > b;
		end);

	if self.m_events and deleteList then
		for i=1,#deleteList do
			table.remove(self.m_events, deleteList[i]);
		end
	end
end

function Battle:_UpdateWakeUp( )
	if self.m_pBattleProp.first_stat == 0 and self.m_pBattleProp.second_stat == 0 then
		return;
	end

	if self.m_nWakeUpLastTime == 0 then
		self.m_nWakeUpNum = math.floor(getMapCount(self.m_allDefender) * self.m_pBattleProp.first_prob / 100);
		local interval = self.m_pBattleProp.second_stat - self.m_pBattleProp.first_stat;
		if interval ~= 0 and self.m_nWakeUpNum > 0 then
			interval = interval / self.m_nWakeUpNum;
			interval = math.min(interval, self.m_pBattleProp.first_interval);
		end
		self.m_nWakeUpInterval = interval;
	end

	-- 第一阶段
	if self.m_pBattleProp.first_stat <= self.m_nTimeEnd and self.m_nTimeEnd < self.m_pBattleProp.second_stat and self.m_nWakeUpNum > 0 then
		-- 随机找一个植物，苏醒
		if self.m_nWakeUpLastTime == 0 or self.m_nTimeEnd > (self.m_nWakeUpLastTime + self.m_nWakeUpInterval) then
			local creatures = {};
			for k,defendCreature in pairsByKeys(self.m_allDefender) do
				if defendCreature:IsSleep() then
					table.insert(creatures, defendCreature);
				end
			end

			self.m_nWakeUpLastTime = self.m_nTimeEnd;
			if #creatures == 0 then
				return;
			end

			local nRandNum = self:GetRandom(1, #creatures);
			creatures[nRandNum]:WakeUp();
			self.m_nWakeUpNum = self.m_nWakeUpNum - 1;
		end
	end

	-- 第二阶段
	if self.m_pBattleProp.second_stat <= self.m_nTimeEnd then
		for k,defendCreature in pairsByKeys(self.m_allDefender) do
			defendCreature:WakeUp();
		end
	end
end

function Battle:_preoadResources( bIsAttack, id )
	local strName = "";
	if bIsAttack then
		local prop = gBattleResource:GetMonsterProp(id);
		strName = prop.m_image;
	else
		local prop = gBattleResource:GetPlantProp(id);
		strName = prop.m_image;
	end
	VArmature:addArmatureFile(strName);
end

-- 客户端独有方法：检查大波僵尸触发时间
function Battle:_UpdateWaveTime( )
	for k,v in pairs(self.waveTime) do
		if self:GetCurrentTime() > v then
			self.waveTime[k] = nil;
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_WAVE_ZOMBIE_ATTACK);
		end
	end
end

function Battle:_UpdateShovel( )
	for k,v in pairs(self.m_shovelList) do
		local pDefender = self.m_activeDefenders[v];
		if pDefender then
			pDefender:SetValid(false);
			self:GetGround():DelUnit(pDefender);
			
			if pDefender:IsFullBlood() then
				pDefender.isShovel = true;
				self.m_shovelDeadList[v] = v;
			end
			-- 添加事件
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_SHOVEL, pDefender);

			self.m_shovelList[k] = nil;
			self.m_activeDefenders[v] = nil;
		end
	end
end