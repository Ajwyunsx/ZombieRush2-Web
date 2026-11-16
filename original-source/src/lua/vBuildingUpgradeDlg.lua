VBuildingUpgradeDlg = VClass("BuildingUpgradeDlg", VMsgBox);

function VBuildingUpgradeDlg:SetBuildingType( aType )
	
	self.aType = aType;
end

function VBuildingUpgradeDlg:onPush(  )
	self("titleText").text = "建筑升级";
	if self.aType == BUILDING_TYPE.BuildingAltar then 
		self:InitAltarDlg();
	elseif self.aType == BUILDING_TYPE.BuildingLaboratory then
		self:InitLaboratoryDlg();
	elseif self.aType == BUILDING_TYPE.BuildingStore then
		self:InitStoreDlg();
	elseif self.aType == BUILDING_TYPE.BuildingBasecamp then
		self:InitBasecampDlg();
	end
end

function VBuildingUpgradeDlg:onClick()
end

--显示太阳神庙升级信息
function VBuildingUpgradeDlg:InitAltarDlg()
	local info = gData.userInfo.manorInfo.altarInfo;
	self("nameText").text = "太阳神殿";
	self("levelText").text = (info.level+1).."级";
	local centerImg = self("tipBgImg");
	centerImg.size = {327,100};
	self("exploinText").text = "\t      多么神圣的建筑，它会在战斗中帮助你制造出阳光和月光，提升它的等级绝对是明智之选。";

	local limit1 = VText{name="limitText1",color={90,40,0}, layout="LeftDown", offset={20,-10}, fontSize=15, relative="tipBgImg"};
	local limit2 = VText{name="limitText2",color={90,40,0}, layout="LeftUpOut", offset={0,0}, fontSize=15, relative="limitText1"};
	limit1.text = "月光产量：";
	limit2.text = "阳光产量：";
	local sunIcon = VImage{name="sunIcon",image="icon_sun_S.png", layout="RightOut", relative="limitText2"};
	local moonIcon = VImage{name="moonIcon",image="icon_yueguang_S.png", layout="RightOut", relative="limitText1"};
	
	local t1 = info.sunshineCount.."/"..info.sunshinePeriod.."秒";
	local t2 = info.darkSunshineCount.."/"..info.darkSunshinePeriod.."秒";
	local sunText = VText{name="sunText",text=t1, fontSize=15, color={90,40,0}, layout="RightOut", relative="sunIcon"};
	local moonText = VText{name="moonText",text=t2, fontSize=15, color={90,40,0}, layout="RightOut", relative="moonIcon"};

	centerImg:Push(limit1);
	centerImg:Push(limit2);
	centerImg:Push(sunIcon);
	centerImg:Push(moonIcon);
	centerImg:Push(sunText);
	centerImg:Push(moonText);

	local toImg1 = VImage{name="toImg1",image="minijiantou.png", layout="RightOut", relative="limitText2", offsetP={0.3,0}};
	local toImg2 = VImage{name="toImg2",image="minijiantou.png", layout="RightOut", relative="limitText1", offsetP={0.3,0}};
	local nextSun = info.nextSunshineCount.."/"..info.nextSunshinePeriod.."秒";
	local nextDark = info.nextDarkSunshineCount.."/"..info.nextDarkSunshinePeriod.."秒";
	local nextSunText = VText{text=nextSun, fontSize=15, color={90,40,0}, layout="RightOut", relative="toImg1", offset={20,0}};
	local nextCoinText = VText{text=nextDark, fontSize=15, color={90,40,0}, layout="RightOut", relative="toImg2", offset={20,0}};

	centerImg:Push(toImg1);
	centerImg:Push(toImg2);
	centerImg:Push(nextSunText);
	centerImg:Push(nextCoinText);

	local c1 = self("conditionLayer1");
	c1("icon").image = "icon_basecamp.png";
	c1("tip").text = "庄园达到"..info.baseCampLimit.."级";

	local c2 = self("conditionLayer2");
	c2("icon").image = "icon_daojishi.png";
	c2("tip").text = self:FormatString(info.upgradeTime);

	local c3 = self("conditionLayer3");
	c3("icon").image = "icon_jinbi.png";
	c3("tip").text = info.upgradeSunshine;

	local c4 = self("conditionLayer4");
	c4("icon").image = "icon_yibi.png";
	c4("tip").text = info.upgradeCoin;

	self("sureBtn").onClick = "node:Parent(1):LevelUp("..BUILDING_TYPE.BuildingAltar..")";
	self("buildImg").image = "mv_shendian.png";
