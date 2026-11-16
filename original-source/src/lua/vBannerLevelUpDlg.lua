VBannerLevelUpDlg = VClass("BannerLevelUpDlg", VMsgBox)


function VBannerLevelUpDlg:Init(attr)
	VBannerLevelUpDlg.super.Init(self, attr);
end

function VBannerLevelUpDlg:setData(delegate, attrType, beforeInfo)
	self.delegate = delegate;
	self.attrType = attrType;
	self.beforeInfo = beforeInfo;
	if attrType == 1 then
		self.beforeAttr = beforeInfo.attackAttr;
	else
		self.beforeAttr = beforeInfo.defendAttr;
	end

end

function VBannerLevelUpDlg:onPush()
	self("titleText").text = "战旗属性升级";
	self.layerCondition = self("layerCondition");
	self.layerCenter = self("layerCenter");
	self:setFlagIcon();
	self:setCondition();
	self:setAttrInfo();
end

function VBannerLevelUpDlg:setFlagIcon()
	self("imageIcon").image = self.beforeInfo:getImage();
end

function VBannerLevelUpDlg:setAttrInfo()
	if self.attrType == 1 then
		self("textAttrLevel").text="攻击属性";
		self("textAttrTypeName").text="攻击力:";
	else
		self("textAttrLevel").text="防御属性";
		self("textAttrTypeName").text="防御力:";
	end

	self("textAttrMaxLevel").text = "(".."最大"..self.beforeAttr.level_max..")";

	self:setAttrUiBefore("imageAttrBefore", "iamgeAttrBeforeBg", self.beforeAttr.value,  self.beforeAttr.level, self.beforeAttr.level_max);
	self:setAttrUi("imageAttrAfter", "iamgeAttrAfterBg", self.beforeAttr.value, self.beforeAttr.level+1, self.beforeAttr.level_max);

	local csvDatas = gData:readCsv("banner_level.csv");
	local data = csvDatas:lineDataWithKey(self.beforeAttr.level);
	if not data then
		return gLog("level %d not found in banner_level.csv", self.beforeAttr.level);
	end

	self("textAttrValueBefore").text = "+"..data.addition.."%";

	data = csvDatas:lineDataWithKey(self.beforeAttr.level + 1);
	if not data then
		return gLog("level %d not found in banner_level.csv", self.beforeAttr.level + 1);
	end
	self("textAttrValueAfter").text = "+"..data.addition.."%";
end



function VBannerLevelUpDlg:setCondition()
	local csvDatas = gData:readCsv("banner_levelup.csv");
	local data = csvDatas:linesWithKeyRowValues(self.beforeAttr.value, self.beforeAttr.level + 1);

	if not data then
		return gLog("attrId = %d ,level = %d not found in banner_levelup.csv", self.beforeAttr.value, self.beforeAttr.level + 1);
	end

    local costScheme = data.costScheme;
	csvDatas = gData:readCsv("banner_action_effect.csv");
	local datas  = csvDatas:linesWithRowValue(0, costScheme);

	if #datas == 0 then
		self("textConditionTitle").visible= 0;
	else
		self("textConditionTitle").visible= 1;
		local num1 = math.modf(#datas/2);
		local num2 = #datas%2;
		if num2 ~= 0 then --奇数个
			local costDataCenter = datas[num1+1];
			local costImage, costName = gData:getResoureIconByID(costDataCenter.eType, costDataCenter.eId);
			local imageScale = self:getImageScale(costDataCenter.eType);
			local imageCenter = VImage{name="imageCost"..tostring(num1+1), image=costImage, layout="Left", scale=imageScale, visible=0};
			self.layerCenter:Push(imageCenter);
			local has = gData:getResoureCount(costDataCenter.eType, costDataCenter.eId);
			local textCenter = VText{name="textCost"..tostring(num1+1), text=tostring(has.." / "..(-1*costDataCenter.eCount)), layout="RightOut", relative="imageCost"..tostring(num1+1), fontSize="fs_14", color="fc_6_", visible=0, offset={2, 0}};
            self.layerCenter:Push(textCenter);
			local textSize = textCenter:getContentSize();
			local imageSize = imageCenter:getContentSize();
			local layerCenterSize= self.layerCenter:getContentSize();
			self.layerCenter.size={textSize.width + imageSize.width*imageScale + 2, layerCenterSize.height};
			imageCenter.visible = 1;
			textCenter.visible = 1;
		else
			local layerCenterSize= self.layerCenter:getContentSize();
			self.layerCenter.size = {1, layerCenterSize.height};
		end
		
		if num1 ~= 0 then
			for i = 1, num1 do
				local index1, index2 = num1 - (i - 1), num1 + i + num2;
				if index1 > 0 then
					local data = datas[index1];
					local textLeft = nil;
					local has = gData:getResoureCount(data.eType, data.eId);
					if i == 1 then
						textLeft = VText{name="textCost"..index1, text=tostring(has.." / "..(data.eCount*-1)), layout="LeftOut", relative="layerCenter",fontSize="fs_14", color="fc_6_", offset={-10, 0}};
					else
						textLeft = VText{name="textCost"..index1, text=tostring(has.." / "..(data.eCount*-1)), layout="LeftOut", relative="imageCost"..(index1+1), fontSize="fs_14", color="fc_6_", offset={-10, 0}};
					end
					local imageScale = self:getImageScale(data.eType);
					local costImage, costName = gData:getResoureIconByID(data.eType, data.eId);
					local imageLeft = VImage{name="imageCost"..index1, image=costImage, layout="LeftOut", relative="textCost"..index1, scale=imageScale};
					self.layerCondition:Push(textLeft);
					self.layerCondition:Push(imageLeft);
				end

				if index2 <= #datas then
					local data = datas[index2];
					local imageScale = self:getImageScale(data.eType);
					local costImage, costName = gData:getResoureIconByID(data.eType, data.eId);
					local imageLeft = nil;
					local has = gData:getResoureCount(data.eType, data.eId);
					if i == 1 then
						imageLeft = VImage{name="imageCost"..index2, image=costImage, layout="RightOut", relative="layerCenter", scale=imageScale, offset={10,0}};
					else
						imageLeft = VImage{name="imageCost"..index2, image=costImage, layout="RightOut", relative="textCost"..(index2-1), scale=imageScale, offset={10,0}};
					end
					textLeft = VText{name="textCost"..index2, text=tostring(has.." / "..(data.eCount*-1)), layout="RightOut", relative="imageCost"..index2, fontSize="fs_14", color="fc_6_"};
					self.layerCondition:Push(imageLeft);
					self.layerCondition:Push(textLeft);
				end
			end
		end

	end
end

function VBannerLevelUpDlg:setAttrUi(frontImgPre, bgImgPre, attrId, curLeve, maxLevel)
	local csvAttrDatas = gData:readCsv("banner_attr.csv");
	local attrCsv = csvAttrDatas:lineDataWithKey(attrId);

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

function VBannerLevelUpDlg:setAttrUiBefore(frontImgPre, bgImgPre, attrId, curLeve, maxLevel)
	local csvAttrDatas = gData:readCsv("banner_attr.csv");
	local attrCsv = csvAttrDatas:lineDataWithKey(attrId);

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

function VBannerLevelUpDlg:getImageScale(atype)
	local scale = 1;
	if atype == 2 then
		scale = 0.4;
	end
	return scale;
end

function VBannerLevelUpDlg:levelUp()
	self:doPop();
	self.delegate:levelUp(self.attrType);
end

function VBannerLevelUpDlg:close()
	self:doPop();
end

function VBannerLevelUpDlg:onClick()
	
end
