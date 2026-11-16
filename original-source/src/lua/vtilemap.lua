--vtilemap.lua

VTileMap = VClass("TileMap", VNode)
function VTileMap:onCreate(attr)
    return cc.TMXTiledMap:create(attr.tileName);
end

function VTileMap:Init(attr)
    VTileMap.super.Init(self, attr);

    local winSize = gWindow.size;
    local scalex = winSize.width/self.size.width;
    local scaley = winSize.height/self.size.height;
    self.minScale = math.min(scalex, scaley);
    self.maxScale = 1.5;
end

function VTileMap:on_touch(b)
	self:InitMultiTouchesListener();
end

function VTileMap:tilePosWithPoint(point)
    local tileSize = self:getTileSize();
    local mapSize = self:getMapSize();

    local stepHeight = point.y / tileSize.height;
    local stepWidth = (point.x - (mapSize.width * tileSize.width/2))/tileSize.width;
    local posX = -(stepHeight - stepWidth - mapSize.width);
    local posY = -(stepHeight + stepWidth - mapSize.height);

    posX = math.min(posX, mapSize.width-1);
    posX = math.max(posX, 0);
    posY = math.min(posY, mapSize.height-1);
    posY = math.max(posY, 0);
    return cc.p(math.modf(posX), math.modf(posY));
end

function VTileMap:test111(touch)
    local touchBegin = self:convertTouchToNodeSpace(touch);
    local pos = self:tilePosWithPoint(touchBegin);

    local tileLayer = self:getLayer("layer01");
    local tile = tileLayer:getTileAt(Var{pos.x, pos.y});
    if tile then
        tile:runAction(VAction{"rotateBy", 0.5, 360});
    end
end

function VTileMap:onTouchesBase(touches)
	local iter = VDataIter()
    while touches:Travel(iter) do
    	local touch = iter:Data();
    	if not self.touch1 then
    		self.touch1 = touch;
    		local touchBegin = self:getParent():convertTouchToNodeSpace(touch);
    		self.offset1 = cc.pSub(self.position, touchBegin);
    	elseif not self.touch2 then
    		self.touch2 = touch;
    		local touchBegin = self:getParent():convertTouchToNodeSpace(touch);
    		self.offset2 = cc.pSub(self.position, touchBegin);
            self:SaveOffset();
    	else
    		break;
    	end
    end
end

function VTileMap:applyFramelimits()
    local winSize = gWindow.size;
    local winRect = self:WinRect();
    local needSet = false;

    local posX = winRect.x;
    local posY = winRect.y;

    if self.scale < self.minScale then
        self:setScale(self.minScale);
    end

    if winRect.x > 0 then
        posX = 0;
        needSet = true;
    elseif winRect.x < winSize.width-winRect.width then
        posX = winSize.width-winRect.width;
        needSet = true;
    end

    if winRect.y > 0 then
        posY = 0;
        needSet = true;
    elseif winRect.y < winSize.height-winRect.height then
        posY = winSize.height-winRect.height;
        needSet = true;
    end

    if needSet then
        self:setWinPos(Var{posX, posY});
    end
end

function VTileMap:scaleToWithCenter(newScale, scaleCenter)
    local oldCenterPoint = cc.p(scaleCenter.x * self.scale, scaleCenter.y * self.scale);
    self:setScale(newScale);
    if newScale > self.maxScale then
        self:setScale(self.maxScale);
    end
    local newCenterPoint = cc.p(scaleCenter.x * self.scale, scaleCenter.y * self.scale);
    local centerPointDelta  = cc.pSub(oldCenterPoint, newCenterPoint);
    self.position = cc.pAdd(self.position, centerPointDelta);
end

function VTileMap:scaleWith2Touches(touch1, touch2)
	local point1 = touch1:getPreviousLocationInView();
	local point2 = touch2:getPreviousLocationInView();
	local preDistance = cc.pGetLength(cc.pSub(point1, point2));
	point1 = touch1:getLocationInView();
	point2 = touch2:getLocationInView();
	local newDistance = cc.pGetLength(cc.pSub(point1, point2));
	local relation = newDistance/preDistance;
	local newScale = self.scale * relation;

    point1 = self:convertTouchToNodeSpace(touch1);
    point2 = self:convertTouchToNodeSpace(touch2);
    local center = cc.pMidpoint(point1, point2);

    self:scaleToWithCenter(newScale, center);

    self:applyFramelimits();
end

function VTileMap:scaleWith2Touches1(touch1, touch2)
    local point1 = touch1:getPreviousLocationInView();
    local point2 = touch2:getLocationInView();
    local preDistance = cc.pGetLength(cc.pSub(point1, point2));
    point1 = touch1:getLocationInView();
    point2 = touch2:getLocationInView();
    local newDistance = cc.pGetLength(cc.pSub(point1, point2));
    local relation = newDistance/preDistance;
    local newScale = self.scale * relation;

    point1 = self:convertTouchToNodeSpace(touch1);
    point2 = self:convertTouchToNodeSpace(touch2);
    local center = cc.pMidpoint(point1, point2);

    self:scaleToWithCenter(newScale, center);

    self:applyFramelimits();
end

function VTileMap:onMovesBase(touches)
	local touch1 = nil;
	local touch2 = nil;
	local iter = VDataIter()
    while touches:Travel(iter) do
    	local touch = iter:Data();
    	if touch == self.touch1 then
    		touch1 = touch;
    	elseif touch == self.touch2 then
    		touch2 = touch;
    	end
    end

    if touch1 and touch2 then
    	self:scaleWith2Touches(touch1, touch2);
        local touchBegin = self:getParent():convertTouchToNodeSpace(touch1);
        self.offset1 = cc.pSub(self.position, touchBegin);
        touchBegin = self:getParent():convertTouchToNodeSpace(touch2);
        self.offset2 = cc.pSub(self.position, touchBegin);
	elseif touch1 then
		if self.touch2 then
            self:scaleWith2Touches1(touch1, self.touch2);
            local touchBegin = self:getParent():convertTouchToNodeSpace(touch1);
            self.offset1 = cc.pSub(self.position, touchBegin);
            touchBegin = self:getParent():convertTouchToNodeSpace(self.touch2);
            self.offset2 = cc.pSub(self.position, touchBegin);
		else
			if self.offset1 then
    			local location = self:getParent():convertTouchToNodeSpace(touch1);
    			self.position = cc.pAdd(location, self.offset1);
                self:applyFramelimits();
    		end
		end
	elseif touch2 then
		if self.touch1 then
			self:scaleWith2Touches1(touch2, self.touch1);
            local touchBegin = self:getParent():convertTouchToNodeSpace(touch2);
            self.offset2 = cc.pSub(self.position, touchBegin);
            touchBegin = self:getParent():convertTouchToNodeSpace(self.touch1);
            self.offset1 = cc.pSub(self.position, touchBegin);
		else
    		if self.offset2 then
    			local location = self:getParent():convertTouchToNodeSpace(touch2);
    			self.position = cc.pAdd(location, self.offset2);
                self:applyFramelimits();
    		end
		end
    end
end

function VTileMap:onLeavesBase(touches)
	local iter = VDataIter()
    while touches:Travel(iter) do
    	local touch = iter:Data();
    	if touch == self.touch1 then
    		self.touch1 = nil;
    		self.offset1 = nil;
    	elseif touch == self.touch2 then
    		self.touch2 = nil;
    		self.offset2 = nil;
    	end
    end
    self:SaveOffset();
end

function VTileMap:onCancelsBase(touches)
	self:onLeavesBase(touches);
end