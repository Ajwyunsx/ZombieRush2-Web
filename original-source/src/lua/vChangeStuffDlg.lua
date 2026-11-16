
VChangeStuffDlg = VClass("ChangeStuffDlg", VMsgBox)

function VChangeStuffDlg:onPush()
	self.inputEdt = self("inputEdt");
	self.inputEdt.text = self.maxCount;
	self("titleText").text = "材料转换";
	self("tip2").text = "每消耗"..self.costCount.."个材料可转换一次，随机转换成一个同品质材料(有一定几率出高品质材料)。";
end

function VChangeStuffDlg:InitData(delegate, itemInfo, maxCount, costCount)
	self.delegate = delegate;
	self.itemInfo = itemInfo;
	self.maxCount = maxCount;
	self.costCount = costCount;
end


function VChangeStuffDlg:turnStuff(value)
	local curNumber = tonumber(self.inputEdt:getText());
	if curNumber <= 1 and value < 0  then return end
	if curNumber >= self.maxCount and value > 0 then return end
	curNumber = curNumber + value;
	self.inputEdt.text = curNumber;
end

function VChangeStuffDlg:turnMinValue()
	self.inputEdt.text = 1;
end

function VChangeStuffDlg:turnMaxValue()
	self.inputEdt.text = self.maxCount;
end

function VChangeStuffDlg:changeStuffClick()
	
	local curNumber = tonumber(self.inputEdt:getText()) or 0;
	if curNumber > self.maxCount or curNumber < 1 then
		gWindow:showTip("输入的数量有误，请重新输入！",2);
		self.inputEdt:setText("1");
		return;
	end
	gWindow:showWaitTip("loading...");
	local aParam = {};
	aParam.bagid = self.itemInfo.id;
	aParam.count = curNumber;
	aParam.itemid = self.itemInfo.itemid;
	gReq:MsgReqItemUse(self, "changeStuffCallBack", aParam);
end

function VChangeStuffDlg:changeStuffCallBack(result, rsp, req)
	gWindow:closeWaitTip();
	if result == 0 then
		gWindow:showReWardTip(rsp.ri, "zhuanhuachenggong.png");
		self.delegate:InitLayer(self.delegate.quality);
		self:doPop();
	end
end