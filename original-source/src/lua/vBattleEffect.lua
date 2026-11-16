--vBattleEffect.lua


-- @Param int, CBattleUnit*, CBattleUnit*
-- @Return BattleCreature*
function GetTargetCreature( target, pSelf, pTarget )
	if target == 1 and pSelf:isInstanceOf(BattleCreature) then
		return pSelf;
	elseif target == 2 and pTarget:isInstanceOf(BattleCreature) then
		return pTarget;
	end

	return nil;
end

-- @Param int, CBattleUnit*, CBattleUnit*
-- @Return BattleUnit*
function GetTargetUnit( target, pSelf, pTarget )
	if target == 1 then
		return pSelf;
	elseif target == 2 then
		return pTarget;
	end

	return nil;
end

local local_bit = gBit;

---------------------------------------  BattleEffectMgr  ---------------------------------------

BattleEffectMgr = vclass("BattleEffectMgr");

function BattleEffectMgr:initialize( )
	self.m_effects = {};						-- map<int, CBattleBaseEffect*>
end

-- @Param 
-- @Return bool
function BattleEffectMgr:Create( )
	self.m_effects[EBattleEffect.EFFECT_MODIFY_ATTR] = BattleEffectModifyAttr:new();
	self.m_effects[EBattleEffect.EFFECT_MODIFY_STATUS] = BattleEffectModifyStatus:new();
	self.m_effects[EBattleEffect.EFFECT_ADD_BUFF] = BattleEffectAddBuff:new();
	self.m_effects[EBattleEffect.EFFECT_DAMAGE] = BattleEffectDamage:new();
	self.m_effects[EBattleEffect.EFFECT_DANCE] = BattleEffectDance:new();
	self.m_effects[EBattleEffect.EFFECT_MODIFY_DAMAGE] = BattleEffectModifyDamage:new();
	self.m_effects[EBattleEffect.EFFECT_OBJECT] = BattleEffectObject:new();
	self.m_effects[EBattleEffect.EFFECT_SONW_MAN] = BattleEffectSnowMan:new();
	self.m_effects[EBattleEffect.EFFECT_SECKILL] = BattleEffectSeckill:new();
	self.m_effects[EBattleEffect.EFFECT_SHEEP] = BattleEffectSheep:new();
	self.m_effects[EBattleEffect.EFFECT_HP_1] = BattleEffectHPOne:new();
	self.m_effects[EBattleEffect.EFFECT_HP_2] = BattleEffectHPTwo:new();
	self.m_effects[EBattleEffect.EFFECT_BLACKHOLE] = BattleEffectBlackHole:new();
	self.m_effects[EBattleEffect.EFFECT_DAMAGE_2] = BattleEffectDamageTwo:new();
	self.m_effects[EBattleEffect.EFFECT_REVIVE] = BattleEffectRevive:new();
	self.m_effects[EBattleEffect.EFFECT_BULLET] = BattleEffectBullet:new();
	self.m_effects[EBattleEffect.EFFECT_RANGE_DAMAGE] = BattleEffectRangeDamage:new();
	self.m_effects[EBattleEffect.EFFECT_MOVE] = BattleEffectMove:new();
	self.m_effects[EBattleEffect.EFFECT_DEL_BUFF] = BattleEffectDelBuff:new();
	self.m_effects[EBattleEffect.EFFECT_MODIFY_HP_MAX] = BattleEffectModifyHpMax:new();
	self.m_effects[EBattleEffect.EFFECT_DAMAGE_3] = BattleEffectDamageThree:new();
	self.m_effects[EBattleEffect.EFFECT_SUICIDE] = BattleEffectSuicide:new();

	return true;
end

-- @Param 
-- @Return 
function BattleEffectMgr:Close( )
	for k,v in pairs(self.m_effects) do
		v = nil;
	end
	self.m_effects = {};
end

-- @Param int
-- @Return BattleBaseEffect
function BattleEffectMgr:GetEffect( id )
	assert(id >= 0 , "BattleEffectMgr:GetEffect() Error id < 0");
	assert(id < EBattleEffect.EFFECT_MAX , "BattleEffectMgr:GetEffect() Error id > EFFECT_MAX");

	return self.m_effects[id];
end

