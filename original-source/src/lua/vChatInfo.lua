--vChatInfo.lua

-----------------------------------------------------------
--message info 
-----------------------------------------------------------
VMessage = vclass("Message");

function VMessage:initialize(pbData)
	if pbData then
		self:synWithPbData(pbData);
	end
end

function VMessage:synWithPbData(pbData)
	if type(pbData) ~= "table" then
		return;		
	end

	self.id = pbData.id;
	self.type = pbData.type;
	self.time = pbData.time;
	self.from = pbData.from;
	self.duration = pbData.duration;
	self.context = tostring(pbData.context);
end

function VMessage:loadWithNotify(notify)
	self.id = notify.id;
	self.type = notify.type;
	self.time = notify.start;
	self.from = 0;
	self.duration = notify.duration;
	self.context = tostring(notify.message);
end

function VMessage:expireTime()
	return self.time + self.duration - gData:currentTime();
end

function VMessage:loadWithContext(context)
	self.id = 0;
	self.type = 1;
	self.time = gData:currentTime();
	self.from = gData.userInfo.userid;
	self.duration = 0;
	self.context = tostring(context);
end

function VMessage:convert2VData()
	local dataTable = {};
	dataTable.id = self.id;
	dataTable.type = self.type;
	dataTable.time = self.time;
	dataTable.from = self.from;
	dataTable.duration = self.duration;
	local stringVar = Var();
	local context = tostring(self.context);
	stringVar:SetString(context, string.len(context))
	dataTable.context = stringVar;

	return Var(dataTable);
end


-----------------------------------------------------------
--message manager 
-----------------------------------------------------------
VMessageManager = vclass("MessageManager")

function VMessageManager:initialize(userid)
	self.fromId = userid;
	self.newCount = 0;
	self.msgArray = {};
end

function VMessageManager:sortMessage()
	table.sort(self.msgArray,
			function(a,b)
				return a.time < b.time;
			end);
end

function VMessageManager:clearNewCount()
	self.newCount = 0;
end

function VMessageManager:addMessageNotifier(notify)
	if notify then
		local message = VMessage:new();
		message:loadWithNotify(notify);
		table.insert(self.msgArray, message);
	end
end

function VMessageManager:addMessageSelf(context)
	if context and context ~= "" then
		local message = VMessage:new();
		message:loadWithContext(context);
		table.insert(self.msgArray, message);
	end
end

function VMessageManager:addMessage(msgInfo)
	if msgInfo.from ~= self.fromId then return end;
	local message = VMessage:new(msgInfo);
	local isLive = false
	for i,v in ipairs(self.msgArray) do
        if v.id == msgInfo.id then
			isLive = true
			break
		end
	end

	if not isLive then
		table.insert(self.msgArray, message);
		self.newCount = self.newCount + 1;
		self:sortMessage();
	end
end

function VMessageManager:removeMessage(message)
	for i,v in ipairs(self.msgArray) do
		if v.id == message.id then
			table.remove(self.msgArray, i);
			break;
		end
	end
	self:sortMessage();
end

function VMessageManager:messageCount()
	return #self.msgArray;
end

function VMessageManager:msgAtIndex(index)
	if index > 0 and index <= self:messageCount() then
		return self.msgArray[index];
	end
	return nil;
end

function VMessageManager:newestMessage()
	local message = self:msgAtIndex(self:messageCount());
	if message then
		return message.context;
	end
	return "";
end

function VMessageManager:newestTime()
	local message = self:msgAtIndex(self:messageCount());
	if message then
		return message.time;
	end
	return 0;
end

function VMessageManager:saveToFile()
	local dataTable = {};
	dataTable.fromId = self.fromId;
	dataTable.msgArray = {};

	for i,v in ipairs(self.msgArray) do
		local messageVar = v:convert2VData();
		table.insert(dataTable.msgArray, messageVar);
	end

	local var = Var(dataTable);
	local fileName = addUserPath(tostring(self.fromId)..".msg");
	var:SaveFile(fileName);
end

function VMessageManager:loadFromVar(varData)
	if not varData then return end;

	if not varData.msgArray then return end;
	local iter = VDataIter();
	while varData.msgArray:Travel(iter) do
		local messageVar = iter:Data();
		local message = VMessage:new(messageVar);
		table.insert(self.msgArray, message);
	end
	self:sortMessage();
end

function VMessageManager:isStranger()
	if gData:isMyFriend(self.fromId) then
		return false;
	elseif self.fromId == gGameMasterId then
		return false;
	else
		return true;
	end
end

-----------------------------------------------------------
--chat info 
-----------------------------------------------------------
VChatInfo = vclass("ChatInfo");

function VChatInfo:initialize()
	self.messageList = {};
	self.lastMessageList = {}
	
