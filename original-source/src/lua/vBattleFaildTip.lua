--vBattleFaildTip.lua

VBattleFaildTip = VClass("BattleFaildTip", VMsgBox);

function VBattleFaildTip:onPush()
	self:updateTitle();
	self:updateCostBtn();
	self:updateTipText();

    if self.tipid == 1 then 
        self("centerImg").image = "guanggaobeijing1.jpg";
        if self.info.shop[self.purchase].buyClass == 2 then
            self.timeCheck = gDtr:getScheduler():scheduleScriptFunc( 
                    function () VCallBack(self, "OnTime"); end, 5, false);
        end
    elseif self.tipid == 2 then
        self("centerImg").image = "guanggaobeijing2.jpg";
    elseif self.tipid == 3 then
        self("centerImg").image = "guanggaobeijing3.jpg";
    elseif self.tipid == 4 then
        self("centerImg").image = "guanggaobeijing4.jpg";
    end

	self.tbv = self("tbv");
	self.listInfo = {};
	self.tbv:setTouchEnabled(false);
	self.tbv.delegate = self;
end

function VBattleFaildTip:onPushFinish(  )
	self:InitData();
	self.tbv.number = #self.listInfo;
	self.tbv:setViewSize(cc.size(230, self.tbv.number*52));
	self.tbv:reloadData();
end

function VBattleFaildTip:close(  )
	if self.info then 
		self:onExtraShopClose();
	end
	self:doPop();
end

function VBattleFaildTip:onClick( ... )
    -- body
end


function VBattleFaildTip:InitData(  )
	local csv = gData:readCsv("advertisement.csv");
	self.listInfo = csv:linesWithRowValue(0, self.tipid);
	table.sort(self.listInfo, function(a,b)
		return a.sortLevel < b.sortLevel;
	end)
end

function VBattleFaildTip:onCell( idx, t, cell )
	idx = idx + 1;
	local info = self.listInfo[idx];
	if info.itemType == 1 then
		if info.itemid == 1 then
            cell("itemIcon").image = "mv_daifu.png";
		elseif info.itemid == 2 then
            cell("itemIcon").image = "jiangshichouka2.png";
		elseif info.itemid == 3 then
            cell("itemIcon").image = "lan.png";
        else
            cell("itemIcon").image = "battleGround6.png";
		end
	else
		cell("itemIcon").image = gData:getResoureIconByID(info.itemType, info.itemid);
	end
	cell("firstTip").text = info.firstTip;
	cell("secondTip").text = info.secondTip;

	if info.canClick == 1 then
		cell("iconLayer").onClick = "ShowItemInfoDlg("..info.itemType..","..info.itemid..")";
	end
end

--更新标题
function VBattleFaildTip:updateTitle(  )
	if self.tipid == 1 then 
		self:InitCostInfo()
		self("titleText").text = self.discount.."折超优惠"
	elseif self.tipid == 2 then
        self("titleText").text = "开通VIP1";
	elseif self.tipid == 3 then
        self("titleText").text = "开通VIP3";
	elseif self.tipid == 4 then
        self("titleText").text = "开通VIP5";
	end
end

--更新提示文字
function VBattleFaildTip:updateTipText(  )
	if self.tipid == 1 then 
		local timeSpace = gData:currentTime() - (gData.userInfo.dungeonInfo.extraShop.time or 0)
        local timeLimit = gData.userInfo.dungeonInfo.timeLimit
    	if timeSpace < timeLimit then
    		cclog("EEEEEEEEEEEEEEEEEEE")
    		self.timeText =  self("timeText")
    		self.timeText.prefix = "限时优惠:"
    		self.timeText.suffix = "后消失"
    		-- self.timeText.format = 2
    		-- self.timeText.max = 4

    		self.timeText.time = tonumber(timeLimit - timeSpace);

    		self.timeText:startCountDown()
    	else
    		self("timeText").visible = 0
    	end
	elseif self.tipid == 2 then
        self("timeText").visible = 0
	elseif self.tipid == 3 then
        self("timeText").visible = 0
	elseif self.tipid == 4 then
        self("timeText").visible = 0
	end
end

function VBattleFaildTip:OnTime( ... )
    -- body
    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local charge = gData:attrValue(AttrType.AttrTypeCharge);
    
    local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end
        
    if YB >= cost * gResRate then
        self:updateCostBtn()
    end
end

--更新钻石按钮
function VBattleFaildTip:updateCostBtn(  )
	if self.tipid == 1 then
        local YB = gData:attrValue(AttrType.AttrTypeCurrency)

		if tonumber(self.discount) < 10 then
            if YB < self.discount * gResRate or self.info.shop[self.purchase].buyClass == 1 then
			    self("costText").text = "充值"..formatPrice(self.discountCost).."元"..formatChargeDesc();
            else
                self("costText").text = formatChargeDesc();
            end
		else
            if YB < self.cardCost * gResRate or 
                self.info.shop[self.purchase].buyClass == 1 then
                 self("costText").text = "充值"..formatPrice(self.cardCost).."元"..formatChargeDesc()
            else
                self("costText").text = formatChargeDesc();
            end
		end

        self("rechargeBtn").onClick = "node:Parent(2):onBuyClick()"
	else
        local csv = gData:readCsv("user_vip.csv");
        local vipData = csv:allData();
        local vipScore = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCharge);
        if self.tipid == 2 then
            local money = (vipData[2][1] - vipScore)/10;
            self("costText").text = "充值"..formatPrice(money).."元"..formatChargeDesc();
    	elseif self.tipid == 3 then
            local money = (vipData[4][1] - vipScore)/10;
            self("costText").text = "充值"..formatPrice(money).."元"..formatChargeDesc();
    	elseif self.tipid == 4 then
            local money = (vipData[6][1] - vipScore)/10;
            self("costText").text = "充值"..formatPrice(money).."元"..formatChargeDesc();
    	end
        self("rechargeBtn").onClick = "view:Push('vPaymentDlg.vui'); node:Parent(2):doPop();";
    end
