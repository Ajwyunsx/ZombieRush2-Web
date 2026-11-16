--vstoreCell.lua

require "vPieceOpreateDlg"
require "vCrystalOpreateDlg"
require "vGiftsOpreateDlg"


VBagTableViewCell = VClass("BagTableViewCell", VTableViewCell)

function VBagTableViewCell:Recover(count, type)
    self("imgbg").image = "huojia2.png";
    self("imgbg").offset = {0,0}
    self.infos = {}
    
    for i = 1, count do
        local lyrBagCell = self("lyrBagCell"..i)
        lyrBagCell.visible = 0
        lyrBagCell("imgTipBagC").visible = 0
        lyrBagCell("textItemCount").offset = {0,5}
        
    end
end


function VBagTableViewCell:SetInfo(info, i, idx, var, openCount, type)
    self.level = idx
    local lyrBagCell = self("lyrBagCell"..i)
    
    if idx == 0 then
        self("imgbg").image = "huojia1.png";
        self("imgbg").offset = {1.7,0}
        lyrBagCell("textItemCount").offset = {0,3}
    end
    
    if info then
        info.i = i
        info.idx = idx
        self.infos[i] = info
        lyrBagCell("txNameBagC").text = info.name;
        lyrBagCell("imgItemBagC").image = info.image or "baoxiang.png";

        --    if item.type <= 2 then
        --        cellItem("imgPlantShopC").image = item.itemImage.."L.png";
        --    end
        local count = self:GetNewItemCount(info)
        if count ~= 0 then
            lyrBagCell("imgTipBagC").visible = 1
            lyrBagCell("txTipBagC").text = count
        end

--        lyrBagCell("txNameBagC").color = gData:getNameColorByQuality(info.quality)
        lyrBagCell("textItemCount").text = "x"..info.count
        
        lyrBagCell.visible = 1
    end
--    cclog("SetInfo~~~~i:"..i)
--    if info ~= nil then
--        
--        --    lyrBagCell:ReLayout()
--        lyrBagCell.lock = false
--        lyrBagCell("lyBagC").visible = 1
----        lyrBagCell("lyBagC").id = info.id
----        lyrBagCell("lyBagC").thingid = info.thingid
--        lyrBagCell.attr = info
--        lyrBagCell.attr.i = i
--        lyrBagCell.attr.idx = idx
--        lyrBagCell("txCountBagC").text = "x"..info.count
--        lyrBagCell("imgPlantBagC").image = info.image
--        lyrBagCell("txNameBagC").text = info.name
--        lyrBagCell("txNameBagC").color = gData:getNameColorByQuality(info.quality)
--        local count = self:GetNewItemCount(info.id)
--        if count ~= 0 then
--            lyrBagCell("imgTipBagC").visible = 1
--            lyrBagCell("txTipBagC").text = count
--        end
--        if type == "ALL" then
--            self:SetOutOpenCountItem(lyrBagCell, i, idx, var, openCount)
--        end
--    elseif type == "ALL" then
--        self:SetOutOpenCountItem(lyrBagCell, i, idx, var, openCount)
--    else
--        lyrBagCell.visible = 0
--    end
end

function VBagTableViewCell:GetNewItemCount(info)
    local id = info.id
    local userInfo = gData.userInfo
    if userInfo.plantInfos.newPlantCount[id] or userInfo.bagInfos.newCountItem[id] then
        local newPlantCount = userInfo.plantInfos.newPlantCount[id] or 0
        if newPlantCount > 0 then
            newPlantCount = math.min(userInfo.plantInfos.newPlantCount[id], info.limit)
            userInfo.plantInfos.newPlantCount[id] = userInfo.plantInfos.newPlantCount[id] - newPlantCount
        end
        
        local newCountItem = userInfo.bagInfos.newCountItem[id] or 0
        if newCountItem > 0 then
            newCountItem = math.min(userInfo.bagInfos.newCountItem[id], info.limit)
            userInfo.bagInfos.newCountItem[id] = userInfo.bagInfos.newCountItem[id] - newCountItem
        end
        
        return newPlantCount + newCountItem
	else
	    return 0
	end
end


function VBagTableViewCell:SetOutOpenCountItem(lyrBagCell, i, idx, var, openCount)
    cclog("SetOutOpenCountItem~~~~i:"..i)
    if var == (openCount + 1) then
        lyrBagCell("imgLockBagC").onClick ="node:Parent(2):onLockClick("..idx..","..i..")"
        local time = gView()("bagDlg"):SetNextRefreshTime(idx, i)
        self:SetNextRefreshTime(time, idx, i)
        lyrBagCell("imgLockBagC").visible = 1 
--        lyrBagCell("txTimeBagC").visible = 1
--        lyrBagCell("txTimelotteryDlg").visible = 1
        lyrBagCell.lock = true
    elseif var > openCount then
        lyrBagCell("imgLockBagC").visible = 1
        lyrBagCell("imgLockBagC").onClick ="node:Parent(2):onLockClick("..idx..","..i..")"
        lyrBagCell.lock = true
    else
        lyrBagCell.lock = false
    end
