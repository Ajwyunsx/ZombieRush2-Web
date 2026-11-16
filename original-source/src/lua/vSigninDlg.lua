--vSigninDlg.lua
-- require "vSignResultDlg"
VSigninDlg = VClass("SigninDlg", VMsgBox);

function VSigninDlg:onClick()
	self("sd_exploinLayer").visible = 0;
end

function VSigninDlg:onPush()
end

function VSigninDlg:onPushFinish(  )
	--列表子项数目
	self.cellCount = 5;

	--初始化数据
	self:InitData();

	--初始化界面
	self:InitDlg();

	--显示签到列表
	local count = #self.signData;
	self.tbv = self("a_tbv");
	self.tbv.delegate = self;
	self.tbv.number = math.ceil(count/self.cellCount);
	self.tbv:reloadData();
	self:SetTbvOffset();
end

function VSigninDlg:onPop(  )
	if self.signState ~= 0 then
		gData.noticeManager:clear(NoticeType.check_in);
	end
end

--初始化数据
function VSigninDlg:InitData(  )
	--VIP
	self.vipLevel = gData.userInfo.roleInfo.vipInfo[0];

	--0未签，1，普通签到，2VIP签到
	self.signState = gData.userInfo.roleInfo.dayInfo.checkin_status;

	--签到次数
	self.signCount = gData.userInfo.roleInfo.monthInfo.checkin_times;

	--获取月份和天数
	local limitTime = gData.userInfo.roleInfo.monthInfo.month;
	local time = limitTime - 86400;
	self.month = tonumber(os.date("%m",time));
	local curTime = gData:currentTime();
    local GMT8_SECONDS = (60 * 60 * 8);
    local A_DAY_SECONDS = (60 * 60 * 24);
    local FIVE_HOUR_SECONDS = (60 * 60 * 5);
    local nTodaySeconds = (curTime + GMT8_SECONDS) % A_DAY_SECONDS;
    self.day = tonumber(os.date("%d", gData:currentTime()));
    if nTodaySeconds < FIVE_HOUR_SECONDS then
		self.day = tonumber(os.date("%d", gData:currentTime()))-1;
	end

	--获取签到数据
	self.signData = gData.userInfo.roleInfo.signData;

	--补VIP签
	self.isPacth = self:IsPacth();
end

--初始化界面
function VSigninDlg:InitDlg(  )
	--显示当前签到信息
	self("sd_signCountText").text = self.signCount;

	--签到按钮
	if self.signState == 0  then
		self("signBtn"):setEnable(true);
		self("signBtn").topImage = "qiandao.png";
		self("signBtn").onClick = "gView('signinDlg'):onSignedBtnClick()";
	elseif self.isPacth then
		self("signBtn"):setEnable(true);
		self("signBtn").topImage = "qiandaovip.png";
		self("signBtn").onClick = "gView('signinDlg'):onSignedBtnClick()";
	else
		self("signBtn").topImage = "qiandao.png";
		self("signBtn"):setEnable(false);
	end

	--补签摁钮
	if self.signState ~=0 and self.signCount < self.day then
		self("costNumber").text = self.signData[self.signCount+1].patchCost;
		self("patchBtn"):setEnable(true);
		self("patchBtn").onClick = "node:Parent(2):onPacthBtnClick()";
	else
		self("costNumber").text = 0;
		self("patchBtn"):setEnable(false);
	end
end

function VSigninDlg:onCell(idx,t,cell)
	for i=1,self.cellCount do
		local n = idx * self.cellCount + i;
		local info = self.signData[n];
		local itemCell = cell("sdc_layer"..i);
		if info and itemCell then
			itemCell.visible = 1;
			itemCell("centerItemImage").image = info.image;
			--vip双倍
			if info.muliple == 0 then 
				itemCell("jbBgImage").visible = 0;
			else
				itemCell("jbBgImage").visible = 1;
				itemCell("jbText").text = "v"..info.muliple.."s";
			end

			--如果当天未签到
			if self.signState == 0 then
				if n < self.signCount + 1 then
					itemCell("checkImg").visible = 1;
					itemCell("maskImg").visible = 1;
				else
					itemCell("checkImg").visible = 0;
					itemCell("maskImg").visible = 0;
				end
			elseif self.signState == 1 then
				if n < self.signCount then
					itemCell("checkImg").visible = 1;
					itemCell("maskImg").visible = 1;
				elseif n == self.signCount then
					if self.isPacth then
						itemCell("checkImg").visible = 0;
						itemCell("maskImg").visible = 0;
					else
						itemCell("checkImg").visible = 1;
						itemCell("maskImg").visible = 1;
					end
				else
					itemCell("checkImg").visible = 0;
					itemCell("maskImg").visible = 0;
				end
			else
				if n <= self.signCount then
					itemCell("checkImg").visible = 1;
					itemCell("maskImg").visible = 1;
				else
					itemCell("checkImg").visible = 0;
					itemCell("maskImg").visible = 0;
				end
			end
			itemCell("signNumText").text = "d"..n.."c";
			itemCell("itemNumText").text = "x"..info.count;
		else
			itemCell.visible = 0;
		end
	end
end

--是否可以补VIP签
function VSigninDlg:IsPacth()
	if self.signState ~= 1 then
		return false;
	end
	local info = self.signData[self.signCount];
	if info.muliple > 0 and self.vipLevel >= info.muliple and self.signState == 1 then
		return true;
	end
	return false;
end

--是否双倍奖励
function VSigninDlg:isDoubleRewards(info)
	if info.muliple > 0 and self.vipLevel >= info.muliple  then
		return true;
	end
	return false;
end


