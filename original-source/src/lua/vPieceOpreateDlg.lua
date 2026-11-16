--VPieceOpreateDlg.lua
require "vSellDlg"

VPieceOpreateDlg = VClass("PieceOpreateDlg", VMsgBox)

function VPieceOpreateDlg:onPush(parameters)
    self("artUp"):play("idle")
    local data = self.info
    self:ShowDlg(data)
end

function VPieceOpreateDlg:ShowDlg(data)
    local costCount = 99
--    local compoundCsv = gData:readCsv("suit_compound.csv");
--    if compoundCsv == nil then
--        gWindow:showTip("suit_compound.csv 找不到", 1)
----        return
--    end
--
--    local compound = compoundCsv:lineDataWithKey(self.info.thingid);
--    if compound == nil then
----        gWindow:showTip(self.info.thingid.."在suit_compound.csv 找不到", 1)
----        return
--        local itemCsv = gData:readCsv("prop_item.csv");
--        if itemCsv == nil then
--            gWindow:showTip("prop_item.csv 找不到", 1)
--            return
--        end
--
--        local item = itemCsv:lineDataWithKey(self.info.thingid);
--        if item == nil then
--            gWindow:showTip(self.info.thingid.."在prop_item.csv 找不到", 1)
--            return
--        else
--            costCount = item.itemCount
--        end
--    else
--        costCount = compound[4]
--    end
    
--    if self:CheckUseType() == nil then
--        self("lyrBt2PieceO").visible = self.isbag
--    else
--        self("lyrBt1PieceO").visible = self.isbag
--    end
    
--    self("lyrBt1PieceO").visible = self.isbag
--    self("btnCostPieceO").visible = not self.isbag
   
    self("txdescribePieceO").text = data.desc
    self("txDexNamePieceO").text = data.name
    self("txDexCountPieceO").text = data.count
--    if data.count >= costCount then
--        self("txUpCountNumZPieceO").color = {0,255,0}
--    else
--        self("txUpCountNumZPieceO").color = {255,255,255}
--    end
--    self("txUpCountNumMPieceO").text = " / "..costCount
--    self("txTitlePieceO").color = gData:getNameColorByQuality(data.quality)
    self("imgDexPieceO").image = data.image

    self("imgDexPieceO").scale = gData:GetFitScale(self("imgDexPieceO"), self("imgDexDPieceO"))
--    self("txDexPieceO").text = "x"..data.count
--    self:SetSellCount(data.costType, data.cost)
end

function VPieceOpreateDlg:SetInfo(info, isbag, shopAttr)
    self.info = info
    self.isbag = isbag
    self.shopAttr = shopAttr
end

function VPieceOpreateDlg:SetSellCount(num, sell)
    if num == 0 then
        self("txCostPieceO").text = "不可出售"
        self("imgCostPieceO").visible = 0
        self("imgCostPieceO").image = nil
    elseif num == 1 then
        self("txCostPieceO").text = sell
        self("imgCostPieceO").image = "icon_jinbi.png"
    elseif num == 2 then
        self("txCostPieceO").text = sell
        self("imgCostPieceO").image = "icon_yibi.png"
    elseif num == 3 then
        self("txCostPieceO").text = sell
        self("imgCostPieceO").image = "icon_zuanshi.png"
    end
end


function VPieceOpreateDlg:onBackClick()
    --    self:Parent():MsgCallBack(self, "MSGBOX")
    self:onClick()
end

function VPieceOpreateDlg:onSellClick()
    cclog("sssssssssssss"..self.info.id.."~~~~~~~`"..self.info.thingid)
    local node = VNode("vSellDlg.vui")
    node:SetInfo(self.info)
    gView():Push(node)
    
    self:onClick()
end

function VPieceOpreateDlg:CheckUseType(parameters)
    local compoundCsv = gData:readCsv("suit_compound.csv");
    if compoundCsv == nil then
        gWindow:showTip("suit_compound.csv 找不到", 1)
        return nil
    end

    local compound = compoundCsv:lineDataWithKey(self.info.thingid);
    return compound
end

function VPieceOpreateDlg:onUseClick()
    cclog("uuuuuuuuuuuu"..self.info.id.."~~~~~~~`"..self.info.thingid)
    local level = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeLevel);

    cclog("玩家等级:"..level.."~~~物品限制等级~~`"..self.info.levelLimit)
    if level < self.info.levelLimit then
        gWindow:showTip("玩家等级不足", 1);
        return
    end
    
    if self:CheckUseType() == nil then
        self:ReqItemUse()
    else
        self:ReqSuitCompound()
    end
    
    self:onClick()
