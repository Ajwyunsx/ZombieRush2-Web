--=====================================
--vBattleLogCell.lua
--=====================================

--=====================================
VBattleLogCell = VClass("BattleLogCell", VTableViewCell)
--=====================================
function VBattleLogCell:setParentType(parent)
    self.parent = parent;
end
function VBattleLogCell:setCellType(type)
	self.type = type;
end
function VBattleLogCell:setBriefLogInfo(info, idx)
    self.info = info;
    self.idx = idx;
end
function VBattleLogCell:recover(count)
    self("imgHarvest1").visible = 1
    self("imgHarvest2").visible = 1
    self("imgHarvest3").visible = 1
    self("txHarvest1").text = 0
    self("txHarvest2").text = 0
    self("txHarvest3").text = 0
    self("txHarvest1").visible = 1
    self("txHarvest2").visible = 1
    self("txHarvest3").visible = 1
    self("imgLoss1").visible = 1
    self("imgLoss2").visible = 1
    self("imgLoss3").visible = 1
    self("txLoss1").text = 0
    self("txLoss2").text = 0
    self("txLoss3").text = 0
    self("txLoss1").visible = 1
    self("txLoss2").visible = 1
    self("txLoss3").visible = 1
    -- self("imgPlayerWarl").touch = 0
end
function VBattleLogCell:setInfo(info)
    self("atkNameText").text = gData.userInfo.roleInfo.nick
    self("atkLvText").text = "LV"..gData.userInfo.roleInfo.level
--    self("atkHeadImg").text = gData.userInfo.roleInfo.image
    self:SetHeadImageInfo(self("atkHeadImg"), gData.userInfo.roleInfo)
    
	local userInfo = nil
    if  self.info.attacker.userid ~= gData.userInfo.userid then
--		local bHasHarvest = false;
--		local bHasLoss = false;
        self("imgHarvest2").visible = 0
        self("txHarvest2").visible = 0
        self("imgHarvest3").visible = 0
        self("txHarvest3").visible = 0
        self("imgHarvest1").image = ""
        
        self("imgLoss3").visible = 0
        self("txLoss3").visible = 0
		local index = 1;
        self("imgHarvest" .. index ).image = "suipian.png";
        if ( info.spoils.itemInfos ~= nil and tonumber(info.spoils.itemCount) > 0 ) then
--			bHasLoss = true;
            
            self("txHarvest" .. index).text = tostring(info.spoils.itemCount);
            self("imgHarvest" .. index ).visible = 1;
            self("txHarvest" .. index).visible = 1
			index = tonumber(index) + 1;
		end
		
		index = 1
        self("imgLoss" .. index ).image = "icon_jinbi_S.png";

        if ( info.spoils.sunshine ~= nil ) then
--            bHasHarvest = true;
            
            self("txLoss" .. index).text = math.abs(info.spoils.sunshine);
            self("imgLoss" .. index ).visible = 1;
            self("txLoss" .. index ).visible = 1;
        end
        index = tonumber(index) + 1;
        
        self("imgLoss" .. index ).image = "icon_yibi_S.png";
		if ( info.spoils.gold ~= nil ) then
--			bHasLoss = true;
			
			self("txLoss" .. index).text = math.abs(info.spoils.gold);
			self("imgLoss" .. index ).visible = 1;
            self("txLoss" .. index ).visible = 1;
		end
        index = tonumber(index) + 1;

        userInfo = self.info.attacker;
    else
--       local bHasHarvest = false;
--		local bHasLoss = false;
        self("imgLoss2").visible = 0
        self("txLoss2").visible = 0
        self("imgLoss3").visible = 0
        self("txLoss3").visible = 0
        
		local index = 1;
        self("imgHarvest" .. index ).image = "icon_jinbi_S.png";
		if ( info.spoils.sunshine ~= nil and tonumber(info.spoils.sunshine) > 0 ) then
			bHasHarvest = true;
			
			self("txHarvest" .. index).text = tostring(info.spoils.sunshine);
			self("imgHarvest" .. index ).visible = 1;
            self("txHarvest" .. index ).visible = 1;
		end
        index = tonumber(index) + 1;
        
        self("imgHarvest" .. index ).image = "icon_yibi_S.png";
		if ( info.spoils.gold ~= nil and tonumber(info.spoils.gold) > 0 ) then
			bHasHarvest = true;
			
			self("txHarvest" .. index).text = tostring(info.spoils.gold);
			self("imgHarvest" .. index ).visible = 1;
            self("txHarvest" .. index ).visible = 1;
		end
        index = tonumber(index) + 1;
        
        self("imgHarvest" .. index ).image = "suipian.png";
        if ( info.spoils.itemInfos ~= nil and tonumber(info.spoils.itemCount) > 0 ) then
			bHasHarvest = true;
			
            self("txHarvest" .. index).text = tostring(info.spoils.itemCount);
			self("imgHarvest" .. index ).visible = 1;
            self("txHarvest" .. index ).visible = 1;
			index = tonumber(index) + 1;
		end
        index = 1
        self("imgLoss" .. index ).image = "jiangshidaibiao.png";
        if ( info.monsters ~= nil and tonumber(info.monsters) > 0 ) then
            --            bHasHarvest = true;
            
            self("txLoss" .. index).text = tostring(info.monsters);
            self("imgLoss" .. index ).visible = 1;
            self("txLoss" .. index ).visible = 1;
        else
            self("txLoss" .. index).text = "无损伤"
        end
        index = tonumber(index) + 1;
		
        userInfo = self.info.defender;
    end
	
    if self.info.defender.userid == gData.userInfo.userid then
        self("imgWarLossTitle").image = "beiqiang.png"
        if info.result == 1 then
            self("imgResultWarl").image = "shibaijiaobiao.png";
            self("imgResultWarl").offset = {-8,0}
