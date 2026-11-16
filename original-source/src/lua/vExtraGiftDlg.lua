VExtraGiftDlg = VClass("ExtraGiftDlg", VMsgBox)

function VExtraGiftDlg:onPush( ... )
    self:InitCostInfo()

    local dungeonInfo = gData.userInfo.dungeonInfo
    local dungeonReward = dungeonInfo:GetDungeonRewardsCsvData()
        -- local lineData = csvData:lineDataWithKey(self.info.shop[3].cardID);
        -- local lineData = csvData:linesWithRowValue(0, self.info.shop[3].cardID);

    local reward = dungeonReward[self.info.shop[self.purchase].cardID]

    for k, v in pairs(reward) do
            card = v
            break
        end

        if card then
            local image, name, quality, data, dataMain= gData:getResoureIconByID(card.type, card.effect_id)
            self("imgItemPlantC").image = image

            self("txname").text = name

            if dataMain.level > 0 then
                self("imgStarC").visible = 1
                self("txlevel").text = dataMain.level
            end

            self("cardImg").image = "carddiban"..quality..".png"
        end

    local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end

    self("txdescribed").text = "确定后"..formatPrice(cost).."元购买获得"
    self("txTime").text = "5秒自动关闭后不会获得卡牌"
    self.time = 5
    self:StartTimer("UpdataExtraTime", 1, 4, 1);
end

function VExtraGiftDlg:SetDlgInfo( info, index )
    -- body
    self.info = info
end



function VExtraGiftDlg:UpdataExtraTime( ... )
    -- body
    self.time = self.time - 1
    if self.time > 0 then
        self("txTime").text = self.time.."秒自动关闭后不会获得卡牌"
    else
        self:StopTimer("UpdataExtraTime")
        self:onClose()
    end
end

function VExtraGiftDlg:InitCostInfo(parameters)
    local dungeonInfo = gData.userInfo.dungeonInfo
    local shopInfo = nil
    shopInfo, self.purchase = dungeonInfo:GetShopExInfo(self.info.id)

    local costInfo = gData:GetLevelCostInfo(self.info, self.purchase)

    if not costInfo then
        return false
    end

    self.discountCost = costInfo.discountCost
        self.discount = costInfo.discount
        self.cardCost = costInfo.cardCost
        self.shopName = costInfo.shopName

    cclog("self.discountCost~~~~~~~~~~~~~"..(self.discountCost or -1))
    cclog("self.discount~~~~~~~~~~~~~"..(self.discount or -1))
    cclog("self.cardCost~~~~~~~~~~~~~"..(self.cardCost or -1))
    cclog("self.shopName~~~~~~~~~~~~~"..(self.shopName or -1))
    cclog("gPackage~~~~~~~~~~~~~"..(gPackage or -1))

end

function VExtraGiftDlg:onOK( ... )
    -- body
    self:StopTimer("UpdataExtraTime")
    local dungeonInfo = gData.userInfo.dungeonInfo

    if dungeonInfo:GetPurchase(self.info.id) == 0 then
        -- self.index
        local cost = self.cardCost

        if tonumber(self.discount) < 10 then
            cost = self.discountCost
        end
        
        dungeonInfo:ShopBuyClick(self.info.id, self.purchase, cost, self)
    else
        self:CheckOpenLevelInfoDlg()
         self:doPop()
    end
end

function VExtraGiftDlg:onClose(parameters)
    if gBattleView then
        VCallBack(gBattleView, "exitBattle");
    end
end

function VExtraGiftDlg:ReqDungeonPurchaseBack( result )
    -- body
    if result == 0 then
        self:CheckOpenLevelInfoDlg()
        local dungeonInfo = gData.userInfo.dungeonInfo
        dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
    end

    self:doPop()
end

function VExtraGiftDlg:SendSMSBack(result)
--    self:ShowBuySuccssDlg()
    local dungeonInfo = gData.userInfo.dungeonInfo
    if result or (gPackage ~= 1006 and self.info.shop[self.purchase].isGet == 1) then
        dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id, nil, nil, self.purchase)

        gData.offlineData:saveOfflineData()
        
        
        if not gData.offlineData.offline then
            local data = gData.offlineData:getDeltaOfflineData()
            if next(data) then
                gReq:MsgReqDungeonReport(self, "ReqDungeonReportBack", data, self.info.chapter, self.info.id)
                return
            end
        else
            dungeonInfo:CreateCardInfo(self.info.id, self.purchase)   
        end
        
        
--        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);

        self:CheckOpenLevelInfoDlg()
        
        dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
    else
        
--        gWindow:showTip("购买失败", 1);


        self:CheckOpenLevelInfoDlg()
    end
    
    gWindow:closeWaitTip()
    self:doPop()
end

function VExtraGiftDlg:ReqDungeonReportBack(result, rsp, req)
    if result == 0 then
        local dungeonInfo = gData.userInfo.dungeonInfo
        local campaignInfo = dungeonInfo.actInfos[self.info.chapter].campaignInfo[self.info.id]
        gData.offlineData:updateLastServerData(campaignInfo);
--        gWindow:showTip("购买成功", 1);
        self:CheckOpenLevelInfoDlg()
        
        dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
    else
        
    end
    
    gWindow:closeWaitTip()
    self:doPop()
end

function VExtraGiftDlg:CheckOpenLevelInfoDlg( ... )
    -- body
    if self.info then
        local dlg = gView()("levelDlg")
        if dlg then
            dlg:OpenLevelInfoDlg(self.info)
        end
    end
end