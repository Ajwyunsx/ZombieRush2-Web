VClanWarDlg = VClass("ClanWarDlg", VMsgBox);
require "vGroupMember"
require "vClanHelpTip"
--设置团战数据
--[[Params:
	VRoleBattleAssistInfo assistInfo;		--战场信息
]]
function VClanWarDlg:SetGroupBattleInfo(groupBattleInfo)
	self.groupBattleInfo = groupBattleInfo;
end

function VClanWarDlg:SetAssistInfo( assistInfo )
	self.assistInfo = assistInfo;
end

--初始化
function VClanWarDlg:onPush()
	-- self.chatLayer = self("chatLayer");
	self.logBtn = self("logBtn");
	self.chatBtn = self("chatBtn");
	self.reinforceTime = self("reinforceTime");
	self.scoreNum = self("scoreNum");
	self.joinBtn = self("joinBtn");
	self.msgText = self("msgText");
	self.timeEnd = self("timeEnd");
	self.helpBtn = self("helpBtn");
	self.timeTipEnd = self("timeTipEnd");
	self.resultTip = self("resultTip");
	self.assistBtn = self("assistBtn");
	self.tbv = self("clanTbv");
	self.resultIconA = self("resultIconA");
	self.resultIconD = self("resultIconD");
	self.tbv.delegate = self;

	self.roleBattleInfo = gData.userInfo.roleInfo.roleBattleInfo;

	self.newMember = {};
	self.msgList = {};
	gWindow:showWaitTip("loading...",10);
	--如果已经取得团战信息
	if self.groupBattleInfo then
		--加载团战参与玩家的基础信息
		self:LoadMembersBaseInfo();
		return;
	end

	--查询团战信息
	self.roleBattleInfo:getGroupBattleInfoById(self, "GroupBattleInfoCallBack", self.assistInfo.battleid);
end

--退出
function VClanWarDlg:onPop(  )
	local pvpDlg = gView()("pvpOptionDlg");
	if pvpDlg then
		pvpDlg:RefreshRes();
	    pvpDlg:UpdateAssitInfo();
		local ly = pvpDlg.optionTable[pvpDlg._curIndex];
		ly:InitLayer();
	end
end

--从桌面返回游戏
function VClanWarDlg:onForeground(  )
	if self.groupBattleInfo and self.groupBattleInfo.result == 0 and self.groupBattleInfo.id then
		gWindow:showWaitTip("loading...",10);
		self.roleBattleInfo:getGroupBattleInfoById(self, "onForegroundCallBack", self.groupBattleInfo.id);
	end
end

--获取数据返回
function VClanWarDlg:onForegroundCallBack( groupBattleInfo )
	gWindow:closeWaitTip();
	if not groupBattleInfo then 
		return;
	end
	self.groupBattleInfo = groupBattleInfo;
	self:InitDlg();
end

--查询团战信息回调
function VClanWarDlg:GroupBattleInfoCallBack( groupBattleInfo )
	if groupBattleInfo then
		self.groupBattleInfo = groupBattleInfo;

		--加载团战参与玩家的基础信息
		self:LoadMembersBaseInfo();
	else
		gWindow:showTip("读取数据出错，请重试！", 2);
		self:doPop();
	end
end


--获取消息提示
function VClanWarDlg:GetMsgTip(  )
	if self.groupBattleInfo.faction == 1 or self.groupBattleInfo.faction == 3 then
		return self.groupBattleInfo.attackChannel[1];
	elseif self.groupBattleInfo.faction == 2 or self.groupBattleInfo.faction == 4 then
		return self.groupBattleInfo.defendChannel[1];
	else
		return;
	end
end

--团战数据变化，更新
function VClanWarDlg:ActionGroupBattleChange(  )
	--重新获取一份团战数据
	if self.groupBattleInfo.id then
		self.roleBattleInfo:getGroupBattleInfoById(self, "RefreshGroupBattleInfoCallBack", self.groupBattleInfo.id);
	end
end

--团战数据更新请求回调函数
function VClanWarDlg:RefreshGroupBattleInfoCallBack( groupBattleInfo )
	if not groupBattleInfo then 
		return;
	end
	self.groupBattleInfo = groupBattleInfo;
	self:InitDlg();
