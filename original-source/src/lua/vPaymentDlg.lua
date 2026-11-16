--vPaymentDlg.lua

require "vRechargeCenterDlg"
require "vOtherUserTip"

VPaymentDlg = VClass("PaymentDlg", VMsgBox);

function VPaymentDlg:onPush()
	self:InitData();
	self.rechargeLayer = self("rechargeLayer");
	self.vipLayer = self("vipLayer");
	
	self:showRechargeLayer();

	gMainView.imgChatView.visible = 0;
end

function VPaymentDlg:setData(delegate, callBack)
	self.delegate = delegate;
	self.callBack = callBack;
end

function VPaymentDlg:onClick()
	-- body
end

function VPaymentDlg:close()
	self:doPop();
	gSys:doWebCmd("close");
	if self.delegate and self.callBack then
		 VCallBack(self.delegate, self.callBack, self.delegate.url, self.delegate.params, self.delegate.x, self.delegate.y, self.delegate.width, self.delegate.height);
	end
	gMainView.imgChatView.visible = 1;
end

function VPaymentDlg:showRechargeLayer()
	self("titliText").image = "congzhi.png";
	self.vipLayer.visible = 0;
	self.rechargeLayer.visible = 1;
	self.rechargeLayer("vipLevel").text = "v"..self.viplevel;
	local idx = math.min(self.viplevel+2, 11);
	local info = self.vipInfo[idx];
	local money = (info.score - self.vipScore)/10;
	if idx == 11 then
		self.rechargeLayer("vipTip").visible = 0;
		self.rechargeLayer("vipNextLevel").visible = 0;
	else
		self.rechargeLayer("vipTip").text = "再充值"..money.."元可达到";
		self.rechargeLayer("vipNextLevel").text = "v"..(info.level);
	end
	
	self.rechargeLayer("p_vipPctText").text = self.vipScore.."/"..info.score;
	self.rechargeLayer("p_vipPct").percentage = (self.vipScore * 100 / info.score);
	self:showWebView();
end


function VPaymentDlg:showVipLayer( )
	self("titliText").image = "vip.png";
	self.vipLayer.visible = 1;
	self.rechargeLayer.visible = 0;
	self.vipLayer("vipLevel").text = "v"..self.viplevel;
	self.vipLayer.curIdx = math.min(self.viplevel+2, 11);
	local info = self.vipInfo[self.vipLayer.curIdx];
	local money = (info.score - self.vipScore)/10;
	if self.vipLayer.curIdx == 11 then
		self.vipLayer("vipTip").visible = 0;
		self.vipLayer("vipNextLevel").visible = 0;
	else
		self.vipLayer("vipTip").text = "再充值"..money.."元可达到";
		self.vipLayer("vipNextLevel").text = "v"..(info.level);
	end
	self.vipLayer("p_vipPctText").text = self.vipScore.."/"..info.score;
	self.vipLayer("p_vipPct").percentage = (self.vipScore * 100 / info.score);

	self.vipLayer("vpl_vipExploinTitleText").text = "v"..info.level;
	local sText = string.gsub(info.describe,"\\n", "\n");
	self.vipLayer("vpl_vipPrivilegeText1").text = sText;

	self.vipLayer("p_vipRightToward").visible = 1;
	self.vipLayer("nextVipText").visible = 1;
	self.vipLayer("lookNText").visible = 1;

	self.vipLayer("p_vipRightToward").visible = 1;
	self.vipLayer("nextVipText").visible = 1;
	self.vipLayer("lookNText").visible = 1;
	
	if self.vipLayer.curIdx == 2 then
		self.vipLayer("p_vipLeftToward").visible = 0;
		self.vipLayer("lastVipText").visible = 0;
		self.vipLayer("lookLText").visible = 0;
	elseif self.vipLayer.curIdx == 11 then
		self.vipLayer("p_vipRightToward").visible = 0;
		self.vipLayer("nextVipText").visible = 0;
		self.vipLayer("lookNText").visible = 0;
	end
	self.vipLayer("lastVipText").text = "v"..info.level - 1;
	self.vipLayer("nextVipText").text = "v"..info.level + 1;
	self.vipLayer("p_vipPgcBgImage"):ReLayout();
	gSys:doWebCmd("close");