---------------------------------------  BattleBaseEffect  ---------------------------------------

BattleBaseEffect = vclass("BattleBaseEffect");

function BattleBaseEffect:initialize( )
end

-- @Param CBattleUnit*, BattleEffectProp*, CBattleBuff*
-- @Return 
function BattleBaseEffect:DoClose( pSelf, pEffect, pBuff )
--	assert(1 ~= 1);
end

-- @Param 
-- @Return 
function BattleBaseEffect:DoCheck( )
	-- todo
end

-- 添加生物
-- @Param CBattle*, int, int, const CBattleUnit*, int, int, int, int
-- @Return bool
function BattleBaseEffect:AddNewMonster( pBattle, road, pos, pUnit, id, hp, attack, defend, buffid, bufftime )
	if not pUnit then return; end

	local pMonsterProp = gBattleResource:GetMonsterProp(id);
	if pMonsterProp == nil then return; end

	local pNewCreature = BattleUnitFactory:GetNewCreature(pMonsterProp:GetMode(), pMonsterProp);
	if not pNewCreature then return; end

	local newId = pBattle:GetNewCreatureId();
	pNewCreature:SetAttr(ECreatureAttr.CREATURE_ATTR_LIFE, pUnit:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * hp / 100);
	pNewCreature:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK, pUnit:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_ATTACK) * attack / 100);
	pNewCreature:SetAttr(ECreatureAttr.CREATURE_ATTR_DEFEND, pUnit:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_DEFEND) * defend / 100);
	pNewCreature:Create(true, newId, pBattle, newId);
	pNewCreature:InitMonster();
	pNewCreature.parentId = pUnit:GetId();
	pBattle:AddCreatureToMgr(pNewCreature, true);
	pBattle:ActiveCreature(pNewCreature, road, pos, false);
	pBattle:AddLivingAttackers(pNewCreature:GetExtra(), pNewCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ID));

	--召唤出的僵尸 支持出生添加BUFF
	buffid = buffid or 0;
	bufftime = bufftime or 0;
	local pBuffProp = gBattleResource:GetBuffProp(buffid);
	if not pBuffProp then
		pBattle:AddTempAttack(pNewCreature);
		return;
	end
	local pNewBuff = BattleBuff:new(pBuffProp);
	if pNewBuff.m_buffData.event == EBattleBuffEvent.BATTLE_BUFF_EVENT_ADD then
		if not gBattleConditionMgr:Check(pBattle, pNewCreature, pNewBuff.m_conditions) then
			pBattle:AddTempAttack(pNewCreature);
			return;
		end
	end
	pNewBuff.m_buffData.time = bufftime; -- 秒转换为毫秒
	pNewCreature:AddBuff(pNewBuff, pBattle);
	-- 客户端使用加入临时列表 在当前遍历中跑一次
	pBattle:AddTempAttack(pNewCreature);
end

---------------------------------------  BattleEffectModifyAttr  ---------------------------------------
-- 修改生物属性

BattleEffectModifyAttr = vclass("BattleEffectModifyAttr", BattleBaseEffect);

function BattleEffectModifyAttr:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature*>&, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectModifyAttr:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local key = pEffect.params[1];	-- ECreatureAttr
	local op = pEffect.params[2];
	local value = pEffect.params[3];

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			-- 加法
			if op == 1 then
				pCreature:SetAttr(key, pCreature:GetAttr(key) + value);
			elseif op == 2 then -- 乘法
				if value >= 0 then
					pCreature:SetAttrX(key, pCreature:GetAttrX(key) + value / 100.0);
				else
					pCreature:SetAttrY(key, pCreature:GetAttrY(key) * (1.0 + value / 100.0));
				end
			end
		end
	end
end

-- @Param CBattleUnit*, BattleEffectProp*, CBattleBuff*
-- @Return 
function BattleEffectModifyAttr:DoClose( pSelf, pEffect, pBuff )
	local pCreature = pSelf;
	if not pCreature:isInstanceOf(BattleCreature) then return; end
	if not pCreature then return; end

	local key = pEffect.params[1];
	local op = pEffect.params[2];
	local value = pEffect.params[3];
	-- 加法
	if op == 1 then
		pCreature:SetAttr(key, pCreature:GetAttr(key) - value);
	elseif op == 2 then -- 乘法
		if value >= 0 then
			pCreature:SetAttrX(key, pCreature:GetAttrX(key) - value / 100.0);
		else
			pCreature:SetAttrY(key, pCreature:GetAttrY(key) / (1.0 + value / 100.0));
		end
	end