end

--显示实验室升级信息
function VBuildingUpgradeDlg:InitLaboratoryDlg()
	local info = gData.userInfo.manorInfo.laboratory;
	local centerImg = self("tipBgImg");
	centerImg.size = {327,100};
	self("nameText").text = "研究所";
	self("levelText").text = (info.level+1).."级";
	self("exploinText").text = "\t      研究所拥有现代科技，能够把僵尸卡牌升至更高的星级。";

	local limit1 = VText{name="limitText1",color={90,40,0}, layout="LeftDown", offset={15,-10}, fontSize=14, relative="tipBgImg"};
	local limit2 = VText{name="limitText2",color={90,40,0}, layout="LeftUpOut", offset={0,0}, fontSize=14, relative="limitText1"};
	limit2.text = "升星容器："..info.monsterLimit.."个";
	limit1.text = string.format("卡牌星级：最高升至%d星", info.level);
	centerImg:Push(limit1);
	centerImg:Push(limit2);
	local toImg1 = VImage{name="toImg1",image="minijiantou.png", layout="Left", relative="limitText2", offsetP={0.5,0}};
	local toImg2 = VImage{name="toImg2",image="minijiantou.png", layout="Left", relative="limitText1", offsetP={0.5,0}};

	local nextLimit1 = VText{name="nextLimit1",color={90,40,0}, layout="RightOut", offset={20,0}, fontSize=14, relative="toImg1"};
	local nextLimit2 = VText{name="nextLimit2",color={90,40,0}, layout="RightOut", offset={20,0}, fontSize=14, relative="toImg2"};
	nextLimit1.text = info.nextMonsterLimit.."个";
	nextLimit2.text = string.format("%d星", info.level+1);
	centerImg:Push(toImg1);
	centerImg:Push(toImg2);
	centerImg:Push(nextLimit1);
	centerImg:Push(nextLimit2);

	local c1 = self("conditionLayer1");
	c1("icon").image = "icon_basecamp.png";
	c1("tip").text = "庄园达到"..info.baseCampLimit.."级";

	local c2 = self("conditionLayer2");
	c2("icon").image = "icon_daojishi.png";
	c2("tip").text = self:FormatString(info.upgradeTime);

	local c3 = self("conditionLayer3");
	c3("icon").image = "icon_jinbi.png";
	c3("tip").text = info.upgradeSunshine;

	local c4 = self("conditionLayer4");
	c4("icon").image = "icon_yibi.png";
	c4("tip").text = info.upgradeCoin;

	self("sureBtn").onClick = "node:Parent(1):LevelUp("..BUILDING_TYPE.BuildingLaboratory..")";
	self("buildImg").image = "mv_shiyanshi.png";
end

--显示金库升级信息
function VBuildingUpgradeDlg:InitStoreDlg()
	local info = gData.userInfo.manorInfo.storeInfo;
	self("nameText").text = "金库";
	
	self("levelText").text = (info.level+1).."级";
	self("exploinText").text = "\t      您珍贵的金币和银币都存在这里，升级金库等级可以增加金币和银币的存储上限。";
	local centerImg = self("tipBgImg");
	centerImg.size = {327,100};
	-- centerImg.fill = {0.4,0.22};
	local limit1 = VText{name="limitText1",color={90,40,0}, layout="LeftDown", offset={20,-10}, fontSize=15, relative="tipBgImg"};
	local limit2 = VText{name="limitText2",color={90,40,0}, layout="LeftUpOut", offset={0,0}, fontSize=15, relative="limitText1"};
	limit2.text = "金币上限：";
	limit1.text = "银币上限：";
	local sunIcon = VImage{name="sunIcon",image="icon_jinbi_S.png", layout="RightOut", relative="limitText2"};
	local coinIcon = VImage{name="coinIcon",image="icon_yibi_S.png", layout="RightOut", relative="limitText1"};
	local sunText = VText{name="sunText",text=info.sunshineMax, fontSize=15, color={90,40,0}, layout="RightOut", relative="sunIcon", format=1};
	local coinText = VText{name="coinText",text=info.coinMax, fontSize=15, color={90,40,0}, layout="RightOut", relative="coinIcon", format=1};

	centerImg:Push(limit1);
	centerImg:Push(limit2);
	centerImg:Push(sunIcon);
	centerImg:Push(coinIcon);
	centerImg:Push(sunText);
	centerImg:Push(coinText);

	local toImg1 = VImage{name="toImg1",image="minijiantou.png", layout="RightOut", relative="limitText2", offsetP={0.3,0}};
	local toImg2 = VImage{name="toImg2",image="minijiantou.png", layout="RightOut", relative="limitText1", offsetP={0.3,0}};
	local nextSunText = VText{name="nextSunText",text=info.nextSunshineMax, fontSize=15, color={90,40,0}, layout="RightOut", offset={20,0}, relative="toImg1", format=1};
	local nextCoinText = VText{name="nextCoinText",text=info.nextCoinMax, fontSize=15, color={90,40,0}, layout="RightOut", offset={20,0}, relative="toImg2", format=1};

	centerImg:Push(toImg1);
	centerImg:Push(toImg2);
	centerImg:Push(nextSunText);
	centerImg:Push(nextCoinText);

	local c1 = self("conditionLayer1");
	c1("icon").image = "icon_basecamp.png";
	c1("tip").text = "庄园达到"..info.baseCampLimit.."级";

	local c2 = self("conditionLayer2");
	c2("icon").image = "icon_daojishi.png";
	c2("tip").text = self:FormatString(info.upgradeTime);

	local c3 = self("conditionLayer3");
	c3("icon").image = "icon_jinbi.png";
	c3("tip").text = info.upgradeSunshine;

	local c4 = self("conditionLayer4");
	c4("icon").image = "icon_yibi.png";
	c4("tip").text = info.upgradeCoin;

	self("sureBtn").onClick = "node:Parent(1):LevelUp("..BUILDING_TYPE.BuildingStore..")";
	self("buildImg").image = "mv_jinku.png";
