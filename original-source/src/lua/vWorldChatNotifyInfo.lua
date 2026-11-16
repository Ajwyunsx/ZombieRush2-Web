--vWorldChatNotifyInfo.lua

VWorldChatNotifyInfo = vclass("WorldChatNotifyInfo")

function VWorldChatNotifyInfo:initialize()
	self.notifyArray = {};
end

function VWorldChatNotifyInfo:nextNotify()
	
	if #self.notifyArray == 0 then return nil end;

	local notify = nil;
	
	notify = self.notifyArray[1];
	
	table.remove(self.notifyArray, 1);

	return notify;
end

function VWorldChatNotifyInfo:addNotifyInfo(notify)
	local start, endle = string.find(notify.msg, "SetHelpMsg")

	if start then
		return
	end

	if #self.notifyArray <= 100 then
		table.insert(self.notifyArray, notify);
	else
		table.remove(self.notifyArray, 1);
		table.insert(self.notifyArray, notify);
	end
end