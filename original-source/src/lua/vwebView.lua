--vwebView.lua

VWebView = VClass("WebView", VLayer)

function VWebView:Init(attr)
	VLayer.Init(self, attr);
	self:NeedEvent(Eff_onEnter);
end

function VWebView:onPush()
	local frameSize = gDtr:getWinSize();
	local webViewjava = self("webViewjava");
	local size = webViewjava:WinSize();
	gSys:openWebView(self.url, "", (frameSize.width-size.width)/2, (frameSize.height-size.height)/2-30, size.width, size.height);
end

function VWebView:closeView()
	gSys:doWebCmd("close");
	self:doPop();
end