--vBuildingSprite.lua

VBuildingSprite = VClass("BuildingSprite", VLayer)

function VBuildingSprite:Init(attr)
	VLayer.Init(self, attr);

	local buildingName = "";
	local buildingOffset = {0,0};
	if self.buildingType == BUILDING_TYPE.BuildingStore then
		buildingName = "金库";
		self.armatureImage = VImage{image="building_store.png", layout="Center"}
		self:Push(self.armatureImage);
	elseif self.buildingType == BUILDING_TYPE.BuildingLaboratory then
		buildingName = "研究所";
		self.armature = VArmature:createArmature("laboratoryBuilding", "", "Center", 0, 0);
		self.armature:play("Action0")
		self:Push(self.armature);
	elseif self.buildingType == BUILDING_TYPE.BuildingBasecamp then
		buildingName = "庄园";
		buildingOffset = {-50,0};
		self.armature = VArmature:createArmature("houseBuilding", "", "Center", 0, 0);
		self.armature:play("Action0")
		self:Push(self.armature);
	elseif self.buildingType == BUILDING_TYPE.BuildingAltar then
		buildingName = "太阳神庙";
		self.armature = VArmature:createArmature("altarBuilding", "", "Center", 0, 0);
		self.armature:play("Action0")
		self:Push(self.armature);
	end
end

function VBuildingSprite:onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
	if self.buildingType == BUILDING_TYPE.BuildingStore then
		if evt == "barrackFinish" then
			if self.needStopAnimation then
				self.armature:stop();
				self.animationing = false;
			end
		end
	end
end

function VBuildingSprite:showChoosedAnimation()
	self:closeChoosedAnimation();
	if not self.animationArrow then
		self.animationArrow = VImage{name = "imgArrow", layout = "Up", image = "xuanzhongjiantouda.png", offset={0,-80}};
		self:Push(self.animationArrow);
		if self.buildingType == BUILDING_TYPE.BuildingStore then
			self.animationArrow.scale = 0.599;
		end
	end

	self.animationArrow:RunAction{"repeatForever", {"sequence", {"moveBy", 0.3, 0, 15}, {"moveBy", 0.3, 0, -15}}}
	self.animationArrow.visible = true;
	self:RunAction{{"scaleTo",0.1, self.fscale}, {"scaleTo",0.1, self.scale}};
	--金库木有骨骼动画
	if self.armature ~= nil then
		self.armature:RunAction{"repeat", -1, {"sequence", {"tintTo", 0.65, 150, 150, 150}, {"tintTo", 0.65, 255, 255, 255}}};
	end

	if self.armatureImage ~= nil then
		self.armatureImage:RunAction{"repeat", -1, {"sequence", {"tintTo", 0.65, 150, 150, 150}, {"tintTo", 0.65, 255, 255, 255}}};
	end
end

function VBuildingSprite:closeChoosedAnimation()
	if self.animationArrow then
		self.animationArrow:stopAllActions();
		self.animationArrow:ReLayout();
		self.animationArrow.visible = false;
		--金库木有骨骼动画
		if self.armature ~= nil then
			self.armature:stopAllActions();
			self.armature.color = {255, 255, 255};
		end

		if self.armatureImage ~= nil then
			self.armatureImage:stopAllActions();
			self.armatureImage.color = {255, 255, 255};
		end
	end
end

function VBuildingSprite:didChoosed()
	-- if self.buildingType == BUILDING_TYPE.BuildingStore then
	-- 	if not self.animationing then
	-- 		self.armature:play("Action0");
	-- 		self.animationing = true;
	-- 	end
	-- 	self.needStopAnimation = false;
	-- end
		self:showChoosedAnimation();
end

function VBuildingSprite:didUnChoose()
	-- if self.buildingType == BUILDING_TYPE.BuildingStore then
	-- 	self.needStopAnimation = true;
	-- end
		self:closeChoosedAnimation();
