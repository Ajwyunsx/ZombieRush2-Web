
require "vEventEntryWebDlg"

VEventEntryCell = VClass("EventEntryCell", VTableViewCell)


function VEventEntryCell:reload(idx, i, data)
    self.data = data;
    local cell = self("imageCell"..i);
    cell.visible = 1;
    cell.image = data.image;
    local newVisible = 0;
    if gData.userInfo.eventEntryInfos:isNew(data.id) then
        cell("imageNew").visible = 1;
        newVisible = 1;
    else
        cell("imageNew").visible = 0;
    end

    if gData.userInfo.eventEntryInfos:isFinish(data.id) then
        cell("imageLj").visible = 1;
    else
        cell("imageLj").visible = 0;
    end
    cell.onClick = "node:Parent(1):openEventEntryView("..data.id..","..i..","..newVisible..")"
end

function VEventEntryCell:openEventEntryView(id, i, isNew)
    local p = VNode("vEventEntryWebDlg.vui");
    local data = gData.userInfo.eventEntryInfos:getInfo(id);
    p:setData(data);
    gView():Push(p);
    if isNew ~= 0 then
        local cell = self("imageCell"..i);
        cell("imageNew").visible = 0;
        gData:addReadEvents(id);
    end
end

function VEventEntryCell:lockCell(idx, i, lock)
    local cellItem = self("imageCell"..i);
    cellItem.lock = lock;
    if lock then
        cellItem.visible = 0
    else
        cellItem.visible = 1
    end
end