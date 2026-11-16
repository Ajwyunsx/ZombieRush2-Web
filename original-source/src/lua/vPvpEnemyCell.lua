-----掠夺界面仇敌选项卡cell

require "vAddEnemyDlg"
require "vPlayerOperateDlg"

VPvpEnemyCell = VClass("PvpEnemyCell", VTableViewCell)


-----将cell界面恢复至初始状态
function VPvpEnemyCell:Recover(count, cellType)
    self.info = {}
    self:StopTimer("UpDataBattleInfo")
    for i = 1, count do
        local item = self("imgBackGroundBagC"..i)

        item("txTimeEnemyl").text = ""
        item("txLevelEnemyl").text = ""
        item("txLevelEnemyl").text = "Lv0"

        item("lyEnemy").visible = 0
        item("lyAddEnemy").visible = 0
        local imgMassege = item("imgMassege")
        imgMassege.visible = 1

        item("txPvpStart").visible = 0
        imgMassege.image = "anniu8.png"
        local txPvpStart = item("txPvpStart")
        txPvpStart.text = "战斗中"
        txPvpStart.color={255,0,0}
        item.onClick = nil
        item.lastBattleInfos = nil
        item.visible = false
    end
end


------设置cell的内容
function VPvpEnemyCell:SetInfo(idx, count, data)

    self.longTime = -1  --------当前cell计时器时间（一个cell有count列信息，统一用一个计时器刷新）
    self.count = count
    
    for i = 1, count do
        local info = data[idx * count + i]
        
        if info then
            
            local item = self("imgBackGroundBagC"..i)
            local time = 0      -------cell对应列的计时时间
            
            if info.userid ~= -1 then   -----cell显示内容为仇敌信息时

                self:SetHeadImageInfo(item("imgEnemyEnemyl"), info)
                
                item("txNickEnemyl").text = info.nick or ""
                item("txLevelEnemyl").text = "LV"..(info.level or 0)
                
                local attackedInfo = gData.userInfo.roleInfo.attackedInfos[info.userid]
                
                if self:CheckCoolDown(info) then   -----判断掠夺是否冷却
                    time = attackedInfo.time - gData:currentTime()
                    item("txTimeEnemyl").text = "冷却时间 :"..self:TransformTimeToString(time)
                    local txPvpStart = item("txPvpStart")
                    txPvpStart.text = "已掠夺"
                    txPvpStart.color = {68, 62, 72}
                    item("txPvpStart").visible = 1
                    item("imgMassege").visible = 0
                    item("lyResEnemy").visible = 0

                    -------将cell内所有列中计时最小的时间记录下来做为cell计时器时间
                    if time > 0 and (time < self.longTime or self.longTime == -1) then
                        self.longTime = time
                    end
                else
                    item("txCoinEnemyl").text = info.money
                    item("txSunEnemyl").text = info.sunshine
                    item("lyResEnemy").visible = 1
                    item("lyResEnemy"):ReLayout()

                    local battle_infos = self:GetLastRoleBattleInfo(info.battle_infos)

                    if battle_infos then
                        time = battle_infos.assistTime - gData:currentTime()

                        local image, bgImage = self:TransformTypeToImage(battle_infos, time)
                        if image == "battle" then
                
                            item("txPvpStart").visible = 1
                            item("imgMassege").visible = 0
                        else
                            local imgMassege = item("imgMassege")
                            item("imgPvpStart").image = image
                            imgMassege.image = bgImage
                            imgMassege.visible = 1
                            item("txPvpStart").visible = 0
                        end
                
                        info.lastBattleInfos = battle_infos
                
                        info.lastBattleInfos:SetAssistTarget(info.userid, battle_infos.target)
            
                    else
                        item("imgPvpStart").image = "lueduo1.png"
                    end
                end
                
                item("lyEnemy").visible = 1
                    
            
            else    -----cell显示内容为添加仇敌功能时
                item.onClick = "node:Parent():OpenAddEnemyDlg()"
                
                item("lyAddEnemy").visible = 1
            end
            
            item.hasTime = time   -----用于判断cell对应列是否要计时，（item.hasTime不大于0则为需要）
            item.time = time      -----存储cell对应列计时时间
            table.insert(self.info, info)
            
            item.visible = true
        end
    end
    
    self.idx = idx

    if self.longTime > 0 then    ------判断cell是否需要计时
        self:StartTimer("UpDataBattleInfo", 1, self.longTime - 1, 0)
    end

end


-----设置玩家头像
function VPvpEnemyCell:SetHeadImageInfo(headImage, userBriefInfo)
    headImage:setHead(userBriefInfo.userid or userBriefInfo.id, userBriefInfo.image, nil, gData:GetVipLevel(userBriefInfo.charge or 0))
    
    headImage:SetHeadImageShader()
end


