--vQuestInfo.lua
VConditionsInfo = vclass("ConditionsInfo")

function VConditionsInfo:initialize()
	
end

----------------------------------------------------------
----
VQuestInfo = vclass("QuestInfo")
function VQuestInfo:initialize()
	self.id = 0;
	self.conditions = {};
end

function VQuestInfo:synWithPbData(pbData, isFirst, squ)
	local update = false;
	if self.id ~= pbData.bi.id then
		update = true;
	end
	self.id = pbData.bi.id;
    self.userid = pbData.bi.userid;
    self.questid = pbData.bi.questid;
    self.start = pbData.bi.start;
    local showAA = false; 
   	if not isFirst and pbData.bi.state and pbData.bi.state == 2 and self.state ~= 2 then
   		showAA = true;
   	end

    self.state = pbData.bi.state; 


    if update then
		self:loadPropCSVData();
		self:loadRewardsCSVData();
		self:loadConditionsCSVData();
	end

    local infos = pbData.bi.infos;
    if infos then
		local iter = VDataIter();
	    while infos:Travel(iter) do
	    	local ec = iter:Data();
	    	self:updateConditionValueByKey(ec.type, ec.target, ec.value);
	    end
	end
	if showAA and self.questType == 3 then
		local info = {};
		info.image = self.questIcon;
		info.name = self.questName;
		table.insert(squ, info);
	end
end

function VQuestInfo:updateConditionValueByKey(t , target, value)
	for group,condition in pairs(self.conditions) do
		if condition.type == t and condition.target == target then
			condition.value = value;
			return true;
		end
	end
	return false;
end

function VQuestInfo:loadPropCSVData()
	local csv_pq = gData:readCsv("prop_quest.csv");
	local prop_pq = csv_pq:lineDataWithKey(self.questid);
	if not prop_pq then return end;
	self.questName = prop_pq[1];
	self.questExploin = prop_pq[2];
	self.questIcon = prop_pq[3];
	self.questShowType = prop_pq[4];
	self.questType = prop_pq[5];
	self.floorLevel = prop_pq[7];
	self.limitLevel = prop_pq[8];
	self.sortLevel = prop_pq[9];
	self.timeType = prop_pq[11];
	self.valueType = prop_pq[14];
end

function VQuestInfo:loadRewardsCSVData()
	self.rewards = {};
	local csv_qr = gData:readCsv("quest_reward.csv");
	local qr = csv_qr:linesWithRowValue(0,self.questid);
	for i,v in ipairs(qr) do
		local info = {};
		local image,name,quality = gData:getResoureIconByID(v[1], v[2]);
		info.rType = v[1];
		info.rid = v[2];
		info.image = image;
		info.name = name;
		info.quality = quality;
		info.count = v[3];
		info.sortLevel = v[4];
		table.insert(self.rewards, info);
	end
	if next(self.rewards) then
		table.sort(self.rewards,
			function(a,b)
				return a.sortLevel < b.sortLevel;
			end);
	end
end

function VQuestInfo:loadConditionsCSVData()
	local csv_pqc = gData:readCsv("quest_condition.csv");
	local prop_pqc = csv_pqc:linesWithRowValue(0,self.questid);

	for i,v in ipairs(prop_pqc) do
		local group = v[1];
		local condition = VConditionsInfo:new();
		condition.value = 0;
		condition.group = group;
		condition.type = v[2];
		condition.target = v[3];
		condition.aim = v[4];
		condition.explain = v[6];
		-- if not self.conditions[group] then
		-- 	self.conditions[group] = {};
		-- end
		table.insert(self.conditions,condition);
	end
end

function VQuestInfo:getConditionCount()
	return #self.conditions;
end

-------------------------------------------------

VQuestManager = vclass("QuestManager")

function VQuestManager:initialize()
	self.questInfos = {};
end

function VQuestManager:synWithPbData(pbData)
	local infos = pbData.infos;
	local iter = VDataIter();
	local isFirst = true;
	if next(self.questInfos) then 
		isFirst = false;
	end
	local squ = {};
    while infos:Travel(iter) do
    	local exQuest = iter:Data();
    	if exQuest.ctrl.op == _VCtrlOP.None or 
    		exQuest.ctrl.op == _VCtrlOP.Rep or
    		exQuest.ctrl.op == _VCtrlOP.Add then
    		if not self.questInfos[exQuest.info.bi.id] then
    			self.questInfos[exQuest.info.bi.id] = VQuestInfo:new();
    		end
    		self.questInfos[exQuest.info.bi.id]:synWithPbData(exQuest.info, isFirst, squ);
    	elseif exQuest.ctrl.op == _VCtrlOP.Del then
    		self.questInfos[exQuest.info.bi.id] = nil;
    	end
    end
    gWindow:achievementAnimation(squ);
    self:checkQuestEvent();
end

function VQuestManager:checkQuestEvent()
	local dailyQuestEvent = 0;
	local achievementEvent = 0;
	for i,v in pairs(self.questInfos) do
		--每日任务可领奖
		if v.state == 2 then
			--成就达成
			if v.questType == 3 then
				achievementEvent = achievementEvent + 1;
			else
				dailyQuestEvent = dailyQuestEvent + 1;
			end
		end	
	end

	if dailyQuestEvent > 0 then
		gData.noticeManager:cover(NoticeType.quest, dailyQuestEvent, nil, NoticeQuestType.quest_finish);
	else
		local noticeInfo = gData.noticeManager:getByType(NoticeType.quest);
		if noticeInfo and noticeInfo.param == NoticeQuestType.quest_finish then
			gData.noticeManager:clear(NoticeType.quest);
		end
	end

	if achievementEvent > 0 then
		gData.noticeManager:cover(NoticeType.achievement_finish, achievementEvent);
		gLog(string.format("cover achievementEvent = %d", achievementEvent));
	else
		gData.noticeManager:clear(NoticeType.achievement_finish);
		gLog("clear achievementEvent");
	end
end

function VQuestManager:questCount()
	local count = 0;
	for k,v in pairs(self.questInfos) do
		count = count + 1;
	end
	return count;
end