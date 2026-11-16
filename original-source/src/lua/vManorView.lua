--vManorView.lua

require "vBuildingSprite"

VManorView = VClass("ManorView", VScrollLayer)

function VManorView:Init(attr)
	VManorView.super.Init(self, attr);
	self:NeedEvent(Eff_onEnter);
    self.maxScale = 1;
    self:setScale(self.minScale*1.4);
end

function VManorView:onPush()
    self.btnVaults = self("btnVaults");
	self.btnAltar = self("btnAltar");
	self.btnCollege = self("btnCollege");
	self.btnBaseCamp = self("btnBaseCamp");
	self.farmLayer = self("farmLayer");
	self.layerBanner = self("layerBanner");
end

function VManorView:onPushFinishBase(parameters)
--    self.farmLayer:SetMap(self.userInfo);
end

function VManorView:onForeground()
	self.farmLayer:onForeground();
end

function VManorView:loadUserInfo(userInfo)
	self.userInfo = userInfo;
	self.farmLayer:SetMap(self.userInfo);

	self.btnVaults:loadUserInfo(userInfo);
	self.btnAltar:loadUserInfo(userInfo);
	self.btnCollege:loadUserInfo(userInfo);
	self.btnBaseCamp:loadUserInfo(userInfo);
end

function VManorView:buttonWithType(buildingType)
	local button = nil;
    if buildingType == BUILDING_TYPE.BuildingStore then
		button = self.btnVaults;
	elseif buildingType == BUILDING_TYPE.BuildingAltar then
		button = self.btnAltar;
	elseif buildingType == BUILDING_TYPE.BuildingLaboratory then
		button = self.btnCollege;
	elseif buildingType == BUILDING_TYPE.BuildingBasecamp then
		button = self.btnBaseCamp;
	end
	return button;
end

function VManorView:didChoosed(target, iType)
	if not iType then
		self.layerBanner:didChoosed();
	elseif iType == LEVELUP_TYPE.LevelupBuilding then
		local builing = self:buttonWithType(target);
		if builing then
			builing:didChoosed();
		end
	elseif iType == LEVELUP_TYPE.LevelupPlant then
		self.farmLayer:didChoosed(target);
	end
end

function VManorView:didUnChoose(target, iType)
	if not iType then 
		self.layerBanner:didUnChoose();
	elseif iType == LEVELUP_TYPE.LevelupBuilding then
		local builing = self:buttonWithType(target);
		if builing then
			builing:didUnChoose();
		end
	elseif iType == LEVELUP_TYPE.LevelupPlant then
		self.farmLayer:didUnChoose(target);
	end
end

function VManorView:refreshBuilding(buildingType, isFinish)
	local builing = self:buttonWithType(buildingType);
	if builing then
		builing:checkLevelUp(isFinish);
	end
end

function VManorView:setLevelOpreation(buildingType, isOp)
	local builing = self:buttonWithType(buildingType);
	gLog("setLevelOpreation   "..buildingType);
	if builing then
		gLog("buttonWithType   2");
		builing:setLevelOpreation(isOp);
	end
end

function VManorView:isLevelOping(buildingType)
	local builing = self:buttonWithType(buildingType);
	if builing then
		return builing:isLevelOping(isOp);
	end
	return false;
end

function VManorView:RecoverChange(manorScrRect, winDesRect, manorScale)
--    local focus = self:convertToNodeSpace(cc.p(winDesRect.x, winDesRect.y));
    cclog("windowX"..gWindow.size.width.."windowY"..gWindow.size.height)
    local focus = self:convertToNodeSpace(cc.p(gWindow.size.width / 2, gWindow.size.height / 2));
    
    cclog("manorScale:"..manorScale)
    cclog("focus:"..self.minScale.."~~~~~~~~~~~~~~~"..self.maxScale)
    
    if manorScale == -1 then
        manorScale = self.minScale--math.max(gWindow.size.width / self:getContentSize().width, gWindow.size.height / self:getContentSize().height)
    elseif manorScale == -2 then
        manorScale = self.maxScale
    elseif manorScale == -3 then
        manorScale = self.minScale * 1.4
    elseif manorScale > self.maxScale then
        manorScale = self.maxScale
    elseif manorScale < self.minScale then
        manorScale = self.minScale
    end

    cclog("gwin:"..gWindow.size.width..","..gWindow.size.height.."~~~~~~~~~~self:"..self:getContentSize().width..","..self:getContentSize().height.."~~~~~~~~~~~~self.scale:"..self.scale)
    cclog("focus"..manorScale.."~~~~~~~~~~~~~~~"..manorScale)
    
    local pos = self:convertToWorldSpace(cc.p(0,0))
    local posX, posY = pos.x, pos.y --self:getPosition()
    
    local moveX = focus.x * self.scale - manorScrRect.x * manorScale * gView():getScaleX()
    local moveY = focus.y * self.scale - manorScrRect.y * manorScale * gView():getScaleY()
    
    local desX = math.min(posX + moveX, 0)
    local desY = math.min(posY + moveY, 0)
    
    self:RunAction{{"spawn", {"moveTo", 1, desX, desY}, {"scaleTo", 1, manorScale, manorScale}}}
end

function VManorView:SetTrainingScene(manorScrRect, winDesRect, manorScale)    
    if manorScale == -1 then
        manorScale = self.minScale
    elseif manorScale == -2 then
        manorScale = self.maxScale
    elseif manorScale == -3 then
        manorScale = self.minScale * 1.4
    elseif manorScale > self.maxScale then
        manorScale = self.maxScale
    elseif manorScale < self.minScale then
        manorScale = self.minScale
    end
        
    
    local moveToX = 400 - manorScrRect.x * 1.54 * manorScale 
    local moveToY = 240 - manorScrRect.y * 1.54 * manorScale
    
    local desX = math.min(moveToX, 0)
    local desY = math.min(moveToY, 0)
    self:StopAction()
    self:RunAction{"sequence", {"spawn", {"scaleTo", 1, manorScale, manorScale}, {"moveTo", 1, desX, desY}}, {gView()("trainingLayer"), "SetbackGround"}}
end

function VManorView:SetMove(bl)
    self.moveEnable = bl;
end

function VManorView:onClickTouchEnd(touch)
	local touchType = nil;
	if not touchType then
		touchType = self.btnVaults:checkClick(touch);
	end
	if not touchType then
		touchType = self.btnAltar:checkClick(touch);
	end
	if not touchType then
		touchType = self.btnCollege:checkClick(touch);
	end
	if not touchType then
		touchType = self.btnBaseCamp:checkClick(touch);
	end
	if not touchType then
		touchType = self.farmLayer:checkClick(touch);
	end

	if not touchType then
		touchType = self.layerBanner:checkClick(touch);
	end

	if not touchType then
		touchType = _VTouchType.Block;
	end
	
	if gMainView then
		gMainView:manorViewTouched(touchType);
	end
end
