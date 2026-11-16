--vBattleAI.lua

-- @Param CBattleCreature*, CBattleCreature*
-- @Return bool
local function Block( pAttack, pDefend)
	-- cclog("***** Block,  atk pos = %f, def pos = %f, atk Lpos = %f, def Lpos = %f ", pAttack:GetPos(), pDefend:GetPos(), pAttack:GetLastPos(), pDefend:GetPos());
	if pAttack:GetPos() == pDefend:GetPos() then
		return true;
	end

	if pAttack:GetPos() < pDefend:GetPos() and pAttack:GetLastPos() > pDefend:GetPos() then
		return true;
	end

	if pAttack:GetAttr(ECreatureAttr.CREATURE_ATTR_BLOCK) == 1 then
		if pAttack:GetPos() < pDefend:GetPos() and pAttack:GetPos() > pDefend:GetPos() - pDefend:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN) then
			return true;
		end
	end

	return false;
end

-- 是否被击中  
-- @Param int, int, CBattleCreature*
-- @Return bool
local function Hit( nBeginPos, nEndPos, pCreature)
	-- 开始位置 要小于 结束位置  
	assert(nBeginPos <= nEndPos, "Hit Error");
	local head = pCreature:GetPos();
	local tail = 0;

	if pCreature:GetIsAttack() then
		tail = head + pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
		-- cclog("*****   nBeginPos = %f, nEndPos = %f", nBeginPos, nEndPos);
		-- cclog("*****   head = %f, tail = %f", head, tail);
		if nBeginPos <= head and head <= nEndPos then
			return true;
		end

		if nBeginPos <= tail and tail <= nEndPos then
			return true;
		end

		if nBeginPos <= head and tail <= nEndPos then
			return true;
		end

		if head < nBeginPos and tail > nEndPos then
			return true;
		end
	else
		tail = head - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
		if nBeginPos <= head and head <= nEndPos then
			return true;
		end

		if nBeginPos <= tail and tail <= nEndPos then
			return true;
		end

		if nBeginPos <= tail and head <= nEndPos then
			return true;
		end

		if tail < nBeginPos and head > nEndPos then
			return true;
		end
	end

	return false;
end
-- 是否被击中  
-- @Param int, int, CBattleCreature*
-- @Return bool
local function Hit3( nBeginPos, nEndPos, pCreature)
	-- 开始位置 要小于 结束位置  
	assert(nBeginPos <= nEndPos, "Hit Error");
	local head = pCreature:GetPos();
	local tail = 0;

	if pCreature:GetIsAttack() then
		tail = head + pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN)/2;
		if nBeginPos <= tail and tail <= nEndPos then
			return true;
		end
	else
		tail = head - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN)/2;
		if nBeginPos <= tail and tail <= nEndPos then
			return true;
		end
	end

	return false;
end

-- 能否被攻击  
-- @Param CBattleCreature*
-- @Return bool
local function CanAttacked( pCreature )
	if pCreature then
		if pCreature:GetValid() and pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_STEALTH) == 0 then
			return true;
		end
	end

	return false;
end
-- 能否可攻击  
-- @Param CBattleCreature*
-- @Param CBattleCreature*
-- @Return bool
local function CanAttack( pAttack, pTarget )
	if (not pAttack) or (not pTarget) then
		return false;
	end
	if not CanAttacked(pTarget) then
		return false;
	end
	if pAttack:GetRoad() ~= pTarget:GetRoad() then
		return false;
	end
	local nAttackPos = pAttack:GetPos();
	local nTargetPos = pTarget:GetPos();
	local distance;
	if (pAttack:GetIsAttack()) then
		distance = nAttackPos - nTargetPos;
	else
		distance = nTargetPos - nAttackPos;
	end

	-- 身后和超出范围的怪  
	if distance < 0 or distance > pAttack:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
		return false;
	end

	return true;
end
-- 生物距离排序  
local function DistanceSort( targets, pSelfPos )
	if targets then
		table.sort(targets,
			function(a,b)
				local distance1 = 0;
				local distance2 = 0;
				if a:GetIsAttack() then
					distance1 = a:GetPos() - pSelfPos;
					distance2 = b:GetPos() - pSelfPos;
				else
					distance1 = pSelfPos - a:GetPos();
					distance2 = pSelfPos - b:GetPos();
				end
				if distance1 < distance2 then
					return true;
				elseif distance1 == distance2 then
					return a:GetId() > b:GetId();
				else
					return false;
				end
			end);
	end
end
local function DistanceSortEx( targets, pSelfPos )
	if targets then
		table.sort(targets,
			function(a,b)
				local distance1 = 0;
				local distance2 = 0;
				if a:GetIsAttack() then
					distance1 = a:GetPos() - pSelfPos;
					distance2 = b:GetPos() - pSelfPos;
				else
					distance1 = pSelfPos - a:GetPos();
					distance2 = pSelfPos - b:GetPos();
				end
				if distance1 < distance2 then
					return true;
				elseif distance1 == distance2 then
					if a:GetId() < b:GetId() then
						return true;
					else
						return false;
					end
				else
					return false;
				end
			end);
	end
end

local local_bit = gBit;

---------------------------------------  BattleAIMgr  ---------------------------------------

BattleAIMgr = vclass("BattleAIMgr");

function BattleAIMgr:initialize( )
	self.m_attackAIs = {};				-- map<int, CBattleAI*>
	self.m_moveAIs = {};				-- map<int, CBattleAI*>
	self.m_skillAIs = {};				-- map<int, CBattleAI*>
end

-- @Param 
-- @Return bool
function BattleAIMgr:Create( )
	-- 攻击AI
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_LINE] = BattleAttackAILine:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_BACK] = BattleAttackAIBack:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_SPIKEWEED] = BattleAttackAISpikeweed:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_MELEE] = BattleAttackAIMelee:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_THREE] = BattleAttackAIThree:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_MELEE_MULTI] = BattleAttackAIMeleeMutli:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_SPIKEWEED_2] = BattleAttackAISpikeweedTwo:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_THIEF] = BattleAttackAIThief:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_RESOURCE] = BattleAttackAIResource:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_BACK_DOUBLE] = BattleAttackAIBackDouble:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_THIEF_BLUE] = BattleAttackAIThiefBlue:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_MELEE_BLOCK] = BattleAttackAIMeleeBlock:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_RANGE_MULTI] = BattleAttackAIRangeMutli:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_PRE_RACE] = BattleAttackAIPreRace:new();
	self.m_attackAIs[EBattleAttackAI.AI_ATTACK_PRE_RACE_DOUBLE] = BattleAttackAIPreRaceDouble:new();
	-- 移动AI
	self.m_moveAIs[EBattleMoveAI.AI_MOVE_LINE] = BattleMoveAILine:new();
	self.m_moveAIs[EBattleMoveAI.AI_MOVE_JUMP] = BattleMoveAIJump:new();

	-- 技能AI
	self.m_skillAIs[EBattleSkillAI.AI_SKILL_TIME] = BattleSkillAI:new();
	self.m_skillAIs[EBattleSkillAI.AI_SKILL_TARGET] = BattleSkillAITarget:new();
	self.m_skillAIs[EBattleSkillAI.AI_SKILL_TARGET_BITE] = BattleSkillAITargetBite:new();
	self.m_skillAIs[EBattleSkillAI.AI_SKILL_TARGET_BODY] = BattleSkillAITargetBody:new();
	self.m_skillAIs[EBattleSkillAI.AI_SKILL_TARGET_HURT] = BattleSkillAITargetHurt:new();
	self.m_skillAIs[EBattleSkillAI.AI_SKILL_TARGET_RACE] = BattleSkillAITargetRace:new();
	self.m_skillAIs[EBattleSkillAI.AI_SKILL_TARGET_BODY_RACE] = BattleSkillAITargetBodyRace:new();
	self.m_skillAIs[EBattleSkillAI.AI_SKILL_TARGET_PRE_RACE] = BattleSkillAITargetPreRace:new();

	return true;
