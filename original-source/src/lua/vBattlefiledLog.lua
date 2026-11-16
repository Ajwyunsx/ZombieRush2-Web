VBattlefiledLog = VClass("BattlefiledLog", VMsgBox);

function VBattlefiledLog:SetLogInfo( logInfo, faction )
	self.logInfo = logInfo;
	self.faction = faction;
	table.sort(self.logInfo, function(a,b)
		return a.time > b.time;
	end)
end

function VBattlefiledLog:onPush()
	self.tbv = self("logTbv");
	self.tbv.delegate = self;
	self.tbv.number = #self.logInfo;
	self.tbv:reloadData();
end

function VBattlefiledLog:onCell(idx, t, cell)
	idx = idx + 1;
	local info = self.logInfo[idx];
	local attackerInfo = gData:briefCache(info.attacker);
	local defenderInfo = gData:briefCache(info.defender);

	if attackerInfo then
		cell("atkNameText").text = attackerInfo.nick;
		cell("atkLvText").text = "Lv"..attackerInfo.level;
		local vipLevel = gData:GetVipLevel(attackerInfo.charge);
		cell("atkHeadImg"):setHead(attackerInfo.userid, attackerInfo.image, nil, vipLevel);
		cell("atkHeadImg"):SetHeadImageShader();
	end

	if defenderInfo then
		cell("defNameText").text = defenderInfo.nick;
		cell("defLvText").text = "Lv"..defenderInfo.level;
		local vipLevel = gData:GetVipLevel(defenderInfo.charge);
		cell("defHeadImg"):setHead(defenderInfo.userid, defenderInfo.image, nil, vipLevel);
		cell("defHeadImg"):SetHeadImageShader();
	end

	if self.faction == 1 or self.faction == 3 then
		cell("factionImg").image = "jinggongtiao.png";
		if info.victor == info.attacker then
			cell("resultImg").image = "shenglijiaobiao.png";
		else
			cell("resultImg").image = "shibaijiaobiao.png";
		end
	else
		cell("factionImg").image = "fangshoutiao.png";
		if info.victor == info.attacker then
			cell("resultImg").image = "shibaijiaobiao.png";
		else
			cell("resultImg").image = "shenglijiaobiao.png";
		end
	end

	cell("intervalText").text = self:GetIntervalString(info.time);
	cell("monsterCasualtyNum").text = info.attacker_dead;
	cell("plantCasualtyNum").text = info.defender_dead;
	cell("replayBtn").onClick = "node:Parent(5):ClickReplayBtn("..idx..")";
end

function VBattlefiledLog:GetIntervalString( endTime )
	time = gData:currentTime() - endTime;
	local day = 60 * 60 * 24;
	local hour = 60 * 60;
	local min = 60;
	if time > day then
		local num = math.modf(time/day);
		return num.."天之前";
	end
	if time > hour then
		local num = math.modf(time/hour);
		return num.."小时之前";
	end
	if time > min then
		local num = math.modf(time/min);
		return num.."分钟之前";
	end
	return time.."秒钟之前";
end

function VBattlefiledLog:ClickReplayBtn(idx)
	local info = self.logInfo[idx];
	gMainView:sendBattleRequest(tostring(info.logid), EBattleRequestType.Replay);
end