end

---------------------------------------  BattleEffectModifyStatus  ---------------------------------------
-- 添加修改生物状态

BattleEffectModifyStatus = vclass("BattleEffectModifyStatus", BattleBaseEffect);

function BattleEffectModifyStatus:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature*>&, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectModifyStatus:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local key = pEffect.params[1];
	if key < 0 or key > ECreatureStatus.CREATURE_STATUS_MAX then
		return;
	end

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			if key == ECreatureStatus.CREATURE_STATUS_HOLD then
				pCreature:ModifyStatus(key, pEffect.params[2]);
			else
				pCreature:SetStatus(key, pEffect.params[2]);
			end
		end
	end
end

-- @Param CBattleUnit*, BattleEffectProp*, CBattleBuff*
-- @Return 
function BattleEffectModifyStatus:DoClose( pSelf, pEffect, pBuff )
	local pCreature = pSelf;
	if not pCreature:isInstanceOf(BattleCreature) then return; end
	if not pCreature then return; end

	local key = pEffect.params[1];
	if key < 0 or key > ECreatureStatus.CREATURE_STATUS_MAX then
		return;
	end

	if key == ECreatureStatus.CREATURE_STATUS_HOLD then
		pCreature:ModifyStatus(key, -1);
	else
		pCreature:SetStatus(key, 0);
	end
end

---------------------------------------  BattleEffectAddBuff  ---------------------------------------
-- 添加Buff

BattleEffectAddBuff = vclass("BattleEffectAddBuff", BattleBaseEffect);

function BattleEffectAddBuff:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectAddBuff:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	-- cclog("******  pBuff.id = "..pBuff.m_id);
	-- cclog("****** BattleEffectAddBuff:DoEffect pSelf.id = "..pSelf:GetId());
	-- cclog("******  pEffect.params[1] = "..pEffect.params[1]);
	local pBuffProp = gBattleResource:GetBuffProp(pEffect.params[1]);
	if not pBuffProp then
		-- cclog("***** pBuffProp nil, return");
		return;
	end
	-- cclog("***** targets count = "..#targets);
	for i,v in ipairs(targets) do
		local pCreature = v;
		-- cclog("***** pCreature id = "..pCreature:GetId());
		if pCreature and pCreature:GetValid() then
			local pNewBuff = BattleBuff:new(pBuffProp);
			if pNewBuff.m_buffData.event == EBattleBuffEvent.BATTLE_BUFF_EVENT_ADD then
				if not gBattleConditionMgr:Check(pBattle, pCreature, pNewBuff.m_conditions) then
					-- cclog("**** Check false, return");
					return;
				end
			end
			-- cclog("******** AddBuff");
			pNewBuff.m_buffData.time = pEffect.params[2]; -- 秒转换为毫秒
			pCreature:AddBuff(pNewBuff, pBattle);
		end
	end
end

function BattleEffectAddBuff:DoClose( pSelf, pEffect, pBuff )
end
---------------------------------------  BattleEffectDamage  ---------------------------------------
-- 范围攻击(九宫格)
BattleEffectDamage = vclass("BattleEffectDamage", BattleBaseEffect);

function BattleEffectDamage:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectDamage:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local fValue = pSelf:GetAttackDamage():GetValue() * pEffect.params[1] / 100;
	local attackDamage = DamageProp:new();
	attackDamage:copyWithProp(pSelf:GetAttackDamage());
	attackDamage:SetValue(fValue);

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			-- 伤害
			local damage = pCreature:DoDamage(pSelf, attackDamage);
			-- 添加事件
			-- cclog("****************** BattleEffectDamage:DoEffect");
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pCreature, damage, pSelf);
		end
	end
end

---------------------------------------  BattleEffectDance  ---------------------------------------
-- 跳舞

BattleEffectDance = vclass("BattleEffectDance", BattleBaseEffect);

