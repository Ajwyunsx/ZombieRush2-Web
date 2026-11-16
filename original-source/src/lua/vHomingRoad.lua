----------------------------------------------------------------------
--自动寻路单步类
VShortestPathStep = vclass("ShortestPathStep");

function VShortestPathStep:initialize()
	self.GScore = 0;
	self.HScore = 0;
	self.parent =nil;
end

function VShortestPathStep:GetFScore( )
	return self.GScore + self.HScore;
end

function VShortestPathStep:InitWithPosition(point)
	self.pos = point;
end

function VShortestPathStep:isEqual(step)
	if step.pos.x == self.pos.x and step.pos.y == self.pos.y then
		return true;
	end 
	return false;
end

----------------------------------------------------------------------
--A星寻路类

VAStar = vclass("AStar");

function VAStar:initialize()
	self.shortestPaths = {};
	self.openArray = {};
	self.closeArray = {};
	self.AstarCoordInfo = {};
	self.mapSize = cc.p(0,0);
end


function VAStar:IsValidPos(point)
	local idx = (point.y-1)*(self.mapSize.y) + point.x;
	if self.AstarCoordInfo[idx] and self.AstarCoordInfo[idx].type == 1 then
		return true;
	end
	return false;
end



function VAStar:InsertInOpenArrays(step)
	table.insert(self.openArray,step);
	table.sort(self.openArray,
		function(a,b)
			return (a:GetFScore() < b:GetFScore());
		end
	);
end

function VAStar:ConstructShortestPath(step)
	repeat
		if step.parent ~= nil then
			table.insert(self.shortestPaths,1,step.pos);
		end
		step = step.parent;
	until step == nil;
end

function VAStar:endStar()
	self.openArray = {};
	self.closeArray = {};
	self.shortestPaths = {};
end

function VAStar:walkableAdjacentTilesCoordForTileCoord(point,tmp)
	local t = false;
	local l = false;
	local r = false;
	local b = false;

	--top
	local p = cc.p(point.x, point.y + 1);
	if self:IsValidPos(p) then
		table.insert(tmp,p);
		t = true;
	end

	--left
	p = cc.p(point.x - 1, point.y);
	if self:IsValidPos(p) then
		table.insert(tmp,p);
		l = true;
	end

	--right
	p = cc.p(point.x + 1, point.y);
	if self:IsValidPos(p) then
		table.insert(tmp,p);
		r = true;
	end

	--bottom
	p = cc.p(point.x, point.y - 1);
	if self:IsValidPos(p) then
		table.insert(tmp,p);
		b = true;
	end

	--top left
	p = cc.p(point.x - 1, point.y + 1);
	if t and l and self:IsValidPos(p) then
		table.insert(tmp,p);
		t = true;
	end

	--bottom left
	p = cc.p(point.x - 1, point.y - 1);
	if b and l and self:IsValidPos(p) then
		table.insert(tmp,p);
	end

	--top right
	p = cc.p(point.x + 1, point.y + 1);
	if t and r and self:IsValidPos(p) then
		table.insert(tmp,p);
	end

	--bottom right
	p = cc.p(point.x + 1, point.y - 1);
	if b and r and self:IsValidPos(p) then
		table.insert(tmp,p);
	end

end

function VAStar:ContainObject(array,st)
	if next(array) == nil then
		return false;
	end
	for i=1,table.getn(array) do
		if array[i]:isEqual(st) then
			return true;
		end
	end
	return false;
end


function VAStar:costToMoveFromStep(fromStep,toStep)
	return math.abs(toStep.pos.x - fromStep.pos.x) + math.abs(toStep.pos.y - fromStep.pos.y);
end

function VAStar:indexOfObject(array,st)
	if next(array) == nil then return -1 end
	for i=1,table.getn(array) do
		if array[i]:isEqual(st) then
			return i;
		end
	end
	return -1;
end

function VAStar:computeHScoreFromCoord(fromCoord,toCoord)
	return math.abs(toCoord.x - fromCoord.x) + math.abs(toCoord.y - fromCoord.y);
end




function VAStar:MoveToward(from,to)
	self.shortestPaths = {};

	if from.x == to.x and from.y == to.y then
		local path = {};
		table.insert(path,to);
		return path;
	end

	local step = VShortestPathStep:new();
	step:InitWithPosition(from);
	self:InsertInOpenArrays(step);

	repeat
		local curStep = self.openArray[1];
		table.insert(self.closeArray,curStep);
		table.remove(self.openArray,1);
		if curStep.pos.x == to.x and curStep.pos.y == to.y then
			self:ConstructShortestPath(curStep);
			local path = self.shortestPaths;
			self:endStar();
			return path;
		end

		local pointVec = {};
		self:walkableAdjacentTilesCoordForTileCoord(curStep.pos,pointVec);
		for i=1,table.getn(pointVec) do
			local st = VShortestPathStep:new();
			st:InitWithPosition(pointVec[i]);
			if self:ContainObject(self.closeArray,st) then
				st = nil;
			else
				local moveCost = self:costToMoveFromStep(curStep,st);
				local index = self:indexOfObject(self.openArray,st);
				if index == -1 then
					st.parent = curStep;
					st.GScore = curStep.GScore + moveCost;
					st.HScore = self:computeHScoreFromCoord(st.pos,to);
					self:InsertInOpenArrays(st);
				else
					local openst = self.openArray[index];
					if curStep.GScore + moveCost < openst.GScore then
						st.parent = curStep;
						st.GScore = curStep.GScore + moveCost;
						table.remove(self.openArray,index);
                        self:InsertInOpenArrays(st);
					end
				end
			end
		end
	until table.getn(self.openArray) <= 0;
	self:endStar();
end

-----------------------------------------------------------------------------
---地图类

VHLMap = vclass("HLMap");

function VHLMap:initialize()
	self.AstarCoordInfo = {};
	self.validCoordInfo = {};
	self.realPos = {};
	self:InitCoordInfo();
end


function VHLMap:InitCoordInfo()
 	local csv_hr = gData:loadCsvWithName("homingRoad.csv");
 	local csv_hrc = gData:loadCsvWithName("homingRoadCoord.csv");
	self.mapSize = cc.p(csv_hr:lineCount(),csv_hr:rowCount(0)-1);
	for h=1,self.mapSize.x do
		for w=1,self.mapSize.y do
			local coordInfo = {};
			coordInfo.point = cc.p(w,h);
			coordInfo.type = csv_hr:lineData(h-1,w);
            local key = (h-1)*(self.mapSize.y) + w;
            local pData = csv_hrc:lineDataWithKey(key);
            if not pData then 
            	break;
            end
            coordInfo.realPoint = cc.p(pData[1],pData[2]);
			if coordInfo.type == 1 then
				table.insert(self.validCoordInfo,coordInfo);
			end
			table.insert(self.AstarCoordInfo,coordInfo);
		end
	end
end


function VHLMap:getRandPos()
	local count = table.getn(self.validCoordInfo);
	local index = math.random(1,count);
	local to = self.validCoordInfo[index].point;
	return to;
end

function VHLMap:getRealPos(p)
	local pos = {};
	local idx = (p.y-1)*(self.mapSize.y) + p.x;
	return self.AstarCoordInfo[idx].realPoint;
end

