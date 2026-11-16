
require "vPlayerOperateDlg"

VPvpFriendCell = VClass("PvpFriendCell", VTableViewCell)

function VPvpFriendCell:Recover(count, cellType)

    self.info = {}
    self:StopTimer("UpDataBattleInfo")
    for i = 1, count do
        local item = self("imgBackGroundBagC"..i)
        
        item("txTimeFriendl").text = ""
        item("txLevelFriendl").text = ""
        item("txLevelFriendl").text = "Lv0"
        item("imgMassege").visible = 0
        item("txPvpStart").visible = 1
        local txPvpStart = item("txPvpStart")
        txPvpStart.text = "未被攻击"
        txPvpStart.color="fc_14_"
        item.lastBattleInfos = nil
        item.visible = false
    end
end

function VPvpFriendCell:SetInfo(idx, count, data)

    self.longTime = -1
    
    for i = 1, count do
        local info = data[idx * count + i]

        if info then
            local item = self("imgBackGroundBagC"..i)

            local vipLevel = self:GetVipLevel(self.info.charge or 0)

            self:SetHeadImageInfo(item("imgFriendFriendl"), info)

            item("txNickFriendl").text = info.nick
            item("txLevelFriendl").text = "LV"..(info.level or 0)
            
            local battle_infos = self:GetLastRoleBattleInfo(info.battle_infos)
            
            local time = 0
            if battle_infos then
                time = battle_infos.assistTime - gData:currentTime()
                item("txTimeFriendl").text = self:TransformTimeToString(time)
--                item("txPvpStart").text = self:TransformTypeToString(battle_infos, time)
                local image, bgImage = self:TransformTypeToImage(battle_infos, time)
                if image == "battle" then
                    local txPvpStart = item("txPvpStart")
                    txPvpStart.text = "战斗中"
                    txPvpStart.color = "fc_11_"
                    txPvpStart.visible = 1
                    local imgMassege = item("imgMassege")
                    imgMassege.visible = 0
                    
                else
                    local imgMassege = item("imgMassege")
                    item("imgPvpStart").image = image
                    imgMassege.image = bgImage
                    imgMassege.visible = 1
                    
                    item("txPvpStart").visible = 0
                end
                
                if time > 0 and (time < self.longTime or self.longTime == -1) then
                    self.longTime = time
                end
                -- info.hasAdd = gData:isMyFriend(info.userid)
                -- self("imgBackGroundFriendl").visible = 1
                info.lastBattleInfos = battle_infos
                info.lastBattleInfos:SetAssistTarget(info.userid, info.userid)
            end
            
            item.time = time
            item.tmpTime = time
            table.insert(self.info, info)
            item.visible = true
        end
    end
    
    self.idx = idx
    if self.longTime > 0 then
        self:StartTimer("UpDataBattleInfo", 1, self.longTime - 1, 0)
    end

end

function VPvpFriendCell:SetHeadImageInfo(headImage, userBriefInfo)
    headImage:setHead(userBriefInfo.userid or userBriefInfo.id, userBriefInfo.image, nil, gData:GetVipLevel(userBriefInfo.charge or 0))

    headImage:SetHeadImageShader()
end

function VPvpFriendCell:GetLastRoleBattleInfo(infos)
    if not infos then
        return
    end
    
    local currentTime = gData:currentTime()
    local info = nil
    local infoC = nil
    local count = #infos
    cclog("count~~~~~~~~~~~"..(count or -11))
    if infos and count ~= 0 then
        for var = 1, count do        ------就取时间戳最大的数据显示
            if currentTime < infos[var].assistTime and 
            (not info or info.assistTime < infos[var].assistTime) then
                info = infos[var]
            elseif not infoC then
                infoC = infos[var]
        	end
        end
    else
        return nil
    end
    
    return info or infoC
end

