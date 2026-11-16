--vBattleResource.lua

local local_bit = gBit;

---------------------------------------  AttrProp  ---------------------------------------
AttrProp = vclass("AttrProp");

function AttrProp:initialize( )
	self.value = 0;					-- int 基础值  
	self.x = 0;						-- float 正向影响  
	self.y = 1.0;						-- float 负向影响  
	self.z = 0;						-- float 最终影响  
end

function AttrProp:copy( pProp )
	local newAttrProp = AttrProp:new();
	newAttrProp.value = pProp.value;
	newAttrProp.x = pProp.x;
	newAttrProp.y = pProp.y;

	return newAttrProp;
end

---------------------------------------  DamageProp  ---------------------------------------
DamageProp = vclass("DamageProp");

function DamageProp:initialize( )
	self.m_value = 0;					-- float 基础值  
	self.m_x = 0;						-- float 正向影响  
	self.m_y = 1.0;						-- float 负向影响  
	self.m_z = 0;						-- float 最终影响  
	self.m_nDamageRace = 0;			-- int 攻击类型  
	self.m_nDamageType = 0;			-- int 伤害类型
	self.m_nAttrType = 0;			-- int 伤害属性类型
	self.m_nAttrLevel = 1;			-- int 伤害属性等级
end

function DamageProp:copyWithProp( prop )
	self.m_value = prop.m_value;
	self.m_x = prop.m_x;
	self.m_y = prop.m_y;
	self.m_z = prop.m_z;
	self.m_nDamageRace = prop.m_nDamageRace;
	self.m_nDamageType = prop.m_nDamageType;
	self.m_nAttrType = prop.m_nAttrType;
	self.m_nAttrLevel = prop.m_nAttrLevel;
end

function DamageProp:GetValue( )
	return self.m_value;
end

function DamageProp:SetValue( val )
	self.m_value = val;
end

function DamageProp:GetX( )
	return self.m_x;
end

function DamageProp:SetX( val )
	self.m_x = val;
end

function DamageProp:GetY( )
	return self.m_y;
end

function DamageProp:SetY( val )
	self.m_y = val;
end

function DamageProp:GetZ( )
	return self.m_z;
end

function DamageProp:SetZ( val )
	self.m_z = val;
end

function DamageProp:GetDamageRace( )
	return self.m_nDamageRace;
end

function DamageProp:SetDamageRace( val )
	self.m_nDamageRace = val;
end

function DamageProp:GetDamageType( )
	return self.m_nDamageType;
end

function DamageProp:SetDamageType( val )
	self.m_nDamageType = val;
end

function DamageProp:SetAttrType( val )
	self.m_nAttrType = val;
end

function DamageProp:GetAttrType( )
	return self.m_nAttrType;
end

function DamageProp:SetAttrLevel( val )
	self.m_nAttrLevel = val;
end

function DamageProp:GetAttrLevel( )
	return self.m_nAttrLevel;
end
---------------------------------------  SkillStatus  ---------------------------------------
SkillStatus = vclass("SkillStatus");

function SkillStatus:initialize( )
	self.pre = 0;					-- int 前摇
	self.post = 0;					-- int 后摇
	self.times = 0;					-- int 次数
	self.nLastTime = 0;				-- int 上次释放时间
end

---------------------------------------  BulletProp  ---------------------------------------
BulletProp = vclass("BulletProp");

