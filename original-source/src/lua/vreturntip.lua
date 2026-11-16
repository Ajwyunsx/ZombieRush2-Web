--vreturntip.lua

VReturnTip = VClass("ReturnTip", VMsgBox)

function VReturnTip:Init(attr)
	VMsgBox.Init(self, attr);
	self.itemList = {};
end

function VReturnTip:onPush()
	self.tableList = self("tabItemList");
	self.tableList.delegate = self;

	if #self.itemList ~= 0 then
		self.tableList.number = #self.itemList;
		self.tableList:reloadData();
	end
end

function VReturnTip:onCell(idx, vTable, cell)
	if vTable == self.tableList then
		local itemInfo = self.itemList[idx+1];
		if itemInfo then
			cell("texItemName").text = itemInfo[1];
			cell("imgItemIcon").image = itemInfo[2];
			cell("texItemAmount").text = itemInfo[3];
		end
	end
end

function VReturnTip:setReturnInfo(returnInfo)
	if not returnInfo then return end;
	self.itemList = {};
	local iter = VDataIter();
	-- if returnInfo.rais then
	-- 	local roleInfo = gData.userInfo.roleInfo;
	-- 	while returnInfo.rais:Travel(iter) do
	--     	local item = iter:Data();
	--     	local itemIcon = "sun.png";
	--     	local itemName = "";
	-- 		if item.type == AttrType.AttrTypeExp then
	--     	elseif item.type == AttrType.AttrTypeLevel then
	--     	elseif item.type == AttrType.AttrTypeCurrency then
	--     	elseif item.type == AttrType.AttrTypeStamina then
	--     	elseif item.type == AttrType.AttrTypeCharge then
	--     	elseif item.type == AttrType.AttrTypeBattleScore then
	--     	elseif item.type == AttrType.AttrTypeMoney then
	--     		itemIcon = "jinbishaoxiaotubiao.png";
	--     		itemName = "金币";
	--     	elseif item.type == AttrType.AttrTypeSunshine then
	--     		itemName = "阳光";
	--     	end
	--     	local itemInfo = {itemName, itemIcon, item.value};
	--     	table.insert(self.itemList, itemInfo);
	-- 	end
	-- end

	-- iter = VDataIter();
	if returnInfo.rtis then
		while returnInfo.rtis:Travel(iter) do
	    	local item = iter:Data();
	    	if item.type == ThingType.ThingTypeItem then
	    		local itemCsvInfo = gData:itemInfo(item.thingid);
	    		local amount = item.count;
	    		if itemCsvInfo then
	    			local itemInfo = {itemCsvInfo.name, "sun.png", amount};
	    			table.insert(self.itemList, itemInfo);
	    		end
	    	elseif item.type == ThingType.ThingTypeSuit then
	    	elseif item.type == ThingType.ThingTypePlant then
	    		
	    	elseif item.type == ThingType.ThingTypeArm then
	    	elseif item.type == ThingType.ThingTypeWounded then
	    	elseif item.type == ThingType.ThingTypeDead then
	    	elseif item.type == ThingType.ThingTypeHeroExp then
	    	end
	    end
	end
end

