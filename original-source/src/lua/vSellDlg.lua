--vSellDlg.lua

VSellDlg = VClass("SellDlg", VMsgBox)

function VSellDlg:onPush(parameters)
     self("artUp"):play("idle")
    local data = self.info
    self("edtCountSell").inputMode = _VEditorInputMode.Number
    self.sellCount = data.count
    self:ShowDlg(data)
end

function VSellDlg:SetInfo(info)
	self.info = info
end

function VSellDlg:ShowDlg(data)
    self:SetSellCount(data.sellType, data.sell)
    self("edtCountSell").text = data.count
    self("txTitleSell").text = data.name
--    self("txTitleSell").color = gData:getNameColorByQuality(data.quality)
    self("imgPlantDexSell").image = data.image
    self("txPlantDexCountSell").text = "x"..data.count
    self:UpDataSellInfo()
end


function VSellDlg: SetSellCount(num, sell)
    if num == 0 then
--        image = "不可出售"
        self("txSellNumSell").text = "不可出售"
        self("imgSellSell").image = nil
    elseif num == 1 then
        self("txSellNumSell").text = sell
        self("imgSellSell").image = "icon_jinbi.png"
        self("imgGetSell").image = "icon_jinbi.png"
    elseif num == 2 then
        self("txSellNumSell").text = sell
        self("imgSellSell").image = "icon_yibi.png"
        self("imgGetSell").image = "icon_yibi.png"
    elseif num == 3 then
        self("txSellNumSell").text = sell
        self("imgSellSell").image = "icon_zuanshi.png"
        self("imgGetSell").image = "icon_zuanshi.png"
    end
end


function VSellDlg:AddSellCount()
    if self.sellCount == self.info.count then
        return
    end

    self.sellCount = self.sellCount + 1
    
    self:UpDataSellInfo()
end

function VSellDlg:SubSellCount()
    if self.sellCount == 1 then
        return
    end

    self.sellCount = self.sellCount - 1
    
    self:UpDataSellInfo()
end

function VSellDlg:MaxSellCount()
    self.sellCount = self.info.count

    self:UpDataSellInfo()
end

function VSellDlg:MinSellCount()

    self.sellCount = 1

    self:UpDataSellInfo()
end

function VSellDlg:UpDataSellInfo(parameters)
    local bagInfo = self.info--gData.userInfo.bagInfos.bagItems[self.info.id]

--    if bagInfo == nil then
--        bagInfo = gData.userInfo.plantInfos.plants[self.info.id]
--    end

    if bagInfo == nil then
        return
    end

--    if bagInfo.resType > 2 then
--        self("txGetNumSell").text = bagInfo.sell * self.sellCount
--    else
--        self("txGetNumSell").text = bagInfo.plantSell * self.sellCount
--    end
    self("txGetNumSell").text = bagInfo.sell * self.sellCount
    self("imgGetSell"):ReLayout()
    self("edtCountSell").text = self.sellCount
end

function VSellDlg:onBackClick()
    --    self:Parent():MsgCallBack(self, "MSGBOX")
    self:onClick()
end

function VSellDlg:onOKClick()
--    self:Parent():MsgCallBack(self, "MSGBOX")
--    self:onClick()
    local plantidUint64 = Var();
    plantidUint64:SetUint64(self.info.id);
    
    local count = self("edtCountSell"):getText()
    self.sellCount = tonumber(count)
    
    if self.sellCount == "" or self.sellCount <= 0 or self.sellCount == nil then
        gWindow:showTip("出售数量必须大于零", 1)
        return       
    end
    
    if self.sellCount > self.info.count then
        gWindow:showTip("出售数量不能超出拥有数量", 1)
        return       
    end
    
    local sells = {}
    local thingInfo = {}
    thingInfo.type = self.info.thingType
    thingInfo.id = plantidUint64
    thingInfo.count = self.sellCount
    
    table.insert(sells, thingInfo)
    gView()("bagDlg"):ReqThingSell(sells)
    
    self:onClick()
end

function VSellDlg:onClick()
    --    local currentView = gView(-2)
    --    if currentView then
    --        currentView.visible = 1
    --    end
    VSellDlg.super.onClick(self)
end