

require "vWorldMessageCell"

VWorldChatDlg = VClass("WorldChatDlg", VLayer)

function VWorldChatDlg:Init(attr)
	VWorldChatDlg.super.Init(self, attr);
	self:NeedEvent(Eff_onEnter);
	self.messageList = {};
end

function VWorldChatDlg:onPush()
	self.editInput = self("editInput");
	self.tbMessage = self("tbMessage");
	self.tbMessage.delegate = self
	self:checkNewMessage();

	local csvData = gData:readCsv("item_common.csv");
    local chatCost = csvData.worldChatCost or 0;
	self.chatCost = chatCost;
--	self.editInput.placeHolder = "发送消息需要消耗"..chatCost.."金币";
	self:startLoopTimer()
end

function VWorldChatDlg:hide()
	self.visible = 0;
	self.editInput.visible = 0;
end

function VWorldChatDlg:show()
	self.visible = 1;
	self.editInput.visible = 1;
end

function VWorldChatDlg:onCell(idx, vTable, cell)
	if vTable == self.tbMessage then
		local message = self.messageList[idx+1];
        cell:loadWorldMessage(message);
	end
end

function VWorldChatDlg:onCellSize(idx, vTable)
	if vTable == self.tbMessage then
		local message = self.messageList[idx+1];
		local cellHeight = message.cellHeight;
		if cellHeight then
			return 380, cellHeight;
		else
            local msg = self:ChageHelpMessage(message.msg)
            local messageHeight = gSys:stringHeightSystemFont(msg, 270, 18, 0);
			if messageHeight > 42 then
				message.cellHeight = 110+(messageHeight-42);
			else
				message.cellHeight = 110;
			end
			return 380, message.cellHeight;
		end
	end
end

function VWorldChatDlg:ChageHelpMessage(message)
    local msg = message
    if string.find(message, "SetHelpMsg") then
        local battleid = "老数据战场id"
        local nick = "老数据战场昵称"
        local userid = "老数据战场id"
        local battleType = 1
        
        local start, endle = string.find(message, "SetHelpMsg")
        local str = string.sub(message, endle + 1, -1)
        start, endle = string.find(str, "~")
        if start then
            battleid = string.sub(str, 1, start - 1)
        end
        
        if endle then
        str = string.sub(str, endle + 1, -1)
        start, endle = string.find(str, "~")
            if start then
                nick = string.sub(str, 1, start - 1)
            end
        end
        
        if endle then
        str = string.sub(str, endle + 1, -1)
        start, endle = string.find(str, "~")
            if start then
                userid = string.sub(str, 1, start - 1)
            end
        end
        
        if endle then
            battleType = string.sub(str, endle + 1, -1)
        end
        
        if tonumber(battleType) == 1 then
            msg = "我在进攻"..nick.."(ID:"..userid..")，点击信息援我，一起抢肥羊。[战场ID："..battleid.."]"
        elseif tonumber(battleType) == 2 then
            msg = "我遭到"..nick.."(ID:"..userid..")的进攻，点击信息援我，一起刷碎片。[战场ID："..battleid.."]"
        end
    end
    
    return msg
end

function VWorldChatDlg:onTableLeave(vTable, leaveType)
	if vTable == self.tbMessage then
		if leaveType == _VTableViewLeave.Up then
			self:checkOldMessage();
		elseif leaveType == _VTableViewLeave.Down then
			self:checkNewMessage();
		end
	end
end

function VWorldChatDlg:startLoopTimer()
--	self:StartTimer("checkNewMessage", 10);
end

function VWorldChatDlg:stopLoopTimer()
--	self:StopTimer("checkNewMessage");
end

