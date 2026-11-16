-----------------------------------------------------------------------------
----------------------角色战争信息
VRoleBattleInfo = vclass("RoleBattleInfo");

function VRoleBattleInfo:initialize()
	self.assistInfo = {};	--进行中的战斗
	self.finishInfo = {};	--已结束的战斗
	self.newAssistInfo = {}; --新开启的团战
	self.newFinishInfo = {};	--新结束的团战
	self.groupBattleCache = {};
end

function VRoleBattleInfo:synWithPbData(pbData)
	self:ClearNewAssistInfo();
	self.assistInfo = {};
	local iter = VDataIter();
	if pbData.battle_infos then
		while pbData.battle_infos:Travel(iter) do
			local data = iter:Data();
			local ratis = VRoleBattleAssistInfo:new();
			ratis:synWithPbData(data);
			if ratis.aType == 2 then
				gData.userInfo.roleInfo.roleBattleInfo:AddNewAssistInfo(self.battleid);
			end
			table.insert(self.assistInfo, ratis);
		end
	end

	self.finishInfo = {};
	iter = VDataIter();
	if pbData.finished_infos then
		while pbData.finished_infos:Travel(iter) do
			local data = iter:Data();
			local rgbis = VGroupBattleFinishInfo:new();
			rgbis:synWithPbData(data);
			table.insert(self.finishInfo, rgbis);
		end
	end
end

--同步正在进行中的团战
function VRoleBattleInfo:synWithAssistInfo(pbData)
	local ratis = VRoleBattleAssistInfo:new();
	ratis:synWithPbData(pbData);
	table.insert(self.assistInfo, ratis);
end

--获取所有团战ID
function VRoleBattleInfo:getAllGroupBattleInfo()
	local info = {};
	for i,v in ipairs(self.finishInfo) do
		table.insert(info, 1, v);
	end
	for i,v in ipairs(self.assistInfo) do
		table.insert(info, 1, v);
	end
	return info;
end

--获取战斗信息
function VRoleBattleInfo:GetRoleBattleAssistInfoById( id )
	for i,v in ipairs(self.assistInfo) do
		if v.battleid and v.battleid == id then
			return v;
		end
	end
end

--查询单次团战信息
function VRoleBattleInfo:getGroupBattleInfoById(delegate, callBack, battleId)

	--如果缓存有数据，返回缓存数据
	if self.groupBattleCache[battleId] then
		VCallBack(delegate, callBack, self.groupBattleCache[battleId]);
		return;
	end
	local param = {};
	param.delegate = delegate;
	param.callBack = callBack;
	gReq:MsgReqGroupBattleInfoQuery(self, "GroupBattleInfoQueryCallBack", battleId, param);
end

function VRoleBattleInfo:GroupBattleInfoQueryCallBack( result, rsp, req )
	if result == 0 then 
		local info = rsp.info;
		local rgbi = VRichGroupBattleInfo:new();
		rgbi:synWithPbData(info);

		if rgbi.result ~= 0 then
			self.groupBattleCache[info.id] = rgbi;
		end

		VCallBack(req.param.delegate, req.param.callBack, rgbi);
	end
end

--添加新开启的团战
function VRoleBattleInfo:AddNewAssistInfo( id )
	table.insert(self.newAssistInfo, id);
	gData.noticeManager:modify(NoticeType.battle_begin,1);
	gLog("************************ AddNewAssistInfo modify");
end

--添加新结束的团战
function VRoleBattleInfo:AddNewFinishInfo( id )
	table.insert(self.newFinishInfo, id);
	gLog("************************ AddNewFinishInfo 1");
	gData.noticeManager:modify(NoticeType.battle_end,1);
end

--清空新开启的团战信息
function VRoleBattleInfo:ClearNewAssistInfo(  )
	self.newAssistInfo = {};
	gData.noticeManager:clear(NoticeType.battle_begin);
	gLog("************************ ClearNewAssistInfo clear");
end

--清空新结束的团战
function VRoleBattleInfo:ClearNewFinishInfo(  )
	self.newFinishInfo = {};
	gData.noticeManager:clear(NoticeType.battle_end);
end

