--vBattleGround.lua

-- @Param bool, set<int>, vector<BattleCreature>, Battle*
-- @Return void
local function FilterCreatures( bAttack, src, pBattle, des )
	if not pBattle then return; end
	for k,pCreature in pairs(src) do
		if pCreature and pCreature.m_mode == EUnitType.TYPE_CREATURE then
			if pCreature.m_bValid and pCreature.m_status[ECreatureStatus.CREATURE_STATUS_STEALTH] == 0 then
				des[k] = pCreature;
			end
		end
	end
end

local function CopyCreatures( src, des )
	for key,value in pairs(src) do
		table.insert(des, value);
	end
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
---------------------------------------  PositionData  ---------------------------------------
PositionData = vclass("PositionData");

function PositionData:initialize( )
	self.road = 0;
	self.pos = 0;
end

---------------------------------------  BattleRoad  ---------------------------------------
BattleRoad = vclass("BattleRoad");

function BattleRoad:initialize( )
	self.m_bValid = false;				
	self.m_pBattle = nil;
	self.m_attackers = {};			-- <set<int>>
	self.m_defenders = {};			-- <set<int>>
	self.m_attackObjects = {};		-- <set<int>>
	self.m_defendObjects = {};		-- <set<int>>
end

-- @Param int, Battle*
-- @Return Bool
function BattleRoad:Create( len, pBattle )
	self.m_bValid = true;
	self.m_pBattle = pBattle;
	return true;
end

-- @Param
-- @Return void
function BattleRoad:Close( )
	-- body
end

-- @Param
-- @Return bool
function BattleRoad:GetValid( )
	return self.m_bValid;
end

-- @Param bool
-- @Return void
function BattleRoad:SetValid( val )
	self.m_bValid = val;
end


-- @Param bool, int, int
-- @Return void
function BattleRoad:AddCreature( bAttack, battleCreature )
	if bAttack then
		self.m_attackers[battleCreature:GetId()] = battleCreature;
	else
		self.m_defenders[battleCreature:GetId()] = battleCreature;
	end
end

-- @Param bool, int, int
-- @Return void
function BattleRoad:DelCreature( bAttack, id )
	if bAttack then
		self.m_attackers[id] = nil;
	else
		self.m_defenders[id] = nil;
	end
end

-- @Param bool, int, int
-- @Return void
function BattleRoad:AddObject( bAttack, id )
	if bAttack then
		self.m_attackObjects[id] = id;
	else
		self.m_defendObjects[id] = id;
	end
end

-- @Param bool, int, int
-- @Return void
function BattleRoad:DelObject( bAttack, id )
	if bAttack then
		if self.m_attackObjects[id] then
			self.m_attackObjects[id] = nil;
		end
	else
		if self.m_defendObjects[id] then
			self.m_defendObjects[id] = nil;
		end
	end
end

-- @Param bool, int, int
-- @Return vector
function BattleRoad:GetCreature( bAttack, desCreature )
	if bAttack then
		FilterCreatures(bAttack, self.m_attackers, self.m_pBattle, desCreature);
	else
		FilterCreatures(bAttack, self.m_defenders, self.m_pBattle, desCreature);
	end
end

-- @Param bool, int, set<int>&
-- @Return void
function BattleRoad:GetAllCreature( bAttack, desCreatures )
	if bAttack then
		CopyCreatures(self.m_attackers, desCreatures);
	else
		CopyCreatures(self.m_defenders, desCreatures);
	end
end

---------------------------------------  BattleGround  ---------------------------------------

BattleGround = vclass("BattleGround");

function BattleGround:initialize( )
	self.m_len = 0;						-- int
	self.m_pBattle = nil					-- CBattle*
	self.m_roads = {};					-- map<CBattleRoad*>
	self.m_roadPosAddPlantCount = {};	--map<int,map<int,int>> 记录每个位置上添加的植物数量
end

---------------------------------------  public  ---------------------------------------

-- @Param int, set<int>&, Battle*
-- @Return void
function BattleGround:Create( nRoadLen, roads, pBattle )
	self.m_len = nRoadLen;
	self.m_pBattle = pBattle;
	
	for k,v in pairs(roads) do
		local pRoad = BattleRoad:new();
		self.m_roads[v] = pRoad;

		if not pRoad:Create(self.m_len, self.m_pBattle) then
			return false;
		end
	end

	return true;
end

-- @Param
-- @Return void
function BattleGround:Close( )
	for k,v in pairs(self.m_roads) do
		v = nil;
	end
	self.m_roads = {};
end

-- @Param 
-- @Return int
function BattleGround:GetLen( )
	return self.m_len;
end

