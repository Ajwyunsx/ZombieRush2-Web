--VBattleResultDlg.lua

VBattleResultDlg = VClass("BattleResultDlg", VMsgBox)

function VBattleResultDlg:Init(attr)
	VMsgBox.Init(self, attr);
end

function VBattleResultDlg:onPush()
	self.btnClose = self("btnClose");

	self.resultLayer = self("resultLayer");
	self.resultArmatureLayer = self("resultArmatureLayer");
	self.resourceLayer = self("resourceLayer");
	self.layDetail = self("layDetail");
	self.imgDetailBG = self("imgDetailBG");
	self.goldText = self("goldText");
	self.sunText = self("sunText");
	self.itemText = self("itemText");

	self.itemLayer = self("itemLayer");
	self.deathLayer = self("deathLayer");

	self.textItemNum = self("textItemNum");
	self.tabSpoilsView = self("tabSpoilsView");
	self.textNoSpoils = self("textNoSpoils");

	self.textPlantDeadNum = self("textPlantDeadNum");
	self.textMonsterDeadNum = self("textMonsterDeadNum");
	self.tabPlantDeathView = self("tabPlantDeathView");
	self.tabMonsterDeathView = self("tabMonsterDeathView");
	self.textNoPlantDeath = self("textNoPlantDeath");
	self.textNoMonsterDeath = self("textNoMonsterDeath");
end

function VBattleResultDlg:onKeyBack()
	return false;
end

function VBattleResultDlg:showResultView( isReplay, attackType )
	self.isReplay = isReplay;
	self.attackType = attackType;

	self.cellAnimation = true;
	self.opacity = 0;
	self:ReLayout();

	self.goldText.text = self.battleResult.spoils.gold;
	self.sunText.text = self.battleResult.spoils.sunshine;
	self.itemText.text = self.battleResult.spoils.itemCount;

	self.isShowDeath = false;
	self:showResultArmature();
	self:setResultValueView();
	self:setResultDeathView();

	self.resultLayer.touch = 0;
	self.resultLayer:RunAction{{"delayTime", 5}, {"hide"}};
	self.resultArmatureLayer:RunAction{{"delayTime", 5}, {"hide"}};
	self.layDetail:RunAction{{"delayTime", 5}, {"show"}};
	self.imgDetailBG:RunAction{{"delayTime", 5}, {"show"}};

	-- gBattleView:playSound("battle_Result_Lost_", 2);
	-- local randomIndex = math.random(1,2);
	-- if randomIndex == 1 then
	-- 	gBattleView:playSound("battle_Result_No");
	-- end
end

function VBattleResultDlg:showResultArmature( )
	if self.battleResult.stars <= 0 then
		self.resultArmatureName = "battleResultLost";
	else
		self.resultArmatureName = "battleResultWin";
	end

	local resultSize = self.resultArmatureLayer:getContentSize();
	local scaleX = resultSize.width / 800;
	local scaleY = resultSize.height / 480;
	local armatureScale = math.max(math.max(scaleX, scaleY), 1);
	self.itemLayer.scale = math.max(math.min(scaleX, scaleY), 1);
	self.deathLayer.scale = math.max(math.min(scaleX, scaleY), 1);

	self.resultArmature = VArmature:createArmature(self.resultArmatureName, "", "DownLeft");
	self.resultArmature.scale = armatureScale;
	self.resultArmatureLayer:Push(self.resultArmature);
	self.resultArmature:ReLayout();

	local pos = cc.p(self.resultArmatureLayer:getContentSize().width * 0.5, self.resultArmatureLayer:getContentSize().height * 0.5);
	self.resultArmature:setPosition(pos.x, pos.y);
	-- forTestCheckPos(self.resultLayer, pos.x, pos.y);
	self.resultArmature.visible = 1;

	local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
		self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
	end 
	self.resultArmature:setEventCallFunc(callBack);

	self.haveData = false;
	if self.battleResult.stars > 0 then
		for i=1,3 do
			if i > self.battleResult.stars then
				local bone = self.resultArmature:getBone("star"..i);
				if bone then
					self.resultArmature:changeDisplay("star"..i, nil, -1);
				end
			end
		end
		self.haveData = true;
	elseif (self.battleResult.spoils.gold + self.battleResult.spoils.sunshine + self.battleResult.spoils.itemCount) > 0 then
		self.haveData = true;
	end

	if self.haveData then
		self.resultArmature:play("show");
	else
		self.resultArmature:play("showLost");
	end

	if gBattleView then
		if self.battleResult.stars <= 0 then
			gBattleView:playSound("battle_Result_Lost_", 2);
		else
			gBattleView:playSound("battle_Result_Win_", 2);
		end
	end
