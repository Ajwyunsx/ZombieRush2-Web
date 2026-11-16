--vUserInfo.lua

VUserInfo = vclass("UserInfo")

function VUserInfo:initialize()
	self.inited = false;--是否初始化过，用于保存上次服务器单机关卡数据
    self.farmEntered = false; --是否进过农场
    self.uprootPlanted = false; -- 是否铲除过植物
    self.useBackupTroop = 0; -- 使用过援军次数
	self.isSelf = true;
	self.roleInfo = VRoleInfo:new();
	self.friendInfos = VFriendManager:new();
    self.enemyInfos = VEnemyManager:new()
	self.bagInfos = VBagManager:new();
	self.plantInfos = VPlantManager:new();
	self.manorInfo = VManorInfo:new();
	-- self.suitInfo = VSuitInfos:new();
	self.questInfos = VQuestManager:new();
	-- self.armyTechInfos = VArmyTechInfos:new(true);
	self.battleInfo = VBattleInfo:new();
	self.monsterInfo = VMonsterInfos:new();
	self.dungeonInfo = VDungeonInfo:new()
	self.eventEntryInfos = VEventEntryManager:new();
	self.bannerInfos = VBannerInfoManager:new();
end

--初始化单机游戏数据，首次单机进入游戏使用
function VUserInfo:makeOfflineData()
   	cclog("makeOfflineData");
   	self.farmEntered = false;
   	self.uprootPlanted = false;
   	self.useBackupTroop = 0;
	self.userid = gData.accountInfo.lastRoleId;
	self.roleInfo.nick = gData:randomNick();
	self.roleInfo.image = 0;
	self.roleInfo.sex = 1;
	self.roleInfo.level = 1;
	self.roleInfo.vipInfo = {};
	self.roleInfo.vipInfo[0] = 0; --vip level
	self.manorInfo.extendLevel = 1;--扩地级别
	self.manorInfo.altarInfo:setLevel(1);

	--下面初始化卡牌
	local plantid = 1000;
	local monsterid = 1000;
    local csv_hr = gData:readCsv("item_effect.csv");
    local rowCount = csv_hr:lineCount();

    for row=0,rowCount-1 do
    	local line = csv_hr:lineData(row);
        local id = line[0];
        local tp = line[1];
        local thingid = line[2];
        local ct = line[3];
        if id==30001 then
            if tp==ThingType.ThingTypePlant then--植物
                for i=0,ct-1 do
                    self.plantInfos.plants[plantid] = VPlantInfo:new();
                    self.plantInfos.plants[plantid].id = plantid;
                    self.plantInfos.plants[plantid].thingid = thingid;
                    self.plantInfos.plants[plantid].accelerated_value = 0;
                    self.plantInfos.plants[plantid].strengthenPoint = 0;
                    plantid = plantid + 1;
            	end
            elseif tp==ThingType.ThingTypeArm then--僵尸
                for i=0,ct-1 do
                    self.monsterInfo.monsterInfos[monsterid] = VMonsterInfo:new();
                    self.monsterInfo.monsterInfos[monsterid].id = monsterid;
                    self.monsterInfo.monsterInfos[monsterid].thingid = thingid;
                    self.monsterInfo.monsterInfos[monsterid].reTime = 0;
                    monsterid = monsterid + 1;
                end
            end
        end
    end

    --下面初始化关卡进度
    -- campid={};
    -- campid[1]={};
    -- campid[2]={};
    -- campid[3]={};
    -- campid[1][1]=10101;
    -- campid[1][2]=10201;
    -- campid[1][3]=10301;
    -- campid[2][1]=20101;
    -- campid[2][2]=20201;
    -- campid[2][3]=20301;
    -- campid[3][1]=30101;
    -- campid[3][2]=30201;
    -- campid[3][3]=30301;

    -- self.dungeonInfo.actInfos={};
    -- for i=1,3 do
    -- 	self.dungeonInfo.actInfos[i]={};
    -- 	self.dungeonInfo.actInfos[i].id=i;
    -- 	self.dungeonInfo.actInfos[i].pass=i+1;
    -- 	self.dungeonInfo.actInfos[i].campaignInfo={};
    -- 	for j=1,3 do
    -- 		cid = campid[i][j];
    -- 		self.dungeonInfo.actInfos[i].campaignInfo[cid]={};
    -- 		self.dungeonInfo.actInfos[i].campaignInfo[cid].id=cid;
    -- 		self.dungeonInfo.actInfos[i].campaignInfo[cid].record=j;
    -- 		self.dungeonInfo.actInfos[i].campaignInfo[cid].online_reward=(j % 2 == 0);
    -- 		self.dungeonInfo.actInfos[i].campaignInfo[cid].purchase=j;
    -- 	end
    -- end
    cclog("init end");
