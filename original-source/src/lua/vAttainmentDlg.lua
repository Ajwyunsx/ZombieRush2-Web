VAttainmentDlg = VClass("AttainmentDlg", VMsgBox);

function VAttainmentDlg:onPush()
	self.questType = 3;
 	self.tbv = self("att_tbv");
 	self.tbv.delegate = self;
 	self("titliText").image = "chengjiuwenzi.png";
 	self.questData = {};
 	--同步任务数据
end

function VAttainmentDlg:onPushFinish()
	self:synchronize();
 	gWindow:showWaitTip("loading...");
end

function VAttainmentDlg:onPop(  )
	for i,v in ipairs(self.questData) do
		v.unfold = nil;
	end
end

function VAttainmentDlg:onClick(  )
end

--同步任务数据
function VAttainmentDlg:synchronize(  )
	local param = {};
    param.syn_flag = 1;
    param.data_type = GameDataType.DataTypeQuest;
    gReq:MsgReqUserDataSyn(self, "synchronizeRespone", param);
end

--初始化数据
function VAttainmentDlg:InitData()
	self.questData = {};
	for i,v in pairs(gData.userInfo.questInfos.questInfos) do
		if v.questType == self.questType  then
			table.insert(self.questData,v);
		end
	end
	if next(self.questData) then
		table.sort(self.questData,
			function(a,b)
				if a.state == 2 then
					if b.state == 2 then
						return a.sortLevel < b.sortLevel;
					else
						return true;
					end
				elseif b.state == 2 then
						return false;
				elseif a.state == 3 then
					if b.state == 3 then
						return a.sortLevel < b.sortLevel;
					else
						return false;
					end
				elseif b.state == 3 then
					return true;
				else
					return a.sortLevel < b.sortLevel;
				end
			end);
	end
end

--显示界面
function VAttainmentDlg:showDlg(  )
	self:InitData();
 	self.tbv.number = #self.questData;
 	self.tbv:reloadData();
end


function VAttainmentDlg:onCell(idx, t, cell)
	--任务名称
	local info = self.questData[idx+1];
	cell("qc_nameText").text = info.questName;
	cell("qc_questImage").image = info.questIcon;

	--任务角标
	if info.state == 2 then
		cell("qc_jiaobiaoImage").visible = 1;
		cell("qc_jiaobiaoImage").image = "wancheng.png";
	else
		cell("qc_jiaobiaoImage").visible = 0;
	end

	--任务描述
	cell("qc_questExploinText").text = info.questExploin;

	--任务按钮状态
	if info.state == 2 then
		cell("qc_finishBtn").visible = 1;
		cell("rewardedImg").visible = 0;
		cell("qc_finishBtn"):setEnable(true);
		cell("qc_finishBtn").onClick = "node:Parent(6):onFinishQuestClick("..idx..")";
	elseif info.state == 1 then
		cell("qc_finishBtn").visible = 1;
		cell("rewardedImg").visible = 0;
		cell("qc_finishBtn"):setEnable(false);
	elseif info.state == 3 then
		cell("rewardedImg").visible = 1;
		cell("qc_finishBtn").visible = 0;
	end

	--扩展选项
	if info.unfold then 
		--任务奖励
		self:UpdateRewards(cell, info);
		-- --任务进度
		self:UpdateConditions(cell, info);
	else
		cell("extendImg").visible = 0;
		cell("bgLayer").size = {650,90};
	end

	--列表项点击
	cell("headLayer").onClick = "node:Parent(5):onItemClick("..idx..")";
end

function VAttainmentDlg:onCellSize(idx, table)
	local info = self.questData[idx+1];

	local count = info:getConditionCount();
	if info.unfold then
		local height = count * 25 + 200;

		return	650, height;
	end

	return 650,90;
end