-----从多场战场信息中按规则获取一场场战场信息
function VPvpEnemyCell:GetLastRoleBattleInfo(infos)
    if not infos then
        return
    end
    
    local currentTime = gData:currentTime()
    local info = nil
    local count = #infos
    if infos and count ~= 0 then
        for var = 1, count do     ------优先取防守信息，没有则取时间戳最大的数据显示
            local battleInfo = infos[var]

            if currentTime < battleInfo.assistTime then
                if not info then
                    info = battleInfo
                elseif battleInfo.aType == 2 then
                    if info.aType ~= 2 then
                        info = battleInfo
                    elseif info.assistTime < battleInfo.assistTime then
                        info = battleInfo
                    end
                elseif battleInfo.aType == 1 then
                    if info.aType ~= 2 and info.assistTime < battleInfo.assistTime then
                        info = battleInfo
                    end
                end
            end
        end
    else
        return nil
    end
    
    return info
end


------计时器调用刷新cell信息
function VPvpEnemyCell:UpDataBattleInfo(parameters)
    self.longTime = self.longTime - 1

    if self.longTime <= 0 then  ----------cell计时器（总计时器）时间到则发送获取最新战斗信息请求
        self:StopTimer("UpDataBattleInfo")
        local userids = {}
        for key, var in ipairs(self.info) do
            table.insert(userids, var.userid)
        end
        gView()("enemyOption"):ReqBattleInfo(userids, self.idx)
    else
        for var = 1, self.count do   -----刷新cell内各列的信息
            local info = self.info[var]

            if info and info.userid ~= -1 then
                local item = self("imgBackGroundBagC"..var)
                if item.hasTime > 0 then  ------判断当前列是否需要刷新
                    if self:CheckCoolDown(info) then  -----界面要求掠夺冷却时，时间才显示，其他情况不显示，所以，掠夺冷却才刷新界面时间
                        item.time = item.time - 1
                        item("txTimeEnemyl").text = "冷却时间 :"..self:TransformTimeToString(item.time)
                    end
                end
            end
        end
    end
end


------判断时间掠夺时间是否冷却
function VPvpEnemyCell:CheckCoolDown( info )
    -- body
    local attackedInfo = gData.userInfo.roleInfo.attackedInfos[info.userid]
                
    return attackedInfo and attackedInfo:GetAttackedCoolDownTime() > 0
end


------将时间格式化
function VPvpEnemyCell:TransformTimeToString(time)
    if time <= 0 then
        return ""
    end
    local hour = math.modf(time/3600);
    local t1 = time%3600;
    local min = math.modf(t1/60);
    local sec = t1%60;

    if hour == 0 then
        if min ~= 0 then
            return min.."分钟"
        else
            if sec == 0 then
                
            end
            return sec.."秒";
        end
    end

    return hour.."小时"
end

-----根据战场信息和时间返回界面按钮的状态
function VPvpEnemyCell:TransformTypeToImage(battle_infos, time)
     local type = battle_infos.aType
    
    local roleBattleInfos = gData.userInfo.roleInfo.roleBattleInfo
    local roleBattleInfo = roleBattleInfos:GetRoleBattleAssistInfoById(battle_infos.battleid)

    --判断当前团战的主敌人是否是自己
    if battle_infos.target == gData.userInfo.userid then--or (roleBattleInfo and roleBattleInfo.aType ~= (type + 2)) then
        return "lueduo1.png", "anniu8.png"
    end


    --判断自己的团战数据是否包含当前团战且自己的状态为协助进攻
    if (roleBattleInfo and roleBattleInfo.aType ~= (type + 2)) then
        if time > 0 then
            return "yijingcanzhan.png", "anniu8.png"
        else
            return "battle"
        end
    end

    --
    if type == 1 then
            return "lueduo1.png", "anniu8.png"
    elseif type == 2 then
        if time > 0 then
            return "weijiao1.png", "anniu9.png"
        end
	else
            return "lueduo1.png", "anniu8.png"
	end
	
    return "battle"
end

-----打开玩家功能操作界面
function VPvpEnemyCell:onOpenPlayerOperateDlg(index)
    local dlg = VNode("vPlayerOperateDlg.vui")
    dlg:SetUserInfo(self.info[index], nil, gView()("enemyOption"), "ReqEnemyDelBack")
    gView():Push(dlg)
end

-----获取vip等级
function VPvpEnemyCell:GetVipLevel(charge)
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


------打开指定id添加仇敌的界面
function VPvpEnemyCell:OpenAddEnemyDlg(parameters)
    local dlg = VNode("vAddEnemyDlg.vui")
    dlg:SetDlgInfo(self.idx)
    gView():Push(dlg)
end


------掠夺，围剿等功能按钮的点击
function VPvpEnemyCell:OpenTeamBattleDlg(pos)
    local info = self.info[pos]
    if info.lastBattleInfos then  ----有无有效的战场信息
        local time = info.lastBattleInfos.assistTime - gData:currentTime()
        if time > 0 and info.lastBattleInfos.aType == 2 then   -----增援时间未到且仇敌处在防守时，打开打开战场界面，其余直接掠夺
            ShowGroupBattleDlgByAssistInfo(info.lastBattleInfos)
        else
            if gMainView then
                gMainView:sendBattleRequest(info.userid, EBattleRequestType.Observe, nil, info);
            end
        end
    else
        if gMainView then
            gMainView:sendBattleRequest(info.userid, EBattleRequestType.Observe, nil, info);
        end
    end
end