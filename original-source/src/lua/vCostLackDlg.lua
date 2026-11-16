
VCostLackDlg = VClass("CostLackDlg", VMsgBox);

function VCostLackDlg:onPush()
	self.costMoney = 0;
	local count = #self.costInfo;
	if count == 1 then
		local info = self.costInfo[1];
		local v = self:getResInfo(info.thingid, info.type);
		self("cl_thingImage1").image = v.image;
		self("cl_numText1").text = info.count;
		self.costMoney = self.costMoney + math.ceil(info.count*v.scale);
		self("cl_thingLayer1").offset = {0,0};

		self("cl_thingLayer2").visible = 0;
	else
		for i=1,2 do 
			local info = self.costInfo[i];
			if info then
				local v = self:getResInfo(info.thingid, info.type);
				if not v then
					gWindow:showTip("读取信息错误！",2);
					self:doPop();
					return;
				end
				self("cl_thingImage"..i).image = v.image;
				self("cl_numText"..i).text = info.count;
				self.costMoney = self.costMoney + (info.count*v.scale);
			end
		end
		self.costMoney = math.ceil(self.costMoney);
	end
	
	self("cl_costText").text = self.costMoney;
end

function VCostLackDlg:getResInfo(id, type)
	local info ={};
	local csvData = gData:readCsv("item_direct_buy.csv");
    local lineData = csvData:lineDataWithKey(id);
    if not lineData then
    	-- cclog("can not find the id:%d in file item_direct_buy.csv", id);
    	return;
    end
    info.image =gData:getResoureIconByID(type,id);
    -- info.image = "cangku.png"; --lineData[2];
    info.scale = lineData[3]/lineData[2];
	return info;
end


function VCostLackDlg:onClick()

end

--点击兑换按钮
function VCostLackDlg:onExchangeBtnClick()
	local money = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency);
	if money < self.costMoney then
		gWindow:showMoneyLackDlg(self.costMoney);
		self:doPop();
	else
		gReq:MsgReqThingDirectBuy(self, "onExchangeCallBack", self.costInfo);
		gWindow:showWaitTip("Loading...");
	end
end

--兑换返回
function VCostLackDlg:onExchangeCallBack(result, rsp, req)
	gWindow:closeWaitTip();
	local costInfo = req.dis;
	if costInfo then
		for i,v in ipairs(costInfo) do
			if v.type == RES_DATA_TYPE.ResDataTypeAttr then
				gData.userInfo.roleInfo:stopHeartBeatSynTimer(v.thingid, 5);
			end
		end
	end
	if result == 0 then
		VCallBack(self.delegate, self.callBack, unpack(self.params));
	end
	self:doPop();
end