--正常签到按钮点击响应
function VSigninDlg:onSignedBtnClick()
	local n = self.signCount;
	local signType = 0;
	local muliple = 1;
	local info = {};
	if self.signState == 0 then
		n = self.signCount + 1;
		info = self.signData[n];
		if info.muliple > 0 and self.vipLevel >= info.muliple  then
			muliple = 2;
		end
		signType = 1;	--普通签到
	elseif self.signState == 1 and self.isPacth then
		info = self.signData[n];
		signType = 2;	--VIP补签
	end
	
	local limitInfo = {};
	local sub = gData:IsResoureUpperLimit(info.rType, info.rid, info.count*muliple);
	if sub then
		local item = {};
		item.type = 1;
		item.id = info.rid
		item.count = sub;
		table.insert(limitInfo, item);
	end

	if next(limitInfo) then
		gWindow:showUpperlimitTip(limitInfo, self, "sendSignMsg", signType, n, muliple);
		return;
	end

	self("signBtn"):setEnable(false);
	gReq:MsgReqUserCheckIn(self, "signedCallBack", signType, 1, n, muliple);
end

--补签摁钮响应
function VSigninDlg:onPacthBtnClick(  )
	local n = self.signCount + 1;
	local info = self.signData[n];
	local vcoin = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency);
	if vcoin < info.patchCost then
		gWindow:showMoneyLackDlg(info.patchCost);
		return;
	end
	local muliple = 1;
	if info.muliple > 0 and self.vipLevel >= info.muliple  then
		muliple = 2;
	end

	local limitInfo = {};
	local sub = gData:IsResoureUpperLimit(info.rType, info.rid, info.count);
	if sub then
		local item = {};
		item.type = 1;
		item.id = info.rid
		item.count = sub;
		table.insert(limitInfo, item);
	end

	if next(limitInfo) then
		gWindow:showUpperlimitTip(limitInfo, self, "sendSignMsg", 3, n, muliple);
		return;
	end

	self("patchBtn"):setEnable(false);
	self:sendSignMsg(3, n, muliple);
end



--签到动画
function VSigninDlg:showSingedAction(n)
	n = n - 1;
	local tableIndex = math.floor(n / self.cellCount);
	local cellIndex = n % self.cellCount + 1;
	local cell = self.tbv:cellAtIndex(tableIndex);
	local cellItem = cell("sdc_layer"..cellIndex);
	cellItem.touch = 0;
	cellItem("sdc_centerBgImage"):StopAction();
	cellItem("sdc_centerBgImage").visible = 0;

	cellItem("sdc_centerImage").image = "qiandaoyilingqu.png";
	cellItem("sdc_centerImage").visible = 1;
	local aImage = VImage{image="qiandaoyilingqu.png", layout="Center"};
	aImage:RunAction{{"hide"}, {"delayTime",0.3}, {"fadeTo",0,100},{"scaleTo", 0, 1.6, 1.6},{"show"}, {"scaleTo", 0.02, 0.9, 0.9},
					{"scaleTo", 0.02, 1.2, 1.2}, {"scaleTo", 0.02, 1, 1},{self,"sendSignMsg",n+1}, 
					{"delete"}};
	cellItem("sdc_centerImage"):RunAction{{"scaleTo", 0, 2, 2},{"scaleTo", 0.3, 1, 1},{cellItem,"setEnable"}};
	cellItem:Push(aImage);
end

--发送签到协议
function VSigninDlg:sendSignMsg( sType, n, muliple)
	gReq:MsgReqUserCheckIn(self, "signedCallBack", sType, 1, n, muliple);
end

--签到消息返回回调
function VSigninDlg:signedCallBack(result, rsp, req)
	if result == 0 then
		-- gEvent:pushEvent(EventId.sign_off);
		--同步签到数据
		local param = {};
	    param.syn_flag = 1;
	    param.data_type = GameDataType.DataTypeRoleInfo;
	    gReq:MsgReqUserDataSyn(self, "synchronismRespone", param);
	    self:showReWardTip(req.idx, req.type, req.muliple);
	    -- gWindow:showReWardTip(rsp.ri, "huodejiangli.png");
	else
		local idx = math.floor((self.signCount + 1)/6);
		self.tbv:updateCellAtIndex(idx);
		self:InitDlg();
	end
end

function VSigninDlg:synchronismRespone( result )
	if result == 0 then
		self:InitData();
		self:InitDlg();
		local n = self.signCount;
		local info = self.signData[n];
		local idx = math.ceil(n/self.cellCount) - 1;
		self.tbv:updateCellAtIndex(idx);
	end
end

--签到说明按钮响应
function VSigninDlg:onExploinBtnClick()
	if self("sd_exploinLayer").visible then
		self("sd_exploinLayer").visible = 0;
	else
		self("sd_exploinLayer").visible = 1;
	end
end

function VSigninDlg:SetTbvOffset(  )
	local maxpos = self.tbv:maxContainerOffset();
	local minpos = self.tbv:minContainerOffset();	
	local n = self.signCount;
	if self.signState == 0 then
		n = n + 1;
	end
	local idx = math.ceil(n/self.cellCount) - 1; 
	local offset = cc.p(minpos.x, math.min((minpos.y + idx * 150), maxpos.y));
	self.tbv:setContentOffset(offset);
end

function VSigninDlg:showReWardTip( idx, sType, muliple )
	local info = self.signData[idx];
	local t = {};
	t.type = info.rType;
	t.thingid = info.rid;
	t.name = info.name;
	t.image = info.image;
	t.count = info.count * muliple;

	local items = {t};
	local rewardTip = VNode("vRewardTip.vui");
	rewardTip:setItemInfo(items, "huodejiangli.png");
	gView():Push(rewardTip);
end