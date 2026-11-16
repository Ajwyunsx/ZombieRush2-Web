VRobOptionLayer = VClass("RobOptionLayer", VLayer);

function VRobOptionLayer:InitLayer()
	if self.isInit then
		self.visible = 1;
	end
	if not self.isInit then
		self.recommendTargets = {};
		self.refreshTimer = self("refreshTimer");
		self.tbv = self("robOptionTbv");
		self.tbv.delegate = self;

		gWindow:showWaitTip("loading...",10);
	end
	--查询肥羊列表
	self.recommendTargetInfo = gData.userInfo.roleInfo.recommendTargetInfo;
	self.attackedInfos = gData.userInfo.roleInfo.attackedInfos;
	self.roleBattleInfo = gData.userInfo.roleInfo.roleBattleInfo;

	self:LoadRecommendTargetInfo();
	self.isInit = true;
end

function VRobOptionLayer:HideLayer()
	self.visible = 0;
end

function VRobOptionLayer:InitData()
	
	--批量查询玩家战斗信息
	if next(self.recommendTargetInfo.targets) then
		gData:userBriefBattleInfo(self, "BriefBattleInfoCallBack", self.recommendTargetInfo.targets);
	else
		self.recommendTargets = {};
		self:ShowLayer();
	end
end

function VRobOptionLayer:ShowLayer()
	gWindow:closeWaitTip();
	local time = self.recommendTargetInfo.refreshTime - gData:currentTime();
	--设置肥羊列表刷新倒计时
	self.refreshTimer.time = time;
	
	--设置倒计时结束后，重新获取肥羊列表
	self.refreshTimer:setDelegateCallback(self, "LoadRecommendTargetInfo");	

	--刷新按钮

	local lineData = gData:LoadUserCommon();
	self.cost = lineData.refreshCost;
	self("costText").text = self.cost;
	self("refreshBtn").visible = 1;
	self("refreshBtn"):ReLayout();
	self("refreshBtn"):setEnable(true);

	self.tbv.number = math.ceil(#self.recommendTargets/2);
	self.tbv:reloadData();

	if self.delegate._curIndex == 1 then
		self.visible = 1;
	end
end

--批量查询玩家战斗信息返回
function VRobOptionLayer:BriefBattleInfoCallBack( userBattleInfos )
	-- gWindow:showTip("BriefBattleInfoCallBack");
	self.recommendTargets = {};
	for i,v in pairs(userBattleInfos) do
		table.insert(self.recommendTargets,v);
	end
	self:ShowLayer();
	-- gWindow:closeWaitTip();
end

--更新肥羊列表
function VRobOptionLayer:LoadRecommendTargetInfo(  )
	--客户端没有肥羊列表，或者刷新时间到了，就重新查询一下
	if self.recommendTargetInfo.refreshTime <= gData:currentTime() then
		gReq:MsgReqFindOpponent(self, "LoadRecommendTargetInfoBack", false);
		return;
	end

	self:InitData();
end

--更新肥羊列表数据返回
function VRobOptionLayer:LoadRecommendTargetInfoBack( result, rsp, req )
	if result == 0 then
		gData.userInfo.roleInfo.recommendTargetInfo:synWithPbData(rsp.info);
		self.recommendTargetInfo = gData.userInfo.roleInfo.recommendTargetInfo;
		self.delegate:RefreshRes();
	else
		gWindow:showTip("掠夺列表数据错误！", 2);
	end
	--初始化数据
	self:InitData();
end

local function isInAssitBattle( id )
	for i,v in ipairs(gData.userInfo.roleInfo.roleBattleInfo.assistInfo) do
		if v.battleid == id then
			return v.aType;
		end
	end
end

function VRobOptionLayer:onCell(idx, t, cell)
	for i=1, 2 do
		local item = cell("itemBgImg"..i);
		local n = 2 * idx + i;
		local info = self.recommendTargets[n];
		if info then
			local vipLevel = gData:GetVipLevel(info.charge);
			item("headImage"):setHead(info.userid, info.image, nil, vipLevel);
			item("headImage"):SetHeadImageShader();
			item("headImage").touch = 1;
			item("headImage").onClick = "node:Parent(4):OpenPlayerOpDlg("..n..")";
			item("nameText").text = info.nick;
			item("coinText").text = info.money;
			item("sunText").text = info.sunshine;
			item("lvText").text = "Lv"..info.level;
			-- local bi = info.battle_infos;
			--进攻是否冷却
			local cellRobBtn = item("cellRobBtn");
			local cellRobTip = item("cellRobTip");
			local coolDownTimer = item("coolDownTimer");
			local time = self:GetAttackedTime(info.userid);
			if time > 0 then
				cellRobBtn.visible = 0;
				cellRobTip.color = {0,0,0};
				cellRobTip.text = "已掠夺";
				coolDownTimer.visible = 1;
				cellRobTip.visible = 1;
				coolDownTimer.time = time;
			--是否在防守
			elseif info:IsDefendBattle() then
				--是否可以围剿
				local bid = info:IsFighting();
				if bid then
					if isInAssitBattle(bid) then
						cellRobBtn.visible = 1;
						cellRobBtn.image = "anniu9.png"
						cellRobBtn.topImage = "yijingcanzhan.png";
						cellRobBtn.onClick = "node:Parent(4):enterGroupBattle("..n..")";
						coolDownTimer.visible = 0;
						cellRobTip.visible = 0;
					else
						cellRobBtn.visible = 1;
						cellRobBtn.image = "anniu9.png"
						cellRobBtn.topImage = "weijiao1.png";
						cellRobBtn.onClick = "node:Parent(4):onAssistBtnClick("..n..")";
						coolDownTimer.visible = 0;
						cellRobTip.visible = 0;
					end
				else
					--战斗中
					cellRobTip.text = "战斗中";
					cellRobTip.color = {224,20,13};
					cellRobBtn.visible = 0;
					coolDownTimer.visible = 0;
					cellRobTip.visible = 1;
				end
			--可掠夺
			else
				cellRobBtn.visible = 1;
				cellRobBtn.image = "anniu8.png"
				cellRobBtn.topImage = "lueduo2.png";
				cellRobBtn.onClick = "node:Parent(4):onRobBtnClick("..n..")";
				coolDownTimer.visible = 0;
				cellRobTip.visible = 0;
			end
		else
			item.visible = 0;
		end
	end
end

--打开玩家头像操作界面
function VRobOptionLayer:OpenPlayerOpDlg( n )
	local info = self.recommendTargets[n];
	gData:OpenPlayerOpDlg(info);
end

--掠夺是否CD
function VRobOptionLayer:GetAttackedTime( id )
	local v = self.attackedInfos[id];
	if v then
		return v:GetAttackedCoolDownTime();
	end
	return 0;
end

--刷新按钮响应
function VRobOptionLayer:onRefreshBtnClick(  )
	local vcoin = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency);
	if vcoin < self.cost then
		gWindow:showMoneyLackDlg(self.cost-vcoin);
		return;
	end
	--重新拉肥羊列表
	if self.recommendTargetInfo.refreshTime > gData:currentTime() then
		gReq:MsgReqFindOpponent(self, "LoadRecommendTargetInfoBack", 1);
		self("refreshBtn"):setEnable(false);
	end
