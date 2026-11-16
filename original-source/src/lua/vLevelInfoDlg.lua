--require "vStarTipDlg"
require "vDungeonShopDlg"
require "vLevelHelpInfoDlg"

VLevelInfoDlg = VClass("LevelInfoDlg", VMsgBox)

function VLevelInfoDlg:onPush(parameters)
    self("artUp"):play("idle")
    
    self:InitShopCardFace()
    self:InitRewardFace()
    self:ShowOpenCondition()
    self:ShowOther()
end

function VLevelInfoDlg:SetDlgInfo(info)
    
	self.info = info
end

function VLevelInfoDlg:InitShopCardFace(parameters)
    local dungeonInfo = gData.userInfo.dungeonInfo
    local rt = dungeonInfo:CheckShopValid(self.info.id, 3)
    local purchase = dungeonInfo:GetPurchase(self.info.id)

    if not rt then
        self("imgBuy").visible = 0
        return
    end

    if dungeonInfo:CheckExraPackage() and self.info.chapter == 1 and purchase ~= 0 then
        self("imgBuy").visible = 0
        return
    end

    if self.info.shop.count ~= 0 and self.info.shop[3] then

        self("imgBuy").visible = 1
        -- local csvData = gData:readCsv("dungeon_rewards.csv");

        local dungeonReward = dungeonInfo:GetDungeonRewardsCsvData()
        -- local lineData = csvData:lineDataWithKey(self.info.shop[3].cardID);
        -- local lineData = csvData:linesWithRowValue(0, self.info.shop[3].cardID);

        local reward = dungeonReward[self.info.shop[3].cardID]
        
        -- if lineData and lineData[1] then
        --     local image, name, quality, data, dataMain= gData:getResoureIconByID(lineData[1][1], lineData[1][2])
        local card = nil

        for k, v in pairs(reward) do
            card = v
            break
        end

        if card then
            local image, name, quality, data, dataMain= gData:getResoureIconByID(card.type, card.effect_id)

            local desc = (data.description or data.desc) or ""
            if string.len(desc) > 16 then
                self("txdecs").text = string.gsub(stringSub(desc, 1, 16).."...","\\n", "\n");
            else
                self("txdecs").text = string.gsub(desc, "\\n", "\n");
            end

            self("txBuyTitle").text = name
            self("imgItem").image = image
            self("imgCard1").image = "carddiban"..quality..".png" --
            self("imgCard2").image = "carddiban"..quality..".png"

            if dataMain then
                local count = dataMain.level
                -- for var = 1, count do
                --     self("imgStarC"..var).visible = 1
                -- end
                if count > 0 then
                    self("starImg").visible = 1
                    self("txlevel").text = count
                else
                    self("starImg").visible = 0
                end
                
            end

        end
    end
    
    
    if purchase ~= 0 then
        self("btnBuy").visible = 0
        self("imghasBuy").visible = 1
    end
end

function VLevelInfoDlg:InitRewardFace(parameters)
    ----显示普通奖励
    for var = 1, 3 do
        local item = self("imgStarBg"..var)

        --      cclog("~~~~~~~~~~~~~~~~~~~~"..self.info["reward"..var][1].type)
        local reward = self.info["reward"..var]
        cclog("~~~~~~~~~~~~~~~~~~~~"..reward[1].type.."~~~~~~~~~~~~~~~~~~"..reward[1].effect_id)

        local image, name, quality, desc = gData:getResoureIconByID(reward[1].type, reward[1].effect_id)
        if 

            reward[1].type == RES_DATA_TYPE.ResDataTypeArm then
            item("imgReward").image = desc.image.."S.png"
--            item("imgReward").scale = 0.22
        elseif reward[1].type == RES_DATA_TYPE.ResDataTypePlant then
            item("imgReward").image = desc.image.."S.png"
--            item("imgReward").scale = 0.3
        else
            cclog("image   "..image)
            item("imgReward").image = image
        end
        item("txRewardnum").text = self.info["reward"..var][1].effect_value
    end

    ----显示网络奖励
    if self.info.rewardNet then
        local rewardNet1 = self.info.rewardNet[1]
        local rewardNet2 = self.info.rewardNet[2]

        local item = self("imgNetBg")
        local image, name, quality, desc = gData:getResoureIconByID(rewardNet1.type, rewardNet1.effect_id)

        if 

            rewardNet1.type == RES_DATA_TYPE.ResDataTypeArm then
            item("imgReward1").image = desc.image.."S.png"
--            item("imgReward1").scale = 0.22
        elseif rewardNet1.type == RES_DATA_TYPE.ResDataTypePlant then
            item("imgReward1").image = desc.image.."S.png"