end

--预加载团战成员基础信息
function VClanWarDlg:LoadMembersBaseInfo( )
	local userids = {};
	for i,v in ipairs(self.groupBattleInfo.attackMembers) do
		table.insert(userids, v.userid);
	end
	for i,v in ipairs(self.groupBattleInfo.defendMembers) do
		table.insert(userids, v.userid);
	end
	if next(userids) then
		gData:userBriefInfo(userids, self, "InitDlg");
	else
		self:InitDlg();
	end
end

--初始化团战界面
function VClanWarDlg:InitDlg( )
	gWindow:closeWaitTip();
	--当团战未结束时
	if self.groupBattleInfo.result == 0 then
		--如果已经加入了团战
		if self.groupBattleInfo.faction ~= 0 then
			--显示消息提示
			local msg = self:GetMsgTip();
			self:ShowMsgTip(msg);
			if not next(self.msgList) then 
				table.insert(self.msgList, msg);
			end
			--初始化聊天界面
			self.joinBtn.visible = 0;
			self.chatBtn.visible = 1;
			self.logBtn.visible = 1;
			self.resultTip.visible = 0;
		else
			self("msgImg").visible = 0;
			self.chatBtn.visible = 0;
			self.logBtn.visible = 0;
			self.joinBtn.visible = 1;
			self.resultTip.visible = 1;

			if self.assistInfo.assistTarget == self.groupBattleInfo.attackerId then
				self.joinBtn.topImage = "jiarugongfang.png";
				self.resultTip.text = "加入攻方可掠夺资源和植物碎片";
			else
				self.joinBtn.topImage = "jiarushoufang.png";
				self.resultTip.text = "加入守方不会被掠夺资源";
			end
		end
		self.timeEnd.visible = 1;
		self.timeTipEnd.visible = 1;
		self.helpBtn.visible = 1;
		self:UpdateAssistTime();
		self.resultIconA.visible = 0;
		self.resultIconD.visible = 0;
	else
		self.reinforceTime:stopCountDown();
		self.timeEnd.visible = 0;
		self.timeTipEnd.visible = 0;
		self.helpBtn.visible = 0;
		self.reinforceTime.visible = 0;
		self("msgImg").visible = 0;
		self.chatBtn.visible = 0;
		self.logBtn.visible = 1;
		self.joinBtn.visible = 0;
		self.resultTip.visible = 1;
		self.resultIconA.visible = 1;
		self.resultIconD.visible = 1;
		if self.groupBattleInfo.result == 1 then
			self.resultIconA.image = "shenglijiaobiao.png";
			self.resultIconD.image = "shibaijiaobiao.png";
			if self.groupBattleInfo.faction == 1 or self.groupBattleInfo.faction == 3 then
				self.resultTip.text = "祝贺你，本次团战你获得了辉煌的胜利！";
			else
				self.resultTip.text = "很遗憾，本次团战你失败了！";
			end
		else
			self.resultIconA.image = "shibaijiaobiao.png";
			self.resultIconD.image = "shenglijiaobiao.png";
			if self.groupBattleInfo.faction == 1 or self.groupBattleInfo.faction == 3 then
				self.resultTip.text = "很遗憾，本次团战你失败了！";
			else
				self.resultTip.text = "祝贺你，本次团战你获得了辉煌的胜利！";
			end
		end
	end
	self:UpdateScore();
	self:UpdateClanCommon();
	self:UpdateAssisitBtn();
	--初始化攻守双方列表
	-- self.mvpId = self.groupBattleInfo:GetMvpId();
	self.tbv.number = math.max(#self.groupBattleInfo.defendMembers, #self.groupBattleInfo.attackMembers);
	self.tbv:reloadData();
	self("tbvBgLayer").visible = 1;

	self:LoadNewMembersBaseInfo();
end

--更新团战时间
function VClanWarDlg:UpdateAssistTime(  )
	local time = self.groupBattleInfo.assistTime + self.groupBattleInfo.closeCountdown - gData:currentTime();
	local assistTime = time - self.groupBattleInfo.closeCountdown;
	if self:IsOnTimer("UpdateAssisitBtn") then
		self:StopTimer("UpdateAssisitBtn");
	end
	if assistTime > 0 then
		self:StartTimer("UpdateAssisitBtn", assistTime, 1);
	end
	if time > 0 then 
		self.reinforceTime.time = time;
		self.reinforceTime.visible = 1;
	else
		self.reinforceTime.time = 0;
	end
end

--更新我的战绩
function VClanWarDlg:UpdateScore(  )
	--我的战绩
	local score = self.groupBattleInfo:GetSelfScore();
	self.scoreNum.text = score;
	self.scoreNum.visible = 1;
end

--更新战斗双方的状况
function VClanWarDlg:UpdateClanCommon()
	--防御方
	self("defenderCount").text = string.format("守方:%d人", #self.groupBattleInfo.defendMembers);
	self("defendNick").text = gData:briefCache(self.groupBattleInfo.defenderId).nick;


	--进攻方
	self("atkCount").text = string.format("攻方:%d人", #self.groupBattleInfo.attackMembers);
	self("atkNick").text = gData:briefCache(self.groupBattleInfo.attackerId).nick;
end

--更新援助按钮
function VClanWarDlg:UpdateAssisitBtn()
	self.assistBtn.visible = 0;
	if self.groupBattleInfo.result == 0 then
		--如果是主战双方
		if self.groupBattleInfo.faction ~= 0 then
			if self.groupBattleInfo.assistTime > gData:currentTime() then
				self.assistBtn.visible = 1;
				self.timeTipEnd.text = string.format("(最后%d分钟不能增援)", 
					math.modf(self.groupBattleInfo.closeCountdown/60));
			else
				self.timeTipEnd.text = "(不可增援)";
			end
		end
	end
end

--显示消息泡泡
function VClanWarDlg:ShowMsgTip( msg )
	if not msg then
		self("msgImg").visible = 0;
		return;
	end
	self("msgImg").visible = 1;
	self.msgText:setDimensions(0,0);
	local strlen = stringLen(msg.context);
	local context = stringSub(msg.context,1,26);
	if strlen > 26 then 
		context = context.."...";
	end
	if msg.from == 0 then
		self.msgText.text = "系统："..context;
	else
		local sender = gData:briefCache(msg.from);
		if sender then
			self.msgText.text = sender.nick.."："..context;
		else
			self.msgText.text = msg.from.."："..context;
		end
	end
	
	local size = self.msgText.size;
	local h,w;
	local lineCont = math.ceil(size.width/370);
	h = (size.height + 5) * lineCont;

	w = math.min(320, size.width);
	self.msgText:setDimensions(w,h);
	if h < 50 then h = 50 end
	self("msgImg").size = {w+50, h};
end

--聊天按钮点击
function VClanWarDlg:onChatBtnClick()
	local msg = self:GetMsgTip();
	self.chatDlg = VNode("vChatLayer.vui");
	self.chatDlg.delegate = self;
	self:Push(self.chatDlg);
end

--日志按钮点击
function VClanWarDlg:onLogBtnClick()
	local log = VNode("vBattlefiledLog.vui");
	log:SetLogInfo(self.groupBattleInfo.attackedInfos, self.groupBattleInfo.faction);
	gView():Push(log);
end

--加入团战按钮响应
function VClanWarDlg:onJoinGroupBattleBtnClick(  )
	self.reinforceTime:stopCountDown();
	self.joinBtn.visible = 0;
	gReq:MsgReqGroupBattleJoin(self, "onJoinGroupBattleCallBack", self.assistInfo.assistTarget, 
		self.groupBattleInfo.attackerId, self.groupBattleInfo.defenderId, self.groupBattleInfo.id)
end


--加入团战回调
function VClanWarDlg:onJoinGroupBattleCallBack( result, rsp, req )
	if result == 0 then
		--同步我的战斗数据
		local assist_info = rsp.assist_info;
		self.roleBattleInfo:synWithAssistInfo(assist_info);
		--查询团战信息
		self.roleBattleInfo:getGroupBattleInfoById(self, "GroupBattleInfoCallBack", self.assistInfo.battleid);
	end
end


--增援按钮点击响应
function VClanWarDlg:AssistBtnOnClick()
	local msg = "是否在世界频道发送求援信息？";
	local target;
	if self.groupBattleInfo.faction == 1 or self.groupBattleInfo.faction == 3 then
		target = self.groupBattleInfo.defenderId;
	else
		target = self.groupBattleInfo.attackerId;
	end
	gWindow:showConfirmTip(msg,"求援","取消",gData,"SetHelpMsg", nil, nil,
		 self.groupBattleInfo.id, target, self.groupBattleInfo.faction);
end

--添加需要加载的新团战成员id
function VClanWarDlg:PushNewMembersId( id )
	table.insert(self.newMember, id);
end

--加载新团战成员基础信息
function VClanWarDlg:LoadNewMembersBaseInfo()
	if next(self.newMember) then
		gData:userBriefInfo(self.newMember, self, "NewMemberBaseInfoCallBack");
	end
end

--加载新团战成员基础信息回调
function VClanWarDlg:NewMemberBaseInfoCallBack( )
	self.newMember = {};
	self.tbv:reloadData();
end

--显示公共信息
function VClanWarDlg:ShowCellCommonInfo( info, item )
	if info.userid == self.groupBattleInfo.attackerId or 
		info.userid == self.groupBattleInfo.defenderId then
		item("indexIcon").image = "tuanzhanbianhao.png";
	else
		item("indexIcon").image = "tuanzhanzengyuan.png";
	end

	--是否是自己
	if info.userid == gData.userInfo.userid then
		item("blinkImg").visible = 1;
	else
		item("blinkImg").visible = 0;
	end
end

function VClanWarDlg:onCell( idx, t, cell )
	idx = idx + 1;
	--显示防御者信息
	self:ShowDefenderCell(idx, cell);

	--显示攻击者信息
	self:ShowAttackerCell(idx, cell);
end


function VClanWarDlg:ShowDefenderCell( idx, cell )
	local info = self.groupBattleInfo.defendMembers[idx];
	if not cell then
		cell = VTableViewCell("vClanWarDlgCell.vui")
	end
	local item = cell("defendLayer");
	if info then
		item.visible = 1;
		item("creatureText").text = "剩余道路："..(#info.roads);
		--其他公共信息
		self:ShowCellCommonInfo(info, item);	

		--是否死亡
		if info.isDead then
			item("defendImg").gray = 1;
			item("deadIcon").visible = 1;
		else
			item("deadIcon").visible = 0;
			item("defendImg").gray = 0;
		end	

		--基础信息
		local faction = 2;
		self:ShowCellBaseInfo(info, item, idx, faction);

		--显示战斗状态
		if self.groupBattleInfo.result == 0 then
			if self.groupBattleInfo.faction == 0 then
				if info.isDead then
					cell("fightBgImg").visible = 0;
					item("attackBtn").visible = 0;
					item("defendTip").visible = 0;
				else
					if info.isFighting then
						cell("fightBgImg").visible = 1;
						cell("fightTime").time = info.fightEndTime;
						item("defendTip").visible = 0;
						item("attackBtn").visible = 0;
					else
						cell("fightBgImg").visible = 0;
						if self.assistInfo.assistTarget == self.groupBattleInfo.attackerId then
							item("attackBtn").visible = 1;
							item("attackBtn"):setEnable(true);
							item("defendTip").visible = 0;
							item("attackBtn").onClick = "gWindow:showTip('加入攻方才可以进行攻击！',1);";
						else
							item("attackBtn").visible = 0;
							item("defendTip").visible = 1;
						end
					end
				end
			elseif self.groupBattleInfo.faction == 1 or self.groupBattleInfo.faction == 3 then
				item("defendTip").visible = 0;
				if info.isDead then
					cell("fightBgImg").visible = 0;
					item("attackBtn").visible = 0;
				else
					if info.isFighting then
						cell("fightBgImg").visible = 1;
						cell("fightTime").time = info.fightEndTime;
						item("attackBtn").visible = 0;
					else
						cell("fightBgImg").visible = 0;
						item("attackBtn").visible = 1;
						if self:isAttackEnable(info.userid) and not self.groupBattleInfo.isDead then
							item("attackBtn"):setEnable(true);
							item("attackBtn").onClick = "node:Parent(7):onAttackBtnClick("..idx..")";
						else
							item("attackBtn"):setEnable(false);
						end
					end
				end
			else
				item("attackBtn").visible = 0;
				if info.isDead then
					cell("fightBgImg").visible = 0;
					item("defendTip").visible = 0;
				else
					if info.isFighting then
						cell("fightBgImg").visible = 1;
						cell("fightTime").time = info.fightEndTime;
						item("defendTip").visible = 0;
					else
						cell("fightBgImg").visible = 0;
						item("defendTip").visible = 1;
					end
				end
			end
		else
			cell("fightBgImg").visible = 0;
			cell("attackBtn").visible = 0;
			item("defendTip").visible = 0;
		end
	else
		item.visible = 0;
		cell("fightBgImg").visible = 0;
	end
end

function VClanWarDlg:ShowAttackerCell( idx, cell )

	local info = self.groupBattleInfo.attackMembers[idx];
	local item = cell("attackLayer");
	if info then 
		item.visible = 1;
		--是否死亡
		if info.isDead then
			item("attackImg").gray = 1;
			item("deadIcon").visible = 1;
		else
			item("attackImg").gray = 0;
			item("deadIcon").visible = 0;
		end
		--其他公共信息
		self:ShowCellCommonInfo(info, item);		
		item("creatureText").text = string.format("突破道路：%d",info.breaks);
		--基础信息
		local faction = 1;
		self:ShowCellBaseInfo(info, item, idx, faction);
	else
		item.visible = 0;
	end
end

--玩家是否在被打
function VClanWarDlg:isAttackEnable( userid )
	for i,v in ipairs(self.groupBattleInfo.attackedInfos) do
		if v.defender == userid and v.attacker == gData.userInfo.userid then
			return false;
		end
	end
	return true;
end

--显示基础信息
function VClanWarDlg:ShowCellBaseInfo( info, item, idx, faction )
	local baseInfo = gData:briefCache(info.userid);

	--如果该成员的基础信息没有加载，则显示默认界面
	if not baseInfo then
		self:PushNewMembersId(info.userid);
		return;
	end
	local vipLevel = gData:GetVipLevel(baseInfo.charge);
	item("nameText").text = baseInfo.nick;
	item("headImage"):setHead(baseInfo.userid, baseInfo.image, nil, vipLevel);
	item("headImage"):SetHeadImageShader();
	if baseInfo.userid ~= gData.userInfo.userid then
		item.touch = 1;
		item.onClick = "node:Parent(5):OpenPlayerOpDlg("..idx..","..faction..")";
	else
		item.touch = 0;
	end

	item("lvText").text = "Lv"..baseInfo.level;
end

--打开玩家头像操作界面
function VClanWarDlg:OpenPlayerOpDlg( idx, faction )
	local info;
	if faction == 1 then
		info = self.groupBattleInfo.attackMembers[idx];
	else
		info = self.groupBattleInfo.defendMembers[idx];
	end
	local baseInfo = gData:briefCache(info.userid);
	local node = VNode("vGroupMember.vui");
	node:SetUserInfoAndBattleInfo(baseInfo, info, faction, self);
	gView():Push(node);
	-- gData:OpenPlayerOpDlg(baseInfo);
end


--点击进攻按钮
function VClanWarDlg:onAttackBtnClick( n )
	local info = self.groupBattleInfo.defendMembers[n];
	gMainView:sendBattleRequest(info.userid, EBattleRequestType.Observe, self.groupBattleInfo.id, info);
end

--插入消息
function VClanWarDlg:PushMsg( msg )
	for i,v in ipairs(self.msgList) do 
		if v.id ~= msg.id then 
			table.insert(self.msgList, msg);
		end
	end
	if self.chatDlg then
		self.chatDlg:ShowLayer();
	end
end

--新消息通知
function VClanWarDlg:ActionGroupBattleChat(info)
	local msg = {};
	msg.from = info.userid;
	msg.context = info.param;
	msg.time = gData:currentTime();
	self:ShowMsgTip(msg);
	self:PushMsg(msg);
end

----------------------------------------------------------------------------------
--VClanWarCell

VClanWarCell = VClass("ClanWarCell", VTableViewCell);