end

function VBuildingSprite:loadUserInfo(userInfo)
	self.userInfo = userInfo;
	self:refreshTitle();
	self:checkLevelUp();
end

function VBuildingSprite:refreshTitle()
	-- local levelString = "";
	-- if self.buildingType == BUILDING_TYPE.BuildingBarracks then
	-- 	local barracksInfo = self.userInfo.manorInfo.barracks;
	-- 	levelString = barracksInfo.level;
	-- elseif self.buildingType == BUILDING_TYPE.BuildingArmycamp then
	-- 	local armCampInfo = self.userInfo.manorInfo.armCamp;
	-- 	levelString = armCampInfo.level;
	-- elseif self.buildingType == BUILDING_TYPE.BuildingLaboratory then
	-- 	local laboratory = self.userInfo.manorInfo.laboratory
	-- 	levelString = laboratory.level;
	-- elseif self.buildingType == BUILDING_TYPE.BuildingBasecamp then
	-- 	local baseCampInfo = self.userInfo.manorInfo.baseCampInfo;
	-- 	levelString = baseCampInfo.level;
	-- end

	-- self.levelText.text = levelString.."级";
end

function VBuildingSprite:checkClick(touch)
	if self:IsInRect(touch) then
		local func = VUiCheckFunction(self, "onClick");
        if func then
            func(self, touch, self:getView());
            func = VUiCheckFunction(self, "onClickAudio");
            if func then
                func(self, touch);
            end
            return _VTouchType.Building;
        end
	end
	return false;
end

function VBuildingSprite:IsInRectLua(touch)
	if self.buildingType == BUILDING_TYPE.BuildingBasecamp then
		local location = self:convertTouchToNodeSpace(touch);
		local size = self.size;
		local rect = cc.rect(0, 0, size.width-80, size.height);
		if cc.rectContainsPoint(rect, location) then
			return true;
		end
		return false;
	end
	return
end

function VBuildingSprite:checkLevelUp(isFinish)
	gLog("VBuildingSprite:checkLevelUp");
	if self.userInfo.isSelf and self.buildingType then
		local levelUpTime = self.userInfo.manorInfo:levelUpTime(self.buildingType, LEVELUP_TYPE.LevelupBuilding);
		if levelUpTime > 0 then
			self:startLevelUpTimer(levelUpTime);
			self:showUpProgress(levelUpTime);
			self.upgradeTimer:startTimer();
			gLog("VBuildingSprite:checkLevelUp levelUpTime ="..levelUpTime);
		else
			-- local levelUpInfo = self.userInfo.manorInfo:levelUpInfo(self.buildingType, LEVELUP_TYPE.LevelupBuilding);
			-- if levelUpInfo then
			-- 	local currentLevel = 0;
			-- 	local buildingInfo = nil;
			-- 	if self.buildingType == BUILDING_TYPE.BuildingBarracks then
			-- 		local barracksInfo = self.userInfo.manorInfo.barracks;
			-- 		currentLevel = barracksInfo.level;
			-- 		buildingInfo = barracksInfo;
			-- 	elseif self.buildingType == BUILDING_TYPE.BuildingArmycamp then
			-- 		local armCampInfo = self.userInfo.manorInfo.armCamp;
			-- 		currentLevel = armCampInfo.level;
			-- 		buildingInfo = armCampInfo;
			-- 	elseif self.buildingType == BUILDING_TYPE.BuildingLaboratory then
			-- 		local laboratory = self.userInfo.manorInfo.laboratory
			-- 		currentLevel = laboratory.level;
			-- 		buildingInfo = laboratory;
			-- 	elseif self.buildingType == BUILDING_TYPE.BuildingBasecamp then
			-- 		local baseCampInfo = self.userInfo.manorInfo.baseCampInfo;
			-- 		currentLevel = baseCampInfo.level;
			-- 		buildingInfo = baseCampInfo;
			-- 	end
			-- 	if levelUpInfo.level > currentLevel then
			-- 		buildingInfo.nextLevel = levelUpInfo.level;
			-- 		self:buildingUpFinish();
			-- 	end
			-- end
			gLog("VBuildingSprite:checkLevelUp closeUpProgress");
			self:stopLevelUpTimer();
			self:closeUpProgress();
			if isFinish then
				self:buildingUpFinishEarly();
			end
		end
		self:refreshTitle();
	else
		gLog("VBuildingSprite:checkLevelUp closeUpProgress 22222");
		self:stopLevelUpTimer();
		self:closeUpProgress();
	end
