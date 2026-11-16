VDungeonInfo = vclass("DungeonInfo")

function VDungeonInfo:initialize()
    self.actInfos = {};  ----存储网络的关卡进度数据
    self.chapters = {}   ----存储配置表的关卡数据
    self.dungeon_rewards = {}
    self.extraShop = {}
    self.needShow = false
    self.levelShow = nil
    self.purchaseShow = false
    self.tipShow = false
    self.extraShopid = 10801    -----有特殊商店的小关卡id（写死）
    self.extendShopid = 11001  ----有特殊商店的小关卡id（写死）
    self.timeLimit = 86400      -----特殊商店消失倒计时（写死）

    -----读取与关卡有关的静态数据（包括配置，以及存储在文件的数据）
    self:LoadlevelShopExToFile()
    self:LoadBattleTipCsv()
    self:LoadDungeonRewards()
    self:LoadPropDungeonCsv()
    self:LoadDungeonShopCsvInfo()
    self:LoadPropCampaignCsv()
    self:LoadDungeonChannelEx()
end

function VDungeonInfo:convertCampaignInfoVData(campaignInfo)
    local campVar = {};
    campVar.id = campaignInfo.id;
    campVar.record = campaignInfo.record;
    campVar.online_reward = campaignInfo.online_reward;

    campVar.purchase = campaignInfo.purchase;
    
    return campVar;
end

function VDungeonInfo:convert2VData()
    local dataTable = {};
    for k1,actInfo in pairs(self.actInfos) do
        local actVar = {};
        actVar.id = actInfo.id;
        actVar.pass = actInfo.pass;
        actVar.infos = {};

        for k2,campaignInfo in pairs(actInfo.campaignInfo) do
            table.insert(actVar.infos, self:convertCampaignInfoVData(campaignInfo));
        end

        local actInfos = {}
        actInfos.info = actVar;
        table.insert(dataTable, actInfos);
    end
    return Var(dataTable);
end

function VDungeonInfo:synWithPbData(pbData)
    if not pbData then return end;


    local count = pbData:Count()

    for var = 0, count - 1 do

        if pbData[var].ctrl == nil then
--            self.actInfos = {}
            local actInfo = self:CreateActInfo(pbData[var])
            
            self.actInfos[actInfo.id] = actInfo
            
        elseif pbData[var].ctrl.op == _VCtrlOP.None then
        
--            self.actInfos = {}
            local actInfo = self:CreateActInfo(pbData[var])

            self.actInfos[actInfo.id] = actInfo
        elseif pbData[var].ctrl.op == _VCtrlOP.Rep or
            pbData[var].ctrl.op == _VCtrlOP.Add then
            
            local actInfo = self:CreateActInfo(pbData[var])
            
            self.actInfos[actInfo.id] = actInfo
            
        elseif pbData[var].ctrl.op == _VCtrlOP.Del then
            self.actInfos[pbData[var].info.id] = nil
        end
    end
end


---根据服务器的数据创建大关卡
function VDungeonInfo:CreateActInfo(pbData)
	local actInfo = {}

    actInfo.id = pbData.info.id 
    actInfo.pass = pbData.info.pass and pbData.info.pass ~= 0;
    actInfo.starHas = 0
    actInfo.campaignInfo = {}   ---用于存储小关卡
    
    local count = pbData.info.infos:Count()
    local campaignInfo = pbData.info.infos

    for var = 0, count - 1 do
    
        local info = self:CreateCampaignInfo(campaignInfo[var])
       
        actInfo.starHas = actInfo.starHas + info.record
        actInfo.campaignInfo[info.id] = info
    end
    
    return actInfo
end


----根据服务器的数据创建小关卡
function VDungeonInfo:CreateCampaignInfo(pbData)
    local info = {}
    info.id = pbData.id
    info.record = pbData.record or 0
    info.online_reward = pbData.online_reward
    info.purchase = pbData.purchase or 0
    
    return info
end


----读取打关卡时有有新植物的帮助说明数据
function VDungeonInfo:LoadBattleTipCsv()
    self.battleHelp = {}

    local csv = gData:readCsv("dungeon_battleTip.csv");

    if not csv then
        return
    end

    local count = csv:lineCount();

    for i = 0, count - 1 do
        local info = csv:lineData(i)
        self.battleHelp[info[0]] = self.battleHelp[info[0]] or {}
        local battleHelp = self.battleHelp[info[0]]
        local helpInfo = VHelpInfo:new(info)
        table.insert(battleHelp, helpInfo)
    end
end