function BulletProp:initialize( )
	self.id = 0;								-- int 
	self.attack_type = 0;       				-- int 1 地 2 空 3 两者  
	self.type = -1;	      					-- int 0 不追踪 1 追踪  2回旋镖
	self.buff = 0;    	  						-- int buff  
	self.self_attack = -1;					-- 自身攻击 (0 无 1 有）  
	self.speed = 0;							-- 速度
	self.num = 0;							-- 伤害次数  
	self.wakeup	 = 0;						-- 0 可以打醒植物 1 不可以打醒植物  
	self.animationType = -1;
	self.name = "";

	-- 暂时没用
	self.cycle = 0;							-- 加速度

	-- 客户端使用
	self.image = "";
end

---------------------------------------  BattleCondition  ---------------------------------------
BattleCondition = vclass("BattleCondition");

function BattleCondition:initialize( )
	self.id = 0;								-- int
	self.expressionId = 0;       				-- int
	self.params = {};      					-- vector<int>
end

---------------------------------------  BattleEffectProp  ---------------------------------------
BattleEffectProp = vclass("BattleEffectProp");

function BattleEffectProp:initialize( )
	self.id = 0;						-- int
	self.expressionId = 0;			-- int
	self.target = 0;					-- int
	self.target_range = 0;			-- int
	self.target_num = 0;			-- int
	self.magic_valid = 0;			-- int
	self.params = {};				-- vector
end

---------------------------------------  BattleBuffData  ---------------------------------------
BattleBuffData = vclass("BattleBuffData");

function BattleBuffData:initialize( )
	self.time = 0;					-- int 持续时间  
	self.cd = 0;						-- int 处理间隔  
	self.event = 0;					-- int 触发阶段  
	self.overlap_max = 0;			-- int 最大叠加次数  
	self.overlap_value = 0;			-- int 叠加参数  
	self.remove_type = 0;			-- int buff消除类型  
end

---------------------------------------  BattleSkillData  ---------------------------------------
BattleSkillData = vclass("BattleSkillData");

function BattleSkillData:initialize( )
	self.family = 0;					-- int 技能组
	self.pre = 0;					-- int 前摇
	self.post = 0;					-- int 后摇
end

---------------------------------------  BattleBuffProp  ---------------------------------------
BattleBuffProp = vclass("BattleBuffProp");

-- @Param BattleBuffProp*
-- @Return void
function BattleBuffProp:initialize( other )
	self.m_id = 0;										-- int
	self.m_type = 0;									-- int
	self.m_skillData = BattleSkillData:new();				-- BattleSkillData
	self.m_buffData = BattleBuffData:new();			-- BattleBuffData
	self.m_conditions = {};								-- map<int, BattleCondition*>
	self.m_effects = {};									-- vector
	self.m_strName = "";
	-- for Animation
	self.m_buffAnimation = {};

	if other then
		self.m_id = other.m_id;
		self.m_type = other.m_type;
		self.m_skillData = other.m_skillData;
		self.m_buffData = other.m_buffData;
		self.m_conditions = other.m_conditions;
		self.m_effects = other.m_effects;

		self.m_buffAnimation = other.m_buffAnimation;
	end
end

---------------------------------------  CreatureCommon  ---------------------------------------
CreatureCommon = vclass("CreatureCommon");

-- @Param
-- @Return void
function CreatureCommon:initialize( )
	self.spikeweed_attack = 0;			-- 钢锯地刺攻击时间  
	self.spikeweed_stop = 0;			-- 钢锯地刺休息时间  
	self.spikeweed_damage = 0;		-- 钢锯地刺伤害加成  
end

---------------------------------------  BattleProp  ---------------------------------------
BattleProp = vclass("BattleProp");

function BattleProp:initialize( )
	self.type = 0;						-- 见pb_common::BattleType  
	self.road = 0;						-- 道路数  
	self.time = 0;						-- 最大时间  
	self.first_stat = 0;					-- 第一阶段开始时间  
	self.first_interval = 0;				-- 第一阶段苏醒间隔  
	self.first_prob = 0;					-- 第一阶段苏醒比例  
	self.second_stat = 0;				-- 第二阶段开始时间  
	self.sunshine = 0;					-- 初始阳光  
	self.limit = 0;						-- 卡牌限制方案
	self.fieldLevel = 0;				-- 田地等级  
end

---------------------------------------  DanceData  ---------------------------------------
DanceData = vclass("DanceData");

function DanceData:initialize( )
	self.id = 0;							-- 方案号  
	self.probability = 0;					-- 概率  
	self.monsterid = 0;					-- 怪物id  
	self.hp_param = 0;					-- 血量百分比  
	self.attack_param = 0;				-- 攻击百分比  
	self.defend_param = 0;				-- 防御百分比
	self.born_buffid = 0;				-- 出生BUFF ID
	self.born_bufftime = 0;				-- 出生BUFF Time  
end

---------------------------------------  SunshineData  ---------------------------------------
SunshineData = vclass("SunshineData");

function SunshineData:initialize( )
	self.id = 0;
	self.time = 0;
	self.value = 0;
end
---------------------------------------  DropItemData  ---------------------------------------
DropItemData = vclass("DropItemData");
function DropItemData:initialize( )
	self.id = 0;
	self.userId = "";
	self.type = 0;
	self.thingId = 0;
	self.count = 0;
end
---------------------------------------  AltarData  ---------------------------------------
AltarData = vclass("AltarData");
function AltarData:initialize( )
	self.upgradeCoin = 0;
	self.upgradeSunshine = 0;
	self.upgradeTime = 0;
	self.sunshinePeriod = 0;
	self.sunshineCount = 0;
	self.darkSunshinePeriod = 0;
	self.darkSunshineCount = 0;
	self.baseCampLimit = 0;
end
---------------------------------------  BattleEvent  ---------------------------------------

BattleEvent = vclass("BattleEvent");

function BattleEvent:initialize( )
	self.type = 0;   								-- int 事件类型  
	self.time = 0;								-- int
	self.road = 0;								-- int
	self.params = {};							-- vector<int> 
	self.params2 = {};							-- vector<int> 
	self.dirty = false;							
end

------------------------------  客户端专用，生成BattleEvent  ------------------------------
function BattleEvent:synWithPbData(pbData)
	self.type = pbData.type;
	self.time = pbData.time;
	self.road = pbData.road;
	self.params = {};
	if pbData.params then
		local iter = VDataIter();
		while pbData.params:Travel(iter) do
			local value = iter:Data();
			table.insert(self.params, value);
		end
	end
	self.params2 = {};
	if pbData.params2 then
		local iter = VDataIter();
		while pbData.params2:Travel(iter) do
			local value = iter:Data();
			table.insert(self.params2, tostring(value));
		end
	end
end

function BattleEvent:initWithCsvData( csvData, id )
	self.type = EBattleLogEvent.LOG_EVENT_ADD_UNIT;
	self.time = csvData[2];
	self.road = csvData[3];
	self.params = {};
	self.params2 = {id};
	self.propid = csvData[1];
end

function BattleEvent:initWithDatas( eventType, road, pos, paramsId )
	self.type = eventType;
	self.road = road;
	self.params = {};
	if pos then
		self.params = {pos};
	end
	self.params2 = {paramsId};
end

function BattleEvent:setTime( eventTime )
	self.time = eventTime;
end
----------------------------------------------

---------------------------------------  BattleUnit  ---------------------------------------
BattleUnit = vclass("BattleUnit");

-- @Param EUnitType, BattleUnit*
-- @Return void
function BattleUnit:initialize( unitType, otherProp )
	self.m_attr = {};							-- vector<int>
	if otherProp then
		if otherProp.m_attr then
			for k,v in pairs(otherProp.m_attr) do
				self.m_attr[k] = AttrProp:copy(v);
			end
		else
			for i=0,ECreatureAttr.CREATURE_ATTR_MAX do
				self.m_attr[i] = AttrProp:new();
			end
		end
		self.m_strName = otherProp.m_strName;
		self.m_image = otherProp.m_image;
		self.m_level = otherProp.m_level;
		self.m_quality = otherProp.m_quality;
		self.m_scale = otherProp.m_scale;
		self.m_speedScale = otherProp.m_speedScale;
	else
		for i=0,ECreatureAttr.CREATURE_ATTR_MAX do
			self.m_attr[i] = AttrProp:new();
		end
		self.m_strName = "";														-- 生物名
		self.m_image = "";															-- 图片名
		self.m_level = 1;															-- 生物等级
		self.m_quality = 1;
		self.m_scale = 60;															-- 骨骼缩放比例
		self.m_speedScale = 100;													-- 骨骼动画速率
	end

	self.m_bValid = false;
	self.m_bIsAttack = false;
	self.m_mode = unitType;
	self.m_id = 0;
	self.m_pos = -1;
	self.m_road = -1;
	self.m_nLastPos = -1;
	self.m_target = 0;																-- 目标
	self.m_attackDamage = DamageProp:new();									-- 进攻伤害  
	self.m_defendDamage = DamageProp:new();									-- 防守伤害  
	self.m_skillStatus = {};															-- 技能状态  map<int, SkillStatus>
end

-- @Param 
-- @Return int
function BattleUnit:GetId( )
	return self.m_id;
end

-- @Param int
-- @Return void
function BattleUnit:SetId( val )
	self.m_id = val;
end

-- @Param 
-- @Return EUnitType
function BattleUnit:GetMode( )
	return self.m_mode;
end

-- @Param EUnitType
-- @Return void
function BattleUnit:SetMode( val )
	self.m_mode = val;
end

-- @Param Enum:ECreatureAttr
-- @Return int
function BattleUnit:GetAttr( key )
	return math.floor(self:GetFloatAttr(key));
end

-- @Param Enum:ECreatureAttr
-- @Return int
function BattleUnit:GetFloatAttr( key )
	assert(key < ECreatureAttr.CREATURE_ATTR_MAX, "BattleUnit:GetAttr() Error");
	local attr = self.m_attr[key];
	local value = attr.value;
	if attr.x > 0 or attr.y < 1 then
		value = attr.value * (1.0 + attr.x) * attr.y + MODIFY_FLOAT;
		value = math.floor(value * 100) * 0.01 + MODIFY_FLOAT;
	end
	return value;
end

-- @Param int, int
-- @Return 
function BattleUnit:SetAttr( key, value )
	assert(key < ECreatureAttr.CREATURE_ATTR_MAX, "BattleUnit:SetAttr() Error");
	self.m_attr[key].value = math.floor(value);
end

-- @Param Enum:ECreatureAttr
-- @Return float
function BattleUnit:GetAttrX( key )
	assert(key < ECreatureAttr.CREATURE_ATTR_MAX, "BattleUnit:GetAttrX() Error");
	return self.m_attr[key].x;
end

-- @Param Enum:ECreatureAttr
-- @Return float
function BattleUnit:GetAttrY( key )
	assert(key < ECreatureAttr.CREATURE_ATTR_MAX, "BattleUnit:GetAttrY() Error");
	return self.m_attr[key].y;
end

-- @Param int, int
-- @Return 
function BattleUnit:SetAttrX( key, value )
	assert(key < ECreatureAttr.CREATURE_ATTR_MAX, "BattleUnit:SetAttrX() Error");
	self.m_attr[key].x = value;
end

-- @Param int, int
-- @Return 
function BattleUnit:SetAttrY( key, value )
	assert(key < ECreatureAttr.CREATURE_ATTR_MAX, "BattleUnit:SetAttrY() Error");
	self.m_attr[key].y = value;
end

-- @Param const vector<int>&
-- @Return 
function BattleUnit:SetAttrs( attrs )
	assert(#attrs == ECreatureAttr.CREATURE_ATTR_MAX, "BattleUnit:SetAttrs() Error");
	self.m_attr = {};	
	for i,v in ipairs(attrs) do
		table.insert(self.m_attr, v);
	end
end

-- @Param
-- @Return const vector<int>&
function BattleUnit:GetAttrs( )
	return self.m_attr;
end

-- @Param
-- @Return bool
function BattleUnit:GetValid( )
	return self.m_bValid;
end

-- @Param bool
-- @Return void
function BattleUnit:SetValid( val )
	self.m_bValid = val;
end

-- @Param
-- @Return bool
function BattleUnit:GetIsAttack( )
	return self.m_bIsAttack;
end

-- @Param bool
-- @Return void
function BattleUnit:SetIsAttack( val )
	self.m_bIsAttack = val;
end

-- @Param
-- @Return int 
function BattleUnit:GetRoad( )
	return self.m_road;
end

-- @Param int
-- @Return void
function BattleUnit:SetRoad( val )
	self.m_road = val;
end

-- @Param
-- @Return int
function BattleUnit:GetLastPos( )
	return math.floor(self.m_nLastPos / gBattleView.msec_unit);
end

-- @Param
-- @Return int
function BattleUnit:GetPos( )
	if self.m_pos >= 0 then
		return math.floor(self.m_pos / gBattleView.msec_unit);
	else
		return 0;
	end
end

-- @Param int
-- @Return 
function BattleUnit:Move( val )
	val = math.modf(val);
	self.m_nLastPos = self.m_pos;
	self.m_pos = self.m_pos + val;
end

-- @Param
-- @Return void
function BattleUnit:SetPos( val )
	self.m_nLastPos = self.m_pos;
	self.m_pos = math.floor(val * gBattleView.msec_unit);
end

-- @Param 
-- @Return int
function BattleUnit:GetTarget( )
	return self.m_target;
end

-- @Param int
-- @Return void
function BattleUnit:SetTarget( val )
	self.m_target = val;
end

-- @Param int
-- @Return SkillStatus*
function BattleUnit:AddSkillStatus( skillId )
	self.m_skillStatus[skillId] = SkillStatus:new();
	return self.m_skillStatus[skillId];
end

-- @Param int
-- @Return SkillStatus*
function BattleUnit:GetSkillStatus( skillId )
	return self.m_skillStatus[skillId];
end

-- @Param 
-- @Return void
function BattleUnit:ClearSkillStatusData()
	for k,skillStatus in pairs(self.m_skillStatus) do
		skillStatus.pre = 0;
		skillStatus.post = 0;
	end
end

function BattleUnit:GetAttackDamage( )
	return self.m_attackDamage;
end

function BattleUnit:SetAttackDamage( val )
	self.m_attackDamage:copyWithProp(val);
end

function BattleUnit:GetDefendDamage( )
	return self.m_defendDamage;
end

function BattleUnit:SetDefendDamage( val )
	self.m_defendDamage:copyWithProp(val);
end

---------------------------------------  BattleResource  ---------------------------------------
BattleResource = vclass("BattleResource");

function BattleResource:initialize( )
	self.m_interval = 0;											-- 战斗帧间隔（毫秒）  
	self.m_nSpoilsRes = 0;										-- 掠夺资源百分比
	self.m_nSpoilsPlantRes = 0;									-- 掠夺植物产量百分比
	self.m_nMartyrdomDamage = 0;							-- 炸弹对坚果的加成系数  
	self.m_nMoveSpeedParam = 1;								-- 移动速度换算参数（参数*速度=速度值）
	self.m_nAttackSpeedParam = 1;							-- 攻击速度值参数（参数/攻击间隔=攻击速度值）
	self.m_nMinDamage = 1;									-- 伤害最小百分比
	self.m_maxSpoilItemsParam = 1;							--最大可掠夺物品 
	self.m_nSunshineTimeout = 0;								-- 阳光自动消失时间  
	self.m_nAttackCD = 0;										-- 攻击cd
	self.m_nObserveTime = 0;									-- 观察阶段时间

	self.m_plantProps = {};										-- map<int, BattleUnit*> 植物属性  
	self.m_monsterProps = {};									-- map<int, BattleUnit*> 僵尸属性  
	self.m_objectProps = {};									-- map<int, BattleUnit*> 物体属性  
	self.m_bulletProps = {};										-- map<int, BulletProp*> 子弹属性  
	self.m_skills = {};											-- map<int, BattleBuffProp*> 技能属性  
	self.m_buffs = {};											-- map<int, BattleBuffProp*> buff属性  
	self.m_effects = {};											-- map<int, BattleEffectProp*> 效果属性  
	self.m_conditions = {};										-- map<int, BattleCondition*> 条件  

	self.m_creatureCommon = CreatureCommon:new();		-- CreatureCommon
	self.m_battleProps = {};										-- map<int, map<int, BattleProp*>> 战斗类型  
	self.m_damageRaces = {};									-- map<int, map<int, int>>
	self.m_damageTypes = {};									-- map<int, int>
	self.m_pvpSpoilLimits = {};									-- map<int64, map<int, int>>
	self.m_dances = {};											-- map<int,vector<DanceData*>>
	
	self.m_attrRestraint = {};									-- map<int,map<int,int>> 战旗属性克制表
	self.m_altar = {};											-- 太阳祭坛信息表
	self.m_battleSpriteImgs = {};								-- 战场动画资源名字列表
	self.m_battlePeaSpriteImgs = {};
end

---------------------------------------  public  ---------------------------------------

-- @Param
-- @Return bool
function BattleResource:Create( )
	-- if not self:LoadMonster() then
	-- 	return false;
	-- end

	if not self:LoadBullet() then
		return false;
	end

	-- if not self:LoadPlant() then
	-- 	return false;
	-- end

	if not self:LoadObject() then
		return false;
	end

	if not self:LoadCommon() then
		return false;
	end

	if not self:LoadCondition() then
		return false;
	end

	if not self:LoadSkill() then
		return false;
	end

	if not self:LoadBuff() then
		return false;
	end

	if not self:LoadSkillEffect() then
		return false;
	end

	if not self:LoadBuffEffect() then
		return false;
	end

	if not self:LoadCreatureCommon() then
		return false;
	end

	if not self:LoadBattle() then
		return false;
	end

	if not self:LoadDamageRace() then
		return false;
	end

	if not self:LoadDamageType() then
		return false;
	end

	if not self:LoadPvpSpoilLimit() then
		return false;
	end

	if not self:LoadDance() then
		return false;
	end

	if not self:LoadAttrRestraint() then
		return false;
	end

	if not self:LoadAltar() then
		return false;
	end

	if not self:LoadBattleSpriteImgs() then
		return false;
	end
	return true;
end

-- @Param
-- @Return 
function BattleResource:Close( )
	
end

-- @Param int
-- @Return const BattleUnit*
function BattleResource:GetMonsterProp( id )
	if not self.m_monsterProps[id] then
		local monsterData = gData:getBriefMonsterCsvData(id);
		assert(monsterData ~= nil, "BattleResource:GetMonsterProp Error monsterData = nil, id = "..id);

		local pProp = BattleUnit:new(EUnitType.TYPE_CREATURE);
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_RACE, monsterData.classType);
		-- pProp.m_strName = monsterData.name;
		pProp.m_image = monsterData.image;
		pProp.m_quality = monsterData.quality;
		pProp.m_level = monsterData.level;

		local animationCsv = gData:readCsv("animation_creature.csv");
		local animationData = animationCsv:lineDataWithKey(pProp.m_image);
		if animationData then
			if gBranch ~= 2 and animationData:Get(6) then
				pProp.m_scale = animationData:Get(6);
			else
				pProp.m_scale = animationData:Get(2);
			end
			pProp.m_speedScale = animationData:Get(3);
		else
			pProp.m_scale = 60;
			pProp.m_speedScale = 400;			
		end

		local monsterCsv = gData:readCsv("prop_creature_monster.csv");
		local monsterBattleData = monsterCsv:lineDataWithKey(id);
		pProp.m_strName = monsterBattleData["name"];
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ID, monsterBattleData["id"]);										-- ID  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_LIFE, monsterBattleData["hp"]);										-- 生命  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK, monsterBattleData["atk"]);									-- 攻击  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_DEFEND, monsterBattleData["def"]);								-- 防御  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED, monsterBattleData["atkTime"]);						-- 攻击速度  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE, monsterBattleData["atkRange"]);					-- 攻击距离  
		local speed = gBattleView.cellNum * gBattleView.msec_unit / monsterBattleData["speed"];
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED, math.floor(speed));									-- 移动速度  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_LEN, monsterBattleData["length"]);									-- 长度  
		-- pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_WID, 1);															-- 宽度  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE, monsterBattleData["atkType"]);						-- 攻击类型 （1 地 2 空 3 两者）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE, monsterBattleData["moveType"]);						-- 移动类型 （1 地 2 空 3 两者）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_BULLET, monsterBattleData["bullet"]);								-- 子弹  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL, monsterBattleData["skill"]);									-- 技能  
		local firsttime = monsterBattleData["firstTime"];
		if gBattleView then
			firsttime = firsttime * gBattleView.msec_unit;
		else
			firsttime = firsttime * 1000;
		end
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_FIRST, firsttime);												-- 技能首次时间  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_CD, monsterBattleData["skillCD"]);							-- 技能CD  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_AI_MOVE, monsterBattleData["moveAI"]);							-- 移动AI  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_AI_ATTACK, monsterBattleData["atkAI"]);							-- 攻击AI  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_PRE, monsterBattleData["beforeShake"]);					-- 攻击前摇  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_POST, monsterBattleData["afterShake"]);					-- 攻击后摇  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_TIMES, monsterBattleData["skillCount"]);						-- 技能释放次数  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_HIGHT, monsterBattleData["height"]);								-- 高度
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_COST, monsterBattleData["consume"]);								-- 消耗  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_AI_SKILL, monsterBattleData["skillAI"]);								-- 技能AI  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR1, monsterBattleData["shield"]);								-- 护甲类型（盾牌）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR2, monsterBattleData["helmet"]);							-- 护甲类型（头盔）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR3, monsterBattleData["shoes"]);								-- 护甲类型（鞋子）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR4, monsterBattleData["hardSkin"]);							-- 护甲类型（石肤）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR5, monsterBattleData["explosionProof"]);					-- 护甲类型（防爆）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_TYPE, monsterBattleData["damageType"]);				-- 攻击类型（平射、抛射、陷阱、肉搏）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_RACE, monsterBattleData["damageRace"]);				-- 伤害类型（物理、元素、神圣、化学）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_SPEED, monsterBattleData["sunshineSpeed"]);			-- 资源植物 阳光速率(小偷 攻击次数）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_VALUE, monsterBattleData["sunshineValue"]);			-- 阳光数值  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_COMBAT, monsterBattleData["combat"]);							-- 战斗力  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_BLOCK, monsterBattleData["block"]);								-- 是否被补种的植物阻挡（0不阻挡，1阻挡）

		pProp:SetMode(monsterBattleData["modle"]);																		-- 模型（0.生物1.物体2.死亡后放技能的生物）

		self.m_monsterProps[id] = pProp;
	end

	return self.m_monsterProps[id];
