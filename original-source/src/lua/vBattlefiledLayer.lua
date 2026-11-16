VBattlefiledLayer = VClass("BattlefiledLayer", VLayer);

function VBattlefiledLayer:InitLayer()
	if self.isInit then
		self.visible = 1;
	end
	
	--玩家参与的战斗信息
	self.roleBattleInfo = gData.userInfo.roleInfo.roleBattleInfo;
	self.battleInfos = self.roleBattleInfo:getAllGroupBattleInfo();

	--初始化战场信息列表数据
	self.battlefiledInfo = {};

	--显示战场信息列表
	self.tbv = self("battlefiledTbv");
	self.tbv.delegate = self;

	--加载战场信息
	self:BatchQueryGroupBattleInfo();
end

function VBattlefiledLayer:ShowLayer( )
	gWindow:closeWaitTip();
	local offset = self.tbv:getContentOffset();
	self.tbv.number = #self.battlefiledInfo;
	self.tbv:reloadData();
	if self.isInit then
		self.tbv:setContentOffset(offset);
	end
	self.isInit = true;
	if self.delegate._curIndex == self.delegate._layerIndex.battlefield then
		self.visible = 1;
		
	end
	if self.tbv.number == 0 then
		self("bfTip").visible = 1;
	else
		self("bfTip").visible = 0;
	end
end

function VBattlefiledLayer:HideLayer(  )
	if self.roleBattleInfo then
		self.roleBattleInfo:ClearNewFinishInfo();
		self.roleBattleInfo:ClearNewAssistInfo();
	end
	self.visible = 0;
end

--批量查询我的战场信息
function VBattlefiledLayer:BatchQueryGroupBattleInfo()
	local battleIds = {};
	for i,v in ipairs(self.battleInfos) do 
		table.insert(battleIds, v.battleid);
	end
	gReq:MsgReqGroupBattleSelfInfoQuery(self, "BatchQueryGroupBattleInfoCallBack", battleIds);
	gWindow:showWaitTip("loading...", 10);
end
--批量查询我的战场信息返回
function VBattlefiledLayer:BatchQueryGroupBattleInfoCallBack( result, rsp, req )
	if result == 0 then
		local userids = {};
		if rsp then 
			--初始化战场信息列表数据
			self.battlefiledInfo = {};
			local infos = rsp.infos;
			local iter = VDataIter();
			while infos:Travel(iter) do
				local data = iter:Data();
				local sgbi = VSelfGroupBattleInfo:new();
				sgbi:synWithPbData(data);
				table.insert(self.battlefiledInfo, sgbi);
				table.insert(userids, sgbi.attacker);
				table.insert(userids, sgbi.defender);
			end
		end
		if next(userids) then
			gData:userBriefInfo(userids, self, "ShowLayer");
		else
			self:ShowLayer();
		end
	else
		gWindow:showTip("加载信息出错！请重试...");
		gWindow:closeWaitTip();
	end
end