-----读取大关卡主表
function VDungeonInfo:LoadPropDungeonCsv(parameters)
    local csv = gData:readCsv("prop_dungeon.csv");

    if not csv then
        return
    end
    
    local count = csv:lineCount();

    for i = 0, count - 1 do
        local info = csv:lineData(i)

        self.chapters[info[0]] = self.chapters[info[0]] or {}

        local chapter = self.chapters[info[0]]
        chapter.id = info[0]
        chapter.limit = info[1]

        if chapter.limit ~= 0 then
            self.chapters[chapter.limit] = self.chapters[chapter.limit] or {}
            self.chapters[chapter.limit].nextChapter = chapter.id
        end
        
        chapter.name = info[5]
    end
end

---读取小关卡的奖励数据
function VDungeonInfo:LoadDungeonRewards()
    

    local csv = gData:readCsv("dungeon_rewards.csv");

    if not csv then
        return
    end

    local count = csv:lineCount();

    for i = 0, count - 1 do
        local info = csv:lineData(i)
        
        if info then
            
            local reward = nil
            
            reward = VRewardInfo:new(info)

            if reward then

                self.dungeon_rewards[reward.id] = self.dungeon_rewards[reward.id] or {}
                
                local rewards = self.dungeon_rewards[reward.id]
                
                rewards[reward.effect_id] = reward
                
            end
            
        end
    end
end


-----读取小关卡主表数据
function VDungeonInfo:LoadPropCampaignCsv( ... )
    -- body
    local csv = gData:readCsv("prop_campaign.csv");
    
    if not csv then
        return
    end 
    
    local count = csv:lineCount();

    for i = 0, count - 1 do
        local info = csv:lineData(i)
        
        ---根据小关卡的信心更新所在大关卡数据
        self.chapters[info[1]] = self.chapters[info[1]] or {}

        local chapter = self.chapters[info[1]]
        chapter.id = info[1]
        chapter.count = (chapter.count or 0) + 3   ---大关卡最多星星数
        chapter.levels = chapter.levels or {}


        ---存储小关卡数据
        local levels = chapter.levels
        levels[info[0]] = levels[info[0]] or {}

        local level = levels[info[0]]
        level.id = info[0]
        level.chapter = info[1]
        level.lockLimit = info[2]
        level.starLimit = info[5]
        level.type = info[3]
        level.reward1ID = info[6]
        level.reward2ID = info[7]
        level.reward3ID = info[8]
        level.rewardNetID = info[9]
        level.needNet = info[12]
        level.name = info[17] or ""

        level.battleHelp = self.battleHelp[level.id]

        --如有前置关卡（0为没有）且前置关卡同在同一个大关卡内
        if level.lockLimit ~= 0 and self:GetActInfosID(level.lockLimit) == level.chapter then
            levels[level.lockLimit] = levels[level.lockLimit] or {}
            
            if level.starLimit == 0 then  --如果本关不是特殊关卡
                levels[level.lockLimit].nextLevel = level.id
            else
                levels[level.lockLimit].extraLevel = level.id
            end
        end

        self:InitDungeonRewards(level)

        self:InitDungeonShop(level)
    end
end

----读取小关卡商店的数据
function VDungeonInfo:LoadDungeonShopCsvInfo(parameters)
    local csv = gData:readCsv("dungeon_shop.csv");

    if not csv then
        return
    end
    
    self.dungeon_shops = {}

    local count = csv:lineCount();

    for i = 0, count - 1 do
        local info = csv:lineData(i)

        if info then

            local shopInfo = nil

            
            shopInfo = VDungeonShopInfo:new(info)

            if shopInfo then

                self.dungeon_shops[shopInfo.id] = self.dungeon_shops[shopInfo.id] or {}

                local dungeon_shops = self.dungeon_shops[shopInfo.id]

                dungeon_shops[shopInfo.buyTip] = shopInfo

            end

        end
    end
end

function VDungeonInfo:LoadDungeonChannelEx( ... )
    -- body
	self.dungeon_channelEx = {}

    local csv = gData:readCsv("dungeon_channelEx.csv");

    if not csv then
        return
    end

    

    local count = csv:lineCount();

    for i = 0, count - 1 do
        local info = csv:lineData(i)
        self.dungeon_channelEx[info[0]] = info;
    end
end

function VDungeonInfo:GetDungeonRewardsCsvData( )
    -- body
    return self.dungeon_rewards
end