function BattleEffectDance:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectDance:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local road = pSelf:GetRoad();
	local pos = pSelf:GetPos();
	
	if (pos - gBattleView.cellNum) > 0 then
		local pData = gBattleResource:GetDanceProp(pEffect.params[1], pBattle:GetRandom(1,100));
		if pData then
			local pUnit = gBattleResource:GetMonsterProp(pData.monsterid);
			self:AddNewMonster(pBattle, road, pos - gBattleView.cellNum, pUnit, pData.monsterid, pData.hp_param, pData.attack_param, pData.defend_param, pData.born_buffid, pData.born_bufftime);
		end
	end

	if (pos + gBattleView.cellNum) < pBattle:GetGround():GetLen() then
		local pData = gBattleResource:GetDanceProp(pEffect.params[2], pBattle:GetRandom(1,100));
		if pData then
			local pUnit = gBattleResource:GetMonsterProp(pData.monsterid);
			self:AddNewMonster(pBattle, road, pos + gBattleView.cellNum, pUnit, pData.monsterid, pData.hp_param, pData.attack_param, pData.defend_param, pData.born_buffid, pData.born_bufftime);
		end
	end

	if pBattle:GetGround():HasRoad(road - 1) then
		local pData = gBattleResource:GetDanceProp(pEffect.params[3], pBattle:GetRandom(1,100));
		if pData then
			local pUnit = gBattleResource:GetMonsterProp(pData.monsterid);
			self:AddNewMonster(pBattle, road - 1, pos, pUnit, pData.monsterid, pData.hp_param, pData.attack_param, pData.defend_param, pData.born_buffid, pData.born_bufftime);
		end
	end

	if pBattle:GetGround():HasRoad(road + 1) then
		local pData = gBattleResource:GetDanceProp(pEffect.params[4], pBattle:GetRandom(1,100));
		if pData then
			local pUnit = gBattleResource:GetMonsterProp(pData.monsterid);
			self:AddNewMonster(pBattle, road + 1, pos, pUnit, pData.monsterid, pData.hp_param, pData.attack_param, pData.defend_param, pData.born_buffid, pData.born_bufftime);
		end
	end
end

---------------------------------------  BattleEffectModifyDamage  ---------------------------------------
-- 修改伤害

BattleEffectModifyDamage = vclass("BattleEffectModifyDamage", BattleBaseEffect);

function BattleEffectModifyDamage:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectModifyDamage:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local targetType = pEffect.params[1];
	local valueType = pEffect.params[2];
	local value = pEffect.params[3];

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			-- 打出的伤害
			if targetType == 1 then
				local attackDamage = pCreature:GetAttackDamage();
				if valueType == 1 then
					attackDamage:SetX(attackDamage:GetX() + value / 100.0);
				elseif valueType == 2 then
					attackDamage:SetY(attackDamage:GetY() * (1.0 + value / 100.0));					
				elseif valueType == 3 then
					attackDamage:SetZ(attackDamage:GetZ() + value);
				end
			-- 受到的伤害
			elseif targetType == 2 then
				local defendDamage = pCreature:GetDefendDamage();
				if valueType == 1 then
					defendDamage:SetX(defendDamage:GetX() + value / 100.0);
				elseif valueType == 2 then
					defendDamage:SetY(defendDamage:GetY() * (1.0 + value / 100.0));					
				elseif valueType == 3 then
					defendDamage:SetZ(defendDamage:GetZ() + value);
				end
			end
		end
	end
end

-- @Param CBattleUnit*, BattleEffectProp*, CBattleBuff*
-- @Return 
function BattleEffectModifyDamage:DoClose( pSelf, pEffect, pBuff )
	assert(pSelf ~= nil, "BattleEffectModifyDamage:DoClose() Error pSelf = nil");
	local targetType = pEffect.params[1];
	local valueType = pEffect.params[2];
	local value = pEffect.params[3];
	local pCreature = pSelf;
	-- 打出的伤害
	if targetType == 1 then
		local attackDamage = pCreature:GetAttackDamage();
		if valueType == 1 then
			attackDamage:SetX(attackDamage:GetX() - value / 100.0);
		elseif valueType == 2 then
			attackDamage:SetY(attackDamage:GetY() / (1.0 + value / 100.0));					
		elseif valueType == 3 then
			attackDamage:SetZ(attackDamage:GetZ() - value);
		end
	-- 受到的伤害
	elseif targetType == 2 then
		local defendDamage = pCreature:GetDefendDamage();
		if valueType == 1 then
			defendDamage:SetX(defendDamage:GetX() - value / 100.0);
		elseif valueType == 2 then
			defendDamage:SetY(defendDamage:GetY() / (1.0 + value / 100.0));					
		elseif valueType == 3 then
			defendDamage:SetZ(defendDamage:GetZ() - value);
		end
	end
