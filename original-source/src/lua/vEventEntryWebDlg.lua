VEventEntryWebDlg = VClass("EventEntryWebDlg", VMsgBox);

function VEventEntryWebDlg:Init(attr)
   VEventEntryWebDlg.super.Init(self, attr);
end

function VEventEntryWebDlg:onPush()
	self("titliText").image = self.data.nameImage;

	local frameSize = gDtr:getWinSize();

	self.url = self.data.url;
		
 	self.params = self:getParams();
 	if not params then
 		params = "";
 	end
 	self.x = frameSize.width * 78/800 ;
 	self.width =  frameSize.width * (712-78)/800;
 	if gRes:Platform() == "ios" or gRes:Platform() == "mac" then
	 	self.y = frameSize.height * 120/450;
	 	self.height = frameSize.height * (367-160)/450;
 	else
	 	self.y = frameSize.height * 81/450;
	 	self.height = frameSize.height * (367-81)/450;
	end
 	self:showWeb(self.url, self.params, self.x, self.y, self.width, self.height);
 	gMainView.imgChatView.visible = 0;
end

function VEventEntryWebDlg:getParams()
	local params = "?uid="..(gData.userInfo.userid).."&sid="..(gZoneid).."&eventId="..(self.data.id).."&channel="..gReq.channelID.."&callback=refreshEventDlg";
	return params;
end

function VEventEntryWebDlg:closeView()
	gSys:doWebCmd("close");
	self:doPop();
	gMainView.imgChatView.visible = 1;
end

function VEventEntryWebDlg:setData(data)
	self.data = data;
end

function VEventEntryWebDlg:doCharge()
	gSys:doWebCmd("close");
	local payTip = VNode("vPaymentDlg.vui");
	payTip:setData(self, "showWeb");
	self:Push(payTip);
end

function VEventEntryWebDlg:showWeb(url, params, x, y, width, height)
	gSys:openWebView(url, params, x, y, width, height);
end

function VEventEntryWebDlg:onClick()
	
end