end

-- @Param int
-- @Return const BattleUnit*
function BattleResource:GetPlantProp( id )
	if not self.m_plantProps[id] then
		local plantData = gData:getBriefPlantCsvData(id);
		assert(plantData ~= nil, "BattleResource:GetPlantProp Error plantData = nil, id = "..id);

		local pProp = BattleUnit:new(EUnitType.TYPE_CREATURE);
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_RACE, plantData.classType);
		-- pProp.m_strName = plantData.name;
		pProp.m_image = plantData.image;
		pProp.m_quality = plantData.quality;
		pProp.m_level = plantData.level;

		local animationCsv = gData:readCsv("animation_creature.csv");
		local animationData = animationCsv:lineDataWithKey(pProp.m_image);
		if animationData then
			if gBranch ~= 2 and animationData:Get(6) then
				pProp.m_scale = animationData:Get(6);
			else
				pProp.m_scale = animationData:Get(2);
			end
			pProp.m_speedScale = animationData:Get(3);
		else
			pProp.m_scale = 60;
			pProp.m_speedScale = 80;			
		end

		local plantBattleCsv = gData:readCsv("prop_creature_plant.csv");
		local plantBattleData = plantBattleCsv:lineDataWithKey(id);
		pProp.m_strName = plantBattleData["name"];
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ID, plantBattleData["id"]);										-- ID  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_LIFE, plantBattleData["hp"]);										-- 生命  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK, plantBattleData["atk"]);								-- 攻击  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_DEFEND, plantBattleData["def"]);								-- 防御  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED, plantBattleData["aspd"]);						-- 攻击速度  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE, plantBattleData["atkRange"]);					-- 攻击距离  
		local speed = gBattleView.cellNum * gBattleView.msec_unit / plantBattleData["speed"];
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED, math.floor(speed));								-- 移动速度  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_LEN, plantBattleData["length"]);									-- 长度  
		-- pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_WID, 1);														-- 宽度  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE, plantBattleData["atkType"]);						-- 攻击类型 （1 地 2 空 3 两者）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE, plantBattleData["moveType"]);						-- 移动类型 （1 地 2 空 3 两者）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_BULLET, plantBattleData["bullet"]);								-- 子弹  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL, plantBattleData["skill"]);									-- 技能  
		local firsttime = plantBattleData["firstTime"];
		if gBattleView then
			firsttime = firsttime * gBattleView.msec_unit;
		else
			firsttime = firsttime * 1000;
		end
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_FIRST, firsttime);											-- 技能首次时间  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_CD, plantBattleData["skillCD"]);							-- 技能CD  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_AI_MOVE, plantBattleData["moveAI"]);							-- 移动AI  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_AI_ATTACK, plantBattleData["atkAI"]);							-- 攻击AI  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_PRE, plantBattleData["beforeShake"]);					-- 攻击前摇  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_POST, plantBattleData["afterShake"]);					-- 攻击后摇  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_TIMES, plantBattleData["skillCount"]);						-- 技能释放次数  
		-- pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_RACE, plantBattleData[""]);									-- 类型  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_HIGHT, plantBattleData["height"]);								-- 高度
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_COST, plantBattleData["consume"]);								-- 消耗  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_AI_SKILL, plantBattleData["skillAI"]);								-- 技能AI  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR1, plantBattleData["shield"]);							-- 护甲类型（盾牌）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR2, plantBattleData["helmet"]);							-- 护甲类型（头盔）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR3, plantBattleData["shoes"]);							-- 护甲类型（鞋子）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR4, plantBattleData["hardSkin"]);							-- 护甲类型（石肤）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ARMOR5, plantBattleData["explosionProof"]);					-- 护甲类型（防爆）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_TYPE, plantBattleData["damageType"]);				-- 攻击类型（平射、抛射、陷阱、肉搏）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_RACE, plantBattleData["damageRace"]);				-- 伤害类型（物理、元素、神圣、化学）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_SPEED, plantBattleData["sunshineSpeed"]);			-- 资源植物 阳光速率(小偷 攻击次数）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_VALUE, plantBattleData["sunshineValue"]);			-- 阳光数值  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_COMBAT, plantBattleData["combat"]);							-- 战斗力  

		pProp:SetMode(plantBattleData["modle"]);																		-- 模型（0.生物1.物体）

		self.m_plantProps[id] = pProp;
	end

	return self.m_plantProps[id];