--更新任务进度
function VAttainmentDlg:UpdateConditions(cell, info)
--扩展栏大小
	local count = info:getConditionCount();
	local height = count * 25 + 200;

	cell("bgLayer").size = {650,height};

	cell("extendImg").size = {583,(count*25+110)};

	--任务条件栏大小
	cell("conditionBg").size = {500,25*count+25};

	--任务进度
	for i=1, 20 do 
		local conditionData = info.conditions[i];
		local conditionLayer = cell("condition"..i);
		if conditionData then 
			local textColor = {116,63,21};
			if conditionData.value >= conditionData.aim then
				textColor = {5,101,1};
			end
			if conditionLayer then
				conditionLayer("curValue").text = conditionData.value;
				conditionLayer("curValue").color = textColor;
				conditionLayer("targetValue").text = "/"..conditionData.aim;
				conditionLayer("contditionExploin").text = conditionData.explain;
			else
				if i == 1 then
					conditionLayer = VLayer{name=("condition"..i),size={500,25},layout="UpLeft",offset={0,25}};
				else
					conditionLayer = VLayer{name=("condition"..i),size={500,25},layout="DownOut",relative=("condition"..(i-1))};
				end
				local curValue = VText{name="curValue",text=conditionData.value,color=textColor,fontSize=15,layout="Left"};
				local targetValue = VText{name="targetValue",text=(" / "..conditionData.aim),color={5,101,1},fontSize=15,layout="RightOut", relative="curValue"};
				local exploin = VText{name="contditionExploin", text=conditionData.explain, color={116,63,21}, fontSize=15,layout="RightOut",relative="targetValue",offset={10,0}};
				conditionLayer:Push(curValue);
				conditionLayer:Push(targetValue);
				conditionLayer:Push(exploin);
				cell("conditionBg"):Push(conditionLayer);
			end
		else
			if conditionLayer then
				conditionLayer:doPop();
			else
				break;
			end
		end
	end
	cell("extendImg").visible = 1;
end

--更新任务奖励
function VAttainmentDlg:UpdateRewards( cell, info )
	for i=1,2 do 
		local rewardData = info.rewards[i];
		local rewardLayer = cell("qc_rewardLayer"..i);
		if rewardData then
			rewardLayer("rewardImage").image = rewardData.image;
			rewardLayer("rewardText").text = rewardData.name.."x"..rewardData.count;
			rewardLayer.visible = 1;
		else
			rewardLayer.visible = 0;
		end
	end
end

--完成任务
function VAttainmentDlg:onFinishQuestClick(idx)
	local info = self.questData[idx+1];
	local limitInfo = {};
	for i,v in ipairs(info.rewards) do 
		local sub = gData:IsResoureUpperLimit(v.rType, v.rid, v.count);
		if sub  then
			local item = {};
			item.type = v.rType;
			item.id = v.rid;
			item.count = sub;
			table.insert(limitInfo, item);
		end
	end

	if next(limitInfo) then
		gWindow:showUpperlimitTip(limitInfo, self, "sendFinishMsg", idx);
		return;
	end
	self:sendFinishMsg(idx);
end


--完成任务消息回调
function VAttainmentDlg:finishQuestCallBack(result, rsp, req)
	if result == 0 then
		--同步任务数据
	    self:synchronize();
	    gWindow:showReWardTip(rsp.ri, "huodejiangli.png");
	else
		local idx = req.idx;
		local info = self.questData[idx+1];
		info.state = 2;
		self:showDlg();
	end
end


--完成任务
function VAttainmentDlg:sendFinishMsg(idx)
	local info = self.questData[idx+1];
	info.state = 3;
	gReq:MsgReqQuestFinish(self, "finishQuestCallBack", info.questid, idx);
end

--同步任务数据
function VAttainmentDlg:synchronizeRespone(result, rsp)
	gWindow:closeWaitTip();
	if result == 0 then
		self:showDlg();
	end
end

--点击任务列表查看详情
function VAttainmentDlg:onItemClick(idx)
	local info = self.questData[idx+1];
	if info then
		if info.unfold then
			info.unfold = false;
		else
			info.unfold = true;
		end
	end
	local offset = self.tbv:getContentOffset();
	local minOffset1 = self.tbv:minContainerOffset();
	self.tbv:reloadData();
	local minOffset2 = self.tbv:minContainerOffset();
	offset.y = offset.y + (minOffset2.y-minOffset1.y);
	self.tbv:setContentOffset(offset);
end