--vSysNotifyInfo.lua

VSysNotifyInfo = vclass("SysNotifyInfo")

function VSysNotifyInfo:initialize()
	self.notifyArray = {};
	self.currentIndex = 0;
	self:loadNotifyFromFile();
end

function VSysNotifyInfo:nextNotify()
	if #self.notifyArray == 0 then return nil end;

	self.currentIndex = self.currentIndex + 1;
	if self.currentIndex > #self.notifyArray then
		self.currentIndex = 1;
	end

	local notify = nil;
	local needSave = false;
	while #self.notifyArray > 0 do
		notify = self.notifyArray[self.currentIndex];
		if notify:expireTime() <= 0 then
			table.remove(self.notifyArray, self.currentIndex);
			needSave = true;
			if self.currentIndex > #self.notifyArray then
				self.currentIndex = 1;
			end
		else
			break;
		end
	end

	if needSave then
		self:saveToFile();
	end
	
	return notify;
end

function VSysNotifyInfo:clearAllNotify()
	self.notifyArray = {}
	self:saveToFile();
end

function VSysNotifyInfo:addNotifyInfo(notify)
	local message = VMessage:new();
	message:loadWithNotify(notify);
	for i,v in ipairs(self.notifyArray) do
		if v.id == message.id then
			table.remove(self.notifyArray, i);
			break;
		end
	end
	if message:expireTime() > 0 then
		table.insert(self.notifyArray, message);
	end
	self:sortMessage();
	self:saveToFile();
end

function VSysNotifyInfo:sortMessage()
	table.sort(self.notifyArray,
			function(a,b)
				return a.time < b.time;
			end);
end

function VSysNotifyInfo:saveToFile()
	local dataTable = {};

	for i,v in ipairs(self.notifyArray) do
		local messageVar = v:convert2VData();
		table.insert(dataTable, messageVar);
	end

	local var = Var(dataTable);
	local fileName = addUserPath("notify.msg");
	var:SaveFile(fileName);
end

function VSysNotifyInfo:loadNotifyFromFile()
	local var = Var();
	local fileName = addUserPath("notify.msg");
	var:FromFile(fileName, false, false, _VPath.Public);
	if var:Count() > 0 then
		self:loadFromVar(var);
	end
end

function VSysNotifyInfo:loadFromVar(varData)
	if not varData then return end;

	self.notifyArray = {};
	local needSave = false;
	local iter = VDataIter();
	while varData:Travel(iter) do
		local messageVar = iter:Data();
		local message = VMessage:new(messageVar);
		if message:expireTime() > 0 then
			table.insert(self.notifyArray, message);
		else
			needSave = true;
		end
	end
	self:sortMessage();
	if needSave then
		self:saveToFile();
	end
end