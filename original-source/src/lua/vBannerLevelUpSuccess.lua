VBannerLevelUpSuccess = VClass("BannerLevelUpSucess", VMsgBox)

function VBannerLevelUpSuccess:Init(attr)
	VBannerLevelUpSuccess.super.Init(self, attr);
end

function VBannerLevelUpSuccess:onPush()
	self:setUI();
end

function VBannerLevelUpSuccess:setData(attrType, beforeLevel, beforeMax, afterInfo)
	self.attrType = attrType;
	self.beforeLevel = beforeLevel;
	self.beforeMax = beforeMax;
	self.data = afterInfo;
end

function VBannerLevelUpSuccess:setFlagIcon()
	self("imageIcon").image = self.data:getImage();
end

function VBannerLevelUpSuccess:setUI()
	self("title").image="zhanqishengjichenggong.png";
	self:setFlagIcon();
	local afterLevel = 0;
	local afterMax = 0;
	local attrId = 0;
	if self.attrType == 1 then
		self("textAttrLevel").text = "攻击级别:";
		self("textAttrName").text = "攻击力:";
		afterLevel = self.data.attackAttr.level;
		afterMax = self.data.attackAttr.level_max;
		attrId  = self.data.attackAttr.value;
	else
		self("textAttrLevel").text="防御级别:";
		self("textAttrName").text = "防御力:";
		afterLevel = self.data.defendAttr.level;
		afterMax = self.data.defendAttr.level_max;
		attrId  = self.data.defendAttr.value;
	end

	self:setAttrUiBefore("imageAttrBefore", "iamgeAttrBeforeBg", attrId, self.beforeLevel, self.beforeMax);
	self:setAttrUi("imageAttrAfter", "iamgeAttrAfterBg", attrId, afterLevel, afterMax);

	local csvDatas = gData:readCsv("banner_level.csv");
	local data = csvDatas:lineDataWithKey(self.beforeLevel);
	if not data then
		return gLog("level %d not found in banner_level.csv", self.beforeLevel);
	end

	self("textAttrValueBefore").text = "+"..data.addition.."%";

	data = csvDatas:lineDataWithKey(afterLevel);
	if not data then
		return gLog("level %d not found in banner_level.csv", afterLevel);
	end
	self("textAttrValueAfter").text = "+"..data.addition.."%";

end

function VBannerLevelUpSuccess:setAttrUi(frontImgPre, bgImgPre, attrId, curLeve, maxLevel)
	local csvDatas = gData:readCsv("banner_attr.csv");
	local attrCsv = csvDatas:lineDataWithKey(attrId);

	if not attrCsv then
		return gLog("attr %d not found in banner_attr.csv", attrId);
	end

	for i = 1, 5 do
		if i <= maxLevel then
			self(bgImgPre..i).visible = 1;
			self(bgImgPre..i).image = "banner_attr_bg"..attrId..".png";
			if i <= curLeve then
				self(frontImgPre..i).visible = 1;
				self(frontImgPre..i).image = "banner_attr"..attrId..".png";
			else
				self(frontImgPre..i).visible = 0;
			end
		else
			self(bgImgPre..i).visible = 0;
		end
	end
end

function VBannerLevelUpSuccess:setAttrUiBefore(frontImgPre, bgImgPre, attrId, curLeve, maxLevel)
	local csvDatas = gData:readCsv("banner_attr.csv");
	local attrCsv = csvDatas:lineDataWithKey(attrId);

	if not attrCsv then
		return gLog("attr %d not found in banner_attr.csv", attrId);
	end

	for i = 1, 5 do
		if i <= maxLevel then
			self(bgImgPre..i).visible = 1;
			self(bgImgPre..i).image = "banner_attr_bg"..attrId..".png";
			if maxLevel - i < curLeve then
				self(frontImgPre..i).visible = 1;
				self(frontImgPre..i).image = "banner_attr"..attrId..".png";
			else
				self(frontImgPre..i).visible = 0;
			end
		else
			self(bgImgPre..i).visible = 0;
		end
	end
end