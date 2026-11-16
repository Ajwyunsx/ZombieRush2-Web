--vRoleInfo.lua

VRoleAttrInfo = vclass("RoleAttrInfo")

function VRoleAttrInfo:initialize(type, value)
	self.id = type;
	self.value = value;
end

function VRoleAttrInfo:synWithPbData(pbData)
	self.id = pbData.id;
	self.value = pbData.value;
	if self.id == AttrType.AttrTypeExp then
		gLog("role attr syn exp = %d", self.value);
	elseif self.id == AttrType.AttrTypeLevel then
		gLog("role attr syn level = %d", self.value);
	end
end

-----------------------------------------
VRoleInfo = vclass("RoleInfo")

function VRoleInfo:initialize()
	self.noAttrTypes = {};
	self.attrInfos = {};
	self.dayInfo = {};
	self.attrInfos = {};
	self.roleShopInfo = VRoleShopInfo:new();
	self.monthInfo = {};
	self.attackedInfos = {};
	self.statusInfos = {};
	self.dayInfo.attacked_userids = {}
	self.signData = {};
	self.funcOpenData = {};
	self.stopHeartBeatHandle = {};
	self.wheel_info = {}
	self.dungeonInfo = VDungeonInfo:new()
	self.recommendTargetInfo = VRecommendTargetInfo:new();
	self.roleBattleInfo = VRoleBattleInfo:new();
	self.activeBanner = VBannerInfo:new();
end

function VRoleInfo:loadLevelCSV(notSelf)
	local currentLevel = self:attrValue(AttrType.AttrTypeLevel);
	local propUser = gData:readCsv("prop_user.csv");
	local propUserCsv = propUser:lineDataWithKey(currentLevel);
	if propUserCsv then
		self.expNeed = propUserCsv[1];
		self.robCost = propUserCsv[2];
	else
		self.expNeed = 1;
		self.robCost = 0;
	end
	
	if not notSelf then
		self:loadFuncOpenData();
		gEvent:pushEvent(EventId.user_levelup);
	end
	cclog("角色信息发生变化")
 -- gData:RunTrainning()
end

function VRoleInfo:synWithPbData(pbData, isHeartBeat)
	if not pbData then return end;
	self.id = pbData.id;
	-- if pbData.part1 then
	-- 	self.questVersion = pbData.part1.quest_version;
	-- 	self.lastLoginTime = pbData.part1.last_login_time;
	-- 	self.accountId = pbData.part1.accountid;
	-- 	self.itemCount = pbData.part1.item_count;
	-- 	self.lastOnlineTime = pbData.part1.last_online_time;
	-- 	self.extend = pbData.part1.extend;
	-- end

	if pbData.part3 then
		self.image = pbData.part3.image;
		self.nick = pbData.part3.nick or "";
		self.regTime = pbData.part3.reg_time;
		self.sex = pbData.part3.sex or 1;					--性别(1 : 女 2 : 男)
		self.npcType = pbData.part3.npc_type;
		self.nickChange = pbData.part3.nick_change or 0;
		
        if not gTrain or not self.initTrain then
            self.training = pbData.part3.training or 0
            self.initTrain = true
        end
        
        self.plant_single_wheel_time = pbData.part3.plant_single_wheel_time or 0
        self.monster_wheel_time = pbData.part3.monster_wheel_time or 0
        self.monster_wheel_times = pbData.part3.monster_wheel_times or 0
        
        self:checkPlantLotteryEvent();
        self:checkMonsterLotteryEvent();