function VDungeonInfo:InitDungeonRewards( level )
    -- body
    
    ---一星奖励数据
    local info = self.dungeon_rewards[level.reward1ID]

    if info then
        level.reward1 = {}
        
        for key, var in pairs(info) do
            local reward = {}
            reward.type = var.type
            reward.effect_id = var.effect_id
            reward.effect_value = var.effect_value
            table.insert(level.reward1, reward)
        end
        
       
    end
    

    ---二星奖励数据
    info = self.dungeon_rewards[level.reward2ID]

    if info then
        level.reward2 = {}

        for key, var in pairs(info) do
            local reward = {}
            reward.type = var.type
            reward.effect_id = var.effect_id
            reward.effect_value = var.effect_value
            table.insert(level.reward2, reward)
        end
        
        
    end
    

    ---三星奖励数据
    info = self.dungeon_rewards[level.reward3ID]

    if info then
        level.reward3 = {}

        for key, var in pairs(info) do
            local reward = {}
            reward.type = var.type
            reward.effect_id = var.effect_id
            reward.effect_value = var.effect_value
            table.insert(level.reward3, reward)
        end
        
        
    end

    
    ---网络奖励数据
    if level.rewardNetID ~= 0 then
    
        info = self.dungeon_rewards[level.rewardNetID]

        if info then
            level.rewardNet = {}

            for key, var in pairs(info) do
                local reward = {}
                reward.type = var.type
                reward.effect_id = var.effect_id
                reward.effect_value = var.effect_value
                table.insert(level.rewardNet, reward)
            end
        end
    end
end


function VDungeonInfo:InitDungeonShop( level )
    
    level.shop = {count = 0}
    
    local shopInfo = self.dungeon_shops[level.id]
    
    if shopInfo then
        for k, v in pairs(shopInfo) do
            level.shop[v.buyTip] = v
            level.shop.count = level.shop.count + 1
        end
    end
end


----设置关卡的网络数据，单机网络数据共用
function VDungeonInfo:SetDungeonInfo(chapterid, levelid, record, online_reward, purchase, unLock)
    local info = nil
    local actInfo = nil
    if self.actInfos and self.actInfos[chapterid] then  ----网络数据中有id 为 chapterid 的大关卡数据
        local actInfo = self.actInfos[chapterid]
        if actInfo.campaignInfo and actInfo.campaignInfo[levelid] then  ----大关卡数据中有id为levelid的小关卡数据
            info = actInfo.campaignInfo[levelid]
            info.purchase = purchase or info.purchase
            
            
            
            if info.record and record and record > info.record then
                actInfo.starHas = (actInfo.starHas or 0) + record - info.record
                info.record = record               
            else
                info.record = info.record or record
            end

            info.online_reward = online_reward or info.online_reward
        else
            info = {}
            info.id = levelid
            info.record = record or 0
            info.online_reward = online_reward or 0
            info.isFirst = true
            info.purchase = purchase or 0
            info.unLock = unLock
            
            actInfo.starHas = (actInfo.starHas or 0) + info.record
            actInfo.campaignInfo = actInfo.campaignInfo or {}
            
            actInfo.campaignInfo[levelid] = info
        end
        
        local chapters = self.chapters
        local levels = chapters[chapterid].levels
        local levelInfo = levels[levelid]
        if not levels[levelInfo.nextLevel] and actInfo.campaignInfo[levelid].record > 0 then
            actInfo.pass = true
        end
    else
        actInfo = {}
        actInfo.id = chapterid
        actInfo.pass = false
        actInfo.starHas = 0
        actInfo.campaignInfo = {}
        
        info = {}
        info.id = levelid
        info.record = record or 0
        info.online_reward = online_reward or 0
        info.purchase = purchase or 0
        
        actInfo.starHas = actInfo.starHas + info.record
        actInfo.campaignInfo[levelid] = info
        
        self.actInfos[chapterid] = actInfo
    end
end


----根据打完某一小关卡的结果设置后续信息动作
function VDungeonInfo:UpDataActInfo(levelid, record, purchase)
    cclog("UpDataActInfo")
    cclog("levelid"..(levelid or -1))
    if not levelid then
        return
    end
    local chapterid = self:GetActInfosID(levelid)
    
    cclog("chapterid"..(chapterid or -1))
    if not chapterid then
        return
    end

    cclog("record"..(record or -1))
    
    self:SetTipShow(chapterid, levelid, record)
    
    self:CreateReward(chapterid, levelid, record)
    
    
    self:SetDungeonInfo(chapterid, levelid, record, nil, purchase, nil)
    gData.offlineData:saveOfflineData()
end


----设置打完关卡失败后的弹窗
function VDungeonInfo:SetTipShow( chapterid, levelid, record )
    -- body
    if (record or 0) == 0 and self:GetPurchase(levelid) == 0 then ---
        local chapter = self.chapters[chapterid]
        if chapter then
            local level = chapter.levels[levelid]
            if level and level.shop[2] and levelid ~= self.extraShopid then
                self.purchaseShow = level
                -- self.tipShow = 2
            elseif level and level.shop[2] and levelid == self.extraShopid then
                -- gData.userInfo.dungeonInfo:SavelevelShopExToFile()
                -- cclog("调用弹出框1")
                -- return

                self.purchaseShow = level
                self.tipShow = 1
            elseif gData.userInfo.roleInfo.vipInfo[0] < 5 and not gData.offlineData.offline  then
                self.tipShow = 2
            elseif gData.userInfo.roleInfo.vipInfo[0] >= 5 and not gData.offlineData.offline then
                self.tipShow = 3
            end
        end
    elseif (record or 0) == 0 and self:GetPurchase(levelid) ~= 0 then
        if gData.userInfo.roleInfo.vipInfo[0] < 5 and not gData.offlineData.offline then
            self.tipShow = 2
        elseif gData.userInfo.roleInfo.vipInfo[0] >= 5 and not gData.offlineData.offline then
            self.tipShow = 3
        end
    end