end

--读取离线存档
function VUserInfo:loadOfflineData(data)
	self.farmEntered = data.farmEntered and data.farmEntered ~= 0;
	self.uprootPlanted = data.uprootPlanted and data.uprootPlanted ~= 0;	
	self.useBackupTroop = data.useBackupTroop or 0;
	self.userid = data.userid;
	self.roleInfo.nick = data.nick;
	self.roleInfo.image = data.image;
	self.roleInfo.sex = data.sex;
	self.roleInfo.level = data.level;
	self.roleInfo.vipInfo = {};
	self.roleInfo.vipInfo[0] = data.vipLevel; --vip level
	self.manorInfo.extendLevel = data.extendLevel;--扩地级别
	self.manorInfo.altarInfo:setLevel(data.altarLevel);--太阳神庙级别
	if gPackage == 1000 or gPackage == 1020 then
	if data.money then
		self.roleInfo:addAttrValue(AttrType.AttrTypeMoney, -gData:attrValue(AttrType.AttrTypeMoney));
		self.roleInfo:addAttrValue(AttrType.AttrTypeMoney, data.money);
	end;
	if data.sunshine then
		self.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, -gData:attrValue(AttrType.AttrTypeSunshine));
		self.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, data.sunshine);
	end;
	end

	--下面读取卡牌
	if data.plants then
		local countp = data.plants:Count();
		for i=0,countp-1 do
			local v = data.plants[i];
			if v and v.id then
				local plantid = v.id;
		        self.plantInfos.plants[plantid] = VPlantInfo:new();
		        self.plantInfos.plants[plantid].id = v.id;
		        self.plantInfos.plants[plantid].thingid = v.thingid;
		        self.plantInfos.plants[plantid].accelerated_value = 0;
		        self.plantInfos.plants[plantid].strengthenPoint = 0;
	        end;
		end
	end
	if data.monsters then
		local countp = data.monsters:Count();
		for i=0,countp-1 do
			local v = data.monsters[i];
			if v and v.id then
		    	local monsterid = v.id;
		        self.monsterInfo.monsterInfos[monsterid] = VMonsterInfo:new();
		        self.monsterInfo.monsterInfos[monsterid].id = v.id;
		        self.monsterInfo.monsterInfos[monsterid].thingid = v.thingid;
		        self.monsterInfo.monsterInfos[monsterid].reTime = 0;
	        end;
	    end
	end
    --下面读取关卡进度
    self.dungeonInfo:synWithPbData(data.acts);
end