--		if pbData.part3.bag_size_info then
--			self.bagSize = pbData.part3.bag_size_info;
--		end
		if pbData.part3.day_info then
			self.dayInfo.day = pbData.part3.day_info.day;
			self.dayInfo.quest = pbData.part3.day_info.quest;
			self.dayInfo.online_time = pbData.part3.day_info.online_time;
			self.dayInfo.charge = pbData.part3.day_info.charge;
			self.dayInfo.box_times = pbData.part3.day_info.box_times;
			self.dayInfo.currency_cost = pbData.part3.day_info.currency_cost;

			self.dayInfo.checkin_status = pbData.part3.day_info.checkin_status;
			if self.dayInfo.checkin_status == 0 then
				gData.noticeManager:cover(NoticeType.check_in, 1);
			end

            self.dayInfo.shop_refresh_times = pbData.part3.day_info.shop_refresh_times or 0;
            self.dayInfo.accelerate_produce_times = pbData.part3.day_info.accelerate_produce_times or 0
            self.dayInfo.attacked_userids = {}
			if pbData.part3.day_info.attacked_userids then
                local iter = VDataIter();
                while pbData.part3.day_info.attacked_userids:Travel(iter) do
                    local attacked = iter:Data();
                    self.dayInfo.attacked_userids[attacked] = true
                end
			end

			self:checkShopRefreshTimeEvent();
		end

		if pbData.part3.wheel_info then
			self.wheel_info.plant_primary_wheel_time = pbData.part3.wheel_info.plant_primary_wheel_time
			self.wheel_info.plant_secondary_wheel_time = pbData.part3.wheel_info.plant_secondary_wheel_time
			self.wheel_info.monster_primary_wheel_time = pbData.part3.wheel_info.monster_primary_wheel_time
			self.wheel_info.monster_secondary_wheel_time = pbData.part3.wheel_info.monster_secondary_wheel_time
			self:SetDrawCardNotice()
		else
		    self:SetDrawCardNotice()
		end

		if pbData.part3.attacked_infos then
			self.attackedInfos = {};
			local iter = VDataIter();
		    while pbData.part3.attacked_infos:Travel(iter) do
		    	local pbData = iter:Data();
		    	local ai = VAttackedInfo:new();
		    	ai:synWithPbData(pbData);
		    	self.attackedInfos[pbData.target] = ai;
		    end
		end

		if pbData.part3.attr_infos then
			local iter = VDataIter();
		    while pbData.part3.attr_infos:Travel(iter) do
		    	local attrInfo = iter:Data();
		    	--如果是心跳返回，就不处理指定的某一些属性。
		    	if not isHeartBeat or (isHeartBeat and not self.noAttrTypes[attrInfo.id]) then
		    		local oldAttr = self.attrInfos[attrInfo.id];
			    	if not oldAttr then
			    		oldAttr = VRoleAttrInfo:new();
			    		self.attrInfos[attrInfo.id] = oldAttr;
			    	end
			    	oldAttr:synWithPbData(attrInfo);
		    	end
		    end
		    if gMainView then
				gMainView:refreshUserMoney();
				gMainView:refreshUserInfo();
			end
		end

		local currLevel = self:attrValue(AttrType.AttrTypeLevel);
		if self.level ~= currLevel then
			self.level = currLevel;
			self:loadLevelCSV();
		end

		if pbData.part3.status_infos then
			local iter = VDataIter();
		    while pbData.part3.status_infos:Travel(iter) do
		    	local statusInfo = VStatusInfo:new();
		    	statusInfo:synWithPbData(iter:Data());
		    	self.statusInfos[statusInfo.id] = statusInfo;
		    end
		else
			self.statusInfos = {};
		end

		if pbData.part3.shop_info then
			self.roleShopInfo:synWithPbData(pbData.part3.shop_info);
		end

		
--        self.dungeonInfo = VDungeonInfo:new()
        

		if pbData.part3.month_info then
			self.monthInfo.checkin_times = pbData.part3.month_info.checkin_times;
			self.monthInfo.month = pbData.part3.month_info.month;
		end

		if pbData.part3.recommend_info then
			self.recommendTargetInfo:synWithPbData(pbData.part3.recommend_info);
		end

		if pbData.part3.battle_info then
			self.roleBattleInfo:synWithPbData(pbData.part3.battle_info);
		end

		if not next(self.signData) then 
			self:loadSignData();
		end
		
		if pbData.part3.active_banner then
			self.activeBanner:update(pbData.part3.active_banner);
			 if gMainView then
			 	gMainView:setBannerImage();
			 end
		end
		self:loadVipData();
	end