end

--显示庄园升级信息
function VBuildingUpgradeDlg:InitBasecampDlg()
	local info = gData.userInfo.manorInfo.baseCampInfo;
	self("levelText").text = (info.level+1).."级";
	local centerImg = self("tipBgImg");
	centerImg.size = {327,100};
	self("exploinText").text = "\t      庄园是农场的核心建筑，升级庄园等级可以提升建筑,植物和僵尸的等级上限。";

	local limit1 = VText{name="limitText1",color={90,40,0}, layout="LeftDown", offset={15,-5}, fontSize=14, relative="tipBgImg"};
	local limit2 = VText{name="limitText2",color={90,40,0}, layout="LeftUpOut", offset={0,0}, fontSize=14, relative="limitText1"};
	-- local limit3 = VText{name="limitText3",color={90,40,0}, layout="LeftUpOut", offset={0,3}, fontSize=14, relative="limitText2"};

	-- local toImg1 = VImage{name="toImg1",image="minijiantou.png", layout="Left", relative="limitText3", offsetP={0.5,0}};
	local toImg2 = VImage{name="toImg2",image="minijiantou.png", layout="Left", relative="limitText2", offsetP={0.5,0}};
	local toImg3 = VImage{name="toImg3",image="minijiantou.png", layout="Left", relative="limitText1", offsetP={0.5,0}};
	
	-- local nextLimit1 = VText{name="nextLimit1",color={90,40,0}, layout="RightOut", offset={20,0}, fontSize=14, relative="toImg1"};
	local nextLimit2 = VText{name="nextLimit2",color={90,40,0}, layout="RightOut", offset={20,0}, fontSize=14, relative="toImg2"};
	local nextLimit3 = VText{name="nextLimit3",color={90,40,0}, layout="RightOut", offset={20,0}, fontSize=14, relative="toImg3"};
	
	local limitStore = VBuildingInfoDlg:getStoreBaseCampLimit(info.level);
	local limitAltar = VBuildingInfoDlg:getAltarBaseCampLimit(info.level);
	local limitLabro = VBuildingInfoDlg:getLabroBaseCampLimit(info.level);
	limit1.text = "建筑等级：最高升至"..info.level.."级";
	limit2.text = "植物星级：最高升至"..info.level.."星";
	-- limit3.text = "等级上限：金库"..limitStore.."级";

	local nextLimitStore = VBuildingInfoDlg:getStoreBaseCampLimit(info.level+1);
	local nextLimitAltar = VBuildingInfoDlg:getAltarBaseCampLimit(info.level+1);
	local nextLimitLabro = VBuildingInfoDlg:getLabroBaseCampLimit(info.level+1);
	-- nextLimit1.text = nextLimitAltar.."级";
	nextLimit2.text = (info.level+1).."星";
	nextLimit3.text = (info.level+1).."级";

	centerImg:Push(limit1);
	centerImg:Push(limit2);
	-- centerImg:Push(limit3);
	-- centerImg:Push(toImg1);
	centerImg:Push(toImg2);
	centerImg:Push(toImg3);
	-- centerImg:Push(nextLimit1);
	centerImg:Push(nextLimit2);
	centerImg:Push(nextLimit3);

	local c1 = self("conditionLayer1");
	c1("icon").image = "icon_daojishi.png";
	c1("tip").text = self:FormatString(info.upgradeTime);

	local c2 = self("conditionLayer2");
	c2("icon").image = "icon_jinbi.png";
	c2("tip").text = info.upgradeSunshine;

	local c3 = self("conditionLayer3");
	c3("icon").image = "icon_yibi.png";
	c3("tip").text = info.upgradeCoin;

	self("conditionLayer4").visible = 0;

	self("sureBtn").onClick = "node:Parent(1):LevelUp("..BUILDING_TYPE.BuildingBasecamp..")";
	self("buildImg").image = "mv_zhuangyuan.png";