end


--------------------self.tipid 为1 的时候相关操作

function VBattleFaildTip:onExtraShopClose( ... )
	-- body
	local time = gData.userInfo.dungeonInfo.extraShop.time or 0
	local timeSpace = gData:currentTime() - time

    local dungeonInfo = gData.userInfo.dungeonInfo

    local purchase = dungeonInfo:GetPurchase(dungeonInfo.extraShopid) or 0
    local timeLimit = gData.userInfo.dungeonInfo.timeLimit
	if time and timeSpace < timeLimit and purchase == 0 then
		
		local levelDlg = gView()("levelDlg")
		if levelDlg then
			levelDlg:ShowExtraShopTip()
		end
	else
        cclog("timeSpace"..timeSpace)
	end

	-- if self.purchase ~= 3 and self.purchase ~= 2 then
 --        local dlg = VNode("vLevelInfoDlg.vui")
 --        dlg:SetDlgInfo(self.info)
 --        gView():Push(dlg)
 --    end


    dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

	-- self:doPop()
end

function VBattleFaildTip:InitCostInfo(parameters)
	if not self.info or not self.purchase then
		return
	end

    local costInfo = gData:GetLevelCostInfo(self.info, self.purchase)

    if not costInfo then
        return
    end

    self.discountCost = costInfo.discountCost
        self.discount = costInfo.discount
        self.cardCost = costInfo.cardCost
        self.shopName = costInfo.shopName
end



function VBattleFaildTip:onBuyClick()
    local dungeonInfo = gData.userInfo.dungeonInfo
    
    local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end
    
    dungeonInfo:ShopBuyClick(self.info.id, self.purchase, cost, self)
    -- if self.info.shop[self.purchase].buyClass == 1 and 
    --     gRes:Platform() ~= "ios" and 
    --     gRes:Platform() ~= "mac" then
    --     --duanxin
        
        
    --     self:SendSMS(cost)
        
    -- else
    --     if gData.offlineData.offline then
    --         -- local normalTip = VNode("vNormalTip.vui")
    --         -- normalTip:initTip("提示", "单机模式不支持第三方支付")
    --         -- gView():Push(normalTip)
    --         gWindow:showNormalTip("单机模式不支持第三方支付", "提示")
    --         gWindow:closeWaitTip()
    --         return
    --     end
        
    --     local YB = gData:attrValue(AttrType.AttrTypeCurrency)
        
        
    --     if YB < cost * gResRate then
    --         -- gWindow:showMoneyLackDlg(cost)
    --         local dlg = VNode("vPaymentDlg.vui")
    --         gView():Push(dlg);
    --         gWindow:closeWaitTip()
    --         return
    --     else
    --         -- gWindow:showWaitTip()
    --         gReq:MsgReqDungeonPurchase(self, "ReqDungeonPurchaseBack", self.purchase, self.info.id);
            
    --     end
    -- end

   
end

function VBattleFaildTip:ReqDungeonPurchaseBack(result, rsp, req)
    if result == 0 then
        self:ReqDungeonPurchaseSuccess(rsp, req)
    else
        self:ReqDungeonPurchaseFail(result, rsp, req)
    end
end


function VBattleFaildTip:ReqDungeonPurchaseSuccess(rsp, req)
--     gData.userInfo.dungeonInfo:SetDungeonInfo(self.info.chapter, self.info.id, rsp.info.record, rsp.info.online_reward, rsp.info.purchase)
--     gData.offlineData:saveOfflineData()
--     gData.offlineData:updateLastServerData(rsp.info);
--     gWindow:closeWaitTip()
--     if self.purchase ~= 3 and self.purchase ~= 2 then
-- --        gMainView:sendBattleRequest(self.info.id, EBattleRequestType.Dungeon);
--         local dlg = VNode("vLevelInfoDlg.vui")
--         dlg:SetDlgInfo(self.info)
--         gView():Push(dlg)
--     end

--     self:ShowBuySuccssDlg()

     local dungeonInfo = gData.userInfo.dungeonInfo

    dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)

    dungeonInfo:ShowBuySuccssDlg(self.info.id, self.purchase)
    
    self:doPop()
end


function VBattleFaildTip:ReqDungeonPurchaseFail(result, rsp, req)
--    gWindow:showTip("购买失败", 1);
    gWindow:closeWaitTip()
end

function VBattleFaildTip:SendSMSBack(result)
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

        dungeonInfo:CheckOpenLevelInfoDlg(self.info.id, self.purchase)
	end
	
    gWindow:closeWaitTip()
    self:doPop()
end

function VBattleFaildTip:ReqDungeonReportBack(result, rsp, req)
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

--------------------self.tipid 为1 的时候相关操作end