--保存离线数据
function VUserInfo:saveOfflineData()
	local data = {};
	data.farmEntered = self.farmEntered;
	data.uprootPlanted = self.uprootPlanted;
	data.useBackupTroop = self.useBackupTroop;
	data.userid = self.userid;
	data.nick = self.roleInfo.nick;
	data.image = self.roleInfo.image;
	data.sex = self.roleInfo.sex;
	data.level = self.roleInfo.level;
	if gPackage == 1000 or gPackage == 1020 then
	data.money = gData:attrValue(AttrType.AttrTypeMoney);
	data.sunshine = gData:attrValue(AttrType.AttrTypeSunshine);
	end
	if self.roleInfo.vipInfo then
		data.vipLevel = self.roleInfo.vipInfo[0]; --vip level
	else
		data.vipLevel = 0;
	end;
	data.extendLevel = self.manorInfo.extendLevel;--扩地级别
	data.altarLevel = self.manorInfo.altarInfo.level;--太阳神庙级别
	-- data.armCampLevel = self.manorInfo.armCamp.level;--驻兵所级别

	--下面保存卡牌
	data.plants = {};
	for k,v in pairs(self.plantInfos.plants) do
		local plant = {};
		if v and v.id and v.thingid then
			plant.id = v.id;
			plant.thingid = v.thingid;
			table.insert(data.plants,Var(plant));
		end;
	end
	for k,v in pairs(self.manorInfo.farmInfos) do --地里面的植物也保存在plants里面,这样战斗才能带入
		local plant = {};
		if v.plantInfo and v.plantInfo.id and v.plantInfo.thingid then
			plant.id = v.plantInfo.id;
			plant.thingid = v.plantInfo.thingid;
			table.insert(data.plants,Var(plant));
		end;
	end
	data.monsters = {};
	for k,v in pairs(self.monsterInfo.monsterInfos) do
		local monster = {};
		if v and v.id and v.thingid then
			monster.id = v.id;
			monster.thingid = v.thingid;
			table.insert(data.monsters,Var(monster));
		end;
	end
    --下面保存关卡进度
    data.acts = self.dungeonInfo:convert2VData();
    return data;
end

function VUserInfo:synWithPbData(pbData, isHeartBeat, synFlag)
	cclog("VUserInfo:synWithPbData");
	if pbData.ctrl then
		self.version = pbData.ctrl.ver;
	end

	self.userid = pbData.userid;
	
	if pbData.role_info then
		self.roleInfo:synWithPbData(pbData.role_info.info, isHeartBeat);
	end
	if pbData.friend_infos then
		self.friendInfos:synWithPbData(pbData.friend_infos);
	end
	if pbData.enemy_infos then
        self.enemyInfos:synWithPbData(pbData.enemy_infos);
	end
	if pbData.army_tech_infos then
		self.armyTechInfos:synWithPbData(pbData.army_tech_infos);
	end
	
	if pbData.bag_item_infos then
		self.bagInfos:synWithPbData(pbData.bag_item_infos);
	end
	if pbData.plant_infos then
		self.plantInfos:synWithPbData(pbData.plant_infos);
	end
	if pbData.quest_infos then
		self.questInfos:synWithPbData(pbData.quest_infos);
	end
	if pbData.battle_info then
		self.battleInfo:synWithPbData(pbData.battle_info);
	end

	if pbData.monster_infos then
		self.monsterInfo:synWithPbData(pbData.monster_infos);
	end
    if pbData.manor_info then
        self.manorInfo:synWithPbData(pbData.manor_info.info, isHeartBeat, synFlag);
    end
	if pbData.act_infos then
        local act_infos = pbData.act_infos
        if act_infos.ctrl.op == _VCtrlOP.None or 
            act_infos.ctrl.op == _VCtrlOP.Rep or
            act_infos.ctrl.op == _VCtrlOP.Add then
            self.dungeonInfo:synWithPbData(pbData.act_infos.infos);
        elseif act_infos.ctrl.op == _VCtrlOP.Del then
            self.dungeonInfo = VDungeonInfo:new()
        end
	end

	if pbData.banner_infos then
		self.bannerInfos:synWithPbData(pbData.banner_infos);
	end

	if not self.inited then
		self.inited = true;
        gData.offlineData:saveOfflineData();--保存本地离线文件
		gData.offlineData:saveLastServerData(self.dungeonInfo:convert2VData());--保存上次关卡同步数据
		
		--新任务通知
		self:checkNewQuestNotic();
	end
end

function VUserInfo:checkVersion(newVer, heartBeat)
    if (self.version ~= newVer) and (not gData.offlineData:isOffline()) then
		local param = {};
		param.syn_flag = 1;
		param.data_type = GameDataType.DataTypeAll;
		param.isHeartBeat = heartBeat;
		gReq:MsgReqUserDataSyn(self, "userHeartBeatSynCallBack", param);
	end
end

