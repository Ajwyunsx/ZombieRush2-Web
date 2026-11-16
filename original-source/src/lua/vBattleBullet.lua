--vBattleBullet.lua
require "vBattleResource"

gCRCLE_POS = 70;

local local_bit = gBit;

-- 是否被击中2
-- @Param int, CBattleCreature*
-- @Return bool
local function Hit2( pos, pCreature)
	local head = pCreature:GetPos();
	local tail = 0;

	if pCreature:GetIsAttack() then
		tail = head + pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
		if head <= pos and pos <= tail then
			return true;
		end
	else
		tail = head - pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LEN);
		if tail <= pos and pos <= head then
			return true;
		end
	end

	return false;
end
---------------------------------------  public  ---------------------------------------
BattleBullet = vclass("BattleBullet", BattleUnit);

function BattleBullet:initialize( prop )
	BattleUnit.initialize(self, EUnitType.TYPE_BULLET, prop);
	
	self.m_src = 0;							-- int 发射物Id
	self.m_nBeginTime = 0;					-- int
	self.m_nEndTime = 0;					-- int 
	self.m_nBeginPos = 0;					-- int
	self.m_damageTargets = {};				-- set<int>
	self.m_prop = prop;					-- BulletProp
	self.m_pBattle = nil;					-- CBattle*
end

-- @Param int, int, CBattle*, CBattleUnit*, CBattleCreature*
-- @Return bool
function BattleBullet:Create( id, time, pBattle, pAttack, pDefend )
	self.m_src = pAttack:GetId();
	self.m_nBeginTime = time;
	self.m_nEndTime = 0;
	self.m_nBeginPos = pAttack:GetPos();
	self.m_pBattle = pBattle;
	self.m_strName = self.m_prop.name;
	if pDefend then
		self:SetTarget(pDefend:GetId());
	end

	self:SetId(id);
	self:SetPos(pAttack:GetPos());
	self:SetRoad(pAttack:GetRoad());
	self:SetAttackDamage(pAttack:GetAttackDamage());
	self.moveType = pAttack:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)

	if pBattle:GetType() == BattleType.BattleTypePlunder or pBattle:GetType() == BattleType.BattleTypePve or pBattle:GetType() == BattleType.BattleTypeGroupbattle then
		if pAttack:GetIsAttack() then
			self:SetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_VALUE, pAttack:GetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_VALUE));
		end
	end

	self:SetValid(true);
	self:SetIsAttack(pAttack:GetIsAttack());

	return true;
end

-- @Param 
-- @Return int
function BattleBullet:GetId( )
	return self.m_id;
end

-- @Param 
-- @Return int
function BattleBullet:GetSrc( )
	return self.m_src;
end

-- @Param 
-- @Return void
function BattleBullet:Close( )
	self:SetValid(false);
end

-- @Param 
-- @Return BulletProp
function BattleBullet:GetProp( )
	return self.m_prop;
end

