--vShopCell.lua
require "vShopItemDlg"
require "vPieceOpreateDlg"
require "vCrystalOpreateDlg"
require "vGiftsOpreateDlg"



VShopCell = VClass("vShopCell", VTableViewCell)

function VShopCell:reload(idx, i, item)
    self.level = idx
    self:Recover(i);
    if not item then return end;
    
    local lyrShopCell = self("lyrShopCell"..i);
    
    if idx == 0 then
        self("imgbg").image = "huojia1.png";
        self("imgbg").offset = {1.7,0}
        lyrShopCell("textItemCount").offset = {0,3}
    end
    
    
    
    lyrShopCell.visible = 1;
    
    self.infos[i] = item;
    
    lyrShopCell.onClick = "node:Parent():onShopClick("..idx..","..i..")"
    
    if item.isBought then
        lyrShopCell.onClick = nil
        lyrShopCell("imgstratShopC").visible = 1
        lyrShopCell("imgItemShopC").gray = 1
--        lyrShopCell("txstratShopC").visible = 1
--        lyrShopCell("imgCostTypeNShopC").visible = 0
--        lyrShopCell("txCostNShopC").visible = 0
    end

    if item.discount < 10 then
        lyrShopCell("imgdisShopC").visible = 1
        lyrShopCell("txdisShopC").text = item.discount.."折"
    end
    
    
    
    lyrShopCell("txNameShopC").text = item.itemName;
    lyrShopCell("imgItemShopC").image = item.itemImage or "baoxiang.png";
    
--    if item.type <= 2 then
--        cellItem("imgPlantShopC").image = item.itemImage.."L.png";
--    end
    
--    lyrShopCell("txNameShopC").color = gData:getNameColorByQuality(item.quality)
    lyrShopCell("textItemCount").text = "x"..item.itemCount;
    
    if self.shopType == 1 or self.shopType == 3 then  -------1是普通商店
        lyrShopCell("txCostNShopC").text = math.ceil(item.itemCost * item.discount / 10)
    else
        lyrShopCell("txCostNShopC").text = math.ceil(item.itemCost * item.discount)
    end

    lyrShopCell("imgCostTypeNShopC").image = gData:getResoureIconByID(item.price_type, item.price_effect_id)--self:GetImageWithType(item.costType)
end

--function VShopCell:UpdataItem(i)
--    local cellItem = self("lyrShopCell"..i);
--    
--end

function VShopCell:GetImageWithType( itype )
    -- body
    if itype == 1 then
        return "icon_jinbi.png"
    elseif itype == 2 then
        return "icon_yibi.png"
    elseif itype == 3 then
        return "icon_zuanshi.png"
    elseif itype == 0 then
        return ""
    elseif itype == 4 then
        return "icon_jifen.png"
    end
end

function VShopCell:Recover(idx)
    self("imgbg").image = "huojia2.png";
    self("imgbg").offset = {0,0}
    local cellItem = self("lyrShopCell"..idx);
    cellItem("imgstratShopC").visible = 0
    cellItem("imgItemShopC").gray = 0
    cellItem("txstratShopC").visible = 0
    cellItem("imgCostTypeNShopC").visible = 1
    cellItem("txCostNShopC").visible = 1
    cellItem("textItemCount").offset = {0,5}
    cellItem("imgdisShopC").visible = 0
    cellItem.visible = 0
end

function VShopCell:lockCell(idx, i, lock)

end

function VShopCell:GetUnLockCost(idx, i)
    local rowCount = gView()("shopDlg").rowCount
--    local openCount = gView()("shopDlg").openCount
--    local count = (idx * rowCount + i) - openCount

    local csvData = gData:readCsv("prop_shop_extend.csv");
--    local YB = 0
    local YB = csvData:lineDataWithKey(idx * rowCount + i, 1);

--    for var = 1, count do
--        local lineData = csvData:lineDataWithKey(openCount + var);
--        YB = YB + lineData[2]
--    end

    return YB
end

function VShopCell:onShopClick(idx, i)
    local itemInfo = self.infos[i]
    if itemInfo.isBought then
        gWindow:showTip("已经卖光了", 0.5);
    else

        local data = VItemData:new()
        
        data:CreateWithShopData(itemInfo)
        
        local shopAttr = {}
        shopAttr.idx = idx
        shopAttr.i = i
        shopAttr.type = self.shopType
        shopAttr.id = data.id
        
--        if data.type == 1 then
        local node = VNode("vShopItemDlg.vui")
            node:SetInfo(data, shopAttr)
            gView():Push(node)

        gAudio:playEffect("sys_msgbox_open.ogg");
    end
end