end

-- @Param 
-- @Return 
function BattleAIMgr:Close( )
	self.m_attackAIs = {};
	self.m_moveAIs = {};
	self.m_skillAIs = {};
end

-- @Param int
-- @Return BattleAI*
function BattleAIMgr:GetAttackAI( id )
	return self.m_attackAIs[id];
end

-- @Param int
-- @Return BattleAI*
function BattleAIMgr:GetMoveAI( id )
	return self.m_moveAIs[id];
end

-- @Param int
-- @Return BattleAI*
function BattleAIMgr:GetSkillAI( id )
	return self.m_skillAIs[id];
end

---------------------------------------  BattleAI  ---------------------------------------

BattleAI = vclass("BattleAI");

function BattleAI:initialize( )
end

-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleAI:Update( time,  pCreature,  pBattle )
	-- body
end

----------------------------------------------------------------           移动AI          -----------------------------------------------------------------
---------------------------------------  BattleMoveAILine  ---------------------------------------

BattleMoveAILine = vclass("BattleMoveAILine", BattleAI);

function BattleMoveAILine:initialize( )
end

-- 直线运动  
-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleMoveAILine:Update( time,  pCreature,  pBattle )
	-- 速度为0，不移动
	local speed = pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED);
	if speed == 0 then
		return;
	end
	
	-- 不能移动
	if pCreature:GetAction() ~= ECreatureAction.ACTION_MOVE then
		return;
	end

	if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_PRE) ~= 0 or pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_POST) ~= 0 then
		return;
	end

	-- -- 被定身
	-- if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) == 1 then
	-- 	return;
	-- end

	-- 能移动肯定不被阻碍
	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_BLOCK, 0);

	-- 移动距离
	local distance = pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED) * pBattle:GetUnitTime();
	-- cclog("*** speed = %f", pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED));
	-- if pCreature:GetId() == 2 then
		-- cclog("**** id = %d, road = %d, pos = %d, rswPos = %f, distance = %f, speed = %f, time = %f", pCreature:GetId(), pCreature:GetRoad(), pCreature:GetPos(), pCreature.m_pos, distance, pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED), pBattle:GetUnitTime());
	-- end
	pCreature:Move(-distance);
	-- if pCreature:GetId() == 2 then
		-- cclog("**** id = %d after move pos = %d", pCreature:GetId(), pCreature:GetPos());
	-- end

	-- 阻挡判断
	local road = pCreature:GetRoad();
	local obj = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, obj);
	for k,v in pairsByKeys(obj) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 移动类型过滤
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue
			else
				-- 阻碍判定
				if Block(pCreature, pEnemy) then
					-- 如果被阻碍 怪物位置定在植物的位置
					pCreature:SetPos(pEnemy:GetPos());
					-- 阻碍，不能移动
					pCreature:SetAction(ECreatureAction.ACTION_ATTACK);
					pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_BLOCK, 1);
					-- 添加事件
					gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_BLOCK, pCreature, pEnemy);
					return;
				end
			end
		end
	end

	if pCreature:GetPos() > 0 then
		return;
	end

	if gBattleView then
		gBattleView:moveEndAndSetBreakRoad(pCreature:GetRoad());
	end

	-- 走到头了，就处于无敌状态
	pCreature:DoEnd();

	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_MOVE_END, pCreature);
end

---------------------------------------  BattleMoveAIJump  ---------------------------------------

BattleMoveAIJump = vclass("BattleMoveAIJump", BattleAI);

function BattleMoveAIJump:initialize( )
end

-- 跳高运动  
-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleMoveAIJump:Update( time,  pCreature,  pBattle )

	-- 速度为0，不移动
	local speed = pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED);
	if speed == 0 then
		return;
	end
	
	-- 不能移动
	if pCreature:GetAction() ~= ECreatureAction.ACTION_MOVE then
		return;
	end

	-- -- 被定身
	-- if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) == 1 then
	-- 	return;
	-- end

	-- 能移动肯定不被阻碍
	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_BLOCK, 0);

	-- 移动距离
	local distance = 0;
	if pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE) ~= EMoveType.MOVE_TYPE_LADDER then
		distance = pCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED) * pBattle:GetUnitTime();
		pCreature:Move(-distance);
	else
		local pBaseProp = gBattleResource:GetMonsterProp(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ID));
		distance = pBaseProp:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED) * pBattle:GetUnitTime();
		pCreature:Move(-distance);
		
		if pCreature:GetPos() <= (pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_JUMP) - gBattleView.cellNum) then
			pCreature:SetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE, EMoveType.MOVE_TYPE_GROUND);
			pCreature:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE, EMoveType.MOVE_TYPE_GROUND);
		end
	end

	-- 阻挡判断
	local road = pCreature:GetRoad();
	local obj = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, obj);
	for k,v in pairsByKeys(obj) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 移动类型过滤
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue
			else
				-- 阻碍判定
				if Block(pCreature, pEnemy) then
					if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_JUMP) ~= 0 then
						-- 如果被阻碍 怪物位置定在植物的位置
						pCreature:SetPos(pEnemy:GetPos());
						-- 阻碍，不能移动
						pCreature:SetAction(ECreatureAction.ACTION_ATTACK);
						pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_BLOCK, 1);
						-- 添加事件
						gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_BLOCK, pCreature, pEnemy);
					else
						-- 跳高
						pCreature:SetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE, EMoveType.MOVE_TYPE_LADDER);
						pCreature:SetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE, EMoveType.MOVE_TYPE_LADDER);
						pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_JUMP, pCreature:GetPos());
						-- 添加事件
						gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_JUMP, pCreature);
					end
					return;
				end
			end
		end
	end

	if pCreature:GetPos() > 0 then
		return;
	end

	-- 走到头了，就处于无敌状态
	pCreature:DoEnd();

	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_MOVE_END, pCreature);
end
-------------------------------------------------------------           移动AI  END          --------------------------------------------------------------


----------------------------------------------------------------           攻击AI          -----------------------------------------------------------------
---------------------------------------  BattleAttackAI  ---------------------------------------

BattleAttackAI = vclass("BattleAttackAI", BattleAI);

function BattleAttackAI:initialize( )
end
	
