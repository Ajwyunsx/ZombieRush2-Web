VBannerRouletteResultDlg = VClass("BannerRouletteResultDlg", VMsgBox)

function VBannerRouletteResultDlg:onPush()
	self("imageBanner").image = self.bannerInfo:getImage();
	self("titleText").text = self.bannerInfo:getName();
	local creatures = self.bannerInfo:getCreatures();
	for i = 1, 7 do
		if i <= #creatures then
			self("imageCreatureBg"..i).visible=1;
			local csvDatas = gData:readCsv("banner_race.csv");
			local data = csvDatas:lineDataWithKey(creatures[i]);
	
			if not data then
				 return gLog("banner race %d not found in banner_race.csv", creatures[i]);
			end

			if data.raceType == 1 then
				self("imageCreature"..i).image = data.image.."S.png";
			else
				self("imageCreature"..i).image = data.image.."L.png";
			end
		else
			self("imageCreatureBg"..i).visible=0;
		end
	end

	self:setAttrUi("imageAtk", "iamgeBgAtk", self("textAtk"), self.bannerInfo.attackAttr, true);
	self:setAttrUi("imageDef", "iamgeBgDef", self("textDef"), self.bannerInfo.defendAttr, false);
end

function VBannerRouletteResultDlg:setAttrUi(frontImgPre, bgImgPre, title, attr, isAttack)
	local csvAttrDatas = gData:readCsv("banner_attr.csv");
	local attrCsv = csvAttrDatas:lineDataWithKey(attr.value);

	if not attrCsv then
		return gLog("attr %d not found in banner_attr.csv", attr.value);
	end

	if isAttack then
		title.text = attrCsv.name.."系攻击";
	else
		title.text = attrCsv.name.."系防御";
	end

	local maxLevel = attr.level_max;
	local curLeve = attr.level;

	for i = 1, 6 do
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

function VBannerRouletteResultDlg:setBannerInfo(bannerInfo)
	self.bannerInfo = bannerInfo;
end

function VBannerRouletteResultDlg:close()
	self:doPop();
end