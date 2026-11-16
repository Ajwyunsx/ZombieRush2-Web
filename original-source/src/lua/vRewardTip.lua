VRewardTip = VClass("RewardTip", VMsgBox);

function VRewardTip:setItemInfo( itemInfo, title, desc, delegate, callBack)
	self.itemInfo = itemInfo;
	self.title = title;
	self.desc = desc;
	self.delegate = delegate;
	self.callBack = callBack;
end

function VRewardTip:onPush(  )
	self.curCount = #self.itemInfo;
	self.cellCount = 2;
	self.tbv = self("tbv");
	self.tbv.delegate = self;
	self.tbv.number = math.ceil(self.curCount/self.cellCount);
	if self.tbv.number < 2 then 
		self.tbv:setTouchEnabled(false);
	end

	if self.desc then
		self("tipText").text = self.desc;
	end

	self.tbv:reloadData();
	if self.title then 
		self("title").image = self.title;
	end
end


function VRewardTip:onCell( idx, t, cell )
	if not cell then 
		cell = VNode("vRewardTipCell.vui"); 
	end;
	if self.tbv.number == 1 then
		cell("layoutLayer").size = {360,125};
		cell("bgLayer").size = {180*self.curCount,70};
	end
	for i=1, self.cellCount do
		local n = idx * self.cellCount + i;
		local item = cell("itemLayer"..i);

		local info = self.itemInfo[n];
		if info then
			item.visible = 1;
			item("itemImg").image = info.image;
			item("itemName").text = info.name;
			item("countText").text = "数量:"..info.count;
			self:SetCellItemOnClick(item, info)
		else
			item.visible = 0;
		end
	end
end

function VRewardTip:onCellSize( idx, t )
	if self.tbv.number == 1 then
		return 360,125;
	end
	return 360,70;
end


function VRewardTip:SetCellItemOnClick( item, itemInfo )
	-- body
	if itemInfo.type == ThingType.ThingTypeArm then
		item.touch = 1
		item.onClick = "showCardInfoDlgById("..itemInfo.thingid..","..(2)..")"
	elseif itemInfo.type == ThingType.ThingTypePlant then
		item.touch = 1
		item.onClick = "showCardInfoDlgById("..itemInfo.thingid..","..(1)..")"
	else
		
	end
end

function VRewardTip:onPop()
	if self.delegate and self.callBack then
    	 VCallBack(self.delegate, self.callBack, nil);
   	end
end