end

function VRoleInfo:UpDataTraining(trainid)
    self.training = trainid;
    self:loadFuncOpenData();
end

function VRoleInfo:DelAttacked(userid)
	self.dayInfo.attacked_userids[userid] = nil
end

function VRoleInfo:UpDataAccelerateProduceTimes()
    self.dayInfo.accelerate_produce_times = self.dayInfo.accelerate_produce_times + 1
end

function VRoleInfo:UpDataShopRefreshTimes(shop_refresh_times)
    self.dayInfo.shop_refresh_times = shop_refresh_times
end

function VRoleInfo:UpDataStartTime()
	self.bagSize.start_time = gData:currentTime()
end

function VRoleInfo:UpDataActInfo(actInfo)
	if not actInfo then return end;
	self.actInfo = {};
	self.actInfo.id = actInfo.id;
	local vipRewards = {}
	if actInfo.vip_rewards then
		local iter = VDataIter();
	    while actInfo.vip_rewards:Travel(iter) do
	    	local id = iter:Data();
	    	table.insert(vipRewards, id);
	    end
	end
	self.actInfo.vip_rewards = vipRewards;
end

function VRoleInfo:UpDataNick(nick)
    self.nick = nick;
end

function VRoleInfo:UpDataSex(sex)
    self.sex = sex;             --性别(1 : 女 2 : 男)
end

function VRoleInfo:UpDataImage(image)
    self.image = image;
end

function VRoleInfo:UpDataDesc(desc)
    self.desc = desc;
end

function VRoleInfo:UpDataNickChange()
    self.nickChange = self.nickChange + 1
end

function VRoleInfo:UpDataDescplantSingleWheelTime(plant_single_wheel_time)
    self.plant_single_wheel_time = plant_single_wheel_time
end

function VRoleInfo:UpDataDescplantPrimaryWheelTime(plant_primary_wheel_time)
    self.wheel_info.plant_primary_wheel_time = plant_primary_wheel_time
end

function VRoleInfo:UpDataDescplantSecondaryWheelTime(plant_secondary_wheel_time)
    self.wheel_info.plant_secondary_wheel_time = plant_secondary_wheel_time
end

function VRoleInfo:UpDataDescmonsterPrimaryWheelTime(monster_primary_wheel_time)
    self.wheel_info.monster_primary_wheel_time = monster_primary_wheel_time
end

function VRoleInfo:UpDataDescmonsterSecondaryWheelTime(monster_secondary_wheel_time)
    self.wheel_info.monster_secondary_wheel_time = monster_secondary_wheel_time
end

function VRoleInfo:synWithOtherPbData(pbData)
	if not pbData then return end;
	
	self.id = pbData.id;
	self.image = pbData.image or "";
	self.sex = pbData.sex or 1;				--性别(1 : 女 2 : 男)
	self.nick = pbData.nick or "";
	self.desc = pbData.desc or "";
	self.lastOnlineTime = pbData.last_online_time;

	if pbData.infos then
		self.attrInfos = {};
		local iter = VDataIter();
	    while pbData.infos:Travel(iter) do
	    	local attrInfo = VRoleAttrInfo:new();
	    	attrInfo:synWithPbData(iter:Data());
	    	self.attrInfos[attrInfo.id] = attrInfo;
	    end 
	end

	local currLevel = self:attrValue(AttrType.AttrTypeLevel);
	if self.level ~= currLevel then
		self.level = currLevel;
		self:loadLevelCSV(true);
	end

	if pbData.status_infos then
		local iter = VDataIter();
	    while pbData.status_infos:Travel(iter) do
	    	local statusInfo = VStatusInfo:new();
	    	statusInfo:synWithPbData(iter:Data());
	    	self.statusInfos[statusInfo.id] = statusInfo;
	    end
	end

	if pbData.active_banner then
			self.activeBanner:update(pbData.active_banner);
	end

	self:loadVipData(false);
end

--差量同步某一个类型的数据的开关
function VRoleInfo:noHeartBeatSyn(type, enable)
	self.noAttrTypes[type] = enable;
