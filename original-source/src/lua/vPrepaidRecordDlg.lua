--vPrepaidRecordDlg.lua

VPrepaidRecordDlg = VClass("PrepaidRecordDlg", VMsgBox);

function VPrepaidRecordDlg:onPush()
	self.start = 0;
	self.logInfo = {};
	self.tbv = self("pr_recordTbv");
	self.tbv.delegate = self;
	self:snsPost();
end

function VPrepaidRecordDlg:snsPost()
	local dataVar = Var();
	dataVar.userId = gData.userInfo.userid;

	local idUint64 = Var();
	idUint64:SetUint64(self.start);
	dataVar.start = idUint64;
	dataVar.count = 10;
	dataVar.sid = gZoneid;
	dataVar.game = 6;
	local dataString = dataVar:ToString();
	local postUrl = gPayUrl.."/charge/orderQuery";
	gNet:Post{url = postUrl, data = dataString, onFinish = function () VCallBack(self, "snsPostCallBack", gLua:Param()); end};
	gWindow:showWaitTip("loading...");
end


function VPrepaidRecordDlg:snsPostCallBack(msg)
	local receive = msg:String("content");
	if not receive or receive == "" then
		gWindow:closeWaitTip();
		return;
	end
	local receiveData = Var();
	gLog(receive);
	receiveData:FromString(receive);
	local userids = {};
	if receiveData.rs == 0 then
		local count = receiveData.logs:Count();
		if count <= 0 then return; end;
		for i=receiveData.logs:Count()-1,0,-1 do
			local info = {};
			local v = receiveData.logs[i];
			info.target_id = v.target_id;
			if not  info.target_id then break; end;
			info.user_id = v.user_id;
			info.amount_game = v.amount_game;
			info.amount_rmb = v.amount_rmb;
			info.channel = v.channel;
			info.notify_time = v.notify_time;
			table.insert(self.logInfo, info);
			table.insert(userids, info.user_id);
		end
		if next(userids) then 
			gData:userBriefInfo(userids, self, "loadUserInfo");
		else
			gWindow:closeWaitTip();
		end
	else
		gWindow:closeWaitTip();
		gWindow:showTip("加载数据出错！",1);
		self:doPop();
	end
end

--查询充值玩家昵称
function VPrepaidRecordDlg:loadUserInfo()
	gWindow:closeWaitTip();
	for i,v in ipairs(self.logInfo) do 
		local info = gData:briefCache(v.user_id);
		v.nick = info.nick;
	end
	self:showList();
end

function VPrepaidRecordDlg:showList()
	self.tbv.number = #self.logInfo;
	self.tbv:reloadData();
end

function VPrepaidRecordDlg:onCell(idx, t, cell)
	local info = self.logInfo[idx+1];
	cell("prc_idText").text = info.user_id;
	if info.user_id == gData.userInfo.userid then
		cell("prc_targetText").text = "自己";
	else
		cell("prc_targetText").text = info.nick.."("..info.target_id..")";	
	end
	cell("prc_vcoinText").text = info.amount_game.."钻石";
	cell("prc_moneyText").text = "充值"..(info.amount_rmb/100).."元";
	cell("prc_timeText").text = os.date("%Y-%m-%d %H:%M:%S", math.modf(info.notify_time/1000));
end