-- 更新
-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleAttackAI:Update( time,  pCreature,  pBattle )
	-- 选择攻击目标
	if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_PRE) == 0 and pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_POST) == 0 then
		if self:DoAttack(time, pCreature, pBattle) ~= 0 then
			return;
		end
	end

	-- 攻击前摇状态
	if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_PRE) ~= 0 then
		if self:DoPre(time, pCreature, pBattle) ~= 0 then
			return;
		end
	end

	-- 攻击后摇状态
	if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_POST) ~= 0 then
		if self:DoPost(time, pCreature, pBattle) ~= 0 then
			return;
		end
	end
end

-- 攻击判断  
-- @Param int ,BattleCreature*, Battle*
-- @Return int
function BattleAttackAI:DoAttack( time,  pCreature,  pBattle )
	-- 检查自己位置是否合法
	if not pBattle:CheckPostion(pCreature:GetRoad(), pCreature:GetPos()) then
		return -1;
	end

	-- 判断攻击速率  
	-- 目前先不做一个时间间隔发射多发子弹  
	local speed = pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED);
	if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME) ~= 0 then
		if (time - pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME)) < speed then
			return -1;
		end
	end

	-- 没有找到攻击目标
	local pSuitableEnemy = self:GetEnemy(pCreature:GetRoad(), pCreature:GetPos(), pCreature, pBattle);
	if not pSuitableEnemy then
		pCreature:SetAction(ECreatureAction.ACTION_MOVE);
		return -1;
	end	

	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME, time);
	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_PRE, pSuitableEnemy:GetId());
	pCreature:SetAction(ECreatureAction.ACTION_ATTACK);

	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK_PRE, pCreature, pSuitableEnemy);

	return 0;
end

-- 前摇处理
-- @Param int ,BattleCreature*, Battle*
-- @Return int
function BattleAttackAI:DoPre( time,  pCreature,  pBattle )
	-- 前摇时间
	local diff = time - pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME);
	if diff < pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_PRE) then
		return -1;
	end

	-- 目标
	local pEnemy = pBattle:GetCreature(not pCreature:GetIsAttack(), pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_PRE));

	-- 重置攻击状态
	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_PRE, 0);
	if self:Attack(pCreature, pEnemy, pBattle) ~= 0 then
		return -1;
	end

	-- 攻击后摇
	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_POST, time);

	return 0;
end

-- 后摇处理  
-- @Param int ,BattleCreature*, Battle*
-- @Return int
function BattleAttackAI:DoPost( time,  pCreature,  pBattle )
	-- 后摇时间
	local diff = time - pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_POST);
	if diff < pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_POST) then
		return -1;
	end

	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_POST, 0);

	return 0;
end

-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAI:Attack( pSelf, pEnemy, pBattle )
	-- 制造子弹
	if not pSelf.m_Bullet then
		return -1;
	end
	-- 子弹初始化
	local pBullet = BattleUnitFactory:GetNewBullet(pSelf.m_Bullet.type, pSelf.m_Bullet);
	if not pBullet then
		return -1;
	end

	-- 攻击动作
	pSelf:DoAttack();

	-- 子弹加入战场
	pBullet:Create(pBattle:GetNewBulletId(), pBattle:GetCurrentTime(), pBattle, pSelf, pEnemy);
	pBattle:ActiveBullet(pBullet);

	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK, pBullet, pSelf, pEnemy);

	return 0;
end

-- 选择合适的目标 
-- @Param int ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleAttackAI:GetEnemy( road, pos, pCreature, pBattle )
	-- 获取敌方目标  
	local nMinDistance = -1;
	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue
			else
				-- 范围判定  
				local nEnemyPos = pEnemy:GetPos();
				local distance = 0;
				if pCreature:GetIsAttack() then
					distance = pos - nEnemyPos;
				else
					distance = nEnemyPos - pos;
				end
				-- 身后和超出范围的怪 过滤掉  
				if distance < 0 or distance > pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
					-- continue
				else
					if nMinDistance == -1 or nMinDistance > distance then
						pSuitableEnemy = pEnemy;
						nMinDistance = distance;
					end
				end
			end
		end
	end
	return pSuitableEnemy;
end

---------------------------------------  BattleAttackAILine  ---------------------------------------
-- 直线单次攻击  
BattleAttackAILine = vclass("BattleAttackAILine", BattleAttackAI);

function BattleAttackAILine:initialize( )
end

---------------------------------------  BattleAttackAIThree  ---------------------------------------
-- 直线远程三路攻击
BattleAttackAIThree = vclass("BattleAttackAIThree", BattleAttackAI);

function BattleAttackAIThree:initialize( )
end

-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAIThree:Attack( pSelf, pEnemy, pBattle )
	if not pSelf.m_Bullet then
		return -1;
	end

	-- 攻击动作
	pSelf:DoAttack();

	for i=0,2 do
		local road = pSelf:GetRoad() + 1 - i;
		local pos = pSelf:GetPos();
		-- if pBattle:CheckPostion(road, pos) then
			local pBullet = BattleUnitFactory:GetNewBullet(pSelf.m_Bullet.type, pSelf.m_Bullet);
			if not pBullet then
				return;
			end
			pBullet:Create(pBattle:GetNewBulletId(), pBattle:GetCurrentTime(), pBattle, pSelf);
			pBullet:SetRoad(road);
			pBattle:ActiveBullet(pBullet);
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK, pBullet, pSelf);
		-- end
	end

	return 0;
end

-- 攻击判断  
-- @Param int ,BattleCreature*, Battle*
-- @Return int
function BattleAttackAIThree:DoAttack( time,  pCreature,  pBattle )
	-- 检查自己位置是否合法
	if not pBattle:CheckPostion(pCreature:GetRoad(), pCreature:GetPos()) then
		return -1;
	end

	-- 判断攻击速率  
	-- 目前先不做一个时间间隔发射多发子弹
	local speed = pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED);
	if time - pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME) < speed then
		return -1;
	end

	local pEnemy = nil;
	for i=0,2 do
		local road = pCreature:GetRoad() + 1 - i;
		local pos = pCreature:GetPos();
		if pBattle:CheckPostion(road, pos) then
			pEnemy = self:GetEnemy(road, pos, pCreature, pBattle);
			if pEnemy then
				break;
			end
		end
	end

	if not pEnemy then
		pCreature:SetAction(ECreatureAction.ACTION_MOVE);
		return -1;
	end

	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME, time);
	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_PRE, pEnemy:GetId());
	pCreature:SetAction(ECreatureAction.ACTION_ATTACK);

	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK_PRE, pCreature, pEnemy);

	return 0;
end

---------------------------------------  BattleAttackAIBack  ---------------------------------------
-- 先攻击后排
BattleAttackAIBack = vclass("BattleAttackAIBack", BattleAttackAI);

function BattleAttackAIBack:initialize( )
end

-- 选择合适的目标 
-- @Param int ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleAttackAIBack:GetEnemy( road, pos, pCreature, pBattle )
	-- 获取敌方目标
	local nMinDistance = -1;
	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue
			else
				-- 范围判定  
				local nEnemyPos = pEnemy:GetPos();
				local distance = 0;
				if pCreature:GetIsAttack() then
					distance = pos - nEnemyPos;
				else
					distance = nEnemyPos - pos;
				end

				-- 身后和超出范围的怪 过滤掉  
				if distance < 0 or distance > pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
					-- continue
				else
					if nMinDistance == -1 or nMinDistance < distance then
						pSuitableEnemy = pEnemy;
						nMinDistance = distance;
					end
				end
			end
		end
	end

	return pSuitableEnemy;
