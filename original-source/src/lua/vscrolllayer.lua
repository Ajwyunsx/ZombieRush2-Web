--vscrolllayer.lua
--自定义滑动控件，用于农场主界面。
VScrollLayer = VClass("ScrollLayer", VLayer)

function VScrollLayer:Init(attr)
	VLayer.Init(self, attr);
    self.minMovePx = 8;
	self.anchor = cc.p(0.0, 0.0);
    local gViewScaleX = 1.0;
    local gViewScaleY = 1.0;
    --获取当前view的scale值。
    if gView() then
        gViewScaleX = gView():getScaleX();
        gViewScaleY = gView():getScaleY();
    end

    --根据当前窗口大小 和 自己的大小，计算最小scale
	local winSize = gWindow.size;
    local scalex = winSize.width/(self.size.width * gViewScaleX);
    local scaley = winSize.height/(self.size.height * gViewScaleY);
    self.minScale = math.max(scalex, scaley);
    self.maxScale = 1.5;
    self.touch = true;
    self.move = true;
    self.moveEnable = true;
    self.scrollDistance = cc.p(0,0);    --惯性移动的距离，X,Y轴上
    self.scrollDeaccelRate = 0.9;       --惯性递减速度
end

function VScrollLayer:on_touch(b)
	self:InitMultiTouchesListener();
end

--处理touches begin 时间
--同一时间只处理2个touch
function VScrollLayer:onTouchesBase(touches)                            
	local iter = VDataIter()
    while touches:Travel(iter) do
        self._touched = true;
        self.scrollDistance = cc.p(0,0);
    	local touch = iter:Data();
    	if not self.touch1 then
            -- gLog("begin touch1 id %d ", touch:getId());
    		self.touch1 = touch;
    		local touchBegin = self:getParent():convertTouchToNodeSpace(touch);
            self.touchBegin1 = touchBegin;--记住点击位置
    		self.offset1 = cc.pSub(self.position, touchBegin);--记住点击位置和自己锚点位置 的距离。
    	elseif not self.touch2 then
            -- gLog("begin touch2 id %d ", touch:getId());
    		self.touch2 = touch;
    		local touchBegin = self:getParent():convertTouchToNodeSpace(touch);
            self.touchBegin2 = touchBegin;
    		self.offset2 = cc.pSub(self.position, touchBegin);
            self:SaveOffset(true);
    	else
    		break;
    	end
    end
    self._winpos = self:getWinPos(-1);
end

--边界判断
function VScrollLayer:applyFramelimits()
    local winSize = gWindow.size;
    local winRect = self:WinRect();
    local needSet = false;

    local posX = winRect.x;
    local posY = winRect.y;
    local direct = 0;

    if self.scale < self.minScale then
        self:setScale(self.minScale);
    end

    if winRect.x > 0 then
        posX = 0;
        needSet = true;
        direct = 1;
    elseif winRect.x < winSize.width-winRect.width then
        posX = winSize.width-winRect.width;
        needSet = true;
        direct = 1;
    end

    if winRect.y > 0 then
        posY = 0;
        needSet = true;
        direct = 2;
    elseif winRect.y < winSize.height-winRect.height then
        posY = winSize.height-winRect.height;
        needSet = true;
        direct = 2;
    end

    if needSet then
        self:setWinPos(Var{posX, posY}, 1, true);
    end
    return needSet, direct;
end

--以某个点为中心，进行缩放。
function VScrollLayer:scaleToWithCenter(newScale, scaleCenter)
    local oldCenterPoint = cc.p(scaleCenter.x * self.scale, scaleCenter.y * self.scale);
    self:setScale(newScale);
    if newScale > self.maxScale then
        self:setScale(self.maxScale);
    end
    local newCenterPoint = cc.p(scaleCenter.x * self.scale, scaleCenter.y * self.scale);
    local centerPointDelta  = cc.pSub(oldCenterPoint, newCenterPoint);
    self.position = cc.pAdd(self.position, centerPointDelta);
end
--两个touch同时移动时缩放。
function VScrollLayer:scaleWith2Touches(touch1, touch2)
	local point1 = touch1:getPreviousLocationInView();
	local point2 = touch2:getPreviousLocationInView();
	local preDistance = cc.pGetLength(cc.pSub(point1, point2));
	point1 = touch1:getLocationInView();
	point2 = touch2:getLocationInView();
	local newDistance = cc.pGetLength(cc.pSub(point1, point2));    --两个touch移动的距离
	local relation = newDistance/preDistance;      --距离差
	local newScale = self.scale * relation;        --新的缩放比

    point1 = self:convertTouchToNodeSpace(touch1);
    point2 = self:convertTouchToNodeSpace(touch2);
    local center = cc.pMidpoint(point1, point2);    --中心点

    self:scaleToWithCenter(newScale, center);

    self:applyFramelimits();
end

--一个touch移动，一个touch未动时，缩放。
function VScrollLayer:scaleWith2Touches1(touch1, touch2)
    local point1 = touch1:getPreviousLocationInView();
    local point2 = touch2:getLocationInView();--取touch事件当前值。
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