end

----创建关卡奖励数据，单击网络通用
function VDungeonInfo:CreateReward( chapterid, levelid, record )
    -- body
    if not gData.offlineData.offline then
--        local data = gData.offlineData:getDeltaOfflineData()
--        gReq:MsgReqDungeonReport(nil, nil, data, chapterid, levelid)
    else
        -- local tmpRecord = self.actInfos[chapterid].campaignInfo[levelid].record or 0
        local tmpRecord = self:GetLevelRecord(levelid)
        
        if record <= tmpRecord then
            return
        end
        
        local chapter = self.chapters[chapterid]
        if chapter then
            local level = chapter.levels[levelid]
            if level then
                
                for var = tmpRecord + 1, record do
                    
                
                    local reward = level["reward"..var]
                
                    if reward and reward[1] and reward[1].type == ThingType.ThingTypePlant then
                        local plantManager = gData.userInfo.plantInfos;
                        local count = reward[1].effect_value

                        for i = 1, count do
                            local id = 0    

                            for key, var in pairs(plantManager.plants) do
                                if string.len(key) <= 5 and tonumber(id) < tonumber(key) then
                                    id = key
                                end
                            end
                        
                            plantManager:updatePlant(id + 1, reward[1].effect_id, 1);
                        end         
                    elseif reward and reward[1] and reward[1].type == ThingType.ThingTypeArm then
                        local mi = gData.userInfo.monsterInfo;
                            
                        local count = reward[1].effect_value

                        for i = 1, count do
                            local id = 0    
                            for key, var in pairs(mi.monsterInfos) do
                                if string.len(key) <= 5 and tonumber(id) < tonumber(key) then
                                    id = key
                                end
                            end

                            mi:addMonster(id + 1, reward[1].effect_id, 1);
                        end
                    
                    elseif reward and reward[1] and reward[1].type == RES_DATA_TYPE.ResDataTypeAttr then
                        gData.userInfo.roleInfo:addAttrValue(reward[1].effect_id, math.abs(reward[1].effect_value));
                    end
                end
            end
        end
    end
end

-----关卡商店购买流程
function VDungeonInfo:ShopBuyClick(levelid, purchase, cost, delegate)
    local levelInfo = self:GetLevelCsvInfo(levelid)

    if levelInfo.shop[purchase].buyClass == 1 and 
        gRes:Platform() ~= "ios" and 
        gRes:Platform() ~= "mac" then

        self:SendSMS(cost)
        
    else
        if gData.offlineData.offline then
            gWindow:showNormalTip("单机模式不支持第三方支付", "提示")
            return
        end
        
        local YB = gData:attrValue(AttrType.AttrTypeCurrency)
        
        
        if YB < cost * gResRate then

            local dlg = VNode("vPaymentDlg.vui")
            gView():Push(dlg);
        else
            gWindow:showWaitTip()
            gReq:MsgReqDungeonPurchase(self, "ReqDungeonPurchaseBack", delegate, "ReqDungeonPurchaseBack", purchase, levelid);
            
        end
    end
--    self.textLoad.text = "同步本地数据...";
--    gWindow:showWaitTip()
end


function VDungeonInfo:CheckOpenLevelInfoDlg( levelid, purchase )
    -- body
    local levelInfo = self:GetLevelCsvInfo(levelid)
    if purchase == 1 then
        local dlg = VNode("vLevelInfoDlg.vui")
        dlg:SetDlgInfo(levelInfo)
        gView():Push(dlg)
    elseif purchase == 3 then
        local dlg = gView()("levelInfoDlg")
        if dlg then
            dlg:onPush()
        end
    end
end

function VDungeonInfo:ReqDungeonPurchaseBack(result, rsp, req)
    if result == 0 then
        self:ReqDungeonPurchaseSuccess(result, rsp, req)
    else
        self:ReqDungeonPurchaseFail(result, rsp, req)
    end
end


