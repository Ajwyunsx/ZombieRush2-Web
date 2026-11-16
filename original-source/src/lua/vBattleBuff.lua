--vBattleBuff.lua
require "vBattleResource"

---------------------------------------  BattleBuff  ---------------------------------------
local function clearCreatureList( creatures )
	if #creatures > 0 then
		for i = 1,#creatures do
			table.remove(creatures,1);
		end
	end
end

local local_bit = gBit;

BattleBuff = vclass("BattleBuff", BattleBuffProp);

function BattleBuff:initialize( prop )
	-- super create
	BattleBuffProp.initialize(self, prop)

	self.m_bVaild = false;					-- bool
	self.m_nOverlap = 0;					-- int
	self.m_nBeginTime = 0;					-- int
	self.m_nLastTime = 0;					-- int
	self.m_pUnit = nil;						-- BattleUnit*
end

function BattleBuff:Relase( )
	if self.m_pUnit ~= nil then
		if self.m_buffData.event == EBattleBuffEvent.BATTLE_BUFF_EVENT_DEL or self.m_buffData.event == EBattleBuffEvent.BATTLE_BUFF_EVENT_ADD then
			for i,v in ipairs(self.m_effects) do
				gBattleEffectMgr:GetEffect(v.expressionId):DoClose(self.m_pUnit, v, self);
			end
		end			
	end
end

-- @Param CBattleUnit*, int
-- @Return bool
function BattleBuff:Create( pUnit, nBeginTime )
	self.m_bVaild = true;
	self.m_pUnit = pUnit;
	self.m_nBeginTime = nBeginTime;
	self.m_nLastTime = nBeginTime;

	return true;
end

-- @Param 
-- @Return int
function BattleBuff:GetBeginTime( )
	return self.m_nBeginTime;
end

-- @Param int
-- @Return void
function BattleBuff:SetBeginTime( val )
	self.m_nBeginTime = val;
end

-- @Param 
-- @Return int
function BattleBuff:GetOverlap( )
	return self.m_nOverlap;
end

-- @Param int
-- @Return void
function BattleBuff:SetOverlap( val )
	self.m_nOverlap = val;
	if self.m_nOverlap > self.m_buffData.overlap_max then
		self.m_nOverlap = self.m_buffData.overlap_max;
	end
end

-- @Param 
-- @Return bool
function BattleBuff:GetValid( )
	return self.m_bVaild;
end

-- @Param bool
-- @Return void
function BattleBuff:SetValid( val )
	self.m_bVaild = val;
end

-- @Param BattleCreature
-- @Return 
function BattleBuff:SetCreature( val )
	self.m_pCreature = val
end

-- @Param EBattleBuffEvent, Battle*
-- @Return void
function BattleBuff:DoBuff( event, pBattle )
	if self.m_buffData.event ~= event then return; end

	local pTarget = pBattle:GetCreature(not self.m_pUnit:GetIsAttack(), self.m_pUnit:GetTarget());

	-- 释放效果
	for i,v in ipairs(self.m_effects) do
		local position = PositionData:new();
		position.road = self.m_pUnit:GetRoad();
		position.pos = self.m_pUnit:GetPos();

		local targets = {};
		self:GetEffectTargets(self.m_pUnit, pTarget, position, pBattle, v, targets);
		gBattleEffectMgr:GetEffect(v.expressionId):DoEffect(self.m_pUnit, targets, v, self, pBattle);
	end

	-- 消失类型
	if local_bit:_and(self.m_buffData.remove_type, EBattleBuffClearType.BATTLE_BUFF_REMOVE_TIMES) ~= 0 then
		self.m_buffData.overlap_value = self.m_buffData.overlap_value - 1;
		if self.m_buffData.overlap_value <= 0 then
			self.m_bVaild = false;
		end
	end
end