end

---------------------------------------  BattleAttackAIBackDouble  ---------------------------------------
-- 先攻击后排 打2个子弹
BattleAttackAIBackDouble = vclass("BattleAttackAIBackDouble", BattleAttackAIBack);

function BattleAttackAIBackDouble:initialize( )
end

-- 选择合适的目标 
-- @Param CBattleCreature* ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleAttackAIBackDouble:Attack( pSelf, pEnemy, pBattle )
	if not pSelf.m_Bullet then
		return -1;
	end

	-- 攻击动作
	pSelf:DoAttack();

	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pSelf:GetIsAttack(), pSelf:GetRoad(), objs);
	local targets = {};
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		-- 攻击类型过滤  
		if local_bit:_and(pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
			-- continue
			objs[k] = nil;
		else
			-- 范围判定  
			local nEnemyPos = pEnemy:GetPos();
			local distance = 0;
			if pSelf:GetIsAttack() then
				distance = pSelf:GetPos() - nEnemyPos;
			else
				distance = nEnemyPos - pSelf:GetPos();
			end
			-- 身后和超出范围的怪 过滤掉  
			if distance < 0 or distance > pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
				-- continue
				objs[k] = nil;
			else
				table.insert(targets, pEnemy);
			end
		end
	end

	if getMapCount(targets) == 0 then
		return 0;
	end

	DistanceSort(targets, pSelf:GetPos());
	for i=1,2 do
		local pBullet = BattleUnitFactory:GetNewBullet(pSelf.m_Bullet.type, pSelf.m_Bullet);
		if pBullet then
			local pEnemy = targets[#targets];
			pBullet:Create(pBattle:GetNewBulletId(), pBattle:GetCurrentTime(), pBattle, pSelf, pEnemy);
			pBullet:SetRoad(pSelf:GetRoad());
			pBattle:ActiveBullet(pBullet);
			if i == 2 then
				pBullet.isSecond = true;
			end

			-- 添加事件
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK, pBullet, pSelf, pEnemy);
			if #targets > 1 then
				table.remove(targets, #targets);
			end
		end
	end

	return 0;
end


---------------------------------------  BattleAttackAISpikeweed  ---------------------------------------
-- 地刺攻击
BattleAttackAISpikeweed = vclass("BattleAttackAISpikeweed", BattleAttackAI);

function BattleAttackAISpikeweed:initialize( )
end

-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAISpikeweed:Attack( pSelf, pEnemy, pBattle )
	local nBeginPos = pSelf:GetPos() - pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
	local nEndPos = pSelf:GetPos();

	-- 攻击动作
	pSelf:DoAttack();

	-- 伤害
	local objs = {}
	pBattle:GetGround():GetCreatureByRoad(not pSelf:GetIsAttack(), pSelf:GetRoad(), objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			if Hit(nBeginPos, nEndPos, pEnemy) then
				-- 攻击类型过滤
				if local_bit:_and(pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
					-- continue;
				else
					local damage = pEnemy:DoDamage(pSelf, pSelf:GetAttackDamage());
					-- 添加事件
					gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pEnemy, damage, pSelf);
				end
			end
		end
	end

	return 0;
end

-- 攻击判断  
-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleAttackAISpikeweed:DoAttack( time, pCreature, pBattle )
	-- 检查自己位置是否合法
	if not pBattle:CheckPostion(pCreature:GetRoad(), pCreature:GetPos()) then
		return -1;
	end

	-- 判断攻击速率  
	-- 目前先不做一个时间间隔发射多发子弹  
	local speed = pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED);
	if (time - pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME)) < speed then
		return -1;
	end

	local nBeginPos = pCreature:GetPos() - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
	local nEndPos = pCreature:GetPos();

	-- 获取敌方目标
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), pCreature:GetRoad(), objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue;
			else
				-- 范围判定
				if Hit(nBeginPos, nEndPos, pEnemy) then
					-- 只要有一个就退出
					pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME, time);
					pCreature:SetAction(ECreatureAction.ACTION_ATTACK);
					pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_PRE, pEnemy:GetId());
					-- 添加事件
					gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK_PRE, pCreature, pEnemy);
					return 0;
				end
			end
		end
	end

	-- 无可攻击目标
	pCreature:SetAction(ECreatureAction.ACTION_MOVE);
	return -1;
end

---------------------------------------  BattleAttackAISpikeweedTwo  ---------------------------------------

BattleAttackAISpikeweedTwo = vclass("BattleAttackAISpikeweedTwo", BattleAttackAI);

function BattleAttackAISpikeweedTwo:initialize( )
end

-- 钢锯地刺攻击
-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleAttackAISpikeweedTwo:DoAttack( time,  pCreature,  pBattle )
	local pCommon = gBattleResource:GetCreatureCommon();
	if not pCommon then
		return -1;
	end

	-- x 秒攻击 y 秒停止  
	local tmp = time % (pCommon.spikeweed_attack + pCommon.spikeweed_stop);
	if tmp > pCommon.spikeweed_attack then
		return 0;
	end

	-- 检查自己位置是否合法
	if not pBattle:CheckPostion(pCreature:GetRoad(), pCreature:GetPos()) then
		return -1;
	end

	local nBeginPos = pCreature:GetPos() - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
	local nEndPos = pCreature:GetPos();

	-- 获取敌方目标
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), pCreature:GetRoad(), objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue;
			else
				-- 范围判定
				if Hit(nBeginPos, nEndPos, pEnemy) then
					-- 只要有一个就退出
					pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME, time);
					pCreature:SetAction(ECreatureAction.ACTION_ATTACK);
					pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_PRE, pEnemy:GetId());
					-- 添加事件
					gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK_PRE, pCreature, pEnemy);
					return 0;
				end
			end
		end
	end

	-- 无可攻击目标
	pCreature:SetAction(ECreatureAction.ACTION_MOVE);
	return -1;
end

---------------------------------------  BattleAttackAIMelee  ---------------------------------------
-- 直线近战单体攻击
BattleAttackAIMelee = vclass("BattleAttackAIMelee", BattleAttackAI);

function BattleAttackAIMelee:initialize( )
end

-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAIMelee:Attack( pSelf, pEnemy, pBattle )
	if pEnemy and pEnemy:GetValid() then
		-- 攻击动作
		pSelf:DoAttack();
		local damage = pEnemy:DoDamage(pSelf, pSelf:GetAttackDamage());
		-- 添加事件
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pEnemy, damage, pSelf);
	end

	return 0;
end