--获取正在进行的团战中，进攻和防御团战的数量
function VRoleBattleInfo:GetAssistCount(  )
	local aCount, dCount = 0,0;
	for i,v in ipairs(self.assistInfo) do
		if v.aType == 1 or v.aType == 3 then
			aCount = aCount + 1;
		else
			dCount = dCount + 1;
		end
	end
	return aCount,dCount;
end
-----------------------------------------------------------------------------
------------------------我的战场信息
VSelfGroupBattleInfo = vclass("SelfGroupBattleInfo");

function VSelfGroupBattleInfo:initialize( )
	self.battleid = 0;	--战场ID

	self.attacker = 0;	--攻击者
	self.defender = 0;	--防御者
	self.faction = 0;	--阵营，1：进攻，2：防守
	self.result = 0;	--1:攻击方胜利 2：防守方胜利 0：未结束
	self.maxEndTime = 0; --超时结束时间
	self.attackTargets = 0;

	self.attack_total = 0;	--进攻前存活
	self.attack_current = 0;	--当前存活数
	self.defend_total = 0;	
	self.defend_current = 0;
	self.reward = VReturnInfo:new(); 	--自己的回报
end

function VSelfGroupBattleInfo:synWithPbData(pbData)
	self.battleid = pbData.id;	--战场ID

	self.attacker = pbData.attacker;	--攻击者
	self.defender = pbData.defender;	--防御者
	self.faction = pbData.self_role;	--阵营
	self.result = pbData.result or 0;	--1:攻击方胜利 2：防守方胜利 0：未结束
	self.maxEndTime = pbData.max_end_time or 0;
	self.attack_total = pbData.attack_total or 0;	--进攻前存活
	self.attack_current = pbData.attack_current or 0;	--当前存活数
	self.defend_total = pbData.defend_total or 0;	
	self.defend_current = pbData.defend_current or 0;
	self.attackTargets = pbData.attack_targets or 0;
	if pbData.reward then
		self.reward:synWithPbData(pbData.reward);
	end
end

--设置协助目标
function VSelfGroupBattleInfo:SetAssistTarget(  )
	if self.faction == 1 then
		self.assistTarget = self.attacker;
	else
		self.assistTarget = self.defender;
	end
end

-----------------------------------------------------------------------------
------------------------进行中的战斗信息
VRoleBattleAssistInfo = vclass("RoleBattleAssistInfo");

function VRoleBattleAssistInfo:initialize(pbData)
	self.aType = 0;	--1：主攻 2：主守 3:协助进攻 4：协助防守
	self.userid = 0; 	--玩家ID
	self.target = 0;	--对手id
	self.battleid = 0;	--团战id（1v1时为0）
	self.assistTime = 0; --增援到期时间 非团战为战斗超时时间 团战自己数据同步下的此字段时间为0
	self.assistTarget = 0; --协助目标id
	if pbData then
		self:synWithPbData(pbData);
	end
end

function VRoleBattleAssistInfo:synWithPbData( pbData )
	self.aType = pbData.type;
	self.target = pbData.target;
	self.battleid = pbData.groupid or 0;
	self.assistTime = pbData.assist_time;
end

--设置目标ID, 协助目标id
function VRoleBattleAssistInfo:SetAssistTarget( userid, assistTarget )
	self.userid = userid;
	self.assistTarget = assistTarget;
	if self.aType == 1 then
		self.attacker = self.userid;
		self.defender = self.target;
	elseif aType == 2 then
		self.attacker = self.target;
		self.defender =	self.userid;
	end
end

--设置攻击方和防御方
--VSelfGroupBattleInfo selfGroupBattleInfo
function VRoleBattleAssistInfo:SetSelfAssistTarget( selfGroupBattleInfo)
	self.attacker = selfGroupBattleInfo.attacker;
	self.defender =	selfGroupBattleInfo.defender;
	if self.aType == 1 or self.aType == 3 then
		self.assistTarget = self.attacker;
	else
        self.assistTarget = self.defender;
	end
end

-----------------------------------------------------------------------------
------------------------已经结束的团战信息
VGroupBattleFinishInfo = vclass("GroupBattleFinishInfo");

