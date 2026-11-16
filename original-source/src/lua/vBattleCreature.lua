--vBattleCreature.lua
require "vBattleResource"

BattleCreature = vclass("BattleCreature", BattleUnit);

function BattleCreature:initialize( prop )
	-- super create
	BattleUnit.initialize(self, EUnitType.TYPE_CREATURE, prop);

	self.m_nSelfTime = 0;											-- int 自身时间  
	self.m_action = ECreatureAction.ACTION_NULL;				-- 当前行为
	self.m_nLastAction = ECreatureAction.ACTION_NULL;			-- 上次行为
	self.m_nAttackTimes = 0;										-- int 攻击次数  
	self.m_extra = "";												-- int64唯一id 扩展字段（服务器使用）  
	self.m_fLife = 0;												-- float 当前生命  
	self.m_fRawLife = 0;											-- float 初始生命  
	self.m_pBattle = nil;											-- Battle* 战场
	self.m_pAttackAI = nil;											-- CBattleAI* 攻击AI
	self.m_pMoveAI = nil;											-- CBattleAI* 移动AI
	self.m_pSkillAI = nil;											-- CBattleAI* 技能AI
	self.m_status = {};												-- vector<int> 状态
	for i=0,ECreatureStatus.CREATURE_STATUS_MAX do
		self.m_status[i] = 0;
	end
	self.m_buffs = {};												-- list<CBattleBuff*> buff
	self.m_nAttackCount = 0;										-- 攻击次数 资源植物专用

	-- 客户端专用
	self.m_lastLife = self.m_fLife;									-- 受伤前的HP
	self.resourceList = nil;											-- 身上的资源
	self.m_nDeadWay = EDeadWay.DEAD_NORMAL;

	self.m_Skill = nil;
	self.m_Bullet = nil;
end

---------------------------------------  public  ---------------------------------------

-- @Param
-- @Return void
function BattleCreature:Relase( )
	self.m_buffs = {};
end

-- @Param bool, int
-- @Return bool
function BattleCreature:Create( bAttack, id, pBattle, extra )
	self.m_pAttackAI = gBattleAIMgr:GetAttackAI(self:GetAttr(ECreatureAttr.CREATURE_ATTR_AI_ATTACK));
	self.m_pMoveAI = gBattleAIMgr:GetMoveAI(self:GetAttr(ECreatureAttr.CREATURE_ATTR_AI_MOVE));
	self.m_pSkillAI = gBattleAIMgr:GetSkillAI(self:GetAttr(ECreatureAttr.CREATURE_ATTR_AI_SKILL));

	self.m_fLife = self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
	self.m_fRawLife = self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
	self.m_nSelfTime = 0;
	self.m_extra = extra;
	self.m_pBattle = pBattle;

	self.m_attackDamage:SetValue(self:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK));
	self.m_attackDamage:SetDamageRace(self:GetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_RACE));
	self.m_attackDamage:SetDamageType(self:GetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_TYPE));
	if pBattle then
		local iAttackAttrType,iAttackAttrLevel,iDefendAttrType,iDefendAttrLevel = pBattle:GetCreatureBannerAttr(bAttack, self:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE));
		self.m_attackDamage:SetAttrType(iAttackAttrType);
		self.m_attackDamage:SetAttrLevel(iAttackAttrLevel);
		self.m_defendDamage:SetAttrType(iDefendAttrType);
		self.m_defendDamage:SetAttrLevel(iDefendAttrLevel);
	end
	self:SetId(id);
	self:SetValid(true);
	self:SetIsAttack(bAttack);

	--记录技能
	local skillId = self:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL);
	if skillId ~= 0 then
		self.m_Skill = gBattleResource:GetSkillProp(skillId);
	end
	--记录子弹
	self.m_Bullet = gBattleResource:GetBulletProp(self:GetAttr(ECreatureAttr.CREATURE_ATTR_BULLET));

	return true;
end

