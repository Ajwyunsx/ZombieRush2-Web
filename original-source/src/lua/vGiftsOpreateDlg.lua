--VGiftsOpreateDlg.lua
require "vSellDlg"

VGiftsOpreateDlg = VClass("GiftsOpreateDlg", VMsgBox)

function VGiftsOpreateDlg:onPush(parameters)
    self("artUp"):play("idle")
    local data = self.info
    self:ShowDlg(data)
end

function VGiftsOpreateDlg:ShowDlg(data)
    self("btnSellGiftsO").visible = self.isbag
    self("btnCostGiftsO").visible = not self.isbag

    self("txdescribeGiftsO").text = data.desc
    self("txNameGiftsO").text = data.name
--    self("txTitleGiftsO").color = gData:getNameColorByQuality(data.quality)
    self("imgDexGiftsO").image = data.image

    self("imgDexGiftsO").scale = gData:GetFitScale(self("imgDexGiftsO"), self("imgDexDGiftsO"))

    self("txDexGiftsO").text = data.count
    
    cclog("~~~~~~~~~~~~~"..data.isUse)
    
    if tonumber(data.isUse) == 1 then
        
    else
        self("btnSellGiftsO").touch = 0
        self("btnSellGiftsO").gray = 1
    end
end

function VGiftsOpreateDlg:SetInfo(info, isbag, shopAttr)
    self.info = info
    self.isbag = isbag
    self.shopAttr = shopAttr
end

function VGiftsOpreateDlg:SetSellCount(num, sell)
    if num == 0 then
        self("txCostGiftsO").text = "不可出售"
        self("imgCostGiftsO").image = nil
    elseif num == 1 then
        self("txCostGiftsO").text = sell
        self("imgCostGiftsO").image = "icon_jinbi.png"
    elseif num == 2 then
        self("txCostGiftsO").text = sell
        self("imgCostGiftsO").image = "icon_yibi.png"
    elseif num == 3 then
        self("txCostGiftsO").text = sell
        self("imgCostGiftsO").image = "icon_zuanshi.png"
    end
end


function VGiftsOpreateDlg:onBackClick()
    --    self:Parent():MsgCallBack(self, "MSGBOX")
    self:onClick()
end

--function VGiftsOpreateDlg:onSellClick()
--    cclog("sssssssssssss"..self.info.id.."~~~~~~~`"..self.info.thingid)
--    local node = VNode("vSellDlg.vui")
--    node:SetInfo(self.info)
--    gView():Push(node)
--end

function VGiftsOpreateDlg:onUseClick()
    cclog("uuuuuuuuuuuu"..self.info.id.."~~~~~~~`"..self.info.thingid)
    local level = gData:attrValue(AttrType.AttrTypeLevel)
    cclog("玩家等级:"..level.."~~~物品限制等级~~`"..self.info.levelLimit)
    if level < self.info.levelLimit then
        gWindow:showTip("玩家等级不足", 1);
        return
    end
        self:ReqItemUse()
    self:onClick()
end

function VGiftsOpreateDlg:ReqItemUse(parameters)
    local aParam = {}
    aParam.bagid = self.info.id
    aParam.itemid = self.info.thingid
    aParam.count = 1
    --        aParam.qulity = compound[5]

    gView()("bagDlg"):ReqItemUse(aParam)

end





function VCrystalOpreateDlg:onBuyClick()
    local shopDlg = gView()("shopDlg")
    shopDlg:BuyItem(self.info, self.shopAttr)
    self:onClick()
end

function VGiftsOpreateDlg:onClick()
    --    local currentView = gView(-2)
    --    if currentView then
    --        currentView.visible = 1
    --    end
    VGiftsOpreateDlg.super.onClick(self)
end