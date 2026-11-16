
VHomingRoadAmt = VClass("HomingRoadAmt",VArmature);

function VHomingRoadAmt:setSpeedAndScale(speed, scale)
	self.aSpeed = speed;
	self.aScale = scale;
end

function VHomingRoadAmt:Run( map, p)
	self.maxY = 1350;
	self.map = map;
	self.as = VAStar:new();
	self.as.AstarCoordInfo = map.AstarCoordInfo;
	self.as.mapSize = map.mapSize;
	self.path = {};
	self:MovetoNext(p);
	self.level = self.maxY - self:getPositionY();
	self:StartTimer("onTimer");
end


function VHomingRoadAmt:onTimer()
	local curY = self.maxY - self:getPositionY();
	if curY ~= self.Level then
		self.level = curY;
	end
end


--怪物移动到下一个点 递归
function VHomingRoadAmt:MovetoNext(from)
	if not self.path[1] then
		local to = self.map:getRandPos();
		if to.x == from.x and to.y == from.y then
			self:RunAction{{self,"AmtIdle"},{"delayTime",10},{self,"MovetoNext", from}};
		else

			self.path = self.as:MoveToward(from,to);
			if not self.path then self.path = {} end;

			local model = math.random(10);
			if model > 5 then 
				self:RunAction{{self,"AmtIdle"},{"delayTime",10},{self,"AmtWalk"},{self,"MovetoNext", from}};
			else
				self:RunAction{{self,"AmtWalk"},{self,"MovetoNext", from}};
			end
		end
	else
		local cpx = self:getPositionX();
		local cpy = self:getPositionY();
		local nextPos = self.path[1];
		local p = self.map:getRealPos(nextPos);
		table.remove(self.path,1);
		
		local l = math.sqrt(math.pow((p.x - cpx),2) + math.pow((p.y - cpy),2));
		local t = l/self.aSpeed;
		if cpx < p.x then
            self:RunAction{{"scaleTo",0,-(self.aScale),(self.aScale)},{"moveTo",t,p.x, p.y},{self,"MovetoNext",nextPos}};
		else
            self:RunAction{{"scaleTo",0,(self.aScale),(self.aScale)},{"moveTo",t,p.x, p.y},{self,"MovetoNext",nextPos}};
		end
	end
end

function VHomingRoadAmt:AmtIdle( )
	self:play("idle");
end

function VHomingRoadAmt:AmtWalk( )
	self:play("walk");
end



