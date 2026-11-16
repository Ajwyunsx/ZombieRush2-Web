
VChatLayer = VClass("ChatLayer", VMsgBox);

function VChatLayer:onPush(  )
	self.editInput = self("editInput");
	self.tbv = self("tbMessage");
	self.battleid = self.delegate.groupBattleInfo.id;
	self.tbv.delegate = self;
	self.tbv.number = #self.delegate.msgList;
	if self.tbv.number > 0 and not self.delegate.isHistoryEnd then 
		self:GetHistoryMsg();
		return;
	end
	self:ShowLayer();
end

function VChatLayer:onPop(  )
	self.delegate.chatDlg = nil;
end

function VChatLayer:ShowLayer(  )
	self.tbv.number = #self.delegate.msgList;
	self.tbv:reloadData();
	self.tbv:setPullLabelPos();
	self:SetTbvOffset();
end

function VChatLayer:SetTbvOffset(  )
	local maxpos = self.tbv:maxContainerOffset();
	-- local minpos = self.tbv:minContainerOffset();
	local curPos = self.tbv:getContentOffset();
	if curPos.y < 0 then
		self.tbv:setContentOffset(maxpos);
	end
	-- self.tbv:setBounceable(false);
	-- gLog("************** maxpos = %d, %d *****************", maxpos.x, maxpos.y);
	-- gLog("************** curPos = %d, %d *****************", curPos.x, curPos.y);
	-- gLog("************** minpos = %d, %d *****************", minpos.x, minpos.y);
end

function VChatLayer:onTableLeave(t, refreshType)
	
	
	if refreshType == _VTableViewLeave.Up  then
		self:GetHistoryMsg();
	end
end

function VChatLayer:onCell(idx, t, cell)
	idx = idx + 1;
	
	local info = self.delegate.msgList[idx];
	
	if info.from == gData.userInfo.userid then
		cell("imgContextBG").image = "liaotiankuang2.png";
		cell("imgHead").layout = "RightUp";
		cell("imgHead").offset = {-5,5};
		cell("texNick").layout = "RightUp";
		cell("texNick").offset = {-70,5};
		cell("imgContextBG").layout = "DownRight";
		cell("imgContextBG").offset = {-70,0};
		cell("texTime").layout = "LeftOut";
		cell("texTime").offset = {-5,0};
	else
		cell("imgContextBG").image = "liaotiankuang1.png";
		cell("imgHead").layout = "LeftUp";
		cell("imgHead").offset = {5,5};
		cell("texNick").layout = "LeftUp";
		cell("texNick").offset = {70,5};
		cell("imgContextBG").layout = "DownLeft";
		cell("imgContextBG").offset = {70,0};
		cell("texTime").layout = "RightOut";
		cell("texTime").offset = {5,0};
	end


	cell("bgLayer").size = {650, info.size.height};
	cell("imgContextBG").size = {info.size.width+80, info.size.height-30};

	cell("texContext").text = info.context;
	cell("texContext"):setDimensions(info.size.width,info.size.height);

	cell("texTime").text = os.date("%Y-%m-%d %X", info.time);
	if info.from == 0 then
		cell("texNick").text = "系统";
	    cell("imgHead").image = "morentouxiang.png";
	else
		local baseInfo = gData:briefCache(info.from);
		if baseInfo and baseInfo.nick ~= "" then
	        cell("texNick").text = baseInfo.nick;
	        local vipLevel = gData:GetVipLevel(baseInfo.charge);
			cell("imgHead"):setHead(baseInfo.userid, baseInfo.image, nil, vipLevel);
			cell("imgHead"):SetHeadImageShader();
	    else
	        cell("texNick").text = info.from;
	        cell("imgHead").image = "morentouxiang.png";
	    end
	end
end

function VChatLayer:onCellSize(idx, t)
	idx = idx + 1;
	local info = self.delegate.msgList[idx];

	return self:GetMsgSize(info);
end

function VChatLayer:GetMsgSize( info )
	if info.size then 
		return 650, info.size.height;
	end
	local msgText = VText{fontSize=18};

	msgText.text = info.context;
	local size = msgText.size;
	-- -- gLog("msgText height = "..size.height..", width = "..size.width);
	local h;

	local lineCont = math.ceil(size.width/450);
	h = (size.height + 10) * (lineCont - 1) + 80;
	w = math.min(450, size.width);
	info.size = cc.size(w,h);
	return 650,h;
end

--查询历史聊天消息
function VChatLayer:GetHistoryMsg( )
	if self.delegate.isHistoryEnd then
		gWindow:showTip("已经没有历史消息了！");
		return;
	end
	gWindow:showWaitTip("loading...");
	gReq:MsgReqGroupBattleMessageFetch(self, "GetHistoryMsgCallBack", 0, self.battleid);
end

--查询历史聊天消息返回
function VChatLayer:GetHistoryMsgCallBack( result, rsp, req )
	if result == 0 then
		if rsp then
			local iter = VDataIter();
			local count = rsp.infos:Count();
			if count < 20 then
				self.delegate.isHistoryEnd = true;
			end
			local index = #self.delegate.msgList;
			for i=1, index do 
				local v = self.delegate.msgList[i];
				for k=0, count-1 do 
					local info = rsp.infos[k];
					if info.id ~= v.id then
						table.insert(self.delegate.msgList, info);
					end
				end
			end
			
			table.sort(self.delegate.msgList, function(a,b)
				return a.time < b.time;
			end)
			self:ShowLayer();
		else
			self.delegate.isHistoryEnd = true;
		end
	end
	gWindow:closeWaitTip();
end

--发送消息按钮
function VChatLayer:onSendMsgBtnClick(  )
	local msg = self.editInput:getText();
	if not msg or msg == "" then
		gWindow:showTip("请输入消息！", 2);
		return;
	end
	self.editInput.text = "";
	gReq:MsgReqGroupBattleMessagePost(self, "", self.battleid, msg);
end