-- @Param 
-- @Return void
-- 植物强化信息
function BattleCreature:InitPlant( attrValue )
	local allValue = 0;
	if attrValue then
		for k,v in pairs(attrValue) do
			-- cclog("**** plant id = %d, k = %d, v = %d", self:GetId(), k, v);
			self:SetAttr(k, self:GetAttr(k) + v);	
			allValue = allValue + v;
		end
	end

	-- self.insigniaImage = gData:getCreatureInsigniaImageName(allValue, self:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE), self.m_quality, true);
	
	self:setMoveAndAttackSpeedParam();

	-- 植物初始都是睡觉状态，除去防守型关卡  
	if self.m_pBattle then
		if self.m_pBattle:GetType() ~= BattleType.BattleTypeEvp then
			self:SetStatus(ECreatureStatus.CREATURE_STATUS_SLEEP, 1);
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_SLEEP, self);
		end
	end

	self.m_fLife = self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
	self.m_fRawLife = self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
end

-- 怪物强化、装备信息
function BattleCreature:InitMonster( )
	self:setMoveAndAttackSpeedParam();
	self.m_fLife = self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
	self.m_fRawLife = self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
end

-- 计算生物的移速、攻速
function BattleCreature:setMoveAndAttackSpeedParam( )
	-- 移速、攻速单独处理
	-- 移动速度值参数 （参数*速度=速度值） 5
	-- 攻击速度值参数（参数/攻击间隔=攻击速度值） 108
	-- local selfMoveSpeed = self:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED);
	-- cclog("*** self speed = %f, speed Param = %f", selfMoveSpeed, gBattleResource:MoveSpeedParam());
	-- self:SetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED, math.floor(selfMoveSpeed / gBattleResource:MoveSpeedParam()));
	-- self:SetAttrX(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED, 0.0);
	-- self:SetAttrY(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED, 1.0);
	-- cclog("*** after self speed = %f", self:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED));
	-- local selfAttackSpeed = self:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED);
	-- cclog("*** self AttackSpeed = %f, atkspeed Param = %f", selfAttackSpeed, gBattleResource:AttackSpeedParam());
	-- if selfAttackSpeed ~= 0 then
	-- 	self:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED, math.floor(gBattleResource:AttackSpeedParam() * 1000 / selfAttackSpeed));
	-- 	self:SetAttrX(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED, 0.0);
	-- 	self:SetAttrY(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED, 1.0);		
	-- end

	-- cclog("*** final equipment creature Id = %d, propId = %d, hp = %f, atk = %f, def = %f, speed = %f, attackspeed = %f", self:GetId(), self:GetAttr(ECreatureAttr.CREATURE_ATTR_ID), self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE), self:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK), self:GetAttr(ECreatureAttr.CREATURE_ATTR_DEFEND), self:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED), self:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED));
end

-- 设置植物身上的金币或阳光
function BattleCreature:setResource( infos )
	-- cclog("*********  setResource");
	if not infos then
		return;
	end

	self.resourceList = {};
	self.surplusResourceList = {};

	if infos[AttrType.AttrTypeMoney] then
		self.resourceList[AttrType.AttrTypeMoney] = infos[AttrType.AttrTypeMoney];
		self.surplusResourceList[AttrType.AttrTypeMoney] = self.resourceList[AttrType.AttrTypeMoney];
		-- cclog("*********  self.resourceList[AttrTypeMoney] = "..self.resourceList[AttrType.AttrTypeMoney]);
	end

	if infos[AttrType.AttrTypeSunshine] then
		self.resourceList[AttrType.AttrTypeSunshine] = infos[AttrType.AttrTypeSunshine];
		self.surplusResourceList[AttrType.AttrTypeSunshine] = self.resourceList[AttrType.AttrTypeSunshine];
		-- cclog("*********  self.resourceList[AttrTypeSunshine] = "..self.resourceList[AttrType.AttrTypeSunshine]);
	end
