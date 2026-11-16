--vShopItemDlg.lua

VShopItemDlg = VClass("ShopItemDlg", VMsgBox)

function VShopItemDlg:onPush(parameters)
    
    self("artUp"):play("idle")
    self.txnameCrystalO = self("txnameCrystalO");
    self.imgItemIcon = self("imgDexShopItemD");
    self.imgItemPrice = self("imgCostShopItemD")
    self.texItemPrice = self("txCostShopItemD");
    self.texItemDesc = self("txdescribeCrystalO");
    self.txDexCrystalO = self("txDexCrystalO")

    self.txnameCrystalO.text = self.info.name;
    self.txDexCrystalO.text = self.info.count
--    self.texItemName.color = gData:getNameColorByQuality(self.info.quality)
    self.imgItemIcon.image = self.info.image;

    if self.shopAttr.type ~= 2 then
        self.texItemPrice.text = math.ceil(self.info.cost * self.info.discount / 10)
    else
        self.texItemPrice.text = math.ceil(self.info.cost * self.info.discount)
    end
--    self("lyrShopItemDlg"):ReLayout()
    self.imgItemPrice.image = gData:getResoureIconByID(self.info.price_type, self.info.price_effect_id)--self:GetCostTypeImage(self.info.costType)
    
    self.texItemDesc.text = self.info.desc

    self.imgItemIcon.scale = gData:GetFitScale(self.imgItemIcon, self("imgDexDCrystalO"))
--    if self.info.isBought then
--        self("btnBuyShopItemD").visible = 0;
--        self("texItemSellOut").visible = 1;
--    end
end

function VShopItemDlg:SetInfo(info, shopAttr)
    self.info = info
    self.shopAttr = shopAttr
end

function VShopItemDlg:GetCostTypeImage(costType)
    local image = ""
    if costType == 1 then
        image = "icon_jinbi.png"
    elseif costType == 2 then
        image = "icon_yibi.png"
    elseif costType == 3 then
        image = "icon_zuanshi.png"
    elseif costType == 4 then
        return "icon_jifen.png"
    end
    
    return image
end

function VShopItemDlg:onCloseClick()
    self:onClick()
end

function VShopItemDlg:onBuyClick()
    local shopDlg = gView()("shopDlg")
    shopDlg:BuyItem(self.info, self.shopAttr)
    self:onClick()
--    -- 还需要做玩家金钱是否足够的判断。
--    cclog("~~~~~~~~onBuyClick")
--    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
--    local coin = gData:attrValue(AttrType.AttrTypeMoney)
--    local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
--    
--    
--    if self.info.costType == 1 then
--        cclog("~~~~~~~~阳光")
--        if sunShine < self.info.itemCost then
--            self:CheckCostInfos(21, 1, self.info.itemCost - sunShine)
--            return
--        end
--    elseif self.info.costType == 2 then
--        cclog("~~~~~~~~金币")
--        if coin < self.info.itemCost then
--            self:CheckCostInfos(20, 1, self.info.itemCost - coin)
--            return
--        end 
--    elseif self.info.costType == 3 then
--        cclog("~~~~~~~~钻石")
--        if YB < self.info.itemCost then
--            gWindow:showMoneyLackDlg(self.info.itemCost)
--            return
----            CheckCostInfos(21, 1, self.info.itemCost)
--        end
--    else
--        
--    end
--    cclog("~~~~~~~~发送购买请求")
--    self:ReqItemBuy(self.idx, self.i)
----    if YB
----    if self.info.itemCost < 
   
end

function VShopItemDlg:CheckCostInfos(thingid, type, count)
    cclog("~~~~~~~~~~~CheckCostInfos")
    local costInfos = {}
    local costInfo = {}

    costInfo.thingid = thingid
    costInfo.type = type
    costInfo.count = count

    table.insert(costInfos, costInfo)
    gWindow:showCostLackDlg(costInfos, self, "ReqItemBuy")
end

function VShopItemDlg:ReqItemBuy(idx, i)
    local aParam = {}
    aParam.type = self.shopType;
    aParam.scheme = self.info.scheme;
    aParam.idx = idx
    aParam.i = i
    gReq:MsgReqItemBuy(self, "ItemBuyCallBack", aParam)
end

function VShopItemDlg:ItemBuyCallBack(result, rsp, req)
    cclog("~~~~~~~~~~~钱:"..gData:attrValue(AttrType.AttrTypeMoney).."钻石"..gData:attrValue(AttrType.AttrTypeCurrency).."阳光"..gData:attrValue(AttrType.AttrTypeSunshine))
    if result == 0 then
        self:ItemBuySuccess(result, rsp, req)
    else
        self:ItemBuyFail()
    end
end

function VShopItemDlg:ItemBuySuccess(result, rsp, req)
    local shopDlg = gView()("shopDlg")
    cclog("~~~~~~~~~~~钱:"..gData:attrValue(AttrType.AttrTypeMoney).."钻石"..gData:attrValue(AttrType.AttrTypeCurrency).."阳光"..gData:attrValue(AttrType.AttrTypeSunshine))
    if shopDlg ~= nil then
        shopDlg:ItemBuySuccess(result, rsp, req)
    end
    self:onClick();
end

function VShopItemDlg:ItemBuyFail()

end