end

function VBuildingSprite:showUpProgress(levelUpTime)
	gLog("VBuildingSprite showUpProgress"..tostring("levelUpTime"));
	local maxTime = 0;
	local scaleSize = 2.2;
	local offsetC = {0, 0};
	if self.buildingType == BUILDING_TYPE.BuildingStore then
		local storeInfo = self.userInfo.manorInfo.storeInfo;
		maxTime = storeInfo.upgradeTime;
		scaleSize = 1.32;
		offsetC = {0, -18}
	elseif self.buildingType == BUILDING_TYPE.BuildingLaboratory then
		local laboratory = self.userInfo.manorInfo.laboratory;
		maxTime = laboratory.upgradeTime;
	elseif self.buildingType == BUILDING_TYPE.BuildingBasecamp then
		local baseCampInfo = self.userInfo.manorInfo.baseCampInfo;
		maxTime = baseCampInfo.upgradeTime;
	elseif self.buildingType == BUILDING_TYPE.BuildingAltar then
		local altarInfo = self.userInfo.manorInfo.altarInfo;
		maxTime = altarInfo.upgradeTime;
	end
	self.maxUpgradeTime = maxTime;

	if not self.upgradeTimer then
		self.upgradeTimer = VUpgradeTimer{name = "txNextTime", layout = "Center", bgImage = "jianzhujindutiaodi.png", image = "jianzhujingdutiao.png",
										 fontSize=16, scale = scaleSize, offset=offsetC};
		self:Push(self.upgradeTimer);
	end
	self.upgradeTimer.visible = true;
	self.upgradeTimer:setTimer(levelUpTime, maxTime);
end

function VBuildingSprite:closeUpProgress()
	gLog("VBuildingSprite closeUpProgress");
	if self.upgradeTimer then
		self.upgradeTimer:stopTimer();
		self.upgradeTimer.visible = false;
	end
end

function VBuildingSprite:startLevelUpTimer(time)
	self:StartTimer("buildingUpFinish", time, 0, 0);
end

function VBuildingSprite:stopLevelUpTimer(time)
	self:StopTimer("buildingUpFinish");
end

function VBuildingSprite:buildingUpFinish()
	self:closeUpProgress();
	self:levelUpFinishAnimation();
	if self.buildingType == BUILDING_TYPE.BuildingAltar then
		local altarInfo = gData.userInfo.manorInfo.altarInfo;
		altarInfo:levelUpFinish(self.userInfo.isSelf);
	elseif self.buildingType == BUILDING_TYPE.BuildingStore then
		local storeInfo = gData.userInfo.manorInfo.storeInfo;
		storeInfo:levelUpFinish(self.userInfo.isSelf);
	elseif self.buildingType == BUILDING_TYPE.BuildingLaboratory then
		local laboratory = gData.userInfo.manorInfo.laboratory;
		laboratory:levelUpFinish(self.userInfo.isSelf);
	elseif self.buildingType == BUILDING_TYPE.BuildingBasecamp then
		local baseCampInfo = gData.userInfo.manorInfo.baseCampInfo;
		baseCampInfo:levelUpFinish(self.userInfo.isSelf);
	end

	if self.maxUpgradeTime and self.maxUpgradeTime < 5 then
		gData.userInfo.roleInfo:stopHeartBeatSynTimer(AttrType.AttrTypeExp, 5);
		gData.userInfo.roleInfo:stopHeartBeatSynTimer(AttrType.AttrTypeLevel, 5);
	end
	self.maxUpgradeTime = nil;
	gData.userInfo.manorInfo:checkWorkingFarmer();
	self:refreshTitle();
	

	if gMainView then
		local layOperation = gMainView("layOperation")
	    if layOperation.visible ~= 0 and layOperation.tab == self.buildingType then
	        layOperation:closeLayer()
	    end
	end