end

---------------------------------------  BattleEffectObject  ---------------------------------------
-- 制造物体

BattleEffectObject = vclass("BattleEffectObject", BattleBaseEffect);

function BattleEffectObject:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return void
function BattleEffectObject:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local pUnitProp = gBattleResource:GetObjectProp(pEffect.params[1]);
	if not pUnitProp then
		cclog("BattleEffectObject:DoEffect Error object %d prop is nil", pEffect.params[1]);
		return;
	end

	local pNewCreature = BattleUnitFactory:GetNewCreature(EUnitType.TYPE_CREATURE_OBJECT, pUnitProp);
	if not pNewCreature then return; end

	local pObject = nil;
	if pNewCreature:isInstanceOf(BattleObject) then
		pObject = pNewCreature;
	else
		return;
	end
	--属性继承
	local iAttack = pObject:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK);
	if pEffect.params[3] then
		iAttack = iAttack + pSelf:GetAttackDamage():GetValue() * pEffect.params[3] / 100;	
	end
	iAttack = math.floor(iAttack);
	pObject:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK, iAttack);
	
	pObject:Create(pSelf:GetIsAttack(), pBattle:GetNewCreatureId(), pBattle, pEffect.params[2]);
	pBattle:ActiveCreature(pObject, pSelf:GetRoad(), pSelf:GetPos(), false);
	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ADD_UNIT, pObject, pBattle:GetCurrentTime(), pSelf);
end

---------------------------------------  BattleEffectSnowMan  ---------------------------------------
-- 扔雪人
BattleEffectSnowMan = vclass("BattleEffectSnowMan", BattleBaseEffect);

function BattleEffectSnowMan:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectSnowMan:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	if not pSelf:isInstanceOf(BattleCreature) then 
		cclog("**** BattleEffectSnowMan:DoEffect Error");
		return;
	end

	-- 找到要扔的位置
	local nMinDistance = -1;
	local pMinEnemy = nil;
	local obj = {}
	pBattle:GetGround():GetCreatureByRoad(not pSelf:GetIsAttack(), pSelf:GetRoad(), obj);
	for k,v in pairsByKeys(obj) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			if local_bit:_and(pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE), EMoveType.MOVE_TYPE_GROUND) == 0 then
				-- continue;
			else
				local distance = pSelf:GetPos() - pEnemy:GetPos();
				if distance > gBattleView.cellNum * 3 or distance < 0 then
					-- continue;
				else
					if nMinDistance < distance then
						nMinDistance = distance;
						pMinEnemy = pEnemy;
					end
				end
			end				
		end
	end

	local pos = pSelf:GetPos() - gBattleView.cellNum * 3;
	
	if pMinEnemy ~= nil then
		pos = pMinEnemy:GetPos() - pMinEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
	end
	if pos < 0 then
		pos = 1;
	end

	-- 添加小怪
	self:AddNewMonster(pBattle, pSelf:GetRoad(), pos, pSelf, pEffect.params[1], pEffect.params[2], pEffect.params[3], pEffect.params[4]);
end

---------------------------------------  BattleEffectSeckill  ---------------------------------------
-- 秒杀
-----------------------------------------------------------------------------------------------------
BattleEffectSeckill = vclass("BattleEffectSeckill", BattleBaseEffect);

function BattleEffectSeckill:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectSeckill:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			pCreature:DoModifyHP(-pCreature:GetHp(), pSelf);
		end
	end
end

---------------------------------------  BattleEffectSheep  -----------------------------------------
-- 随机变羊
-----------------------------------------------------------------------------------------------------
BattleEffectSheep = vclass("BattleEffectSheep", BattleBaseEffect);