end

-- 通过伤害，获取植物身上的金币或阳光
function BattleCreature:getResourceData( damage )
	-- if not self.resourceList then
	-- 	return;
	-- end

	-- if damage >= 0 then
	-- 	return
	-- end

	-- local resourceTable = {};
	-- damage = math.abs(damage);
	-- local life = self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
	-- if damage > self.m_lastLife then
	-- 	damage = self.m_lastLife;
	-- end

	-- for k,v in pairs(self.resourceList) do
	-- 	if damage == self.m_lastLife then
	-- 		resourceTable[k] = self.surplusResourceList[k];
	-- 		cclog("***** 111 id = %d, k = %d, value = %f, damage = %d", self:GetId(), k, resourceTable[k], damage);
	-- 	else
	-- 		local value = math.floor(damage / life * v);
	-- 		cclog("***** id = %d, type = %d, value = %f, damage = %f, self.m_lastLife = %f, life = %f, resource = %f", self:GetId(), k, value, damage, self.m_lastLife, life, v);
	-- 		self.surplusResourceList[k] = self.surplusResourceList[k] - value;
	-- 		resourceTable[k] = value;
	-- 	end
	-- end

	-- for k,v in pairs(resourceTable) do
	-- 	cclog("*********** resourceTable v = "..v);
	-- end

	-- gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_GET_RESOURCE, self, resourceTable);
end

function BattleCreature:WakeUp( )
	if self:GetStatus(ECreatureStatus.CREATURE_STATUS_SLEEP) ~= 0 then
		self:SetStatus(ECreatureStatus.CREATURE_STATUS_SLEEP, 0);
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_WAKEUP, self);
	end
end

function BattleCreature:IsSleep( )
	return self:GetStatus(ECreatureStatus.CREATURE_STATUS_SLEEP) == 1;
end

-- @Param
-- @Return int
function BattleCreature:GetExtra( )
	return self.m_extra;
end

-- @Param
-- @Return int
function BattleCreature:GetHp( )
	return self.m_fLife;
end

-- @Param int
-- @Return void
function BattleCreature:SetHp( val )
	self.m_lastLife = self.m_fLife;
	self.m_fLife = val;
end

function BattleCreature:GetRawHp( )
	return self.m_fRawLife;
end

-- @Param
-- @Return bool
function BattleCreature:IsDead( )
	if self.m_fLife <= 0 then
		return true;
	else
		return false;
	end
end

-- @Param
-- @Return bool
function BattleCreature:IsFullBlood( )
	return (math.floor(self.m_fLife) == math.floor(self.m_fRawLife));
end

-- @Param int
-- @Return void
function BattleCreature:SetAction( val )
	-- if val == ECreatureAction.ACTION_MOVE then
	-- 	if self:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) == 1 then
	-- 		self.m_nLastAction = val;
	-- 		return;
	-- 	end
	-- end

	if self.m_action ~= val and val == ECreatureAction.ACTION_MOVE then
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_MOVE, self);
	end

	self.m_nLastAction = self.m_action;
	self.m_action = val;
end

-- @Param void
-- @Return int
function BattleCreature:GetAction( )
	return self.m_action;
end

-- @Param void
-- @Return int
function BattleCreature:GetLastAction( )
	return self.m_nLastAction;
end

-- @Param int
-- @Return void
function BattleCreature:SetAttackTimes( val )
	self.m_nAttackTimes = val;
end

-- @Param void
-- @Return int
function BattleCreature:GetAttackTimes( )
	return self.m_nAttackTimes;
end

-- @Param void
-- @Return void
function BattleCreature:ClearAttackAI( )
	self.m_pAttackAI = nil;
end

-- @Param
-- @Return void
function BattleCreature:ResetAttackStatus( )
	self:SetStatus(ECreatureStatus.CREATURE_STATUS_ATTACK, 0);
	self:SetStatus(ECreatureStatus.CREATURE_STATUS_PRE, 0);