end

--停止差量同步某一个类型的数据, time秒后打开开关
function VRoleInfo:stopHeartBeatSynTimer(type, time)
	gLog("stopHeartBeatSynTimer = %d", type);
	self:noHeartBeatSyn(type, true);
	local handle = self.stopHeartBeatHandle[type];
	if handle then
		gDtr:getScheduler():unscheduleScriptEntry(handle)
		self.stopHeartBeatHandle[type] = nil;
	end
	self.stopHeartBeatHandle[type] = gDtr:getScheduler():scheduleScriptFunc( 
		function () VCallBack(gData.userInfo.roleInfo, "stopHeartBeatSynCallBack", type); end, time, false);
end

function VRoleInfo:stopHeartBeatSynCallBack(type)
	if self.stopHeartBeatHandle[type] then
		gDtr:getScheduler():unscheduleScriptEntry(self.stopHeartBeatHandle[type])
        self.stopHeartBeatHandle[type] = nil;
	end
	self:noHeartBeatSyn(type, false);
end

function VRoleInfo:attrValue(type)
	local attrInfo = self.attrInfos[type];
	if attrInfo then
		return attrInfo.value;
	end
	return 0;
end

function VRoleInfo:addAttrValue(attrType, value)
	local attrInfo = self.attrInfos[attrType];
	if attrInfo then 
		attrInfo.value = attrInfo.value + value;
		if attrInfo.value <= 0 then 
			self.attrInfos[attrType] = nil;
		end
	else
		if value > 0 then
			attrInfo = VRoleAttrInfo:new(attrType, value);
			self.attrInfos[attrInfo.id] = attrInfo;
		end
	end

	if attrType == AttrType.AttrTypeExp then
		gLog("add exp %d", value);
		self:checkExpFull();
	elseif attrType == AttrType.AttrTypeLevel then
		local level = self:attrValue(AttrType.AttrTypeLevel);
		if level ~= self.level then
			gLog("add level %d", level);
			self.level = level
			self:loadLevelCSV();
		end
	end

	if gMainView then
		gMainView:refreshUserMoney();
		gMainView:refreshUserInfo();
	end
end

function VRoleInfo:checkExpFull()
	local currentExp = self:attrValue(AttrType.AttrTypeExp);
	local expNeed = self.expNeed;
	if currentExp >= expNeed then
		currentExp = currentExp - expNeed;

		local expInfo = self.attrInfos[AttrType.AttrTypeExp];
		expInfo.value = currentExp;

		local levelInfo = self.attrInfos[AttrType.AttrTypeLevel];
		levelInfo.value = levelInfo.value + 1;

		self.level = levelInfo.value;
		self:loadLevelCSV();
	end
end

function VRoleInfo:loadVipData(notSelf)
	local vipScore = self:attrValue(AttrType.AttrTypeCharge);
	local vipCsv = gData:readCsv("user_vip.csv");

	local iter = VDataIter()
    while vipCsv.var:Travel(iter) do
    	local item = iter:Data();
    	if item[1] > vipScore then
    		break;
    	else
    		
    		self.vipInfo = item;
    	end
    end
    if not notSelf and gMainView then


			gData:UpDataMainInterFaceWithVipChage()
		

		gMainView:refreshUserInfo();
	end
end

function VRoleInfo:protectTime()
	local statusInfo = self.statusInfos[ROLE_STATUS.RoleStatusVipBless];
	if statusInfo and statusInfo:passTime() > 0 then
		return statusInfo:passTime();
	end

	statusInfo = self.statusInfos[ROLE_STATUS.RoleStatusFail];
	if statusInfo and statusInfo:passTime() > 0 then
		return statusInfo:passTime();
	end

	statusInfo = self.statusInfos[ROLE_STATUS.RoleStatusProtect];
	if statusInfo and statusInfo:passTime() > 0 then
		return statusInfo:passTime();
	end

	return 0;
end



