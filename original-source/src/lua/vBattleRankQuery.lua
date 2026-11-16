--vBattleRankQuery.lua

-----------------------------------------
VBattleRewardInfo = vclass("BattleRewardInfo")

function VBattleRewardInfo:initialize( csv, index )
	self.index = csv:lineData(index, 0);
	self.resType = csv:lineData(index, 1);
	self.itemid = csv:lineData(index, 2);
	self.itemCount = csv:lineData(index, 3);
	self.itemScore = csv:lineData(index, 4);

	if self.resType == RES_DATA_TYPE.ResDataTypeItem then
		local itemInfo = gData:itemInfo(self.itemid);
		if itemInfo then
			self.name = itemInfo.name;
			self.image = itemInfo.image;
		end
	elseif self.resType == RES_DATA_TYPE.ResDataTypeSuit then
		local suitCsv = gData:readCsv("prop_suit.csv");
		local suitData = suitCsv:lineDataWithKey(self.itemid);
		if suitData then 
			self.name = suitData[1];
			self.image = suitData[12];
		end
	end
end

-----------------------------------------
VBattleRankInfo = vclass("BattleRankInfo")

function VBattleRankInfo:initialize(pbData)
	self.nick = "";
	self.image = "";
	self.level = -1;

	if pbData then
		self:synWithPbData(pbData);
	end
end

function VBattleRankInfo:synWithPbData(pbData)
	self.userid = pbData.userid;
	self.score = pbData.data;
	self.reward = pbData.reward;
end

function VBattleRankInfo:setUserInfo( )
	if self.userid == gData.userInfo.roleInfo.id then
		self.nick = gData.userInfo.roleInfo.nick;
		self.image = gData.userInfo.roleInfo.image;
		self.level = gData:attrValue(AttrType.AttrTypeLevel);
		self.vipLevel = gData.userInfo.roleInfo.vipInfo[0];
	else
		local otherUserInfo = gData:briefCache(self.userid);
		if otherUserInfo then
			self.nick = otherUserInfo.nick;
			self.image = otherUserInfo.image;
			self.level = otherUserInfo.level;
			self.vipLevel = otherUserInfo.vipInfo[0];
		end
	end
end

function VBattleRankInfo:setRankIndex( index )
	self.rankIndex = index;
	self.rewardPoint = 0;
	local pointCsv = gData:readCsv("ranking_point.csv");
	local pointInfo = pointCsv:allData();
	for i,v in ipairs(pointInfo) do
		if self.rankIndex >= v[0] and self.rankIndex <= v[1] then
			self.rewardPoint = v[2];
			return;
		end
	end
end

-----------------------------------------
VBattleRankQuery = vclass("BattleRankQuery")

function VBattleRankQuery:initialize()
	self.pos = -1;
	self.selfRankInfo = VBattleRankInfo:new();
	self.total = 0;
	self.rankInfos = {};
	self.rankIdList = {};
end

function VBattleRankQuery:initRewardInfo( )
	self.rewardInfos = {};

	local rewardsCsv = gData:readCsv("ranking_point_exchange.csv");
	local csvLine = rewardsCsv:lineCount();

	for i=0,csvLine-1 do
		local rewardInfo = VBattleRewardInfo:new(rewardsCsv, i);
		table.insert(self.rewardInfos, rewardInfo);
	end
end

function VBattleRankQuery:synWithPbData(pbData, startIndex)
	self.selfRankInfo:synWithPbData(pbData.self_info);
	self.selfRankInfo:setUserInfo();
	local tempPos = 0;
	if not pbData.self_info.userid or pbData.self_pos == 5000 then
		self.pos = "5000+";
		tempPos = 99999;
	else
		self.pos = pbData.self_pos + 1;
		tempPos = self.pos;
	end
	self.selfRankInfo:setRankIndex(tempPos);
	self.total = self.total + pbData.total;

	if pbData.infos then
		local iter = VDataIter();
		local i = startIndex;
		while pbData.infos:Travel(iter) do
			local data = iter:Data();
			if not self.rankIdList[data.userid] then
				i = i + 1;
				local rankInfo = VBattleRankInfo:new(data);
				rankInfo:setRankIndex(i);
				table.insert(self.rankInfos, rankInfo);
				self.rankIdList[data.userid] = data.userid;
			end
		end
	end
end

function VBattleRankQuery:getNoneUserId( index, count )
	local idList = {};
	for i=index+1,index+count do
		local data = self.rankInfos[i];
		if data then
			if data.level == -1 then
				table.insert(idList, data.userid);
			end
		end
	end
	return idList;
end

function VBattleRankQuery:getSelfReward( )
	self.selfRankInfo.reward = 1;
end