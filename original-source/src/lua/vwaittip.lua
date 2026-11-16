--vwaittip.lua

VWaitTip = VClass("WaitTip", VMsgBox)

function VWaitTip:Init(attr)
	VMsgBox.Init(self, attr);
	self.timeOut = 30;
end

function VWaitTip:onClick()
	
end

function VWaitTip:setMsg(msg)
	self("texLoading").text = msg;
end

function VWaitTip:setDelegateCallBack(delegate, callBack)
	self.delegate = delegate;
	self.timeOutCallback = callBack;
end

function VWaitTip:onPush()
	self.imgLoading = self("imgLoading");
	self.imgLoading:RunAction{"repeatForever", {"rotateBy", 1, 360}}

	if self.timeOut and self.timeOut~=0 then
		self:StartTimer("timeOutAction", 0, 0, self.timeOut);
	end
end

function VWaitTip:timeOutAction()
	self:closeTip();
	VCallBack(self.delegate, self.timeOutCallback);
end

function VWaitTip:closeTip()
	self:StopTimer("timeOutAction");
	self:doPop();
end