--vBattleCondition.lua

-- @Param float, int, float
-- @Return bool
local function OP( x, op, y )
	-- 1 大于等于  2 等于 3 小于等于  
	if op == 1 and x >= y then
		return true;
	elseif op == 2 and x == y then
		return true;
	elseif op == 3 and x <= y then
		return true;
	else
		return false;
	end

	return false;
end

---------------------------------------  BattleConditionMgr  ---------------------------------------

BattleConditionMgr = vclass("BattleConditionMgr");

function BattleConditionMgr:initialize( )
	self.m_conditions = {};				-- map<int, CBattleBaseCondition*>
end

-- @Param 
-- @Return bool
function BattleConditionMgr:Create( )
	self.m_conditions[EBattleCondition.BATTLE_CONDITION_STATUS] = BattleConditionStatus:new();
	self.m_conditions[EBattleCondition.BATTLE_CONDITION_ATTR] = BattleConditionAttr:new();
	self.m_conditions[EBattleCondition.BATTLE_CONDITION_PROBABILITY] = BattleConditionProbability:new();

	return true;
end

-- @Param 
-- @Return 
function BattleConditionMgr:Close( )
	self.m_conditions = {};
end

-- @Param CBattleUnit*, vector<int>&
-- @Return bool
function BattleConditionMgr:Check( pBattle, pSelf, conditions )
	for i,v in ipairs(conditions) do
		local pConditionProp = gBattleResource:GetCondition(v);
		if pConditionProp ~= nil then
			local pCondition = gBattleConditionMgr:GetCondition(pConditionProp.expressionId);
			if pCondition ~= nil then
				if not pCondition:Check(pBattle, pSelf, pConditionProp.params) then
					return false;
				end
			end
		end
	end

	return true;
end

-- @Param int
-- @Return BattleBaseCondition
function BattleConditionMgr:GetCondition( id )
	assert(id >= 0 , "BattleConditionMgr:GetCondition() Error id < 0");
	assert(id < EBattleCondition.BATTLE_CONDITION_MAX , "BattleConditionMgr:GetCondition() Error id > EFFECT_MAX");

	return self.m_conditions[id];
end

---------------------------------------  BattleBaseCondition  ---------------------------------------

BattleBaseCondition = vclass("BattleBaseCondition");

function BattleBaseCondition:initialize( )

end

-- @Param CBattleUnit*, vector<int>&
-- @Return bool
function BattleBaseCondition:Check( pBattle, pSelf, params )
	-- todo
end

---------------------------------------  BattleConditionStatus  ---------------------------------------
-- 检查状态
BattleConditionStatus = vclass("BattleConditionStatus", BattleBaseCondition);

function BattleConditionStatus:initialize( )

end

-- @Param CBattleUnit*, vector<int>&
-- @Return bool
function BattleConditionStatus:Check( pBattle, pSelf, params )
	if not pSelf:isInstanceOf(BattleCreature) then 
		cclog("**** BattleConditionStatus:Check Error");
		return false;
	end

	return OP(pSelf:GetStatus(params[1]), params[2], params[3]);
end

---------------------------------------  BattleConditionAttr  ---------------------------------------
-- 检查属性
BattleConditionAttr = vclass("BattleConditionAttr", BattleBaseCondition);

function BattleConditionAttr:initialize( )

end

-- @Param CBattleUnit*, vector<int>&
-- @Return bool
function BattleConditionAttr:Check( pBattle, pSelf, params )
	if not pSelf:isInstanceOf(BattleCreature) then 
		cclog("**** BattleConditionAttr:Check Error");
		return false;
	end

	-- 当前属性值
	local attr = 0;
	if params[1] == ECreatureAttr.CREATURE_ATTR_LIFE then
		attr = pSelf:GetHp();
	else
		attr = pSelf:GetAttr(params[1]);
	end

	-- 原始属性值
	local pBaseProp = nil;
	if pSelf:GetIsAttack() then
		pBaseProp = gBattleResource:GetMonsterProp(pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ID));
	else
		pBaseProp = gBattleResource:GetPlantProp(pSelf:GetAttr(ECreatureAttr.CREATURE_ATTR_ID));
	end

	return OP(attr, params[2], pBaseProp:GetAttr(params[1]) * params[3] / 100);
end

---------------------------------------  BattleConditionProbability  ---------------------------------------
-- 检查概率
BattleConditionProbability = vclass("BattleConditionProbability", BattleBaseCondition);

function BattleConditionProbability:initialize( )

end

-- @Param CBattleUnit*, vector<int>&
-- @Return bool
function BattleConditionProbability:Check( pBattle, pSelf, params )
	local random = pBattle:GetRandom(1, 100);
	return random <= params[1];
end