function BattleEffectSheep:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectSheep:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			--行为置为移动
			pCreature:SetAction(ECreatureAction.ACTION_MOVE);
			--攻击状态清理
			pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_PRE, 0);
			pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_POST, 0);
			--技能状态清理
			pCreature:ClearSkillStatusData();
			--不能攻击
			pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_NO_ATTACK, 1);
		end
	end
end

-- @Param CBattleUnit*, BattleEffectProp*, CBattleBuff*
-- @Return 
function BattleEffectSheep:DoClose( pSelf, pEffect, pBuff )
	if not pSelf:isInstanceOf(BattleCreature) then 
		cclog("**** BattleEffectSheep:DoEffect Error");
		return;
	end

	pSelf:SetStatus(ECreatureStatus.CREATURE_STATUS_NO_ATTACK, 0);
end

---------------------------------------  BattleEffectHPOne  -----------------------------------------
-- 加、减血数值（可叠加） 固定数值
-----------------------------------------------------------------------------------------------------
BattleEffectHPOne = vclass("BattleEffectHPOne", BattleBaseEffect);

function BattleEffectHPOne:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectHPOne:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			local hp = pEffect.params[1];
			if pBuff then
				hp = hp  * pBuff:GetOverlap();
			end
			hp = math.modf(hp);
			local damage = pCreature:DoModifyHP(hp, pSelf);
			-- 添加事件
			if damage > 0 then
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ADD_HP, pCreature, damage, pSelf);
			else
				-- cclog("****************** BattleEffectHPOne:DoEffect");
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pCreature, damage, pSelf);
			end
		end
	end
end

---------------------------------------  BattleEffectHPTwo  -----------------------------------------
-- 加、减血数值（可叠加） 百分比
-----------------------------------------------------------------------------------------------------
BattleEffectHPTwo = vclass("BattleEffectHPTwo", BattleBaseEffect);

function BattleEffectHPTwo:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectHPTwo:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			local hp = pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * pEffect.params[1] / 100 + MODIFY_FLOAT;
			hp = math.modf(hp);
			local damage = pCreature:DoModifyHP(hp, pSelf);

			if damage > 0 then
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ADD_HP, pCreature, damage, pSelf);
			else
				-- cclog("****************** BattleEffectHPTwo:DoEffect");
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pCreature, damage, pSelf);
			end
		end
	end
end

---------------------------------------  BattleEffectBlackHole  -----------------------------------------
-- 黑洞
-----------------------------------------------------------------------------------------------------
BattleEffectBlackHole = vclass("BattleEffectBlackHole", BattleBaseEffect);

function BattleEffectBlackHole:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectBlackHole:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	if not pBattle:CheckPostion(pSelf:GetRoad(), pSelf:GetPos()) then
		return;
	end

	-- 选择目标
	targets = {};
	local position = PositionData:new();
	position.pos = pSelf:GetPos();
	position.road = pSelf:GetRoad();
	local diff = pEffect.params[1] / 2;
	pBattle:GetGround():GetRangeCreatures(not pSelf:GetIsAttack(), position, 0, -diff, diff, pEffect.magic_valid, targets);
	if #targets <= 0 then
		return;
	end

	local pBuffProp = gBattleResource:GetBuffProp(pEffect.params[2]);

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			-- 移动
			pCreature:SetPos(pSelf:GetPos());
			pCreature:SetTarget(0);

			-- 添加buff
			if pBuffProp then
				local newBuff = BattleBuff:new(pBuffProp);
				newBuff.m_buffData.time = pEffect.params[3];

				if pBuffProp.m_buffData.event == EBattleBuffEvent.BATTLE_BUFF_EVENT_ADD then
					if gBattleConditionMgr:Check(pBattle, pCreature, pBuffProp.m_conditions) then
						pCreature:AddBuff(newBuff, pBattle);
					end
				else
					pCreature:AddBuff(newBuff, pBattle);
				end
				pCreature.blackHoleId = pSelf:GetId();
			end
		end
	end
end

---------------------------------------  BattleEffectDamageTwo  -----------------------------------------
-- 造成伤害（带类型）  
-----------------------------------------------------------------------------------------------------
BattleEffectDamageTwo = vclass("BattleEffectDamageTwo", BattleBaseEffect);