end

--点击充值记录按钮
function VPaymentDlg:onRecordBtnClick()
	self:getView():Push("vPrepaidRecordDlg.vui");
end

--点击VIP按钮
function VPaymentDlg:onClickVipBtn()
	-- local vip = VNode("vVipDlg.vui");
	-- vip:setVipData(self.vipInfo, self.viplevel, self.vipScore);
	-- self:getView():Push(vip);
	self:showVipLayer();
end

--点击充值按钮
function VPaymentDlg:onClickRechargeBtn()
	self:showRechargeLayer();
end

function VPaymentDlg:InitData()
	self.vipScore = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCharge);
	self.vipInfo = {};
	local csv_uv = gData:readCsv("user_vip.csv");
	local data = csv_uv:allData();
	for i,v in ipairs(data) do
		local info = {};
		info.level = v[0];
		info.score = v[1];
		info.describe = v[5];
		if self.vipScore >= v[1] then
			self.viplevel = v[0];
		end
		table.insert(self.vipInfo, info);
	end
end

function VPaymentDlg:onVipTowardClick( toward )
	if toward == "last" then
		self.vipLayer.curIdx = self.vipLayer.curIdx - 1;
		if self.vipLayer.curIdx > 2 then
			self.vipLayer("p_vipRightToward").visible = 1;
			self.vipLayer("nextVipText").visible = 1;
			self.vipLayer("lookNText").visible = 1;
			
		else
			self.vipLayer("p_vipLeftToward").visible = 0;
			self.vipLayer("lastVipText").visible = 0;
			self.vipLayer("lookLText").visible = 0;
		end
	elseif toward == "next" then
		self.vipLayer.curIdx = self.vipLayer.curIdx + 1;
		if self.vipLayer.curIdx <= 10 then
			self.vipLayer("p_vipLeftToward").visible = 1;
			self.vipLayer("lastVipText").visible = 1;
			self.vipLayer("lookLText").visible = 1;
		else
			self.vipLayer("p_vipRightToward").visible = 0;
			self.vipLayer("nextVipText").visible = 0;
			self.vipLayer("lookNText").visible = 0;
		end
	else
		return;
	end
	local info = self.vipInfo[self.vipLayer.curIdx];
	self.vipLayer("vpl_vipExploinTitleText").text = "v"..info.level;
	local sText = string.gsub(info.describe,"\\n", "\n");
	self.vipLayer("vpl_vipPrivilegeText1").text = sText;
	self.vipLayer("lastVipText").text = "v"..info.level - 1;
	self.vipLayer("nextVipText").text = "v"..info.level + 1;
end

function VPaymentDlg:onRechareSelfClick()
	if gCanPay ~= nil and gCanPay == false then
	else
		local rc = VNode("vRechargeCenterDlg.vui");
		local nick = gData.userInfo.roleInfo.nick;
		rc:setRechargeInfo(nick, gData.userInfo.userid, image, self);
		self:getView():Push(rc);
		gSys:doWebCmd("close");
	end
end

--给他人充值
function VPaymentDlg:onOtherRechargeClick()
	if gCanPay ~= nil and gCanPay == false then
	else		
		local node = VNode("vOtherUserTip.vui");
		node.delegate = self;
		self:Push(node);
		gSys:doWebCmd("close");
	end
end



function VPaymentDlg:showWebView(  )
	local frameSize = gDtr:getWinSize();
	local webViewjava = self("webBg");
	local size = webViewjava:WinSize();
	local rect = webViewjava:WinRect();
	local url = "http://beta2.www.farm.vk51.com/client/vip/vip.html";
	local params = "?vip="..(self.viplevel+1);
	gSys:openWebView(url, params, (frameSize.width-size.width)/2, (frameSize.height-size.height)/2, size.width, size.height);
end