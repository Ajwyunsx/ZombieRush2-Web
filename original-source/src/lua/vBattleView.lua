--VBattleView.lua
require "vBattleCommon"
require "vBattleSpriteCommon"
require "vBattleResultDlg"

VBattleView = VClass("BattleView", VView)

local local_bit = gBit;

--------------------------------------------    Vui Function    --------------------------------------------

function VBattleView:Init( attr )
	VView.Init(self, attr);
	if gWindow.needAction then
		self.pushAction = nil;
	end
	self.runFps = 50;
	gDtr:setAnimationInterval(1.0 / self.runFps);
end

function VBattleView:onPush()
	gOpenBattleLog = (gServerIndex == 0);
	-- gOpenBattleLog = true;

	if gBattleScaleTest then
		self:openScaleTest();
	end
	
	gBattleViewTest = false;
	-- cclog("*******VBattleView on push");
	-- gDtr :setAnimationInterval(1.0 / 50);

	gBattleView = self;
	self.battleInfo = nil;
	self:setInstanceData();

	self.imgSunshineFrame = self("imgSunshineFrame");
	self.textSunshine = self("textSunshine");
	self.imgSunshine = self("imgSunshine");

	self.imgDefUser = self("imgDefUser");
	self.textDefVip = self("textDefVip");
	self.textDefName = self("textDefName");
	self.textDefLevel = self("textDefLevel");
	self.atkUserLayer = self("atkUserLayer");
	self.imgAtkUser = self("imgAtkUser");
	self.textAtkVip = self("textAtkVip");
	self.textAtkName = self("textAtkName");
	self.textAtkLevel = self("textAtkLevel");

	self.imgResultTitleLeft = self("imgResultTitleLeft");
	self.imgResultTitleRight = self("imgResultTitleRight");

	self.textTips = self("textTips");
	self.textTime = self("textTime");
	self.textSearchTime = self("textSearchTime");
	self.textNotEnoughSun = self("textNotEnoughSun");
	self.textSpoilsSun = self("textSpoilsSun");
	self.textSpoilsGold = self("textSpoilsGold");
	self.textGetSun = self("textGetSun");
	self.textGetGold = self("textGetGold");
	self.textGetObj = self("textGetObj");
	self.imgDefSunSlot = self("imgDefSunSlot");
	self.imgDefGoldSlot = self("imgDefGoldSlot");
	self.imgAtkSunSlot = self("imgAtkSunSlot");
	self.imgAtkGoldSlot = self("imgAtkGoldSlot");
	self.imgDefFlag = self("imgDefFlag");
	self.imgAtkFlag = self("imgAtkFlag");
	self.textDefFlag = self("textDefFlag");
	self.textAtkFlag = self("textAtkFlag");
	self.textDefFlag2 = self("textDefFlag2");
	self.textAtkFlag2 = self("textAtkFlag2");

	self.touchTipsText = self("touchTipsText");
	self.touchMonsterLightImage = self("touchMonsterLightImage");
	self.touchPlantLightImage = self("touchPlantLightImage");
	self.monsterTable = self("monsterTable");
	self.monsterTable.delegate = self;
	self.detailMonsterTable = self("detailMonsterTable");
	self.detailMonsterTable.delegate = self;
	self.detailMonsterLayer = self("detailMonsterLayer");

	self.battleBackupImage = self("battleBackupImage");
	self.backupCard = self("backupCard");
	self.backupIcon = self("backupIcon");
	self.backupCount = self("backupCount");
	self.backupCost = self("backupCost");
	self.backupLevelText = self("backupLevelText");
	self.backupSelect = self("backupSelect");
	self.backupFlash = self("backupFlash");
	self.backupArrow = self("backupArrow");

	self.groundLayer = self("groundLayer");
	self.battleLayer = self("battleLayer");
	self.sunshineLayer = self("sunshineLayer");
	self.btnClose = self("btnClose");
	self.btnUpRightClose = self("btnUpRightClose");
	self.btnPass = self("btnPass");
	self.btnSpeed = self("btnSpeed");
	self.btnShovel = self("btnShovel");
	self.textSpeed = self("textSpeed");
	self.imgBattleTitle = self("imgBattleTitle");
	self.imgWaveZombieTitle = self("imgWaveZombieTitle");
	self.animationTouchLayer = self("animationTouchLayer");
	self.DaveArmature= self("DaveArmature");
	self.battleTalkingFrame = self("battleTalkingFrame");
	self.imgRevivePoint = self("imgRevivePoint");
	self.textReviveNum = self("textReviveNum");

	gAudio:setEffectsVolume(gAudio:getEffectsVolume() * 0.8);
	gAudio:setMusicVolume(gAudio:getMusicVolume() * 0.8);
end

function VBattleView:onPushFinish( )

end

function VBattleView:onShow()
	-- cclog("*******VBattleView on show")
	-- todo
end

function VBattleView:onHide()
	-- cclog("*******VBattleView on hide")
	-- todo
end

function VBattleView:onPop()
	-- cclog("*******VBattleView on pop")
	gDtr:getScheduler():setTimeScale(1.0);
end

function VBattleView:onPopFinish( )
	-- cclog("*******VBattleView on onPopFinish")
	gBattleView = nil;
end

function VBattleView:onKeyBack()
	if not self.isShowBattleView then
		return false;
	end

	if self.isShowConfirmTip then
		gWindow:closeConfirmtip();
		self.isShowConfirmTip = false;
	else
		if self.battleInfo then
			if self.battleInfo.playType == EBattlePlayType.PlayAttack then
				if not self.isStartBattle then
					if not self.isCloseingBattle then
						self:exitBattle();
					end
				else
					self:closeBtnClick();
				end
			else
				self:closeBattle();
			end
		else
			return false;
		end
	end

	return true;
end

function VBattleView:onForeground()
	if gAudio:getMusicOff() == 1 and gAudio:isMusicPlaying() then
		gAudio:pauseMusic();
	end
end

--------------------------------------------    View Function    --------------------------------------------

function VBattleView:showBattleView( )
	-- 预加载战场骨骼动画资源
	self:preloadBattleSpriteRes();
	-- 清空精灵
	self:cleanAllSprite();

	-- 刷新用户面板
	self:setUserView();

	-- 刷新时间
	self:refreshTimeView();

	-- 刷新田地
	self:setFarmView();

	-- 刷新植物
	self:setPlantView();

	-- 刷新按钮其他信息
	self:setOtherInfoView();

	-- 刷新掠夺数值
	self:setSpoilsView();

	-- 刷新星星
	self:setStarsView();
	
	-- 刷新人口数
	self:setPopTextView();

	-- 刷新怪物列表
	self:setMonsterTableView();

	-- 刷新关卡援军
	self:setSupportView();

	-- 刷新出兵点
	self:setAttackPlace();

	-- 刷新终点宝箱
	self:setFinalSpoilBox();

	-- 刷新阳光
	self:setSunshineView();

	-- 刷新提示语
	self:setTipsText();

	-- 刷新植物摆放点
	self:setDefendPlace();

	-- 打开云朵
	self:finishShowBattleViewAndOpenCloud();
end

-- 清空精灵
function VBattleView:cleanAllSprite( )
	for k,v in pairs(self.BulletList) do
		v:deleteSprite();
		v = nil;
	end
	self.BulletList = {};

	for k,v in pairs(self.PlantList) do
		v:deleteSprite();
		v = nil;
	end
	self.PlantList = {};
	
	for k,v in pairs(self.MonsterList) do
		v:deleteSprite();
		v = nil;
	end
	self.MonsterList = {};

	for k,v in pairs(self.ObjectList) do
		v:deleteSprite();
		v = nil;
	end
	self.ObjectList = {};

	for k,v in pairs(self.SpoilBoxList) do
		v:deleteSprite();
		v = nil;
	end
	self.SpoilBoxList = {};
	self.openBoxList = {};

	for k,v in pairs(self.SunshineList) do
		v:deleteSprite();
		v = nil;
	end
	self.SunshineList = {};

	for k,v in pairs(self.DropItemList) do
		v:deleteSprite();
		v = nil;
	end
	self.DropItemList = {};
end

-- 刷新用户面板
function VBattleView:setUserView( )
	self.imgDefUser:setHead(self.battleInfo.defender.userid, self.battleInfo.defender.image, nil);
	self.imgDefUser:SetHeadImageShader("mv_zhezhao.png");
	self.textDefVip.text = "VIP"..self.battleInfo.defender.vipInfo[0];
	self.textDefName.text = self.battleInfo.defender.nick;
	if self.battleInfo.defender.level then
		self.textDefLevel.text = "Lv"..tostring(self.battleInfo.defender.level);
	else
		self.textDefLevel.visible = 0;
	end

	self.imgAtkUser:setHead(self.battleInfo.attacker.userid, self.battleInfo.attacker.image, nil);
	self.imgAtkUser:SetHeadImageShader("mv_zhezhao.png");
	self.textAtkVip.text = "VIP"..self.battleInfo.attacker.vipInfo[0];
	self.textAtkName.text = self.battleInfo.attacker.nick;
	if self.battleInfo.attacker.level then
		self.textAtkLevel.text = "Lv"..tostring(self.battleInfo.attacker.level);
	else
		self.textAtkLevel.visible = 0;
	end

	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		self.imgAtkUser.image = "NPCHeadImage.png";
	elseif self.battleInfo.attackType == BattleType.BattleTypePve then
		self.imgDefUser.image = "NPCHeadImage.png";
	end

	if self.battleInfo.attackType ~= BattleType.BattleTypeEvp then
		self.imgSunshine:setTexture("battleSunDark.png");
	end

	if self.battleInfo.attacker_banner and self.battleInfo.attacker_banner.attackAttr then
		self.imgAtkFlag.visible = 1;
		self.textAtkFlag.visible = 1;
		self.textAtkFlag2.visible = 1;

		local flagImage = "battleFlag"..self.battleInfo.attacker_banner:getImage();
		if flagImage then
			self.imgAtkFlag.image = flagImage;
		end

		local csvDatas = gData:readCsv("banner_level.csv");
		local data = csvDatas:lineDataWithKey(self.battleInfo.attacker_banner.attackAttr.level);
		if data then
			self.textAtkFlag.text = "+"..data.addition.."%";
			self.textAtkFlag2.text = "+"..data.addition.."%";
		end
	else
		self.imgAtkFlag.visible = 0;
		self.textAtkFlag.visible = 0;
		self.textAtkFlag2.visible = 0;
	end

	if self.battleInfo.defender_banner and self.battleInfo.defender_banner.attackAttr then
		self.imgDefFlag.visible = 1;
		self.textDefFlag.visible = 1;
		self.textDefFlag2.visible = 1;

		local flagImage = "battleFlag"..self.battleInfo.defender_banner:getImage();
		if flagImage then
			self.imgDefFlag.image = flagImage;
		end

		local csvDatas = gData:readCsv("banner_level.csv");
		local data = csvDatas:lineDataWithKey(self.battleInfo.defender_banner.attackAttr.level);
		if data then
			self.textDefFlag.text = "+"..data.addition.."%";
			self.textDefFlag2.text = "+"..data.addition.."%";
		end
	else
		self.imgDefFlag.visible = 0;
		self.textDefFlag.visible = 0;
		self.textDefFlag2.visible = 0;
	end	
end

-- 显示攻方信息
function VBattleView:showAttackerInfoView( )
	if gData:briefCache(self.battleInfo.attacker.userid) then
		local dlg = VNode("vVisitDlg.vui");
		dlg.info = gData:briefCache(self.battleInfo.attacker.userid);
		dlg:HideOtherInfo();
		gView():Push(dlg);
	end
end

-- 显示守方信息
function VBattleView:showDefenderInfoView( )
	if gData:briefCache(self.battleInfo.defender.userid) then
		local dlg = VNode("vVisitDlg.vui");
		dlg.info = gData:briefCache(self.battleInfo.defender.userid);
		dlg:HideOtherInfo();
		gView():Push(dlg);
	end
end

-- 刷新按钮其他信息
function VBattleView:setOtherInfoView( )
	if self.battleInfo.playType == EBattlePlayType.PlayObserve then
		self:setDaveAnimation(true);

		self.btnSpeed.visible = 0;
		self.btnPass.visible = 0;
		self.btnClose.visible = 0;
		self.btnUpRightClose.visible = 1;
	else
		self:setDaveAnimation(false);
	
		self.btnClose.visible = 1;
		self.btnUpRightClose.visible = 0;
		self.btnSpeed.visible = 1;
		self.textSpeed.text = "x"..self.battleSpeed;
		if self.battleInfo.playType == EBattlePlayType.PlayReplay then
			-- self.btnClose.text = "返回庄园";
			self.btnPass.visible = 0;
		else
			self.btnPass.visible = 0;
		end

		if self.battleInfo.attackType == BattleType.BattleTypeEvp then
			self.btnShovel.visible = 1;
		else
			self.btnShovel.visible = 0;
		end
	end
end

function VBattleView:setDaveAnimation( isShow )
	if isShow then
		local curTime = gData:currentTime();
		local reviveCount = 0;
		for i,monster in pairs(gData.userInfo.monsterInfo.monsterInfos) do
			if monster.reTime > curTime then
				reviveCount = reviveCount + 1;
			end
		end
		if reviveCount > 0 then
			self.imgRevivePoint.visible = 1;
		else
			self.imgRevivePoint.visible = 0;
		end
		self.textReviveNum.text = reviveCount;

		self.DaveArmature:play("say");
		self.DaveArmature.visible = 1;
		self.battleTalkingFrame.visible = 1;
	else
		self.DaveArmature:stop();
		self.DaveArmature.visible = 0;
		self.battleTalkingFrame.visible = 0;		
	end
end

-- 刷新掠夺数值
function VBattleView:setSpoilsView( )
	self.textSpoilsSun.text = self.battleInfo.spoils.sunshine;
	self.textSpoilsGold.text = self.battleInfo.spoils.gold;

	self.textGetSun.text = self.battleInfo.spoils.spoilsSunshine;
	self.textGetGold.text = self.battleInfo.spoils.spoilsGold;
	self.textGetObj.text = self.battleInfo.spoils.spoilsItemCount;

	self.imgDefSunSlot:setAnchorPoint(cc.p(0,0.5));
	self.imgDefSunSlot.maxScale = 0.5;
	self.imgDefSunSlot.maxValue = self.battleInfo.spoils.sunshine;
	self:setSpoilsSlotImg(self.imgDefSunSlot, self.battleInfo.spoils.sunshine);

	self.imgDefGoldSlot:setAnchorPoint(cc.p(0,0.5));
	self.imgDefGoldSlot.maxScale = 0.5;
	self.imgDefGoldSlot.maxValue = self.battleInfo.spoils.gold;
	self:setSpoilsSlotImg(self.imgDefGoldSlot, self.battleInfo.spoils.gold);

	self.imgAtkSunSlot:setAnchorPoint(cc.p(0,0.5));
	self.imgAtkSunSlot.maxScale = 0.4;
	self.imgAtkSunSlot.maxValue = self.battleInfo.spoils.sunshine;
	self:setSpoilsSlotImg(self.imgAtkSunSlot, self.battleInfo.spoils.spoilsSunshine);
	
	self.imgAtkGoldSlot:setAnchorPoint(cc.p(0,0.5));
	self.imgAtkGoldSlot.maxScale = 0.4;
	self.imgAtkGoldSlot.maxValue = self.battleInfo.spoils.gold;
	self:setSpoilsSlotImg(self.imgAtkGoldSlot, self.battleInfo.spoils.spoilsGold);
end

function VBattleView:showSpoilsViewAnimation( isAnimation )
	self:setResourceTextView(self.textSpoilsSun, self.battleInfo.spoils.sunshine, isAnimation);
	self:setResourceTextView(self.textSpoilsGold, self.battleInfo.spoils.gold, isAnimation);

	self:setResourceTextView(self.textGetSun, self.battleInfo.spoils.spoilsSunshine, isAnimation);
	self:setResourceTextView(self.textGetGold, self.battleInfo.spoils.spoilsGold, isAnimation);
	self:setResourceTextView(self.textGetObj, self.battleInfo.spoils.spoilsItemCount, isAnimation);

	self:setSpoilsSlotImg(self.imgDefSunSlot, self.battleInfo.spoils.sunshine, true);
	self:setSpoilsSlotImg(self.imgDefGoldSlot, self.battleInfo.spoils.gold, true);

	self:setSpoilsSlotImg(self.imgAtkSunSlot, self.battleInfo.spoils.spoilsSunshine, true);
	self:setSpoilsSlotImg(self.imgAtkGoldSlot, self.battleInfo.spoils.spoilsGold, true);
end

function VBattleView:setSpoilsSlotImg( imgNode, value, isAnimation )
	if imgNode.maxValue <= 0 then
		if isAnimation then
			imgNode:RunAction{{"scaleTo", 2, 0, 1}};
		else
			imgNode.scale = 0;
		end
	else
		local xValue = value / imgNode.maxValue * imgNode.maxScale;
		if xValue > imgNode.maxScale then
			xValue = imgNode.maxScale;
		end
		if isAnimation then
			local allTime = 4;
			local animationTime = xValue * allTime;
			imgNode:RunAction{{"scaleTo", animationTime, xValue, 1}};
		else
			imgNode:setScaleX(xValue);
			imgNode:setScaleY(1);
		end
	end
