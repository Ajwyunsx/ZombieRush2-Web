VBannerDecomposeDlg = VClass("BannerDecomposeDlg", VMsgBox)

function VBannerDecomposeDlg:Init(attr)
	VBannerDecomposeDlg.super.Init(self, attr);
end

function VBannerDecomposeDlg:setData(delegate, bannerInfo)
	self.delegate = delegate;
	self.bannerInfo = bannerInfo;
end

function VBannerDecomposeDlg:onPush()
	self("titleText").text = "战旗分解";
	self("textBannerName").text = self.bannerInfo:getName();
	self.layerGains = self("layerGains");
	self.layerCenter = self("layerCenter");
	self:setUI();
end

function VBannerDecomposeDlg:setUI()
	local datas = self:tidyGainData();
	if #datas > 0 then
		local num1 = math.modf(#datas/2);
		local num2 = #datas%2;
		if num2 ~= 0 then --奇数个
			local gainDataCenter = datas[num1+1];
			local gainImage, gainName = gData:getResoureIconByID(gainDataCenter.eType, gainDataCenter.eId);
			local imageScale = self:getImageScale(gainDataCenter.eType);
			local imageCenter = VImage{name="imageGain"..tostring(num1+1), image=gainImage, layout="Left", scale=imageScale, visible=0};
			self.layerCenter:Push(imageCenter);
			local textCenter = VText{name="textGain"..tostring(num1+1), text="x"..tostring(gainDataCenter.eCount), layout="RightOut", relative="imageGain"..tostring(num1+1), fontSize=18, color={83,42,0}, visible=0, offset={2, 0}};
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
				local index1, index2 = num1 - (i - 1), num1 + i+num2;
				if index1 > 0 then
					local data = datas[index1];
					local textLeft = nil;
					if i == 1 then
						textLeft = VText{name="textGain"..index1, text="x"..tostring(data.eCount), layout="LeftOut", relative="layerCenter",fontSize=18, color={83,42,0}, offset={-10, 0}};
					else
						textLeft = VText{name="textGain"..index1, text="x"..tostring(data.eCount), layout="LeftOut", relative="imageGain"..(index1+1), fontSize=18, color={83,42,0}, offset={-10, 0}};
					end
					local imageScale = self:getImageScale(data.eType);
					local gainImage, gainName = gData:getResoureIconByID(data.eType, data.eId);
					local imageLeft = VImage{name="imageGain"..index1, image=gainImage, layout="LeftOut", relative="textGain"..index1, scale=imageScale};
					self.layerGains:Push(textLeft);
					self.layerGains:Push(imageLeft);
				end

				if index2 <= #datas then
					local data = datas[index2];
					local imageScale = self:getImageScale(data.eType);
					local gainImage, gainName = gData:getResoureIconByID(data.eType, data.eId);
					local imageLeft = nil;
					if i == 1 then
						imageLeft = VImage{name="imageGain"..index2, image=gainImage, layout="RightOut", relative="layerCenter", scale=imageScale, offset={10,0}};
					else
						imageLeft = VImage{name="imageGain"..index2, image=gainImage, layout="RightOut", relative="textGain"..(index2-1), scale=imageScale, offset={10,0}};
					end
					textLeft = VText{name="textGain"..index2, text="x"..tostring(data.eCount), layout="RightOut", relative="imageGain"..index2, fontSize=18, color={83,42,0}};
					self.layerGains:Push(imageLeft);
					self.layerGains:Push(textLeft);
				end
			end
		end

	end
end

function VBannerDecomposeDlg:tidyGainData()
	local datasAtk = self:getGainData(self.bannerInfo.attackAttr.value, self.bannerInfo.attackAttr.level);
	local datasDef = self:getGainData(self.bannerInfo.defendAttr.value, self.bannerInfo.defendAttr.level);

	local datas = {};

	if datasAtk ~= nil and #datasAtk > 0 then
		for i = 1, #datasAtk do
            local data = {};
            data.scheme = datasAtk[i].scheme;
            data.eType = datasAtk[i].eType;
            data.eId = datasAtk[i].eId;
            data.eCount = datasAtk[i].eCount;
			table.insert(datas, data);
		end
	end

	local datasCount = #datas;

	if datasDef ~= nil and #datasDef > 0 then
		for i = 1, #datasDef do
			if datasCount > 0 then
				local has = false;
				for j = 1, datasCount do
					if datas[j].eType == datasDef[i].eType and datas[j].eId == datasDef[i].eId then
						datas[j].eCount = datas[j].eCount + datasDef[i].eCount;
						has = true;
						break;
					end
				end

				if not has then
					table.insert(datas, datasDef[i]);
				end
			else
				table.insert(datas, datasDef[i]);
			end
		end
	end

	return datas;
end

function VBannerDecomposeDlg:getGainData(attrId, attrLevel)
	local csvDatas = gData:readCsv("banner_decompose.csv");
	local data = csvDatas:linesWithKeyRowValues(attrId, attrLevel);

	if not data then
		return gLog("attrId = %d ,level = %d not found in banner_decompose.csv", attrId, attrLevel);
	end

    local gainScheme = data.gainScheme;
	csvDatas = gData:readCsv("banner_action_effect.csv");
	local datas  = csvDatas:linesWithRowValue(0, gainScheme);
	return datas;
end

function VBannerDecomposeDlg:getImageScale(atype)
	local scale = 1;
	if atype == 2 then
		scale = 0.8;
	end
	return scale;
end

function VBannerDecomposeDlg:decompose()
	self:doPop();
	self.delegate:decompose(self.bannerInfo.id);
end

function VBannerDecomposeDlg:doClose()
	self:doPop();
end

function VBannerDecomposeDlg:onClick()
end