function VRoleInfo:loadFuncOpenData()
	local csv = gData:readCsv("user_function.csv");
	local level = self:attrValue(AttrType.AttrTypeLevel);
	local trainId = self.training or 0;
	local data = csv:allData();
	local openFuncEvent = nil;
	for i,v in ipairs(data) do
		local open;
		if v[1] < level then
			open = true;
		else
			if v[1] <= level and v[2] <= trainId then
				open = true;
			else
				open = false;
			end
		end
		if not self.funcOpenData[v[0]] and open then
			openFuncEvent = true;
		end
		self.funcOpenData[v[0]] = open;
	end
	if openFuncEvent then
		gEvent:pushEvent(EventId.openFunc_on);
	end
end

--判断游戏功能是否开放
function VRoleInfo:isFunctionOpen(funcid)
	return true;
	-- return self.funcOpenData[funcid];
end


--加载签到信息
function VRoleInfo:loadSignData(  )
	local limitTime = self.monthInfo.month;
	local time = limitTime - 86400;
	local month = tonumber(os.date("%m",time));
	local csv_si = gData:readCsv("check_in.csv");
	local si_lines = csv_si:linesWithRowValue(0,month);
	for i,v in ipairs(si_lines) do 
		self.signData[i] = {};
		local itemType = v[2];
		local itemid = v[3];
		self.signData[i].count = v[4];
		self.signData[i].muliple = v[5];
		self.signData[i].rType = itemType;
		self.signData[i].rid = itemid;
		local image,name,quality = gData:getResoureIconByID(itemType,itemid);
		self.signData[i].image = image;
		self.signData[i].name = name;
		self.signData[i].patchCost = v[6];
	end
end

--检测商店的免费刷新
function VRoleInfo:checkShopRefreshTimeEvent()
	if self.dayInfo.shop_refresh_times == 0 then
		gEvent:pushEvent(EventId.shop_refresh_on);
	else
		gEvent:pushEvent(EventId.shop_refresh_off);
	end
end

--检测植物的免费抽奖
function VRoleInfo:checkPlantLotteryEvent()
	local updataTime = self.plant_single_wheel_time or 0;
	if gData:currentTime() >= updataTime then
		gEvent:pushEvent(EventId.plant_lottery_on);
	else
		gEvent:pushEvent(EventId.plant_lottery_off);
	end
end

--检测怪物的免费抽奖
function VRoleInfo:checkMonsterLotteryEvent()
	local updataTime = self.monster_wheel_time or 0;
	if gData:currentTime() >= updataTime then
		gEvent:pushEvent(EventId.monster_lottery_on);
	else
		gEvent:pushEvent(EventId.monster_lottery_off);
	end
end

function VRoleInfo:SetDrawCardNotice()
    local count = 0
    if (self.wheel_info.plant_primary_wheel_time or 0) <= gData:currentTime() then
        count = count + 1
	end
    if (self.wheel_info.plant_secondary_wheel_time or 0) <= gData:currentTime() then
        count = count + 1
    end
    if (self.wheel_info.monster_primary_wheel_time or 0) <= gData:currentTime() then
        count = count + 1
    end
    if (self.wheel_info.monster_secondary_wheel_time or 0) <= gData:currentTime() then
        count = count + 1
    end
	
    gData.noticeManager:cover(NoticeType.free_draw_card, count)
end

--是否有激活的战旗
function VRoleInfo:hasActiveBanner()
	if not self.activeBanner or self.activeBanner.id == "0" then
		return false;
	else
		return true;
	end
end


function VRoleInfo:updateActive(pbData)
	if not self.activeBanner then
		self.activeBanner = VBannerInfo:new();
	end
	self.activeBanner:update(pbData);
end

--有激活的banner则返回，没有返回nil
function VRoleInfo:getActiveBanner()
	if self.activeBanner and self.activeBanner.id ~= "0" then
		return self.activeBanner;
	end
	return nil;
end

function VRoleInfo:getBannerImageInMainView()
	if self.activeBanner and self.activeBanner.id ~= "0" then
		return self.activeBanner:getImage();
	else
		return "wu.png";
	end
end