end

function VBattleView:setResourceTextView( textNode, resourceData, isAnimation )
	if resourceData then
		if isAnimation then
			textNode:changeNumAnimation(resourceData);
		else
			textNode.text = resourceData;
		end
	end
end

-- 刷新星星
function VBattleView:setStarsView( )
	for i=1,3 do
		if i > self.battleInfo.stars then
			self("imgStar"..i).visible = 0;
		else
			self("imgStar"..i).visible = 1;
		end
	end
end

-- 刷新阳光数值
function VBattleView:setSunshineView( )
	if self.battle then
		self.textSunshine.text = self.battle:GetSunshineValue();
	else
		self.textSunshine.text = "";
	end

	-- self:checkBattleUnitCostIndex();

	for i=0,self.monsterTable.number-1 do
		self.monsterTable:updateCellAtIndex(i);
	end

	self:updateSupportViewWithCost();
end

function VBattleView:showAddSunshineAnimation( sunshine )
	local sunCount = getMapCount(self.sunshineAnimationList);
	local sunSize = self.imgSunshineFrame:getContentSize();
	local sunshineNumText = self.imgSunshineFrame:Push(VText{text="+"..sunshine.value, color={245,210,6}, fontSize=24, opacity=0});
	sunshineNumText:setAnchorPoint(cc.p(0,0.5));
	sunshineNumText:setPosition(sunSize.width * 0.4, self.textSunshine:getPositionY() - sunshineNumText:getContentSize().height);
	sunshineNumText:RunAction{{"delayTime", sunCount*0.3}, {"fadeTo", 0, 255}, {"moveBy", 0.8, 0, sunSize.height}, {"fadeTo", 0.5, 0}, {function(node) VBattleView.finishSunshineAnimation(node, sunshine) end}};

	self.sunshineAnimationList[sunshine.mId] = sunshineNumText;
end

function VBattleView.finishSunshineAnimation( node, sunshine )
	if gBattleView then
		local sunshineNumText = gBattleView.sunshineAnimationList[sunshine.mId];
		if sunshineNumText then
			sunshineNumText:Delete();
		end

		gBattleView.sunshineAnimationList[sunshine.mId] = nil;
	end
end

function VBattleView:showSunshineTips( tipsString )
	self.textNotEnoughSun.text = tipsString;
	self.textNotEnoughSun:RunAction{{"fadeTo", 0, 255}, {"scaleTo", 0, 1, 1}, {"show"}, {"scaleTo", 0.1, 1.4, 1.4}, {"scaleTo", 0.1, 1, 1}, {"delayTime", 0.6}, {"fadeTo", 0.5, 0}, {"hide"}};
end