end

-- @Param int
-- @Return const BulletProp*
function BattleResource:GetBulletProp( id )
	return self.m_bulletProps[id];
end

-- @Param int
-- @Return const GetSkillProp*
function BattleResource:GetSkillProp( id )
	return self.m_skills[id];
end

-- @Param int
-- @Return const BuffProp*
function BattleResource:GetBuffProp( id )
	return self.m_buffs[id];
end

-- @Param int
-- @Return const BuffProp*
function BattleResource:GetCondition( id )
	return self.m_conditions[id];
end

-- @Param int
-- @Return const BuffProp*
function BattleResource:GetObjectProp( id )
	return self.m_objectProps[id];
end

-- @Param 
-- @Return const CreatureCommon
function BattleResource:GetCreatureCommon( )
    return self.m_creatureCommon;
end

-- @Param 
-- @Return const AltarData
function BattleResource:getAltarInfo( level )
	return self.m_altar[level];
end

-- @Param
-- @Return bool
function BattleResource:LoadMonster( )

end

-- @Param
-- @Return bool
function BattleResource:LoadPlant( )

end

-- @Param
-- @Return bool
function BattleResource:LoadBullet( )
	local bulletCsv = gData:readCsv("prop_bullet.csv");
	local csvLine = bulletCsv:lineCount();

	for i=0,csvLine-1 do
		local pProp = BulletProp:new();
		local n = 0;

		pProp.id = bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.name = bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.image = bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.type = EUnitType.TYPE_BULLET + bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.attack_type = bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.speed = bulletCsv:lineData(i,n) / gBattleView.msec_unit;
		n = n + 1;
		pProp.buff = bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.self_attack = bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.num = bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.wakeup = bulletCsv:lineData(i,n);
		n = n + 1;
		pProp.animationType = bulletCsv:lineData(i,n);

		local bulletId = pProp.id;
		self.m_bulletProps[pProp.id] = pProp;
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadSkill( )
	local skillCsv = gData:readCsv("prop_skill.csv");
	local csvLine = skillCsv:lineCount();

	for i=0,csvLine-1 do
		local pProp = BattleBuffProp:new();
		local n = 0;
		pProp.m_id = skillCsv:lineData(i,n);
		n = n + 1;
		pProp.m_strName = skillCsv:lineData(i,n);
		n = n + 3;		-- 图片、描述
		pProp.m_skillData.family = skillCsv:lineData(i,n);
		n = n + 2;		-- 等级
		pProp.m_skillData.pre = skillCsv:lineData(i,n);
		n = n + 1;
		pProp.m_skillData.post = skillCsv:lineData(i,n);
		n = n + 1;

		for j=n, skillCsv:rowCount(i)-1 do
			if skillCsv:lineData(i,n) ~= nil or skillCsv:lineData(i,n) ~= "" then
				table.insert(pProp.m_conditions, skillCsv:lineData(i,n));
				n = n + 1
			end
		end

		local skillId = pProp.m_id;
		self.m_skills[skillId] = pProp;
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadBuff( )
	local animationCsv = gData:readCsv("animation_buff.csv");
	local buffCsv = gData:readCsv("prop_buff.csv");
	local csvLine = buffCsv:lineCount();

	for i=0,csvLine-1 do
		local pProp = BattleBuffProp:new();
		local n = 0;

		pProp.m_id = buffCsv:lineData(i,n);
		n = n + 3;		-- 描述、图片
		pProp.m_buffData.overlap_max = buffCsv:lineData(i,n);
		n = n + 1;
		pProp.m_buffData.cd = buffCsv:lineData(i,n);
		n = n + 1;
		pProp.m_buffData.remove_type = buffCsv:lineData(i,n);
		n = n + 1;
		pProp.m_buffData.event = buffCsv:lineData(i,n);
		n = n + 1;

		for j=n, buffCsv:rowCount(i)-1 do
			if buffCsv:lineData(i,n) ~= nil or buffCsv:lineData(i,n) ~= "" then
				table.insert(pProp.m_conditions, buffCsv:lineData(i,n));
				n = n + 1
			end
		end

		local animationData = animationCsv:lineDataWithKey(pProp.m_id);
		if animationData then
			for j=3, 4 do
				if animationData:Get(j) ~= nil and animationData:Get(j) ~= "" then
					table.insert(pProp.m_buffAnimation, animationData:Get(j));
				end
			end
		end

		local buffId = pProp.m_id;
		self.m_buffs[buffId] = pProp;
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadSkillEffect( )
	local skillEffectCsv = gData:readCsv("skill_effect.csv");
	local csvLine = skillEffectCsv:lineCount();

	for i=0,csvLine-1 do
		local n = 0;
		local id = skillEffectCsv:lineData(i,n);
		n = n + 1;
		local pProp = self:GetSkillProp(id);
		assert(pProp ~= nil, "BattleResource:LoadSkillEffect() Error pProp = nil");

		local effect = BattleEffectProp:new();
		effect.target = skillEffectCsv:lineData(i,n);
		n = n + 1;
		effect.target_range = skillEffectCsv:lineData(i,n);
		n = n + 1;
		effect.target_num = skillEffectCsv:lineData(i,n);
		n = n + 1;
		effect.magic_valid = skillEffectCsv:lineData(i,n);
		n = n + 1;
		effect.expressionId = skillEffectCsv:lineData(i,n);
		n = n + 1;

		for j=n, skillEffectCsv:rowCount(i)-1 do
			if skillEffectCsv:lineData(i,n) ~= nil or skillEffectCsv:lineData(i,n) ~= "" then
				table.insert(effect.params, skillEffectCsv:lineData(i,n));
				n = n + 1;
			end
		end

		table.insert(pProp.m_effects, effect);
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadBuffEffect( )
	local buffEffectCsv = gData:readCsv("buff_effect.csv");
	local csvLine = buffEffectCsv:lineCount();

	for i=0,csvLine-1 do
		local n = 0;
		local id = buffEffectCsv:lineData(i,n);
		n = n + 1;
		local pProp = self:GetBuffProp(id);
		assert(pProp ~= nil, "BattleResource:LoadBuffEffect() Error pProp = nil, id = "..id);

		local effect = BattleEffectProp:new();
		effect.target = buffEffectCsv:lineData(i,n);
		n = n + 1;
		effect.target_range = buffEffectCsv:lineData(i,n);
		n = n + 1;
		effect.target_num = buffEffectCsv:lineData(i,n);
		n = n + 1;
		effect.magic_valid = buffEffectCsv:lineData(i,n);
		n = n + 1;
		effect.expressionId = buffEffectCsv:lineData(i,n);
		n = n + 1;
		for j=n, buffEffectCsv:rowCount(i)-1 do
			if buffEffectCsv:lineData(i,n) ~= nil or buffEffectCsv:lineData(i,n) ~= "" then
				table.insert(effect.params, buffEffectCsv:lineData(i,n));
				n = n + 1;
			end
		end

		table.insert(pProp.m_effects, effect);
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadCondition( )
	local conditionCsv = gData:readCsv("skill_condition.csv");
	local csvLine = conditionCsv:lineCount();

	for i=0,csvLine-1 do
		local n = 0;
		local pCondition = BattleCondition:new();
		pCondition.id = conditionCsv:lineData(i,n);
		n = n + 1;
		pCondition.expressionId = conditionCsv:lineData(i,n);
		n = n + 1;

		for j=n, conditionCsv:rowCount(i)-1 do
			if conditionCsv:lineData(i,n) and conditionCsv:lineData(i,n) ~= "" then
				local x = conditionCsv:lineData(i,n);
				table.insert(pCondition.params, conditionCsv:lineData(i,n));
				n = n + 1;
			end
		end

		self.m_conditions[pCondition.id] = pCondition;
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadCommon( )
	local commonCsv = gData:readCsv("battle_common.csv");
	local csvLine = commonCsv:lineCount();

	for i=0,csvLine-1 do
		self.m_interval = commonCsv:lineData(i,0);
		self.m_nSpoilsRes = commonCsv:lineData(i,2);
		self.m_nSpoilsPlantRes = commonCsv:lineData(i,4);
		self.m_nMartyrdomDamage = commonCsv:lineData(i,10);
		self.m_nMoveSpeedParam = commonCsv:lineData(i,11);
		self.m_nAttackSpeedParam = commonCsv:lineData(i,12);
		self.m_nMinDamage = commonCsv:lineData(i,14);
		self.m_maxSpoilItemsParam = commonCsv:lineData(i,3);
		if gBattleView then
			self.m_nSunshineTimeout = commonCsv:lineData(i,16) * gBattleView.msec_unit;
		else
			self.m_nSunshineTimeout = commonCsv:lineData(i,16) * 1000;
		end
		self.m_nAttackCD = commonCsv:lineData(i,17);
		self.m_nObserveTime = commonCsv:lineData(i,18);
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadObject( )
	local objCsv = gData:readCsv("prop_object.csv");
	local csvLine = objCsv:lineCount();

	for i=0,csvLine-1 do
		local pProp = BattleUnit:new(EUnitType.TYPE_OBJECT);
		local objData = objCsv:lineData(i);

		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ID, objData["id"]);								-- ID
		pProp.m_strName = objData["name"];
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_LEN, objData["length"]);							-- 长度  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK, objData["atk"]);						-- 攻击  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_AI_ATTACK, objData["atkAI"]);					-- 攻击AI  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED, objData["atkTime"]);			-- 攻击速度  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_PRE, objData["beforeShake"]);			-- 攻击前摇  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_POST, objData["afterShake"]);			-- 攻击后摇  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE, objData["atkType"]);				-- 攻击类型 （1 地 2 空 3 两者）  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE, objData["atkRange"]);			-- 攻击距离  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL, objData["skill"]);							-- 技能  
		local firsttime = objData["firstTime"];
		if gBattleView then
			firsttime = firsttime * gBattleView.msec_unit;
		else
			firsttime = firsttime * 1000;
		end
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_FIRST, firsttime);							-- 技能首次时间  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_CD, objData["skillCD"]);					-- 技能CD  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_TIMES, objData["skillCount"]);			-- 技能释放次数  
		pProp:SetAttr(ECreatureAttr.CREATURE_ATTR_AI_SKILL, objData["skillAI"]);						-- 技能AI  
		pProp:SetMode(objData["modle"]);																-- 模型（0.生物1.物体2.死亡后放技能的生物）
		pProp.m_image = objData["image"];

		local objId = pProp:GetAttr(ECreatureAttr.CREATURE_ATTR_ID);
		self.m_objectProps[objId] = pProp;
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadCreatureCommon( )
	local commonCsv = gData:readCsv("creature_common.csv");
	local csvLine = commonCsv:lineCount();

	for i=0,csvLine-1 do
		self.m_creatureCommon.spikeweed_attack = commonCsv:lineData(i,0);
		self.m_creatureCommon.spikeweed_stop   = commonCsv:lineData(i,1);
		self.m_creatureCommon.spikeweed_damage = commonCsv:lineData(i,2);
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadBattle( )
	local battleCsv = gData:readCsv("prop_battle.csv");
	local csvLine = battleCsv:lineCount();

	for i=0,csvLine-1 do
		local prop = BattleProp:new();

		prop.type = battleCsv:lineData(i,0);
		prop.road = battleCsv:lineData(i,1);
		prop.time = battleCsv:lineData(i,2);
		if gBattleView then
			prop.first_stat = battleCsv:lineData(i,3) * gBattleView.msec_unit;
			prop.first_interval = battleCsv:lineData(i,4) * gBattleView.msec_unit;
			prop.second_stat = battleCsv:lineData(i,6) * gBattleView.msec_unit;
		else
			prop.first_stat = battleCsv:lineData(i,3) * 1000;
			prop.first_interval = battleCsv:lineData(i,4) * 1000;
			prop.second_stat = battleCsv:lineData(i,6) * 1000;
		end
		prop.first_prob = battleCsv:lineData(i,5);
		prop.sunshine = battleCsv:lineData(i,7);
		prop.limit = battleCsv:lineData(i,8);
		prop.fieldLevel = battleCsv:lineData(i,9);
		prop.m_shovelPlantNum = battleCsv:lineData(i,10);

		if not self.m_battleProps[prop.type] then
			self.m_battleProps[prop.type] = {};
		end

		local index = prop.road * 100 + prop.fieldLevel;
		self.m_battleProps[prop.type][index] = prop;
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadDamageRace( )
	local raceCsv = gData:readCsv("damage_race.csv");
	local csvLine = raceCsv:lineCount();
	local rowCount = raceCsv:rowCount(0);

	for i=1,csvLine-1 do
		local damageType = raceCsv:lineData(i, 0);
		if not self.m_damageRaces[damageType] then
			self.m_damageRaces[damageType] = {};
		end	
	end	

	for i=1,csvLine-1 do
		local damageType = raceCsv:lineData(i, 0);
		for k=1,rowCount-1 do
			local damageRace = raceCsv:lineData(0, k);
			self.m_damageRaces[damageType][damageRace] = raceCsv:lineData(i, k);
		end
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadPvpSpoilLimit( )
	local spoilCsv = gData:readCsv("pvp_spoil_limit.csv");
	local csvLine = spoilCsv:lineCount();

	for i=0,csvLine-1 do
		local spoilType = spoilCsv:lineData(i,0);
		local effect_id = spoilCsv:lineData(i,1);
		local camp = spoilCsv:lineData(i,2);			-- 1,进攻方 2,防守方
		local limit = spoilCsv:lineData(i,3);

		spoilType = local_bit:_lshift(spoilType, 32);
		local id = local_bit:_or(spoilType, effect_id);
		if not self.m_pvpSpoilLimits[id] then
			self.m_pvpSpoilLimits[id] = {};
		end
		self.m_pvpSpoilLimits[id][camp] = limit;
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadDance( )
	local danceCsv = gData:readCsv("prop_dance.csv");
	local csvLine = danceCsv:lineCount();

	for i=0,csvLine-1 do
		local pInfo = DanceData:new();
		pInfo.id = danceCsv:lineData(i,0);
		pInfo.probability = danceCsv:lineData(i,1);
		pInfo.monsterid = danceCsv:lineData(i,2);
		pInfo.hp_param = danceCsv:lineData(i,3);
		pInfo.attack_param = danceCsv:lineData(i,4);
		pInfo.defend_param = danceCsv:lineData(i,5);
		pInfo.born_buffid = danceCsv:lineData(i,6);
		pInfo.born_bufftime = danceCsv:lineData(i,7);
		if not self.m_dances[pInfo.id] then
			self.m_dances[pInfo.id] = {};
		end 
		table.insert(self.m_dances[pInfo.id], pInfo);
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadAttrRestraint( )
	local attrRestraintCsv = gData:readCsv("attribute_restraint.csv");
	local csvLine = attrRestraintCsv:lineCount();
	
	local iMaxLevel = 6;
	local iMaxType = 8;

	for i=0,csvLine-1 do
		local index = 0;
		local mapValue = {};
		local iDefendIndex = 1;
		local iAttackIndex = tonumber(attrRestraintCsv:lineData(i,index));
		index = index + 1;
		local iValue = attrRestraintCsv:lineData(i,index);
		index = index + 1;
		mapValue[iDefendIndex] = math.floor(tonumber(iValue));
		
		for j = 1,iMaxType do
			for k = 1,iMaxLevel do
				iDefendIndex = j * 100 + k;
				iValue = attrRestraintCsv:lineData(i,index);
				index = index + 1;
				mapValue[iDefendIndex] = math.floor(tonumber(iValue));
			end
		end
		self.m_attrRestraint[iAttackIndex] = mapValue;
	end
	
	return true;
