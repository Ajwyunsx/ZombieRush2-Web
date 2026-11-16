VBannerInfoCell = VClass("BannerInfoCell", VTableViewCell)


function VBannerInfoCell:reload(delegate, data)
	self.delegate = delegate;
    self.data = data;
    self:setUI();
end

function VBannerInfoCell:setUI()
	-- if not self.data then return end;
	self("imageCellIconBg").image=self.data:getImageBg();
	self("imageCellIcon").image=self.data:getImage();
	if self.data.id ==  gData.userInfo.roleInfo.activeBanner.id then
		self("imageCellJihuoBg").visible = 1;
	else
		self("imageCellJihuoBg").visible = 0;
	end

	self("textCellName").text = self.data:getName().."("..self.data:getQualityName()..")";

	self:setAttrUi("imageCellAtk", "iamgeCellBgAtk", self.data.attackAttr);
	self:setAttrUi("imageCellDef", "iamgeCellBgDef", self.data.defendAttr);
	if self.delegate.selectBannerInfo.id == self.data.id then
		self("imageArrow").visible = 1;
		self("imageCellBg").image = "bg_choosed.png";
	else
		self("imageArrow").visible = 0;
		self("imageCellBg").image = "bg_normal.png";
	end
end

function VBannerInfoCell:clickBanner()
	local index = self.delegate:getBannerIndex(self.delegate.selectBannerInfo.id);
	self.delegate:refreshSelectedBannerInfo(self.data);
	self.delegate.tableBanners:updateCellAtIndex(index -1);
	self("imageCellBg").image = "bg_choosed.png";
	self("imageArrow").visible = 1;
end

function VBannerInfoCell:setAttrUi(frontImgPre, bgImgPre, attr)
	local csvAttrDatas = gData:readCsv("banner_attr.csv");
	local attrCsv = csvAttrDatas:lineDataWithKey(attr.value);

	if not attrCsv then
		return gLog("attr %d not found in banner_attr.csv", attr.value);
	end

	local maxLevel = attr.level_max;
	local curLeve = attr.level;

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