-- @Param int, CBattle*
-- @Return void
function BattleBullet:Update( time )
	local nCurrentPos = self:_CurrentPos(time);
	nCurrentPos = math.floor(nCurrentPos);
	self:SetPos(nCurrentPos);

	if self:GetLastPos() > self.m_pBattle:GetGround():GetLen() then
		self:SetValid(false);
		return;
	end

	local nMinDistance = -1;
	local pSuitableEnemy = nil;

	-- 获取敌方单位
	local obj = {};
	self.m_pBattle:GetGround():GetCreatureByRoad(not self:GetIsAttack(), self:GetRoad(), obj);
	for k,v in pairsByKeys(obj) do
		local pTarget = v;

		-- 类型匹配
		if local_bit:_and(self.m_prop.attack_type, pTarget:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
			-- continue;
		else
			-- 位置匹配
			local distance = -1;
			local nEnemyPos = pTarget:GetPos();
			local isContinue = false;
			if self:GetIsAttack() then
				-- if self:GetId() == 1 then
				-- 	cclog("*** 1  self:GetLastPos() = %f, nEnemyPos = %f, nCurrentPos = %f", self:GetLastPos(), nEnemyPos, nCurrentPos);
				-- end
				if nCurrentPos > nEnemyPos or nEnemyPos > self:GetLastPos() then
					-- continue;
					isContinue = true;
				else	
					distance = self:GetLastPos() - nEnemyPos;
				end
			else
				-- if self:GetId() == 1 then
				-- 	cclog("*** 2  self:GetLastPos() = %f, nEnemyPos = %f, nCurrentPos = %f", self:GetLastPos(), nEnemyPos, nCurrentPos);
				-- end

				if self:GetLastPos() > nEnemyPos or nEnemyPos > nCurrentPos then
					-- continue;
					isContinue = true;
				else
					distance = nEnemyPos - self:GetLastPos();
				end
			end

			if not isContinue then
				if nMinDistance == -1 or nMinDistance > distance then
					pSuitableEnemy = pTarget;
					nMinDistance = distance;
				end
			end
		end
	end

	if pSuitableEnemy == nil then
		return;
	end

	-- cclog("********* nCurrentPos = %f, nEnemyPos = %f,  self:GetLastPos() = %f", nCurrentPos, pSuitableEnemy:GetPos(), self:GetLastPos());
	self:SetValid(false);
	BattleBullet:DoDamage(self, pSuitableEnemy, self.m_pBattle);
end

-- @Param CBattleBullet*, CBattleCreature*, CBattle*
-- @Return int
function BattleBullet:DoDamage( pBullet, pTarget, pBattle )
	-- 执行buff
	local pBuff = gBattleResource:GetBuffProp(pBullet.m_prop.buff);
	if pBuff and gBattleConditionMgr:Check(pBattle, pBullet, pBuff.m_conditions) then
		local buff = BattleBuff:new(pBuff);
		buff:Create(pBullet, pBattle:GetCurrentTime());
		buff:DoBuff(EBattleBuffEvent.BATTLE_BUFF_EVENT_ATTACK, pBattle);
	end

	-- 执行攻击
	if pTarget then
		if pBullet.m_prop.self_attack == 1 then
			-- cclog("****** hp = %f",  pTarget.m_fLife);
			local damage = pTarget:DoDamage(pBullet, pBullet:GetAttackDamage());
			-- cclog("****** damage = %f,  hp = %f", damage,  pTarget.m_fLife);
			-- 添加事件
			gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DAMAGE, pTarget, damage, pBullet);
			
			-- 不是回旋镖则抛出销毁事件
			if pBullet.m_prop.type ~= 2 then
				if pTarget:GetHp() == 0 and pTarget:GetValid() == false then
					pBullet.doDel = true;
				end
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_DEATH, pBullet, pTarget);
			end
		end

		-- 执行阳光
		if pBullet:GetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_VALUE) ~= 0 and pTarget and pTarget:GetValid() then
			pBattle:AddSunshine(pBullet:GetAttr(ECreatureAttr.CREATURE_ATTR_SUNSHINE_VALUE), pBattle:GetCurrentTime(), pTarget);
		end
	end
	
	return 0;
end