end

-- @Param int, int, int, int
-- @Return int
function BattleResource:GetAttrRestraintValue( iAttackAttrType, iAttackAttrLevel, iDefendAttrType, iDefendAttrLevel )
	local iAttackIndex = iAttackAttrType * 100 + iAttackAttrLevel;
	local iDefendIndex = iDefendAttrType * 100 + iDefendAttrLevel;
	if self.m_attrRestraint[iAttackIndex] == nil then self.m_attrRestraint[iAttackIndex] = {} end
	if self.m_attrRestraint[iAttackIndex][iDefendIndex] == nil then
		local attrRestraintCsv = gData:readCsv("attribute_restraint.csv");
		local row = 1;
		if iDefendAttrType ~= 0 then
			row = iDefendAttrType * 6 + iDefendAttrLevel - 5;
		end
		self.m_attrRestraint[iAttackIndex][iDefendIndex] = math.floor(tonumber(attrRestraintCsv:lineDataWithKey(iAttackIndex,row)));
	end
	return self.m_attrRestraint[iAttackIndex][iDefendIndex] or 100;
end

-- @Param
-- @Return bool
function BattleResource:LoadAltar()
	local altarCsv = gData:readCsv("prop_altar.csv");
	local csvLine = altarCsv:lineCount();

	for i=0,csvLine-1 do
		local pInfo = AltarData:new();
		local level = altarCsv:lineData(i,0);
		pInfo.upgradeCoin = altarCsv:lineData(i,1);
		pInfo.upgradeSunshine = altarCsv:lineData(i,2);
		pInfo.upgradeTime = altarCsv:lineData(i,3);
		pInfo.sunshinePeriod = altarCsv:lineData(i,4);
		pInfo.sunshineCount = altarCsv:lineData(i,5);
		pInfo.darkSunshinePeriod = altarCsv:lineData(i,6);
		pInfo.darkSunshineCount = altarCsv:lineData(i,7);
		pInfo.baseCampLimit = altarCsv:lineData(i,8);

		self.m_altar[level] = pInfo;
	end

	return true;
