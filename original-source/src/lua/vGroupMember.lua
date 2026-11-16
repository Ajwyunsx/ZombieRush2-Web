--vGroupMember.lua

VGroupMember = VClass("GroupMember", VMsgBox);

function VGroupMember:onPush()
	self.enemyList = gData.userInfo.enemyInfos.enemys;
    self.friendList = gData.userInfo.friendInfos.friends;
    self("titleText").text = "选择操作";
    self:InitBtns();
end

function VGroupMember:onPushFinish(  )
    self:InitBattleInfo();
end

function VGroupMember:InitBattleInfo(  )
	local vipLevel = gData:GetVipLevel(self.userInfo.charge);
	self("headImage"):setHead(self.userInfo.userid, self.userInfo.image, nil, vipLevel);
	self("headImage"):SetHeadImageShader();

	self("name").text = "昵称 : "..self.userInfo.nick;
	self("level").text = "Lv"..self.userInfo.level;
	
	self("idTxt").text = "ID : "..self.userInfo.userid;
	self("score").text = "战功 : "..self.delegate.groupBattleInfo:GetGroupMemberScore(
			self.battleInfo.score, self.faction);
	if self.faction == 2 then
		self("kill").text = string.format("剩余道路 : %d", #self.battleInfo.roads);
		
		self("creature").text = "植物 : 剩余"..(#self.battleInfo.plants);
		self("power").visible = 1;
		self("power").text = string.format("战力 : %d", self.battleInfo.combat);
	else
		self("kill").text = string.format("突破道路 : %d", self.battleInfo.breaks);
		self("creature").visible = 0;
		self("power").visible = 0;
	end
end

function VGroupMember:getPlantPower(  )
	local data = CreateCsvCacheByCsvNameAndKeys("prop_creature_plant.csv",0);
	local power = 0;
	if self.battleInfo.plants then
		for i,v in ipairs(self.battleInfo.plants) do 
			local lineData = data[tostring(v.propid)];
			power = power + lineData.combat;
		end
	end
	return power;
end

function VGroupMember:SetUserInfoAndBattleInfo(userInfo, battleInfo, faction, delegate)
	self.userInfo = userInfo;
	self.battleInfo =  battleInfo;
	self.faction = faction;
	self.delegate = delegate;
end

--聊天按钮响应
function VGroupMember:onChatClick()
    gMainView:openChatDlg(self.battleInfo.userid);
end

--初始化按钮
function VGroupMember:InitBtns(  )
	local relation = self:getUserRelation(self.battleInfo.userid);
	if relation == 3 then 
		self("btn0").visible = 1;
		self("btn0").onClick = "node:Parent(1):onLookFarmClick()";
		self("btn1").text = "设为仇敌";
		self("btn1").onClick = "node:Parent(1):addEnemyClick(node)";
		self("btn2").text = "设为好友";
		self("btn2").onClick = "node:Parent(1):addFriendClick(node)";
	elseif relation == 2 then
		self("btn0").visible = 0;
		self("btn1").text = "删除仇敌";
		self("btn1").onClick = "node:Parent(1):delEnemyClick(node)";
		self("btn2").text = "访问农场";
		self("btn2").onClick = "node:Parent(1):onLookFarmClick(node)";
	elseif relation == 1 then
		self("btn0").visible = 0;
		self("btn1").text = "删除好友";
		self("btn1").onClick = "node:Parent(1):delFriendClick(node)";
		self("btn2").text = "访问农场";
		self("btn2").onClick = "node:Parent(1):onLookFarmClick(node)";
	end
	self("btn0"):setEnable(true);
	self("btn1"):setEnable(true);
	self("btn2"):setEnable(true);
end

function VGroupMember:getUserRelation( userid )
	if self.friendList[userid] then
		return 1;
	elseif self.enemyList[userid] then
		return 2;
	else
		return 3;
	end
end

--查看农场
function VGroupMember:onLookFarmClick()
	if gMainView then
        gMainView:jumpToOther(self.battleInfo.userid);
    end
end

--设为好友
function VGroupMember:addFriendClick( node )
	local aParam = {};
    aParam.userid = self.battleInfo.userid;
	gReq:MsgReqFriendAdd(self, "BtnClickCallBack", aParam);
	node:setEnable(false);
end

--设为仇敌
function VGroupMember:addEnemyClick( node )
	local aParam = {}
    aParam.userid = self.battleInfo.userid;
    gReq:MsgReqEnemyAdd(self,"BtnClickCallBack",aParam);
    node:setEnable(false);
end

--删除仇敌
function VGroupMember:delEnemyClick( node )
	local aParam = {}
    aParam.userid = self.battleInfo.userid;
    gReq:MsgReqEnemyDel(self,"BtnClickCallBack",aParam);
    node:setEnable(false);
end

--删除好友
function VGroupMember:delFriendClick( node )
	local aParam = {}
    aParam.userids = {self.battleInfo.userid};
    gReq:MsgReqFriendDel(self,"BtnClickCallBack",aParam);
    node:setEnable(false);
end

function VGroupMember:BtnClickCallBack( result )
	self:onPush();
end