-- @Param CBattleUnit*, CBattleUnit*, PositionData&, CBattle*, BattleEffectProp&
-- @Return void
function BattleBuff:GetEffectTargets( pSelf, pTarget, position, pBattle, effect, targets )
	local bAttack = false;
	local pTmp = nil;
	if not pSelf then
		cclog("* BattleBuff:DoBuff Warning, pSelf = nil");
		return;
	end
	
	-- cclog("********** effect.target = "..effect.target);
	-- 己方
	if effect.target == 1 then
		pTmp = pSelf;
		if not pTmp:isInstanceOf(BattleCreature) then 
			return;
		end
		bAttack = pSelf:GetIsAttack();
		position.road = pSelf:GetRoad();
		position.pos = pSelf:GetPos();

	-- 敌方
	elseif effect.target == 2 then
		bAttack = not pSelf:GetIsAttack();
		if pTarget then
			pTmp = pTarget;
			if not pTmp:isInstanceOf(BattleCreature) then 
				return;
			end

			-- bAttack = pTarget:GetIsAttack();
			position.road = pTarget:GetRoad();
			position.pos = pTarget:GetPos();
		end
	end
	
	-- cclog("********** effect.target_range = "..effect.target_range);
	-- cclog("********** effect.magic_valid = "..effect.magic_valid);
	if effect.target_range == 1 then
		-- 一个目标
		if pTmp and (effect.magic_valid == 0 or pTmp:GetStatus(ECreatureStatus.CREATURE_STATUS_MAGIC_INV) == 0) then
			table.insert(targets, pTmp);
		end
	elseif effect.target_range == 2 then
		-- 一大格范围
		local diff = gBattleView.cellNum / 2;
		pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, -diff, diff, effect.magic_valid, targets);
	elseif effect.target_range == 3 then
		-- 九宫格范围
		local diff = math.floor((gBattleView.cellNum * 8) / 10 + MODIFY_FLOAT);  
		pBattle:GetGround():GetRangeCreatures(bAttack, position, 1, -diff, diff, effect.magic_valid, targets);
	elseif effect.target_range == 4 then
		-- 前后一大格  
		local diff = gBattleView.cellNum;
		pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, -diff, diff, effect.magic_valid, targets);
	elseif effect.target_range == 5 then
		-- 从当前位置向小端
		position.road = pSelf:GetRoad();
		position.pos = pSelf:GetPos();  
		local diff = gBattleView.cellNum * 10;

		if pSelf:GetIsAttack() then
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, -diff, 0, effect.magic_valid, targets);
		else
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, 0, diff, effect.magic_valid, targets);
		end
	elseif effect.target_range == 6 then
		-- 从当前位置向大端
		position.road = pSelf:GetRoad();
		position.pos = pSelf:GetPos();  
		local diff = gBattleView.cellNum * 10;

		if pSelf:GetIsAttack() then
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, -diff, 0, effect.magic_valid, targets);
		else
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, 0, diff, effect.magic_valid, targets);
		end

		if #targets > 1 then
			local rand = pBattle:GetRandom(1, #targets);
			local pCreature = targets[rand];
			clearCreatureList(targets);
			table.insert(targets, pCreature);
		end
	elseif effect.target_range == 7 then
		-- 查询从当前位置向敌人方向一格的敌人
		position.road = pSelf:GetRoad();
		position.pos = pSelf:GetPos();  
		local diff = gBattleView.cellNum;
		
		if pSelf:GetIsAttack() then
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, -diff, 0, effect.magic_valid, targets);
		else
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, 0, diff, effect.magic_valid, targets);
		end
	elseif effect.target_range == 8 then
		-- 从当前位置向身前方向查询二格内的所有生物
		position.road = pSelf:GetRoad();
		position.pos = pSelf:GetPos();  
		local diff = gBattleView.cellNum * 2;

		if pSelf:GetIsAttack() then
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, -diff, 0, effect.magic_valid, targets);
		else
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, 0, diff, effect.magic_valid, targets);
		end
	elseif effect.target_range == 9 then
		-- 自身上的生物
		position.road = pSelf:GetRoad();
		position.pos = pSelf:GetPos();  
		local diff = pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);

		if pSelf:GetIsAttack() then
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, 0, diff, effect.magic_valid, targets);
		else
			pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, -diff, 0, effect.magic_valid, targets);
		end
	elseif effect.target_range == 10 then
		position.road = pSelf:GetRoad();
		position.pos = pSelf:GetPos();  
		local diff = gBattleView.cellNum * 10;
		pBattle:GetGround():GetRangeCreatures(bAttack, position, 0, -diff, diff, effect.magic_valid, targets);
		if #targets > 1 then
			local rand = pBattle:GetRandom(1, #targets);
			local pCreature = targets[rand];
			clearCreatureList(targets);
			table.insert(targets, pCreature);
		end
	end

	-- cclog("*** #targets = "..#targets);
	-- cclog("*** effect.target_num = "..effect.target_num);
	if #targets == 0 then
		return;
	end

	local targetsSize = #targets;
	local i = targetsSize;
	while true do
		if i > effect.target_num then
			i = i - 1;
			table.remove(targets, #targets);
		else
			break;
		end
	end
end

-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleBuff:Update( time,  pCreature,  pBattle )
	-- 先执行效果
	while true do
		-- cd
		-- cclog("********** time = %f,  self.m_nLastTime = %f,  self.m_buffData.cd = %f", time, self.m_nLastTime, self.m_buffData.cd);
		if time - self.m_nLastTime < self.m_buffData.cd then
			break;
		end
		self.m_nLastTime = self.m_nLastTime + self.m_buffData.cd;

		if not gBattleConditionMgr:Check(pBattle, pCreature, self.m_conditions) then
			-- cclog("***** Check false");
			break;
		end

		self:DoBuff(EBattleBuffEvent.BATTLE_BUFF_EVENT_UPDATE, pBattle);
		break;
	end

	-- 清除buff
	-- cclog("**** remove_type = %f,  remove time = %f", self.m_buffData.remove_type, EBattleBuffClearType.BATTLE_BUFF_REMOVE_TIME)
	if local_bit:_and(self.m_buffData.remove_type, EBattleBuffClearType.BATTLE_BUFF_REMOVE_TIME) ~= 0 then
		-- buff 持续时间
		-- cclog("*** id = %d, time = %f,  self.m_nBeginTime = %f,  self.m_buffData.time = %f", pCreature:GetId(), time, self.m_nBeginTime, self.m_buffData.time);
		if (time - self.m_nBeginTime) >= self.m_buffData.time then
			self.m_bVaild = false;
			return;
		end
	end
end

-- @Param const BattleBuffProp*, CBattleUnit*, CBattleCreature*, PositionData&, CBattle*
-- @Return 
function BattleBuff:DoSkill( pSkill, pSelf, pTarget, position, pBattle )
	-- 释放效果
	for i,v in ipairs(pSkill.m_effects) do
		local targets = {};
		self:GetEffectTargets(pSelf, pTarget, position, pBattle, v, targets);
		-- cclog("****  v.expressionId = %d", v.expressionId);
		-- for i,v in ipairs(targets) do
		-- 	cclog("*** v.id = "..v:GetId());
		-- end
		gBattleEffectMgr:GetEffect(v.expressionId):DoEffect(pSelf, targets, v, nil, pBattle);
	end
end