function VBattleView:checkBattleUnitCostIndex( )
	if self.battleInfo.playType == EBattlePlayType.PlayObserve then
		return;
	end

	local isSupport = false;
	if self.selectCreature == -1 then
		if self.battleInfo.supportList and getMapCount(self.battleInfo.supportList) > 0 then
			local isSupport = true;
			for k,v in pairs(self.battleInfo.supportList) do
				if v.prop.cost > self.battle:GetSunshineValue() then
					self.selectCreature = 1;
					break;
				end
			end
		else
			self.selectCreature = 1;
		end
	end

	local checkNextUnit = false;
	local battleUnit = self.battleInfo.battleUnitList[self.selectCreature];
	if not battleUnit then
		return;
	end
	
	local prop = battleUnit.childUnit[#battleUnit.childUnit];
	if prop then
		if prop.cost > self.battle:GetSunshineValue() or battleUnit.unitCount <= 0 then
			checkNextUnit = true;
		end
	end

	if checkNextUnit then
		for i=self.selectCreature+1,self.monsterTable.number do
			local battleUnit = self.battleInfo.battleUnitList[i];
			local prop = battleUnit.childUnit[#battleUnit.childUnit];
			if prop then
				if prop.cost < self.battle:GetSunshineValue() then
					self.selectCreature = i;
					checkNextUnit = false;
					break;
				end
			end
		end	
	end

	if checkNextUnit then
		for i=1,self.selectCreature do
			local battleUnit = self.battleInfo.battleUnitList[i];
			local prop = battleUnit.childUnit[#battleUnit.childUnit];
			if prop then
				if prop.cost < self.battle:GetSunshineValue() then
					self.selectCreature = i;
					checkNextUnit = false;
					break;
				end
			end
		end	
	end

	if checkNextUnit and isSupport then
		self.selectCreature = -1;
	end
end

-- 刷新人口数
function VBattleView:setPopTextView( )
	-- if self.battleInfo.pop < 0 then
	-- 	self.textPop.text = "人口：0";
	-- else	
	-- 	self.textPop.text = "人口："..self.battleInfo.pop;
	-- end
end

-- 人口不足动画
function VBattleView:showNotEnoughPopAnimation( )
	self.textPop:RunAction{{"repeat", 2, {{self, "popTextChangeColor", 1}, {"delayTime", 0.1}, {self, "popTextChangeColor", 2}, {"delayTime", 0.1}}}};
end

function VBattleView:popTextChangeColor( index )
	if index == 1 then
		self.textPop.color = {255, 0, 0};
	else
		self.textPop.color = {255, 255, 255};
	end
end

-- 刷新怪物列表
function VBattleView:setMonsterTableView( )
	if self.battleInfo.playType ~= EBattlePlayType.PlayObserve then
		self.monsterTable:RunAction{{"hide"}};
	end
	self.monsterTable.level = self.maxLevel * EAnimationSpriteLevel.HIGH_LEVEL - 1;
	self.detailMonsterLayer.level = self.maxLevel * EAnimationSpriteLevel.HIGH_LEVEL - 1;

	if self.isNewbie then
		return;
	end
	self.selectCreature = 1;

	if self.battleInfo.battleUnitList then
		self.monsterTable.number = #self.battleInfo.battleUnitList;
		if #self.battleInfo.battleUnitList > 0 then
			local battleUnit = self.battleInfo.battleUnitList[1];
			local prop = battleUnit.childUnit[#battleUnit.childUnit];
			self.selectQuality[self.selectCreature] = prop.quality;
		end
	else
		self.monsterTable.number = 0;
	end
	self.monsterTable:reloadData();
	for i=1,self.monsterTable.number do
		self.monsterTable:updateCellAtIndex(i-1);
	end
end

-- 刷新关卡援军
function VBattleView:setSupportView( )
	if self.battleInfo.supportList and getMapCount(self.battleInfo.supportList) > 0 then
		local prop = nil;
		for k,v in pairs(self.battleInfo.supportList) do
			prop = v.prop;
		end

		if prop then
			self.battleBackupImage.visible = 1;
			self.backupCard.image = "battleCard"..prop.quality..".png";
			self.backupIcon.image = prop.image.."Card.png";
			self.backupCount.text = getMapCount(self.battleInfo.supportList);
			self.backupCost.text = prop.cost;
			self.backupLevelText.text = prop.level;
			self:selectSupportUnit();

			if gData.offlineData:hasUseBackupTroop() < 3 then
				self.backupArrow.visible = 1;
				self.backupArrow:RunAction({"repeatForever", {"sequence", {"moveBy", 0.5, 20, 0}, {"moveBy", 0.5, -20, 0}}});
			end
		end

		self:setSupportViewAction();
	end
end

function VBattleView:updateSupportViewArrow( )
	if self.backupArrow:isVisible() then
		self.backupArrow.visible = 0;
		self.backupArrow:stopAllActions();
		gData.offlineData:useBackupTroop();
	end
end

function VBattleView:updateSupportViewWithCost( )
	if self.battleInfo.supportList and getMapCount(self.battleInfo.supportList) > 0 then
		local prop = nil;
		for k,v in pairs(self.battleInfo.supportList) do
			prop = v.prop;
		end
		if prop then
			if prop.cost > self.battle:GetSunshineValue()  then
				self.backupCard.gray = 1;
				self.backupCard.touch = 0;
			else
				self.backupCard.gray = 0;
				self.backupCard.touch = 1;
			end
		end
	end
end

function VBattleView:setSupportViewAction( )
	self.backupFlash.index = 0;
	self.backupFlash:RunAction{{"delayTime", 3}, {"show"}, {"delayTime", 0.01}, {self, "supportViewAnimation"}};
end

function VBattleView:supportViewAnimation( )
	self.backupFlash.index = self.backupFlash.index + 1;
	if self.backupFlash.index > 5 then
		self.backupFlash.visible = 0;
		self.backupFlash:setTexture("guanqianyuanjunshan1.png");
		self:setSupportViewAction();
	else
		self.backupFlash:setTexture("guanqianyuanjunshan"..self.backupFlash.index..".png");
		self.backupFlash:RunAction{{"delayTime", 0.01}, {self, "supportViewAnimation"}};
	end
end

-- 刷新田地
function VBattleView:setFarmView( )
	if self.battleInfo.playType ~= EBattlePlayType.PlayObserve and self.battleInfo.attackType == BattleType.BattleTypeEvp then
		self.groundLayer:RunAction{{"hide"}};
	end

	for i=1,5 do
		for j=3,7 do
			self("imageGround"..i..j).visible = 0;
		end
	end

	for i,v in ipairs(self.battleInfo.road) do
		for j=3,self.battleInfo.len do
			self("imageGround"..v..j).visible = 1;		
		end
	end
end

-- 刷新出兵点
function VBattleView:setAttackPlace( )
	self.touchTipsText.visible = 0;

	local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
		self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
	end 

	for i=1,5 do
		local touchNode = self("touchLayer"..i);
		touchNode:setVisible(false);
		local carNode = self("carArmature"..i);
		carNode:setEventCallFunc(callBack);

		local x = touchNode:getPositionX() + touchNode:getContentSize().width * touchNode:getAnchorPoint().x;
		local y = touchNode:getPositionY() - self.cellMinPixH;
		carNode:setPosition(x, y);
	end

	for n,v in ipairs(self.battleInfo.road) do
		-- self("carArmature"..v):setVisible(true);
	end

	if self.battleInfo.playType == EBattlePlayType.PlayAttack and self.battleInfo.attackType ~= BattleType.BattleTypeEvp then
		for n,v in ipairs(self.battleInfo.road) do
			self("touchLayer"..v):setVisible(true);
			self("touchLayer"..v):InitListener(false);
		end

		self.touchTipsText.visible = 0;
	end
end

function VBattleView:closeAttackPlace( )
	for i=1,5 do
		self("touchLayer"..i):setVisible(false);
	end

	self.touchTipsText.visible = 0;

	if self.defenderPlaceList then
		for i,v in ipairs(self.defenderPlaceList) do
			self(v):setVisible(false);
		end
	end
	self.touchPlantLightImage:stopAllActions();
	self.touchPlantLightImage.visible = 0;
end

-- 刷新植物摆放点
function VBattleView:setDefendPlace( )
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		self.defenderPlaceList = {};
		for i,v in ipairs(self.battleInfo.road) do
			for j=1,self.battleInfo.len do
				local placeName = "placeLayer"..v..j;
				local placeLayer = self.battleLayer:Push(VLayer{name=placeName, size={self.cellPixW, self.cellPixH}, touch=1});
				placeLayer.creatureid = -1;
				placeLayer.onClick = "gView('BattleView'):touchAndCreatePlant("..v..","..j..")";
				placeLayer:setAnchorPoint(cc.p(1,1));
				placeLayer:setPosition(j*self.cellPixW, v*self.cellPixH);
				placeLayer:InitListener(false);
				table.insert(self.defenderPlaceList, placeName);
			end
		end
		for i=1,5 do
			self("touchLayer"..i):InitListener(false);
		end
	end
end

function VBattleView:resetDefendPlace( road, pos )
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		local len = pos / self.cellNum;
		local placeLayer = self("placeLayer"..road..len);
		placeLayer.creatureid = -1;
		-- if placeLayer then
		-- 	placeLayer:setVisible(true);
		-- end
	end
end

-- 刷新终点宝箱
function VBattleView:setFinalSpoilBox( )
	for i,v in ipairs(self.battleInfo.road) do
		local box = self.SpoilBoxList[v];
		if not box then
			box = VBattleSpoilBoxSprite:new();
			box:create(v);
			self.SpoilBoxList[v] = box;
		end
	end
end

function VBattleView:openFinalSpoilBox( road, isGetSpoil )
	local box = self.SpoilBoxList[road];
	if box then
		box:showSpoilBoxAnimation(isGetSpoil);
	end
end

-- 刷新植物
function VBattleView:setPlantView( )
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		return;
	end
	local plants = {};
	for k,v in pairsByKeys(self.battleInfo.plants) do
		plants[v.id] = v;
	end
	for k,v in pairsByKeys(plants) do
		if v.propid then
			local pPlantProp = gBattleResource:GetPlantProp(v.propid);
			local pPlant = BattleCreature:new(pPlantProp);
			pPlant:Create(false, v.id, self.battle, v.plantid);
			pPlant:setResource(v.keyValueInfos);
			pPlant:InitPlant(v.attrValueInfos);

			if self.battleInfo.playType == EBattlePlayType.PlayObserve then
				pPlant:SetRoad(v.road);
				pPlant:SetPos(v.pos*self.cellNum);
			else
				self.battle:AddDefender(v);
				self.battle:ActiveCreature(pPlant, v.road, v.pos*self.cellNum);
				if not self.battle:AddCreatureToMgr(pPlant) then
					cclog("VBattleView:setPlantView AddCreatureToMgr Error");		
					return;
				end
			end
			if not gBattleViewTest then
				local plantSprite = self:getPlantSprite(pPlant);
				plantSprite:doSleep();
			end
		end
	end
end

-- 刷新提示语
function VBattleView:setTipsText( )
	-- if self.isNewbie then
	-- 	self.textTips.text = "僵尸正在进攻您的庄园";
	-- 	return;
	-- end

	if self.battleInfo.playType ~= EBattlePlayType.PlayAttack then
		return;
	end

	if self.putOutTroopCount == 0 then
		if self.battleInfo.attackType == BattleType.BattleTypeEvp then
			self.textTips.text = "放置植物：点击左侧田地";
		else
			self.textTips.text = "放置僵尸：点击右侧卡车";
		end
	else
		if self.battleInfo.attackType == BattleType.BattleTypeEvp then
			if self.battleInfo.stars == 3 then
				self.textTips.text = "三星条件：成功防守所有道路，并且没有植物死亡";
			elseif self.battleInfo.stars == 2 then
				self.textTips.text = "二星条件：成功防守所有道路，并且植物死亡数量小于等于5";
			elseif self.battleInfo.stars == 1 then
				self.textTips.text = "失败条件：有道路被突破";
			end
		else
			if #self.battleInfo.road == 1 then
				self.textTips.text = "胜利条件：僵尸打开宝箱";
			else
				if self.battleInfo.stars == 3 then
					self.textTips.text = "";
				elseif self.battleInfo.stars == 2 then
					self.textTips.text = "三星条件：僵尸打开剩余所有宝箱";
				elseif self.battleInfo.stars == 1 then
					local needRoad = math.ceil(#self.battleInfo.road / 2) - getMapCount(self.breakRoadMaps);
					self.textTips.text = "二星条件：僵尸再打开"..needRoad.."个宝箱";
				elseif self.battleInfo.stars == 0 then
					self.textTips.text = "一星条件：僵尸打开1个宝箱";
				end
			end
		end
	end
end

-- 刷新时间
function VBattleView:refreshTimeView( )
	self.textSearchTime:stopAllActions();
	self.textTime:stopAllActions();

	if self.battleInfo.playType == EBattlePlayType.PlayObserve then
		self.textTime.visible = 0;
		if self.battleInfo.time > 0 then
			self.textSearchTime.visible = 1;
			self:updateTimeTextAnimation(self.battleInfo.time, self.textSearchTime);
		end
	else
		self.textTime.text = math.floor(self.battleInfo.time / 1000);
		self.textTime.visible = 1;
		self.textSearchTime.visible = 0;
		-- local time = (self.battleInfo.time - self.battle.m_nTimeEnd) / self.msec_unit;
		-- self:updateTimeTextAnimation(math.floor(time), self.textTime);
	end
end

function VBattleView:updateTimeTextAnimation( time, textNode )
	textNode.text = self:getTimeStringWithTime(time);

	if time > 0 then
		local nextTime = time - 1;
		if self.battleInfo.playType == EBattlePlayType.PlayObserve then
			textNode:RunAction{{"delayTime", 1}, {self, "updateTimeTextAnimation", nextTime, textNode}};
			if time == 2 then
				gBattleView:playSound("battle_timer_down");
			end
		end
	elseif time == 0 then
		local nextTime = time - 1;
		textNode:RunAction{{"delayTime", 1}, {self, "updateTimeTextAnimation", nextTime, textNode}};
	else
		-- 搜索时，时间到了发请求开打
		if self.battleInfo.playType == EBattlePlayType.PlayObserve then
			self:attackBattle();
		else
			-- 时间到了放兵点隐藏掉
			self:closeAttackPlace();
			-- 如果在0秒时候道路全部打通 则暂时不结束战斗 播放完后面的动画先
			if not self.isAllRoadBreak then
				self.viewIsOver = true;
				self:toDoBattleEnd();
			end
		end
	end
end

function VBattleView:getTimeStringWithTime( time )
	if self.battleInfo.playType == EBattlePlayType.PlayObserve then
		if time == 0 then
			return "开战";
		else
			return time;
		end
	else
		if time < 0 then
			return "结束";
		else
			return time;
		end
	end

	-- local timeString = time;
	-- if time > 60 then
	-- 	local m = math.floor(time / 60.0);
	-- 	local s = time - m * 60;
	-- 	if s < 10 then
	-- 		s = "0"..s;
	-- 	end
	-- 	timeString = m..":"..s;
	-- end
	-- return timeString;
end

-- 停止刷新时间
function VBattleView:stopTimeView( )
	self.textTime:stopAllActions();

	if self.battleInfo.playType == EBattlePlayType.PlayReplay then
		self.textTime.text = 0;
	end
end

-- 延时打开云朵
function VBattleView:finishShowBattleViewAndOpenCloud( )
	if self.battleInfo.playType ~= EBattlePlayType.PlayObserve then
		self.animationTouchLayer:RunAction{{"show"}};
	end
	self:RunAction{{"delayTime", 0.4}, {self, "doOpenCloud"}};
end

function VBattleView:doOpenCloud( )
	-- 关闭过渡窗口
	gWindow:openCloud(self, "showStartBattleAnimation");
end

-- 开战动画
function VBattleView:showStartBattleAnimation( )
	if self.battleInfo.playType ~= EBattlePlayType.PlayObserve then
		self:setBattleTitleAnimation();
		self:setGroundLayerAnimation();
		self:setOperationTableAnimation();
		self:setCarEnterAnimation();
		self:StartTimer("finishStartBattleAnimation", 4);
	else
		self.isShowBattleView = true;
	end
end

function VBattleView:setBattleTitleAnimation( )
	local pos = cc.p(self.imgBattleTitle:getPositionX(), self.imgBattleTitle:getPositionY());
	local winWidth = gWindow:getContentSize().width;
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		self.imgBattleTitle:setTexture("BattleTitleDefend.png");
		self.imgBattleTitle:RunAction{{"moveTo", 0, pos.x - winWidth, pos.y}, {"delayTime", 0.3}, {"show"}, {"moveTo", 0.3, pos.x, pos.y}, {"delayTime", 1}, {"moveTo", 0.3, pos.x + winWidth, pos.y}};
	else
		self.imgBattleTitle:setTexture("BattleTitleAttack.png");
		self.imgBattleTitle:RunAction{{"moveTo", 0, pos.x + winWidth, pos.y}, {"delayTime", 0.3}, {"show"}, {"moveTo", 0.3, pos.x, pos.y}, {"delayTime", 1}, {"moveTo", 0.3, pos.x - winWidth, pos.y}};
	end
	self.animationTouchLayer:RunAction{{"delayTime", 4}, {"hide"}};
end

function VBattleView:setGroundLayerAnimation( )
	local pos = cc.p(self.groundLayer:getPositionX(), self.groundLayer:getPositionY());
	local winWidth = gWindow:getContentSize().width;
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		local delay = 2;
		self.groundLayer:RunAction{{"moveTo", 0, pos.x - winWidth, pos.y}, {"delayTime", delay}, {"show"}, {"moveTo", 0.5, pos.x, pos.y}, {"delayTime", 1.2}, {self, "setDefendTouchLight"}};

		for i,v in ipairs(self.battleInfo.road) do
			local smokeImg = self.groundLayer:Push(VImage{image="battleSmoke.png"});
			smokeImg:setScaleX(-0.3);
			smokeImg:setScaleY(0.3);
			smokeImg:setAnchorPoint(cc.p(1,0));

			local groundNode = self("imageGround"..v..self.battleInfo.len);
			local groundSize = groundNode:getContentSize();
			local groundAnPos = groundNode:getAnchorPoint();
			local pos = cc.p(groundNode:getPositionX() + groundSize.width * groundAnPos.x - self.cellMinPixW, groundNode:getPositionY() - groundSize.height * groundAnPos.y);
			smokeImg:setPosition(pos.x, pos.y);

			smokeImg:RunAction{{"hide"}, {"delayTime", delay+0.5}, {"show"}, {"spawn", {"moveBy", 0.2, 20, 0}, {"scaleTo", 0.2, -0.8, 0.8}}, {"spawn", {"scaleTo", 0.65, -1.1, 0.95}, {"fadeTo", 0.65, 0}}, {"delete"}};
		end
	-- else
	-- 	local delay = 3.2;
	-- 	self.groundLayer:RunAction{{"delayTime", delay}, {self, "setAttackTouchLight"}};
	end
end

function VBattleView:setOperationTableAnimation( )
	local delay = 0;
	local pos = cc.p(self.monsterTable:getPositionX(), self.monsterTable:getPositionY());
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		delay = 2.6;
		self.monsterTable:RunAction{{"moveTo", 0, pos.x - self.monsterTable:getContentSize().width*1.2, pos.y}, {"delayTime", delay}, {"show"}, {"moveTo", 0.4, pos.x, pos.y}};
	else
		delay = 2;
		self.monsterTable:RunAction{{"moveTo", 0, pos.x + gWindow:getContentSize().width*1.2, pos.y}, {"delayTime", delay}, {"show"}, {"moveTo", 0.3, pos.x, pos.y}};
	end
end

function VBattleView:setCarEnterAnimation( )
	local delay = 2.4;
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		delay = 3;
		for i,v in ipairs(self.battleInfo.road) do
			self("carArmature"..v):changeDisplay("smokeNode", nil, -1);
			self("carArmature"..v):changeDisplay("carArrow", nil, -1);
		end
	else
		self("touchLayerForSize"):RunAction{{"delayTime", delay}, {self, "setTouchTipsAnimation"}};
	end

	for i,v in ipairs(self.battleInfo.road) do
		self("carArmature"..v):RunAction{{"delayTime", delay}, {"show"}, {self, "showCarEnterAnimation", v}};
	end
end

function VBattleView:showCarEnterAnimation( index )
	self("carArmature"..index):play("enter", nil, 0);
end

function VBattleView:finishStartBattleAnimation( )
	self:StopTimer("finishStartBattleAnimation");
	self.isShowBattleView = true;

	if self.battleInfo:isDungeonBattle() then
		if not gData:ShowBattleHelpDlg(self.battleInfo.dungeonId, self, "closeBattleHelpDlgCallBack") then
			self:startBattleTimer();
		end
	else
		self:startBattleTimer();
	end
end

function VBattleView:closeBattleHelpDlgCallBack( )
	self:startBattleTimer();
end

function VBattleView:setAttackTouchLight( )
	local fillY = #self.battleInfo.road / 5 + 0.1;
	local fillX = 0.3;
	self.touchMonsterLightImage.fill = {fillX, fillY};
	self.touchMonsterLightImage:RunAction{{"show"}, {"repeat", -1, {"sequence", {"fadeTo", 0.3, 80}, {"fadeTo", 0.7, 255}}}};
end

function VBattleView:setDefendTouchLight( )
	local fillY = #self.battleInfo.road / 5 + 0.1;
	local fillX = self.battleInfo.len / 10 + 0.05;
	self.touchPlantLightImage.fill = {fillX, fillY};
	self.touchPlantLightImage:RunAction{{"show"}, {"repeat", -1, {"sequence", {"fadeTo", 0.3, 80}, {"fadeTo", 0.7, 255}}}};
	self:setTouchTipsAnimation();
end

function VBattleView:setTouchTipsAnimation( )
	for i,v in ipairs(self.battleInfo.road) do
		local touchName = "touchImg"..v;
		local touchImg = self.battleLayer:Push(VImage{name=touchName, image="battleTouchTips.png", scale=0.6, visible=0});
		local x = 0;
		if self.battleInfo.attackType == BattleType.BattleTypeEvp then
			x = self.cellNum/2 * self.cellMinPixW;
		else
			x = (90 - self.cellNum/2) * self.cellMinPixW;
		end
		local y = (v - 0.5) * self.cellPixH;
		touchImg:setPosition(x, y);
		touchImg:RunAction{{"delayTime", 0.4}, {"show"}, {"repeat", -1, {"spawn", {"sequence", {"fadeTo", 1.3, 30}, {"fadeTo", 0, 255}}, {"sequence", {"scaleTo", 1.3, 1.6}, {"scaleTo", 0, 0.6}}}}};
	end
end

function VBattleView:removeTouchTipsImg( road )
	if self("touchImg"..road) then
		self("touchImg"..road):stopAllActions();
		self("touchImg"..road):Delete();
		-- self("touchImg"..road) = nil;
	end
end

-- 捡阳光
function VBattleView:pickupSunshine( id )
	local event = BattleEvent:new();
	event:initWithDatas(EBattleLogEvent.LOG_EVENT_SUNSHINE, -1, nil, id);
	self.battle:AddEvent(event);

	local sprite = self.SunshineList[id];
	if sprite then
		sprite:doPickupAnimation();
	end
end

-- 选择援军
function VBattleView:supportCardOnClick( )
	if getMapCount(self.battleInfo.supportList) > 0 then
		local lastIndex = self.selectCreature;
		self.selectCreature = -1;

		if lastIndex - 1 >= 0 then
			self.monsterTable:updateCellAtIndex(lastIndex-1);	
		end

		self:selectSupportUnit(true);
	end
end

function VBattleView:selectSupportUnit( isSupport )
	if isSupport ~= nil then
		self.isSupport = isSupport;
	end

	if self.isSupport then
		self.backupSelect.visible = 1;
	else
		self.backupSelect.visible = 0;
	end
end

-- 放怪
function VBattleView:touchAndCreateMonster( node )
	if self.selectShovel then
		self:unSelectShovelBtnClick();
		return;
	end

	if self.battleInfo.playType ~= EBattlePlayType.PlayAttack then
		return;
	end

	if self.picking then
		return;
	end
	-- if self.battleInfo.pop <= 0 then
	-- 	self:showNotEnoughPopAnimation();
	-- 	return;
	-- end
	if self.isSupport then
		self:addMonsterSupportInBattle(EBattleLogEvent.LOG_EVENT_ADD_UNIT, node.road);
	else
		self:addMonsterInBattle(EBattleLogEvent.LOG_EVENT_ADD_UNIT, node.road);
	end
end

function VBattleView:addMonsterSupportInBattle( eventType, road )
	-- 如果没有援军了 返回
	if getMapCount(self.battleInfo.supportList) <= 0 then
		return;
	end

	local unit = nil;
	for k,v in pairs(self.battleInfo.supportList) do
		unit = v;
	end

	-- 阳光不足 返回 
	if unit.prop.cost > self.battle:GetSunshineValue() then 
		self:showSunshineTips("月光不足");
		return;
	end

	if not unit.id then
		return;
	end 

	-- 放兵，战场添加操作事件
	-- self("touchLayer"..road):setVisible(false);

	self.putOutTroopCount = self.putOutTroopCount + 1;
	if self.putOutTroopCount == 1 then
		self:setTipsText();
	end

	self.battleInfo.supportList[unit.id] = nil;
	self.backupCount.text = getMapCount(self.battleInfo.supportList);
	if getMapCount(self.battleInfo.supportList) <= 0 then
		self:selectSupportUnit(false);
		self.backupCard.gray = 1;
		self.backupCard.touch = 0;

		self.selectCreature = 1;
		self:updateNextTableCell(0);
	end

	local event = BattleEvent:new();
	event:initWithDatas(eventType, road, nil, unit.id);

	----测试：阳光不足上报服务器客户端实时数据----
	table.insert(event.params,unit.prop.cost);
	table.insert(event.params,self.battle:GetSunshineValue()); 
	table.insert(event.params,self.battle.m_nTimeEnd);
	table.insert(event.params,self.battle.m_nSunshineNum);
	table.insert(event.params,self.PrepareSunshine);
	----------------------------------------------
	
	self:addPrepareZombieList(event, unit.prop.cost);
	-- self.battle:AddEvent(event);
	self:removeTouchTipsImg(road);

	self:updateSupportViewArrow();
end

function VBattleView:addMonsterInBattle( eventType, road )
	local battleUnit = self.battleInfo.battleUnitList[self.selectCreature];
	if not battleUnit then
		return;
	end
	local selectQuality = self.selectQuality[self.selectCreature];
	if not selectQuality then
		return;
	end

	-- 如果没有怪物 返回
	if battleUnit.unitCount <= 0 then
		return;
	end

	-- 阳光不足 返回 
	local cost = self:isEnoughSunshinForBattleUnit(battleUnit);
	if cost == -1 then
		self:showSunshineTips("月光不足");
		return;
	end

	local monsterId = self.battleInfo:removeBattleUnit(battleUnit.basicProp.classType, selectQuality);
	self.selectQuality[self.selectCreature] = nil;
	if not monsterId then
		return;
	end 

	-- 放兵，战场添加操作事件
	-- self("touchLayer"..road):setVisible(false);

	self.monsterTable:updateCellAtIndex(self.selectCreature-1);

	local event = BattleEvent:new();
	event:initWithDatas(eventType, road, nil, monsterId);
	----测试：阳光不足上报服务器客户端实时数据----
	table.insert(event.params,cost);
	table.insert(event.params,self.battle:GetSunshineValue()); 
	table.insert(event.params,self.battle.m_nTimeEnd);
	table.insert(event.params,self.battle.m_nSunshineNum);
	table.insert(event.params,self.PrepareSunshine);
	----------------------------------------------

	self:addPrepareZombieList(event, cost);
	-- self.battle:AddEvent(event);
	-- self.battleInfo.pop = self.battleInfo.pop - battleUnit.basicProp.population;
	self:setPopTextView();
	self.putOutTroopCount = self.putOutTroopCount + 1;
	if self.putOutTroopCount == 1 then
		self:setTipsText();
	end

	self:updateNextTableCell(battleUnit.unitCount);
	self:removeTouchTipsImg(road);
end

function VBattleView:addPrepareZombieList( event, cost )
	self.PrepareSunshine = self.PrepareSunshine + cost;
	table.insert(self.PrepareZombieList[event.road], event);
	if not self("carArmature"..event.road).isOpen and #self.PrepareZombieList[event.road] == 1 then
		self.battle:AddEvent(event);
		table.remove(self.PrepareZombieList[event.road], 1);
	end
	self:setSunshineView();
end

function VBattleView:reducePrepareSunshine( cost )
	if self.battleInfo.attackType ~= BattleType.BattleTypeEvp then
		self.PrepareSunshine = self.PrepareSunshine - cost;
	end
end

function VBattleView:addNextZombieEvent( battleCreature )
	local road = battleCreature:GetRoad();
	self("carArmature"..road).isOpen = false;

	if #self.PrepareZombieList[road] > 0 then
		local event = self.PrepareZombieList[road][1];
		self.battle:AddEvent(event);
		table.remove(self.PrepareZombieList[road], 1);
	end
end

function VBattleView:isEnoughSunshinForBattleUnit( battleUnit )
	local prop = nil;
	local selectQuality = self.selectQuality[self.selectCreature];
	if selectQuality then
		for i,v in ipairs(battleUnit.childUnit) do
			if v.quality == selectQuality then
				prop = v;
				break;
			end
		end
	else
		prop = battleUnit.childUnit[#battleUnit.childUnit];
	end

	if prop then
		if prop.cost > self.battle:GetSunshineValue() then
			return -1;
		else
			return prop.cost;
		end
	else
		return -1;
	end
end

function VBattleView:updateNextTableCell( count )
	-- 如果选择的兵小于0，自动选择下一种怪
	if count <= 0 then
		for i=self.selectCreature,#self.battleInfo.battleUnitList do
			local nextBattleUnit = self.battleInfo.battleUnitList[i];
			if nextBattleUnit.unitCount > 0 then
				self:selectMonsterCellWithIndex(i-1);
				return;
			end
		end

		for i=1,#self.battleInfo.battleUnitList do
			if i > self.selectCreature then
				return;
			end
			local nextBattleUnit = self.battleInfo.battleUnitList[i];
			if nextBattleUnit.unitCount > 0 then
				self:selectMonsterCellWithIndex(i-1);
				return;
			end
		end
	end
end

function VBattleView:addEventReadySendRequest( event )
	if self.battleInfo.playType == EBattlePlayType.PlayAttack then 
		table.insert(self.battleEvents, event);
		table.insert(self.reportEvents, event);
	elseif self.battleInfo.playType == EBattlePlayType.PlayReplay then
		-- for i,v in ipairs(self.battleInfo.monsters.armies) do
		-- 	if v.id == event.params[2] then
		-- 		v.count = v.count - 1;
		-- 		self.monsterTable:updateCellAtIndex(i-1);
		-- 		break;
		-- 	end
		-- end
	end
end

-- 放植物
function VBattleView:touchAndCreatePlant( road, pos )
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		if self.selectShovel then
			if self("placeLayer"..road..pos).creatureid ~= -1 then
				-- 铲掉植物
				local battleCreatureId = self("placeLayer"..road..pos).creatureid;
				self.battle:addShovelPlantList(battleCreatureId);
				local event = BattleEvent:new();
				event:initWithDatas(EBattleLogEvent.LOG_EVENT_SHOVEL, road, pos, battleCreatureId);
				event.time = self.battle:GetCurrentTime();
				self:addEventReadySendRequest(event);

				self("placeLayer"..road..pos).creatureid = -1;
			end

			self:unSelectShovelBtnClick();
			return;
		end
	end

	if self.picking then
		return;
	end

	if self("placeLayer"..road..pos).creatureid ~= -1 then
		return;
	end

	-- 是否选择援军
	if self.isSupport then
		self:touchAndCreateSupportPlant(road, pos);
		return;
	end

	local battleUnit = self.battleInfo.battleUnitList[self.selectCreature];
	if not battleUnit then
		return;
	end
	local selectQuality = self.selectQuality[self.selectCreature];
	if not selectQuality then
		return;
	end

	-- 如果没有植物 返回
	if battleUnit.unitCount <= 0 then
		return;
	end

	-- 阳光不足 返回 
	local cost = self:isEnoughSunshinForBattleUnit(battleUnit);
	if cost == -1 then
		self:showSunshineTips("阳光不足");
		return;
	end

	local plantId = self.battleInfo:removeBattleUnit(battleUnit.basicProp.classType, selectQuality);
	self.selectQuality[self.selectCreature] = nil;
	if not plantId then
		return;
	end 

	-- 放兵，战场添加操作事件
	-- self("placeLayer"..road..pos):setVisible(false);

	self.putOutTroopCount = self.putOutTroopCount + 1;
	if self.putOutTroopCount == 1 then
		self:setTipsText();
	end

	self.monsterTable:updateCellAtIndex(self.selectCreature-1);
	self:updateNextTableCell(battleUnit.unitCount);

	-- 创造植物 添加进战场 
	local battleCreature = self.battleInfo.plants[plantId];
	local pPlantProp = gBattleResource:GetPlantProp(battleCreature.propid);
	local pPlant = BattleCreature:new(pPlantProp);
	pPlant:Create(false, battleCreature.id, self.battle, battleCreature.plantid);
	pPlant:setResource(battleCreature.keyValueInfos);
	pPlant:InitPlant(battleCreature.attrValueInfos);

	pPlant:SetRoad(road);
	pPlant:SetPos(pos*self.cellNum);
	self.battle:AddDefender(battleCreature);
	if not self.battle:AddCreatureToMgr(pPlant) then
		cclog("VBattleView:setPlantView AddCreatureToMgr Error");
		return;
	end
	self("placeLayer"..road..pos).creatureid = pPlant:GetId();

	local addTime = self.battle:GetCurrentTime();
	self.battle:AddPreDefender(pPlant:GetId(), addTime);

	local event = BattleEvent:new();
	event:initWithDatas(EBattleLogEvent.LOG_EVENT_ADD_UNIT, road, pos*self.cellNum, plantId);
	event:setTime(addTime);
	self:addEventReadySendRequest(event);

	if not gBattleViewTest then
		self:getPlantSprite(pPlant);
	end
	self:setSunshineView();
	self:removeTouchTipsImg(road);
end

function VBattleView:touchAndCreateSupportPlant( road, pos )
	-- 如果没有援军了 返回
	if getMapCount(self.battleInfo.supportList) <= 0 then
		return;
	end

	local unit = nil;
	for k,v in pairs(self.battleInfo.supportList) do
		unit = v;
	end

	-- 阳光不足 返回 
	if unit.prop.cost > self.battle:GetSunshineValue() then 
		self:showSunshineTips("阳光不足");
		return;
	end

	if not unit.id then
		return;
	end 
	
	-- 放兵，战场添加操作事件
	-- self("placeLayer"..road..pos):setVisible(false);

	self.putOutTroopCount = self.putOutTroopCount + 1;
	if self.putOutTroopCount == 1 then
		self:setTipsText();
	end

	-- 创造植物 添加进战场 
	local battleCreature = unit;
	local pPlantProp = gBattleResource:GetPlantProp(battleCreature.propid);
	local pPlant = BattleCreature:new(pPlantProp);
	pPlant:Create(false, battleCreature.id, self.battle, battleCreature.plantid);
	pPlant:setResource({});
	pPlant:InitPlant({});

	pPlant:SetRoad(road);
	pPlant:SetPos(pos*self.cellNum);
	self.battle:AddDefender(battleCreature);
	if not self.battle:AddCreatureToMgr(pPlant) then
		cclog("VBattleView:setPlantView AddCreatureToMgr Error");
		return;
	end
	self("placeLayer"..road..pos).creatureid = pPlant:GetId();

	local addTime = self.battle:GetCurrentTime();
	self.battle:AddPreDefender(pPlant:GetId(), addTime);
	self:getPlantSprite(pPlant);
	self:setSunshineView();
	self:removeTouchTipsImg(road);

	self.battleInfo.supportList[unit.id] = nil;
	self.backupCount.text = getMapCount(self.battleInfo.supportList);
	if getMapCount(self.battleInfo.supportList) <= 0 then
		self:selectSupportUnit(false);
		self.backupCard.gray = 1;
		self.backupCard.touch = 0;

		self.selectCreature = 1;
		self:updateNextTableCell(0);
	end

	local event = BattleEvent:new();
	event:initWithDatas(EBattleLogEvent.LOG_EVENT_ADD_UNIT, road, pos*self.cellNum, battleCreature.plantid);
	event:setTime(addTime);
	self:addEventReadySendRequest(event);

	self:updateSupportViewArrow();
end

-- 选择铲子
function VBattleView:selectShovelBtnClick( )
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		if not self.selectShovel then
			if not gData.offlineData:hasUprooted() then
				gData.offlineData:uprootPlant();

				self.isShowShovelTips = true;
				local title = "铲除植物不会返还阳光。\n铲除前"..self.m_shovelPlantNum.."个满血植物\n不影响三星评价";
				gWindow:showConfirmTip(title, "确定", nil, self, "confirmShovelTips", nil, "");
			end

			self.selectShovel = true;
			self.btnShovel:setTexture("shovelLightButton.png");
			self.btnShovel:RunAction{{"repeat", -1, {"sequence", {"fadeTo", 0.4, 150}, {"fadeTo", 0.4, 255}}}};
		end
	end
end

function VBattleView:confirmShovelTips( )
	self.isShowShovelTips = false;
end

function VBattleView:unSelectShovelBtnClick( )
	if self.battleInfo.attackType == BattleType.BattleTypeEvp then
		if self.selectShovel then
			if not self.isShowShovelTips then
				self.selectShovel = false;
				self.btnShovel:setTexture("shovelButton.png");
				self.btnShovel:RunAction{{"fadeTo", 0.3, 255}};
			end
		end	
	end
end

-- 开打
function VBattleView:attackBattle( )
	self:setDaveAnimation(false);

	gWindow:closeCloud(self, "sendAttackRequest");
end

-- 复活
function VBattleView:ReviveBattle( )
	local mr = VNode("vMonsterReviveDlg.vui");
	mr.level = self.maxLevel * EAnimationSpriteLevel.HIGH_LEVEL;
	gView():Push(mr);
end

function VBattleView:sendAttackRequest( )
	-- 打搜索到的玩家
	if self.targetBattleId then
		gReq:MsgReqGroupBattleAttack( self.battleInfo.defender.userid, self.targetBattleId );
	else
		gReq:MsgReqAttack( self.battleInfo.defender.userid, self.battleInfo.attackType );
	end
	-- 测试打指定玩家
--	 gReq:MsgReqAttack( 1001065 , self.battleInfo.attackType );
end

-- 跳过
function VBattleView:passBattle( )
	self.isPassBattle = true;
	self:closeBattle(180*self.msec_unit);
end

-- 退出
function VBattleView:closeBtnClick( )
	if self.selectShovel then
		self:unSelectShovelBtnClick();
		return;
	end

	if self.battleInfo.playType == EBattlePlayType.PlayAttack then
		if self.battleInfo:isDungeonBattle() and self.putOutTroopCount == 0 then
			self:closeBattle();
		else
			self.isShowConfirmTip = true;
			gWindow:showConfirmTip("撤退会按战场当前状况结算，\n确认撤退吗？", "确定", "取消", self, "closeBattle", nil, "是否撤退？");
		end
	else
		self:closeBattle();
	end
end

function VBattleView:finishCloseingBattle()
	self.isCloseingBattle = false;
end

function VBattleView:closeBattle( endTime )
	if self.battleInfo.playType == EBattlePlayType.PlayAttack then
		if self.isStartBattle then
			self.isStartBattle = false;
			self.isCloseingBattle = true;
		else
			return;
		end
	end

	gDtr:getScheduler():setTimeScale(1.0);
	-- self.btnClose.gray = 1;
	-- self.btnClose.touch = 0;
	self.btnClose.visible = 0;
	self.btnUpRightClose.visible = 0;
	self.btnPass.visible = 0;
	self.btnSpeed.visible = 0;
	self.textTips.visible = 0;
	
	self:closeAttackPlace();
	gAudio:stopAllEffects();

	if endTime then
		self.battle.m_nTimeEnd = endTime;
	end

	if self.battleInfo.playType == EBattlePlayType.PlayAttack then
		if gData.offlineData:isOffline() then
			self:stopBattle();
			self:setSingleResult();
		else
			local retreatFlag = 0;
			self:StartTimer("delayShowLoadingAnimation", 5);
			if self.battleInfo:isDungeonBattle() then
				gReq:MsgReqDungeonEnd( self.battleInfo.dungeonId, self.battle.m_nTimeEnd, self.battleEvents, retreatFlag, self, "getMsgReqDungeonEnd");
			else
				gReq:MsgReqAttackEnd( self.battleInfo.defender.userid, self.battle.m_nTimeEnd, self.battleEvents, retreatFlag, self.battleInfo.groupBattleId, self, "getMsgRspAttackEnd");
			end
			self:stopBattle();
		end
	else
		if self.battleInfo.playType == EBattlePlayType.PlayReplay and self.resultDlg == nil then
			self:finishReplay();
		else
			self:exitBattle();
		end
	end
end

function VBattleView:exitBattle( )
	gWindow:closeCloud(self, "exitBattleView");
end

function VBattleView:exitBattleView( )
	self.runFps = 50;
	gDtr:setAnimationInterval(1.0 / self.runFps);
	if self.groupInfo then
		local isWin = false;
		if self.battleInfo.attacker.userid == gData.userInfo.userid then
			if self.battleResult.stars == 0 then
				isWin = false;
			else
				isWin = true;
			end
		elseif self.battleInfo.defender.userid == gData.userInfo.userid then
			if self.battleResult.stars == 0 then
				isWin = true;
			else
				isWin = false;
			end
		end
		gWindow:Replace("vMainView.vui", function() gMainView:openGroupBattleDlg(self.groupInfo, isWin); end);
	elseif self.targetBattleId then
		gWindow:Replace("vMainView.vui", function() gMainView:openTargetBattleId(self.targetBattleId); end);
	else
		gWindow:Replace("vMainView.vui", function() gWindow:openCloud() end);
	end

	gAudio:setEffectsVolume(gAudio:getEffectsVolume() / 0.8);
	gAudio:setMusicVolume(gAudio:getMusicVolume() / 0.8);
	-- gWindow:Pop(1, function() gWindow:openCloud() end);
	gBattleView = nil;
end

function VBattleView:delayShowLoadingAnimation( )
	self:StopTimer("delayShowLoadingAnimation");
	gWindow:showLoadingAnimation();
	self:StartTimer("isTimeOutTimer", 35);
end

function VBattleView:isTimeOutTimer( )
	self:StopTimer("isTimeOutTimer");
	gWindow:showConfirmTip("网络不给力啊，请检查您的网络", "确定", nil, self, "exitBattle");
	gWindow:closeLoadingAnimation();
end

function VBattleView:getMsgRspAttackEnd( result, aMsgRspAttackEnd, req )
	self:StopTimer("isTimeOutTimer");
	if result == 0 then
		--心跳
		gReq:MsgReqHeartbeat(gData, "heartBeatCallBack");
		-- 结算
		if aMsgRspAttackEnd then
			local result = aMsgRspAttackEnd.result;
			self.groupInfo = aMsgRspAttackEnd.info;
			gBattleView:showBattleResultView(result);
			
			-- 战斗逻辑比较
			local str = aMsgRspAttackEnd.str;
			gBattleView:compareBattleLog(str);
		else
			self:exitBattle();
		end
	elseif result < 0 then
		gWindow:closeLoadingAnimation();
		gWindow:showConfirmTip("网络不给力啊，请检查您的网络\n重新连接 _(:з」∠)_", "确定", nil, self, "sendBattleEndRequestAgain");
	else
		gBattleView:attackError(result);
	end
end

function VBattleView:getMsgReqDungeonEnd( result, aMsgRspDungeonEnd, req )
	self:StopTimer("isTimeOutTimer");
	if result == 0 then
		-- 结算
		--心跳
		gReq:MsgReqHeartbeat(gData, "heartBeatCallBack");

		if aMsgRspDungeonEnd then
			local result = aMsgRspDungeonEnd.result;
			gBattleView:showBattleResultView(result);

			-- 刷新关卡
			if aMsgRspDungeonEnd.info then
				gData.userInfo.dungeonInfo:UpDataActInfo(aMsgRspDungeonEnd.info.id, aMsgRspDungeonEnd.result.stars, aMsgRspDungeonEnd.info.purchase);
			end

			-- 战斗逻辑比较
			local str = aMsgRspDungeonEnd.str;
			gBattleView:compareBattleLog(str);
		else
			self:exitBattle();
		end
	elseif result < 0 then
		gWindow:closeLoadingAnimation();
		gWindow:showConfirmTip("网络不给力啊，请检查您的网络\n重新连接 _(:з」∠)_", "确定", nil, self, "sendBattleEndRequestAgain");
	else
		gBattleView:attackError(result);
	end
end

function VBattleView:sendBattleEndRequestAgain( )
	gWindow:showLoadingAnimation();
	if self.battleInfo:isDungeonBattle() then
		gReq:MsgReqDungeonEnd( self.battleInfo.dungeonId, self.battle.m_nTimeEnd, self.battleEvents, 0, self, "getMsgReqDungeonEnd");
	else
		gReq:MsgReqAttackEnd( self.battleInfo.defender.userid, self.battle.m_nTimeEnd, self.battleEvents, 0, self.battleInfo.groupBattleId, self, "getMsgRspAttackEnd");
	end
end

-- 战斗结束处理
function VBattleView:toDoBattleEnd( )
	if self.battle:IsOver() and self.viewIsOver and not self.isShowResult then
		self:battleEndAndUpdateView();
		self.isShowResult = true;
		if self.battleInfo.playType == EBattlePlayType.PlayAttack then
			self:closeBattle();
		else
			self:finishReplay();
		end
	end
end

function VBattleView:battleEndAndUpdateView( )
	local battleResult = VBattleResult:new();
	battleResult:initSingleGameResult(self.battle, self.battleInfo);
	self.battleInfo.stars = battleResult.stars;
	self:setStarsView();
	self.textTips.text = "";
end

function VBattleView:battleEvpViewIsOver( )
	self:StartTimer("viewIsOverInEVP", 0, 0, 3);
end

function VBattleView:viewIsOverInEVP( )
	self:StopTimer("viewIsOverInEVP");
	self.viewIsOver = true;
	self:toDoBattleEnd();
end

-- 变速
function VBattleView:changeSpeedBtnClick( )
	if self.selectShovel then
		self:unSelectShovelBtnClick();
		return;
	end

	self.btnSpeed.gray = 1;
	self.btnSpeed.touch = 0;

	local speedList = {1,2,4};
	local speedTextList = {1,2,4};

	if self.battleSpeed == speedList[1] then
		self.battleSpeed = speedList[2];
	elseif self.battleSpeed == speedList[2] then
		self.battleSpeed = speedList[3];
	elseif self.battleSpeed == speedList[3] then
		self.battleSpeed = speedList[1];
	end

	self.isChangeSpeed = true;
end

function VBattleView:changeSpeed( )
	if self.isChangeSpeed then
		self.isChangeSpeed = false;
		gDtr:getScheduler():setTimeScale(self.battleSpeed);
		self.textSpeed.text = "x"..self.battleSpeed;
		self.btnSpeed.gray = 0;
		self.btnSpeed.touch = 1;
	end
end

-- 设置单击版结算
function VBattleView:setSingleResult( )
	self.btnClose.visible = 0;
	self.btnUpRightClose.visible = 0;
	self.btnSpeed.visible = 0;
	self.battleSpeed = 1;
	self.textSpeed.text = "x"..self.battleSpeed;
	gDtr:getScheduler():setTimeScale(self.battleSpeed);

	if self.putOutTroopCount == 0 then
		self:exitBattle();
		return;
	end

	self.battleResult = VBattleResult:new();
	self.battleResult:initSingleGameResult(self.battle, self.battleInfo);
	self.battleResult:initSingleGameRewards(self.battleInfo);
	self.battleResult:setDeathDataInfo(self.battleInfo);

	self.resultDlg = self:Push("vBattleResultDlg.vui");
	self.resultDlg.battleResult = self.battleResult;
	self.resultDlg.dungeonId = self.battleInfo.dungeonId;
	self.resultDlg:showResultView(self.isReplay, self.battleInfo.attackType);
	self.resultDlg.level = self.maxLevel * EAnimationSpriteLevel.HIGH_LEVEL;

	gData.userInfo.dungeonInfo:UpDataActInfo(self.battleInfo.dungeonId, self.battleResult.stars, nil);
end

-- 战斗结束显示结算界面
function VBattleView:showBattleResultView( result )
	-- self:exitBattle();
	self:StopTimer("delayShowLoadingAnimation");
	self:StopTimer("isTimeOutTimer");
	gWindow:closeLoadingAnimation();

	self.btnClose.visible = 0;
	self.btnUpRightClose.visible = 0;
	self.btnSpeed.visible = 0;
	self.battleSpeed = 1;
	self.textSpeed.text = "x"..self.battleSpeed;
	gDtr:getScheduler():setTimeScale(self.battleSpeed);

	if self.battleInfo:isDungeonBattle() and self.putOutTroopCount == 0 then
		self:exitBattle();
	else
		if result then
			self.battleResult = VBattleResult:new(result);
			if self.battleInfo.attackType ~= BattleType.BattleTypePve then
				self.battleInfo.plants = self.battleInfo.plants64;
			else
				local tempList = self.battleInfo.plants;
				self.battleInfo.plants = {};
				for k,v in pairs(tempList) do
					self.battleInfo.plants[tostring(k)] = v;
				end
			end
			self.battleResult:setDeathDataInfo(self.battleInfo);
		end
		if not self.battleInfo:isDungeonBattle() and self.battleInfo.playType ~= EBattlePlayType.PlayReplay then
			gData.userInfo.monsterInfo:updateMonsterReliveTime(self.battleResult.monsters);
		end

		self.resultDlg = self:Push("vBattleResultDlg.vui");
		self.resultDlg.battleResult = self.battleResult;
		if self.battleInfo:isDungeonBattle() then
			self.resultDlg.dungeonId = self.battleInfo.dungeonId;
		end
		self.resultDlg:showResultView(self.isReplay, self.battleInfo.attackType);
		self.resultDlg.level = self.maxLevel * EAnimationSpriteLevel.HIGH_LEVEL;
	end
end

--------------------------------------------    Data Function    --------------------------------------------

function VBattleView:initInstanceBattleData( )
	if gBattleResource == nil then
		gBattleResource = BattleResource:new();
		gBattleResource:Create();
	end

	if gBattleAIMgr == nil then
		gBattleAIMgr = BattleAIMgr:new();
		gBattleAIMgr:Create();
	end

	if gBattleEffectMgr == nil then
		gBattleEffectMgr = BattleEffectMgr:new();
		gBattleEffectMgr:Create();
	end

	if gBattleConditionMgr == nil then
		gBattleConditionMgr = BattleConditionMgr:new();
		gBattleConditionMgr:Create();
	end

	if gBattlePlantSpriteMgr == nil then
		gBattlePlantSpriteMgr = VBattlePlantSpriteMgr:new();
	end

	if gBattleMonsterSpriteMgr == nil then
		gBattleMonsterSpriteMgr = VBattleMonsterSpriteMgr:new();
	end

	if gBattleTestPlantSpriteMgr == nil then
		gBattleTestPlantSpriteMgr = VBattleTestPlantSpriteMgr:new();
	end

	if gBattleTestMonsterSpriteMgr == nil then
		gBattleTestMonsterSpriteMgr = VBattleTestMonsterSpriteMgr:new();
	end
end

function VBattleView:setInstanceData( )
	self.msec_unit = 1000;									-- 1000毫秒常量
	self.cellNum = 10;										-- 每大格子包含多少小格
	local cellSize = self("touchLayerForSize"):getContentSize();
	self.cellPixW = cellSize.width;							-- 每个大格子宽度多少像素
	self.cellPixH = cellSize.height;							-- 每个大格子高度多少像素
	self.cellMinPixW = self.cellPixW / self.cellNum;			-- 每个小格子宽度多少像素
	self.cellMinPixH = self.cellPixH / self.cellNum;
	self.sunshinePixH = self("sunshineTemplate"):getContentSize().height;

	local imageSize = self("bg"):getContentSize();
	local viewSize = self:getContentSize();
	-- cclog("******** imageSize.w = %f, h = %f, viewSize.w = %f, h = %f", imageSize.width, imageSize.height, viewSize.width, viewSize.height);
	self.spriteScale = 0.6;--viewSize.width / imageSize.width;									-- 界面精灵缩放比例
	self.maxLevel = 6;

	self.battleSpeed = 1;									-- 播放速度1、2、3倍
	-- self.battleTime = 0;
	self.reportFinalTime = 8;
	self.animationTime = 0.1;
	self.BulletList = {};										-- 子弹精灵列表
	self.impactBulletList = {};								-- 碰撞子弹列表
	self.PlantList = {};										-- 植物精灵列表
	self.MonsterList = {};									-- 僵尸精灵列表
	self.ObjectList = {};										-- 物体精灵列表
	self.SpoilBoxList = {};									-- 宝箱精灵列表
	self.SunshineList = {};									-- 阳光精灵列表
	self.EventList = {};
	self.isShowConfirmTip = false;
	self.readyDoubleClick = false;
	self.detailUnitData = {};									-- 选择2级列表数据
	self.selectQuality = {};									-- 选择品质
	self.isSupport = false;									-- 是否选择援军
	self.selectShovel = false;								-- 是否选择铲子
	self.isShowBattleView = false;

	self.sunshineAnimationList = {};							-- 阳光动画列表
	self.PrepareSunshine = 0;								-- 僵尸预备消耗阳光
	self.PrepareZombieList = {};								-- 僵尸预备列表
	for i=1,5 do
		self.PrepareZombieList[i] = {};
	end

	if gShowStumpAnimation == nil then
		-- 低于1.0.2版本木有受伤动画
		if versionCompare(gRes:Version(), "1.0.2") == -1 then
			gShowStumpAnimation = false;
		else
			gShowStumpAnimation = true;
		end 
	end

	if gShowBloomAnimation == nil then
		-- 低于1.0.4版本木有shader效果
		if versionCompare(gRes:Version(), "1.0.4") == -1 then
			gShowBloomAnimation = false;
		else
			gShowBloomAnimation = true;
		end 
	end

	if gGetArmatureBoneScale == nil then
		-- 低于1.0.7版本木有bone的Scale方法
		if versionCompare(gRes:Version(), "1.0.7") == -1 then
			gGetArmatureBoneScale = false;
		else
			gGetArmatureBoneScale = true;
		end 
	end

	--掉落相关
	self.DropItemId = 0;			--掉落ID
	self.DropItemList = {};			--掉落道具列表
end

function VBattleView:enterBattleView(info, playType, observeTargetInfo)
	self:initInstanceBattleData();

	if playType == EBattlePlayType.PlayObserve then
		self:getTargetAndShow(info, observeTargetInfo);  --观察
	elseif playType == EBattlePlayType.PlayReplay then
		self:replayBattle(info);	--回放
	elseif playType == EBattlePlayType.PlayAttack then
		if gData.offlineData:isOffline() then
			self:startSingleBattle(info);	-- 单机关卡开战
		else
			self:startBattle(info); --开战
		end
	end
end

function VBattleView:getTargetAndShow( otherUserInfo, observeTargetInfo )
	self.battleInfo = VBattleInfo:new();
	self.battleInfo:initWithOtherUserInfo(otherUserInfo);
	if observeTargetInfo then
		self.targetBattleId = observeTargetInfo.targetBattleId;
		self.battleInfo:appendTargetInfo(observeTargetInfo);
	end

	self:showBattleView();
end

function VBattleView:startBattle( battleInfo )
	self.isStartBattle = true;
	self.isCloseingBattle = false;
	self.battleInfo = VBattleInfo:new(battleInfo);

	-- for test
	-- self.battleInfo = VBattleInfo:new();
	-- local xxx = 11001;
	-- self.battleInfo:initSingleGame(xxx);--battleInfo.bi.defender.id);
	self:doBattle();
	self:showBattleView();
	-- self:startBattleTimer();
end

function VBattleView:startSingleBattle( DungeonId )
	self.isStartBattle = true;
	self.isCloseingBattle = false;

	self.battleInfo = VBattleInfo:new();
	self.battleInfo:initSingleGame(DungeonId);

	self:doBattle();
	self:showBattleView();
	-- self:startBattleTimer();
end

function VBattleView:replayBattle( battleLogInfo )
	self.isReplay = true;
	self.battleLogInfo = battleLogInfo;
	local LogInfo = VBattleLogInfo:new(battleLogInfo);
	LogInfo.battleInfo:setReplayPlayType();
	self.battleInfo = LogInfo.battleInfo;
	self.battleResult = LogInfo.resultInfo;

	if self.battleInfo.attackType ~= BattleType.BattleTypePve then
		self.battleInfo.plants = self.battleInfo.plants64;
	else
		local tempList = self.battleInfo.plants;
		self.battleInfo.plants = {};
		for k,v in pairs(tempList) do
			self.battleInfo.plants[tostring(k)] = v;
		end
	end
	self.battleResult:setDeathDataInfo(self.battleInfo);

	self:doBattle();
	self:showBattleView();
	-- self:startBattleTimer();
end

function VBattleView:readyReplayBattleAgain( )
	gWindow:closeCloud(self, "replayBattleAgain");
end

function VBattleView:replayBattleAgain( )
	self:replayBattle(self.battleLogInfo);
end

function VBattleView:replayNewbieBattle( battleInfo, battleResult )
	battleInfo:getInsigniaInfo();
	self.battleInfo = battleInfo;
	self.battleResult = battleResult;
	self.isNewbie = true;

	self:doBattle();
	self:showBattleView();
	self:startBattleTimer();
end

function VBattleView:finishReplay( )
	self:stopBattle();
	self:showBattleResultView();
end

function VBattleView:doBattle( )
	if gOpenBattleLog then
		self.battleLogText = "";
		cc.VResource:SaveTextToFile("battleLog.txt", "");
	end

	self.battleBreakRoad = {};											-- 记录逻辑打通道路
	self.breakRoadMaps = {};											-- 打通道路列表
	self.battleEvents = {};												-- 操作事件容器，战斗结束时上报
	self.reportTime = 0;												-- 定时上报时间
	self.reportEvents = {};												-- 定时操作事件容器，定时上报，上报后清空
	self.isPassBattle = false;											-- 是否跳过
	self.viewIsOver = false;												-- 界面是否结束战斗
	self.isShowResult = false;											-- 是否显示结算
	self.isAllRoadBreak = false;											-- 倒计时0秒时候 道路是否已经被打通
	self.validTroopCount = 0;	--self.battleInfo:getBattleUnitCount();	-- 部队总数,用于计算界面战斗是否结束
	self.putOutTroopCount = 0;
	self.monstersDeathCount = 0;
	self.m_shovelPlantNum = 0;

	--系统产阳光相关
	local iSunshineNumber = 200;
	local battleProp = gBattleResource:GetBattleProp(self.battleInfo.attackType, #self.battleInfo.road, self.battleInfo.fieldLevel);
	if battleProp then
		iSunshineNumber = battleProp.sunshine;
		if battleProp.m_shovelPlantNum then
			self.m_shovelPlantNum = battleProp.m_shovelPlantNum;
		end
	end
	if self.battleInfo.dungeonId then
		iSunshineNumber = gBattleResource:GetDungeonSunshine(self.battleInfo.dungeonId);
	end
	local iSunshineSpeed = 5000;
	local iSunshineUnit = 49;
	local altarInfo = gBattleResource:getAltarInfo(self.battleInfo.temple);
	if altarInfo then
		if self.battleInfo.attackType == BattleType.BattleTypeEvp then
			iSunshineSpeed = altarInfo.sunshinePeriod * self.msec_unit;
			iSunshineUnit = altarInfo.sunshineCount;
		else
			iSunshineSpeed = altarInfo.darkSunshinePeriod * self.msec_unit;
			iSunshineUnit = altarInfo.darkSunshineCount;
		end
	end

	self.battle = Battle:new();
	self.battle:Create(self.battleInfo.attackType, self.battleInfo.seed, self.battleInfo.inerval, self.battleInfo.time, self.battleInfo.road, 9*self.cellNum, self.battleInfo.index, false, iSunshineNumber, iSunshineSpeed, iSunshineUnit, self.battleInfo.fieldLevel);--self.battleInfo.pop);
	self.battle:SetBattleZombieWave(self.battleInfo.waveTime);
	-- 设置战旗
	self.battle:SetBattleBanner(self.battleInfo);

	-- 战场添加怪物数据
	if self.battleInfo.monsters then
		for k, v in pairs(self.battleInfo.monsters) do
			self.battle:AddAttacker(v);
		end
	end

	-- 添加怪物援军数据
	if self.battleInfo.attackType == BattleType.BattleTypePve then
		if self.battleInfo.supportList then
			for k, v in pairs(self.battleInfo.supportList) do
				self.battle:AddAttacker(v);
			end
		end
	end

	-- 放录像 添加操作事件进战场
	if self.battleInfo.playType == EBattlePlayType.PlayReplay then
		self.battle.m_events = self.battleInfo.events;
	else
		-- 防守时 添加操作事件进战场
		if self.battleInfo.attackType == BattleType.BattleTypeEvp then
			self.battle.m_events = self.battleInfo.events;
		end
	end
end

function VBattleView:startBattleTimer()
	self.avgDt = {};
	self.passTime = 0;
	self.textTimeNum = self.battleInfo.time / 1000;
	self:scheduleUpdateWithPriorityLua(VBattleView.update, 0);
end

function VBattleView:attackError( result )
	self:exitBattleView();
	-- local errorCode = gData:readCsv("errorCode.csv");
	-- local errordiscr = errorCode:lineDataWithKey(result, 1);
	-- -- errordiscr = errordiscr..tostring(result);
	-- gWindow:showTip(errordiscr, 3);
end

function VBattleView:stopBattle( )
	if not self.battle:IsOver() then
		self.battle:_BattleEnd(true);
		self.battle.m_isTimeOut = false;
	end
	-- self:StopTimer("updateBattle");
	-- self:StopTimer("updateAnimation");
	self:unscheduleUpdate();

	for k,v in pairs(self.BulletList) do
		v:stopAllAnimation();
	end

	for k,v in pairs(self.PlantList) do
		v:stopAllAnimation();
	end

	for k,v in pairs(self.MonsterList) do
		v:stopAllAnimation();
	end

	for k,v in pairs(self.ObjectList) do
		v:stopAllAnimation();
	end

	for k,v in pairs(self.SunshineList) do
		v:stopAllAnimation();
	end

	for k,v in pairs(self.DropItemList) do
		v:stopAllAnimation();
	end

	self:stopTimeView();
end

function VBattleView:sendBattleReportRequest( )
	if gData.offlineData:isOffline() then
		return;
	end
	self.reportTime = self.reportTime + self.battle.m_nTimeUnit / self.msec_unit;
	if self.reportTime > self.reportFinalTime then
		if #self.reportEvents > 0 then
			-- cclog("*** report time = "..os.time());
			gReq:MsgReqBattleReport(self.reportEvents);
			self.reportEvents = {};
		end
		self.reportTime = 0;
	end
end

function VBattleView.update( dt )
	gBattleView:changeSpeed();
	table.insert(gBattleView.avgDt, dt);
	if #gBattleView.avgDt >= 10 then
		local totalDt = 0;
		for i,v in ipairs(gBattleView.avgDt) do
			totalDt = totalDt + v;
		end

		dt = totalDt / #gBattleView.avgDt;
		gBattleView.avgDt = {};

		if dt * 1000 > gBattleView.battleInfo.inerval * 1.1 then
			local tScale = gDtr:getScheduler():getTimeScale();
			local newTScale = math.max(1, tScale * tScale / gBattleView.runFps / dt);
			gDtr:getScheduler():setTimeScale(newTScale);
		elseif dt < gBattleView.battleSpeed / gBattleView.runFps / 1.5 then
			gBattleView.isChangeSpeed = true;
		end
	end

	gBattleView.passTime = gBattleView.passTime + dt;
	if gBattleView.passTime > (gBattleView.battleInfo.inerval / 1000) then
		gBattleView.passTime = gBattleView.passTime - (gBattleView.battleInfo.inerval / 1000);
		gBattleView:updateBattle();
	end

	-- battleAnimationCo = coroutine.create(function ()
	-- 	if gBattleView then
	-- 		gBattleView:updateAnimation(dt);
	-- 		coroutine.yield();
	-- 	end
	-- end)
	-- coroutine.resume(battleAnimationCo);
	gBattleView:updateAnimation(dt);
end

function VBattleView:updateBattle()
	local runTime = self.battle.m_nTimeEnd + self.battle.m_nTimeUnit;
	self.battle:Update(runTime);

	-- battleUpdateCo = coroutine.create(function ()
	-- 	if self and self.battle then
	-- 		local runTime = self.battle.m_nTimeEnd + self.battle.m_nTimeUnit;
	-- 		self.battle:Update(runTime);
	-- 		coroutine.yield();
	-- 	end
	-- end)
	-- coroutine.resume(battleUpdateCo);
	self:sendBattleReportRequest();
end

function VBattleView:createBulletSprite( battleBullet, pos , parent)
	if battleBullet.m_prop.image == "" then
		return nil;
	end

	local class = _G["VBattle"..battleBullet.m_prop.image.."Sprite"];
	if class then
		return class:new(battleBullet, pos, parent);
	else
		return VBattleBulletSprite:new(battleBullet, pos, parent);
	end
end

function VBattleView:getBulletSprite( battleBullet, parent )
	-- return nil;
	local bulletId = battleBullet:GetId();
	local sprite = self.BulletList[bulletId];

	if not sprite then
		if battleBullet:GetSrc() == nil then
			return nil;
		end

		local pos = nil;
		if battleBullet:GetIsAttack() then
			pos = self.MonsterList[battleBullet:GetSrc()]:getShootPos(battleBullet.isSecond);
		else
			pos = self.PlantList[battleBullet:GetSrc()]:getShootPos(battleBullet.isSecond);
		end

		sprite = self:createBulletSprite(battleBullet, pos, parent);
		self.BulletList[bulletId] = sprite;
	end

	return sprite;
end

function VBattleView:removeBulletSprite( bulletId, target, isClean )
	-- local bulletId = battleBullet:GetId();
	local sprite = self.BulletList[bulletId];
	if sprite then
		sprite:die(target, isClean);
	end
	self.BulletList[bulletId] = nil;
	if self.impactBulletList[bulletId] then
		self.impactBulletList[bulletId] = nil;
	end
end

function VBattleView:removeBulletId( bulletId )
	self.BulletList[bulletId] = nil;
	self.impactBulletList[bulletId] = nil;
end

function VBattleView:createPlantSprite( battleCreature )
	if gSimpleVersion then
		return VBattleTestPlantSprite:new(battleCreature);
	else
		local class = _G["VBattle"..battleCreature.m_image.."Sprite"];
		if class then
			return class:new(battleCreature);
		else
			return VBattlePlantSprite:new(battleCreature);
		end
	end
end

function VBattleView:getPlantSprite( battleCreature )
	local plantId = battleCreature:GetId();
	local sprite = self.PlantList[plantId];

	if not sprite and battleCreature:GetValid() then
		sprite = self:createPlantSprite(battleCreature);
		self.PlantList[plantId] = sprite;
	end

	return sprite;
end

function VBattleView:removePlantSprite( plantId )
	local sprite = self.PlantList[plantId];

	if sprite then
		sprite:die();
		self.PlantList[plantId] = nil;
	end

	for k,v in pairs(self.MonsterList) do
		if v.targetPlant then
			if v.targetPlant.id == plantId then
				v.targetPlant = nil;
				self:addEventData(EBattleLogEvent.LOG_EVENT_MOVE, self.battle:GetCreature(true, v.id), true);
			end
		end
	end
end

function VBattleView:createMonsterSprite( battleCreature )
	if gSimpleVersion then
		return VBattleTestMonsterSprite:new(battleCreature);
	else
		local class = _G["VBattle"..battleCreature.m_image.."Sprite"];
		if class then
			return class:new(battleCreature);
		else
			return VBattleMonsterSprite:new(battleCreature);
		end
	end
end

function VBattleView:getMonsterSprite( battleCreature )
	local monsterId = battleCreature:GetId();
	local sprite = self.MonsterList[monsterId];

	if not sprite and battleCreature:GetValid() then
		sprite = self:createMonsterSprite(battleCreature);
		self.MonsterList[monsterId] = sprite;
	end

	if sprite and sprite:isValid() then
		return sprite;
	else
		return nil;
	end
end

function VBattleView:removeMonsterSprite( monsterId )
	local sprite = self.MonsterList[monsterId];

	if sprite then
		sprite:die();
		self.MonsterList[monsterId] = nil;
	end
end

function VBattleView:createObjectSprite( battleObject, battleUnit )
	local class = _G["VBattle"..battleObject.m_image.."Sprite"];
	if class then
		return class:new(battleObject, battleUnit);
	else
		return VBattleObjectSprite:new(battleObject, battleUnit);
	end
end

function VBattleView:getObjectSprite( battleObject, battleUnit )
	local objId = battleObject:GetId();
	local sprite = self.ObjectList[objId];

	if not sprite and battleObject:GetValid() then
		sprite = self:createObjectSprite(battleObject, battleUnit);
		self.ObjectList[objId] = sprite;
	end

	if sprite then
		return sprite;
	else
		return nil;
	end
end

function VBattleView:removeObjectSprite( objId )
	local sprite = self.ObjectList[objId];

	if sprite then
		sprite:die();
		self.ObjectList[objId] = nil;
	end
end

function VBattleView:createSunshineSprite( battleCreature, sunshineData )
	if not sunshineData then
		return;
	end

	local sunshineId = sunshineData.id;
	local sprite = self.SunshineList[sunshineId];

	if not sprite then
		sprite = VBattleSunShineSprite:new(battleCreature, sunshineData);
		self.SunshineList[sunshineId] = sprite;
	end

	if sprite and self.battleInfo.playType == EBattlePlayType.PlayReplay then
		sprite:setTouchUnable();
	end
end

function VBattleView:getSunshineSprite( sunshineId )
	return self.SunshineList[sunshineId];
end

function VBattleView:removeSunshineSprite( sunshineId )
	local sprite = self.SunshineList[sunshineId];

	if sprite then
		sprite:deleteSprite();
		self.SunshineList[sunshineId] = nil;
	end
end

function VBattleView:getSpriteWithObjData( obj )
	if obj:GetMode() == EUnitType.TYPE_CREATURE then
		if obj:GetIsAttack() then
			return self:getMonsterSprite(obj);
		else
			return self:getPlantSprite(obj);
		end
	elseif obj:GetMode() == EUnitType.TYPE_BULLET then
		
	end
end

function VBattleView:addEventData( eventType, obj, param1, param2)
	---------------------------------  test  ---------------------------------
	if gOpenBattleLog then
		local bTime = self.battle.m_nTimeEnd / self.msec_unit;
		local logText = "";
		if eventType == EBattleLogEvent.LOG_EVENT_MOVE and not param1 then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 开始行动 "..obj:GetRoad()..":"..obj:GetPos();

		elseif eventType == EBattleLogEvent.LOG_EVENT_BLOCK then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 被阻挡 "..param1.m_strName..param1:GetId().." "..obj:GetRoad()..":"..obj:GetPos();

		elseif eventType == EBattleLogEvent.LOG_EVENT_MOVE_END then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 行动到尽头 "..obj:GetRoad()..":"..obj:GetPos();
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_ATTACK then
			if obj:GetMode() == EUnitType.TYPE_CREATURE then
				logText = bTime.." "..obj.m_strName..obj:GetId().." 攻击 "..param1.m_strName..param1:GetId().." "..param1:GetRoad()..":"..param1:GetPos();
			elseif obj:GetMode() >= EUnitType.TYPE_BULLET then
				if param2 then
					logText = bTime.." "..param1.m_strName..param1:GetId().." 攻击 "..param2.m_strName..param2:GetId().." "..param2:GetRoad()..":"..param2:GetPos();
				else
					logText = bTime.." "..param1.m_strName..param1:GetId().." 攻击 ";
				end
			end
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_ATTACK_PRE then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 攻击 "..param1.m_strName..param1:GetId().." 前摇 "..param1:GetRoad()..":"..param1:GetPos();
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_DAMAGE then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 受到来自 "..param2.m_strName..param2:GetId().." 的伤害 "..param1.." "..obj:GetRoad()..":"..obj:GetPos();
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_DEATH then
			if obj:GetMode() <= EUnitType.TYPE_CREATURE_MAX then
				logText = bTime.." "..obj.m_strName..obj:GetId().." 死亡 "..obj:GetRoad()..":"..obj:GetPos();
			end
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_SKILL then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 释放技能 "..param1.." "..obj:GetRoad()..":"..obj:GetPos();
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_SKILL_SHAKE then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 释放技能 "..param1.." 前摇 "..obj:GetRoad()..":"..obj:GetPos();
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_ADD_UNIT then
			logText = param1 / self.msec_unit.." "..obj.m_strName..obj:GetId().." 增加新单位 "..obj:GetRoad()..":"..obj:GetPos();
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_ADD_BUFF then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 获得Buff "..param1.." "..obj:GetRoad()..":"..obj:GetPos();
			
		elseif eventType == EBattleLogEvent.LOG_EVENT_DEL_BUFF then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 清除Buff "..param1.." "..obj:GetRoad()..":"..obj:GetPos();

		elseif eventType == EBattleLogEvent.LOG_EVENT_BATTLE_END then
			logText = bTime.." 战斗结束";

		elseif eventType == EBattleLogEvent.LOG_EVENT_WAKEUP then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 苏醒";

		elseif eventType == EBattleLogEvent.LOG_EVENT_SUNSHINE then
			logText = bTime.." 拾取阳光 "..obj.id .. " 数量:" .. obj.value;

		elseif eventType == EBattleLogEvent.LOG_EVENT_NEW_SUNSHINE then
			if obj then
				logText = bTime.." "..obj.m_strName..obj:GetId().." 产生阳光 "..param1.id .. " 数量:" .. param1.value;
			else
				logText = bTime.." 战场产生阳光 "..param1.id .. " 数量:" .. param1.value;
				obj = "";
			end
		elseif eventType == EBattleLogEvent.LOG_EVENT_SUNSHINE_CONSUME then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 增加新单位需消耗阳光: " .. param2;
		
		elseif eventType == EBattleLogEvent.LOG_EVENT_ADD_HP then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 受到来自 "..param2.m_strName..param2:GetId().." 的加血 "..param1.." "..obj:GetRoad()..":"..obj:GetPos();

		elseif eventType == EBattleLogEvent.LOG_EVENT_SHOVEL then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 被铲除植物 "..obj:GetRoad()..":"..obj:GetPos();

		elseif eventType == EBattleLogEvent.LOG_EVENT_SUICIDE then
			logText = bTime.." "..obj.m_strName..obj:GetId().." 自杀 "..obj:GetRoad()..":"..obj:GetPos();

		end

		if logText ~= "" then
			cclog(logText);
			logText = logText.."\n";
			self.battleLogText = self.battleLogText..logText;
			cc.VResource:SaveTextToFile("battleLog.txt", logText, false, "a");
		end
	end

	if eventType == EBattleLogEvent.LOG_EVENT_NEW_SUNSHINE then
		if not obj then
			obj = "";
		end
	end

	if not gBattleViewTest then
		local eventData = {eventType};
		if obj then
			table.insert(eventData, obj);
		end
		if param1 then
			table.insert(eventData, param1);
		end
		if param2 then
			table.insert(eventData, param2);
		end
		table.insert(self.EventList, eventData);
	end
end

function VBattleView:compareBattleLog( battleServerLogText )
	if battleServerLogText then
		if gOpenBattleLog and not self.isPassBattle then
			cc.VResource:SaveTextToFile("battleServerLog.txt", battleServerLogText);
			if self.battleLogText ~= battleServerLogText and self.putOutTroopCount > 0 then
				gWindow:showConfirmTip("战斗逻辑不一致，把vlog、battleLog、battleServerLog文件发给序猿", "确定");
			end
		end
	end
end

--掉落相关
function VBattleView:getDropItemId( )
	self.DropItemId = self.DropItemId + 1;
	return self.DropItemId;
end

function VBattleView:showDropItems( battleCreature, dropItems )
	for key, value in pairs(dropItems) do
		local id = value.id;
		local sprite = self.DropItemList[id];
		if not sprite then
			sprite = VBattleDropItemSprite:new(battleCreature, value);
			self.DropItemList[id] = sprite;
		end
		if sprite and self.battleInfo.playType == EBattlePlayType.PlayReplay then
			sprite:setTouchUnable();
		end
	end
end

function VBattleView:removeDropItemSprite( dropItemId )
	local sprite = self.DropItemList[dropItemId];

	if sprite then
		sprite:deleteSprite();
		self.DropItemList[dropItemId] = nil;
	end
end

function VBattleView:addDropItem( dropItemId )
	local sprite = self.DropItemList[dropItemId];
	if sprite then
		if sprite.userId == self.battleInfo.attacker.userid then
			self.battleInfo.spoils:addItem(true, sprite.count);
		else
			self.battleInfo.spoils:addItem(false, sprite.count);
		end
		self:showSpoilsViewAnimation(true);
	end
end
-- 捡碎片
function VBattleView:pickupDropItem( id )
	local sprite = self.DropItemList[id];
	if sprite then
		sprite:doPickupAnimation();
	end
end
--------------------------------------------    Event Function    --------------------------------------------

function VBattleView:updateAnimation( dt )
	-- 更新战斗时间
	if self.textTimeNum > 0 then
		self:updateTimeTextAnimation(math.floor(self.textTimeNum), self.textTime);
		self.textTimeNum = self.textTimeNum - dt;
		if self.textTimeNum < 0 then
			self.textTimeNum = -1;
		end
	end

	-- 碰撞检测
	self:bulletCollisionDetect();

	-- 事件处理
	for i,v in ipairs(self.EventList) do
		local eventType = v[1];
		local obj = v[2];

		if eventType == EBattleLogEvent.LOG_EVENT_MOVE then
			self:doMoveEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_BLOCK then
			self:doBlockEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_MOVE_END then
			self:doMoveEndEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_ATTACK then
			if #v == 4 then
				local parent = v[3];
				local target = v[4];
				self:doAttackEvent(obj, parent, target);
			elseif #v == 3 then
				local parent = v[3];
				self:doAttackEvent(obj, parent);
			else
				self:doAttackEvent(obj);
			end
		elseif eventType == EBattleLogEvent.LOG_EVENT_ATTACK_PRE then
			if #v == 3 then
				local target = v[3];
				self:doAttackPreEvent(obj, target);
			else
				self:doAttackPreEvent(obj);
			end
		elseif eventType == EBattleLogEvent.LOG_EVENT_DAMAGE then
			if #v == 4 then
				local originObj = v[4];
				self:doDamageEvent(obj, originObj);
			else
				self:doDamageEvent(obj);
			end
		elseif eventType == EBattleLogEvent.LOG_EVENT_DEATH then
			if #v == 3 then
				local target = v[3];
				self:doDeathEvent(obj, target);
			else
				self:doDeathEvent(obj);
			end
		elseif eventType == EBattleLogEvent.LOG_EVENT_SKILL then
			if #v == 4 then
				local target = v[4];
				self:doSkillEvent(obj, target);
			else
				self:doSkillEvent(obj);
			end
		elseif eventType == EBattleLogEvent.LOG_EVENT_SKILL_SHAKE then
			self:doSkillPreEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_ADD_UNIT then
			if #v == 4 then
				local battleUnit = v[4];
				self:doAddMonsterEvent(obj, battleUnit);
			else
				self:doAddMonsterEvent(obj);
			end
		elseif eventType == EBattleLogEvent.LOG_EVENT_ADD_BUFF then
			local buffId = v[3];
			self:doAddBuffEvent(obj, buffId);
		elseif eventType == EBattleLogEvent.LOG_EVENT_DEL_BUFF then
			local buffId = v[3];
			self:doDelBuffEvent(obj, buffId);
		elseif eventType == EBattleLogEvent.LOG_EVENT_BATTLE_END then
			self:doBattleEndEvent();
		elseif eventType == EBattleLogEvent.LOG_EVENT_WAKEUP then
			self:doWakeUpEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_SUNSHINE then
			self:doPickupSunshineEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_NEW_SUNSHINE then
			local sunshineData = v[3];
			self:newSunsineEvent(obj, sunshineData);
		elseif eventType == EBattleLogEvent.LOG_EVENT_ADD_HP then
			-- do animation
		elseif eventType == EBattleLogEvent.LOG_EVENT_BATTLE_DROP then
			local killReturnInfo =  v[3];
			local dieReturnInfo =  v[4];
			self:doBattleDropEvent(obj, killReturnInfo, dieReturnInfo);
		elseif eventType == EBattleLogEvent.LOG_EVENT_SHOVEL then
			self:doDeathEvent(obj);

		-----------  动画事件  客户端专用  -----------
		elseif eventType == EBattleLogEvent.LOG_EVENT_INJURY then
			self:doInjuryEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_JUMP then
			self:doJumpEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_ROTATION then
			self:doRotationImpactEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_GET_RESOURCE then
			local resource = v[3];
			self:doGetResourceEvent(obj, resource);
		elseif eventType == EBattleLogEvent.LOG_EVENT_SLEEP then
			self:doSleepEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_ZOMBIE_ENTER then
			self:doZombieEnterEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_RESET_PLANT then
			self:doResetPlantEvent();
		elseif eventType == EBattleLogEvent.LOG_EVENT_ZOMBIE_ACTIVE then
			self:doZombieActiveEvent(obj);
		elseif eventType == EBattleLogEvent.LOG_EVENT_WAVE_ZOMBIE_ATTACK then
			self:doWaveZombieEvent();
		end
	end

	self.EventList = {};
end

function VBattleView:bulletCollisionDetect( )
	-- 界面碰撞检测
	for bulletId,bullet in pairs(self.impactBulletList) do
		if bullet.image then
			local bulletRect = bullet:getBulletRect();

			if bullet.isAttack then
				for plantId,plant in pairs(self.PlantList) do
					if bullet.road == plant.road and plant.armature then
						if local_bit:_and(bullet.attackType, plant.moveType) ~= 0 then
							local posX = plant.armature:getPositionX();
							local posY = plant.armature:getPositionY() + self.cellPixH / 2;
							local plantRect = cc.rect(posX, posY, self.cellPixW*0.5 , self.cellPixH);
							
							if cc.rectIntersectsRect(bulletRect, plantRect) then
								self:removeBulletSprite(bulletId);
								break;
							end
						end
					end
				end
			else
				for monsterId,monster in pairs(self.MonsterList) do
					if bullet.road == monster.road and monster.valid and monster.armature then
						local posX = monster.armature:getPositionX();
						local posY = monster.armature:getPositionY() + self.cellPixH / 2;

						if gSimpleVersion then
							local monsterRect = cc.rect(posX, posY, monster.armature:getContentSize().width, monster.armature:getContentSize().height);
							if cc.rectIntersectsRect(bulletRect, monsterRect) then
								self:removeBulletSprite(bulletId);
								break;
							end
						else
							if monster.armature:getBone("body"):getDisplayRenderNode() then
								local monsterRect = cc.rect(posX, posY, monster.armature:getBoneSize("body").width, self.cellPixH);
								if cc.rectIntersectsRect(bulletRect, monsterRect) then
									self:removeBulletSprite(bulletId);
									break;
								end
							end
						end
					end
				end
			end
		end
	end
end

-------------------  EBattleLogEvent 逻辑事件  -------------------
-- 移动事件
function VBattleView:doMoveEvent( obj )
	if obj:GetMode() == EUnitType.TYPE_CREATURE then
		if obj:GetIsAttack() then
			local sprite = self:getMonsterSprite(obj);
			if sprite then
				local pos = -1;
				local plant = nil;
				for k,v in pairs(self.PlantList) do
					if v.road == sprite.road and local_bit:_and(sprite.attackType, v.moveType) ~= 0 and v.pos > pos then
						pos = v.pos;
						plant = v;
					end
				end

				sprite:walk(obj, plant);
			end
		else
			local sprite = self:getPlantSprite(obj);
			if sprite then
				sprite:delayStay();
			end
		end
	end
end

-- 阻碍事件
function VBattleView:doBlockEvent( obj )
	if obj:GetIsAttack() then
		-- local sprite = self:getMonsterSprite(obj);
	end
end

-- 走到尽头事件
function VBattleView:doMoveEndEvent( obj )
	if obj:GetIsAttack() then
		local road = obj:GetRoad();
		self:moveEndAndSetBreakRoad(road);

		local sprite = self:getMonsterSprite(obj);
		if sprite then
			sprite:walkEnd();
			-- sprite:moveEnd();
		end
	end
end

function VBattleView:moveEndAndSetBreakRoad( road )
	if not self.battleBreakRoad[road] then
		self.battleBreakRoad[road] = road;
	end
	if getMapCount(self.battleBreakRoad) == #self.battleInfo.road then
		self.isAllRoadBreak = true;
	end
end

-- 攻击事件
function VBattleView:doAttackEvent( obj, parent, target )
	if obj:GetMode() == EUnitType.TYPE_CREATURE then
		if obj:GetIsAttack() then
			-- cclog("****** %f 怪物 %d 攻击", self.battleTime, obj:GetId());
		else
			-- cclog("****** %f 植物 %d 攻击", self.battleTime, obj:GetId());
		end
	elseif obj:GetMode() >= EUnitType.TYPE_BULLET then
		-- cclog("****** %f 子弹 %d 攻击", self.battleTime, obj:GetId());
		local sprite = self:getBulletSprite(obj, parent);
		if sprite then
			if parent then
				-- 子弹的父节点 即谁发射的子弹
				if parent:GetIsAttack() then
					local monsterSprite = self.MonsterList[parent:GetId()];
					if monsterSprite then
						monsterSprite:setMonsterBullet(sprite.id);
					end
				end
			end

			if obj.m_prop.type == EUnitType.TYPE_BULLET_TRACE or obj.m_prop.animationType == EBulletAnimationType.LIGHTNING_TYPE then
				if obj:GetIsAttack() then
					sprite:attack(self.PlantList[obj.m_target], target);
				else
					sprite:attack(self.MonsterList[obj.m_target], target);
				end
			else
				sprite:attack();
			end
		end
	end
end

-- 攻击前摇事件
function VBattleView:doAttackPreEvent( obj, target )
	local sprite = self:getSpriteWithObjData(obj);
	if sprite then
		sprite:attack(obj, target);
	end
end

-- 受伤事件
function VBattleView:doDamageEvent( obj, originObj )
	-- 受伤动画
	local sprite = self:getSpriteWithObjData(obj);
	if sprite then
		sprite:doDamageAnimation(obj);
	end

	if originObj and originObj:GetMode() == EUnitType.TYPE_BULLET then
		local bulletSprite = self.BulletList[originObj:GetId()];
		if bulletSprite and bulletSprite.imageName == "boomerang.png" then
			bulletSprite:hitSound();
		end
	end
end

-- 死亡事件
function VBattleView:doDeathEvent( obj, target )
	if obj:GetMode() == EUnitType.TYPE_CREATURE then
		if obj:GetIsAttack() then
			self:removeMonsterSprite(obj:GetId());
		else
			self:removePlantSprite(obj:GetId());
			if self.battleInfo.attackType == BattleType.BattleTypeEvp then
				if not self.deathPlantNum then
					self.deathPlantNum = 0;
					self.deathShovelNum = 0;
				end
				if obj.isShovel then
					self.deathShovelNum = self.deathShovelNum + 1;
					if self.deathShovelNum > self.m_shovelPlantNum then
						obj.isShovel = false;
					end
				end
				if not obj.isShovel then
					self.deathPlantNum = self.deathPlantNum + 1;
				end
				if self.deathPlantNum == 0 then
					self.battleInfo.stars = 3;
				elseif self.deathPlantNum > 0 and self.deathPlantNum <= 5 then
					if self.battleInfo.stars >= 2 then
						self.battleInfo.stars = 2;
					end
				else
					if self.battleInfo.stars >= 1 then
						self.battleInfo.stars = 1;
					end
				end
				self:setStarsView();
				self:setTipsText();
			end
		end
	elseif obj:GetMode() == EUnitType.TYPE_CREATURE_OBJECT then
		self:removeObjectSprite(obj:GetId());
	elseif obj:GetMode() == EUnitType.TYPE_BULLET then
		-- 平射子弹、魔法师闪电子弹不依赖逻辑通知去删除
		-- 平射子弹依赖界面碰撞检测
		-- 魔法师闪电子弹依照动画需求
		if obj.m_prop.animationType == EBulletAnimationType.NORMAL_TYPE then
			if obj.doDel then
				self:removeBulletSprite(obj:GetId());
			end
		elseif obj.m_prop.animationType == EBulletAnimationType.PARA_CURVE_TYPE then
			if obj.doDel then
				self:removeBulletSprite(obj:GetId(), target);
			end
		end
	end
end

-- 释放技能事件
function VBattleView:doSkillEvent( obj, target )
	local sprite = self:getSpriteWithObjData(obj);
	
	if sprite and sprite["doingSkill"] then
		sprite:doingSkill(obj, target);
	end
end

-- 释放技能前摇事件
function VBattleView:doSkillPreEvent( obj )
	local sprite = self:getSpriteWithObjData(obj);
	
	if sprite then
		sprite:doSkill(obj);
	end
end

-- 增加怪物事件
function VBattleView:doAddMonsterEvent( obj, battleUnit )
	if obj:GetMode() == EUnitType.TYPE_CREATURE then
		if self.battleInfo.playType == EBattlePlayType.PlayReplay then
			self:updateMonsterTableWithPropIdAndCount(obj);
		end
	elseif obj:GetMode() == EUnitType.TYPE_CREATURE_OBJECT then
		self:getObjectSprite(obj, battleUnit);
	end
end

-- 添加buff事件
function VBattleView:doAddBuffEvent( obj, buffId )
	local sprite = self:getSpriteWithObjData(obj);

	if sprite then
		sprite:addBuff(obj, buffId);
	end
end

-- 移除buff事件
function VBattleView:doDelBuffEvent( obj, buffId )
	local sprite = self:getSpriteWithObjData(obj);

	if sprite then
		sprite:delBuff(obj, buffId);
	end
end

-- 战斗结束事件
function VBattleView:doBattleEndEvent( )
	self:toDoBattleEnd();
end

-- 苏醒事件
function VBattleView:doWakeUpEvent( obj )
	local sprite = self:getSpriteWithObjData(obj);

	if sprite then
		sprite:doWakeUp(obj);
	end
end

-- 捡阳光事件
function VBattleView:doPickupSunshineEvent( obj )
	if self.battleInfo.playType == EBattlePlayType.PlayReplay then
		local sprite = self.SunshineList[obj.id];
		if sprite then
			sprite:doPickupAnimation();
		end
	end
end

-- 产生新阳光事件
function VBattleView:newSunsineEvent( obj, sunshineData )
	self:createSunshineSprite(obj, sunshineData);
end

-- 掉落
function VBattleView:doBattleDropEvent( obj, killReturnInfo, dieRetureInfo )
	-->测试日志
	-- for _, v in pairs(killReturnInfo.returnThingInfo) do
	--  	cclog(string.format("############:doBattleDropEvent:killReturnInfo :thingId = %s, count = %s",v.thingid,v.count));
	-- end
	-- for _, v in pairs(dieRetureInfo.returnThingInfo) do
	--  	cclog(string.format("############:doBattleDropEvent:dieRetureInfo thingId = %s, count = %s",v.thingid,v.count));
	-- end
	--<测试日志
	local tblDropItems = {};
	local userid = gData.userInfo.userid;
	local attackerId = self.battleInfo.attacker.userid;
	local defenderId = self.battleInfo.defender.userid;
	if userid == attackerId then 	--攻击方
		if obj:GetIsAttack() then
			for _, v in pairs(killReturnInfo.returnThingInfo) do
			 	self.battleInfo.spoils:addItem(false, v.count);
			end
			for _, v in pairs(dieRetureInfo.returnThingInfo) do
			 	local dropItem = DropItemData:new();
			 	dropItem.id = self:getDropItemId();
			 	dropItem.userId = attackerId;
			 	dropItem.type = v.type;
			 	dropItem.thingId = v.thingid;
			 	dropItem.count = v.count;

			 	table.insert(tblDropItems, dropItem);
			end
		else
			for _, v in pairs(killReturnInfo.returnThingInfo) do
			 	local dropItem = DropItemData:new();
			 	dropItem.id = self:getDropItemId();
			 	dropItem.userId = attackerId;
			 	dropItem.type = v.type;
			 	dropItem.thingId = v.thingid;
			 	dropItem.count = v.count;

			 	table.insert(tblDropItems, dropItem);
			end
			for _, v in pairs(dieRetureInfo.returnThingInfo) do
			 	self.battleInfo.spoils:addItem(false, v.count);
			end
		end
		self:showSpoilsViewAnimation(true);
	elseif userid == defenderId then
		if obj:GetIsAttack() then
			for _, v in pairs(killReturnInfo.returnThingInfo) do
			 	local dropItem = DropItemData:new();
			 	dropItem.id = self:getDropItemId();
			 	dropItem.userId = defenderId;
			 	dropItem.type = v.type;
			 	dropItem.thingId = v.thingid;
			 	dropItem.count = v.count;

			 	table.insert(tblDropItems, dropItem);
			end
			for _, v in pairs(dieRetureInfo.returnThingInfo) do
			 	self.battleInfo.spoils:addItem(true, v.count);
			end
		else
			for _, v in pairs(killReturnInfo.returnThingInfo) do
			 	self.battleInfo.spoils:addItem(true, v.count);
			end
			for _, v in pairs(dieRetureInfo.returnThingInfo) do
			 	local dropItem = DropItemData:new();
			 	dropItem.id = self:getDropItemId();
			 	dropItem.userId = defenderId;
			 	dropItem.type = v.type;
			 	dropItem.thingId = v.thingid;
			 	dropItem.count = v.count;

			 	table.insert(tblDropItems, dropItem);
			end
		end
		self:showSpoilsViewAnimation(true);
	else
		if obj:GetIsAttack() then
			for _, v in pairs(killReturnInfo.returnThingInfo) do
			 	local dropItem = DropItemData:new();
			 	dropItem.id = self:getDropItemId();
			 	dropItem.userId = defenderId;
			 	dropItem.type = v.type;
			 	dropItem.thingId = v.thingid;
			 	dropItem.count = v.count;

			 	table.insert(tblDropItems, dropItem);
			end
			for _, v in pairs(dieRetureInfo.returnThingInfo) do
			 	local dropItem = DropItemData:new();
			 	dropItem.id = self:getDropItemId();
			 	dropItem.userId = attackerId;
			 	dropItem.type = v.type;
			 	dropItem.thingId = v.thingid;
			 	dropItem.count = v.count;

			 	table.insert(tblDropItems, dropItem);
			end
		else
			for _, v in pairs(killReturnInfo.returnThingInfo) do
			 	local dropItem = DropItemData:new();
			 	dropItem.id = self:getDropItemId();
			 	dropItem.userId = attackerId;
			 	dropItem.type = v.type;
			 	dropItem.thingId = v.thingid;
			 	dropItem.count = v.count;

			 	table.insert(tblDropItems, dropItem);
			end
			for _, v in pairs(dieRetureInfo.returnThingInfo) do
			 	local dropItem = DropItemData:new();
			 	dropItem.id = self:getDropItemId();
			 	dropItem.userId = defenderId;
			 	dropItem.type = v.type;
			 	dropItem.thingId = v.thingid;
			 	dropItem.count = v.count;

			 	table.insert(tblDropItems, dropItem);
			end
		end
	end
	-- cclog(string.format("############:tblDropItems:"));
	-- for key,value in pairs(tblDropItems) do
	-- 	cclog(string.format("Id = %s, userid = %s, thingId = %s, count = %s",tostring(value.id),tostring(value.userId),tostring(value.thingId),tostring(value.count)));
	-- end
	self:showDropItems(obj, tblDropItems);
end

-------------------  EBattleLogEvent 动画事件  -------------------
-- 残肢事件
function VBattleView:doInjuryEvent( obj )
	if obj:GetIsAttack() then
		local sprite = self:getMonsterSprite(obj);
		if sprite then
			sprite:halfLifeAnimation();
		end
	else
		local sprite = self:getPlantSprite(obj);
		sprite:injuryAnimation(obj);
	end
end

-- 跳高事件
function VBattleView:doJumpEvent( obj )
	local sprite = self:getMonsterSprite(obj);
	sprite:jump();
end

-- 回旋镖碰撞事件
function VBattleView:doRotationImpactEvent( obj )
	local bulletSprite = self:getBulletSprite(obj);
	bulletSprite:doRotationImpactAnimation(obj);
end

-- 攻击植物获得资源事件
function VBattleView:doGetResourceEvent( obj, resource )
	if not obj:GetIsAttack() then
		self.battleInfo.spoils:reduceResource(resource);
		self:showSpoilsViewAnimation(true);

		-- 植物飘￥动画
		local sprite = self:getPlantSprite(obj);
		if sprite then
			sprite:showGetSpoilAnimation(resource);
		end
	end
end

-- 植物睡觉事件
function VBattleView:doSleepEvent( obj )
	local sprite = self:getSpriteWithObjData(obj);

	if sprite then
		sprite:doSleep(obj);
	end
end

-- 僵尸进场事件
function VBattleView:doZombieEnterEvent( obj )
	local sprite = self:getSpriteWithObjData(obj);

	if sprite then
		sprite:doEnter();
	end
end

-- 放置植物在死亡植物位置
function VBattleView:doResetPlantEvent( )
	-- if self.battleInfo.attackType == BattleType.BattleTypeEvp then
	-- 	if self.battleInfo.stars == 2 then
	-- 		self.battleInfo.stars = 1;
	-- 		self:setStarsView();
	-- 	end
	-- end
end

function VBattleView:doZombieActiveEvent( obj )
	self:addNextZombieEvent(obj);
end

-- 一大波僵尸动画 
function VBattleView:doWaveZombieEvent( )
	self.imgWaveZombieTitle:RunAction{{"fadeTo", 0, 255}, {"scaleTo", 0, 3}, {"show"}, {"scaleTo", 0.7, 1}, {"delayTime", 1}, {"fadeTo", 0.5, 0}, {"hide"}};
	gAudio:playEffect("battle_wave_zombie.ogg");
end

-------------------  动画事件回调  -------------------
-- 怪物死亡回调
function VBattleView:monsterIsValid( )
	if self.viewIsOver then
		-- 战斗已结束，不处理
		return;
	end

	-- 死亡后减少当前怪物总数
	if self.validTroopCount > 0 then
		self.validTroopCount = self.validTroopCount - 1;
		self.monstersDeathCount = self.monstersDeathCount + 1;
	end

	if self.validTroopCount <= 0 then
		-- 根据当前总数，判断界面战斗是否结束
		self:StartTimer("monsterAllDeadBattleEnd", 0, 0, 1.5);
	end
end

function VBattleView:monsterAllDeadBattleEnd( )
	self:StopTimer("monsterAllDeadBattleEnd");
	self.viewIsOver = true;
	self:toDoBattleEnd();
end

-- 怪物走到尽头回调
function VBattleView:monsterMoveEnd( road )
	-- 走到尽头 该道路被突破 获取相关资源
	if not self.breakRoadMaps[road] then
		self.breakRoadMaps[road] = road;

		local isGetSpoil = false;
		if getMapCount(self.breakRoadMaps) == #self.battleInfo.road then
			-- 突破所有道路，界面战斗结束
			-- self.viewIsOver = true;
			isGetSpoil = self.battleInfo.spoils:spoilAllResource();
			if self.battleInfo.attackType ~= BattleType.BattleTypeEvp then
				self.battleInfo.stars = 3;
				self:setStarsView();
			end
		else
			if self.battleInfo.attackType == BattleType.BattleTypeEvp then
				if self.battleInfo.stars > 0 then
					self.battleInfo.stars = 0;
					self:setStarsView();
				end
			else
				if getMapCount(self.breakRoadMaps) == 1 then
					if self.battleInfo.stars == 0 then
						self.battleInfo.stars = 1;
						self:setStarsView();
					end
				elseif getMapCount(self.breakRoadMaps) >= math.ceil(#self.battleInfo.road / 2) then
					if self.battleInfo.stars == 1 then
						self.battleInfo.stars = 2;
						self:setStarsView();
					end
				end
			end

			if not self.battleInfo:isDungeonBattle() then
				isGetSpoil = self.battleInfo.spoils:reduceResource(self.battleInfo.roadResource, getMapCount(self.breakRoadMaps));
				--[[test
				if not self.battleInfo.roadResource[AttrType.AttrTypeBattleScore][getMapCount(self.breakRoadMaps)] then
					if self.battleInfo.roadResource[AttrType.AttrTypeBattleScore] then
						for k,v in pairs(self.battleInfo.roadResource[AttrType.AttrTypeBattleScore]) do
							cclog("********** AttrTypeBattleScore k = %d, v =%d", k, v);
						end
					else
						cclog("****** self.battleInfo.roadResource[AttrType.AttrTypeBattleScore] = nil");
					end
					if self.breakRoadMaps then
						cclog("**** AttrTypeBattleScore getMapCount(self.breakRoadMaps) = "..getMapCount(self.breakRoadMaps));
					end
				end
				--]]
				self.battleInfo.spoils:reduceScore(self.battleInfo.roadResource[AttrType.AttrTypeBattleScore][getMapCount(self.breakRoadMaps)]);
				--[[test
				if not self.battleInfo.roadResource[RES_DATA_TYPE.ResDataTypeItem][getMapCount(self.breakRoadMaps)] then
					if self.battleInfo.roadResource[RES_DATA_TYPE.ResDataTypeItem] then
						for k,v in pairs(self.battleInfo.roadResource[RES_DATA_TYPE.ResDataTypeItem]) do
							cclog("********** ResDataTypeItem k = %d, v =%d", k, v);
						end
					else
						cclog("****** self.battleInfo.roadResource[RES_DATA_TYPE.ResDataTypeItem] = nil");
					end
					if self.breakRoadMaps then
						cclog("**** ResDataTypeItem getMapCount(self.breakRoadMaps) = "..getMapCount(self.breakRoadMaps));
					end
				end
				--]]
				self.battleInfo.spoils:reduceItem(self.battleInfo.roadResource[RES_DATA_TYPE.ResDataTypeItem][getMapCount(self.breakRoadMaps)]);
			else
				isGetSpoil = false;
			end
		end

		self:openFinalSpoilBox(road, isGetSpoil);
		self:setTipsText();
		self:showSpoilsViewAnimation(true);
	end

	-- self:toDoBattleEnd();
end

function VBattleView:finishOpenBox( road )
	if not self.openBoxList[road] then
		self.openBoxList[road] = 1;
	end

	if #self.battleInfo.road == getMapCount(self.openBoxList) then
		-- 突破所有道路，界面战斗结束
		self.viewIsOver = true;
		self:toDoBattleEnd();
	end
end

-------------------  音效处理  -------------------
function VBattleView:playSound( sound, randomMax )
	if randomMax then
		local randomIndex = math.random(1,randomMax);
		local soundName = sound..randomIndex..".ogg";
		gAudio:playEffect(soundName);
	else
		local soundName = sound..".ogg";
		gAudio:playEffect(soundName);
	end
end

--------------------------------------------    Table Function    --------------------------------------------

function VBattleView:onCell(index, table, cell)
	if table == self.monsterTable then
		return self:initMonsterTableCell(index, cell);
	elseif table == self.detailMonsterTable then
		return self:initDetailMonsterTableCell( index, cell);
	end
end

function VBattleView:initMonsterTableCell( index, cell )
	if not cell then
		cell = VTableViewCell("vMonsterTableViewcell.vui");
	end
	local battleUnit = self.battleInfo.battleUnitList[index+1];

	if battleUnit then
		cell("creatureIcon"):setVisible(true);

		local imageName = battleUnit.basicProp.image.."Card.png";
		local cost = 0;
		local selectDetailUnitData = self.detailUnitData[index+1];
		local selectQuality = self.selectQuality[index+1];
		if selectDetailUnitData and selectDetailUnitData.basicProp.classType == battleUnit.basicProp.classType and selectQuality then
			local selectUint = nil;
			for i,v in ipairs(selectDetailUnitData.childUnit) do
				if v.quality == selectQuality then
					selectUint = v;
					break;
				end
			end
			if selectUint then
				imageName = selectUint.image.."Card.png";
				cell("creatureCost").text = selectUint.cost;
				local unitlevel = 0;
				if selectDetailUnitData.unitLevel[selectUint.quality] and #selectDetailUnitData.unitLevel[selectUint.quality] > 0 then
					unitlevel = selectDetailUnitData.unitLevel[selectUint.quality][#selectDetailUnitData.unitLevel[selectUint.quality]];
				end

				cell("creatureLevelText").text = unitlevel;
				if unitlevel == 0 then
					cell("creatureLevel").image = "battleStartBlack.png";
				else
					cell("creatureLevel").image = "battleStart.png";
				end
				cell("creatureCard").image = "battleCard"..selectUint.quality..".png";
				cost = selectUint.cost;
			end
		else
			local qualityIndex = #battleUnit.childUnit;
			local prop = battleUnit.childUnit[qualityIndex];
			while battleUnit.childCount[prop.quality] == 0 do
				qualityIndex = qualityIndex - 1;
				if qualityIndex == 0 then
					break;
				else
					prop = battleUnit.childUnit[qualityIndex];
				end
			end

			if prop then
				cell("creatureCost").text = prop.cost;
				local unitlevel = 0;
				if battleUnit.unitLevel[prop.quality] and #battleUnit.unitLevel[prop.quality] > 0 then
					unitlevel = battleUnit.unitLevel[prop.quality][#battleUnit.unitLevel[prop.quality]];
				end

				cell("creatureLevelText").text = unitlevel;
				if unitlevel == 0 then
					cell("creatureLevel").image = "battleStartBlack.png";
				else
					cell("creatureLevel").image = "battleStart.png";
				end

				cell("creatureCard").image = "battleCard"..prop.quality..".png";
				imageName = prop.image.."Card.png";
				cost = prop.cost;
				self.selectQuality[index+1] = prop.quality;
			else
				cell("creatureCost").text = "";
			end
		end

		cell("creatureIcon").image = imageName;
		
		if self.battleInfo.playType == EBattlePlayType.PlayAttack then
			-- cclog("*************** onCell,  self.selectCreature = %d, index = %d ", self.selectCreature, index);
			cell("creatureLayer").onClick = "gView('BattleView'):monsterTableOnCellTouch("..index..")";
		end

		local isGray = false;
		if battleUnit.unitCount > 0 then
			cell("creatureCount").text = "x"..battleUnit.unitCount;

			if self.battle then
				if self.battle:GetSunshineValue() >= cost then
					cell("creatureLayer").gray = 0;
					cell("creatureLayer").touch = 1;
				else
					isGray = true;
				end
			end
		else
			isGray = true;
			cell("creatureCount").text = "x"..0;
		end

		if isGray then
			cell("creatureLayer").gray = 1;
			cell("creatureLayer").touch = 0;
			cell("creatureCost").color = {255,0,0};
		else
			cell("creatureCost").color = {255,255,255};
		end

		if battleUnit.childUnit and #battleUnit.childUnit > 1 then
			cell("battleArrows").visible = 1;
		else
			cell("battleArrows").visible = 0;
		end

		if self.selectCreature == (index + 1) then
			if isGray then
				cell("selectCreatureImg").visible = 0;
				cell("battleArrows").image = "battleSelectRightArrow.png";
				cell("creatureLayer").offset={0,0};
			else
				cell("selectCreatureImg").visible = 1;
				cell("battleArrows").image = "battleSelectLeftArrow.png";
				cell("creatureLayer").offset={18,0};
			end
		else
			cell("selectCreatureImg").visible = 0;
			cell("battleArrows").image = "battleSelectRightArrow.png";
			cell("creatureLayer").offset={0,0};
		end
	else
		cell("creatureIcon"):setVisible(false);
	end

	return cell;
end

function VBattleView:initDetailMonsterTableCell( index, cell )
	if not cell then
		cell = VTableViewCell("vMonsterTableViewcell.vui");
	end

	cell("selectCreatureImg").visible = 0;
	cell("battleArrows").visible = 0;

	local i = 0;
	local selectDetailUnitData = self.detailUnitData[self.selectCreature];
	if selectDetailUnitData then
		local unitProp = selectDetailUnitData.childUnit[index+1];

		if unitProp then
			cell("creatureIcon"):setVisible(true);
			cell("creatureIcon").image = unitProp.image.."Card.png";
			local unitlevel = 0;
			if selectDetailUnitData.unitLevel[unitProp.quality] and #selectDetailUnitData.unitLevel[unitProp.quality] > 0 then
				unitlevel = selectDetailUnitData.unitLevel[unitProp.quality][#selectDetailUnitData.unitLevel[unitProp.quality]];
			end

			cell("creatureLevelText").text = unitlevel;
			if unitlevel == 0 then
				cell("creatureLevel").image = "battleStartBlack.png";
			else
				cell("creatureLevel").image = "battleStart.png";
			end

			cell("creatureCost").text = unitProp.cost;
			cell("creatureCard").image = "battleCard"..unitProp.quality..".png";

			local unitCount = selectDetailUnitData.childCount[unitProp.quality];
			if unitCount <= 0 then
				cell("creatureLayer").gray = 1;
				cell("creatureCount").text = "x"..0;
			else
				cell("creatureLayer").gray = 0;
				cell("creatureCount").text = "x"..unitCount;
			end
			cell("creatureCost").color = {255,255,255};
			cell("creatureLayer").onClick = "gView('BattleView'):detailMonsterTableOnCellTouch("..unitProp.quality..")";
		else
			cell("creatureIcon"):setVisible(false);
		end
	else
		cell("creatureIcon"):setVisible(false);
	end

	return cell;
end

function VBattleView:monsterTableOnCellTouch(index)
	if self.readyDoubleClick and self.selectCreature == index + 1 then
		local battleUnit = self.battleInfo.battleUnitList[self.selectCreature];
		if battleUnit.childUnit and #battleUnit.childUnit > 1 then
			self:showDetailMonsterLayer();
			return;
		end
	end

	self:selectSupportUnit(false);
	self:StopTimer("startDoubleClickTime");
	self.readyDoubleClick = true;
	self:StartTimer("startDoubleClickTime", 0, 0, 1);

	self:selectMonsterCellWithIndex(index);
end

function VBattleView:detailMonsterTableOnCellTouch( quality )
	local selectDetailUnitData = self.detailUnitData[self.selectCreature];
	if selectDetailUnitData then
		if selectDetailUnitData.childCount[quality] > 0 then
			self.selectQuality[self.selectCreature] = quality;
			self.monsterTable:updateCellAtIndex(self.selectCreature-1);
		end
	end
end

function VBattleView:startDoubleClickTime( )
	self.readyDoubleClick = false;
	self:StopTimer("startDoubleClickTime");
end

function VBattleView:selectMonsterCellWithIndex( index )
	if self.selectCreature == index + 1 then
		return;
	end

	local lastIndex = self.selectCreature;
	self.selectCreature = index + 1;
	if lastIndex - 1 >= 0 then
		self.monsterTable:updateCellAtIndex(lastIndex-1);	
	end
	self.monsterTable:updateCellAtIndex(index);
end

function VBattleView:showDetailMonsterLayer( )
	local battleUnit = self.battleInfo.battleUnitList[self.selectCreature];
	self.detailUnitData[self.selectCreature] = battleUnit;
	if battleUnit.childUnit then
		self.detailMonsterTable.number = #battleUnit.childUnit;
	else
		self.detailMonsterTable.number = 0;
	end
	self.detailMonsterTable:reloadData();
	self.detailMonsterLayer.visible = 1;
end

function VBattleView:closeDetailMonsterLayer( )
	self.detailMonsterLayer.visible = 0;	
end

function VBattleView:updateMonsterTableWithPropIdAndCount( pCreature )
	local index = 0;
	local race = pCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE);
	self.battleInfo:removeBattleUnit(race, pCreature.m_quality);
	for i,v in ipairs(self.battleInfo.battleUnitList) do
		if v.basicProp.classType == race then
			index = i;
			break;
		end
	end

	if index > 0 then
		self.monsterTable:updateCellAtIndex(index-1);
	end
end

-- 帧事件回调
function VBattleView:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	if evt == "finishEnter" then
		local armature = bone:getArmature();
		self("carArmature"..armature.road).isOpen = false;
		self("carArmature"..armature.road):play("idle");
		if self.battleInfo.playType == EBattlePlayType.PlayAttack and self.battleInfo.attackType ~= BattleType.BattleTypeEvp then
			-- self("touchLayer"..armature.road):setVisible(true);
		end
	elseif evt == "finishBack" then
		local armature = bone:getArmature();
		if gBattleView.battleInfo.attackType == BattleType.BattleTypeEvp then
			self("carArmature"..armature.road):play("idle2");
		else
			self("carArmature"..armature.road):play("idle");
		end
	end
end

function VBattleView:onMoveBase( touch )
	if self.battleInfo.playType == EBattlePlayType.PlayReplay then
		return;
	end
	
	VBattleView.super.onMoveBase(self, touch);
	self:startPickupSunshine(touch);
	self:startPickupDropItem(touch);
end

function VBattleView:onTouchBase( touch )
	if self.battleInfo.playType == EBattlePlayType.PlayReplay then
		return;
	end
	
	VBattleView.super.onTouchBase(self, touch);
	self.picking = false;
	self:startPickupSunshine(touch);
	self:startPickupDropItem(touch);
end

function VBattleView:onLeaveBase(touch)
	if self.battleInfo.playType == EBattlePlayType.PlayReplay then
		return;
	end

	VBattleView.super.onLeaveBase(self, touch);
	self.picking = false;
	self:unSelectShovelBtnClick();
end

function VBattleView:startPickupSunshine( touch )
	if self.selectShovel then
		return;
	end
	for k,v in pairs(self.SunshineList) do
		if v and v.image and (not v.isPicking) and self:IsImageInRect(v.image, touch) and v.imagetouch then
			self.picking = true;
			self:pickupSunshine(v.mId);
		end;
	end;		
end

function VBattleView:startPickupDropItem( touch )
	if self.selectShovel then
		return;
	end
	for k,v in pairs(self.DropItemList) do
		if v and v.image and (not v.isPicking) and self:IsImageInRect(v.image, touch) and v.imagetouch then
			self.picking = true;
			self:pickupDropItem(v.mId);
		end;
	end;		
end

function VBattleView:IsImageInRect(image, touch)
	local location = image:convertTouchToNodeSpace(touch);
	local size = image.size;
	local rect = cc.rect(0-size.width/2, 0-size.height/2, size.width*2, size.height*2);
	if cc.rectContainsPoint(rect, location) then
		return true;
	end
	return false;
end

function VBattleView:preloadBattleSpriteRes()
	local data = gBattleResource:GetBattleSpriteImgs();
	for key,value in pairs(data) do
		VArmature:addArmatureFile(key);
	end
	data = gBattleResource:GetBattlePeaSpriteImgs();
	for key,value in pairs(data) do
		local nameList = {key.."Body", key.."Child"};
		for i,armatureName in ipairs(nameList) do
			VArmature:addArmatureFile(armatureName);
		end
	end
end

function VBattleView:openScaleTest( )
	self.scaleTest = true;
	self.scaleTestValue = 60;
	self("battleTestLayer").visible = 1;
end

function VBattleView:testBattleA( )
	if self.scaleTest then
		self.scaleTestValue = self.scaleTestValue - 1;
		self("textTest2").text = self.scaleTestValue;
	end
end

function VBattleView:testBattleB( )
	if self.scaleTest then
		if self.useTestScale then
			self.useTestScale = false;
			self("btnTest2").text = "【0】";
		else
			self.useTestScale = true;
			self("btnTest2").text = "【测试】";
		end
	end
end

function VBattleView:testBattleC( )
	if self.scaleTest then
		self.scaleTestValue = self.scaleTestValue + 1;
		self("textTest2").text = self.scaleTestValue;
	end
end

function VBattleView:showBattleTestScale( csvValue, testValue )
	if self.scaleTest then
		self("textTest1").text = csvValue;
		self("textTest2").text = testValue;
	end
end