function VGroupBattleFinishInfo:initialize(pbData)
	self.battleid = 0;
	self.finishTime = 0;	--结束时间
	self.isGetReward = false;	--是否已经领奖
	if pbData then
		self:synWithPbData(pbData);
	end
end
function VGroupBattleFinishInfo:synWithPbData(pbData)
	self.battleid = pbData.battleid;
	self.finishTime = pbData.time;
	self.isGetReward = pbData.reward;
end


-----------------------------------------------------------------------------
------------------团战信息
VRichGroupBattleInfo = vclass("RichGroupBattleInfo");

function VRichGroupBattleInfo:initialize()
	--查询richgroupbattleinfo只返回本阵营最新一条
	self.id = 0; --64位唯一ID
	self.assistTime = 0;	--可增援时间
	self.closeCountdown = 0; --结束倒计时，可增援时间+结束倒计时=结束时刻
	self.attackerId = 0;	--主攻击id
	self.defenderId = 0;	--主防御id
	self.result = 0;		--1:攻击方胜利 2：防守方胜利 0：未结束
	self.faction = 0;		--1:攻击方，2:防御方，3:协助攻击，4:协助防御，0:未加入
	self.isDead = false;		--自己是否阵亡
	self.defendRecord = 0;	--防守方战绩
	self.attackRecord = 0;	--攻击方战绩
	self.attackMembers = {}; 	--进攻成员列表
	self.defendMembers = {};	--防御成员列表

	self.attackingInfos = {};	--进行中的战斗
	self.attackedInfos = {};	--结束的战斗
	
	self.attackChannel = 0;	--进攻方聊天信息 
	self.defendChannel = 0;	--防守方聊天信息 

	self.fightTimeCsv = CreateCsvCacheByCsvNameAndKeys("prop_battle.csv",0,1,9);
end

function VRichGroupBattleInfo:synWithPbData( pbData )
	self.id = pbData.id;

	self.assistTime = pbData.base_info.assist_time or 0;
	self.closeCountdown = pbData.base_info.close_countdown or 0;
	self.attackerId = pbData.base_info.attacker;
	self.defenderId = pbData.base_info.defender;
	self.result = pbData.base_info.result or 0;

	self.attackingInfos = {};	--进行中的战斗
	-- message BriefAttackInfo {
	-- 	optional uint32 attacker = 10;
	-- 	optional uint32 defender = 20;
	-- 	optional uint32 time = 30;	//发起时间
	-- 	optional uint32 victor = 40;	// 胜利者
	-- 	optional uint64 logid = 50;
	--  optional uint32 attacker_dead = 60;	//攻方死亡数量
	--  optional uint32 defender_dead = 70;
	-- }
	iter = VDataIter();
	if pbData.attacking_infos then
		while pbData.attacking_infos:Travel(iter) do
			local data = iter:Data();
			table.insert(self.attackingInfos, data);
		end
	end

	iter = VDataIter();
	self.attackedInfos = {};	--结束的战斗
	if pbData.attacked_infos then
		while pbData.attacked_infos:Travel(iter) do
			local data = iter:Data();
			table.insert(self.attackedInfos, data);
		end
	end

	self.attackMembers = {}; 	--进攻成员列表

	local count = pbData.attack_members:Count();
	local userid = gData.userInfo.userid;
	for i=0, count-1 do
		local data = pbData.attack_members[i];
		local gmInfo = VGroupMemberInfo:new();
		gmInfo:synWithPbData(data);
		gmInfo.index = i + 1;
		self.attackRecord = self.attackRecord + gmInfo.score;
		if gmInfo.userid == userid then
			self.isDead = gmInfo.isDead;
		end
		table.insert(self.attackMembers, gmInfo);
	end
	
	self.defendMembers = {};	--防御成员列表
	count = pbData.defend_members:Count();
	for i=0, count-1 do
		local data = pbData.defend_members[i];
		local gmInfo = VGroupMemberInfo:new();
		gmInfo:synWithPbData(data);
		self.defendRecord = self.defendRecord + gmInfo.score;
		gmInfo.index = i + 1;
		if gmInfo.userid == userid then
			self.isDead = gmInfo.isDead;
		end
		table.insert(self.defendMembers, gmInfo);
	end

	--将团战成员排序
	self:SortMembers();
	--聊天信息
	-- message MessageInfo {
	-- 	optional uint64 id = 10;			// 记录id
	-- 	optional uint32 type = 20;			// 类型
	-- 	optional uint32 time = 30;			// 时间
	-- 	optional uint32 from = 40;			// 来自
	-- 	optional uint32 duration = 50;		// 持续时间
	-- 	optional string context = 60;		// 内容
	-- }
	self.attackChannel = {};	--进攻方聊天信息 
	if pbData.attack_channel then
		local iter = VDataIter();
		while pbData.attack_channel:Travel(iter) do
			local data = iter:Data();
			table.insert(self.attackChannel, data);
		end
	end
	table.sort(self.attackChannel, function(a,b)
		return a.time > b.time;
	end)

	self.defendChannel = {};	--防守方聊天信息 
	if pbData.defend_channel then
		local iter = VDataIter();
		while pbData.defend_channel:Travel(iter) do
			local data = iter:Data();
			table.insert(self.defendChannel, data);
		end
	end
	table.sort(self.defendChannel, function(a,b)
		return a.time > b.time;
	end)

	--初始化阵营
	self.faction = self:GetSelfFaction();