-- 选择合适的目标 
-- @Param int ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleAttackAIMelee:GetEnemy( road, pos, pCreature, pBattle )
	-- 如果已经目标，就采用原有的目标
	local pEnemy = pBattle:GetCreature(not pCreature:GetIsAttack(), pCreature:GetTarget());
	if CanAttack(pCreature,pEnemy) then
		return pEnemy;
	else
		pCreature:SetTarget(0);
	end

	pEnemy = BattleAttackAI.GetEnemy(self, road, pos, pCreature, pBattle);
	if pEnemy then
		pCreature:SetTarget(pEnemy:GetId());
		pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_BLOCK, 1);
	end

	return pEnemy;
end

---------------------------------------  BattleAttackAIMeleeBlock  ---------------------------------------
-- 直线近战单体攻击被阻挡
BattleAttackAIMeleeBlock = vclass("BattleAttackAIMeleeBlock", BattleAttackAIMelee);

function BattleAttackAIMeleeBlock:initialize( )
end

-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAIMeleeBlock:Attack( pSelf, pEnemy, pBattle )
	if pEnemy and pEnemy:GetValid() then
		-- 攻击动作
		pSelf:DoAttack();
		local damage = pEnemy:DoDamage(pSelf, pSelf:GetAttackDamage());
		-- 添加事件
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pEnemy, damage, pSelf);
		local skillId = pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL);
		if skillId then
			local pSkillStatus = pSelf:GetSkillStatus(skillId);
			if pSkillStatus then
				if pSkillStatus.times <= pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_TIMES) then
					pSelf:SetStatus(ECreatureStatus.CREATURE_STATUS_BLOCK, 1);
				end
			end
		end
	end

	return 0;
end

---------------------------------------  BattleAttackAIMeleeMutli  ---------------------------------------
-- 直线近战多体攻击
BattleAttackAIMeleeMutli = vclass("BattleAttackAIMeleeMutli", BattleAttackAIMelee);

function BattleAttackAIMeleeMutli:initialize( )
end

-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAIMeleeMutli:Attack( pSelf, pEnemy, pBattle )
	-- 攻击动作
	pSelf:DoAttack();

	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pSelf:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue;
			else
				-- 范围判定  
				local nEnemyPos = pEnemy:GetPos();
				local distance = 0;
				if pSelf:GetIsAttack() then
					distance = pSelf:GetPos() - nEnemyPos;
				else
					distance = nEnemyPos - pSelf:GetPos();
				end

				-- 身后和超出范围的怪 过滤掉  
				if distance < 0 or distance > pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
					-- continue;
				else
					local damage = pEnemy:DoDamage(pSelf, pSelf:GetAttackDamage());
					-- 添加事件
					gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pEnemy, damage, pSelf);
				end
			end
		end
	end

	return 0;
end

---------------------------------------  BattleAttackAIRangeMutli  ---------------------------------------
-- 直线范围多体攻击
BattleAttackAIRangeMutli = vclass("BattleAttackAIRangeMutli", BattleAttackAIMelee);

function BattleAttackAIRangeMutli:initialize( )
end

-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAIRangeMutli:Attack( pSelf, pEnemy, pBattle )
	-- 攻击动作
	pSelf:DoAttack();
	local objs = {};
	local position = PositionData:new();
	position.road = pSelf:GetRoad();
	position.pos = pSelf:GetPos();  
	local diff = gBattleView.cellNum * 1.5;
	if pSelf:GetIsAttack() then
		pBattle:GetGround():GetRangeCreatures(not pSelf:GetIsAttack(), position, 0, -diff, 0, false, objs);
	else
		pBattle:GetGround():GetRangeCreatures(not pSelf:GetIsAttack(), position, 0, 0, diff, false, objs);
	end
	local targets = {};
	for k,v in pairs(objs) do
		if v:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), v:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue;
			else
				table.insert(targets,v);
			end
		end
	end
	for key, value in pairs(targets) do
		local damage = value:DoDamage(pSelf, pSelf:GetAttackDamage());
		-- 添加事件
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, value, damage, pSelf);
	end

	return 0;
end
---------------------------------------  BattleAttackAIThief  ---------------------------------------
-- 小偷
BattleAttackAIThief = vclass("BattleAttackAIThief", BattleAttackAI);

function BattleAttackAIThief:initialize( )
end

-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAIThief:Attack( pSelf, pEnemy, pBattle )
	-- 制造子弹
	if not pSelf.m_Bullet then
		return -1;
	end

	-- 子弹初始化
	local pBullet = BattleUnitFactory:GetNewBullet(pSelf.m_Bullet.type, pSelf.m_Bullet);
	if not pBullet then
		return -1;
	end

	-- 攻击动作
	pSelf:DoAttack();

	-- 子弹加入战场
	pBullet:Create(pBattle:GetNewBulletId(), pBattle:GetCurrentTime(), pBattle, pSelf, pEnemy);
	pBattle:ActiveBullet(pBullet);

	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK, pBullet, pSelf, pEnemy);

	return 0;
end

---------------------------------------  BattleAttackAIThiefBlue  ---------------------------------------
-- 蓝色小偷 选择非远程植物
BattleAttackAIThiefBlue = vclass("BattleAttackAIThiefBlue", BattleAttackAIThief);

function BattleAttackAIThiefBlue:initialize( )
end

-- 选择合适的目标 
-- @Param int ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleAttackAIThiefBlue:GetEnemy( road, pos, pCreature, pBattle )
	-- 获取敌方目标
	local bFind = false;
	local nMinDistance = -1;
	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		-- 攻击类型过滤  
		if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
			-- continue
		else
			-- 范围判定
			local nEnemyPos = pEnemy:GetPos();
			local distance = 0;
			if pCreature:GetIsAttack() then
				distance = pos - nEnemyPos;
			else
				distance = nEnemyPos - pos;
			end

			-- 身后和超出范围的怪 过滤掉
			if distance < 0 or distance > pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
				-- continue
			else
				-- 伤害类型
				if pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_TYPE) ~= 1 and pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_DAMAGE_TYPE) ~= 2 then
					if not bFind then
						pSuitableEnemy = pEnemy;
						nMinDistance = distance;
						bFind = true;
					end

					if nMinDistance > distance then
						pSuitableEnemy = pEnemy;
						nMinDistance = distance;
					end
				end

				if bFind then
					-- continue
				else
					if nMinDistance == -1 or nMinDistance > distance then
						pSuitableEnemy = pEnemy;
						nMinDistance = distance;
					end
				end
			end
		end
	end
	return pSuitableEnemy;
end

---------------------------------------  BattleAttackAIResource  ---------------------------------------
-- 资源植物  
BattleAttackAIResource = vclass("BattleAttackAIResource", BattleAI);

function BattleAttackAIResource:initialize( )
end

-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleAttackAIResource:Update( time,  pCreature,  pBattle )
	if pBattle:GetType() ~= BattleType.BattleTypeEvp then
		pCreature:ClearAttackAI();
		return;
	end
	--查看首次产阳光时间
	if time - pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_ACTIVE_TIME) < pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_SPEED) then
		return;
	end
	
	local speed = pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_SPEED);
	if pCreature:AttackCount() <= 0 then
		speed = 0;
	end

	if time - pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME) < speed then
		return;
	end

	pCreature:SetStatus(ECreatureStatus.CREATURE_STATUS_LAST_ATTACK_TIME, time);
	local sunValue = pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_VALUE);
	pBattle:AddSunshine(sunValue, time, pCreature);
	pCreature:IncAttackCount();