function VWorldChatDlg:checkNewMessage()
	if self.isCheckIngNew then
		return;
	end
	if #self.messageList ~= 0 then
		self.isCheckIngNew = true;
		local lastMessage = self.messageList[#self.messageList];
		self:getNextMessage(lastMessage.time, "getNextMessageCallback");
	else
		self:getNextMessage(0, "getNewMessageCallback");
	end
end

function VWorldChatDlg:checkOldMessage()
	if self.isCheckIngOld then
		return;
	end
	if #self.messageList ~= 0 then
		self.isCheckIngOld = true;
		local lastMessage = self.messageList[1];
		self:getPreMessage(lastMessage.time);
	end
end

function VWorldChatDlg:getNewMessage()
	local postTable = {};
	postTable.guildId = 0;
	postTable.userId = gData.userInfo.userid;
	if gServerIndex == 0 then
		postTable.sid = 1;--gZoneid;
	else
		postTable.sid = gZoneid;
	end
	gReq:snsPost("/chat/guild/get", postTable, self, "getNewMessageCallback")
end

function VWorldChatDlg:getPreMessage(time)
	local postTable = {};
	postTable.guildId = 0;
	postTable.userId = gData.userInfo.userid;
	postTable.time = time;
	if gServerIndex == 0 then
		postTable.sid = 1;--gZoneid;
	else
		postTable.sid = gZoneid;
	end
	gReq:snsPost("/chat/guild/pre", postTable, self, "getPreMessageCallback")
end

function VWorldChatDlg:getNextMessage(time, callback)
	local postTable = {};
	postTable.guildId = 0;
	postTable.userId = gData.userInfo.userid;
	postTable.time = time;
	if gServerIndex == 0 then
		postTable.sid = 1;--gZoneid;
	else
		postTable.sid = gZoneid;
	end
	gReq:snsPost("/chat/guild/next", postTable, self, callback)
end

function VWorldChatDlg:getNewMessageCallback(msg)
	local receive = msg:String("content");
	if receive then
		gLog("receive = %s", receive);
		local receiveData = Var();
		receiveData:FromString(receive);
		if receiveData.rs == 0 then
			if not receiveData.content then return end;
			self:loadMessageAll(receiveData.content)
		else
			local errordiscr = receiveData.error;
			gWindow:showTip(errordiscr);
		end
	end
end

function VWorldChatDlg:getNextMessageCallback(msg)
	local receive = msg:String("content");
	if receive then
		gLog("receive = %s", receive);
		local receiveData = Var();
		receiveData:FromString(receive);
		if receiveData.rs == 0 then
			if not receiveData.content then
				self.isCheckIngNew = false;
				return;
			end
			self:loadMessageNext(receiveData.content)
		else
			local errordiscr = receiveData.error;
			gWindow:showTip(errordiscr);
			self.isCheckIngNew = false;
		end
	else
		self.isCheckIngNew = false;
	end
end

function VWorldChatDlg:getPreMessageCallback(msg)
	local receive = msg:String("content");
	if receive then
		gLog("receive = %s", receive);
		local receiveData = Var();
		receiveData:FromString(receive);
		if receiveData.rs == 0 then
			if not receiveData.content then 
				self.isCheckIngOld = false;
				return;
			end
			self:loadMessagePre(receiveData.content)
		else
			self.isCheckIngOld = false;
			local errordiscr = receiveData.error;
			gWindow:showTip(errordiscr);
		end
	else
		self.isCheckIngOld = false;
	end
end

function VWorldChatDlg:loadMessageAll(content)
	self.messageList = {};
	local iter = VDataIter();
	while content:Travel(iter) do
		local message = iter:Data();
		if message.userId then
			table.insert(self.messageList, message);
		end
	end

	local userids = {};
	for i,v in ipairs(self.messageList) do
		table.insert(userids, v.userId);
	end

	gData:userBriefInfo(userids, self, "userBriefInfoCallBackAll")
end

function VWorldChatDlg:addMessage(message)
--    self.messageList = {};
    if message.userId == gData.userInfo.userid then
        return
    end
    
    table.insert(self.messageList, message);
    
    local userids = {};
    for i,v in ipairs(self.messageList) do
        table.insert(userids, v.userId);
    end

    gData:userBriefInfo(userids, self, "userBriefInfoCallBackAll")
end

function VWorldChatDlg:userBriefInfoCallBackAll()
	self.tbMessage.number = #self.messageList;
	self.tbMessage:reloadData();
	self.tbMessage:setPullLabelPos();
	self.tbMessage:scrollToCell(self.tbMessage.number);
	self.isCheckIngNew = false;
end

function VWorldChatDlg:loadMessageNext(content)
	if not content then return end;
	local count = 0;
	local userids = {};
	local iter = VDataIter();
	while content:Travel(iter) do
		local message = iter:Data();
		if message.msg then
			count = count + 1;
			table.insert(self.messageList, message);
			table.insert(userids, message.userId);
		end
	end

	if count > 0 then
		self.loadCount = count;
		gData:userBriefInfo(userids, self, "userBriefInfoCallBackNext")
	else
		self.isCheckIngNew = false;
	end
end

function VWorldChatDlg:userBriefInfoCallBackNext()
	self.tbMessage.refreshType = _VTableViewLeave.Down;
	self.tbMessage:addCellNum(self.loadCount, self.loadCount);
	self.loadCount = 0;
	self.isCheckIngNew = false;
end

function VWorldChatDlg:loadMessagePre(content)
	local count = 0;
	local userids = {};
	for i=content:Count()-1,0,-1 do
		local message = content[i];
		if message.msg then
			count = count + 1;
			table.insert(self.messageList, 1, message);
			table.insert(userids, message.userId);
		end
	end

	if count > 0 then
		self.loadCount = count;
		gData:userBriefInfo(userids, self, "userBriefInfoCallBackPre")
	else
		self.isCheckIngOld = false;
		self.tbMessage:cancelLoading();
	end
end

function VWorldChatDlg:userBriefInfoCallBackPre()
	self.tbMessage:addCellNum(self.loadCount, self.loadCount);
	self.loadCount = 0;
	self.isCheckIngOld = false;
	if self.tbMessage.number > 100 then
		self.tbMessage:cancelLoading();
	end
end

function VWorldChatDlg:sendMessageAction()
	if not gData.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_chat_speak) then
		gWindow:showTip("该功能暂未开放！",1);
		return;
	end

	local money = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeMoney);
    cclog("self.chatCost~~~~~~"..self.chatCost)
	if self.chatCost and money < self.chatCost then
		gWindow:showTip("金币不足!",1);
		return;
	end

	local context = self.editInput:getText();
	if string.len(context) == 0 then
		return;
	end

	self.editInput:setText("");
	
	gReq:MsgReqMessagePost(self, "messageSendCallBack", 0, context, 2);
    
--    gData:SetHelpMsg("求援测试,勿点", "敌方昵称", "角色id", 2)
end 

function VWorldChatDlg:messageSendCallBack(result, rsp, req)
	if result then
		self:checkNewMessage();
	else

	end
end

function VWorldChatDlg:closeMessageView()
    self:stopLoopTimer()
	self:doPop();
end