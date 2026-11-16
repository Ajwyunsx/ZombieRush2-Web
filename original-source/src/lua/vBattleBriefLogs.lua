--vBattleBriefLogs.lua

_VLogType = VEnum{
	attack = 1,
	defend = 2,
	all = 3,
	[1] = "attack",
	[2] = "defend",
	[3] = "all",
}

VBattleBriefLogs = vclass("BattleBriefLogs")

function VBattleBriefLogs:initialize()
	self.attackBriefLog = {};
	self.defendBriefLog = {};
	self.allBriefLog = {};
	-- self:loadLogFromFile(_VLogType.attack);
	self:loadLogFromFile(_VLogType.all);
end

function VBattleBriefLogs:opLogArray(logType)
	local logArray = {};
	if logType == _VLogType.attack then

	elseif logType == _VLogType.defend then
		for i,v in ipairs(self.allBriefLog) do 
			if v.defender.userid == gData.userInfo.userid then
				table.insert(logArray, v);
			end
		end
	elseif logType == _VLogType.all then
		logArray = self.allBriefLog
	end
	return logArray;
end

function VBattleBriefLogs:setAllNewLogOff(logType)
	for i,logInfo in ipairs(self:opLogArray(logType)) do
		logInfo.isNew = false;
	end
end

function VBattleBriefLogs:newNumbers(logType)
	local newNumber = 0;
	for i,logInfo in ipairs(self:opLogArray(logType)) do
		if logInfo.isNew then
			newNumber = newNumber+1;
		end
	end
	return newNumber;
end

function VBattleBriefLogs:newestId(logType)
	local newestLog	= self:opLogArray(logType)[1];
	if newestLog then
		return newestLog.id;
	end
	return "0";
end

function VBattleBriefLogs:lastId(logType)
	if ( #self:opLogArray(logType) == 0 ) then
		return "0";
	end
	local lastLog = self:opLogArray(logType)[#self:opLogArray(logType)];
	if lastLog then
		return lastLog.id;
	end
	return "0";
end

function VBattleBriefLogs:addLogs(pbData, logType, lastLogId, checkNew)
	if not pbData then return end;
	cclog("addLogs");
	local newId = self:newestId(logType);
	local iter = VDataIter();
	while pbData:Travel(iter) do
		local item = iter:Data();
		if not checkNew or (checkNew and item.id > newId) then
			local log = VBriefBattleLogInfo:new(item);
			if self:ChecklogLive(logType, log.id) then
    			if lastLogId and log.id > lastLogId then
                    log.isNew = true;
    			end
    			table.insert(self:opLogArray(logType), log);
			end
		end
	end
	self:sortMessage(logType);
	self:saveToFile(logType);
end

function VBattleBriefLogs:ChecklogLive(logType, id)
    local loglist = self:opLogArray(logType)
    local ret = true
    for key, var in ipairs(loglist) do
    	if var.id == id then
    	    ret = false
    	end
    end
    
    return ret
end

function VBattleBriefLogs:sortMessage(logType)
	table.sort(self:opLogArray(logType),
				function(a,b)
					return a.time > b.time;
				end);
end

function VBattleBriefLogs:saveToFile(logType)
	local dataTable = {};
	for i,v in ipairs(self:opLogArray(logType)) do
		local logVar = v:convert2VData();
		table.insert(dataTable, logVar);
	end

	local var = Var(dataTable);
	local fileName = addUserPath(_VLogType[logType].."Battlebrief.log");
	var:SaveFile(fileName);
end

function VBattleBriefLogs:loadLogFromFile(logType)
	local var = Var();
	local fileName = addUserPath(_VLogType[logType].."Battlebrief.log");
	var:FromFile(fileName, false, false, _VPath.Public);
	if var:Count() > 0 then
		self:loadFromVar(var, logType);
	end
end

function VBattleBriefLogs:loadFromVar(varData, logType)
	if not varData then return end;
	local needSave = false;
	local iter = VDataIter();
	while varData:Travel(iter) do
		local logVar = iter:Data();
		if logVar then
			local log = VBriefBattleLogInfo:new();
			log:loadFromVar(logVar);
			table.insert(self:opLogArray(logType), log);
		end
	end
	self:sortMessage(logType);
end