end

--围剿按钮响应
function VRobOptionLayer:onAssistBtnClick(n)
	if not self.delegate:IsAssitAtkEnable() then
		gWindow:showTip("可进攻/助攻次数不足！", 2);
		return;
	end
	local info = self.recommendTargets[n];
	local curTime = gData:currentTime();
	for i,v in ipairs(info.battle_infos) do
		if v.aType == 2 and v.assistTime > curTime then
			v:SetAssistTarget(info.userid, v.target);
			ShowGroupBattleDlgByAssistInfo(v);
			return;
		end
	end
end

--进入已经参与的团战
function VRobOptionLayer:enterGroupBattle( n )
	local info = self.recommendTargets[n];
	local bid = info:IsFighting();
	ShowGroupBattleDlgByAssistId(bid);
end

--冷却CD摁钮响应
function VRobOptionLayer:onCoolDownBtnClick(n)
	gWindow:showTip("进攻冷却ING...!", 2);
end


--掠夺按钮响应
function VRobOptionLayer:onRobBtnClick( n )
	if not self.delegate:IsAssitAtkEnable() then
		gWindow:showTip("可进攻/助攻次数不足！", 2);
		return;
	end

	if gData:IsResoureUpperLimit(1,20,1) or gData:IsResoureUpperLimit(1,21,1) then
		local msg = "您的资源已达金库上限，超出部分将无法获得，是否继续掠夺？";
		local title = "提示";
		local okTip = "掠夺";
		local cancelTip = "取消";
		gWindow:showConfirmTip(msg,okTip,cancelTip,self,"sendRobQuest",nil,title,n);
		return;
	end
	self:sendRobQuest(n);
end

--继续掠夺
function VRobOptionLayer:sendRobQuest( n )
	if gMainView then
		local info = self.recommendTargets[n];
		gMainView:sendBattleRequest(info.userid, EBattleRequestType.Observe, nil, info);
	end
end