end

function VBattleResultDlg:showIdleAnimation( )
	if self.haveData then
		self.resultArmature:play("idle");
	else
		self.resultArmature:play("idleLost");
	end
	self.resultLayer.touch = 1;
	if self.haveData then
		self.resourceLayer.scale = self.resultArmature.scale;
		self.resourceLayer:ReLayout();
		self.resourceLayer:setAnchorPoint(cc.p(0,0));
		self.resourceLayer.visible = 1;
		local pos = self.resultArmature:getBonePos("resultNode");
		self.resourceLayer:setPosition(pos.x, pos.y);	
	end
end

-- 帧事件回调
function VBattleResultDlg:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	if evt == "finishShow" then
		self:showIdleAnimation();
	end
end

function VBattleResultDlg:showDetailView( )
	self.resultLayer.touch = 0;
	self.resultLayer:RunAction{{"hide"}};
	self.resultArmatureLayer:RunAction{{"hide"}};
	self.layDetail:RunAction{{"show"}};
	self.imgDetailBG:RunAction{{"show"}};
	-- self.resultLayer:RunAction{{"fadeTo", 1, 0}, {"hide"}};
	-- self.layDetail:RunAction{{"fadeTo", 0, 0}, {"show"}, {"fadeTo", 1, 255}};
end

function VBattleResultDlg:showMsgBoxColor( )
	-- self:RunAction{{"fadeTo", 0.5, 255}};
	self:RunAction({"repeatForever", {"sequence", {"delayTime", 0.05}, {self, "changeMsgBoxColor"}}});
end

function VBattleResultDlg:changeMsgBoxColor( ) 
	local addOpacity = 10
	if self.opacity + addOpacity > 127 then
		self.opacity = 127;
		self:stopAllActions();
	else
		self.opacity = self.opacity + addOpacity;
	end
end

function VBattleResultDlg:setResultDeathView( )
	local dieCount = 0;
	local plantCount = 0;
	if self.battleResult.diePlantList then
		for i,v in ipairs(self.battleResult.diePlantList) do
			dieCount = dieCount + v.count;
		end
		plantCount = #self.battleResult.diePlantList;
	end
	self.textPlantDeadNum.text = dieCount;

	dieCount = 0;
	local monsterCount = 0;
	if self.battleResult.dieMonsterList then
		for i,v in ipairs(self.battleResult.dieMonsterList) do
			dieCount = dieCount + v.count;
		end
		monsterCount = #self.battleResult.dieMonsterList;
	end
	self.textMonsterDeadNum.text = dieCount;

	if plantCount > 0 then
		self.textNoPlantDeath.visible = 0;
	else
		self.textNoPlantDeath.visible = 1;
	end

	if monsterCount > 0 then
		self.textNoMonsterDeath.visible = 0;
	else
		self.textNoMonsterDeath.visible = 1;
	end	

	self.tabPlantDeathView.delegate = self;
	self.tabPlantDeathView.number = plantCount;
	self.tabPlantDeathView:reloadData();

	self.tabMonsterDeathView.delegate = self;
	self.tabMonsterDeathView.number = monsterCount;
	self.tabMonsterDeathView:reloadData();
end