end

-- @Param
-- @Return void
function BattleCreature:DoEnd( )
	self:SetValid(false);
	self:SetPos(0);
	self:SetStatus(ECreatureStatus.CREATURE_STATUS_INV, 1);
end

-- @Param BattleBuff*, Battle*
-- @Return 
function BattleCreature:AddBuff( pBuff, pBattle )
	-- cclog("***  BattleCreature:AddBuff pBuff.m_id = "..pBuff.m_id);
	-- 更新buff
	for i,v in ipairs(self.m_buffs) do
		if pBuff.m_id == v.m_id then
			v:SetBeginTime(pBattle:GetCurrentTime());
			v:SetOverlap(v:GetOverlap() + 1);
			-- 添加事件 
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ADD_BUFF, self, pBuff.m_id);
			return;
		end
	end

	-- 添加新buff
	table.insert(self.m_buffs, pBuff);
	pBuff:SetOverlap(1);
	local newBuff = pBuff;
	newBuff:Create(self, pBattle:GetCurrentTime());
	newBuff:DoBuff(EBattleBuffEvent.BATTLE_BUFF_EVENT_ADD, pBattle);

	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ADD_BUFF, self, pBuff.m_id);
end

-- @Param int
-- @Return 
function BattleCreature:DelBuff( id )
	for i,v in ipairs(self.m_buffs) do
		if id == v.m_id then
			v:SetValid(false);
			return;
		end
	end
end

-- @Param EBattleBuffEvent
-- @Return 
function BattleCreature:DoBuff( event )
	for i,v in ipairs(self.m_buffs) do
		if v:GetValid() and v.m_buffData.event == event then
			if gBattleConditionMgr:Check(self.m_pBattle, self, v.m_conditions) then
				v:DoBuff(event, self.m_pBattle);
			end
		end
	end
end

function BattleCreature:UpdateBuff( )
	if #self.m_buffs <= 0 then
		return;
	end
	
	local eventBuffIdList = {};
	local deleteBuffIdList = {};

	for i=1,#self.m_buffs do
		local pBuff = self.m_buffs[i];
		if pBuff:GetValid() then
			pBuff:Update(self.m_pBattle:GetCurrentTime(), self, self.m_pBattle);
		end

		if not pBuff:GetValid() then
			-- 添加事件
			local buffId = pBuff.m_id + 0;
			table.insert(eventBuffIdList, buffId);
			table.insert(deleteBuffIdList, i);
			pBuff:Relase();
		end
	end

	for i=#deleteBuffIdList,1,-1 do
		table.remove(self.m_buffs, deleteBuffIdList[i]);
	end
	for i=1,#eventBuffIdList do
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DEL_BUFF, self, eventBuffIdList[i]); 
	end
end