function VUserInfo:userHeartBeatSynCallBack(result, aMsgRspUserDataSyn, req)
	if result == 0 then
		self:checkProtectTime();
	else
	end
end

function VUserInfo:isAttack()
	return self.roleInfo.defendInfo:isAttack();
end

function VUserInfo:checkProtectTime()
	if gMainView then
		gMainView:refreshProtectTime();
	end
end

function VUserInfo:checkNewQuestNotic(  )
	self.lastExitTime = gData:LoadLastExitTime();
	local nextFreshTime = gData:GetNextDayTime();
	local oneDayTime = 60*60*24;
	if nextFreshTime - oneDayTime > self.lastExitTime then
		gData.noticeManager:modify(NoticeType.quest, 1, nil, NoticeQuestType.quest_new);
	end
end

function VUserInfo:checkNewEvent()
	if not self.readEvents then
		self.readEvents = gData:loadReadEvents();
	end

end

function VUserInfo:isBannerFuncOpen()
	local csvDatas = gData:readCsv("banner_common.csv");
    if csvDatas then
        local csvData = csvDatas:lineData(0);
        if csvData and self.manorInfo.baseCampInfo.level < csvData.openLevel then
           return false, csvData.openLevel;
        else
            return true;
        end
    else
    	return true;
    end
end
---------------------------------------------------------------------
VBriefUserInfo = vclass("BriefUserInfo")

function VBriefUserInfo:synWithPbData(pbData)
	if not pbData then return end;
	self.userid = pbData.id or pbData.userid;
	self.image = pbData.image;
	self.nick = pbData.nick;
	self.sex = pbData.sex;
	self.level = pbData.level;
	self.charge = pbData.charge or 0;
	self.last_login_time = pbData.last_login_time or 0;
	self:loadVipData();
end

function VBriefUserInfo:loadVipData()
	local vipCsv = gData:readCsv("user_vip.csv");

	local iter = VDataIter()
    while vipCsv.var:Travel(iter) do
    	local item = iter:Data();
    	if item[1] > self.charge then
    		break;
    	else
    		self.vipInfo = item;
    	end
    end
end

function VBriefUserInfo:loadByUserInfo(userInfo)
	if not userInfo then return end;
	self.userid = userInfo.userid;
	self.image = userInfo.roleInfo.image;
	self.nick = userInfo.roleInfo.nick;
	self.sex = userInfo.roleInfo.sex;
	self.level = userInfo.roleInfo:attrValue(AttrType.AttrTypeLevel);
	self.charge = userInfo.roleInfo:attrValue(AttrType.AttrTypeCharge);
	self.vipInfo = userInfo.roleInfo.vipInfo;
end

function VBriefUserInfo:convert2VData()
	local dataTable = {};
	dataTable.userid = self.userid;
	dataTable.image = self.image;
	dataTable.nick = self.nick;
	dataTable.sex = self.sex;
	dataTable.level = self.level;
	dataTable.charge = self.charge;
	
	return Var(dataTable);
end

----------------------------------------------------------------------
VOtherUserInfo = vclass("OtherUserInfo")

function VOtherUserInfo:initialize()
	self.roleInfo = VRoleInfo:new();
	self.plantInfos = VPlantManager:new();
	self.manorInfo = VManorInfo:new();
	self.monsterInfo = VMonsterInfos:new();
end

function VOtherUserInfo:synWithPbData(pbData)
	if not pbData then return end;

	if pbData.ui then
		self.roleInfo:synWithOtherPbData(pbData.ui);
		self.userid = self.roleInfo.id;
	end

	if pbData.pi then
		self.plantInfos:synWithOtherPbData(pbData.pi);
	end

	if pbData.techs then
		self.armyTechInfos:synWithOtherPbData(pbData.techs);
	end

	if pbData.mi then
		self.manorInfo:synWithPbData(pbData.mi);
	end
end

function VOtherUserInfo:initUserInfo( pbData )
	if not pbData then return; end

	if pbData.ui then
		self.roleInfo:synWithOtherPbData(pbData.ui);
		self.userid = self.roleInfo.id;
	end
end