--            item("imgReward1").scale = 0.3
        else
            item("imgReward1").image = image
        end

        --        item("imgReward1").image = desc.image.."S.png"
        item("txRewardnum1").text = rewardNet1.effect_value

        if not rewardNet2 then
            --            image = gData:getResoureIconByID(self.info.rewardNet[2].type, self.info.rewardNet[2].effect_id)
            item("imgDReward1").offset = {0,0}
            item("txRewardnum1").layout = "Right"
            item("txRewardnum1").offset = {5,0}
            item("imgDReward2").visible = 0
            item("imgReward2").visible = 0
            item("txRewardnum2").visible = 0
        else
            image, name, quality, desc = gData:getResoureIconByID(rewardNet2.type, rewardNet2.effect_id)
            if 

                rewardNet2.type == RES_DATA_TYPE.ResDataTypeArm then
                item("imgReward2").image = desc.image.."S.png"
                
            elseif rewardNet2.type == RES_DATA_TYPE.ResDataTypePlant then
                item("imgReward2").image = desc.image.."S.png"
                
            else
                item("imgReward2").image = image
            end
            --            item("imgReward2").image = desc.image.."S.png"
            item("txRewardnum2").text = rewardNet2.effect_value
        end
    end


    ----显示相关奖励是否获得
    local levelInfo = gData.userInfo.dungeonInfo:GetLevelInfo(self.info.id)

    if levelInfo then
        for var = 1, levelInfo.record do
            local item = self("imgStarBg"..var)
            for k = 1, var do
                item("imgbgStar"..k).image = "guanqiaxiaoxing1.png"
            end
            item("imgGet").visible = 1
            self("imgStar"..var).image = "guanqiaxiaoxing1.png"
        end
        if levelInfo.record and levelInfo.record ~= 0 then
            if levelInfo.online_reward ~= 0 and levelInfo.online_reward ~= nil then
                self("imgNetBg")("imgGet").visible = 1
                local btGet = self("imgNetBg")("btGet")
                btGet.visible = 0
                btGet.gray = 1
                btGet.touch = 0
                btGet("imgGetz").gray = 1
            else
                self("imgNetBg")("imgGet").visible = 0
                local btGet = self("imgNetBg")("btGet")
                btGet.visible = 1
                btGet.gray = 0
                btGet.touch = 1
                btGet("imgGetz").gray = 0
            end
        end
    end
end

function VLevelInfoDlg:ShowOpenCondition( )
    -- body
    local limitInfo = gData.userInfo.dungeonInfo:GetLevelInfo(self.info.lockLimit)

    local limitCsvInfo = gData.userInfo.dungeonInfo:GetLevelCsvInfo(self.info.lockLimit)

    if (self.info.lockLimit ~= 0 and limitCsvInfo) and 
        self.info.starLimit == 0 and 
        (not limitInfo or limitInfo.record == 0) and 
        gData.userInfo.dungeonInfo:GetActInfosID(self.info.id) == self.info.chapter then
        
        local btnChallenge = self("btnChallenge")
        btnChallenge.touch = 0
        btnChallenge.gray = 1
        btnChallenge("txChallenge").color = {255,255,255}
--                self("imgBuy").visible = 0
        self("txlimit").text = "通过"..limitCsvInfo.name.."可挑战"
        self("txlimit").visible = 1
    end
end

function VLevelInfoDlg:ShowOther( ... )
    -- body
    if self.info.type == 3 then
        self("txChapter").text = "进攻模式"
        self("txChapter").color = "fc_10_"
        self("imgChapter").image = "guanqiaxiangqingtu2.png"
        self("btnChallenge").image = "jingonganniu1.png"
    else
        self("txChapter").text = "防守模式"
        self("txChapter").color = "fc_14_"
    end
    
    if self.info.rewardNetID == 0 then
        self("imgNetBg").visible = 0
        self("imgStarBg1").offset = {70,-59}
        self("imgStarBg2").offset = {70,-13}
        self("imgStarBg3").offset = {70,33}
    end
    
    self("txTitle").text = self.info.name--chapters[self.info.chapter].name.." "..(math.floor(tostring(self.info.id) / 100) % 100)
end

function VLevelInfoDlg:Challenge(parameters)
--    local actInfos = gData.userInfo.dungeonInfo.actInfos
--    local campaignInfo = self:GetCampaignInfo()
--    if (not campaignInfo or campaignInfo.purchase == 0) and self.info.shop and self.info.shop[1] then
--        local dlg = VNode("vDungeonShopDlg.vui")
--        dlg:SetDlgInfo(self.info, 1)
--        gView():Push(dlg)
--        return
--    end
    