-- @Param CBattleUnit*, DamageProp&
-- @Return int
function BattleCreature:DoDamage( pAttack, attackDamage )
	-- cclog("**** 0 id = "..self:GetId());
	-- 免疫
	if self:GetStatus(ECreatureStatus.CREATURE_STATUS_INV) == 1 then
		return 0;
	end

	-- 伤害计算	攻击 * （攻击 / （攻击 + 防御）） c1
	local defend = self:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_DEFEND);
	-- local damage = attack * (attack / (attack + defend));
	local damage = attackDamage:GetValue() - defend;
	-- cclog("**** 1 damage = %f, attack = %f, defend = %f", damage, attackDamage:GetValue(), defend);
	-- local nMinDamage = gBattleResource:MinDamageParam() * attackDamage:GetValue() / 100;
	-- -- cclog("**** 2 damage = %f, nMinDamage = %f", damage, nMinDamage);
	-- if damage < nMinDamage then
	-- 	damage = nMinDamage;
	-- end

	-- 进攻方修正
	damage = damage * (1 + attackDamage:GetX()) * attackDamage:GetY() + attackDamage:GetZ();
	-- cclog("**** 3 damage = %f, x = %f, y = %f, z = %f", damage, attackDamage:GetX(), attackDamage:GetY(), attackDamage:GetZ());

	-- 防守方修正
	damage = damage * (1 + self:GetDefendDamage():GetX()) * self:GetDefendDamage():GetY() + self:GetDefendDamage():GetZ();
	-- cclog("**** 4 damage = %f, x = %f, y = %f, z = %f", damage, self:GetDefendDamage():GetX(), self:GetDefendDamage():GetY(), self:GetDefendDamage():GetZ());

	-- 种族修正
	local fDamageRace = 1.0;
	local pDamageRace = gBattleResource:GetDamageRace(attackDamage:GetDamageRace(), self:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE)) / 100.0;
	if pDamageRace > 0 then
		fDamageRace = pDamageRace;
	end
	-- 护甲修正
	local fDamageType = 1.0;
	-- cclog("***** attackDamage:GetDamageType() = "..attackDamage:GetDamageType());
	local nDefendType = gBattleResource:GetDamageType(attackDamage:GetDamageType());
	-- cclog("****  nDefendType = "..nDefendType);
	if nDefendType > 0 then
		-- cclog("**** self:GetAttr(nDefendType) = "..self:GetAttr(nDefendType));
		fDamageType = self:GetAttr(nDefendType) / 100.0;
	end

	--战旗属性克制
	local fAttrRestraintValue = 1.0;
	local nAttrRestraintValue = gBattleResource:GetAttrRestraintValue(attackDamage:GetAttrType(),attackDamage:GetAttrLevel(),self:GetDefendDamage():GetAttrType(),self:GetDefendDamage():GetAttrLevel());
	if nAttrRestraintValue > 0 then
		fAttrRestraintValue = nAttrRestraintValue / 100;
	end
	--cclog("#################：fAttrRestraintValue = " .. tostring(fAttrRestraintValue))

	damage = damage * fDamageRace * fDamageType * fAttrRestraintValue;
	-- cclog("**** 5 damage = %f, fDamageRace = %f, fDamageType = %f", damage, fDamageRace, fDamageType);

	if damage <= 0 then
		return 0;
	end
	damage = damage + MODIFY_FLOAT;
	-------------------- 客户端动画处理逻辑 --------------------
	local creaturelife = self:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
	local isHealthParam = {false, false};
	local injuryHpPre = 0.4;
	if self:GetIsAttack() then
		if self.m_fLife >= creaturelife * injuryHpPre then
			isHealthParam[1] = true;
		end
	else
		if self:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) == EPlantCreatureType.WALLNUT_TYPE then
			if self.m_fLife >= creaturelife * 2/3 then
				isHealthParam[1] = true;
			elseif self.m_fLife >= creaturelife * 1/3 then
				isHealthParam[2] = true;
			end
		end
	end
	-------------------------------------------------------------

	damage = self:DoModifyHP(0-math.floor(damage), pAttack);

	-------------------- 客户端动画处理逻辑 --------------------
	-- 是否受伤动画
	if self:GetIsAttack() then
		if self.m_fLife < creaturelife * injuryHpPre and isHealthParam[1] then
			-- 添加事件
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_INJURY, self); 
		end
	else
		if self:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) == EPlantCreatureType.WALLNUT_TYPE then

			-- 添加事件 坚果受伤换皮肤
			if self.m_fLife < creaturelife * 2/3 and isHealthParam[1] then
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_INJURY, self);
			elseif self.m_fLife < creaturelife * 1/3 and isHealthParam[2] then 
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_INJURY, self);
			end
		end
	end

	-- 是否掉钱
	self:getResourceData(damage);
	-------------------------------------------------------------

	-- cclog("*********  GetHp = %f", self:GetHp());
	return damage;
end