end

function VBagTableViewCell:SetNextRefreshTime(time, idx, i)
    local lyrBagCell = self("lyrBagCell"..i)
    cclog("SetNextRefreshTime~~~~i:"..i)
    if time ~= 0 then
        if not lyrBagCell("txTimelotteryDlg").visible then
        lyrBagCell("txTimeBagC").visible = 0
            lyrBagCell("txTimelotteryDlg"):on_time(time)
        --        self("txTimelotteryDlg").time = self.time
        --        self("txTimelotteryDlg"):showTimeStamp()
        lyrBagCell("txTimelotteryDlg").visible = 1
        end

        --        node("txTimeBagC").visible = 1
        --        node("txTimeBagC").color = {239,232,57}
        --        self:StartTimer("OnTime", 1, self.time - 1, 0)
--        self:StartTimer("OnTime", self.time, 0, 0)
    else
        lyrBagCell("txTimelotteryDlg").visible = 0
        lyrBagCell("txTimeBagC").visible = 1
        --        node("txTimeBagC").text = "可开启"
        lyrBagCell("imgLockBagC").onClick = "node:Parent(2):onOpenClick("..idx..","..i..")"
    end
end

function VBagTableViewCell:StopRefreshTime(idx, i)
    local lyrBagCell = self("lyrBagCell"..i)
    lyrBagCell("txTimelotteryDlg").visible = 0
    lyrBagCell("txTimeBagC").visible = 1
    lyrBagCell("txTimelotteryDlg"):stopCountDown()
    
    --        node("txTimeBagC").text = "可开启"
    lyrBagCell("imgLockBagC").onClick = "node:Parent(2):onOpenClick("..idx..","..i..")"
end


--function VBagTableViewCell:GetItemType(key)
--    local itemType = nil
--    local csvData = gData:readCsv("prop_plant.csv")
--    local lineData = csvData:lineDataWithKey(key)
--
--    if not lineData then
--        csvData = gData:readCsv("prop_item.csv");
--        lineData = csvData:lineDataWithKey(key)
--        if not lineData then
--            csvData = gData:readCsv("prop_suit.csv");
--            lineData = csvData:lineDataWithKey(key)
--            itemType
--        else 
--            itemType = lineData.description
--        end
--    else
--        itemType = lineData.produceSpeed
--    end
--
--    return itemType
--end

function VBagTableViewCell:onStoreCellClick(index)
--    local expand = {["thingid"] = thingid, ["id"] = id}
--    local csvData = gData:readCsv("prop_plant.csv");
--    local type = csvData:lineDataWithKey(thingid, 9)
    local info = self.infos[index]
    
    if info == nil then
        return
    end
    local bagDlg = gView()("bagDlg");
    if bagDlg then
        bagDlg:SetCurrentOperatItem(info.idx, info.i)
    end
    
    self:RemoveNewItemCount(info)
    
    cclog("物品类型"..info.type)
    if self:getMsgBox() then
--        self:getMsgBox().visible = 0
        if lock then

            print("onStoreCellClick")
        elseif gFarm.touchPos.x == 0 then
            
            cclog("~~~~~~~~~~~"..info.type)
            if info.type == 1 then
                local node = VNode("vCrystalOpreateDlg.vui")
                    node:SetInfo(info, true)
                    gView():Push(node)
            elseif info.type == 2 then
                local node = VNode("vGiftsOpreateDlg.vui")
                node:SetInfo(info, true)
                gView():Push(node)
            elseif info.type == 3 then
                local node = VNode("vPieceOpreateDlg.vui")
                node:SetInfo(info, true)
                gView():Push(node)
            end

            gAudio:playEffect("sys_msgbox_open.ogg");

        elseif gFarm.touchPos.x ~= 0 then
            gFarm:ReqManorPlantPlaceToFarm(info);
            self:getMsgBox():onClick()
            gAudio:playEffect("sys_plant_farm.ogg");
            gMainView:CheckNewBagItem()
--            gFarm:PutPlantToField(id)
        end
    end
end

function VBagTableViewCell:RemoveNewItemCount(info)
    gData.userInfo.bagInfos:DeleteNewItem(info.id)
    gData.userInfo.plantInfos:DeleteNewItem(info.id)
--    gData.userInfo.suitInfo:DeleteNewItem(info.id)
    
    local lyrBagCell = self("lyrBagCell"..info.i)
    lyrBagCell("imgTipBagC").visible = 0
end

function VBagTableViewCell:onOpenClick(idx, i)
    gView()("bagDlg"):SetCurrentOperatItem(idx, i)
--    local count = gView()("bagDlg").rowCount
--    local openCount = gView()("bagDlg").openCount
--    if (openCount + 1) ==  (idx * count + i) then
        local aParam = {}
        aParam.type = 1
        aParam.count = 1
        gView()("bagDlg"):ReqBagExtend(aParam)
--    else
--        
--    end
end