-- @Param CBattleBullet*, CBattle*
-- @Return int
function BattleBullet:ImpactAndDamage( pBullet,  pBattle)
	local target = -1;
	local nMinDistance = -1;
	local obj = {};
	pBattle:GetGround():GetCreatureByRoad(not pBullet:GetIsAttack(), pBullet:GetRoad(),obj);
	for k,v in pairsByKeys(obj) do
		local pEnemy = v;

		-- 类型匹配
		if local_bit:_and(pBullet.m_prop.attack_type, pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) == 0 then
			-- continue;
		else
			-- 只考虑防守方的
			local nEnemyPos = pEnemy:GetPos();
			local nEnemyId = pEnemy:GetId();
			-- if pBullet:GetId() == 3 then
			-- 	cclog("*** time = %f, id = %d,   Pos = %f, nEnemyPos = %f, LastPos = %f", bTime, pBullet:GetId(), pBullet:GetPos(), nEnemyPos, pBullet:GetLastPos());
			-- end

			local isFullDamage = true;
			if pBullet:GetLastPos() <= nEnemyPos and nEnemyPos <= pBullet:GetPos() then
				if getMapCount(pBullet.m_damageTargets) < self.m_prop.num and not pBullet.m_damageTargets[nEnemyId] then
					pBullet.m_damageTargets[nEnemyId] = 0;
					isFullDamage = false;
				end

				if not isFullDamage then
					-- cclog("*** 1  id = %d, damageTargets = %d", pBullet:GetId(), pBullet.m_damageTargets[nEnemyId]);
					BattleBullet:DoDamage(pBullet, pEnemy, pBattle);
					if nMinDistance == -1 then
						target = pEnemy:GetId();
						nMinDistance = nEnemyPos - pBullet:GetLastPos();
					end
				end
			end

			isFullDamage = true;
			if pBullet:GetPos() <= nEnemyPos and nEnemyPos <= pBullet:GetLastPos() then
				-- cclog("** 2 #pBullet.m_damageTargets = %d,  self.m_prop.num = %d", #pBullet.m_damageTargets, self.m_prop.num);
				if pBullet.m_damageTargets[nEnemyId] then
					if pBullet.m_damageTargets[nEnemyId] == 0 then
						pBullet.m_damageTargets[nEnemyId] = 1;
						isFullDamage = false;
					end
				elseif getMapCount(pBullet.m_damageTargets) < self.m_prop.num then
					pBullet.m_damageTargets[nEnemyId] = 1;
					isFullDamage = false;
				end

				if not isFullDamage then
					-- cclog("*** 2  id = %d, damageTargets = %d", pBullet:GetId(), pBullet.m_damageTargets[nEnemyId]);
					BattleBullet:DoDamage(pBullet, pEnemy, pBattle);
				end
			end
		end
	end

	return target;
end

---------------------------------------  private  ---------------------------------------

-- @Param int
-- @Return int
function BattleBullet:_CurrentPos( time )	
	if self.m_prop.speed == 0 then
		return self.m_nBeginPos;
	end

	local distance = (time - self.m_nBeginTime) / gBattleView.msec_unit * self.m_prop.speed;
	if self:GetIsAttack() then
		return self.m_nBeginPos - distance;
	else
		return self.m_nBeginPos + distance;
	end
end

---------------------------------------  BattleBulletTrace  ---------------------------------------
-- 跟踪子弹
BattleBulletTrace = vclass("BattleBulletTrace", BattleBullet);

function BattleBulletTrace:initialize( prop )
	BattleBullet.initialize(self, prop);
	self.m_nTargetPos = 0;	
	self.m_nTargetRoad = 0;
	self:SetMode(EUnitType.TYPE_BULLET_TRACE);
end

function BattleBulletTrace:Create( id, time, pBattle, pAttack, pDefend )
	local ret = BattleBullet.Create(self, id, time, pBattle, pAttack, pDefend );
	if not ret then
		return ret;
	end

	self:UpdateTargetPos();
	return ret;
end

function BattleBulletTrace:Update( time )
	-- 还未达到目标,追踪子弹时，速度表示运行时间
	if time - self.m_nBeginTime < self.m_prop.speed * gBattleView.msec_unit then
		return;
	end

	-- 时间到了，不管怪物死活，子弹都无效
	self:SetValid(false);

	-- 获取敌方单位
	local pTarget = nil;
	local obj = {};
	self.m_pBattle:GetGround():GetCreatureByRoad(not self:GetIsAttack(), self:GetRoad(), obj);
	for k,v in pairsByKeys(obj) do
		local pEnemy = v;

		-- 位置匹配
		if Hit2(self.m_nTargetPos, pEnemy) then
			-- 类型匹配
			if local_bit:_and(self.m_prop.attack_type, pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE)) ~= 0 then
				-- 匹配最高的
				if not pTarget then
					pTarget = pEnemy;
				elseif pTarget:GetAttr(ECreatureAttr.CREATURE_ATTR_HIGHT) < pEnemy:GetAttr(ECreatureAttr.CREATURE_ATTR_HIGHT) then
					pTarget = pEnemy;
				end
			end
		end
	end

	self:SetPos(self.m_nTargetPos);
	self:SetRoad(self.m_nTargetRoad);
	BattleBullet:DoDamage(self, pTarget, self.m_pBattle);
end

function BattleBulletTrace:UpdateTargetPos()
	local pTarget = self.m_pBattle:GetCreature(not self:GetIsAttack(), self:GetTarget());
	assert(pTarget ~= nil, "BattleBulletTrace:UpdateTargetPos Error, pTarget = nil");
	if not pTarget then
		return;
	end

	self.m_nTargetPos = pTarget:GetPos();
	self.m_nTargetRoad = pTarget:GetRoad();
end

---------------------------------------  BattleBulletCycle  ---------------------------------------
-- 回旋镖子弹
BattleBulletCycle = vclass("BattleBulletCycle", BattleBullet);

function BattleBulletCycle:initialize( )
	BattleBullet.initialize(self, prop);
	self.m_cycle = 1;									-- 1 正向运动 2 回旋中 3 负向运动  
	self.m_nImpactPos = 0;								-- 第一次碰撞点  
	self.m_nImpactTime = 0;							-- 第一次碰撞时间  
	self.m_fAccelerate = 0;								-- 加速度  
	self:SetMode(EUnitType.TYPE_BULLET_CYCLE);
end