function VBattlefiledLayer:onCell(idx, t, cell)
	if not cell then
		cell = VTableViewCell("vBattlefiledLayerCell.vui");
	end

	idx = idx + 1;
	local info = self.battlefiledInfo[idx];
	local battleInfo = self.battleInfos[idx];
	local attackerInfo = gData:briefCache(info.attacker);
	local defenderInfo = gData:briefCache(info.defender);
	if info.faction ==  1 then
		if attackerInfo then
			local atkUserImg = cell("atkUserImg");
			atkUserImg("atkNameText").text = attackerInfo.nick;
			atkUserImg("atkLvText").text = "Lv"..attackerInfo.level;
			local vipLevel = gData:GetVipLevel(attackerInfo.charge);
			cell("atkHeadImg"):setHead(attackerInfo.userid, attackerInfo.image, nil, vipLevel);
			cell("atkHeadImg"):SetHeadImageShader();
			cell("atkHeadImg").onClick = "node:Parent(4):OpenPlayerOpDlg("..info.attacker..")";
			atkUserImg("survivalText").text = info.attack_current;
			atkUserImg("totalText").text = "/"..info.attack_total;
			cell("atkIcon").image = "gong.png";
		end

		if defenderInfo then
			local defUserImg = cell("defUserImg");
			defUserImg("defNameText").text = defenderInfo.nick;
			defUserImg("defLvText").text = "Lv"..defenderInfo.level;
			local vipLevel = gData:GetVipLevel(defenderInfo.charge);
			cell("defHeadImg"):setHead(defenderInfo.userid, defenderInfo.image, nil, vipLevel);
			cell("defHeadImg"):SetHeadImageShader();
			cell("defHeadImg").onClick = "node:Parent(4):OpenPlayerOpDlg("..info.defender..")";
			defUserImg("survivalText").text = info.defend_current;
			defUserImg("totalText").text = "/"..info.defend_total;
			cell("defIcon").image = "fang.png";
		end
	else
		if defenderInfo then
			local defUserImg = cell("atkUserImg");
			defUserImg("atkNameText").text = defenderInfo.nick;
			defUserImg("atkLvText").text = "Lv"..defenderInfo.level;
			local vipLevel = gData:GetVipLevel(defenderInfo.charge);
			cell("atkHeadImg"):setHead(defenderInfo.userid, defenderInfo.image, nil, vipLevel);
			cell("atkHeadImg"):SetHeadImageShader();
			cell("atkHeadImg").onClick = "node:Parent(4):OpenPlayerOpDlg("..info.defender..")";
			
			defUserImg("survivalText").text = info.defend_current;
			defUserImg("totalText").text = "/"..info.defend_total;
			cell("atkIcon").image = "fang.png";
		end

		if attackerInfo then
			local atkUserImg = cell("defUserImg");
			atkUserImg("defNameText").text = attackerInfo.nick;
			atkUserImg("defLvText").text = "Lv"..attackerInfo.level;
			local vipLevel = gData:GetVipLevel(attackerInfo.charge);
			cell("defHeadImg"):setHead(attackerInfo.userid, attackerInfo.image, nil, vipLevel);
			cell("defHeadImg"):SetHeadImageShader();
			cell("defHeadImg").onClick = "node:Parent(4):OpenPlayerOpDlg("..info.attacker..")";
			atkUserImg("survivalText").text = info.attack_current;
			atkUserImg("totalText").text = "/"..info.attack_total;
			cell("defIcon").image = "gong.png";
		end

	end

	


	--阵营图标
	if info.faction == 1 or info.faction == 3 then
		cell("factionImg").image = "jinggongtiao.png";
	else
		cell("factionImg").image = "fangshoutiao.png";
	end

	
	if info.result == 0 then
		cell("cellBtn").topImage="jinruzhanchang.png"
		cell("cellBtn").image = "anniu9.png";
		cell("cellBtn").gray = 0;
		cell("cellBtn").onClick = "node:Parent(4):EnterGroupBattle("..idx..")";
		cell("intervalText").time = info.maxEndTime - gData:currentTime();
		cell("intervalText").visible = 1;
		cell("resultImg").visible = 0;
		cell("newTip").visible = 0;
		cell("fightingTxt").visible = 1;
		cell("atkNumTxt").visible = 1;
		if info.faction == 1 then
			cell("atkNumTxt").text = string.format("可攻击%d人", info.attackTargets);
		else
			cell("atkNumTxt").text = string.format("防守中%d人", info.defend_current);
		end
		cell("sunLayer").visible = 0;
		cell("coinLayer").visible = 0;
		cell("scoreLayer").visible = 0;
		cell("bannerLayer").visible = 0;
		if self:IsNewAssistBattle(info.battleid) then
			cell("newTip").visible = 1;
		else
			cell("newTip").visible = 0;
		end
	else
		if self:IsNewFinishBattle(info.battleid) then
			cell("newTip").visible = 1;
		else
			cell("newTip").visible = 0;
		end

		if info.result == 1 then
			if info.faction == 1  then
				cell("resultImg").image = "shenglijiaobiao.png";
				self:ShowWinRewardLayer(info.reward, cell);
			else
				cell("resultImg").image = "shibaijiaobiao.png";
				self:ShowFailRewardLayer(info.reward, cell);
			end
		else
			if info.faction == 1  then
				cell("resultImg").image = "shibaijiaobiao.png";	
				self:ShowFailRewardLayer(info.reward, cell);
			else
				cell("resultImg").image = "shenglijiaobiao.png";
				self:ShowWinRewardLayer(info.reward, cell);
			end
		end
		if not battleInfo then 
			gLog(string.format("can not find info from battleinfo at index %d, tbv number is %d", idx, t.number));
			return;
		end
		if battleInfo.isGetReward then
			cell("cellBtn").image = "anniu9.png";
			cell("cellBtn").topImage="yijinglingqu.png"
			cell("cellBtn").gray = 1;
			cell("cellBtn").onClick = "node:Parent(4):EnterFinishGroupBattle("..idx..")";	
		else
			cell("cellBtn").gray = 0;
			cell("cellBtn").image = "anniu8.png";
			cell("cellBtn").topImage="lingqujiangli.png";
			cell("cellBtn").onClick = "node:Parent(4):GetRewardBtnClick("..idx..")";
		end
		cell("intervalText"):setDelegateCallback(nil, nil);
		cell("intervalText").visible = 0;
		cell("intervalText").time = -1;
		cell("atkNumTxt").visible = 0;
		cell("resultImg").visible = 1;
		cell("fightingTxt").visible = 0;
	end
end

function VBattlefiledLayer:OpenPlayerOpDlg( userid )
	if userid == gData.userInfo.userid then return end;
	local info = gData:briefCache(userid);
	gData:OpenPlayerOpDlg(info);
end

-- --更新指定ID的团战战场信息
-- function VBattlefiledLayer:updateBattlefiledInfo( battleid )
-- 	if not battleid or battleid == 0 then return end
-- 	local battleIds = {battleid};
-- 	gReq:MsgReqGroupBattleSelfInfoQuery(self, "GroupBattleInfoByIdCallBack", battleIds);
-- end

