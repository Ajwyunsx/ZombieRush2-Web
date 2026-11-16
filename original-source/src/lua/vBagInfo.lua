--vBagInfo.lua

VBagInfo = vclass("BagInfo")

function VBagInfo:initWithFakeData(thingid, amount)
    self.id = thingid;
    self.itemid = thingid;
    self.amount = amount;
    self.start = 0;
    self.fake = true;
    self:loadCsvData();
end

function VBagInfo:initialize()
    self.id = 0;
    self.itemid = 0;
    self.amount = 0;
    self.start = 0;
end

function VBagInfo:synWithPbData(pbData)
    local needUpdate = false;
    if self.itemid ~= pbData.info.bi.itemid then
        needUpdate = true;
    end
    
	self.id = pbData.info.bi.id;
	self.itemid = pbData.info.bi.itemid;
	self.amount = pbData.info.bi.amount;
	self.start = pbData.info.bi.start;
    self.fake = nil;
	
    if needUpdate then
        self:loadCsvData();
    end
end

function VBagInfo:loadCsvData()
    if not self.itemid then return end;
    -- local itemOutCsv = gData:readCsv("prop_item.csv");
    -- local itemOut = itemOutCsv:lineDataWithKey(self.itemid);

    local itemOutCsv = gData:LoadItemCsv()

    local itemOut = itemOutCsv[""..self.itemid]
    
    if not itemOut then 
        return gLog("item %d not found ", self.itemid);
    end
    
    cclog("物品信息读表")
    
    self.itemName = itemOut.name;
    self.itemImage = itemOut.image;
    self.limit = itemOut.coutLimit;
    self.isUse = itemOut.isUse;
    self.sellType = itemOut.sellType;
    self.sell = itemOut.sell;
    self.costType = itemOut.costType;
    self.cost = itemOut.cost;
    self.itemDesc = itemOut.desc;
    self.quality = itemOut.quality;
    self.levelLimit = itemOut.levelLimit;
    self.resType = itemOut.clientResType;
    self.sort = itemOut.sort;
    self.isShow = itemOut.isShow;
    
--    if self.resType == 7 then
--        self.equipment = VEquipmentInfo:new();
--        local csv_pe = gData:readCsv("prop_equipment.csv");
--        if csv_pe == nil then
--            cclog("prop_equipment.csv miss")
--            return
--        end
--        local prop_pe = csv_pe:lineDataWithKey(self.itemid);
--
--        self.equipment:loadDataWithProp(prop_pe);
--    end
--
--    --进阶卡
--    if self.resType == 8 then
--        local ti = gData.userInfo.armyTechInfos.techInfos;
--        local cardCsv = gData:readCsv("item_monster_advance.csv");
--        local shopProp = cardCsv:lineDataWithKey(self.itemid);
--        if shopProp == nil then
--            cclog("item_monster_advance miss key:%d", self.itemid)
--            return false
--        end
--        self.advanceInfo = {};
--        self.advanceInfo.mid = shopProp[1];
--        self.advanceInfo.quality = shopProp[2];
--        
--        cclog("进阶卡id:x = %f, 科技品质:y = %f, 进阶卡品质:z = %f", self.itemid, ti[self.advanceInfo.mid].quality, self.advanceInfo.quality)
--        
--        if ti[self.advanceInfo.mid]:isDeblock() and ti[self.advanceInfo.mid].quality < self.advanceInfo.quality then
--            self.advanceInfo.canUsed = true;
--        else
--            self.advanceInfo.canUsed = false;
--        end
--    end
end


function VBagInfo:CheckAdvance()
    if self.resType == 8 then
        local ti = gData.userInfo.armyTechInfos.techInfos;
        local cardCsv = gData:readCsv("item_monster_advance.csv");
        local shopProp = cardCsv:lineDataWithKey(self.itemid);
        if shopProp == nil then
            cclog("item_monster_advance miss key:%d", self.itemid)
            return 0
        end
        self.advanceInfo = {};
        self.advanceInfo.mid = shopProp[1];
        self.advanceInfo.quality = shopProp[2];

        cclog("进阶卡id:x = %f, 科技品质:y = %f, 进阶卡品质:z = %f", self.itemid, ti[self.advanceInfo.mid].quality, self.advanceInfo.quality)

        if ti[self.advanceInfo.mid]:isDeblock() and ti[self.advanceInfo.mid].quality < self.advanceInfo.quality then
            return 1;
        elseif not (ti[self.advanceInfo.mid].quality < self.advanceInfo.quality) then
            return 3;
        else
            return 2
        end
    else
        return 0
    end
end


function VBagInfo:addCount(count)
    self.amount = self.amount + count;
    if self.amount < 0 then
        self.amount = 0;
    end
end



-----------------------------------------------------

VBagManager = vclass("BagManager")