end

---------------------------------------  BattleAttackAIPreRace  ---------------------------------------
--攻击最近一个目标（优先魔法师和炸弹僵尸）
BattleAttackAIPreRace = vclass("BattleAttackAIPreRace", BattleAttackAI);
function BattleAttackAIPreRace:initialize( )
end
-- 选择合适的目标 
-- @Param int ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleAttackAIPreRace:GetEnemy( road, pos, pCreature, pBattle )
	-- 获取敌方目标
	local nCurrentRace = -1;
    local nTargetRace = -1;  
	local nMinDistance = -1;
	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue
			else
				-- 范围判定  
				local nEnemyPos = pEnemy:GetPos();
				local distance = 0;
				if pCreature:GetIsAttack() then
					distance = pos - nEnemyPos;
				else
					distance = nEnemyPos - pos;
				end
				-- 身后和超出范围的怪 过滤掉  
				if distance < 0 or distance > pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
					-- continue
				else
					nTargetRace = pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE);	
					if nMinDistance == -1 then
						pSuitableEnemy = pEnemy;
						nMinDistance = distance;
						nCurrentRace = nTargetRace;
					else
						if nCurrentRace ==30 or nCurrentRace == 40 then		        
			                if (nTargetRace ==30 or nTargetRace == 40) and (nMinDistance > distance) then           
			                    pSuitableEnemy = pEnemy;
			                    nMinDistance = distance;
			                    nCurrentRace = nTargetRace;
			                end			            
						else
							if nTargetRace ==30 or nTargetRace == 40 then
								pSuitableEnemy = pEnemy;
			                    nMinDistance = distance;
			                    nCurrentRace = nTargetRace;
							else
								if nMinDistance > distance then
									pSuitableEnemy = pEnemy;
			                    	nMinDistance = distance;
			                    	nCurrentRace = nTargetRace;
								end
							end
						end
					end
				end
			end
		end
	end
	return pSuitableEnemy;
end

---------------------------------------  BattleAttackAIPreRaceDouble  ---------------------------------------
--攻击前排两个目标（优先魔法师和炸弹僵尸）
BattleAttackAIPreRaceDouble = vclass("BattleAttackAIPreRaceDouble", BattleAttackAI);
function BattleAttackAIPreRaceDouble:initialize( )
end
-- 攻击处理  
-- @Param CBattleCreature*, CBattleCreature*, CBattle*
-- @Return int
function BattleAttackAIPreRaceDouble:Attack( pSelf, pEnemy, pBattle )
	if not pSelf.m_Bullet then
		return -1;
	end
	-- 攻击动作
	pSelf:DoAttack();
	local objsSuitable = {};
	local objs1 = {};
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pSelf:GetIsAttack(), pSelf:GetRoad(), objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;
		-- 攻击类型过滤  
		if local_bit:_and(pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
			-- continue
		else
			-- 范围判定  
			local nEnemyPos = pEnemy:GetPos();
			local distance = 0;
			if pSelf:GetIsAttack() then
				distance = pSelf:GetPos() - nEnemyPos;
			else
				distance = nEnemyPos - pSelf:GetPos();
			end
			-- 身后和超出范围的怪 过滤掉  
			if distance < 0 or distance > pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
			else
				if pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) == 30 or pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) == 40 then
					table.insert(objsSuitable,pEnemy);
				else
					table.insert(objs1,pEnemy);
				end
			end
		end
	end

	if #objsSuitable < 2 and #objs1 > 0 then
		DistanceSortEx(objs1, pSelf:GetPos());
		for key,value in pairs(objs1) do
			table.insert(objsSuitable,value);
			if #objsSuitable >= 2 then
				break;
			end
		end
	end
	if #objsSuitable <= 0 then
		return;
	end
	DistanceSortEx(objsSuitable, pSelf:GetPos());
	for i = 1, 2 do
		local pBullet = BattleUnitFactory:GetNewBullet(pSelf.m_Bullet.type, pSelf.m_Bullet);
		if pBullet then
			local pEnemy = objsSuitable[i];
			if pEnemy == nil then
				pEnemy = objsSuitable[#objsSuitable];
			end
			pBullet:Create(pBattle:GetNewBulletId(), pBattle:GetCurrentTime(), pBattle, pSelf, pEnemy);
			pBullet:SetRoad(pSelf:GetRoad());
			pBattle:ActiveBullet(pBullet);
			if i == 2 then
				pBullet.isSecond = true;
			end

			-- 添加事件
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ATTACK, pBullet, pSelf, pEnemy);
		end
	end

	return 0;
end
-------------------------------------------------------------           攻击AI  END          --------------------------------------------------------------


----------------------------------------------------------------           技能AI          -----------------------------------------------------------------
---------------------------------------  BattleSkillAI  ---------------------------------------
-- 基础技能AI(按照时间释放)  
BattleSkillAI = vclass("BattleSkillAI", BattleAI);

function BattleSkillAI:initialize( )
end

-- 更新
-- @Param int ,BattleCreature*, Battle*
-- @Return void
function BattleSkillAI:Update( time,  pCreature,  pBattle )
	if not pCreature.m_Skill then
		return;
	end
	-- 技能状态
	local pSkillStatus = pCreature:GetSkillStatus(pCreature.m_Skill.m_id);
	if not pSkillStatus then
		pSkillStatus = pCreature:AddSkillStatus(pCreature.m_Skill.m_id);
	end

	-- 判断技能释放
	-- cclog("***** pSkillStatus.pre = %f, pSkillStatus.post = %f", pSkillStatus.pre, pSkillStatus.post);
	if pSkillStatus.pre == 0 and pSkillStatus.post == 0 then
		if self:DoSkill(time, pSkillStatus, pCreature.m_Skill, pCreature, pBattle) ~= 0 then
			-- cclog("**** 3");
			return;
		end
	end

	-- 技能前摇
	-- cclog("***** pSkillStatus.pre = %f, pSkill.m_skillData.pre = %f, pSkillStatus.post = %f", pSkillStatus.pre, pSkill.m_skillData.pre, pSkillStatus.post);
	if (pSkillStatus.pre ~= 0 or pCreature.m_Skill.m_skillData.pre == 0) and pSkillStatus.post == 0 then
		if self:DoPre(time, pSkillStatus, pCreature.m_Skill, pCreature, pBattle) ~= 0 then
			-- cclog("**** 4");
			return;
		end
	end	

	-- 技能后摇
	-- cclog("***** pSkillStatus.post = %f, pSkill.m_skillData.post = %f", pSkillStatus.post, pSkill.m_skillData.post);
	if pSkillStatus.post ~= 0 or pCreature.m_Skill.m_skillData.post == 0 then
		if self:DoPost(time, pSkillStatus, pCreature.m_Skill, pCreature, pBattle) ~= 0 then
			-- cclog("**** 5");
			return;
		end
	end
end