-- function VBattlefiledLayer:GroupBattleInfoByIdCallBack( result, rsp, req )
-- 	if result == 0 then
-- 		if not rsp then return end;
-- 		local infos = rsp.infos;
-- 		local data = infos[0];
-- 		if data then
-- 			for i,v in ipairs(self.battlefiledInfo) do
-- 				if v.battleid == tostring(data.id) then
-- 					v:synWithPbData(data);
-- 					self.tbv:updateCellAtIndex(i-1);
-- 				end
-- 			end
-- 		end
-- 	end
-- end

--进入团战界面
function VBattlefiledLayer:EnterGroupBattle(idx)
	local info = self.battlefiledInfo[idx];
	local assitInfo = self.roleBattleInfo:GetRoleBattleAssistInfoById(info.battleid);
	assitInfo:SetSelfAssistTarget(info);
	ShowGroupBattleDlgByAssistInfo(assitInfo);
end

--进入结束的团战界面
function VBattlefiledLayer:EnterFinishGroupBattle( idx )
	local info = self.battlefiledInfo[idx];
	info:SetAssistTarget();
	ShowGroupBattleDlgByAssistInfo(info);
end

--领取团战奖励
function VBattlefiledLayer:GetRewardBtnClick( idx )
	local info = self.battlefiledInfo[idx];
	local limitInfo = {};
	for i,v in pairs(info.reward.returnAttrInfo) do
		local sub = gData:IsResoureUpperLimit(1,v.type,v.count);
		if sub then
			local item = {};
			item.type = 1;
			item.id = v.type;
			item.count = sub;
			table.insert(limitInfo, item);
		end
	end
	if next(limitInfo) then
		gWindow:showUpperlimitTip(limitInfo, self, "sendGetRewardMsg", idx);
		return;
	end
	self:sendGetRewardMsg(idx);
end

function VBattlefiledLayer:sendGetRewardMsg( idx )
	local info = self.battlefiledInfo[idx];
	gReq:MsgReqGroupBattleReward(self, "GetRewardCallBack", info.battleid);
	gWindow:showWaitTip("loading...",10);
end

--领取团战奖励返回
function VBattlefiledLayer:GetRewardCallBack( result, rsp, req )
	if result == 0 then
		gWindow:showReWardTip(rsp.ri, "huodejiangli.png");
		self.delegate:RefreshRes();
		local battleid = rsp.info.battleid;

		for i,v in ipairs(self.battleInfos) do
			if v.battleid == battleid then
				v:synWithPbData(rsp.info);
				self.tbv:updateCellAtIndex(i-1);
				break;
			end
		end
	end
	gWindow:closeWaitTip();
end

--判断该团战是否是新结束的
function VBattlefiledLayer:IsNewFinishBattle( id )
	for i,v in ipairs(self.roleBattleInfo.newFinishInfo) do 
		if v == id then
			return true;
		end
	end
	return false;
end

--判断该团战是否是新开启的
function VBattlefiledLayer:IsNewAssistBattle( id )
	for i,v in ipairs(self.roleBattleInfo.newAssistInfo) do
		if v == id then
			return true;
		end
	end
	return false;
end

--显示失败结束的战场奖励
function VBattlefiledLayer:ShowFailRewardLayer(reward, cell )
	local scoreReward,bannerReward = 0,0;
	for i,v in ipairs(reward.returnThingInfo) do 
		if v.type == 2 and v.thingid == 5002 then
			bannerReward = v.count;
		end
	end
	for i,v in ipairs(reward.returnAttrInfo) do
		if v.type == AttrType.AttrTypeBattleScore then
			scoreReward = v.value;
		end
	end
	cell("scoreCasualtyNum").text = scoreReward;
	cell("bannerCasualtyNum").text = bannerReward;

	cell("scoreLayer").offset = {5,0};
	cell("bannerLayer").offset = {8,0};
	cell("sunLayer").visible = 0;
	cell("coinLayer").visible = 0;
	cell("scoreLayer").visible = 1;
	cell("bannerLayer").visible = 1;
end

--显示成功结束的战场奖励
function VBattlefiledLayer:ShowWinRewardLayer(reward, cell)
	local sun,coin,scoreReward,bannerReward = 0,0,0,0;
	for i,v in ipairs(reward.returnAttrInfo) do
		if v.type == AttrType.AttrTypeSunshine then
			sun = v.value;
		elseif v.type == AttrType.AttrTypeMoney then
			coin = v.value;
		elseif v.type == AttrType.AttrTypeBattleScore then
			scoreReward = v.value;
		end
	end
	for i,v in ipairs(reward.returnThingInfo) do 
		if v.type == 2 and v.thingid == 5002 then
			bannerReward = v.count;
		end
	end

	cell("scoreCasualtyNum").text = scoreReward;
	cell("bannerCasualtyNum").text = bannerReward;
	cell("sunCasualtyNum").text = sun;
	cell("coinCasualtyNum").text = coin;
	cell("scoreLayer").offset = {5,10};
	cell("bannerLayer").offset = {8,10};
	cell("sunLayer").visible = 1;
	cell("coinLayer").visible = 1;
	cell("scoreLayer").visible = 1;
	cell("bannerLayer").visible = 1;
end