-- @Param float
-- @Return int
-- 直接掉血，不计算攻防
function BattleCreature:DoModifyHP( hp, pAttack )
	-- 加血处理
	if hp > 0 then
		self.m_fLife = self.m_fLife + hp;
		self.m_fLife = math.min(self.m_fLife, self.m_fRawLife);
		return hp;
	end

	-- 掉血处理
	-- 惊醒
	local pBullet = nil;
	local isWakeup = false;
	if pAttack:isInstanceOf(BattleBullet) then
		pBullet = pAttack;
		if pBullet:GetProp().wakeup == 1 then
			isWakeup = true;
		end
	end
	if not pBullet or isWakeup then
		self:WakeUp();
	end

	-- 免疫
	if self:GetStatus(ECreatureStatus.CREATURE_STATUS_INV) == 1 then
		return 0;
	end

	self:SetHp(self.m_fLife + hp);

	-- 死了
	if self.m_fLife <= 0 then
		self:DoDead();
	end

	return hp;
end

-- @Param float
-- @Return int
-- 修改生物血量上限
function BattleCreature:DoModifyHpMax(value)
	--修改血量上限值  
	self.m_fRawLife = self.m_fRawLife + value;
	if self.m_fRawLife < 0.0 then
		self.m_fRawLife = 0.0;
	end
	--修正当前血量值
	self.m_fLife = math.min(self.m_fLife, self.m_fRawLife);
	--如果血量上限将为 0 则作死亡处理
	if self.m_fLife <= 0.0 then
		self:DoDead();
	end

	return value;
end

-- @Param 
-- @Return void
function BattleCreature:DoDead( deadWay )
	self.m_nDeadWay = deadWay or EDeadWay.DEAD_NORMAL;

	self.m_fLife = 0;
	self:SetValid(false);
	self:DoBuff(EBattleBuffEvent.BATTLE_BUFF_EVENT_DEAD);

	if self:GetValid() then
		return;
	end

	-- 死亡的战斗力统计
	if self:GetIsAttack() then
		self.m_pBattle:SetAttackDeadCombat(self:GetAttr(ECreatureAttr.CREATURE_ATTR_COMBAT));
	else
		self.m_pBattle:SetDefendDeadCombat(self:GetAttr(ECreatureAttr.CREATURE_ATTR_COMBAT));
	end  

	self:DoSpoils();
end

function BattleCreature:DoAttack( )
	self:DoBuff(EBattleBuffEvent.BATTLE_BUFF_EVENT_ATTACK);
	return 0;
end

-- @Param Enum(ECreatureStatus)
-- @Return int
function BattleCreature:GetStatus( key )
	assert(key < ECreatureStatus.CREATURE_STATUS_MAX, "BattleCreature:getStatus() Error key = "..key);
	return self.m_status[key];
end

-- @Param int, int
-- @Return void
function BattleCreature:SetStatus( key, value )
	assert(key < ECreatureStatus.CREATURE_STATUS_MAX, "BattleCreature:setStatus() Error key = "..key);
	self.m_status[key] = value;
end

-- @Param int, int
-- @Return void
function BattleCreature:ModifyStatus( key, value )
	assert(key < ECreatureStatus.CREATURE_STATUS_MAX, "BattleCreature:ModifyStatus() Error key = "..key);
	self.m_status[key] = self.m_status[key] + value;
	if self.m_status[key] < 0 then
		self.m_status[key] = 0;
	end
end


function BattleCreature:GetAttackDamage( )
	self.m_attackDamage:SetValue(self:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK));
	self.m_attackDamage:SetDamageRace(self:GetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_RACE));
	self.m_attackDamage:SetDamageType(self:GetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_TYPE));

	return self.m_attackDamage;
end

function BattleCreature:GetDefendDamage( )
	self.m_defendDamage:SetValue(self:GetAttr(ECreatureAttr.CREATURE_ATTR_DEFEND));
	return self.m_defendDamage
end

