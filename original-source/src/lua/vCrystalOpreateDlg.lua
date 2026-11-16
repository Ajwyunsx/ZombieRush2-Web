--VCrystalOpreateDlg.lua
require "vSellDlg"

VCrystalOpreateDlg = VClass("CrystalOpreateDlg", VMsgBox)

function VCrystalOpreateDlg:onPush(parameters)
    self("artUp"):play("idle")
    local data = self.info
    self:ShowDlg(data)
end

function VCrystalOpreateDlg:ShowDlg(data)
    self("btnSellCrystalO").visible = self.isbag
    -- self("btnCostCrystalO").visible = not self.isbag
    if not self.isbag then
        self("txCostD1CrystalO").visible = 1
        self("imgCostCrystalO").visible = 1
        self("txCostCrystalO").visible = 1
        self("lyBt").offset = {0,-23} 
    end

    self("txdescribeCrystalO").text = data.desc
    self("txnameCrystalO").text = data.name
--    self("txTitleCrystalO").color = gData:getNameColorByQuality(data.quality)
    self("imgDexCrystalO").image = data.image

    self("imgDexCrystalO").scale = gData:GetFitScale(self("imgDexCrystalO"), self("imgDexDCrystalO"))

    self("txDexCrystalO").text = data.count
    self:SetSellCount(data.costType, data.cost)
    if data.costType ~= 0 then
        self:SetSellCount(data.costType, data.cost)
    else
        self("btnSellCrystalO").touch = 0
        self("btnSellCrystalO").gray = 1
    end
end

function VCrystalOpreateDlg:SetInfo(info, isbag, shopAttr)
    self.info = info
    self.isbag = isbag
    self.shopAttr = shopAttr
end

function VCrystalOpreateDlg:SetSellCount(num, sell)
    if num == 0 then
        self("txCostCrystalO").text = "不可出售"
        self("imgCostCrystalO").image = nil
    elseif num == 1 then
        self("txCostCrystalO").text = sell
        self("imgCostCrystalO").image = "icon_jinbi.png"
    elseif num == 2 then
        self("txCostCrystalO").text = sell
        self("imgCostCrystalO").image = "icon_yibi.png"
    elseif num == 3 then
        self("txCostCrystalO").text = sell
        self("imgCostCrystalO").image = "icon_zuanshi.png"
    end
end


function VCrystalOpreateDlg:onBackClick()
    --    self:Parent():MsgCallBack(self, "MSGBOX")
    self:onClick()
end

function VCrystalOpreateDlg:onSellClick()
    cclog("sssssssssssss"..self.info.id.."~~~~~~~`"..self.info.thingid)
    local node = VNode("vSellDlg.vui")
    node:SetInfo(self.info)
    gView():Push(node)
    self:onClick()
end

function VCrystalOpreateDlg:onBuyClick()
    local shopDlg = gView()("shopDlg")
    shopDlg:BuyItem(self.info, self.shopAttr)
    self:onClick()
end


function VCrystalOpreateDlg:onClick()
    --    local currentView = gView(-2)
    --    if currentView then
    --        currentView.visible = 1
    --    end
    VCrystalOpreateDlg.super.onClick(self)
end