function VBagManager:initialize()
	self.bagItems = {};
	self.newCountItem = {}
	self.newCount = 0
end

function VBagManager:synWithPbData(pbData)
	local infos = pbData.infos;
	local iter = VDataIter();
    while infos:Travel(iter) do
    	local exBagItem = iter:Data();
    	if exBagItem.ctrl.op == _VCtrlOP.None or 
    		exBagItem.ctrl.op == _VCtrlOP.Rep or
    		exBagItem.ctrl.op == _VCtrlOP.Add then
    		if not self.bagItems[exBagItem.info.bi.id] then
    			self.bagItems[exBagItem.info.bi.id] = VBagInfo:new();
    		end
    		self.bagItems[exBagItem.info.bi.id]:synWithPbData(exBagItem);
    	elseif exBagItem.ctrl.op == _VCtrlOP.Del then
    		self.bagItems[exBagItem.info.bi.id] = nil;
    	end
    end
    -- self:checkPackageEvent();
    
end

function VBagManager:itemCount()
	local count = 0;
	for k,v in pairs(self.bagItems) do
		count = count + 1;
	end
	return count;
end

function VBagManager:addItem(id, thingid, amount)
    if not self.bagItems[id] then
        if amount > 0 then
            local newItem = VBagInfo:new();
            newItem.id = id;

            newItem.itemid = thingid;
            
            newItem.amount = amount;
            newItem:loadCsvData();
            self.bagItems[id] = newItem;

            -- local level = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeLevel);
            -- if newItem.resType == 6 and level >= v.levelLimit then
            --     gEvent:pushEvent(EventId.package_on);
            -- end
        end
    else
        self.bagItems[id]:addCount(amount);
        if self.bagItems[id].amount == 0 then
            self:removeItem(id);
        end
    end
    
    self:AddNewItem(id, thingid, amount)
    
end

function VBagManager:AddNewItem(id, thingid, amount)
	if amount > 0 then
        self.newCount = self.newCount + amount
        
        if not self.newCountItem[id] then
            self.newCountItem[id] = amount
        else
            self.newCountItem[id] = self.newCountItem[id] + amount
        end
        
        if gMainView then
            gMainView:CheckNewBagItem()
        end
    end
end

function VBagManager:DeleteNewItem(id)
	if self.newCountItem[id] then
	    self.newCountItem[id] = nil
	    self.newCount = self.newCount - 1
	end
end

function VBagManager:addItemThingid(thingid, amount)
    local itemInfo = self:itemThingid(thingid);
    if itemInfo then
        itemInfo:addCount(amount);
    end
end

function VBagManager:GetSortbagItems(parameters)
   

    local bags = {}

    for key, var in pairs(self.bagItems) do
        table.insert(bags, var)
    end

    table.sort(bags,
        function(a,b)
            return a.sort < b.sort;
        end);
        
    return bags
    
end

function VBagManager:itemCountThingid(thingid)
    local itemInfo = self:itemThingid(thingid);
    if itemInfo then
        return itemInfo.amount;
    end
    return 0;
end

function VBagManager:itemThingid(thingid)
    local itemInfo = nil;
    for k,v in pairs(self.bagItems) do
        if v.itemid == thingid then
            itemInfo = v;
        end
    end
    return itemInfo;
end

function VBagManager:removeItem(id)
    self.bagItems[id] = nil;
end


-- function VBagManager:getEquipmentItems(id)
--     local equipmentItems = {}; --1,头；2，手；3，身体；4，脚
--     equipmentItems[1] = {}; 
--     equipmentItems[2] = {};
--     equipmentItems[3] = {};
--     equipmentItems[4] = {};
--     local csv_pe = gData:readCsv("prop_equipment.csv");

--     for i,v in pairs(self.bagItems) do
--         if v.resType == 7 then
--             local prop_pe = csv_pe:lineDataWithKey(v.itemid);
--             local monsterid = prop_pe[4];
--             if monsterid == id then
--                 for i=1,v.amount do
--                     local equipment = VEquipmentInfo:new();
--                     equipment.id = v.id;
--                     equipment.thingid = v.itemid;
--                     equipment.posid = prop_pe[5];
--                     equipment.monsterid = prop_pe[4]
--                     equipment:loadDataWithProp(prop_pe);
--                     equipment.wear = false;
--                     table.insert(equipmentItems[equipment.posid],equipment);
--                 end
--             end
--         end
--     end
--     return equipmentItems;
-- end


function VBagManager:checkPackageEvent()
    local level = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeLevel);
    local event = false;
    for i,v in pairs(self.bagItems) do
        if v.resType == 6 and level >= v.levelLimit then
            event = true;
        end
    end
    if event then
        gEvent:pushEvent(EventId.package_on);
    else
        gEvent:pushEvent(EventId.package_off);
    end
end