-- 前摇处理
-- @Param int, SkillStatus*, BattleBuffProp*, CBattleCreature*, CBattle*
-- @Return void
function BattleSkillAI:DoPre( time, pSkillStatus, pSkill, pSelf, pBattle )
	-- 前摇未结束
	if time - pSkillStatus.pre < pSkill.m_skillData.pre then
		return -1;
	end

	local pTarget = pBattle:GetCreature(not pSelf:GetIsAttack(), pSelf:GetTarget());
	if not pTarget then
		pTarget = pBattle:GetCreature(pSelf:GetIsAttack(), pSelf:GetTarget());
	end

	-- 重置前摇
	pSkillStatus.pre = 0;
	pSkillStatus.times = pSkillStatus.times + 1;

	-- 添加事件
	gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_SKILL, pSelf, pSkill.m_id, pTarget);

	-- 释放效果
	local position = PositionData:new();
	BattleBuff:DoSkill(pSkill, pSelf, pTarget, position, pBattle);

	-- 技能后摇
	if pSkill.m_skillData.post ~= 0 then
		pSkillStatus.post = time;
	end

	return 0;
end

-- 后摇处理
-- @Param int, SkillStatus*, BattleBuffProp*, CBattleCreature*, CBattle*
-- @Return void
function BattleSkillAI:DoPost( time, pSkillStatus, pSkill, pSelf, pBattle )
	-- 前摇未结束
	-- cclog("**** id = %d, time = %f,  pSkillStatus.post = %f,  pSkill.m_skillData.post = %f ", pSelf:GetId(), time, pSkillStatus.post, pSkill.m_skillData.post);
	if time - pSkillStatus.post < pSkill.m_skillData.post then
		return -1;
	end

	-- 重置后摇
	pSkillStatus.post = 0;

	-- 生物需要切换状态
	pSelf:SetAction(pSelf:GetLastAction());

	return 0;
end

-- 技能判断
-- @Param int, SkillStatus*, BattleBuffProp*, CBattleCreature*, CBattle*
-- @Return void
function BattleSkillAI:DoSkill( time, pSkillStatus, pSkill, pSelf, pBattle )
	-- 检查释放条件
	if self:Check(time, pSkillStatus, pSkill, pSelf, pBattle) ~= 0 then
		return -1;
	end

	-- 设置状态
	pSelf:SetAction(ECreatureAction.ACTION_SKILL);
	pSkillStatus.nLastTime = time;

	-- 释放前摇
	if pSkill.m_skillData.pre ~= 0 and pSkillStatus.pre == 0 then
		pSkillStatus.pre = time;
		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_SKILL_SHAKE, pSelf, pSkill.m_id);
	end

	return 0;
end

-- 额外判断
-- @Param int, SkillStatus*, BattleBuffProp*, CBattleCreature*, CBattle*
-- @Return void
function BattleSkillAI:Check( time, pSkillStatus, pSkill, pSelf, pBattle )
	-- 首次释放时间
	if (time - pSelf:GetStatus(ECreatureStatus.CREATURE_STATUS_ACTIVE_TIME)) < pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_FIRST) then
		-- cclog("************ time = %f, active time = %f, skill first = %f", time, pSelf:GetStatus(ECreatureStatus.CREATURE_STATUS_ACTIVE_TIME), pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_FIRST));
		return -1;
	end

	-- 释放次数
	if pSkillStatus.times >= pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_TIMES) then
		-- cclog("************ pSkillStatus.times = %f, skill times = %f", pSkillStatus.times, pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_TIMES));
		return -1;
	end

	-- 释放CD
	if pSkillStatus.nLastTime ~= 0 and time - pSkillStatus.nLastTime < pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_CD) then
		-- cclog("************ pSkillStatus.nLastTime = %f, time = %f, skill cd = %f", pSkillStatus.nLastTime, time, pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_SKILL_CD));
		return -1;
	end

	-- 释放条件
	if not gBattleConditionMgr:Check(pBattle, pSelf, pSkill.m_conditions) then
		-- cclog("**** Check condition false");
		--条件失败开始CD
		pSkillStatus.nLastTime = time;
		return -1;
	end

	return 0;
end

---------------------------------------  BattleSkillAITarget  ---------------------------------------
-- 有敌方目标释放技能  
BattleSkillAITarget = vclass("BattleSkillAITarget", BattleSkillAI);

function BattleSkillAITarget:initialize( )
end

-- 额外判断
-- @Param int, SkillStatus*, BattleBuffProp*, CBattleCreature*, CBattle*
-- @Return void
function BattleSkillAITarget:Check( time, pSkillStatus, pSkill, pSelf, pBattle )
	local pTarget = self:GetEnemy(pSelf:GetRoad(), pSelf:GetPos(), pSelf, pBattle);
	if not pTarget then
		if not pSelf.m_pAttackAI then
			pSelf:SetAction(ECreatureAction.ACTION_MOVE);
		end
		return -1;
	end

	if BattleSkillAI.Check(self,time,pSkillStatus,pSkill,pSelf,pBattle) ~= 0 then
		return -1;
	end

	pSelf:SetTarget(pTarget:GetId());

	return 0;
end

-- 选择合适的目标 
-- @Param int ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleSkillAITarget:GetEnemy( road, pos, pCreature, pBattle )
	-- 如果已经目标，就采用原有的目标
	local pEnemy = pBattle:GetCreature(not pCreature:GetIsAttack(), pCreature:GetTarget());
	if CanAttack(pCreature,pEnemy) then
		return pEnemy;
	else
		pCreature:SetTarget(0);
	end

	-- 获取敌方目标
	local nMinDistance = -1;
	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue;
			else
				-- 范围判定  
				local nEnemyPos = pEnemy:GetPos();
				local distance = 0;
				if pCreature:GetIsAttack() then
					distance = pos - nEnemyPos;
				else
					distance = nEnemyPos - pos;
				end

				-- 身后和超出范围的怪 过滤掉  
				if distance < 0 or distance > pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
					-- continue;
				else
					if nMinDistance == -1 or nMinDistance > distance then
						pSuitableEnemy = pEnemy;
						nMinDistance = distance;
					end
				end
			end
		end
	end

	return pSuitableEnemy;
end


---------------------------------------  BattleSkillAITargetBite  ---------------------------------------
-- 有未被咬住的目标释放技能
BattleSkillAITargetBite = vclass("BattleSkillAITargetBite", BattleSkillAITarget);

function BattleSkillAITargetBite:initialize( )
end

-- 选择合适的目标 
-- @Param int, int, BattleCreature*, Battle*
-- @Return BattleCreature*
function BattleSkillAITargetBite:GetEnemy( road, pos, pCreature, pBattle )
	-- 每次选择新目标  
	pCreature:GetTarget(0);

	-- 获取敌方目标  
	local nMinDistance = -1;
	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue;
			else
				-- 被咬住的过滤掉  
				if pCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_BITE) == 1 then
					-- continue
				else
					-- 范围判定  
					local nEnemyPos = pEnemy:GetPos();
					local distance = 0;
					if pCreature:GetIsAttack() then
						distance = pos - nEnemyPos;
					else
						distance = nEnemyPos - pos;
					end

					-- 身后和超出范围的怪 过滤掉  
					if distance < 0 or distance > pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
						-- continue;
					else
						if nMinDistance == -1 or nMinDistance > distance then
							pSuitableEnemy = pEnemy;
							nMinDistance = distance;
						end
					end
				end
			end
		end
	end
	
	return pSuitableEnemy;