function VDungeonInfo:ReqDungeonPurchaseSuccess(result, rsp, req)
    local levelInfo = self:GetLevelCsvInfo(req.id)

    gData.userInfo.dungeonInfo:SetDungeonInfo(levelInfo.chapter, levelInfo.id, rsp.info.record, rsp.info.online_reward, rsp.info.purchase)
    gData.offlineData:saveOfflineData()
    gData.offlineData:updateLastServerData(rsp.info);
    gWindow:closeWaitTip()

    VCallBack(req.userDelegate, req.userCallBack, result, rsp, req);
end


function VDungeonInfo:ReqDungeonPurchaseFail(result, rsp, req)
--    gWindow:showTip("购买失败", 1);
    gWindow:closeWaitTip()
end

function VDungeonInfo:SendSMS(cost)
--  sendApi()
    gWindow:showWaitTip() 

    PayAtOffLine(tonumber(cost))
    cclog("SendSMS")
end

function VDungeonInfo:ShowBuySuccssDlg(levelid, purchase)
    local levelInfo = self:GetLevelCsvInfo(levelid)
    local csvData = gData:readCsv("dungeon_rewards.csv");

    local lineData = csvData:linesWithRowValue(0, levelInfo.shop[purchase].cardID);

    if not lineData then
        return
    end

    local image, name, quality, desc, data  = gData:getResoureIconByID(lineData[1][1], lineData[1][2])
    local items = {}
    local item = {}
    
    item.thingid = desc.id or data.thingid or data.id
    item.image = image
    item.name = name
    item.count = 1
    item.type = lineData[1][1]
    table.insert(items, item)
    
    local rewardTip = VNode("vRewardTip.vui");
    rewardTip:setItemInfo(items, "goumaichenggong.png");
    rewardTip.level = 30000
    gView():Push(rewardTip);
end

