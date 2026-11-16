--vShopDlg.lua

require "vShopCell"
--require "vplantResCell"
--require "vplantWarCell"

SHOP_ENUM = {
    shangdianwenzi = 1,
    shenmishangren = 2,
    zhifenshangdian = 3,
}

VShopDlg = VClass("ShopDlg", VMsgBox)

function VShopDlg:Init(attr)
    VMsgBox.Init(self, attr);
    self.rowCount = 5;
    self.maxShopSize = 40--gData.userInfo.roleInfo.roleShopInfo.shopItemCount--测试数据
--    local csv = gData:readCsv("item_common.csv");
    self.refreshCost = gData:GetShopRefreshCost();
    self:initDataSource();
end

function VShopDlg:initDataSource()
    self.shop = gData.userInfo.roleInfo.roleShopInfo.shopInfo;
    self.secretShop = gData.userInfo.roleInfo.roleShopInfo.secretShop;
   
    self.battleRankQuery = {}
    self.battleRankQuery.shopItems = {}
    local shopItems = self.battleRankQuery.shopItems
    
    local rewardsCsv = gData:readCsv("prop_point_shop.csv");
    local csvLine = rewardsCsv:lineCount();

    for i=0,csvLine-1 do
        local rewardInfo = self:CreateRewardInfo(rewardsCsv, i);
        table.insert(shopItems, rewardInfo);
    end
    
    
    
    self.openCount = gData.userInfo.roleInfo.roleShopInfo.shopItemCount--15 --测试数据
end

function VShopDlg:CreateRewardInfo(csv, index)
    local rewardInfo = {}
    rewardInfo.scheme = csv:lineData(index, 0);
    rewardInfo.resType = csv:lineData(index, 1);
    rewardInfo.thingid = csv:lineData(index, 2);
    rewardInfo.itemCount = csv:lineData(index, 3);
--    rewardInfo.itemCost = csv:lineData(index, 4);

    local lineData = nil
    rewardInfo.itemImage, rewardInfo.itemName, rewardInfo.quality, lineData = gData:getResoureIconByID(rewardInfo.resType, rewardInfo.thingid)
    
    rewardInfo.type = lineData.clientResType
    rewardInfo.itemDesc = lineData.desc
    rewardInfo.costType = lineData.costType
    rewardInfo.itemCost = lineData.cost * rewardInfo.itemCount;
    rewardInfo.discount = 100
    
    return rewardInfo
end

function VShopDlg:CheckNormalShopTimeOut()
    if not self.shop then return true end;
    local expireTime = self.shop.expireTime;
    
    if not expireTime or gData:currentTime() > expireTime then
        return true;
    end
    
    return false;
end

function VShopDlg:onPush()
    self.btnTimeShop = self("btnTimeShop")
    self.tbShop = self("tbShop");
    self.tabRankRewardView = self("tabRankRewardView")
    self.tbShop.delegate = self;
    self.lastTableBt = self("btnTabShop1")
--    self.lastTableBt.level = 100
    self.refreshTip = self("refreshTimeText");
    self.secretTimeText = self("secretTimeText")
    self.btnNormalShop = self("btnTabShop1");
    self.btnSecretShop = self("btnTabShop2");
    -- self("txStoreShop").text = self.openCount.."/"..self.maxShopSize
    
    self.btnNormalShop.shopType = ShopType.ShopTypeNormal;
    self.btnSecretShop.shopType = ShopType.ShopTypeSecret;
    self.lastTableBt.type = ShopType.ShopTypeNormal;
    
    
    
    self("titliText").image="shangdianwenzi3.png";

    self.tbShop:setTouchEnabled(false)



    if self:CheckShopTimewithType(ShopType.ShopTypeNormal) then
        self:InitShopDlg()
    end
end

