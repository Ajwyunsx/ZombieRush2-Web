VBuildingInfoDlg = VClass("BuildingInfoDlg", VMsgBox);

function VBuildingInfoDlg:SetBuildingType( aType )
	
	self.aType = aType;
end

function VBuildingInfoDlg:onPush(  )
	self("titleText").text = "农场建筑";
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

--显示太阳神庙信息
function VBuildingInfoDlg:InitAltarDlg()
	local info = gData.userInfo.manorInfo.altarInfo;
	local centerImg = self("tipBgImg");
	centerImg.size = {327,100};
	self("nameText").text = "太阳神殿";
	self("levelText").text = info.level.."级";
	self("exploinText").text = "\t      多么神圣的建筑，它会在战斗中帮助你制造出阳光和月光，提升它的等级绝对是明智之选。";

	local limit1 = VText{name="limitText1",color={90,40,0}, layout="LeftDown", offset={20,-10}, fontSize=15, relative="tipBgImg"};
	local limit2 = VText{name="limitText2",color={90,40,0}, layout="LeftUpOut", offset={0,0}, fontSize=15, relative="limitText1"};
	limit1.text = "月光产量：";
	limit2.text = "阳光产量：";
	local sunIcon = VImage{name="sunIcon",image="icon_sun_S.png", layout="RightOut", relative="limitText2"};
	local moonIcon = VImage{name="moonIcon",image="icon_yueguang_S.png", layout="RightOut", relative="limitText1"};
	
	local t1 = info.sunshineCount.."/"..info.sunshinePeriod.."秒";
	local t2 = info.darkSunshineCount.."/"..info.darkSunshinePeriod.."秒";
	local sunText = VText{text=t1, fontSize=15, color={90,40,0}, layout="RightOut", relative="sunIcon"};
	local moonText = VText{text=t2, fontSize=15, color={90,40,0}, layout="RightOut", relative="moonIcon"};

	centerImg:Push(limit1);
	centerImg:Push(limit2);
	centerImg:Push(sunIcon);
	centerImg:Push(moonIcon);
	centerImg:Push(sunText);
	centerImg:Push(moonText);

	self("buildImg").image = "mv_shendian.png";
end

--显示实验室信息
function VBuildingInfoDlg:InitLaboratoryDlg()
	local info = gData.userInfo.manorInfo.laboratory;
	local centerImg = self("tipBgImg");
	self("nameText").text = "研究所";
	centerImg.size = {327,100};
	self("levelText").text = info.level.."级";
	self("exploinText").text = "\t      研究所拥有现代科技，能够把僵尸卡牌升至更高的星级。";

	local limit1 = VText{name="limitText1",color={90,40,0}, layout="LeftDown", offset={20,-10}, fontSize=15, relative="tipBgImg"};
	local limit2 = VText{name="limitText2",color={90,40,0}, layout="LeftUpOut", offset={0,0}, fontSize=15, relative="limitText1"};
	limit2.text = "升星容器："..info.monsterLimit.."个";
	limit1.text = string.format("怪物星级：最高升至%d星",info.level);
	centerImg:Push(limit1);
	centerImg:Push(limit2);

	self("buildImg").image = "mv_shiyanshi.png";
end

--显示金库信息
function VBuildingInfoDlg:InitStoreDlg()
	local info = gData.userInfo.manorInfo.storeInfo;
	self("nameText").text = "金库";
	self("levelText").text = info.level.."级";
	self("exploinText").text = "\t      您珍贵的金币和银币都存在这里，升级金库等级可以增加金币和银币的存储上限。";
	local centerImg = self("tipBgImg");
	centerImg.size = {327,100};
	local limit1 = VText{name="limitText1",color={90,40,0}, layout="LeftDown", offset={20,-10}, fontSize=15, relative="tipBgImg"};
	local limit2 = VText{name="limitText2",color={90,40,0}, layout="LeftUpOut", offset={0,0}, fontSize=15, relative="limitText1"};
	limit2.text = "金币上限：";
	limit1.text = "银币上限：";
	local sunIcon = VImage{name="sunIcon",image="icon_jinbi_S.png", layout="RightOut", relative="limitText2"};
	local coinIcon = VImage{name="coinIcon",image="icon_yibi_S.png", layout="RightOut", relative="limitText1"};
	local sunText = VText{text=info.sunshineMax, fontSize=15, color={90,40,0}, layout="RightOut", relative="sunIcon", format=1};
	local coinText = VText{text=info.coinMax, fontSize=15, color={90,40,0}, layout="RightOut", relative="coinIcon", format=1};

	centerImg:Push(limit1);
	centerImg:Push(limit2);
	centerImg:Push(sunIcon);
	centerImg:Push(coinIcon);
	centerImg:Push(sunText);
	centerImg:Push(coinText);
	self("buildImg").image = "mv_jinku.png";
end

--显示庄园信息
function VBuildingInfoDlg:InitBasecampDlg()
	local info = gData.userInfo.manorInfo.baseCampInfo;
	self("levelText").text = info.level.."级";
	local centerImg = self("tipBgImg");
	centerImg.size = {327,100};
	local limit1 = VText{name="limitText1",color={90,40,0}, layout="LeftDown", offset={20,-5}, fontSize=15, relative="tipBgImg"};
	local limit2 = VText{name="limitText2",color={90,40,0}, layout="LeftUpOut", offset={0,0}, fontSize=15, relative="limitText1"};
	-- local limit3 = VText{name="limitText3",color={90,40,0}, layout="LeftUpOut", offset={0,3}, fontSize=15, relative="limitText2"};
	local limitStore = self:getStoreBaseCampLimit(info.level);
	local limitAltar = self:getAltarBaseCampLimit(info.level);
	local limitLabro = self:getLabroBaseCampLimit(info.level);
	limit1.text = string.format("建筑等级：最高升至%d级",info.level);
	limit2.text = string.format("植物星级：最高升至%d星",info.level);
	-- limit3.text = "等级上限：金库"..limitStore.."级";
	centerImg:Push(limit1);
	centerImg:Push(limit2);
	-- centerImg:Push(limit3);
	self("exploinText").text = "\t      庄园是农场的核心建筑，升级庄园等级可以提升建筑,植物和僵尸的等级上限。";
	self("buildImg").image = "mv_zhuangyuan.png";
end


function VBuildingInfoDlg:getStoreBaseCampLimit( bcLevel )
	local csv = gData:readCsv("prop_store.csv");
	local data = csv:allData();
	for i,v in ipairs(data) do 
		if v.baseCampLimit > bcLevel then
			return v.level;
		end
	end
end

function VBuildingInfoDlg:getAltarBaseCampLimit( bcLevel )
	local csv = gData:readCsv("prop_altar.csv");
	local data = csv:allData();
	for i,v in ipairs(data) do 
		if v.baseCampLimit > bcLevel then
			return v.level;
		end
	end
end

function VBuildingInfoDlg:getLabroBaseCampLimit( bcLevel )
	local csv = gData:readCsv("prop_laboratory.csv");
	local data = csv:allData();
	for i,v in ipairs(data) do 
		if v.baseCampLimit > bcLevel then
			return v.level;
		end
	end
end