function VBattleResultDlg:setResultValueView( )
	self.spoilsList = {};

	local tempList = {};
	if self.battleResult.spoils.itemInfos then
		for i,v in ipairs(self.battleResult.spoils.itemInfos) do
			-- cclog("****** i = %d, v.id = %f, v.count = %f, v.name = %s,  v.image = %s", i, v.id, v.count, v.name,  v.image);
			if #tempList < 1 then
				table.insert(tempList, v);
			else
				local itemList = {tempList[1], v};
				table.insert(self.spoilsList, itemList);
				tempList = {};
			end
		end
	end

	if #tempList > 0 then
		local itemList = {};
		for i=1,#tempList do
			table.insert(itemList, tempList[i]);
			-- cclog("**** #itemList = %d", #itemList);
		end
		table.insert(self.spoilsList, itemList); 
		-- cclog("**** #self.spoilsList = %d", #self.spoilsList);
	end

	self.tabSpoilsView.delegate = self;
	self.tabSpoilsView.number = #self.spoilsList;
	self.tabSpoilsView:reloadData();
	
	if #self.spoilsList > 0 then
		self.textNoSpoils.visible = 0;
	else
		self.textNoSpoils.visible = 1;
	end

	self.textItemNum.text = "合计："..self.battleResult.spoils.itemCount;
end

function VBattleResultDlg:changeView( )
	if not self.isShowDeath then
	-- 	self.itemLayer.visible = 1;
	-- 	self.deathLayer.visible = 0;
	-- 	self.isShowDeath = false;
	-- else
		self.itemLayer.visible = 0;
		self.deathLayer.visible = 1;
		self.isShowDeath = true;
	end
end

function VBattleResultDlg:onCell(index, table, cell)
-- 	tabPlantDeathView
-- tabMonsterDeathView
	if table == self.tabPlantDeathView then
		if not cell then
			cell = VTableViewCell("vBattleDeathCell.vui");
		end

		local plant = self.battleResult.diePlantList[index+1];
		if plant then
			-- plant.name
			cell("creatureIcon").image = plant.image.."S.png";
			cell("creatureCount").text = plant.count;
		end

	elseif table == self.tabMonsterDeathView then
		if not cell then
			cell = VTableViewCell("vBattleDeathCell.vui");
		end

		local zombie = self.battleResult.dieMonsterList[index+1];
		if zombie then
			-- zombie.name
			cell("creatureIcon").image = zombie.image.."L.png";
			cell("creatureCount").text = zombie.count;
		end
		cell("creatureIcon").scale = 0.8;

	elseif table == self.tabSpoilsView then
		if not cell then
			cell = VTableViewCell("vBattleSpoilsCell.vui");
		end
		local spoils = self.spoilsList[index+1];

		if spoils then
			for i=1,#spoils do
				local thingInfo = spoils[i];
				local tempImage = VImage{image=thingInfo.image};
				local size = 60;
				if thingInfo.type == ThingType.ThingTypePlant or thingInfo.type == ThingType.ThingTypeArm then
					size = 54;
				end
				local scaleX = size / tempImage:getContentSize().width;
				local scaleY = size / tempImage:getContentSize().height;
				tempImage:Delete();

				cell("objName"..i).text = thingInfo.name;
				cell("objIcon"..i).image = thingInfo.image;
				cell("objIcon"..i):setScaleX(scaleX);
				cell("objIcon"..i):setScaleY(scaleY);
				cell("objCount"..i).text = "x "..thingInfo.count;
				cell("layObj"..i).visible = 1;
			end
		end
	end
end

function VBattleResultDlg:finishReplayButton( )
	gBattleView:finishCloseingBattle();

	if self.isReplay then
		self.isReadyReplay = true;
	end
end

function VBattleResultDlg:btnCloseAction()
	-- if self.isReplay and not self.isReadyReplay then
	-- 	return;
	-- end
	local isQuit = false;
	if self.dungeonId and self.battleResult.stars > 0 then
		if gData.userInfo.dungeonInfo:CheckShopValidEx(self.dungeonId) then
			local dlg = gData.userInfo.dungeonInfo:OpenShopDlgEx(self.dungeonId, nil, self.level+1);
		else
			isQuit = true;
		end
	else
		isQuit = true;
	end

	if gBattleView and isQuit then
		VCallBack(gBattleView, "exitBattle");
	end
end

function VBattleResultDlg:btnReplayAction( )
	if self.isReplay and not self.isReadyReplay then
		return;
	end

	if gBattleView then
		VCallBack(gBattleView, "readyReplayBattleAgain");
		self:onClick();
	end
end