end

-- @Param
-- @Return bool
function BattleResource:LoadBattleSpriteImgs( )
	--可被召唤的小僵尸
	self.m_battleSpriteImgs["DancingZombie"] = true;
	self.m_battleSpriteImgs["HipHopZombie"] = true;
	self.m_battleSpriteImgs["SuitDancingZombie"] = true;
	self.m_battleSpriteImgs["ElvisZombie"] = true;
	self.m_battleSpriteImgs["JacksonZombie"] = true;
	self.m_battleSpriteImgs["IMP"] = true;
	self.m_battleSpriteImgs["FrozenIMP"] = true;
	self.m_battleSpriteImgs["FireIMP"] = true;

	--美国队长部件
	self.m_battleSpriteImgs["CaptainZombieChild"] = true;
	--战场BUFF效果
	self.m_battleSpriteImgs["battleCar"] = true;
	self.m_battleSpriteImgs["battleResultLost"] = true;
	self.m_battleSpriteImgs["battleResultWin"] = true;
	self.m_battleSpriteImgs["BlackHoleExplode"] = true;
	self.m_battleSpriteImgs["BloodyBuff"] = true;
	self.m_battleSpriteImgs["BloodyBullet"] = true;
	self.m_battleSpriteImgs["BombExplode"] = true;
	self.m_battleSpriteImgs["DizzinessBuff"] = true;
	self.m_battleSpriteImgs["FireBallBulletExplode"] = true;
	self.m_battleSpriteImgs["FireMelonExplode"] = true;
	self.m_battleSpriteImgs["MelonExplode"] = true;
	self.m_battleSpriteImgs["Mushroom"] = true;
	self.m_battleSpriteImgs["OtherShoreBuff"] = true;
	self.m_battleSpriteImgs["ShamanMumBuff"] = true;
	self.m_battleSpriteImgs["SoapCornExplode"] = true;
	self.m_battleSpriteImgs["spoilBoxArmature"] = true;
	self.m_battleSpriteImgs["SummonArmature"] = true;
	self.m_battleSpriteImgs["UsefulBuff"] = true;
	self.m_battleSpriteImgs["UselessBuff"] = true;
	self.m_battleSpriteImgs["WinterMelonExplode"] = true;
	if false then
		self.m_battleSpriteImgs["BombPitcherExplode"] = true;
		self.m_battleSpriteImgs["LavaExplode"] = true;
		self.m_battleSpriteImgs["SpaceMelonExplode"] = true;
		self.m_battleSpriteImgs["SporeCornExplode"] = true;
	end
	--豌豆部件
	self.m_battlePeaSpriteImgs["PeaShooter"] = true;
	self.m_battlePeaSpriteImgs["PoisonPea"] = true;
	self.m_battlePeaSpriteImgs["SnipeShooter"] = true;
	self.m_battlePeaSpriteImgs["SnowPea"] = true;

	return true;