function VDungeonInfo:CreateCardInfo(levelid, purchase)
    local levelInfo = self:GetLevelCsvInfo(levelid)
    local csvData = gData:readCsv("dungeon_rewards.csv");
    -- local lineData = csvData:lineDataWithKey(self.info.shop[self.purchase].cardID);
    local lineData = csvData:linesWithRowValue(0, levelInfo.shop[purchase].cardID);
    
    
    local infos;
    if lineData[1][1] == RES_DATA_TYPE.ResDataTypePlant then
        infos = gData.userInfo.plantInfos.plants
    elseif lineData[1][1] == RES_DATA_TYPE.ResDataTypeArm then
        infos = gData.userInfo.monsterInfo.monsterInfos
    else
        if gPackage == 1000 or gPackage == 1020 then
        gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, 10000);
        gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, 10000);

        local chapterDlg = gView("chapterDlg")
        if chapterDlg then
             chapterDlg("txYuanbaoShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeMoney))
            chapterDlg("txJinbiShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeSunshine))
        end
        end
        return
    end 
     
    local id = 0    
    for key, var in pairs(infos) do
        if string.len(key) <= 5 and tonumber(id) < tonumber(key) then
            id = key
        end
    end
    cclog("~~~~~~~~~~"..id)
    if lineData[1][1] == RES_DATA_TYPE.ResDataTypePlant then
        gData.userInfo.plantInfos:InsertPlant(tonumber(id) + 1, lineData[1][2], 1)
    elseif lineData[1][1] == RES_DATA_TYPE.ResDataTypeArm then
        gData.userInfo.monsterInfo:addMonster(tonumber(id) + 1, lineData[1][2], 1)
    end
end
----关卡商店购买流程end


----根据小关卡id获取所在大关卡id
function VDungeonInfo:GetActInfosID(levelid)
	local csv = gData:readCsv("prop_campaign.csv");
    
    if not csv then
        return 0
    end 
    
    local lineData = csv:lineDataWithKey(levelid);
    
    if not lineData then
        return 0
    end
    
    return lineData[1]
end

----根据小关卡id获取本小关卡星星
function VDungeonInfo:GetLevelRecord(levelid)

    local actInfosID = self:GetActInfosID(levelid)
    if actInfosID and actInfosID ~= 0 then

        if self.actInfos and self.actInfos[actInfosID] then
            local actInfo = self.actInfos[actInfosID]

            if actInfo.campaignInfo and actInfo.campaignInfo[levelid] then

                return actInfo.campaignInfo[levelid].record or 0
        	end
	    end
	end
	
	return 0
end


----根据大关卡id获取本大关卡星星
function VDungeonInfo:GetChapterStar(chapterid)
    if self.actInfos and self.actInfos[chapterid] then
        return self.actInfos[chapterid].starHas or 0
    else
        return 0
    end
end


---判断本小关卡是否开启
function VDungeonInfo:CheckLevelOpen(levelid)
    local chapterid = self:GetActInfosID(levelid)

    local actInfos = self.actInfos
    local chapters = self.chapters
    local chapter = chapters[chapterid]
    
    if not chapter then
        return false
    end
    
    local levels = chapters[chapterid].levels
    local levelInfo = levels[levelid]
    

    if not levels[levelInfo.lockLimit] then
        return true
    elseif actInfos[chapterid] then

        if levelInfo.starLimit == 0 then
            
            local campaignInfo = actInfos[chapterid].campaignInfo[levelInfo.lockLimit]
            if campaignInfo and (campaignInfo.record or 0) > 0 then
            
            else
                
                return false
            end
        else
            
            -- local campaignInfo = actInfos[chapterid].campaignInfo[levelInfo.id]
            -- if campaignInfo and  then--campaignInfo.unLock then

            local campaignInfo = actInfos[chapterid].campaignInfo[levelInfo.lockLimit]
            if campaignInfo and (campaignInfo.record or 0) > 0 and self:GetChapterStar(chapterid) >= levelInfo.starLimit then

            else
                
                return false
            end
        end
    else
        return false
    end

    return true
end


---获取本小关卡商店买过的物品
function VDungeonInfo:GetPurchase(levelid)
    local chapterid = self:GetActInfosID(levelid)

    local actInfos = self.actInfos
    
    if actInfos[chapterid] then
        
        local campaignInfo = actInfos[chapterid].campaignInfo[levelid]
        
        if campaignInfo then
            return campaignInfo.purchase or 0
        end
    else
        return 0
    end

    return 0
end


----根据小关卡id获取本小关卡配置表的关卡数据
function VDungeonInfo:GetLevelCsvInfo(levelid)
    local chapterid = self:GetActInfosID(levelid)

    local chapters = self.chapters
    local chapter = chapters[chapterid]
    
    if not chapter then
        return nil
    end
    
    local levels = chapters[chapterid].levels
    local levelInfo = levels[levelid]

    return levelInfo
end


----根据小关卡id获取存储网络的关卡进度数据
function VDungeonInfo:GetLevelInfo( levelid )
    -- body
    local chapterid = self:GetActInfosID(levelid)

    local actInfos = self.actInfos
    local actInfo = actInfos[chapterid]

    if not actInfo then
        return nil
    end

    local levelInfo = actInfo.campaignInfo[levelid]

    return levelInfo
end


---判断本大关卡是否通关
function VDungeonInfo:CheckChaptersPass(chapterid)
	if self.actInfos and self.actInfos[chapterid] then
        return self.actInfos[chapterid].pass
    else
        return false
	end
end


---获取大关卡中小关卡的按id排序列表
function VDungeonInfo:GetLevelSortList( chapterid )
    -- body
    local chapters = self.chapters
    local chapter = chapters[chapterid]

    if not chapter then
        return nil
    end
    
    local levels = chapters[chapterid].levels

    local sortList = {}

    for k,v in pairs(levels) do
        table.insert(sortList, v)
    end

    table.sort(sortList,
        function(a,b)
            return tonumber(a.id) < tonumber(b.id);
        end);
    
    
    return sortList
end

function VDungeonInfo:SaveFreeGiftToFile()
    local data = {};

    self.shopGifts = (self.shopGifts or 0) + 1

    local shopGifts = {}

    shopGifts.count = self.shopGifts

    table.insert(data,Var(shopGifts));
    
    if #data > 0 then
        data = Var(data);
        local fileName = addUserPath("shopGifts.msg");
        data:SaveFile(fileName);
    end
end

function VDungeonInfo:CheckFreeGiftDlgOpen( levelid )
    -- body
    if not self:CheckExraPackage() then
        return false
    end

    local levelInfo = self:GetLevelCsvInfo(levelid)

    if levelInfo.chapter ~= 1 or levelInfo.id ~= 10101 then
        return false
    end

    if not self.shopGifts then
        self.shopGifts = 0
        if gZoneid and gData.userInfo then
            local var = Var();
            local fileName = addUserPath("shopGifts.msg");

            var:FromFile(fileName, false, false, _VPath.Public);

            if var then
                local iter = VDataIter();
               
                while var:Travel(iter) do
                    local shopGifts = iter:Data();

                    if shopGifts and shopGifts.count then
                        self.shopGifts = shopGifts.count

                        if tonumber(self.shopGifts) >= 2 then
                            return false
                        end
                    end
                end
            end
        end
    end

    return self.shopGifts < 2
end

function VDungeonInfo:OpenFreeGiftDlg( levelid )
    -- body
    local levelInfo = self:GetLevelCsvInfo(levelid)

    local dlg = VNode("vFreeGiftDlg.vui")
    dlg:SetDlgInfo(levelInfo)
    gView():Push(dlg)
end

function VDungeonInfo:CheckShopValid( levelid, purchase )
    -- body
    if not levelid or not purchase then
        return false
    end

    local levelInfo = self:GetLevelCsvInfo(levelid)

    if not levelInfo then
        return false
    end

    if not levelInfo.shop or not levelInfo.shop[purchase] then
        return false
    end
    if gPackage == 1000 or gPackage == 1020 then
    local phoneType = gSys:GetPhoneNet();
    if phoneType == 100 then
        if levelInfo.shop[purchase].isValidYd == 0 then
            return false
        end
    elseif phoneType == 102 then
        if levelInfo.shop[purchase].isValidDx == 0 then
            return false
        end
    elseif phoneType == 101 then
        if levelInfo.shop[purchase].isValidLt == 0 then
            return false
        end
    end
    elseif self:CheckExraPackage() then
        if levelInfo.shop[purchase].isValidOt == 0 then
            return false
        end
    else
        if levelInfo.shop[purchase].isValidSk == 0 then
            return false
        end
    end

    return true
end

function VDungeonInfo:OpenShopDlg( levelid, purchase )
    -- body
    local levelInfo = self:GetLevelCsvInfo(levelid)

    if levelid == self.extraShopid then
        self:SavelevelShopExToFile()
        gWindow:showBattleFaildTip(1, levelInfo, purchase)
        return
    elseif self:CheckExraPackage() and levelInfo.shop[purchase].buyClass == 1 then
        -- gWindow:showBattleFaildTip(1, levelInfo, purchase)
        -- gWindow:showTip("新窗口", 1)
        local dlg = VNode("vExtraShopDlg.vui")
        dlg:SetDlgInfo(levelInfo, purchase)
        gView():Push(dlg)
        return
    elseif levelid ~= self.extraShopid then
        local dlg = VNode("vDungeonShopDlg.vui")
        dlg:SetDlgInfo(levelInfo, purchase)
        gView():Push(dlg)
        return
    -- elseif levelid == self.extraShopid then
    --     self:SavelevelShopExToFile()
    --     gWindow:showBattleFaildTip(1, levelInfo, purchase)
    --     return
    end
end


function VDungeonInfo:CheckShopValidEx( levelid )
    -- body
    if not self:CheckExraPackage() then
        return false
    end

    local shopInfo = self:GetShopExInfo(levelid)

    if not shopInfo then
        return false
    end

    local buyClass = shopInfo.buyClass
    if buyClass ~= 1 then
        return false
    end

    local levelInfo = self:GetLevelCsvInfo(levelid)

    if not levelInfo.shop or 
        (not levelInfo.shop[1] and not levelInfo.shop[2] and not levelInfo.shop[3]) then
        return false
    end

    local rt = self:GetPurchase(levelid)

    if levelInfo.chapter == 1 and 
        (levelid == 10101 or levelid == 10301 or levelid == 10601 or levelid == 10901) and
        rt == 0 then
        return true
    end

    return false
end


function VDungeonInfo:OpenShopDlgEx( levelid, index, viewLevel )

    -- body
    local levelInfo = self:GetLevelCsvInfo(levelid)

    local dlg = VNode("vExtraGiftDlg.vui")

    if viewLevel then
        dlg.level = viewLevel;
    end
    dlg:SetDlgInfo(levelInfo, index)

    gView():Push(dlg)
end

function VDungeonInfo:CheckShop2ValidEx( levelid )
    -- body
    if not self:CheckExraPackage() then
        return false
    end

    local shopInfo = self:GetShopExInfo(levelid)

    if not shopInfo then
        return false
    end
    
    local buyClass = shopInfo.buyClass
    if buyClass ~= 1 then
        return false
    end

    local list = self:GetShopCanBuylist(1, levelid)

    local levelInfo = self:GetLevelCsvInfo(levelid)
    if #list <= 0 then
        return false
    end

    -- local rt = self:GetPurchase(levelid)

    if levelInfo.chapter == 1 and 
        (levelid == 10101 or levelid == 10301 or levelid == 10601 or levelid == 10901) then
        return true
    end

    return false
end

function VDungeonInfo:OpenShop2DlgEx( levelid )
    -- body
    local list = self:GetShopCanBuylist(1, levelid)

    -- local levelInfo = self:GetLevelCsvInfo(levelid)
    if #list <= 0 then
        return
    end

    local dlg = VNode("vExtraGift2Dlg.vui")

    dlg:SetDlgInfo(list, levelid)

    gView():Push(dlg)
end

function VDungeonInfo:GetShopCanBuylist( chapterid, levelid )
    -- body
    local levels = {}

    if not chapterid and not levelid then
        return levels
    end

    local chapter = self.chapters[chapterid]

    if not chapter or not chapter.levels then
        return 
    end

    for k, v in pairs(chapter.levels) do
        local shopInfo = self:GetShopExInfo(k)
        local purchase = self:GetPurchase(k)
        if shopInfo and purchase == 0 and tonumber(k) <= tonumber(levelid) then
            table.insert(levels, k)
        end
    end

    if #levels <= 0 then
        return levels
    end

    table.sort(levels,
        function(a,b)
            return a < b;
        end);

    return levels
end

function VDungeonInfo:GetShopExInfo( levelid )
    -- body
    -- if not self:CheckExraPackage() then
    --     return false
    -- end
    
    local levelInfo = self:GetLevelCsvInfo(levelid)

    if not levelInfo.shop or 
        (not levelInfo.shop[1] and not levelInfo.shop[2] and not levelInfo.shop[3]) then
        return false
    end

    for i = 1, 3 do
        if levelInfo.shop[i] and levelInfo.shop[i].isValidOt == 1 then
            return levelInfo.shop[i], i
        end
    end
end

function VDungeonInfo:CheckExraPackage( ... )
    -- body
    local info = self.dungeon_channelEx[gReq.channelID];
    if info and gData:IsTimeInForce(info[3]) then
       return info;
    end
end

function VDungeonInfo:CheckBattleHelpDlgShow( levelid )
    -- body
    local levelInfo = self:GetLevelCsvInfo(levelid)
    local shopInfo = self:GetShopExInfo(levelid)

    if not shopInfo or not levelInfo then
        return false
    end

    local buyClass = shopInfo.buyClass

    if self:CheckExraPackage() and
        levelInfo.chapter == 1 and
        buyClass == 1 then
        return true
    end

    return false
end

function VDungeonInfo:SavelevelShopExToFile()
    local data = {};

    cclog("self.extraShop.time"..(self.extraShop.time or 1))

    

    self.extraShop.time = self.extraShop.time or gData:currentTime()

    local extraShop = {}

    extraShop.time = self.extraShop.time

    extraShop.hasBuy = self.extraShop.hasBuy or 1



    table.insert(data,Var(extraShop));
    
    if #data > 0 then
        data = Var(data);
        local fileName = addUserPath("levelShop.msg");
        data:SaveFile(fileName);
    end
end

function VDungeonInfo:LoadlevelShopExToFile(parameters)
    if gZoneid and gData.userInfo then

        local var = Var();
        local fileName = addUserPath("levelShop.msg");

        
        var:FromFile(fileName, false, false, _VPath.Public);
        
        
        if not var then return end;
        
        local iter = VDataIter();
           
        while var:Travel(iter) do
            local extraShop = iter:Data();
            
            cclog("load.extraShop.time"..(self.extraShop.time or 2))

            self.extraShop.time = extraShop.time

            cclog("load.extraShop.time"..(self.extraShop.time or 3))

            self.extraShop.hasBuy = extraShop.hasBuy 
        end
    end
end


VRewardInfo = vclass("RewardInfo")

function VRewardInfo:initialize(data)
    if data then
        self:synWithData(data);
    end
end

function VRewardInfo:synWithData(data)
    self.id = data[0]
    self.type = data[1]
    self.effect_id = data[2]
    self.effect_value = data[3]
end

VDungeonShopInfo = vclass("DungeonShopInfo")

function VDungeonShopInfo:initialize(data)
    if data then
        self:synWithData(data);
    end
end

function VDungeonShopInfo:synWithData(data)
    self.id = data[0]
    self.buyTip = data[1]
    self.buyClass = data[2]
    self.cardID = data[3]
    self.isValidYd = data[25]
    self.cardCostYd = data[4]
    self.discountCostYd = data[5]
    self.discountYd = data[6]
    self.shopNameYd = data[7]
    self.isValidSk = data[26]
    self.cardCostSk = data[8]
    self.discountCostSk = data[9]
    self.discountSk = data[10]
    self.shopNameSk = data[11]
    self.isValidDx = data[27]
    self.cardCostDx = data[12]
    self.discountCostDx = data[13]
    self.discountDx = data[14]
    self.shopNameDx = data[15]
    self.isValidLt = data[28]
    self.cardCostLt = data[16]
    self.discountCostLt = data[17]
    self.discountLt = data[18]
    self.shopNameLt = data[19]
    self.isValidOt = data[29]
    self.discountCostOt = data[21]
    self.discountOt = data[22]
    self.cardCostOt = data[23]
    self.shopNameOt = data[24]
    self.isGet = data[20]
end

VHelpInfo = vclass("HelpInfo")

function VHelpInfo:initialize(data)
    if data then
        self:synWithData(data);
    end
end

function VHelpInfo:synWithData(data)
    self.levelid = data[0]
    self.type = data[1]
    self.thingid = data[2]
    self.title = data[3]
    self.desc = data[4]
    self.typeDecs = data[5]
end