function VPvpFriendCell:UpDataBattleInfo(parameters)
    self.longTime = self.longTime - 1
    
	for var = 1, 2 do
        local info = self.info[var]

        if info then
            local item = self("imgBackGroundBagC"..var)
            if item.time > 0 then
                if self.longTime <= 0 then
                    self:StopTimer("UpDataBattleInfo")
                    local userids = {}
                    for key, var in ipairs(self.info) do
                        table.insert(userids, var.userid)
                    end
                    local friendOption = gView()("friendOption")
                    if friendOption then
                        friendOption:ReqBattleInfo(userids, self.idx)
                    end
                else
                    item.tmpTime = item.tmpTime - 1
                    item("txTimeFriendl").text = self:TransformTimeToString(item.tmpTime)
                end
            end
            --            info.lastBattleInfos.assistTime = info.lastBattleInfos.assistTime - 1
            --            item("txTimeFriendl").text = self:TransformTimeToString(info.lastBattleInfos.assistTime)
        end
	end
end

function VPvpFriendCell:TransformTimeToString(time, item)
    if time <= 0 then
        return ""
    end
    
    local hour = math.modf(time/3600);
    local t1 = time % 3600;
    local min = math.modf(t1/60);
    local sec = t1%60;
    
--    item.hour = hour
--    item.min = min
--    item.sec = sec
--    
    if hour == 0 then
        if min ~= 0 then
            return "增援倒计时"..min.."分钟"
        else
            if sec == 0 then
                
            end
            return "增援倒计时"..sec.."秒";
        end
    end
    
    return "增援倒计时"..hour.."小时"
end

function VPvpFriendCell:TransformTypeToImage(battle_infos, time)
    local type = battle_infos.aType
    
    local roleBattleInfos = gData.userInfo.roleInfo.roleBattleInfo
    local roleBattleInfo = roleBattleInfos:GetRoleBattleAssistInfoById(battle_infos.battleid)

    if battle_infos.target == gData.userInfo.userid then--or (roleBattleInfo and roleBattleInfo.aType ~= (type + 2)) then
        return "battle"
    end

    if (roleBattleInfo and roleBattleInfo.aType == (type + 2)) then
        return "yijingzengyuan.png", "anniu8.png"
    elseif (roleBattleInfo and roleBattleInfo.aType ~= (type + 2)) then
        return "yijingcanzhan.png", "anniu8.png"
    end
    
	if type == 1 then
        if time > 0 then
            return "xiezhujinggong1.png", "anniu9.png"
	    end   
    elseif type == 2 then
        if time > 0 then
            return "xiezhufangshou1.png", "anniu9.png"
        end
--	else
--        if time > 0 then
--            return "有战斗"
--        end       
	end
	
    return "battle"
end

function VPvpFriendCell:onOpenPlayerOperateDlg(index)
    local dlg = VNode("vPlayerOperateDlg.vui")
    dlg:SetUserInfo(self.info[index], nil, gView()("friendOption"), "ReqFriendDelCallBack")
    gView():Push(dlg)
end


function VPvpFriendCell:GetVipLevel(charge)
    local vipCsv = gData:readCsv("user_vip.csv");
    local vipInfo = nil
    local iter = VDataIter()
    while vipCsv.var:Travel(iter) do
        local item = iter:Data();
        if item[1] > charge then
            break;
        else
            vipInfo = item;
        end
    end

    return vipInfo[0]
end

function VPvpFriendCell:OpenTeamBattleDlg(pos)
    local info = self.info[pos]
    
    if info.lastBattleInfos then
        local roleBattleInfos = gData.userInfo.roleInfo.roleBattleInfo
        local roleBattleInfo = roleBattleInfos:GetRoleBattleAssistInfoById(info.lastBattleInfos.battleid)
  
        if info.lastBattleInfos.target == gData.userInfo.userid then--or (roleBattleInfo and roleBattleInfo.aType ~= (info.lastBattleInfos.aType + 2)) then
            return
        end
    
        local time = info.lastBattleInfos.assistTime - gData:currentTime()
        if time > 0 then
            ShowGroupBattleDlgByAssistInfo(info.lastBattleInfos)
        end
    end
end