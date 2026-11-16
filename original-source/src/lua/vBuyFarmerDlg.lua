
VBuyFarmerDlg = VClass("BuyFarmerDlg", VMsgBox);

function VBuyFarmerDlg:onPush()
	self("titleText").text = "购买工人";
	self("bgImg").touch = 1;
	self.cost = gData.userInfo.manorInfo:farmerNextCost();
	self("bf_vcoinText").text = self.cost;
	self("suerBtn").onClick = "gView('buyFarmerDlg'):onBuyBtnClick()";
end

function VBuyFarmerDlg:onPop()
	if gData.userInfo.roleInfo.vipInfo[0] < 1 then
		gWindow:showBattleFaildTip(2);
	end 
end
 
function VBuyFarmerDlg:onBuyBtnClick()
	local vcoin = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency);
	if vcoin < self.cost then
		gWindow:showMoneyLackDlg(self.cost);
		return;
	end
	gReq:MsgReqManorFarmerAdd(self, "FarmerAddCallBack", 1);
	gData.userInfo.manorInfo:addFarmer(1);
	if gMainView then
		gMainView:refreshFarmerValue();
	end
	gWindow:showTip("购买成功！",1);
	self:doPop();
end

function VBuyFarmerDlg:FarmerAddCallBack(result, rsp, req)
	if result ~= 0 then
		
	end
end