--touches move 事件。
function VScrollLayer:onMovesBase(touches)
	local touch1 = nil;
	local touch2 = nil;
	self.moving = true;
    if not self.moveEnable then
        return;
    end
    local iter = VDataIter()
    while touches:Travel(iter) do
    	local touch = iter:Data();
    	if touch == self.touch1 then
            -- gLog("move touch1 id %d ", touch:getId());
    		touch1 = touch;
    	elseif touch == self.touch2 then
            -- gLog("move touch2 id %d ", touch:getId());
    		touch2 = touch;
        else
            -- gLog("unkonw move touch id %d ", touch:getId());
    	end
    end

    if touch1 and touch2 then
    	self:scaleWith2Touches(touch1, touch2);
        local touchBegin = self:getParent():convertTouchToNodeSpace(touch1);
        self.offset1 = cc.pSub(self.position, touchBegin);
        touchBegin = self:getParent():convertTouchToNodeSpace(touch2);
        self.offset2 = cc.pSub(self.position, touchBegin);
	elseif touch1 then--只有一个touch move
		if self.touch2 then--另外一个touch 是否存在， 如果存在，则是缩放。
            self:scaleWith2Touches1(touch1, self.touch2);
            local touchBegin = self:getParent():convertTouchToNodeSpace(touch1);
            self.offset1 = cc.pSub(self.position, touchBegin);
            touchBegin = self:getParent():convertTouchToNodeSpace(self.touch2);
            self.offset2 = cc.pSub(self.position, touchBegin);
		else--如果不存在，则是移动
			if self.offset1 then
    			local location = self:getParent():convertTouchToNodeSpace(touch1);
                local pos = cc.pSub(location, self.touchBegin1);
                if math.abs(pos.y) < self.minMovePx and math.abs(pos.x) < self.minMovePx then
                    --touche begin的点 和 touche move的点 相差小于5 认为没有移动。
                else
                    local oldPosition = self.position;
                    self.position = cc.pAdd(location, self.offset1);
                    self:applyFramelimits();
                    self.scrollDistance = cc.pSub(self.position, oldPosition);
                end
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
                local pos = cc.pSub(location, self.touchBegin2);
                if math.abs(pos.y) < self.minMovePx and math.abs(pos.x) < self.minMovePx then

                else
                    local oldPosition = self.position;
                    self.position = cc.pAdd(location, self.offset2);
                    self:applyFramelimits();
                    self.scrollDistance = cc.pSub(self.position, oldPosition);
                end
    		end
		end
    end
end

--touches end 事件
function VScrollLayer:onLeavesBase(touches)
	local iter = VDataIter()
    while touches:Travel(iter) do
        self._touched = false;
    	local touch = iter:Data();
    	if touch == self.touch1 then
            -- gLog("end touch1 id %d ", touch:getId());
    		self.touch1 = nil;
    		self.offset1 = nil;
    		if not self.moving then--如果没有移动，则是 单击
    			self:onClickTouchEnd(touch);
            else--如果移动，则 判断移动距离是否超过5个像素
                local location = self:getParent():convertTouchToNodeSpace(touch);
                local pos = cc.pSub(location, self.touchBegin1);
                if math.abs(pos.y) < self.minMovePx and math.abs(pos.x) < self.minMovePx then
                    self:onClickTouchEnd(touch);
                else
                    self:StartTimer("deaccelerateScrolling")--开始 惯性滑动。
                end
    		end
    	elseif touch == self.touch2 then
            -- gLog("end touch2 id %d ", touch:getId());
    		self.touch2 = nil;
    		self.offset2 = nil;
            if self.moving then
                local location = self:getParent():convertTouchToNodeSpace(touch);
                local pos = cc.pSub(location, self.touchBegin2);
                if math.abs(pos.y) < self.minMovePx and math.abs(pos.x) < self.minMovePx then

                else
                    self:StartTimer("deaccelerateScrolling")
                end 
            end
        else
            if self.touch2 and (self.touch2:getId() > 2 or self.touch2:getId() < 0) then
                self.touch2 = nil;
                self.offset2 = nil;    
            end
            -- gLog("unkonw touche %d ", touch:getId());
    	end
    end
    if self.moving then
        self:SaveOffset(true);--一旦移动了，就要保存offset的属性值。
    end
    self.moving = false;
end

function VScrollLayer:onCancelsBase(touches)
	self:onLeavesBase(touches);
end

function VScrollLayer:onClickTouchEnd(touch)
	
end

function VScrollLayer:deaccelerateScrolling()
    if self._touched then
        self:StopTimer("deaccelerateScrolling");
    end

    self.position = cc.pAdd(self.position, self.scrollDistance);
    self.scrollDistance = cc.pMul(self.scrollDistance, self.scrollDeaccelRate);

    local needReset, direct = self:applyFramelimits();
    if needReset then
        if direct == 1 then--如果某个方向超出界限，该方向移动值置0。
            self.scrollDistance.x = 0;
        elseif direct == 2 then
            self.scrollDistance.y = 0;
        end
    end
    --移动距离小于0，则停止移动
    if (math.abs(self.scrollDistance.x) <= 1.0 and math.abs(self.scrollDistance.y) <= 1.0) then
        self:StopTimer("deaccelerateScrolling");
    end
end