--	self:LoadLastMessageList()
end

function VChatInfo:LoadLastMessageList(parameters)
    local var = Var();
    local fileName = addUserPath("lastMessageList.msg");

    
    var:FromFile(fileName, false, false, _VPath.Public);
    
    
    if not var then return end;
    
    local iter = VDataIter();
       
    while var:Travel(iter) do
        local messageVar = iter:Data();
        local message = VMessageManager:new(messageVar.fromId);
        message.lastTime = messageVar.lastTime
        self.lastMessageList[messageVar.fromId] = message;
    end
end

function VChatInfo:GetLastMessageList(parameters)
    return self.lastMessageList
end

function VChatInfo:AddLastMessage(msgInfo)
    local messageManager = VMessageManager:new(msgInfo.from);
    messageManager.lastTime = msgInfo.time
    self.lastMessageList[msgInfo.from] = messageManager;
    
    self:SaveLastMessageToFile()
end

function VChatInfo:SaveLastMessageToFile()
    local data = {};
    for key, var in pairs(self.lastMessageList) do
        local message = {}
        message.fromId = var.fromId
        message.lastTime = var.lastTime
        message.newCount = var.newCount
        table.insert(data,Var(message));
    end
    
    if #data > 0 then
        data = Var(data);
        local fileName = addUserPath("lastMessageList.msg");
        data:SaveFile(fileName);
    end
end



function VChatInfo:addMessageNotifier(notify)
	local messageManager = self:managerWithId(0);
	if not messageManager then
		messageManager = VMessageManager:new(0);
		self.messageList[0] = messageManager;
	end
	messageManager:addMessageNotifier(notify);
	self:saveMessageToFile(0);
	return messageManager;
end

function VChatInfo:addMessageSelf(target, context)
	local messageManager = self:managerWithId(target);
	if not messageManager then
		messageManager = VMessageManager:new(target);
		self.messageList[target] = messageManager;
	end
	messageManager:addMessageSelf(context);
	return messageManager;
end

function VChatInfo:addMessage(msgInfo)
	local messageManager = self:managerWithId(msgInfo.from);
	if not messageManager then
		messageManager = VMessageManager:new(msgInfo.from);
		self.messageList[msgInfo.from] = messageManager;
		self.listNew = true
	end
	messageManager:addMessage(msgInfo);
	self:saveMessageToFile(msgInfo.from);
end

function VChatInfo:removeMessage(message)
	local messageManager = self:managerWithId(message.fromId);
	if not messageManager then return end;

	messageManager:removeMessage(message);
	if messageManager:messageCount() == 0 then
		self:removeMessageFromFile(message.fromId);
	else
		self:saveMessageToFile(message.fromId);
	end
end

function VChatInfo:removeMessageAll(userid)
	self.messageList[userid] = nil;
	self:removeMessageFromFile(userid);
end

function VChatInfo:loadMessageFromFile(userid)
	local var = Var();
	local fileName = addUserPath(tostring(userid)..".msg");
	var:FromFile(fileName, false, false, _VPath.Public);
	if var:Count() > 0 then
		local manager = VMessageManager:new(userid);
		manager:loadFromVar(var);
		return manager;
	else
		return nil;
	end
end

function VChatInfo:saveMessageToFile(userid)
	local messageManager = self.messageList[userid];
	if messageManager then
		messageManager:saveToFile();
	end
end

function VChatInfo:removeMessageFromFile(userid)
	local fileName = addUserPath(tostring(userid)..".msg");
	gRes:RemoveFile(fileName);
end

function VChatInfo:managerWithId(userid)
	if not userid then
		return nil
	end
	local messageManager = self.messageList[userid];
	if not messageManager then
		messageManager = self:loadMessageFromFile(userid);
		self.messageList[userid] = messageManager;
	end
	return messageManager;
end

function VChatInfo:strangerList()
	local strangers = {};
	for k,manager in pairs(self.messageList) do
		-- if manager:isStranger() then
			table.insert(strangers, manager)
		-- end
	end

	if #strangers > 0 then
		table.sort(strangers,
			function (a, b)
				return a:newestTime() > b:newestTime();
			end)
		return strangers;
	end

	return nil;
end

function VChatInfo:DelAllMessage(parameters)
    for k,manager in pairs(self.messageList) do
--        if manager:isStranger() then
            self:removeMessageAll(manager.fromId)
--        end
    end
    
    self.lastMessageList = {}
    
    local data = {}
    data = Var(data);
    local fileName = addUserPath("lastMessageList.msg");
    data:SaveFile(fileName);
--    gRes:RemoveFile("lastMessageList.msg");
end

function VChatInfo:unReadCount()
	local unread = 0;
	for k,manager in pairs(self.messageList) do
		unread = unread + manager.newCount;
	end
	return unread;
end