--			self("txResultWarl").image = "防守失败";
            
        else
            self("imgResultWarl").image = "shenglijiaobiao.png";
            self("imgResultWarl").offset = {-8,2}
--			self("txResultWarl").image = "防守胜利";
        end
        self("imgStartWarl").image = "fangshoutiao.png"
        self("defIcon").image = "gong.png"
        self("atkIcon").image = "fang.png"
    elseif self.info.attacker.userid == gData.userInfo.userid then
        self("imgWarLossTitle").image = "siwang.png"
        if info.result == 1 then
            self("imgResultWarl").image = "shenglijiaobiao.png";
            self("imgResultWarl").offset = {-8,2}
--			self("txResultWarl").image = "进攻胜利";
        else
            self("imgResultWarl").image = "shibaijiaobiao.png";
            self("imgResultWarl").offset = {-8,0}
--			self("txResultWarl").image = "进攻失败";
        end
        self("imgStartWarl").image = "jinggongtiao.png"
        self("defIcon").image = "fang.png"
        self("atkIcon").image = "gong.png"
    end

    self("txTimeWarl").text = self:showTimeText(info.time)
    
    if userInfo == nil then
        cclog("没找到玩家信息")
        return
    end
    
    self("txNameWarl").text = userInfo.nick;
--    self("imgPlayerWarl").image = gData:headImage(userInfo.userid, userInfo.image);
    self:SetHeadImageInfo(self("imgPlayerWarl"), userInfo)
    self("txLevelWarl").text = "LV"..userInfo.level;
    local imgPlayerWarl = self("imgPlayerWarl")
    -- imgPlayerWarl.touch = 1
    imgPlayerWarl.info = userInfo
--	self("txVipWarl").text = "Vip"..userInfo.vipInfo[0];
--	self("imgGroupWarl").image = self:getImgGroup();
end

function VBattleLogCell:SetHeadImageInfo(headImage, userBriefInfo)

    local vipCharge = userBriefInfo.charge or 0

    if (userBriefInfo.userid or userBriefInfo.id) == gData.userInfo.userid then
        vipCharge = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCharge)
    end

    headImage:setHead(userBriefInfo.userid or userBriefInfo.id, userBriefInfo.image, nil, gData:GetVipLevel(vipCharge))

    headImage:SetHeadImageShader()
end

function VBattleLogCell:getSignNumWithType(num, logType)
    local text = "";
    if ( num == 0 ) then
        return num;
    elseif (logType == "DEF") then
	   text = "-" .. num;
	else
	   text = "+" .. num;
	end
	
    return text;
end
function VBattleLogCell:getSexImgWithNum(sexNum)
    if (sexNum == 1) then
        return "nv.png";
    else
        return "nan.png";
    end
end
function VBattleLogCell:showTimeText(time)
    local timeText = "";
    local timeSpace = self:calcTimeSpace(gData:currentTime(), time);
    
    local hour = 0;
    local min = 0;
    
    if (timeSpace.day > 0 and timeSpace.day < 2) then
        return "昨天";
    elseif (timeSpace.day >= 2 and timeSpace.day < 3) then
        return "前天";
    elseif (timeSpace.day >= 3) then
        return timeSpace.day.."天前";
    else
        if (timeSpace.hour > 0) then
            return timeSpace.hour.."小时前";
        else
            if (timeSpace.min > 0) then
                return timeSpace.min.."分钟前";
            else
                return "刚刚";
            end
        end
    end
end
function VBattleLogCell:calcTimeSpace(time1, time2)
    local timeSpace = {}
    local secSpace = time1 - time2
    timeSpace.day = math.floor(secSpace / (3600 * 24))
    timeSpace.hour = math.floor((secSpace - (timeSpace.day * 3600 * 24)) / 3600)
    timeSpace.min = math.floor((secSpace - (timeSpace.day * 3600 * 24) - (timeSpace.hour * 3600)) / 60)
    timeSpace.sec = secSpace - (timeSpace.day * 3600 * 24) - (timeSpace.hour * 3600) - (timeSpace.min * 60)
	return timeSpace
end
function VBattleLogCell:onOpenLogDetailDlg()
    -- local aParam = {}
    -- aParam.id = self.info.id
    -- aParam.battleInfo = {}
    -- aParam.battleInfo.userid = self.info.userid
    -- aParam.battleInfo.image = self.info.image
    -- aParam.battleInfo.level = self.info.level
    -- aParam.battleInfo.sex = self.info.sex
    -- aParam.battleInfo.nick = self.info.nick
    self:Parent(3):reqBattleLogInfoQuery(self.info);
end
function VBattleLogCell:onPlayback(info)
    cclog("id"..self.info.id)
    gData.showLog = true
    VCallBack(gMainView, "sendBattleRequest", tostring(self.info.id), EBattleRequestType.Replay);
end


function VBattleLogCell:onOpenPlayerOperateDlg( ... )
    -- body
    local imgPlayerWarl = self("imgPlayerWarl")
    local info = imgPlayerWarl.info
    local dlg = VNode("vPlayerOperateDlg.vui")
    dlg:SetUserInfo(info)
    gView():Push(dlg)
end