-- @Param 
-- @Return int
function BattleGround:GetWid( )
	return #self.m_roads;
end

-- @Param int
-- @Return bool
function BattleGround:HasRoad( road )
	if self.m_roads[road] then
		return true;
	else
		return false;
	end
end

-- @Param int, int, CBattleUnit*
-- @Return bool
function BattleGround:AddUnit( road, pos, pUnit )
	if not pUnit then
		return false;
	end

	-- 检查路径
	if self.m_roads[road] == nil then
		return false;
	end

	-- 检查长度
	if pos < 0 or pos > self.m_len then
		return false;
	end

	if pUnit:GetMode() == EUnitType.TYPE_CREATURE then
		self.m_roads[road]:AddCreature(pUnit:GetIsAttack(), pUnit);
		if not pUnit:GetIsAttack() then
			if self.m_roadPosAddPlantCount[road] == nil then
				self.m_roadPosAddPlantCount[road] = {};
			end
			if self.m_roadPosAddPlantCount[road][pos] == nil then
				self.m_roadPosAddPlantCount[road][pos] = 0;
			end
			self.m_roadPosAddPlantCount[road][pos] = self.m_roadPosAddPlantCount[road][pos] + 1;
			if self.m_roadPosAddPlantCount[road][pos] > 1 then
				gBattleView:addEventData(EBattleLogEvent.LOG_EVENT_RESET_PLANT);
			end
		end
	elseif pUnit:GetMode() == EUnitType.TYPE_CREATURE_OBJECT then 
		self.m_roads[road]:AddObject(pUnit:GetIsAttack(), pUnit:GetId());
	end

	pUnit:SetRoad(road);
	pUnit:SetPos(pos);

	return true;
end

-- @Param CBattleUnit* 
-- @Return void
function BattleGround:DelUnit( pUnit )
	if pUnit == nil then
		return;
	end

	local road = pUnit:GetRoad();
	local pos = pUnit:GetPos();

	if self.m_roads[pUnit:GetRoad()] == nil then
		return;
	end

	if pUnit:GetMode() == EUnitType.TYPE_CREATURE then
		self.m_roads[pUnit:GetRoad()]:DelCreature(pUnit:GetIsAttack(), pUnit:GetId());
	elseif pUnit:GetMode() == EUnitType.TYPE_CREATURE_OBJECT then 
		self.m_roads[pUnit:GetRoad()]:DelObject(pUnit:GetIsAttack(), pUnit:GetId());
	end
	-- pUnit:_ClearPostion();
end

-- @Param bool, int
-- @Return set<int>&
function BattleGround:GetCreatureByRoad( bAttack, road, desCreature )
	if self.m_roads[road] == nil then
		return;
	end
	self.m_roads[road]:GetCreature(bAttack, desCreature);
end

-- @Param bool, PositionData&, int, int, int, int
-- @Return vector<BattleCreature>
function BattleGround:GetRangeCreatures( bAttack, position, nRoadDiff, nPosMin, nPosMax, nMagicValid, desCreatures )
	if position.pos == -1 or position.road == -1 then
		cclog("BattleGround:GetRangeCreatures Warning, road = %d, pos = %d", position.road, position.road);
		return;
	end
	-- 遍历路
	for i=(position.road - nRoadDiff), (position.road + nRoadDiff) do
		if self.m_pBattle:GetGround():HasRoad(i) then
			-- 遍历路上的怪物
			local tmp = {};
			self.m_pBattle:GetGround():GetCreatureByRoad(bAttack, i, tmp);
			for k,pEnemy in pairsByKeys(tmp) do
				-- 在伤害范围内
				if Hit(position.pos + nPosMin, position.pos + nPosMax, pEnemy) then
					-- cclog("******* nMagicValid = %d, MAGIC_INV = %d", nMagicValid, pEnemy:GetStatus(ECreatureStatus.CREATURE_STATUS_MAGIC_INV));
					if nMagicValid ~= 0 and pEnemy:GetStatus(ECreatureStatus.CREATURE_STATUS_MAGIC_INV) ~= 0 then
						-- continue
					else
						table.insert(desCreatures, pEnemy);
					end
				end
			end
		end
	end
end

-- @Param void
-- @Return int
function BattleGround:GetReplantPlantCount()
	local iCount = 0;
	for road, roadInfo in pairs(self.m_roadPosAddPlantCount) do
		for pos, number in pairs(roadInfo) do
			iCount = iCount + number - 1;
		end
	end
	return iCount;
end
---------------------------------------  private  ---------------------------------------

-- @Param 
-- @Return vector
function BattleGround:GetRoads( )
	return self.m_roads;
end