end

function VBuildingSprite:buildingUpFinishEarly()
	self:levelUpFinishAnimation();
	self:refreshTitle();

	if gMainView then
		local layOperation = gMainView("layOperation")
	    if layOperation.visible ~= 0 and layOperation.tab == self.buildingType then
	        layOperation:closeLayer()
	    end

	    if self.buildingType == BUILDING_TYPE.BuildingArmycamp then
			local armCampInfo = gData.userInfo.manorInfo.armCamp;
			armCampInfo:checkPoplation();
		end
	end
end

function VBuildingSprite:levelUpFinishAnimation()
	if not self.LevelUpAmature then
		self.LevelUpAmature = VArmature:createArmature("buildingUpdateAnimation", "", "Center", 0, 0);
		if self.buildingType == BUILDING_TYPE.BuildingAltar then
			self.LevelUpAmature.offsetP={0.15, -0.1};
		elseif self.buildingType == BUILDING_TYPE.BuildingStore then
			self.LevelUpAmature.offsetP={0.15, -0.27};
			self.LevelUpAmature.scale = 0.70;
		elseif self.buildingType == BUILDING_TYPE.BuildingLaboratory then
			self.LevelUpAmature.offsetP={0.12, -0.1};
		elseif self.buildingType == BUILDING_TYPE.BuildingBasecamp then
			self.LevelUpAmature.offsetP={0.08, -0.1};
		end
		self:Push(self.LevelUpAmature);	
	end
	self.LevelUpAmature:play("update", nil, 0);

	-- local exp = 0;
	-- if self.buildingType == BUILDING_TYPE.BuildingStore then
	-- 	local storeInfo = gData.userInfo.manorInfo.storeInfo;
	-- 	exp = storeInfo.userExp;
	-- elseif self.buildingType == BUILDING_TYPE.BuildingArmycamp then
	-- 	local armCampInfo = gData.userInfo.manorInfo.armCamp;
	-- 	exp = armCampInfo.userExp;

	-- elseif self.buildingType == BUILDING_TYPE.BuildingLaboratory then
	-- 	local laboratory = gData.userInfo.manorInfo.laboratory;
	-- 	exp = laboratory.userExp;
	-- elseif self.buildingType == BUILDING_TYPE.BuildingBasecamp then
	-- 	local baseCampInfo = gData.userInfo.manorInfo.baseCampInfo;
	-- 	exp = baseCampInfo.userExp;
	-- end
	-- exp = "Exp+"..exp;
	-- local aText = VText{text=exp, fontSize=30, color={43,222,27}, layout="Center", offset={0, 20}};
 --    aText:RunAction{{"hide"},{"delayTime",0.1},{"show"},{"moveBy",2,0,30},{"delete"}};
 --    self:Push(aText);
end

function VBuildingSprite:isLevelOping()
	return self.isLevelOpreation;
end

function VBuildingSprite:setLevelOpreation(isOp)
	local t = "false";
	if isOp then t = "ture" end
	gLog("setLevelOpreation"..t);
	self.isLevelOpreation = isOp;
	if isOp then
        self:StartTimer("levelOpreationTimeOut", 20, 0);
    else
        self:StopTimer("levelOpreationTimeOut");
    end
end

function VBuildingSprite:levelOpreationTimeOut()
    self.isLevelOpreation = false;
end