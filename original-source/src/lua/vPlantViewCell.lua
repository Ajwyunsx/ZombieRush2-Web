--vstoreCell.lua

require "vPieceOpreateDlg"
require "vCrystalOpreateDlg"
require "vGiftsOpreateDlg"



VPlantViewCell = VClass("PlantViewCell", VTableViewCell)

function VPlantViewCell:Recover(count, type)
    
    self.infos = {}

    for i = 1, count do
        local lyrPlantCell = self("lyrPlantCell"..i)
        lyrPlantCell.visible = 0
        lyrPlantCell("imgTipPlantC").visible = 0
        -- lyrPlantCell("imgbgPlantC").image = "carddiban1.png"
        lyrPlantCell("textItemCount").visible = 0
        local count = 5
    end
end


function VPlantViewCell:SetInfo(info, i, idx, var, openCount, type)

    
    local lyrPlantCell = self("lyrPlantCell"..i)
    if info then
        info.i = i
        info.idx = idx
        self.infos[i] = info
        lyrPlantCell("txNamePlantC").text = info.name;
        lyrPlantCell("imgItemPlantC").image = info.image or "baoxiang.png";
        lyrPlantCell("imgbgPlantC").image = "carddiban"..info.quality..".png" or "carddiban1.png"

        if (info.level or 0) > 0 then
            lyrPlantCell("starImg").visible = 1
            lyrPlantCell("txlevel").text = info.level
        else
            lyrPlantCell("starImg").visible = 0
        end
        
        local count = self:GetNewItemCount(info.id)
        if count ~= 0 then
            lyrPlantCell("imgTipPlantC").visible = 1
            lyrPlantCell("txTipPlantC").text = count
        end

        lyrPlantCell("txNamePlantC").color = gData:getNameColorByQuality(info.quality)
        lyrPlantCell("textItemCount").text = info.count

        lyrPlantCell.visible = 1
    end

end

function VPlantViewCell:GetNewItemCount(id)
    local userInfo = gData.userInfo
    if userInfo.plantInfos.newPlantCount[id] or userInfo.bagInfos.newCountItem[id] then
        return (userInfo.plantInfos.newPlantCount[id] or 0) + (userInfo.bagInfos.newCountItem[id] or 0)
    else
        return 0
    end
end


function VPlantViewCell:SetOutOpenCountItem(lyrPlantCell, i, idx, var, openCount)
    cclog("SetOutOpenCountItem~~~~i:"..i)
    if var == (openCount + 1) then
        lyrPlantCell("imgLockPlantC").onClick ="node:Parent(2):onLockClick("..idx..","..i..")"
        local time = gView()("PlantDlg"):SetNextRefreshTime(idx, i)
        self:SetNextRefreshTime(time, idx, i)
        lyrPlantCell("imgLockPlantC").visible = 1 
        --        lyrPlantCell("txTimePlantC").visible = 1
        --        lyrPlantCell("txTimelotteryDlg").visible = 1
        lyrPlantCell.lock = true
    elseif var > openCount then
        lyrPlantCell("imgLockPlantC").visible = 1
        lyrPlantCell("imgLockPlantC").onClick ="node:Parent(2):onLockClick("..idx..","..i..")"
        lyrPlantCell.lock = true
    else
        lyrPlantCell.lock = false
    end
end

function VPlantViewCell:SetNextRefreshTime(time, idx, i)
    local lyrPlantCell = self("lyrPlantCell"..i)
    cclog("SetNextRefreshTime~~~~i:"..i)
    if time ~= 0 then
        if not lyrPlantCell("txTimelotteryDlg").visible then
            lyrPlantCell("txTimePlantC").visible = 0
            lyrPlantCell("txTimelotteryDlg"):on_time(time)
            --        self("txTimelotteryDlg").time = self.time
            --        self("txTimelotteryDlg"):showTimeStamp()
            lyrPlantCell("txTimelotteryDlg").visible = 1
        end

        --        node("txTimePlantC").visible = 1
        --        node("txTimePlantC").color = {239,232,57}
        --        self:StartTimer("OnTime", 1, self.time - 1, 0)
        --        self:StartTimer("OnTime", self.time, 0, 0)
    else
        lyrPlantCell("txTimelotteryDlg").visible = 0
        lyrPlantCell("txTimePlantC").visible = 1
        --        node("txTimePlantC").text = "可开启"
        lyrPlantCell("imgLockPlantC").onClick = "node:Parent(2):onOpenClick("..idx..","..i..")"
    end
end

function VPlantViewCell:StopRefreshTime(idx, i)
    local lyrPlantCell = self("lyrPlantCell"..i)
    lyrPlantCell("txTimelotteryDlg").visible = 0
    lyrPlantCell("txTimePlantC").visible = 1
    lyrPlantCell("txTimelotteryDlg"):stopCountDown()

    --        node("txTimePlantC").text = "可开启"
    lyrPlantCell("imgLockPlantC").onClick = "node:Parent(2):onOpenClick("..idx..","..i..")"
end

--function VPlantViewCell:GetItemType(key)
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

function VPlantViewCell:onStoreCellClick(index)
    --    local expand = {["thingid"] = thingid, ["id"] = id}
    --    local csvData = gData:readCsv("prop_plant.csv");
    --    local type = csvData:lineDataWithKey(thingid, 9)
    local info = self.infos[index]

    if info == nil then
        return
    end
    local PlantDlg = gView()("PlantDlg");
    if PlantDlg then
        PlantDlg:SetCurrentOperatItem(info.idx, info.i)
    end

    self:RemoveNewItemCount(info)

    cclog("物品类型"..info.type)
    if self:getMsgBox() then
        --        self:getMsgBox().visible = 0
        if lock then
            --            gView():Push("vUnlockPlantItemDlg.vui")
            print("onStoreCellClick")
        elseif gFarm.touchPos.x == 0 then

            cclog("~~~~~~~~~~~"..info.type)
            local node = VNode("vCrystalOpreateDlg.vui")
            node:SetInfo(info, true)
            gView():Push(node)
      
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

function VPlantViewCell:RemoveNewItemCount(info)
    gData.userInfo.plantInfos:DeleteNewItem(info.id)
    gData.userInfo.bagInfos:DeleteNewItem(info.id)
    --    gData.userInfo.suitInfo:DeleteNewItem(info.id)

    local lyrPlantCell = self("lyrPlantCell"..info.i)
    lyrPlantCell("imgTipPlantC").visible = 0
end

function VPlantViewCell:onOpenClick(idx, i)
    gView()("PlantDlg"):SetCurrentOperatItem(idx, i)
    --    local count = gView()("PlantDlg").rowCount
    --    local openCount = gView()("PlantDlg").openCount
    --    if (openCount + 1) ==  (idx * count + i) then
    local aParam = {}
    aParam.type = 1
    aParam.count = 1
    gView()("PlantDlg"):ReqPlantExtend(aParam)
    --    else
    --        
    --    end
end

function VPlantViewCell:onLockClick(idx, i)

    gView()("PlantDlg"):SetCurrentOperatItem(idx, i)
    gView():Push("vUnlockPlantItemDlg.vui")
end