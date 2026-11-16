VDungeonShopDlg = VClass("DungeonShopDlg", VMsgBox)

function VDungeonShopDlg:onPush(parameters)
    self("artUp"):play("idle")
    
    self:InitCostInfo()
    
    gData.userInfo.dungeonInfo.purchaseShow = false
    
    self.txDexGiftsO1 = self("txDexGiftsO1")
    self.txDexGiftsO2 = self("txDexGiftsO2")
    self.txDexGiftsO3 = self("txDexGiftsO3")
    self.txdescribe = self("txdescribe")
    
    if tonumber(self.discount) < 10 then
        self("txdescribe2").text = self.discount.."折优惠"
        self.txDexGiftsO3.text = "价       格 : "..formatPrice(self.cardCost).."元 → "..formatPrice(self.discountCost).."元"
        self("txSellGiftsO1").text = "充值"..formatPrice(self.discountCost).."元购买"
    else
        self("txdescribe2").visible = 0
        self("txdescribe3").visible = 0
       
        self.txDexGiftsO3.text = "价       格 : "..formatPrice(self.cardCost).."元"
        self("txSellGiftsO1").text = "充值"..formatPrice(self.cardCost).."元购买"
    end
    
    local image, name, quality, data  = self:GetResoureInfo()
    
    self("imgDexGiftsO").image = image
   
   local desc = (data.description or data.desc) or ""
    self.txdescribe.text = string.gsub(desc,"\\n", "\n");
    
    

    self("txTitle").text = self.shopName--self:GetPurchaseName(quality)
    self.txDexGiftsO1.text = "商品名称 : "..self.shopName--self:GetPurchaseName(quality)

    self.txDexGiftsO2.text = "物品名称 : "..name
end

function VDungeonShopDlg:InitCostInfo(parameters)
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

function VDungeonShopDlg:GetPurchaseName(quality)
	local csvData = gData:readCsv("dungeon_rewards.csv");
    local lineData = csvData:lineDataWithKey(self.info.shop[self.purchase].cardID);
            
--        cclog("~~~~~~~~~~~`"..lineData[1].."~~~~~~~~~~~~~~~~~~~"..lineData[2])
    local str1 = "金色"
    if quality == 1 then
        str1 = "白色"
    elseif quality == 2 then
        str1 = "绿色"
    elseif quality == 3 then
        str1 = "蓝色"
    elseif quality == 4 then
        str1 = "紫色"
    end
    
    
    local str2 = "僵尸"
    if lineData[1] == RES_DATA_TYPE.ResDataTypePlant then
--        return gData:getResoureIconByID(lineData[1], lineData[2])
        str2 = "植物"
    end
    
    return str1..str2
end

function VDungeonShopDlg:SetDlgInfo(info, purchase)
    self.info = info
    self.purchase = purchase
end

function VDungeonShopDlg:GetResoureInfo()
	local csvData = gData:readCsv("dungeon_rewards.csv");
    -- local lineData = csvData:lineDataWithKey(self.info.shop[self.purchase].cardID);
    local lineData = csvData:linesWithRowValue(0, self.info.shop[self.purchase].cardID);

            if lineData then
        -- cclog("~~~~~~~~~~~`"..lineData[1].."~~~~~~~~~~~~~~~~~~~"..lineData[2])
        return gData:getResoureIconByID(lineData[1][1], lineData[1][2])
            end
            return "", ""
end

function VDungeonShopDlg:CheckBuy(  )
    local csv = gData:readCsv("dungeon_channelEx2.csv");
    local lineData = csv:lineDataWithKey(gReq.channelID);
    if lineData and lineData[1] == 1 then
        local cost = self.cardCost

        if tonumber(self.discount) < 10 then
            cost = self.discountCost
        end
        gWindow:showConfirmTip("消费"..cost.."元话费购买", "确定", "取消", self, "onBuyClick");
    else
        self:onBuyClick();
    end
end


function VDungeonShopDlg:onBuyClick()
    local dungeonInfo = gData.userInfo.dungeonInfo

    
    cclog("VDungeonShopDlg:onBuyClick");
    
    local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end

    dungeonInfo:ShopBuyClick(self.info.id, self.purchase, cost, self)
end

function VDungeonShopDlg:onClose(parameters)

    local dungeonInfo = gData.userInfo.dungeonInfo

    dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    -- dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)

    -- self:CheckOpenLevelInfoDlg()
    
    VDungeonShopDlg.super.onClick(self)
end

-- function VDungeonShopDlg:CheckOpenLevelInfoDlg( ... )
--     -- body
--     if self.purchase ~= 3 and self.purchase ~= 2 then
--         local dlg = VNode("vLevelInfoDlg.vui")
--         dlg:SetDlgInfo(self.info)
--         gView():Push(dlg)
--     end
-- end

function VDungeonShopDlg:ReqDungeonPurchaseBack(result, rsp, req)
    if result == 0 then
        self:ReqDungeonPurchaseSuccess(rsp, req)
    else
        self:ReqDungeonPurchaseFail(result, rsp, req)
    end
end


function VDungeonShopDlg:ReqDungeonPurchaseSuccess(rsp, req)
    -- gData.userInfo.dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id, rsp.info.record, rsp.info.online_reward, rsp.info.purchase)
    -- gData.offlineData:saveOfflineData()
    -- gData.offlineData:updateLastServerData(rsp.info);
    -- gWindow:closeWaitTip()

    local dungeonInfo = gData.userInfo.dungeonInfo

    dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
    
    self:doPop()
end


function VDungeonShopDlg:ReqDungeonPurchaseFail(result, rsp, req)
--    gWindow:showTip("购买失败", 1);
    gWindow:closeWaitTip()
end

function VDungeonShopDlg:SendSMSBack(result)
--    self:ShowBuySuccssDlg()
local dungeonInfo = gData.userInfo.dungeonInfo
	if result or (gPackage ~= 1006 and self.info.shop[self.purchase].isGet == 1) then
        dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id, nil, nil, self.purchase)
        cclog("CreateCardInfo")

        gData.offlineData:saveOfflineData()
        
        
        if not gData.offlineData.offline then
            local data = gData.offlineData:getDeltaOfflineData()
            if next(data) then
                gReq:MsgReqDungeonReport(self, "ReqDungeonReportBack", data, self.info.chapter, self.info.id)
                return
            end
        else
            -- self:CreateCardInfo()   
            dungeonInfo:CreateCardInfo(self.info.id, self.purchase)   
        end
        
        
--        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);
        
        

    dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)

        -- self:CheckOpenLevelInfoDlg()
        
        -- self:ShowBuySuccssDlg()
	else
        
--        gWindow:showTip("购买失败", 1);


    dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    -- dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)

    --     self:CheckOpenLevelInfoDlg()
	end
	
    gWindow:closeWaitTip()
    self:doPop()
end

function VDungeonShopDlg:ReqDungeonReportBack(result, rsp, req)
	if result == 0 then
        local dungeonInfo = gData.userInfo.dungeonInfo
        local campaignInfo = dungeonInfo.actInfos[self.info.chapter].campaignInfo[self.info.id]
        gData.offlineData:updateLastServerData(campaignInfo);
--        gWindow:showTip("购买成功", 1);
        
        
        

        dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
	else
	    
	end
	
    gWindow:closeWaitTip()
    self:doPop()
end