-- @Param int, CBattle*
-- @Return void
function BattleCreature:Update( time, pBattle )
	if self:IsSleep() then
		return;
	end

	if self.m_nSelfTime == 0 then
		self.m_nSelfTime = time;
	else
		-- 被定身不更新时间
		if self:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) == 0 then
			self.m_nSelfTime = self.m_nSelfTime + pBattle:GetUnitTime();
		end
	end

	-- 技能释放
	if self.m_pSkillAI then
		-- 定身、不能攻击、攻击前摇、后摇 时不能释放技能  
		if self:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) == 0 and
			self:GetStatus(ECreatureStatus.CREATURE_STATUS_NO_ATTACK) == 0 and
				self:GetStatus(ECreatureStatus.CREATURE_STATUS_PRE) == 0 and 
					self:GetStatus(ECreatureStatus.CREATURE_STATUS_POST) == 0 and
						self:GetStatus(ECreatureStatus.CREATURE_STATUS_NO_SKILL) == 0 then
			-- cclog("*****  self.m_pSkillAI:Update");
			self.m_pSkillAI:Update(self.m_nSelfTime, self, pBattle);
		end
	end

	-- 攻击处理
	if self.m_pAttackAI and 
		self:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) == 0 and
		self:GetAction() ~= ECreatureAction.ACTION_SKILL and 
		self:GetStatus(ECreatureStatus.CREATURE_STATUS_NO_ATTACK) == 0 then
		self.m_pAttackAI:Update(self.m_nSelfTime, self, pBattle);
	end

	-- 移动处理，没有攻击时才能移动
	if self.m_pMoveAI and self:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) == 0 then
		self.m_pMoveAI:Update(self.m_nSelfTime, self, pBattle);
	end

	-- Buff更新
	self:UpdateBuff();
	-- local eventBuffIdList = {};
	-- for i=#self.m_buffs,1,-1 do
	-- 	local pbuff = self.m_buffs[i];
	-- 	if pbuff:GetValid() then
	-- 		pbuff:Update(time, self, pBattle);
	-- 		if not pbuff:GetValid() then
	-- 			-- 添加事件
	-- 			local buffId = pbuff.m_id + 0;
	-- 			table.insert(eventBuffIdList, buffId);
	-- 			pbuff:Relase();
	-- 			-- table.insert(deleteList, i);
	-- 			table.remove(self.m_buffs, i);
	-- 		end
	-- 	end
	-- end

	-- for i=#eventBuffIdList,1,-1 do
	-- 	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DEL_BUFF, self, eventBuffIdList[i]); 
	-- end
end

-- @Param
-- @Return void
function BattleCreature:_ClearPostion( )
	self:SetRoad(-1);
	self:SetPos(-1);
end

function BattleCreature:DoSpoils( )
	if self.m_pBattle:GetType() == BattleType.BattleTypeEvp or self.m_pBattle:GetType() == BattleType.BattleTypePve then
		return;
	end
	--[[
	当敌方死亡战力小于等于己方死亡战力时，直接使用基础掉率；
	当敌方死亡战力大于己方死亡战力时，会对基础掉落做一个修正；
	修正值 =（1-（（对手死亡-自己死亡）/（对手死亡+自己死亡+1））/）^2)^参数1
	]]--
	local pInfo = nil;
	if self:GetIsAttack() then
		pInfo = self.m_pBattle:GetCreatureReturnInfo(self:GetIsAttack(), self.m_extra);
	else
		pInfo = self.m_pBattle:GetCreatureReturnInfo(self:GetIsAttack(), self:GetId());
	end
	if not pInfo then
	 	return;
	end

	local selfCombat = 0.0;
	local enemy = 0.0;
	if self:GetIsAttack() then
		selfCombat = self.m_pBattle:GetAttackDeadCombat();
		enemy = self.m_pBattle:GetDefendDeadCombat();
	else
		selfCombat = self.m_pBattle:GetDefendDeadCombat();
		enemy = self.m_pBattle:GetAttackDeadCombat();
	end
	local fSpoilsParma = math.pow((1.0 - math.pow((enemy - selfCombat) / (enemy + selfCombat + 1), 2)), 1);
	if enemy <= selfCombat then
		fSpoilsParma = 1;
	end

	local dieReturnInfo = self:GetDropReturnInfo(pInfo.die, fSpoilsParma);
	local killReturnInfo = self:GetDropReturnInfo(pInfo.kill, fSpoilsParma);
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_BATTLE_DROP, self, killReturnInfo, dieReturnInfo);
end

