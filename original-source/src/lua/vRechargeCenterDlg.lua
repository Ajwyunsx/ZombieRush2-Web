require "vYeePayDlg"
require "vAlipayDlg"
require "vNotePayDlg"
require "vPrepaidRecordDlg"
require "vAlipayView"

VRechargeCenterDlg = VClass("RechargeCenterDlg", VMsgBox);

function VRechargeCenterDlg:setRechargeInfo(nick, userId, image, delegate, charge)
	self.userNick = nick;
	self.payUserId = gData.userInfo.userid;
	self.userId = userId;
	self.image = image;
	self.delegate = delegate;
	self.charge = charge;
end

function VRechargeCenterDlg:onPop(  )
	self.delegate:showWebView();
end

function VRechargeCenterDlg:onPush()
	self("rc_nameText").text = "昵称："..self.userNick;
	self("rc_idText").text = "ID："..self.userId;
	
	if self.userId == self.payUserId then
		self("titliText").image = "geizijichong1.png";
		self("rc_otherRechargeBtn").visible = 0;
		self("recordBtn").visible = 1;
		local leftVcoin = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency);
		self("rc_moneyText").text = "余额："..leftVcoin;
		local vipLevel = gData.userInfo.roleInfo.vipInfo[0];
		self("headImg"):setHead(self.userid, self.image, nil, vipLevel);
		self("headImg"):SetHeadImageShader();
	else
		self("rc_otherRechargeBtn").visible = 1;
		self("recordBtn").visible = 0;
		self("titliText").image = "geitachongzhi1.png";
		self("rc_moneyText").visible = 0;
		self("rc_idText").offset = {100,15};
		self("rc_nameText").offset = {100,-15};
		self("rc_nameText").layout = "LeftDown";
		local vipLevel = gData:GetVipLevel(self.charge);
		self("headImg"):setHead(self.userid, self.image, nil, vipLevel);
		self("headImg"):SetHeadImageShader();
	end

	if gPackage == 1005 then
		self("rc_chanelLayer").visible = 0;
		self("rc_chanelLayerI4").visible = 1;
		self("rc_chanelLayerUUC").visible = 0;
	elseif gPackage == 1006 then
		self("rc_chanelLayer").visible = 0;
		self("rc_chanelLayerI4").visible = 0;
		self("rc_chanelLayerUUC").visible = 1;
	elseif gPackage == 1009 then
		self("rc_alipayTextXY").text = "XY充值";
		self("rc_chanelLayer").visible = 0;
        self("rc_chanelLayerI4").visible = 0;
		self("rc_chanelLayerXY").visible = 1;
	elseif gPackage == 1012 then
		self("rc_alipayTextXY").text = "海马充值";
		self("rc_chanelLayer").visible = 0;
        self("rc_chanelLayerI4").visible = 0;
		self("rc_chanelLayerXY").visible = 1;
    elseif gPackage == 1013 then
        self("rc_alipayTextXY").text = "91充值";
        self("rc_chanelLayer").visible = 0;
        self("rc_chanelLayerI4").visible = 0;
        self("rc_chanelLayerXY").visible = 1;
	elseif gPackage == 1014 then
		self("rc_alipayTextXY").text = "飓风互动充值";
		self("rc_chanelLayerI4").visible = 0;
		self("rc_chanelLayer").visible = 0;
		self("rc_chanelLayerXY").visible = 1;
	elseif gPackage == 1015 then
		self("rc_alipayTextXY").text = "快用充值";
		self("rc_chanelLayerI4").visible = 0;
		self("rc_chanelLayer").visible = 0;
		self("rc_chanelLayerXY").visible = 1;
    elseif gPackage == 1016 then
        self("rc_alipayTextXY").text = "XX充值";
        self("rc_chanelLayerI4").visible = 0;
        self("rc_chanelLayer").visible = 0;
        self("rc_chanelLayerXY").visible = 1;
    elseif gPackage == 1017 then
        self("rc_alipayTextXY").text = "同步推充值";
        self("rc_chanelLayerI4").visible = 0;
        self("rc_chanelLayer").visible = 0;
        self("rc_chanelLayerXY").visible = 1;
    elseif gPackage == 1018 then
        self("rc_alipayTextXY").text = "itools充值";
        self("rc_chanelLayerI4").visible = 0;
        self("rc_chanelLayer").visible = 0;
        self("rc_chanelLayerXY").visible = 1;
    elseif gPackage == 1019 then
        self("rc_alipayTextXY").text = "乐8充值";
        self("rc_chanelLayerI4").visible = 0;
        self("rc_chanelLayer").visible = 0;
        self("rc_chanelLayerXY").visible = 1;
    elseif gPackage == 1020 then
        self("rc_alipayTextXY").text = "uc充值";
        self("rc_chanelLayerI4").visible = 0;
        self("rc_chanelLayer").visible = 0;
        self("rc_chanelLayerXY").visible = 1;
	else
		if gWechatPay ~= nil and gWechatPay then
			self("rc_payBtn7").visible = 1;
		else
			self("rc_payBtn7").visible = 0;
		end
	end


end

function VRechargeCenterDlg:onClick()
end

function VRechargeCenterDlg:onOtherRechargeBtnClick()
	local ot = VNode("vOtherUserTip.vui");
	ot:SetUser(self.userId);
	self:Push(ot);
end


--易宝充值卡
function VRechargeCenterDlg:onShowYeePayDlg(atype) --type: 1,移动  2电信， 3联通
	local yp = VNode("vYeePayDlg.vui");
	yp.payUserId = self.payUserId;
	yp.userId = self.userId;
	yp.cardType = atype;
	gView():Push(yp);
end

--网银支付宝类
function VRechargeCenterDlg:onShowAlipayDlg(channel)
	local ad = VNode("vAlipayDlg.vui");
	ad.channel = channel;
	ad.userId = self.userId;
	ad.payUserId = self.payUserId;
	gView():Push(ad);
end

--新的网银支付宝界面
function VRechargeCenterDlg:onShowNewAlipayView( channel )
	local ad = VNode("vAlipayView.vui");
	ad.channel = channel;
	ad.userId = self.userId;
	ad.payUserId = self.payUserId;
	gView():Push(ad);
end

--短信
function VRechargeCenterDlg:onShowNotepayDlg()
	local nd = VNode("vNotePayDlg.vui");
	nd.userId = self.userId;
	nd.payUserId = self.payUserId;
	gView():Push(nd);
end

function VRechargeCenterDlg:onRechargeBtnClick(channel)
	-- local params = Var();
	-- params.sid = gZoneid;
	-- params.client_ver = gVersion;
	-- params.payUserId = self.payUserId;
	-- params.goodsName = self.rechargeInfo.vcoin.."钻石";
	-- -- gSys:pay(channel, self.userId, 200, params:ToString());
	-- gSys:pay(channel, self.userId, self.rechargeInfo.money*100, params:ToString());
end


--转账汇款
function VRechargeCenterDlg:onGIROPay(  )
	local url = "http://beta.www.farm.vk51.com/client/recharge/zhuanzhang.html";
	gSys:openWebviewByDefaultIE(url);
end

function VRechargeCenterDlg:javacall(desc)
	gWindow:closeWaitTip();
	if desc and string.len(desc) > 0 then
		gWindow:showTip(desc);
	end
end

