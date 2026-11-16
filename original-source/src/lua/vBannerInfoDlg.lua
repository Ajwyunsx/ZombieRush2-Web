require "vBannerInfoCell"
require "vBannerLevelUpSuccess"
require "vBannerLevelUpDlg"
require "vBannerDecomposeDlg"
require "vBannerRaceDlg"

VBannerInfoDlg = VClass("BannerInfoDlg", VMsgBox);

function VBannerInfoDlg:Init(attr)
	VBannerInfoDlg.super.Init(self, attr);
	self.banners = {};
	self.selectBannerInfo = nil;
end

function VBannerInfoDlg:onPush()
	self.tableBanners = self("tableBanners");
	self:backShow();
end

function VBannerInfoDlg:backShow()
	self:tidyData();
	self:setBannerCountUI();
	self:refreshBannerTable();
	self:setSelectedBannerInfo();
end

function VBannerInfoDlg:setBannerCountUI()
	local countString = tostring(#self.banners);
	local csvDatas = gData:readCsv("banner_common.csv");
    if csvDatas then
        local csvData = csvDatas:lineData(0);
        countString = countString.."/"..csvData.maxBanners;
    end
	self("textBannerCount").text = countString;
end

function VBannerInfoDlg:setCreatures()
	if self.selectBannerInfo then
		local creatures = self.selectBannerInfo:getCreatures();
		for i=1, 6 do
			if i <= #creatures then
				self("iamgeBannerRaceBg"..i).visible=1;
				local csvDatas = gData:readCsv("banner_race.csv");
				local data = csvDatas:lineDataWithKey(creatures[i]);
	
				if not data then
				 	return gLog("banner race %d not found in banner_race.csv", creatures[i]);
				end
				
				self("iamgeBannerRaceBg"..i).touch = 1;

				local imageNode = self("imageBannerRaceIcon"..i);
				if data.raceType == 1 then
					imageNode.image = data.image.."S.png";
					self("iamgeBannerRaceBg"..i).onClick = "node:Parent(4):onClickRace("..creatures[i]..",'"..data.image.."S.png',"..data.raceType..")";
				else
					imageNode.image = data.image.."L.png";
					self("iamgeBannerRaceBg"..i).onClick = "node:Parent(4):onClickRace("..creatures[i]..",'"..data.image.."L.png',"..data.raceType..")";
				end
				-- self:setIconMask(imageNode);
				self("textBannerRaceName"..i).visible = 1;
				self("textBannerRaceName"..i).text = data.name;
			else
				self("iamgeBannerRaceBg"..i).visible=0;
				self("iamgeBannerRaceBg"..i).touch = 0;
				self("iamgeBannerRaceBg"..i).onClick = nil;
				self("textBannerRaceName"..i).visible = 0;
			end
		end
	end
end

function VBannerInfoDlg:onClickRace(creature, image, raceType)
	local vBannerRaceDlg = VNode("vBannerRaceDlg.vui");
	vBannerRaceDlg:setData(creature, image, raceType);
	gView():Push(vBannerRaceDlg);
end

function VBannerInfoDlg:setIconMask(imgNode)
	 local u_mask = {}
    u_mask.type = "sampler2D"
    u_mask.value = "banner_race_icon_cover.png"

    local params = {};
    params.u_mask = u_mask
    imgNode:Set_Shader("mask.fsh", u_mask.value, true, params);
end

--选中的战旗信息
function VBannerInfoDlg:setSelectedBannerInfo()
	self:setCreatures();
	self:setAttrs();
end

function VBannerInfoDlg:setAttrs()
	if self.selectBannerInfo then
		self:setAttrUi("imageAtk", "iamgeBgAtk", self.selectBannerInfo.attackAttr, true);
		self:setAttrUi("imageDef", "iamgeBgDef", self.selectBannerInfo.defendAttr, false);
		self:setAttackUI(self.selectBannerInfo.attackAttr);
		self:setDefendUI(self.selectBannerInfo.defendAttr);
	end
end

function VBannerInfoDlg:setAttrUi(frontImgPre, bgImgPre, attr, isAttack)
	local csvAttrDatas = gData:readCsv("banner_attr.csv");
	local attrCsv = csvAttrDatas:lineDataWithKey(attr.value);

	if not attrCsv then
		return gLog("attr %d not found in banner_attr.csv", attr.value);
	end

	local maxLevel = attr.level_max;
	local curLeve = attr.level;

	if curLeve > 0 then
		if isAttack then
			if curLeve < maxLevel then
				self("btnAtkLevelUp").touch = 1;
				self("imgAtkLevelUp").image = "zhanqishengji.png";
			else
				self("btnAtkLevelUp").touch = 0;
				self("imgAtkLevelUp").image = "zhanqi_yimanji.png";
			end
			self("textAtkDesc").text = curLeve.."级"..attrCsv.name.."攻";
		else
			if curLeve < maxLevel then
				self("btnDefLevelUp").touch = 1;
				self("imgDefLevelUp").image = "zhanqishengji.png";
			else
				self("btnDefLevelUp").touch = 0;
				self("imgDefLevelUp").image = "zhanqi_yimanji.png";
			end
			self("textDefDesc").text = curLeve.."级"..attrCsv.name.."防";
		end
	else
		if isAttack then
			if curLeve < maxLevel then
				self("btnAtkLevelUp").touch = 1;
				self("imgAtkLevelUp").image = "zhanqishengji.png";
			else
				self("btnAtkLevelUp").touch = 0;
				self("imgAtkLevelUp").image = "zhanqi_yimanji.png";
			end
			self("textAtkDesc").text = "基础"..attrCsv.name.."攻";
		else
			if curLeve < maxLevel then
				self("btnDefLevelUp").touch = 1;
				self("imgDefLevelUp").image = "zhanqishengji.png";
			else
				self("btnDefLevelUp").touch = 0;
				self("imgDefLevelUp").image = "zhanqi_yimanji.png";
			end
			self("textDefDesc").text = "基础"..attrCsv.name.."防";
		end
	end

	for i = 1, 5 do
		if i <= maxLevel then
			self(bgImgPre..i).visible = 1;
			self(bgImgPre..i).image = "banner_attr_bg"..attr.value..".png";
			if i <= curLeve then
				self(frontImgPre..i).visible = 1;
				self(frontImgPre..i).image = "banner_attr"..attr.value..".png";
			else
				self(frontImgPre..i).visible = 0;
			end
		else
			self(bgImgPre..i).visible = 0;
		end
	end
end

function VBannerInfoDlg:setAttackUI(attr)
	local csvDatas = gData:readCsv("banner_level.csv");
	local data = csvDatas:lineDataWithKey(attr.level);

	if not data then
		return gLog("level %d not found in banner_level.csv", attr.level);
	end

	self("textAtkValue").text = data.addition.."%";

	csvDatas = gData:readCsv("banner_attribute_relation.csv");
	data = csvDatas:linesWithKeyRowValues(attr.value, 1);

	if not data then
		return gLog("attr %d attack not found in banner_attribute_relation.csv", attr.value);
	end

	self:setAttrDescUi(1, data.restrain1, data.restrainExt1, data.star1, true);
	self:setAttrDescUi(2, data.restrain2, data.restrainExt2, data.star2, true);
	self:setAttrDescUi(3, data.restrain3, data.restrainExt3, data.star3, true);
end

function VBannerInfoDlg:setDefendUI(attr)
	local csvDatas = gData:readCsv("banner_level.csv");
	local data = csvDatas:lineDataWithKey(attr.level);

	if not data then
		return gLog("level %d not found in banner_level.csv", attr.level);
	end

	self("textDefValue").text = data.addition.."%";

	csvDatas = gData:readCsv("banner_attribute_relation.csv");
	data = csvDatas:linesWithKeyRowValues(attr.value, 2);

	if not data then
		return gLog("attr %d defend not found in banner_attribute_relation.csv", attr.value);
	end

	self:setAttrDescUi(1, data.restrain1, data.restrainExt1, data.star1, false);
	self:setAttrDescUi(2, data.restrain2, data.restrainExt2, data.star2, false);
	self:setAttrDescUi(3, data.restrain3, data.restrainExt3, data.star3, false);
end

function VBannerInfoDlg:setAttrDescUi(i, attr1, attr2, star, isAttack)
	local atkOrDef = "Atk";
	
	if not isAttack then
		atkOrDef = "Def";
	end

	if attr1 == -1 and attr2 == -1 then
		self("text"..atkOrDef..i).visible = 0;
		self("text"..atkOrDef.."Atr"..i).visible = 0;
		self("text"..atkOrDef.."Ext"..i).visible = 0;
		self:setStar("image"..atkOrDef.."Atr"..i.."Star", 0);
	else
		local csvDatas = gData:readCsv("banner_attr.csv");
		self("text"..atkOrDef..i).visible = 1;
		self("text"..atkOrDef.."Atr"..i).visible = 1;
		local attrName = "";
		if attr1 ~= -1 then
			if attr1 == 99 then
				attrName = attrName.."五行";
			else
				local data = csvDatas:lineDataWithKey(attr1);

				if not data then
					return gLog("attr %d not found in banner_attr.csv", attr1);
				end

				attrName = attrName..data.name;
			end

			if attr2 ~= -1 then
				attrName = attrName.."、";
			end
		end

		if attr2 ~= -1 then
			if attr1 == 99 then
				attrName = attrName.."五行";
			else
				local data = csvDatas:lineDataWithKey(attr2);

				if not data then
					return gLog("attr %d not found in banner_attr.csv", attr2);
				end

				attrName = attrName..data.name;
			end
		end
		self("text"..atkOrDef.."Atr"..i).text = attrName;
		self("text"..atkOrDef.."Ext"..i).visible = 1;
		self:setStar("image"..atkOrDef.."Atr"..i.."Star", star);
	end

	
end

function VBannerInfoDlg:setStar(namePre, count)
	for i=1, 5 do
		if i <= count then
			self(namePre..i).visible = 1;
		else
			self(namePre..i).visible = 0;
		end
	end
end

function VBannerInfoDlg:refreshBannerTable()
	self.tableBanners.number = #self.banners;
	self.tableBanners.delegate = self;
	self.tableBanners:reloadData();
end

function VBannerInfoDlg:tidyData()
	self.banners = {};
	for k, v in pairs(gData.userInfo.bannerInfos.bannerInfos) do
		table.insert(self.banners, v);
	end

	self.selectBannerInfo = self.banners[1];
	-- if not self.selectBannerInfo or self:getBannerIndex(self.selectBannerInfo.id) < 0 then
	-- 	--默认选择已经激活的banner，如果都未激活，则默认选中第一个
	-- 	local activeBanner = gData.userInfo.roleInfo:getActiveBanner();
	-- 	if activeBanner then
	-- 		local index = self:getBannerIndex(activeBanner.id);
	-- 		if index > 0 then
	-- 			self.selectBannerInfo = self.banners[index];
	-- 		end
	-- 	else
	-- 		if #self.banners > 0 then
	-- 			self.selectBannerInfo = self.banners[1];
	-- 		end
	-- 	end
	-- end	
end

function VBannerInfoDlg:getBannerIndex(id)
	local index = -1;
     for i=1, #self.banners do
     	local bannerInfo = self.banners[i]
     	if bannerInfo.id == id then
     		index = i;
     		break;
     	end
     end
     return index;
end

function VBannerInfoDlg:onCell(idx, table, cell)
	if table == self.tableBanners then
		local data = self.banners[idx+1];
		if data then
			cell:reload(self, data);
		end
	end
end

function VBannerInfoDlg:refreshSelectedBannerInfo(data)
	self.selectBannerInfo = data;
	self:setSelectedBannerInfo();
end

-------------属性升级

function VBannerInfoDlg:openLevelUpDlg(attrType)
	local bannerLevelUp = VNode("vBannerLevelUpDlg.vui");
	bannerLevelUp:setData(self, attrType, self.selectBannerInfo)
	gView():Push(bannerLevelUp);
end

function VBannerInfoDlg:levelUp(attrType)
	gWindow:showWaitTip("升级中")
	local curLevel = 0;
	local maxLevel = 0;
	if attrType == 1 then
		curLevel = self.selectBannerInfo.attackAttr.level;
		maxLevel = self.selectBannerInfo.attackAttr.level_max;
	else
		curLevel = self.selectBannerInfo.defendAttr.level;
		maxLevel = self.selectBannerInfo.defendAttr.level_max;
	end
	gReq:MsgReqBannerLevelUp(self, "levelUpCallBack", self.selectBannerInfo.id, attrType, curLevel, maxLevel);
end

function VBannerInfoDlg:levelUpCallBack(result, rsp, req)
	gWindow:closeWaitTip();
     if result == 0 then
     	local id = self.selectBannerInfo.id;
     	local index = self:getBannerIndex(id);
     	if index ~= -1 then
     		self.banners[index] = gData.userInfo.bannerInfos.bannerInfos[id];
     		self:refreshSelectedBannerInfo(self.banners[index]);
     	end
     	local resultSuccess = VNode("vBannerLevelUpSuccess.vui");
     	resultSuccess:setData(req.attr_type, req.curLevel, req.maxLevel, gData.userInfo.bannerInfos.bannerInfos[id]);
     	gView():Push(resultSuccess);
     end
end

-------------抽战旗
function VBannerInfoDlg:openBannerLottery()
	local bannerlotteryDlg = VNode("vBannerlotteryDlg.vui");
	bannerlotteryDlg:setCallBack(self, "backShow");
	gView():Push(bannerlotteryDlg);
end

-------------激活
function VBannerInfoDlg:activate()
	gWindow:showWaitTip("激活中");
	gReq:MsgReqBannerActivate(self, "activateCallBack", self.selectBannerInfo.id)
end

function VBannerInfoDlg:activateCallBack(result, rsp, req)
	gWindow:closeWaitTip();
	if result == 0 then
		self.tableBanners:reloadData();
	end
end

-------------分解
function VBannerInfoDlg:openDecomposeDlg()
	local decomposeDlg = VNode("vBannerDecomposeDlg.vui");
	decomposeDlg:setData(self, self.selectBannerInfo);
	gView():Push(decomposeDlg);
end

function VBannerInfoDlg:decompose(bannerId)
	gReq:MsgReqBannerDecompose(self, "decomposeCallBack", bannerId);
end

function VBannerInfoDlg:decomposeCallBack(result, rsp, req)
	if result == 0 then
		local id = self.selectBannerInfo.id;
     	local index = self:getBannerIndex(id);

     	if index ~= -1 then
     		table.remove(self.banners, index);
     		if #self.banners > 0 then
     			if index <= #self.banners then
     				self:refreshSelectedBannerInfo(self.banners[index]);
     			else
     				self:refreshSelectedBannerInfo(self.banners[index-1]);
     			end
				gWindow:showReWardTip(rsp.ri, "fenjiechenggong.png", "你获得了以下材料", self, nil);
     		else
				gWindow:showReWardTip(rsp.ri, "fenjiechenggong.png", "你获得了以下材料", self, "noBannerCallBack");
				return;
     		end
     	end
   		self:refreshBannerTable();
    	self:setBannerCountUI();
	end
end

function VBannerInfoDlg:noBannerCallBack()
	gWindow:showConfirmTip("已经没有战旗了，去抽取战旗？", "取消", "close", self, "抽战旗", "openBannerLottery", "");
end


function VBannerInfoDlg:close()
	self:doPop();
end

function VBannerInfoDlg:onClick()
	-- body
end