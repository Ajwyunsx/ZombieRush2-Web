VExtraShopDlg = VClass("ExtraShopDlg", VMsgBox)

function VExtraShopDlg:onPush( ... )
	self("artUp"):play("idle")
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

            self("imgDex").image = image

            local desc = (data.description or data.desc) or ""
    		self("txDexd").text = string.gsub(desc,"\\n", "\n");

    		self("txnamed").text = name
        end

    local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end

    self("txdescribed").text = "确定后将从您话费账户扣除"..formatPrice(cost).."元(运营商合作,不含通讯费)"
end

function VExtraShopDlg:SetDlgInfo(info, purchase)
    self.info = info
    self.purchase = purchase
end

function VExtraShopDlg:InitCostInfo()

    local costInfo = gData:GetLevelCostInfo(self.info, self.purchase)

    if not costInfo then
        return false
    end
    -- if not info.shop[2] then
    --     return false
    -- end

    -- local shop = info.shop[2]

    -- if gPackage == 1000 then
    --     self.discountCost = shop.discountCostYd
    --     self.discount = shop.discountYd
    --     self.cardCost = shop.cardCostYd
    --     self.shopName = shop.shopNameYd
    -- elseif gPackage == 1001 then
    --    self.discountCost = shop.discountCostDx
    --     self.discount = shop.discountDx
    --     self.cardCost = shop.cardCostDx
    --     self.shopName = shop.shopNameDx
    -- elseif gPackage == 1002 then
    --     self.discountCost = shop.discountCostLt
    --     self.discount = shop.discountLt
    --     self.cardCost = shop.cardCostLt
    --     self.shopName = shop.shopNameLt
    -- else
    --     self.discountCost = shop.discountCostSk
    --     self.discount = shop.discountSk
    --     self.cardCost = shop.cardCostSk
    --     self.shopName = shop.shopNameSk
    -- end

    self.discountCost = costInfo.discountCost
        self.discount = costInfo.discount
        self.cardCost = costInfo.cardCost
        self.shopName = costInfo.shopName

    cclog("self.discountCost~~~~~~~~~~~~~"..(self.discountCost or -1))
    cclog("self.discount~~~~~~~~~~~~~"..(self.discount or -1))
    cclog("self.cardCost~~~~~~~~~~~~~"..(self.cardCost or -1))
    cclog("self.shopName~~~~~~~~~~~~~"..(self.shopName or -1))
    cclog("gPackage~~~~~~~~~~~~~"..(gPackage or -1))

    return true
end

function VExtraShopDlg:CheckBuy( ... )
	-- body
	local dungeonInfo = gData.userInfo.dungeonInfo
    local info = dungeonInfo:CheckExraPackage();
	if info[1] == 1 then
		local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end
		gWindow:showConfirmTip("消费"..cost.."元话费购买", "确定", "取消", self, "onBuyClick");
	else
		self:onBuyClick()
	end
end

function VExtraShopDlg:onBuyClick()
    cclog("VExtraShopDlg:onBuyClick");
    
    local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end

    local dungeonInfo = gData.userInfo.dungeonInfo

    dungeonInfo:ShopBuyClick(self.info.id, self.purchase, cost, self)
    
    -- cclog("self.info.shop[self.purchase].buyClass~~~~~~~~~~~~~"..self.info.shop[self.purchase].buyClass)

    -- if self.info.shop[self.purchase].buyClass == 1 and 
    --     gRes:Platform() ~= "ios" and 
    --     gRes:Platform() ~= "mac" then
    --     --duanxin
        
    --      cclog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
    --     self:SendSMS(cost)
        
    -- else
    --     if gData.offlineData.offline then
    --         -- local normalTip = VNode("vNormalTip.vui")
    --         -- normalTip:initTip("提示", "单机模式不支持第三方支付")
    --         -- gView():Push(normalTip)
    --         cclog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~2")
    --         gWindow:showNormalTip("单机模式不支持第三方支付", "提示")
    --         return
    --     end
        
    --     local YB = gData:attrValue(AttrType.AttrTypeCurrency)
        
        
    --     cclog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~3")
    --     if YB < cost * gResRate then
    --         cclog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~4")
    --         -- gWindow:showMoneyLackDlg(cost)
    --         local dlg = VNode("vPaymentDlg.vui")
    --         gView():Push(dlg);
    --     else
    --         cclog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~5")
    --         gWindow:showWaitTip()
    --         gReq:MsgReqDungeonPurchase(self, "ReqDungeonPurchaseBack", self.purchase, self.info.id);
            
    --     end
    -- end
