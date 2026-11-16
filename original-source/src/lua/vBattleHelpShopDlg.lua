VBattleHelpShopDlg = VClass("BattleHelpShopDlg", VMsgBox)

function VBattleHelpShopDlg:onPush( ... )
	-- body
	self:InitCostInfo()

	local csvData = gData:readCsv("dungeon_rewards.csv");

    local lineData = csvData:linesWithRowValue(0, self.info.shop[self.purchase].cardID);

    if not lineData then
        return
    end

    local info = lineData[1]

    local image, name, quality, desc, data  = gData:getResoureIconByID(info[1], info[2])

	-- local image, name, quality, desc = gData:getResoureIconByID(self.battleHelp[self.page].type, self.battleHelp[self.page].thingid)

	if self.amt then
		self.amt:doPop()
	end

		self.amt = VArmature{jsonName = desc.image, animation="idle", layout="Center"};
		self.amt.scale = self:getAmtSpeedAndScale(desc.image)
		self.amt.scale = gData:GetFitScale(self.amt, self("imgDexDGiftsO"))

    	self("imgDexDGiftsO"):Push(self.amt);


	self("txDexGiftsO1").text = name--self.battleHelp[self.page].title

	-- local decs = self.battleHelp[self.page].desc
	-- if decs and decs ~= "" then
	-- 	self("txdescribe").text = decs
	-- else
	-- 	local skill = self:GetSkillchange(self.battleHelp[self.page].type, self.battleHelp[self.page].thingid)
	-- 	self("txdescribe").text = string.gsub(skill,"\\n", "\n")

	-- end
    local desc = (desc.description or desc.desc) or ""
    self("txdescribe").text = string.gsub(desc,"\\n", "\n");

	-- self("txDexd").text = self.battleHelp[self.page].typeDecs
	local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end

    self("txdescribed").text = "确定后将从您话费账户扣除"..cost.."元(运营商合作,不含通讯费)"
end

function VBattleHelpShopDlg:InitCostInfo()
	local dungeonInfo = gData.userInfo.dungeonInfo
	local shopInfo, purchase = dungeonInfo:GetShopExInfo(self.info.id)

	self.purchase = purchase

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

    return true
end

function VBattleHelpShopDlg:GetSkillchange(type, id)
	local skillchange
	if type == RES_DATA_TYPE.ResDataTypePlant then

    	skillchange = gData:readCsv("plant_upstar_skillchange.csv");
    else

    	skillchange = gData:readCsv("monster_upstar_skillchange.csv");
    end

    local skill = skillchange:lineDataWithKey(self.battleHelp[self.page].thingid);
    cclog("self.thingid"..self.battleHelp[self.page].thingid)
    if not skill then
        return
    end
    return skill[2] or ""
end

function VBattleHelpShopDlg:getAmtSpeedAndScale(image)
    local speed, scale;
    local acCsv = gData:readCsv("animation_creature.csv");
    scale = acCsv:lineDataWithKey(image,2)/ 100 or 1;
    speed = acCsv:lineDataWithKey(image,5)/100 or 1;
    return scale;
end

function VBattleHelpShopDlg:SetInfo( info )
	-- body
	self.info = info
end



function VBattleHelpShopDlg:onClose( ... )
	if self.delegate and self.callBack then
		VCallBack(self.delegate, self.callBack);
	end
	VBattleHelpShopDlg.super.onClick(self)
end

function VBattleHelpShopDlg:onClick( ... )
	
end

function VBattleHelpShopDlg:onOK( ... )
	-- body
	cclog("VExtraShopDlg:onBuyClick");
    
    local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end

    local dungeonInfo = gData.userInfo.dungeonInfo

    dungeonInfo:ShopBuyClick(self.info.id, self.purchase, cost, self)
end


function VBattleHelpShopDlg:ReqDungeonPurchaseBack(result, rsp, req)
    if result == 0 then
        self:ReqDungeonPurchaseSuccess(rsp, req)
    else
        self:ReqDungeonPurchaseFail(result, rsp, req)
    end
end


function VBattleHelpShopDlg:ReqDungeonPurchaseSuccess(rsp, req)
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

    -- dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
    
    self:onClose()
end


function VBattleHelpShopDlg:ReqDungeonPurchaseFail(result, rsp, req)
--    gWindow:showTip("购买失败", 1);
    gWindow:closeWaitTip()
end


function VBattleHelpShopDlg:SendSMSBack(result)
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
    --      dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

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
         -- dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)
	end
	
    gWindow:closeWaitTip()
    self:onClose()
end

function VBattleHelpShopDlg:ReqDungeonReportBack(result, rsp, req)
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
         -- dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

        dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
	else
	    
	end
	
    gWindow:closeWaitTip()
    self:onClose()
end