function BattleEffectDamageTwo:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectDamageTwo:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local fValue = pSelf:GetAttackDamage():GetValue() * pEffect.params[1] / 100.0;

	local attackDamage = DamageProp:new();
	attackDamage:copyWithProp(pSelf:GetAttackDamage());
	attackDamage:SetValue(fValue);
	attackDamage:SetDamageRace(pEffect.params[2]);
	attackDamage:SetDamageType(pEffect.params[3]);

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			-- 伤害
			local damage = pCreature:DoDamage(pSelf, attackDamage);
			-- 添加事件
			-- cclog("****************** BattleEffectDamageTwo:DoEffect");
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pCreature, damage, pSelf);
		end
	end
end

---------------------------------------  BattleEffectRevive  -----------------------------------------
-- 复活  
-----------------------------------------------------------------------------------------------------
BattleEffectRevive = vclass("BattleEffectRevive", BattleBaseEffect);

function BattleEffectRevive:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectRevive:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature then
			local hp = pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * pEffect.params[1] / 100.0;
			hp = math.modf(hp);
			pCreature:DoModifyHP(hp, pSelf);
			pCreature:SetValid(true);
		end
	end
end


---------------------------------------  BattleEffectBullet  -----------------------------------------
-- 创造子弹
-----------------------------------------------------------------------------------------------------
BattleEffectBullet = vclass("BattleEffectBullet", BattleBaseEffect);

function BattleEffectBullet:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectBullet:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	if #targets == 0 then
		return;
	end

	local pBulletProp = gBattleResource:GetBulletProp(pEffect.params[1]);
	if not pBulletProp then
		return;
	end

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			-- 子弹初始化
			local pBullet = BattleUnitFactory:GetNewBullet(pBulletProp.type, pBulletProp);
			if pBullet then
				-- 子弹加入战场
				pBullet:Create(pBattle:GetNewBulletId(), pBattle:GetCurrentTime(), pBattle, pSelf, pCreature);
				pBattle:ActiveBullet(pBullet);

				-- 添加事件
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK, pBullet, pSelf, pCreature);
			end
		end		
	end
end

---------------------------------------  BattleEffectRangeDamage  -----------------------------------------
-- 均摊伤害  
-----------------------------------------------------------------------------------------------------
BattleEffectRangeDamage = vclass("BattleEffectRangeDamage", BattleBaseEffect);

function BattleEffectRangeDamage:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectRangeDamage:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	if #targets == 0 or #pEffect.params < 2 then
		return;
	end
	-- 平均伤害
	local fValue = 0;
	if pEffect.params[1] == 1 then
		fValue = (pSelf:GetAttackDamage():GetValue() * pEffect.params[2] / 100.0) / #targets;
	else
		fValue = pEffect.params[2] / #targets;
	end

	local attackDamage = DamageProp:new();
	attackDamage:copyWithProp(pSelf:GetAttackDamage());
	attackDamage:SetValue(fValue);

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			-- 伤害
			local damage = pCreature:DoDamage(pSelf, attackDamage);
			-- 添加事件
			-- cclog("****************** BattleEffectRangeDamage:DoEffect");
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pCreature, damage, pSelf);
		end
	end
end

---------------------------------------  BattleEffectMove  -----------------------------------------
-- 移动 太岁顶退1格  
-----------------------------------------------------------------------------------------------------
BattleEffectMove = vclass("BattleEffectMove", BattleBaseEffect);

function BattleEffectMove:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectMove:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local pBuffProp = gBattleResource:GetBuffProp(pEffect.params[2]);

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			pCreature:Move(pEffect.params[1] * gBattleView.msec_unit);
			if pCreature:GetPos() <= 0 then
				pCreature:SetPos(1);
			end
			pCreature:SetTarget(0);

			-- 添加buff
			if pBuffProp then
				local newBuff = BattleBuff:new(pBuffProp);
				newBuff.m_buffData.time = pEffect.params[3];
				
				if pBuffProp.m_buffData.event == EBattleBuffEvent.BATTLE_BUFF_EVENT_ADD then
					if gBattleConditionMgr:Check(pBattle, pCreature, pBuffProp.m_conditions) then
						pCreature:AddBuff(newBuff, pBattle);
					end
				else
					pCreature:AddBuff(newBuff, pBattle);
				end
			end
		end
	end