-- @Param int, CBattle*
-- @Return void
function BattleBulletCycle:Update( time )
	-- 正向移动  
	if self.m_cycle == 1 then
		local nCurrentPos = self.m_nBeginPos + (time - self.m_nBeginTime) / gBattleView.msec_unit * self.m_prop.speed;
		nCurrentPos = math.floor(nCurrentPos);
		self:SetPos(nCurrentPos);

		-- 找到最近的怪物，造成伤害  
		local pTarget = nil;	--BattleCreature
		local target = self:ImpactAndDamage(self, self.m_pBattle);
		if target ~= -1 then
			pTarget = self.m_pBattle:GetCreature(not self:GetIsAttack(), target);
		end

		-- 碰撞到怪物或到达路的尽头  
		local nImpactPos = 0;
		if pTarget == nil then
			nImpactPos = gCRCLE_POS;
		else
			nImpactPos = nCurrentPos;
		end
		if nCurrentPos < nImpactPos then
			return;
		end
		-- cclog("### 1 id = %d,  self:GetPos() = %f, self:GetLastPos() = %f", self:GetId(), self:GetPos(), self:GetLastPos());

		self.m_cycle = 2;
		self.m_nImpactPos = nCurrentPos;
		self.m_nImpactTime = time;
		local s = 90 - self.m_nImpactPos;
		if s > 20 then
			s = 20;
		end
		self.m_fAccelerate = -math.pow(s, 2.0) / (2 * s);

		gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ROTATION, self);
		-- local accelerate = self.m_prop.speed * gBattleView.msec_unit * 2 / self.m_prop.cycle;
		-- local t = self.m_prop.cycle / 2;
		-- local endPos = self.m_nImpactPos + t * self.m_prop.speed / gBattleView.msec_unit - 0.5 * accelerate * math.pow(t / gBattleView.msec_unit, 2);
		-- if endPos >= self.m_pBattle:GetGround():GetLen() then
		-- 	endPos = self.m_pBattle:GetGround():GetLen();
		-- 	t = math.sqrt((endPos - self.m_nImpactPos) / accelerate);
		-- end
		-- cclog("**** nImpactPos = %f, endPos = %f", self.m_nImpactPos, endPos);
		-- gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_ROTATION, self, endPos- self.m_nImpactPos, t);

	-- 加速度阶段
	elseif self.m_cycle == 2 then
		-- cclog("### 2 id = %d,  self:GetPos() = %f, self:GetLastPos() = %f", self:GetId(), self:GetPos(), self:GetLastPos());

		-- local accelerate = self.m_prop.speed * gBattleView.msec_unit * 2 / self.m_prop.cycle;
		local t = time - self.m_nImpactTime;
		local nCurrentPos = self.m_nImpactPos + t * self.m_prop.speed / gBattleView.msec_unit - 0.5 * self.m_fAccelerate * math.pow(t / gBattleView.msec_unit, 2);
		nCurrentPos = math.floor(nCurrentPos);
		-- cclog("**** id = "..self:GetId()..", nCurrentPos = "..nCurrentPos..", m_nImpactPos = "..self.m_nImpactPos..", t = "..t..", m_prop.speed = "..self.m_prop.speed..", m_fAccelerate = "..self.m_fAccelerate..", math.pow = "..math.pow(t / gBattleView.msec_unit, 2));
		if nCurrentPos >= self.m_pBattle:GetGround():GetLen() then
			nCurrentPos = self.m_pBattle:GetGround():GetLen();
		end
		self:SetPos(nCurrentPos);

		-- 碰撞到怪物
		self:ImpactAndDamage(self, self.m_pBattle);

		local pos = self.m_nImpactPos + 20;
		if pos >= self.m_pBattle:GetGround():GetLen() then
			pos = self.m_pBattle:GetGround():GetLen();
		end

		if nCurrentPos < pos then
			-- cclog("### 3 id = %d,  self:GetPos() = %f, self:GetLastPos() = %f", self:GetId(), self:GetPos(), self:GetLastPos());
			return
		end

		self.m_cycle = 3;
		self.m_nImpactPos = nCurrentPos;
		self.m_nImpactTime = time;
		self:SetPos(nCurrentPos);

	-- 反向阶段
	elseif self.m_cycle == 3 then
		local nCurrentPos = self.m_nImpactPos - (time - self.m_nImpactTime) / gBattleView.msec_unit * self.m_prop.speed;
		nCurrentPos = math.floor(nCurrentPos);

		if nCurrentPos <= self.m_nBeginPos then
			nCurrentPos = self.m_nBeginPos;
		end
		self:SetPos(nCurrentPos);

		-- 碰撞到怪物  
		self:ImpactAndDamage(self, self.m_pBattle);

		if nCurrentPos > self.m_nBeginPos then
			return;
		end

		self.m_cycle = 0;
		self.m_nImpactPos = 0;
		self.m_nImpactTime = 0;
		self:SetPos(self.m_nBeginPos);
		self:SetValid(true);
	end
end