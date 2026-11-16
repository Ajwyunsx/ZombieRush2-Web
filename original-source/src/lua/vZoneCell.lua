--vZoneCell.lua

VZoneCell = VClass("ZoneCell", VTableViewCell)

function VZoneCell:reloadItem(item, i)
	local zoneBg = self("zoneBg"..i);
	local nameLabel = zoneBg("zoneName");
	local stateLabel = zoneBg("zoneState");
	local numberLabel = zoneBg("zoneNumber");
	local zoneLine = zoneBg("zoneLine");
	
	if item then
		zoneBg.visible = 1;
		local zoneId = item[0];
		local zoneName = item[1];
		local zoneState = item[2];
		local zoneTag = item[3];
		if gZoneid == zoneId then
			zoneLine.visible = 1;
		else
			zoneLine.visible = 0;
		end
		zoneBg.zoneId = zoneId;
		nameLabel.text = zoneName;
		numberLabel.text = tostring(zoneId).."区";

		if zoneTag == 1 then
			stateLabel.text = "新区"	
			stateLabel.color = {255,168,0};
			numberLabel.color = {255,168,0};
			nameLabel.color = {255,168,0};
		else
			if zoneState > 80 then
				stateLabel.text = "爆满"
				stateLabel.color = {255,0,0};
				numberLabel.color = {255,218,45};
				nameLabel.color = {255,218,45};
			elseif zoneState > 50 then
				stateLabel.text = "繁忙"
				stateLabel.color = {255,0,0};
				numberLabel.color = {255,218,45};
				nameLabel.color = {255,218,45};
			else
				stateLabel.text = "流畅"
				stateLabel.color = {66,234,7};
				numberLabel.color = {66,234,7};
				nameLabel.color = {66,234,7};
			end
		end
	else
		zoneBg.visible = 0;
		stateLabel.text = "";
		nameLabel.text = "";
		numberLabel.text = "";
	end
end