end

function VPieceOpreateDlg:ReqItemUse(parameters)
    local itemCsv = gData:readCsv("prop_item.csv");
    if itemCsv == nil then
        gWindow:showTip("prop_item.csv 找不到", 1)
        return
    end

    local item = itemCsv:lineDataWithKey(self.info.thingid);
    if item == nil then
        gWindow:showTip(self.info.thingid.."在prop_item.csv 找不到", 1)
        return
    end
    
    if self.info.count < item[15] then
        cclog("资源不足")

        gWindow:showTip("植物碎片数量不足", 1)
        return
    end
    
    local aParam = {}
    aParam.bagid = self.info.id
    aParam.itemid = self.info.thingid
    aParam.count = item[15]
    --        aParam.qulity = compound[5]

    gView()("bagDlg"):ReqItemUse(aParam)

end

function VPieceOpreateDlg:ReqSuitCompound(parameters)
    
    local compoundCsv = gData:readCsv("suit_compound.csv");
    if compoundCsv == nil then
        gWindow:showTip("suit_compound.csv 找不到", 1)
        return
    end

    local compound = compoundCsv:lineDataWithKey(self.info.thingid);
    if compound == nil then
        gWindow:showTip(self.info.thingid.."在suit_compound.csv 找不到", 1)
        return
        

    end

    if self.info.count < compound[4] then
        cclog("资源不足")
        gWindow:showTip("基因片段数量不足", 1)
        return
    end

    local aParam = {}
    aParam.thingid = compound[0]
    aParam.count = 1
    aParam.qulity = compound[1]

    gView()("bagDlg"):ReqSuitCompound(aParam)
end


function VPieceOpreateDlg:onFastUseClick()
    --    self:Parent():MsgCallBack(self, "MSGBOX")
    --    self:onClick()

    cclog("uuuuuuuuuuuu"..self.info.id.."~~~~~~~`"..self.info.thingid)
    local level = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeLevel);


    if level < self.info.levelLimit then
        gWindow:showTip("玩家等级不足", 1);
        return
    end

    if self:CheckUseType() == nil then
        self:ReqFastItemUse()
    else
        self:ReqFastSuitCompound()
    end
    
    self:onClick()
end

function VPieceOpreateDlg:ReqFastItemUse(parameters)
    local itemCsv = gData:readCsv("prop_item.csv");
    if itemCsv == nil then
        gWindow:showTip("prop_item.csv 找不到", 1)
        return
    end

    local item = itemCsv:lineDataWithKey(self.info.thingid);
    if item == nil then
        gWindow:showTip(self.info.thingid.."在prop_item.csv 找不到", 1)
        return
    end
    
    if self.info.count < item[15] then
        cclog("~~~~~!!!!!!!!!!!!!~~~资源不足")
        gWindow:showTip("植物碎片数量不足", 1)
        return
    end

    local aParam = {}
    aParam.bagid = self.info.id
    aParam.itemid = self.info.thingid
    aParam.count = math.modf(self.info.count / item[15]) * item[15]

    gView()("bagDlg"):ReqItemUse(aParam)

end

function VPieceOpreateDlg:ReqFastSuitCompound(parameters)
    local compoundCsv = gData:readCsv("suit_compound.csv");
    if compoundCsv == nil then
        gWindow:showTip("suit_compound.csv 找不到", 1)
        return
    end

    local compound = compoundCsv:lineDataWithKey(self.info.thingid);
    if compound == nil then
        gWindow:showTip(self.info.thingid.."在suit_compound.csv 找不到", 1)
        return
    end

    if self.info.count < compound[4] then
        cclog("资源不足")
        gWindow:showTip("基因片段数量不足", 1)
        return
    end
    cclog("使用数量"..math.modf(self.info.count / compound[4]).."~~~~~~~~~~"..compound[4])
    local aParam = {}
    aParam.thingid = compound[0]
    aParam.count = math.modf(self.info.count / compound[4])
    aParam.qulity = compound[1]

    gView()("bagDlg"):ReqSuitCompound(aParam)
end

function VPieceOpreateDlg:onBuyClick()
    if self.info.costType == 0 then
        return
    end
    
    local shopDlg = gView()("shopDlg")
    shopDlg:BuyItem(self.info, self.shopAttr)
    self:onClick()
end

function VPieceOpreateDlg:onClick()
    --    local currentView = gView(-2)
    --    if currentView then
    --        currentView.visible = 1
    --    end
    VPieceOpreateDlg.super.onClick(self)
end