function VShopDlg:InitShopDlg(parameters)
    self:initDataSource();

    self("txJinbiShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeMoney))
--    self("txJinbiShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeBattleScore))
    self("txYuanbaoShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeCurrency))
    self("txSunShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeSunshine))
    self("txjifenShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeBattleScore))
    self.refreshCost = gData:GetShopRefreshCost();
    
    if self:CheckSecretShopTimeOut() then
        self.btnSecretShop.visible = 0
    else
        self.btnSecretShop.visible = 1
        self:CalcSecretShopTime(ShopType.ShopTypeSecret)
        self:StartTimer("SetSecretShopTime", 1)
    end
    
    self:CalcNextRefreshTime(ShopType.ShopTypeNormal)

    local refreshCost = gData:GetShopRefreshCost();

    if refreshCost and refreshCost > 0 then
        self("refreshCostImage").visible = 1;
        self("refreshCostText").offset = {2,0};
        self("refreshCostText").text = refreshCost.." 刷新";
        self("refreshCostText"):ReLayout();
        self("refreshCostImage"):ReLayout();
    else
        self("refreshCostImage").visible = 0;
        self("refreshCostText").offset = {0,0};
        self("refreshCostText").text = "免费刷新";
    end

    self:StartTimer("SetNextRefreshTime", 1)

    if not self.tbShop.shopType then
        self:RecoverShopFace(ShopType.ShopTypeNormal)
        self:ReloadTable(ShopType.ShopTypeNormal)
    else
        self:RecoverShopFace(self.tbShop.shopType)
        self:ReloadTable(self.tbShop.shopType);
    end
end

function VShopDlg:CheckSecretShopTimeOut(parameters)
	return ((not self.secretShop) or #self.secretShop.shopItems == 0 or self.secretShop.expireTime < gData:currentTime())
end

function VShopDlg:ReqRefresh(extend)
    local refreshType = extend
    if type(extend) == "table" then
        refreshType = extend.ShopRefreshType
    end
    local YB = gData:attrValue(AttrType.AttrTypeBattleScore)
    if YB < self.refreshCost and refreshType ~= 1 then
--        gWindow:showMoneyLackDlg(self.refreshCost)
        --            CheckCostInfos(21, 1, self.itemInfo.itemCost)
        gWindow:showTip("战功不足", 1)
        return
    end
    
    local aParam = {}
    aParam.type = refreshType
    gReq:MsgReqShopRefresh(self, "RefreshCallBack", aParam)
    gWindow:showWaitTip()
end

function VShopDlg:onbtnReqRefreshClick()
   
    
    local cost = gData:GetShopRefreshCost()
    
    local extend = {}
    extend.title = "刷新商店"
    extend.content = "确定消耗"..cost.."钻石刷新吗"
    extend.ShopRefreshType = ShopRefreshType.ShopRefreshBattleScore

        self:ReqRefresh(extend)

end

function VShopDlg:SetSecretShopTime()
    cclog("SetSecretShopTime调用了")
    local time = self:GetSecretShopTime()
    self.secretTimeText.text = time.."后免费刷新";
end

function VShopDlg:CalcSecretShopTime(shopType)
    local time = self.secretShop.expireTime - gData:currentTime()
    
    cclog("time = %d", time);
    
    if time <= 0 then
        self.minS = 0
        self.secS = 0
    end

    self.minS = math.modf(time / 60)
    self.secS = time % 60
end

function VShopDlg:GetSecretShopTime()
    if self.secS == 0 then
        self.secS = 59
        self.minS = self.minS - 1
        if self.minS < 0 then
            self:StopTimer("SetSecretShopTime")
            cclog("商城计时刷新了")
            if self.lastTableBt.type == ShopType.ShopTypeSecret then
                self.tbShop.shopType = nil
                self:InitShopDlg()
            end
            self("btnSecretShop").visible = 0
            
            self.minS = 0
            self.secS = 0
        end
    else
        self.secS = self.secS - 1
--        cclog("商城计时了")
    end

    local time = ""..self.minS.."分"..self.secS.."秒";
--    cclog("商城时间:"..time)
    return time
end

function VShopDlg:SetNextRefreshTime()
--    cclog("SetNextRefreshTime调用了")
    local time = self:GetNextRefreshTime()
    self.refreshTip.text = time.."后免费刷新";
end

function VShopDlg:CalcNextRefreshTime(shopType)

    local time = self.shop.expireTime - gData:currentTime()
    
    if shopType == ShopType.ShopTypeSecret then
        time = self.secretShop.expireTime - gData:currentTime()
    end
    cclog("time = %d", time);
    
    
--    self.min = math.modf(time / 60)
--    self.sec = time % 60
    
    self.hour = math.modf(time / 3600)
    self.min = math.modf(time % 3600 / 60)
    self.sec = time % 3600 % 60
end

function VShopDlg:GetNextRefreshTime()
--    if self.sec == 0 then
--        self.sec = 59
--        self.min = self.min - 1
--        if self.min < 0 then
--            self:StopTimer("SetNextRefreshTime")
--            cclog("商城计时刷新了")
--            if self.lastTableBt.type ~= ShopType.ShopTypeSecret then
--                self:ReqRefresh(ShopRefreshType.ShopRefreshTime)
--            end
--            
--            self.min = 0
--            self.sec = 0
--        end
--    else
--        
--        self.sec = self.sec - 1
----        cclog("商城计时了")
--    end

        self.sec = self.sec - 1
    
    if self.sec < 0 then
        self.sec = 59
        self.min = self.min - 1
        if self.min < 0 then
            self.hour = self.hour - 1
            if self.hour < 0 then
                self:StopTimer("SetNextRefreshTime")
                cclog("商城计时刷新了")
                if self.lastTableBt.type ~= ShopType.ShopTypeSecret then
                    self:ReqRefresh(ShopRefreshType.ShopRefreshTime)
                end
                
                self.hour = 0
                self.min = 0
                self.sec = 0
            else
                self.min = 59
            end
            
        end
--        if self.min < 0 then
--            self:StopTimer("SetNextRefreshTime")
--            cclog("商城计时刷新了")
--            if self.lastTableBt.type ~= ShopType.ShopTypeSecret then
--                self:ReqRefresh(ShopRefreshType.ShopRefreshTime)
--            end
--
--            self.min = 0
--            self.sec = 0
--        end
    
        --        cclog("商城计时了")
    end
    
--    local time = (999).."分"
    
--    if self.min > 0 then
--        time =  self.min.."分"
--    else
--        time = self.sec.."秒"
--    end
--    local time = ""..self.min.."分"..self.sec.."秒";
    local str1 = self.hour
    local str2 = self.min
    local str3 = self.sec

    
    
    if str1 < 10 then
        str1 = "0"..str1
    end
    
    if str2 < 10 then
        str2 = "0"..str2
    end
    
    if str3 < 10 then
        str3 = "0"..str3
    end
    
    local time = str1..":"..str2..":"..str3.."秒";
--    cclog("商城时间:"..time)
    return time
end

function VShopDlg:RefreshCallBack(result, rsp, req)
	if result == 0 then
        self:RefreshSuccess(rsp, req)
	else
        self:RefreshFail()
	end
end


function VShopDlg:RefreshSuccess(rsp, req)
    self:InitShopDlg()
    if req.type == 1 then
        gData.noticeManager:clear(NoticeType.shop_refresh)
        if gMainView then
            gMainView:CheckShopRefresh()
        end
    end
    gWindow:closeWaitTip()
    gWindow:showTip("商品已刷新", 1)
end


function VShopDlg:RefreshFail()
    gWindow:closeWaitTip()
end

function VShopDlg:ReloadTable( type )
    
        self.tbShop.shopType = type
        self.tbShop.number = math.ceil(self.maxShopSize / self.rowCount);
        self.tbShop:reloadData();
--    else
--        self.tabRankRewardView.delegate = self;
--        if not self.battleRankQuery.rewardInfos then
--            self.battleRankQuery:initRewardInfo();
--        end
--        self.tabRankRewardView.number = #self.battleRankQuery.rewardInfos;
--        self.tabRankRewardView:reloadData();
--    end
end

function VShopDlg:onCell(idx, t, cell)
    if t == self.tbShop then
        local shopInfo = nil;
        if t.shopType == ShopType.ShopTypeNormal then
            shopInfo = self.shop
        elseif t.shopType == ShopType.ShopTypeSecret then
            shopInfo = self.secretShop
        elseif t.shopType == 3 then
            shopInfo = self.battleRankQuery
        end

        if not shopInfo then return end;
        cell.shopType = t.shopType
        cell.infos = {}
        for i=1,self.rowCount do
            local cellIdx = idx*self.rowCount + i;
            local item = shopInfo.shopItems[cellIdx];
            cell:reload(idx, i, item);
--            if cellIdx > self.openCount then
--                cell:lockCell(idx, i, true);
--            end
        end
    end
end

function VShopDlg:onCellSize(idx, t)
    if idx == 0 then
        return 685,217
    else
        return 683,151
    end
end

function VShopDlg:CheckShopTimewithType(shopType)
	if shopType == ShopType.ShopTypeSecret then
	    if self:CheckSecretShopTimeOut() then
            self:StopTimer("SetSecretShopTime")
            self.tbShop.shopType = nil
            self:InitShopDlg()
            return false
        end
    else
        if self:CheckNormalShopTimeOut() then
            self:StopTimer("SetNextRefreshTime")
            self:ReqRefresh(ShopRefreshType.ShopRefreshTime)

            return false
        end
    end
    
    return true    
end

function VShopDlg:ChageTable( shopType )
    if self.lastTableBt.type == shopType then
        return
    end
    
    if not self:CheckShopTimewithType(shopType) then
        return
    end
    
    self:RecoverShopFace(shopType)
    self.lastTableBt = self("btnTabShop"..shopType)
    self.lastTableBt.type = shopType
    
    self:ReloadTable(shopType)
end

function VShopDlg:RecoverShopFace(shopType)  
    for key, var in pairs(SHOP_ENUM) do
        local bt = self("btnTabShop"..var)
        
        cclog("~~~~~~~~~~"..self.lastTableBt.type.."~~~~~~~~~~~"..shopType.."var: "..var)
        
        if shopType == var then
            cclog("ccccccccccc")
            local image = VImage{name="tmp1", image="mubanxuanzhong.png"}
            bt.image = "mubanxuanzhong.png"
            bt.size = {image.size.width, image.size.height}
--            bt.offset = {bt.offset.x - 15, bt.offset.y + 5}
            self("imgTabShop"..var).image = key.."1.png"
        elseif self.lastTableBt.type == var then
            cclog("bbbbbbbbbbb")
            local image = VImage{name="tmp", image="mubanweixuanzhong.png"}
            bt.image = "mubanweixuanzhong.png"
            bt.size = {image.size.width, image.size.height}
            self("imgTabShop"..var).image = key.."2.png"
--            bt.offset = {bt.offset.x + 15, bt.offset.y - 5}
        end
        
        bt:ReLayout()    
    end
    
    if shopType == 3 then
        self("imgSunDShop").visible = 0
        self("imgJinbiDShop").visible = 0
        self("imgYuanbaoDShop").visible = 0
        self("imgTimeShop").visible = 0
        self("imgjifenDShop").visible = 1
    else
        self("imgSunDShop").visible = 0
        self("imgJinbiDShop").visible = 0
        self("imgYuanbaoDShop").visible = 1
        self("imgTimeShop").visible = 1
        self("imgjifenDShop").visible = 1
        if shopType == 1 then
            local refreshCost = gData:GetShopRefreshCost();
            if refreshCost and refreshCost > 0 then
                self.refreshTip.visible = 1
            else
                self.refreshTip.visible = 0
            end
            
            self.secretTimeText.visible = 0
            self.btnTimeShop.visible = 1
        else
            if self:CheckSecretShopTimeOut() then
                self.secretTimeText.visible = 0
            else
                self.secretTimeText.visible = 1
            end
            
            self.refreshTip.visible = 0
            self.btnTimeShop.visible = 0
        end
    end
--    self:StartTimer("SetNextRefreshTime", 1, - 1, 0)
end

function VShopDlg:UpdataItem(result, rsp, req)
    if result == 0 then
        self:initDataSource();
--        self:ReloadTable(self.tbShop.shopType);
        if self.tbShop.shopType == req.type then
            local shopInfo
            if req.type == ShopType.ShopTypeNormal then
                shopInfo = self.shop
            elseif req.type == ShopType.ShopTypeSecret then
                shopInfo = self.secretShop
            end
            
            local cell = self.tbShop:cellAtIndex(req.idx)
            
            if cell then
                local cellIdx = req.idx * self.rowCount + req.i;
                local item = shopInfo.shopItems[cellIdx];
                cell:reload(req.idx, req.i, item);
--                if cellIdx > self.openCount then
--                    cell:lockCell(req.idx, req.i, true);
--                end
            end
--            cell:UpdataItem(i)
        end
    else
        self:RefreshFail()
    end
end

function VShopDlg:SetCurrentOperatItem(idx, i)
--    self.choosedItem = scheme
--    cclog("chossItem = %d", self.choosedItem);
    self.idx = idx
    self.i = i
end

function VShopDlg:ReqShopExtend(aParam)
--    local aParam = {}
--    aParam.count = 1;
--    gReq:MsgReqShopExtend(self, "ShopExtendCallBack", aParam)
    aParam.node = self
    aParam.idx = self.idx
    aParam.i = self.i
    gReq:MsgReqShopExtend(self, "ShopExtendCallBack", aParam)
end

function VShopDlg:ShopExtendCallBack(result, rsp, req)
    if result == 0 then
        self:ShopExtendSuccess(rsp, req)
    else
        self:ShopExtendFail()
    end
end


function VShopDlg:ShopExtendSuccess(rsp, req)
    self:initDataSource();
    local txStoreShop = self("txStoreShop")
    if txStoreShop ~= nil then
--        txStoreShop.text = self.openCount.."/"..self.maxShopSize
    end
    
    if self("txjifenShop") then
        self("txJinbiShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeMoney))
--        self("txJinbiShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeBattleScore))
        self("txYuanbaoShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeCurrency))
        self("txSunShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeSunshine))
        self("txjifenShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeBattleScore))
        self.refreshCost = gData:GetShopRefreshCost();
    end
    
--    self:ReloadTable(self.tbShop.shopType);
    local tbShop = self("tbShop")
    local startPosidx = math.floor((self.openCount - req.count) / self.rowCount)

    cclog("startPosidx"..startPosidx)
    for var = startPosidx, req.idx + 1 do
        local cell = tbShop:cellAtIndex(var)
        if cell then
            self:onCell(var, tbShop, cell)
        end
    end
end


function VShopDlg:ShopExtendFail()

end

function VShopDlg:BuyItem(info, shopAttr)
    -- 还需要做玩家金钱是否足够的判断。
    cclog("~~~~~~~~onBuyClick")
    self.shopAttr = shopAttr
    -- local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    -- local coin = gData:attrValue(AttrType.AttrTypeMoney)
    -- local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
    -- local JF = gData:attrValue(AttrType.AttrTypeBattleScore)


    -- if info.costType == 1 then
    --     cclog("~~~~~~~~阳光")
    --     if tonumber(sunShine) < info.cost then
    --         self:CheckCostInfos(21, 1, info.cost - sunShine)
    --         return
    --     end
    -- elseif info.costType == 2 then
    --     cclog("~~~~~~~~金币")
    --     if tonumber(coin) < info.cost then
    --         self:CheckCostInfos(20, 1, info.cost - coin)
    --         return
    --     end 
    -- elseif info.costType == 3 then
    --     cclog("~~~~~~~~钻石")
    --     if tonumber(YB) < info.cost then
    --         gWindow:showMoneyLackDlg(info.cost)
    --         return
    --         --            CheckCostInfos(21, 1, shopAttr.cost)
    --     end
    -- else
    --     cclog("~~~~~~~~积分")
    --     if tonumber(JF) < info.cost then
    --         gWindow:showTip("积分不足", 1)
    --         return
    --         --            CheckCostInfos(21, 1, shopAttr.cost)
    --     end
    -- end
   
    local res = {}
    local infoi = {}
    infoi.type = info.price_type;
    infoi.id = info.price_effect_id;
    infoi.cost = math.ceil(info.cost * info.discount / 10)--info.cost
    table.insert(res, infoi)

    if not gData:CheckResConsume(res, self, "ReqItemBuy") then
    -- if not gData:CheckResConsume(res, nil, nil) then
        return
    end

    cclog("~~~~~~~~发送购买请求")
    self:ReqItemBuy(shopAttr.idx, shopAttr.i)
    --    if YB
    --    if shopAttr.cost < 

end

function VShopDlg:CheckCostInfos(thingid, type, count)
    cclog("~~~~~~~~~~~CheckCostInfos")
    local costInfos = {}
    local costInfo = {}

    costInfo.thingid = thingid
    costInfo.type = type
    costInfo.count = count

    table.insert(costInfos, costInfo)
    gWindow:showCostLackDlg(costInfos, self, "ReqItemBuy")
end

function VShopDlg:ReqItemBuy(idx, i)
    local aParam = {}
    aParam.type = self.shopAttr.type;
    aParam.boxid = self.shopAttr.id;
    aParam.idx = self.shopAttr.idx
    aParam.i = self.shopAttr.i
    gReq:MsgReqItemBuy(self, "ItemBuyCallBack", aParam)
    gWindow:showWaitTip()
end

function VShopDlg:ItemBuyCallBack(result, rsp, req)
    cclog("~~~~~~~~~~~钱:"..gData:attrValue(AttrType.AttrTypeMoney).."钻石"..gData:attrValue(AttrType.AttrTypeCurrency).."阳光"..gData:attrValue(AttrType.AttrTypeSunshine))
    if result == 0 then
        self:ItemBuySuccess(result, rsp, req)
    else
        self:ItemBuyFail()
    end
end

function VShopDlg:ItemBuySuccess(result, rsp, req)
--    self.rowCount = 5
--    self.openCount = gData.userInfo.roleInfo.roleShopInfo.shopItemCount--15 --测试数据
--    self.maxShopSize = 8--gData.userInfo.roleInfo.roleShopInfo.shopItemCount--测试数据
--
--    self:InitShop()
--    self:InitSecretShop()
--
--    self:ReloadTable("SHOP")
    if req.type == 3 then
        gWindow:showTip("兑换成功", 1)
    else
        self:UpdataItem(result, rsp, req)
    end
    cclog("钱:"..gData:attrValue(AttrType.AttrTypeMoney).."钻石"..gData:attrValue(AttrType.AttrTypeCurrency).."阳光"..gData:attrValue(AttrType.AttrTypeSunshine))
    if self("txjifenShop") then
--        self("txJinbiShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeMoney))
        self("txJinbiShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeBattleScore))
        self("txYuanbaoShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeCurrency))
        self("txSunShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeSunshine))
        self("txjifenShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeBattleScore))
        self.refreshCost = gData:GetShopRefreshCost();
    end
    gWindow:closeWaitTip()
end


function VShopDlg:ItemBuyFail()
    gWindow:closeWaitTip()
end


function VShopDlg:onClick()
--    local currentView = gView(-2)
--    if currentView then
--        currentView.visible = 1
--    end
    self:StopTimer("SetNextRefreshTime")
    VShopDlg.super.onClick(self)
end

function VShopDlg:showGongxunCameFrom( )
    self("shabixuqiu").visible = 1;
    self("shabixuqiu1").visible = 1;
end

function VShopDlg:shabixuqiuyincang( )
    self("shabixuqiu").visible = 0;
    self("shabixuqiu1").visible = 0;
end