--    self.textLoad.text = "同步本地数据...";
--    gWindow:showWaitTip()
end

function VExtraShopDlg:onClose(parameters)
--    if self.purchase ~= 3 and self.purchase ~= 2 then
--        gData.userInfo.dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id)
--        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);     
--    end
    -- if self.purchase ~= 3 and self.purchase ~= 2 then
    --     local dlg = VNode("vLevelInfoDlg.vui")
    --     dlg:SetDlgInfo(self.info)
    --     gView():Push(dlg)
    -- end
    -- self:CheckOpenLevelInfoDlg()
    local dungeonInfo = gData.userInfo.dungeonInfo

    dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)
    
    VExtraShopDlg.super.onClick(self)
end


function VExtraShopDlg:ReqDungeonPurchaseBack(result, rsp, req)
    if result == 0 then
        self:ReqDungeonPurchaseSuccess(rsp, req)
    else
        self:ReqDungeonPurchaseFail(result, rsp, req)
    end
end


function VExtraShopDlg:ReqDungeonPurchaseSuccess(rsp, req)
    -- gData.userInfo.dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id, rsp.info.record, rsp.info.online_reward, rsp.info.purchase)
    -- gData.offlineData:saveOfflineData()
    -- gData.offlineData:updateLastServerData(rsp.info);
    -- gWindow:closeWaitTip()
--     if self.purchase ~= 3 and self.purchase ~= 2 then
-- --        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);
--         local dlg = VNode("vLevelInfoDlg.vui")
--         dlg:SetDlgInfo(self.info)
--         gView():Push(dlg)
--     end
    -- self:CheckOpenLevelInfoDlg()

    -- self:ShowBuySuccssDlg()
    local dungeonInfo = gData.userInfo.dungeonInfo

    dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
    
    self:doPop()
end


function VExtraShopDlg:ReqDungeonPurchaseFail(result, rsp, req)
--    gWindow:showTip("购买失败", 1);
    gWindow:closeWaitTip()
end


function VExtraShopDlg:SendSMSBack(result)
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
        -- if self.purchase ~= 3 and self.purchase ~= 2 then
        --     --        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);
        --     local dlg = VNode("vLevelInfoDlg.vui")
        --     dlg:SetDlgInfo(self.info)
        --     gView():Push(dlg)
        -- end
        -- self:CheckOpenLevelInfoDlg()
        
        -- self:ShowBuySuccssDlg()
         dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
	else
        
--        gWindow:showTip("购买失败", 1);
        -- if self.purchase ~= 3 and self.purchase ~= 2 then
        --     --        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);
        --     local dlg = VNode("vLevelInfoDlg.vui")
        --     dlg:SetDlgInfo(self.info)
        --     gView():Push(dlg)
        -- end

        -- self:CheckOpenLevelInfoDlg()
         dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)
	end
	
    gWindow:closeWaitTip()
    self:doPop()
end

function VExtraShopDlg:ReqDungeonReportBack(result, rsp, req)
	if result == 0 then
        local dungeonInfo = gData.userInfo.dungeonInfo
        local campaignInfo = dungeonInfo.actInfos[self.info.chapter].campaignInfo[self.info.id]
        gData.offlineData:updateLastServerData(campaignInfo);
--        gWindow:showTip("购买成功", 1);
        
        
        
        -- if self.purchase ~= 3 and self.purchase ~= 2 then
        --     --        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);
        --     local dlg = VNode("vLevelInfoDlg.vui")
        --     dlg:SetDlgInfo(self.info)
        --     gView():Push(dlg)
        -- end

        -- self:CheckOpenLevelInfoDlg()
        
        -- self:ShowBuySuccssDlg()
        dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

        dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
	else
	    
	end
	
    gWindow:closeWaitTip()
    self:doPop()
end