end

--升级时间格式化
function VBuildingUpgradeDlg:FormatString( time )
	local timeTable = os.date("!*t", time);
	local level = 0;
	local timeString = "";
	if level < 2 and timeTable.day > 1 then
		timeString = timeString..(timeTable.day-1).."天";
		level = level + 1;
	end
	if level < 2 and timeTable.hour > 0 then
		timeString = timeString..timeTable.hour.."小时";
		level = level + 1;
	end
	if level < 2 and timeTable.min > 0 then
		timeString = timeString..timeTable.min.."分钟";
		level = level + 1;
	end
	if level < 2 and timeTable.sec > 0 then
		timeString = timeString..timeTable.sec.."秒";
	end
	return timeString;
end

function VBuildingUpgradeDlg:LevelUp( buildType )
	local info,buildSprite;
	if buildType == BUILDING_TYPE.BuildingAltar then 
		info = gData.userInfo.manorInfo.altarInfo;
		buildSprite = gMainView.manorView.btnAltar;
	elseif buildType == BUILDING_TYPE.BuildingLaboratory then
		info = gData.userInfo.manorInfo.laboratory;
		buildSprite = gMainView.manorView.btnCollege
	elseif buildType == BUILDING_TYPE.BuildingStore then
		info = gData.userInfo.manorInfo.storeInfo;
		buildSprite = gMainView.manorView.btnVaults;
	elseif buildType == BUILDING_TYPE.BuildingBasecamp then
		info = gData.userInfo.manorInfo.baseCampInfo;
		buildSprite = gMainView.manorView.btnBaseCamp;
	end
	if not info then return end;
	local sun = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeSunshine);
	local coin = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeMoney);
	if info.baseCampLimit and gData.userInfo.manorInfo.baseCampInfo.level < info.baseCampLimit then
		gWindow:showNormalTip("等级不足！需要庄园"..info.baseCampLimit.."级");
		self:doPop();
		return;
	end
	local mi = gData.userInfo.manorInfo;
	if mi:idleFarmer() <= 0 then
        if mi:farmerNextCost() then
            gWindow:showFarmerLackTip();
        else
            gWindow:showTip("工人都在忙碌中，没有空闲的工人。", 1);
        end
        self:doPop();
        return;
    end
    local costInfo = {};
	if info.upgradeCoin > coin then
		local t = {};
		t.thingid = 20;
		t.type = 1;
		t.count = info.upgradeCoin-coin;

		table.insert(costInfo, t);
	end
	if info.upgradeSunshine > sun then
		local t = {};
		t.thingid = 21;
		t.type = 1;
		t.count = info.upgradeSunshine-sun;
		table.insert(costInfo, t);
	end
	if next(costInfo) then
		gWindow:showCostLackDlg(costInfo, self, "sendLevelUpMsg", info, buildSprite, buildType);
		self.visible = 0;
		return;
	end
	self:sendLevelUpMsg(info, buildSprite, buildType);
end

function VBuildingUpgradeDlg:sendLevelUpMsg( info, buildSprite, buildType)
	self.visible = 1;
	if gMainView and buildSprite:isLevelOping() then
        gWindow:showTip("哎呀，操作太快了.");
        return;
    end
    buildSprite:setLevelOpreation(true);
    buildSprite:showUpProgress(info.upgradeTime);
    info:levelUp();
	gReq:MsgReqManorBuildingLevelUp(nil, nil, buildType);
	self:doPop();
end