end

---------------------------------------  BattleSkillAITargetBody  ---------------------------------------
-- 身体上方有目标释放技能
BattleSkillAITargetBody = vclass("BattleSkillAITargetBody", BattleSkillAITarget);

function BattleSkillAITargetBody:initialize( )
end

-- 选择合适的目标 
-- @Param int, int, BattleCreature*, Battle*
-- @Return BattleCreature*
function BattleSkillAITargetBody:GetEnemy( road, pos, pCreature, pBattle )
	pCreature:SetTarget(0);

	local nBeginPos = 0;
	local nEndPos = 0;
	if not pCreature:GetIsAttack() then
		nBeginPos = pCreature:GetPos() - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
		nEndPos = pCreature:GetPos();
	else
		nEndPos = pCreature:GetPos() + pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
		nBeginPos = pCreature:GetPos();
	end

	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		-- 攻击类型过滤
		if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
			-- continue
		else
			-- 范围判定
			if Hit(nBeginPos, nEndPos, pEnemy) then
				pSuitableEnemy = pEnemy;
				break;
			end
		end
	end

	return pSuitableEnemy;
end

---------------------------------------  BattleSkillAITargetHurt  ---------------------------------------
-- 有受伤的目标释放技能  
BattleSkillAITargetHurt = vclass("BattleSkillAITargetHurt", BattleSkillAITarget);

function BattleSkillAITargetHurt:initialize( )
end

-- 选择合适的目标 
-- @Param int, int, BattleCreature*, Battle*
-- @Return BattleCreature*
function BattleSkillAITargetHurt:GetEnemy( road, pos, pCreature, pBattle )
	pCreature:SetTarget(0);

	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(pCreature:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;
		if pEnemy:GetHp() ~= pEnemy:GetRawHp() then
			pSuitableEnemy = pEnemy;
			break;
		end
	end
	return pSuitableEnemy;
end

---------------------------------------  BattleSkillAITargetRace  ---------------------------------------
-- 目标为玉米或者西瓜  
BattleSkillAITargetRace = vclass("BattleSkillAITargetRace", BattleSkillAITarget);

function BattleSkillAITargetRace:initialize( )
end

-- 选择合适的目标 
-- @Param int ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleSkillAITargetRace:GetEnemy( road, pos, pCreature, pBattle )
	pCreature:SetTarget(0);
	-- 获取敌方目标
	local nMinDistance = -1;
	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue;
			else
				--目标类型判断 玉米 or 西瓜
				if pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) ~= 160 and pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) ~= 180 then
					--continue;
				else
					-- 范围判定  
					local nEnemyPos = pEnemy:GetPos();
					local distance = 0;
					if pCreature:GetIsAttack() then
						distance = pos - nEnemyPos;
					else
						distance = nEnemyPos - pos;
					end

					-- 身后和超出范围的怪 过滤掉  
					if distance < 0 or distance > pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
						-- continue;
					else
						if nMinDistance == -1 or nMinDistance > distance then
							pSuitableEnemy = pEnemy;
							nMinDistance = distance;
						end
					end
				end
			end
		end
	end

	return pSuitableEnemy;
end
---------------------------------------  BattleSkillAITargetBodyRace  ---------------------------------------
-- 身体上方有目标为橄榄球 or 伽刚特尔僵尸
BattleSkillAITargetBodyRace = vclass("BattleSkillAITargetBodyRace", BattleSkillAITarget);

function BattleSkillAITargetBodyRace:initialize( )
end

-- 选择合适的目标 
-- @Param int, int, BattleCreature*, Battle*
-- @Return BattleCreature*
function BattleSkillAITargetBodyRace:GetEnemy( road, pos, pCreature, pBattle )
	pCreature:SetTarget(0);

	local nBeginPos = 0;
	local nEndPos = 0;
	if not pCreature:GetIsAttack() then
		nBeginPos = pCreature:GetPos() - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN)/2 - 2;
		nEndPos = pCreature:GetPos() - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN)/2 + 2;
	else
		nBeginPos = pCreature:GetPos() + pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN)/2 - 2;
		nEndPos = pCreature:GetPos() + pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN)/2 + 2;
	end

	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		-- 攻击类型过滤
		if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
			-- continue
		else
			--目标类型判断 橄榄球 or 伽刚特尔僵尸  
			if pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) ~= 50 and pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE) ~= 80 then
				--continue;
			else
				-- 范围判定
				if Hit3(nBeginPos, nEndPos, pEnemy) then
					pSuitableEnemy = pEnemy;
					break;
				end
			end
		end
	end

	return pSuitableEnemy;
end

---------------------------------------  BattleSkillAITargetPreRace  ---------------------------------------
-- CBattleSkillAITargetPreRace  
BattleSkillAITargetPreRace = vclass("BattleSkillAITargetPreRace", BattleSkillAITarget);

function BattleSkillAITargetPreRace:initialize( )
end

-- 选择合适的目标 
-- @Param int ,BattleCreature*, Battle*
-- @Return CBattleCreature
function BattleSkillAITargetPreRace:GetEnemy( road, pos, pCreature, pBattle )
	-- 获取敌方目标
	local nCurrentRace = -1;
    local nTargetRace = -1;  
	local nMinDistance = -1;
	local pSuitableEnemy = nil;
	local objs = {};
	pBattle:GetGround():GetCreatureByRoad(not pCreature:GetIsAttack(), road, objs);
	for k,v in pairsByKeys(objs) do
		local pEnemy = v;

		if pEnemy:GetValid() then
			-- 攻击类型过滤  
			if local_bit:_and(pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE), pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
				-- continue
			else
				-- 范围判定  
				local nEnemyPos = pEnemy:GetPos();
				local distance = 0;
				if pCreature:GetIsAttack() then
					distance = pos - nEnemyPos;
				else
					distance = nEnemyPos - pos;
				end
				-- 身后和超出范围的怪 过滤掉  
				if distance < 0 or distance > pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) then
					-- continue
				else
					nTargetRace = pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE);	
					if nMinDistance == -1 then
						pSuitableEnemy = pEnemy;
						nMinDistance = distance;
						nCurrentRace = nTargetRace;
					else
						if nCurrentRace ==30 or nCurrentRace == 40 then		        
			                if (nTargetRace ==30 or nTargetRace == 40) and (nMinDistance > distance) then           
			                    pSuitableEnemy = pEnemy;
			                    nMinDistance = distance;
			                    nCurrentRace = nTargetRace;
			                end			            
						else
							if nTargetRace ==30 or nTargetRace == 40 then
								pSuitableEnemy = pEnemy;
			                    nMinDistance = distance;
			                    nCurrentRace = nTargetRace;
							else
								if nMinDistance > distance then
									pSuitableEnemy = pEnemy;
			                    	nMinDistance = distance;
			                    	nCurrentRace = nTargetRace;
								end
							end
						end
					end
				end
			end
		end
	end

	return pSuitableEnemy;
end
-------------------------------------------------------------           技能AI  END          --------------------------------------------------------------