--    if actInfos[self.info.chapter] and actInfos[self.info.chapter].starHas then
    
    local starHas = gData.userInfo.dungeonInfo:GetChapterStar(self.info.chapter)
    
    -- cclog("self.info.starLimit"..self.info.starLimit)

    if self.info.starLimit > starHas then
        --            gWindow:showConfirmTip("当前关卡需要"..self.info.starLimit.."星星才可解锁,请继续收集星星", nil, nil, nil, nil, "", "提示");
--        local normalTip = VNode("vNormalTip.vui")
--        normalTip:initTip("提示", "当前关卡需要"..self.info.starLimit.."星星才可解锁,请继续收集星星")
        gWindow:showNormalTip("当前关卡需要"..self.info.starLimit.."星星才可解锁,请继续收集星星", "提示")
--        gView():Push(normalTip)
        return
--    elseif self.info.starLimit ~= 0 then
--        
--            if not gData.userInfo.dungeonInfo:CheckLevelOpen(self.info.id) then
--                if not gData.offlineData.offline then
--                gData.userInfo.dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id, nil, nil, nil, true)
--                gData.offlineData:saveOfflineData()
--                
--                    local data = gData.offlineData:getDeltaOfflineData()
--                    gReq:MsgReqDungeonReport(self, "ReqUnLockLevelBack", data, self.info.chapter, self.info.id)
--                    gWindow:showWaitTip()
--                else
--                    gWindow:showTip("该关卡需要联网解锁", 1)
--                end
--                
--                return
--            end
        
        
    end
--    end
    
    if self.info.needNet == 1 and gData.offlineData.offline then
        
    
        gWindow:showConfirmTip("当前关卡需要在联网模式下进行挑战", "联网", "取消", gWindow, "jumpToLoginView", "", "提示");
        return
    end
        
	if gMainView then
        gData.userInfo.dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id)
        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);
    end
end

function VLevelInfoDlg:ReqUnLockLevelBack(result, rsp, req)
    if result == 0 then
        gData.offlineData:updateLastServerData(rsp.info);
        self("imgOKPlantDefO").image = ""
        gView()("levelDlg")("lylevel"..self.info.id)("imgsuo").visible = 0
    else
        gWindow:showTip("解锁失败", 1)
    end
    
    gWindow:closeWaitTip()
end

function VLevelInfoDlg:GetNetReward(parameters)
	if gData.offlineData.offline then
	    gWindow:showTip("必须联网才能获取", 1)
	else
        gWindow:showWaitTip()
        gReq:MsgReqDungeonOnlineReward(self, "ReqDungeonOnlineRewardBack", self.info.id)
        
	end
end

function VLevelInfoDlg:ReqDungeonOnlineRewardBack(result, rsp, req)
    if result == 0 then
        self:ReqDungeonOnlineRewardSuccess(rsp, req)
    else
        self:ReqDungeonOnlineRewardFail(result, rsp, req)
    end
end


function VLevelInfoDlg:ReqDungeonOnlineRewardSuccess(rsp, req)
    gData.userInfo.dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id, rsp.info.record, rsp.info.online_reward, rsp.info.purchase )
    gData.offlineData:saveOfflineData()
--    self("imgNetBg")("txGet").text = "已获得"
    self("imgNetBg")("imgGet").visible = 1
                    self("imgNetBg")("btGet").visible = 0
    gData.offlineData:updateLastServerData(rsp.info);
    
    gWindow:showNormalTip("成功领取网络奖励", "")
    
    gWindow:closeWaitTip()
end


function VLevelInfoDlg:ReqDungeonOnlineRewardFail(result, rsp, req)
    gWindow:showTip("领取失败", 1);
    gWindow:closeWaitTip()
end

function VLevelInfoDlg:OpenHelp(parameters)
    local dlg = VNode("vLevelHelpInfoDlg.vui")
    dlg:SetShowType(self.info.type)
    gView():Push(dlg)
end

function VLevelInfoDlg:OpenDungeonShop(parameters)
    local dungeonInfo = gData.userInfo.dungeonInfo
    local purchase = dungeonInfo:GetPurchase(self.info.id)
    if purchase == 0 then
    
        -- local dlg = VNode("vDungeonShopDlg.vui")
        -- dlg:SetDlgInfo(self.info, 3)
        -- gView():Push(dlg)
        dungeonInfo:OpenShopDlg(self.info.id, 3)
    else
        gWindow:showTip("此物品已买过", 1)
    end
end

function VLevelInfoDlg:onClose(parameters)
    VLevelInfoDlg.super.onClick(self)
end