VEventEntryInfo = vclass("EventEntryInfo")

function VEventEntryInfo:initialize()
	self.id = 0; --id
end

function VEventEntryInfo:build(id)
	self.id = id;
	self:loadCsvData();
end

function VEventEntryInfo:loadCsvData()
	if not self.id then  return end
	local csvDatas = gData:readCsv("prop_activity.csv");
	local data = csvDatas:lineDataWithKey(self.id);
	
	if not data then
		 return gLog("activity %d not found in prop_activity.csv", self.id);
	end

	self.image = data.image;
	self.sequence = data.sequence;
	self.url = data.url;
	self.nameImage = data.nameImage;
end

---------------------------VEventEntryManager------------------------------

VEventEntryManager = vclass("EventEntryManager")

function VEventEntryManager:initialize()
	self.showInfos = {};  --显示的活动
	self.startInfos = {}; --开启的活动
	self.rewardInfos = {}; --完成可领奖的活动
end


function VEventEntryManager:update(showInfos, startInfos, rewardInfos)
	self.showInfos = self:convert(showInfos);
	self.startInfos = self:convert(startInfos);
	self.rewardInfos = self:convert(rewardInfos);
end

function VEventEntryManager:convert(tableInfos)
	local infos = {};
	if tableInfos ~= nil then
		if #tableInfos > 0 then
			for i = 1, #tableInfos do
				local info = VEventEntryInfo:new();
				local id = tableInfos[i];
				info:build(id);
				table.insert(infos, info);
			end
		end	
	end
	return infos;
end

function VEventEntryManager:getNoticeCnt()
	local startCnt = #self.startInfos;
	local rewardCnt = #self.rewardInfos;
	if #self.startInfos > 0 then
		for i = 1, #self.startInfos do
			for j = 1, #self.rewardInfos do
				if self.startInfos[i].id == self.rewardInfos[j].id then
					startCnt = startCnt -1;
					break;
				end
			end
		end
	end
	return startCnt, rewardCnt;
end

function VEventEntryManager:getInfos()
	local infoIds = {}; --用来去重
	local infos = {};
	if #self.rewardInfos > 0 then
		self:sortData(self.rewardInfos);
		infos = self:addAll(infoIds, infos, self.rewardInfos);
	end

	if #self.startInfos > 0 then
		self:sortData(self.startInfos);
		infos = self:addAll(infoIds, infos, self.startInfos);
	end

	if #self.showInfos > 0 then
		self:sortData(self.showInfos);
		infos = self:addAll(infoIds, infos, self.showInfos);
	end
	return infos;
end

function VEventEntryManager:getInfo(id)
	if #self.rewardInfos > 0 then
		for i=1, #self.rewardInfos do
			if self.rewardInfos[i].id == id then
				return self.rewardInfos[i];
			end
		end
	end

	if #self.startInfos > 0 then
		for i=1, #self.startInfos do
			if self.startInfos[i].id == id then
				return self.startInfos[i];
			end
		end
	end

	if #self.showInfos > 0 then
		for i=1, #self.showInfos do
			if self.showInfos[i].id == id then
				return self.showInfos[i];
			end
		end
	end
end

--将tableDest中的所有元素合并到tableSrc后面
function VEventEntryManager:addAll(ids, tableSrc, tableDest)
	if not tableDest then return tableSrc end
	for i=1, #tableDest do
		if not ids[tostring(tableDest[i].id)] then
			ids[tostring(tableDest[i].id)] = true;
			table.insert(tableSrc, tableDest[i]);
		end
	end
	return tableSrc;
end

--排序
function VEventEntryManager:sortData(tableInfos)
	if not tableInfos then return end
	table.sort(tableInfos, function(info1, info2)
								return info1.sequence < info2.sequence;
							end
	);
end

function VEventEntryManager:isNew(id)
	local isNew = false;
	for i=1, #self.startInfos do
		if self.startInfos[i].id == id then
			isNew = true;
			break;
		end
	end

	if isNew then
		if gData:isReadEvent(id) then
			isNew = false;
		end
	end
	return isNew;
end

function VEventEntryManager:isFinish(id)
	local isFinish = false;
	for i=1, #self.rewardInfos do
		if self.rewardInfos[i].id == id then
			isFinish = true;
			break;
		end
	end
	return isFinish;
end