end

-- @Param int, int
-- @Return int
function BattleResource:GetDamageRace( nDamageType, race )
	if not self.m_damageRaces[nDamageType] then
		return -1;
	end

	if not self.m_damageRaces[nDamageType][race] then
		return -1;
	end

	return self.m_damageRaces[nDamageType][race];
end

-- @Param
-- @Return bool
function BattleResource:LoadDamageType( )
	local typeCsv = gData:readCsv("damage_type.csv");
	local csvLine = typeCsv:lineCount();

	for i=0,csvLine-1 do
		local damageType = typeCsv:lineData(i,0);
		local defendType = typeCsv:lineData(i,1);
		self.m_damageTypes[damageType] = defendType;
	end

	return true;
end

-- @Param int
-- @Return int
function BattleResource:GetDamageType( nAttackType )
	if not self.m_damageTypes[nAttackType] then
		return -1;
	end

	return self.m_damageTypes[nAttackType];
end

-- @Param int, int
-- @Return BattleProp*
function BattleResource:GetBattleProp( type, road, filedLevel )
	if self.m_battleProps[type] then
		local index = road * 100 + filedLevel;
		if self.m_battleProps[type][index] then
			return self.m_battleProps[type][index];
		end
	end
	return nil;
end

-- @Param int, int, int
-- @Return int
function BattleResource:GetPvpSpoilLimit( spoilType, effect_id, camp )
	local id = local_bit:_or(local_bit:_lshift(spoilType, 32), effect_id);
	if not self.m_pvpSpoilLimits[id] then
		return -1;
	end

	if not self.m_pvpSpoilLimits[id][camp] then
		return -1;
	end

	return self.m_pvpSpoilLimits[id][camp];
