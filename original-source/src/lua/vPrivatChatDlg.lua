require "vMessageCell"

VPrivatChatDlg = VClass("PrivatChatDlg", VLayer)

function VPrivatChatDlg:Init(attr)
    VLayer.Init(self, attr);
    self:NeedEvent(Eff_onEnter+Eff_onExit);
    if gWindow.needAction then
        self.pushAction = {{"fadeTo",0,0},{"scaleTo",0,0.2},{"show"},{"scaleTo",0.15,1.2},{"spawn",{"fadeTo",0.1,self.opacity},{"scaleTo",0.1,1.0}}};
        self.popAction = {{"fadeTo",0.1,0},{"scaleTo",0.1,0.8}};
        -- self.stopEventTime = 0.3;
    end
end

function VPrivatChatDlg:onPush()
	self.imgChatBg = self("imgChatBg");
	self.imgChatBg:setScaleX(-1);
	-- self.btnAddFriend = self("btnAddFriend");
	self.txChatTitleT = self("txChatTitleT");
	self.editInput = self("editInput");
	self.tbMessage = self("tbMessage");
	self.tbMessage.delegate = self;
end

function VPrivatChatDlg:onCell(idx, vTable, cell)
	if vTable == self.tbMessage then
		local message = self.messageManager:msgAtIndex(idx+1);
		cell:loadMessage(message);
	end
end

function VPrivatChatDlg:GetMsgSize( info )

	-- if info.sizeS then 
	-- 	cclog("1~~~~~~~~~~~~~")
	-- 	return 780, info.sizeS.height;
	-- end

	-- cclog("2~~~~~~~~~~~~~")

	local msgText = VText{fontSize=18};

	msgText.text = info.context;
	local size = msgText.size;
	-- -- gLog("msgText height = "..size.height..", width = "..size.width);
	local h;

	local lineCont = math.ceil(size.width/450);
	h = (size.height + 10) * (lineCont - 1) + 80;
	w = math.min(450, size.width);
	info.sizeS = cc.size(w,h);

	cclog("3~~~~~~~~~~~~~")
	return 650,h;
end


function VPrivatChatDlg:onCellSize(idx, vTable)
	if vTable == self.tbMessage then
		local message = self.messageManager:msgAtIndex(idx+1);
		cclog("message~~~~~~~~~~~~~")
		return self:GetMsgSize(message)
		-- local cellHeight = message.cellHeight;
		-- if cellHeight then
		-- 	return 800, cellHeight;
		-- else
		-- 	local messageHeight = gSys:stringHeightSystemFont(message.context, 300, 18, 0);
		-- 	if messageHeight > 42 then
		-- 		message.cellHeight = 110+(messageHeight-42);
		-- 	else
		-- 		message.cellHeight = 110;
		-- 	end
		-- 	return 800, message.cellHeight;
		-- end

	end
end

function VPrivatChatDlg:loadByUserid(userid)
	if self.userid == userid then return end;
	self.userid = userid;
	gData:userBriefInfo({userid}, self, "userInfoCallBack");

	-- if gData:isMyFriend(userid) or userid == gGameMasterId then
	-- 	self.btnAddFriend.visible = 0;
	-- else
	-- 	self.btnAddFriend.visible = 1;
	-- end

	self.messageManager = gData.chatInfo:managerWithId(userid);
	if self.messageManager and self.messageManager:messageCount() ~= 0 then
		self.messageManager:clearNewCount();
		self.tbMessage.number = self.messageManager:messageCount();
		self.tbMessage:reloadData();
		self.tbMessage:scrollToCell(self.tbMessage.number);
	else
		self.tbMessage.number = 0;
		self.tbMessage:reloadData();
	end
end

function VPrivatChatDlg:checkNewMessage()
	if not self.messageManager then
		self.messageManager = gData.chatInfo:managerWithId(self.userid);
	end
	if self.messageManager and self.messageManager.newCount ~= 0 then
		self.tbMessage:addCellNum(self.messageManager.newCount);
		self.messageManager:clearNewCount();
	end
end

function VPrivatChatDlg:userInfoCallBack()
	self.biefInfo = gData:briefCache(self.userid);
	if self.biefInfo then
		if self.biefInfo.nick and self.biefInfo.nick ~= "" then
			self.txChatTitleT.text = self.biefInfo.nick;
		else
			self.txChatTitleT.text = self.biefInfo.userid;
		end
	end
end

function VPrivatChatDlg:closeMessageView()
	local imgDOpen = gView()("imgDOpen")

    if imgDOpen then
        imgDOpen.visible = 1
    end
    
	self:doPop();
end

function VPrivatChatDlg:sendMessageAction()
	local context = self.editInput:getText();
	if string.len(context) == 0 then
		return;
	end
	
    if string.len(context) > 105 then
        gWindow:showTip("信息最长35个中文，或者105个英文和数字", 1);
        return;
    end
	
	if self.messageManager then
		self.messageManager:addMessageSelf(context);
	else
		self.messageManager = gData.chatInfo:addMessageSelf(self.userid, context);
	end
	self.tbMessage.refreshType = _VTableViewLeave.Down;
	-- self.tbMessage:reloadData();
	self.editInput:setText("");
	

	gReq:MsgReqMessagePost(self, "messageSendCallBack", self.userid, context, 1);
end

function VPrivatChatDlg:messageSendCallBack(result, rsp, req)
	if result == 0 then
		self.messageManager:saveToFile();
		
        local societyDlg = gView()("societyDlg");
        if societyDlg and societyDlg.visible then
            societyDlg:InitSocietyData()
            societyDlg:ReqSocietyInfo()

            gMainView:checkUnReadMessage()

        end

        if self.messageManager and self.messageManager:messageCount() ~= 0 then
		self.messageManager:clearNewCount();
		self.tbMessage.number = self.messageManager:messageCount();
		self.tbMessage:reloadData();
		self.tbMessage:scrollToCell(self.tbMessage.number);
		else
			self.tbMessage.number = 0;
			self.tbMessage:reloadData();
		end
	else

	end
end

function VPrivatChatDlg:addFriendAction()
	self.btnAddFriend:setEnable(false);
	gData:addFriend(self.userid, self, "addFriendActionCallBack");
end

function VPrivatChatDlg:addFriendActionCallBack(result, rsp, req)
	if result == 0 then
		gWindow:showTip("添加好友成功!");
		self.btnAddFriend.visible = 0;
	else
		self.btnAddFriend:setEnable(true);
	end
end

function VPrivatChatDlg:clearMessageLog()
	if self.messageManager and self.messageManager:messageCount() ~= 0 then
		gWindow:showConfirmTip("是否要清空所有聊天记录?", "确定", "取消", self, "clearMessageLogConfirm");	
	else
		gWindow:showTip("聊天记录已经清空!");
	end
end

function VPrivatChatDlg:clearMessageLogConfirm()
	self.messageManager = nil;
	gData.chatInfo:removeMessageAll(self.userid);
	self.tbMessage.number = 0;
	self.tbMessage:reloadData();
end