end

--将团战成员排序
function VRichGroupBattleInfo:SortMembers()
	local func2 = function(a,b)
		if a.isDead and b.isDead then
			return a.userid < b.userid;
		elseif a.isDead then
			return false;
		else
			return true;
		end;
	end
	local func = function(t)
		local count = #t;
		for k=1,count do 
			for i=1,count-k do 
				if not func2(t[i], t[i+1]) then
					local n = t[i+1];
					t[i+1] = t[i];
					t[i] = n;
				end
			end
		end
	end
	func(self.attackMembers);
	func(self.defendMembers);

	for i,v in ipairs(self.attackingInfos) do
		for ii,vv in ipairs(self.attackMembers) do
			if vv.userid == v.attacker then
				local info = self.attackMembers[ii];
				info.isFighting = true;
				table.remove(self.attackMembers, ii);
				table.insert(self.attackMembers, 1, info);
			end
		end
		for iii,vvv in ipairs(self.defendMembers) do
			if vvv.userid == v.defender then
				local info = self.defendMembers[iii];
				info.isFighting = true;
				local key = "5"..(#info.roads)..info.extendLevel;
				local endTime = self.fightTimeCsv[key][2] or 0;
				info.fightEndTime = endTime + v.time - gData:currentTime();
				table.remove(self.defendMembers, iii);
				table.insert(self.defendMembers, 1, info);
			end
		end
	end
end

--获取自己的战功
function VRichGroupBattleInfo:GetSelfScore(  )
	local userid = gData.userInfo.userid;
	local score = 0;
	for i,v in ipairs(self.attackMembers) do
		if v.userid == userid then
			score = v.score;
			break;
		end
	end

	for i,v in ipairs(self.defendMembers) do
		if v.userid == userid then
			score = v.score;
			break;
		end
	end

	if self.faction == 1 or self.faction == 3 then
		return math.modf(score*(self.defendRecord/(self.attackRecord+1))*(self.defendRecord/(self.defendRecord+self.attackRecord+1)));
	elseif self.faction == 2 or self.faction == 4 then
		return math.modf(score*(self.attackRecord/(self.defendRecord+1))*(self.defendRecord/(self.defendRecord+self.attackRecord+1)));
	end
	return 0;
end

--获取团战成员的战功
function VRichGroupBattleInfo:GetGroupMemberScore( score, faction )
	if faction == 1 or faction == 3 then
		return math.modf(score*(self.defendRecord/(self.attackRecord+1))*(self.defendRecord/(self.defendRecord+self.attackRecord+1)));
	elseif faction == 2 or faction == 4 then
		return math.modf(score*(self.attackRecord/(self.defendRecord+1))*(self.defendRecord/(self.defendRecord+self.attackRecord+1)));
	end
	return 0;
end

--设置自己的阵营
function VRichGroupBattleInfo:GetSelfFaction()
	local userid = gData.userInfo.userid;
	if userid == self.attackerId then
		return 1;
	end
	if userid == self.defenderId then
		return 2;
	end
	for i,v in ipairs(self.attackMembers) do
		if v.userid == userid then
			return 3;
		end
	end
	for i,v in ipairs(self.defendMembers) do
		if v.userid == userid then
			return 4;
		end
	end
	return 0;
end

-- 获取Mvp
function VRichGroupBattleInfo:GetMvpId()
	local max = 0;
	local mvp = 0;
	for i,v in ipairs(self.defendMembers) do 
		if max < v.win then
			max = v.win;
			mvp = v.userid;
		end
	end
	for i,v in ipairs(self.attackMembers) do
		if max < v.win then
			max = v.win;
			mvp = v.userid;
		end
	end
	return mvp;
end

-----------------------------------------------------------------------------
------------------团战成员信息
VGroupMemberInfo = vclass("GroupMemberInfo"); 

function VGroupMemberInfo:initialize()
	self.userid = 0;
	self.score = 0;
	self.win = 0;	--累计胜场
	self.breaks = 0;	--突破道路
	self.combat = 0;		--战力值
	self.isDead = false; 	--当前是否阵亡
	self.plants = {};		--当前植物信息列表	只有防守方有
	self.totalPlantsCount = 0;	--初始植物总量	 
	self.roads = {};			--int32 场地宽度
	self.extendLevel = 0; 
	self.money = 0;				--当前可掠夺值（主防才有）
	self.sunshine = 0;	
	self.index = 0;				--编号
	self.fightEndTime = 0;
	self.rewardInfo = VReturnInfo:new();	--团战战利品
end

function VGroupMemberInfo:synWithPbData( pbData )
	self.userid = pbData.userid;
	self.score = pbData.score or 0;
	self.win = pbData.win or 0;
	self.isDead = pbData.dead;
	self.totalPlantsCount = pbData.total_plants or 0;
	self.money = pbData.money or 0;
	self.sunshine = pbData.sunshine or 0;
	self.breaks = pbData.breaks or 0;
	self.extendLevel = pbData.extend_level or 0;
	self.combat = pbData.combat or 0;
	local iter = VDataIter();
	if pbData.road then
		while pbData.road:Travel(iter) do
			local data = iter:Data();
			table.insert(self.roads, data);
		end
	end

	if pbData.reward then
		self.rewardInfo:synWithPbData(pbData.reward);
	end

	local iter = VDataIter();
	if pbData.plants then
		while pbData.plants:Travel(iter) do
			local data = iter:Data();
			local plant = VBattleCreature:new();
			plant:synWithPlantPbData(data);
			table.insert(self.plants, plant);
		end
	end
end


-----------------------------------------------------------------------------
------------------用户回报信息
VReturnInfo = vclass("ReturnInfo");

function VReturnInfo:initialize()
	self.userid = 0;
	self.returnThingInfo = {}; 	--物品信息
	self.returnAttrInfo = {};	--资源信息
end

function VReturnInfo:synWithPbData(pbData)
	self.userid = pbData.userid;
	local iter = VDataIter();
	if pbData.rtis then
		while pbData.rtis:Travel(iter) do
	    	local data = iter:Data();
	    	local item = VReturnThingInfo:new(data);
			table.insert(self.returnThingInfo, item);
	    end
	end
	iter = VDataIter();
	if pbData.rais then
		while pbData.rais:Travel(iter) do
	    	local data = iter:Data();
	    	local item = VReturnAttrInfo:new(data);
	    	table.insert(self.returnAttrInfo, item);
	    end
	end
end

function VReturnInfo:GetReWardItems()
	local items = {};
	for i,v in ipairs(self.returnAttrInfo) do 
		local info = v:GetReWardItem();
		if info then
			table.insert(items, info);
		end
	end
	for i,v in ipairs(self.returnThingInfo) do 
		local info = v:GetReWardItem();
		if info then
			table.insert(items, info);
		end
	end
	return items;
end

-----------------------------------------------------------------------------
VReturnAttrInfo = vclass("ReturnAttrInfo");
function VReturnAttrInfo:initialize(pbData)
	if pbData then
		self.type = pbData.type;
		self.value = pbData.value;
	else
		self.type = 0;
		self.value = 0;
	end
end

function VReturnAttrInfo:GetReWardItem()
	if self.value > 0 then
		local item = {};
		item.image,item.name = gData:getResoureIconByID(RES_DATA_TYPE.ResDataTypeAttr, self.type);
		item.count = self.value;
		return item;
	end
end

VReturnThingInfo = vclass("ReturnThingInfo");
function VReturnThingInfo:initialize(pbData)
	if pbData then
		self.type = pbData.type;
		self.guid = pbData.guid;
		self.thingid = pbData.thingid;
		self.count = pbData.count;
		self.param0 = pbData.param0;
		self.param1 = pbData.param1;
	else
		self.type = 0;
		self.guid = 0;
		self.thingid = 0;
		self.count = 0;
		self.param0 = 0;
		self.param1 = 0;
	end
end

function VReturnThingInfo:GetReWardItem()
	if self.count > 0 then
		local item = {};
		item.image,item.name = gData:getResoureIconByID(self.type, self.thingid);
		item.count = self.count;
		return item;
	end
end
-----------------------------------------------------------------------------
----------------------推荐肥羊列表
VRecommendTargetInfo = vclass("RecommendTargetInfo");

function VRecommendTargetInfo:initialize()
	self.refreshTime = 0;	--刷新时间
	self.targets = {};		--肥羊userid数组
end


function VRecommendTargetInfo:synWithPbData(pbData)
	self.refreshTime = pbData.refresh_time;
	self.targets = {};

	local targetsData = pbData.targets;
	if targetsData then
		local iter = VDataIter();
		while(targetsData:Travel(iter)) do
			local tid = iter:Data();
			table.insert(self.targets, tid);
		end
	end
end

-----------------------------------------------------------------------------
--------------------------角色进攻记录
VAttackedInfo = vclass("AttackedInfo");

function VAttackedInfo:initialize()
	self.target = 0;	--目标userid
	self.time = 0;		--战斗结束时间
end

function VAttackedInfo:synWithPbData(pbData)
	self.target = pbData.target;
	self.time = pbData.time;
end

--目标进攻CD时间
function VAttackedInfo:GetAttackedCoolDownTime()
	local curTime = gData:currentTime();
	return (self.time - curTime);
end


-----------------------------------------------------------------------------
--------------------------角色战斗信息
VBriefUserBattleInfo = vclass("BriefUserBattleInfo");

function VBriefUserBattleInfo:initialize(  )
	self.userid = 0;          	--用户id
	self.image = 0;	      	--个人头像
	self.nick = 0;        	--昵称
	self.sex = 0;			--性别(1 : 女 2 : 男)
	self.level = 0;			--等级
	self.charge = 0;		--vip积分
	self.money = 0;			--可掠夺金币
	self.sunshine = 0;		--可掠夺阳光
	self.battle_infos = {};	--当前战斗增援信息列表
end

function VBriefUserBattleInfo:synWithPbData( pbData )
	self.userid = pbData.id;  
	self.image = pbData.image;
	self.nick = pbData.nick;
	self.sex = pbData.sex;
	self.level = pbData.level;
	self.charge = pbData.charge;
	self.money = pbData.money;
	self.sunshine = pbData.sunshine;
	self.battle_infos = {};	--当前战斗增援信息
	if pbData.battle_infos then
		local iter = VDataIter();
		while pbData.battle_infos:Travel(iter) do
			local data = iter:Data();
			local ratis = VRoleBattleAssistInfo:new();
			ratis:synWithPbData(data);
			table.insert(self.battle_infos, ratis);
		end
	end
end

--是否在防守
function VBriefUserBattleInfo:IsDefendBattle(  )
	for i,v in ipairs(self.battle_infos) do
		if v.aType == 2 then 
			return true;
		end
	end
	return false;
end

--是否可增援防守
function VBriefUserBattleInfo:IsFighting()
	for i,v in ipairs(self.battle_infos) do
		local time = v.assistTime - gData:currentTime();
		if v.aType == 2 and time > 0 and v.target ~= gData.userInfo.userid then 
			return v.battleid;
		end
	end
end