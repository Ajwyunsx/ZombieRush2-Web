--vOtherUserTip.lua

VOtherUserTip = VClass("OtherUserTip", VMsgBox);

function VOtherUserTip:onPush(  )
	self("titleText").text = "充  值";
	self("titleText").fontSize = 32; 
end

function VOtherUserTip:SetUser( userid )
	self.userid = userid;
end

--取消
function VOtherUserTip:close(  )
	if self.delegate then
		self.delegate:showWebView();
	end
	self:doPop();
end

--查询充值玩家信息
function VOtherUserTip:transformOtherUsertoRecharge()
	local id = self("rc_otherIdEditor"):getText();
	if id == "" then
		gWindow:showTip("玩家ID不能为空！",1);
		return;
	end
	if id == self.userid then
		return;
	end
	local userids = {};
	table.insert(userids,tonumber(id));
	gWindow:showWaitTip("loading...",3);
	gData:userBriefInfo(userids, self, "otherUserRechargeCallBack");
end

--查询玩家信息返回
function VOtherUserTip:otherUserRechargeCallBack()
	gWindow:closeWaitTip();
	local id = tonumber(self("rc_otherIdEditor"):getText());
	local info = gData:briefCache(id);
	if info then
		local nick = info.nick;
		if self.userid then
			local rc = self:Parent(1);
			self.userNick = nick;
			rc.userId = id;
			rc.image = info.image;
			rc.charge = info.charge;
			rc:onPush();
		else
			local rc = VNode("vRechargeCenterDlg.vui");
			rc:setRechargeInfo(nick, id, info.image, self.delegate, info.charge);
			gView():Push(rc);
		end
		self:doPop();
	else
		gWindow:showTip("该玩家不存在！",2);
	end
end