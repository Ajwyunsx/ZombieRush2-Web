
VMoneyLackDlg = VClass("MoneyLackDlg", VMsgBox);

function VMoneyLackDlg:onPush()
	self("titleText").text = self.title;
	self("tipText").text = self.tip;
end


function VMoneyLackDlg:onRechargeBtnClick()
	VCallBack(self.delegate, self.callBack, unpack(self.params));
	self:doPop();
end