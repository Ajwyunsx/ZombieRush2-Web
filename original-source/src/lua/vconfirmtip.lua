--vconfirmtip.lua

VConfirmTip = VClass("ConfirmTip", VMsgBox)

function VConfirmTip:onClick()
	
end

function VConfirmTip:setMsg(msg, okTip, cancelTip)
	self("texMsg").text = msg;
	self.btnOK = self("btnOK");
	self.okTip = self("okTip");
	self.cancelTip = self("cancelTip");
	if okTip and okTip~="" then
		self.okTip.text = okTip;
	end

	self.btnCancel = self("btnCancel");
	if cancelTip and cancelTip~="" then
		self.cancelTip.text = cancelTip;
	end
	if not cancelTip then
		self.btnCancel.visible = 0;
		self.btnOK.step = {0, 0};
	end
end

function VConfirmTip:setExtandParam( ... )
	self.param = {...};
end

function VConfirmTip:setDelegateCallBack(delegate, okCallBack, cancelCallBack)
	self.delegate = delegate;
	self.okCallBack = okCallBack;
	self.cancelCallBack = cancelCallBack;
end

function VConfirmTip:onOKAction()
	self:doPop();
	VCallBack(self.delegate, self.okCallBack, unpack(self.param));
end

function VConfirmTip:onCancelAction()
	self:doPop();
	if self.cancelCallBack == "f1111" then
		if gData.userInfo.roleInfo.vipInfo[0] < 1 then
			gWindow:showBattleFaildTip(2);
		end 
	else	
		VCallBack(self.delegate, self.cancelCallBack);
	end
end