end

-- @Param int, int
-- @Return DanceData*
function BattleResource:GetDanceProp( id, rand )
	if not self.m_dances[id] then
		return nil;
	end

	for i,v in ipairs(self.m_dances[id]) do
		local danceInfo = v;
		if rand > danceInfo.probability then
			rand = rand - danceInfo.probability;
		else
			return danceInfo;
		end
	end

	return nil;
end

-- @Param
-- @Return int
function BattleResource:Interval( )
	return self.m_interval;
end

-- @Param
-- @Return int
function BattleResource:MartyrdomDamage( )
	return self.m_nMartyrdomDamage;
end

-- @Param
-- @Return int
function BattleResource:MoveSpeedParam( )
	return self.m_nMoveSpeedParam;
end

-- @Param
-- @Return int
function BattleResource:AttackSpeedParam( )
	return self.m_nAttackSpeedParam;
end

-- @Param
-- @Return int
function BattleResource:MinDamageParam( )
	return self.m_nMinDamage;
end

-- @Param
-- @Return int
function BattleResource:SpoilParam( )
	return self.m_nSpoilsRes;
end

-- @Param
-- @Return int
function BattleResource:SpoilPlantParam( )
	return self.m_nSpoilsPlantRes;
end

-- @Param
-- @Return int
function BattleResource:SpoilItemsParam( )
	return self.m_maxSpoilItemsParam;
end

-- @Param
-- @Return int
function BattleResource:SunshineTimeoutParam( )
	return self.m_nSunshineTimeout;
end

-- @Param
-- @Return int
function BattleResource:AttackCDParam( )
	return self.m_nAttackCD;
end

-- @Param
-- @Return int
function BattleResource:ObserveTimeParam( )
	return self.m_nObserveTime;
end

-- @Param
-- @Return int
function BattleResource:GetDungeonSunshine( dungeonId )
	local sunshine = 200;
	if dungeonId then
		local campaignCsv = gData:readCsv("prop_campaign.csv");
		local campaignData = campaignCsv:lineDataWithKey(dungeonId);
		if campaignData then
			sunshine = campaignData:Get(14) or 200;
		end
	end

	return sunshine;
end

function BattleResource:GetBattleSpriteImgs( )
	return self.m_battleSpriteImgs;
end

function BattleResource:GetBattlePeaSpriteImgs( )
	return self.m_battlePeaSpriteImgs;
end