function BattleCreature:GetDropReturnInfo( returnInfo, spoilsParma )
	local info = VReturnInfo:new();
	if returnInfo then
		for _, v in pairs(returnInfo.returnAttrInfo) do
			local value = v.value * spoilsParma;
			value = math.floor(value);
			if value > 0 then
				local data = VReturnAttrInfo:new(v);
				data.value = value;
				table.insert(info.returnAttrInfo, data);
			end
		end
		for _, v in pairs(returnInfo.returnThingInfo) do
			if v.count > 0 then
				local prob = math.floor(v.param0 * spoilsParma + MODIFY_FLOAT);
				local rand = self.m_pBattle:GetRandom(1,100000);
				if rand <= prob then
					local data = VReturnThingInfo:new(v);
					table.insert(info.returnThingInfo, data);
				end
			end
		end
	end 
	return info;
end

function BattleCreature:AttackCount()
	return self.m_nAttackCount;
end

function BattleCreature:IncAttackCount()
	self.m_nAttackCount = self.m_nAttackCount + 1;
end

function BattleCreature:GetDeadWay()
	return self.m_nDeadWay;
end
---------------------------------------  BattleObject  ---------------------------------------
BattleObject = vclass("BattleObject", BattleCreature);

function BattleObject:initialize( prop )
	-- super create
	BattleCreature.initialize(self, prop);

	self:SetMode(EUnitType.TYPE_CREATURE_OBJECT);
	self.m_nMaxTime = 0; 					-- 最大存活时间
end

-- @Param bool, int, int
-- @Return void
function BattleObject:Create( bAttack, id, pBattle, time )
	self.m_nMaxTime = time;
	self.m_pAttackAI = gBattleAIMgr:GetAttackAI(self:GetAttr(ECreatureAttr.CREATURE_ATTR_AI_ATTACK));
	self.m_pSkillAI = gBattleAIMgr:GetSkillAI(self:GetAttr(ECreatureAttr.CREATURE_ATTR_AI_SKILL));
	self.m_pBattle = pBattle;

	self.m_attackDamage:SetValue(self:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK));
	self.m_attackDamage:SetDamageRace(self:GetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_RACE));
	self.m_attackDamage:SetDamageType(self:GetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_TYPE));

	self:SetId(id);
	self:SetValid(true);
	self:SetIsAttack(bAttack);

	--记录技能
	local skillId = self:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL);
	if skillId ~= 0 then
		self.m_Skill = gBattleResource:GetSkillProp(skillId);
	end
	--记录子弹
	self.m_Bullet = gBattleResource:GetBulletProp(self:GetAttr(ECreatureAttr.CREATURE_ATTR_BULLET));
	
	return true;
end

-- @Param 
-- @Return void
function BattleObject:close( )
	
end

-- @Param int, CBattle*
-- @Return void
function BattleObject:Update( time, pBattle )
	-- 已经到期
	if self.m_nSelfTime >= self.m_nMaxTime then
		self:DoDead();
		return;
	end

	self.m_nSelfTime = self.m_nSelfTime + pBattle:GetUnitTime();

	-- 释放技能
	if self.m_pSkillAI then
		self.m_pSkillAI:Update(self.m_nSelfTime, self, pBattle);
	end

	-- 攻击处理
	if self.m_pAttackAI then
		self.m_pAttackAI:Update(self.m_nSelfTime, self, pBattle);
	end
end