end

---------------------------------------  BattleEffectDelBuff  -----------------------------------------
-- 清除buff  
-----------------------------------------------------------------------------------------------------
BattleEffectDelBuff = vclass("BattleEffectDelBuff", BattleBaseEffect);

function BattleEffectDelBuff:initialize( )
end

-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectDelBuff:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			pCreature:DelBuff(pEffect.params[1]);
		end
	end
end

---------------------------------------  BattleEffectModifyHpMax  -----------------------------------
-- 修改血量上限
-----------------------------------------------------------------------------------------------------
BattleEffectModifyHpMax = vclass("BattleEffectModifyHpMax", BattleBaseEffect);

function BattleEffectModifyHpMax:initialize( )
end
-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectModifyHpMax:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local op = pEffect.params[1];
	local value = pEffect.params[2];

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			local fModifyValue = 0.0;
			if op == 1 then
				fModifyValue = value;
			elseif op == 2 then
				fModifyValue = pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * value / 100 + MODIFY_FLOAT;
			end
			fModifyValue = math.modf(fModifyValue);
			pCreature:DoModifyHpMax(fModifyValue);
			if fModifyValue > 0 then
				pCreature:DoModifyHP(fModifyValue, pSelf);
			end
		end
	end
end
-- @Param CBattleUnit*, BattleEffectProp*, CBattleBuff*
-- @Return 
function BattleEffectModifyHpMax:DoClose( pSelf, pEffect, pBuff )
	local pCreature = pSelf;
	local op = pEffect.params[1];
	local value = pEffect.params[2];

	local fModifyValue = 0.0;
	if op == 1 then
		fModifyValue = value;
	elseif op == 2 then
		fModifyValue = pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * value / 100 + MODIFY_FLOAT;
	end
	fModifyValue = math.modf(fModifyValue);
	pCreature:DoModifyHpMax(-fModifyValue);
end

---------------------------------------  BattleEffectDamageThree  -----------------------------------
-- 造成伤害（指定种族） 
-----------------------------------------------------------------------------------------------------
BattleEffectDamageThree = vclass("BattleEffectDamageThree", BattleBaseEffect);

function BattleEffectDamageThree:initialize( )
end
-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectDamageThree:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	local value = pEffect.params[1];
	local bSkipRace = false;
	if pEffect.params[2] == 2 then
		bSkipRace = true;
	end
	local vecRace = {};
	for i = 3, #pEffect.params do
		table.insert(vecRace, pEffect.params[i]);
	end
	
	local attackDamage = DamageProp:new();
	attackDamage:copyWithProp(pSelf:GetAttackDamage());

	for i,v in ipairs(targets) do
		local pCreature = v;
		if pCreature and pCreature:GetValid() then
			if bSkipRace then
				attackDamage:SetX(attackDamage:GetX() + value / 100.0);
			else
				attackDamage:SetX(pSelf:GetAttackDamage():GetX());
			end

			for key, value in pairs(vecRace) do
				if value == pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) then
					if bSkipRace then
						attackDamage:SetX(pSelf:GetAttackDamage():GetX());
					else
						attackDamage:SetX(attackDamage:GetX() + value / 100.0);
					end
					break;
				end
			end
			
			local damage = pCreature:DoDamage(pSelf, attackDamage);
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pCreature, damage, pSelf);
		end
	end
end

---------------------------------------  BattleEffectSuicide  -----------------------------------
-- 自杀
-----------------------------------------------------------------------------------------------------
BattleEffectSuicide = vclass("BattleEffectSuicide", BattleBaseEffect);
function BattleEffectSuicide:initialize( )
end
-- @Param CBattleUnit*, vector<CBattleCreature>, BattleEffectProp*, CBattleBuff*, CBattle*
-- @Return 
function BattleEffectSuicide:DoEffect( pSelf, targets, pEffect, pBuff, pBattle )
	for i,v in ipairs(targets) do
		local pCreature = v;
		pCreature:DoDead( EDeadWay.DEAD_SUICIDE );
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_SUICIDE, pCreature);
	end
end