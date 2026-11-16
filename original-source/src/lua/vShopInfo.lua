--vShopInfo.lua

VShopItem = vclass("ShopItem")
function VShopItem:synWithPbData(pbData)
	local needUpdate = false;
    if self.scheme ~= pbData.scheme then
        needUpdate = true;
    end

	self.scheme = pbData.boxid;
	self.isBought = pbData.isBought;

    self.thingid = pbData.itemid or 3101;
--    self.itemName = shopProp[2];
    self.itemCount = pbData.count or 1;
    -- self.shopType = 1
    self.discount = (pbData.discount or 1)
    self.itemType = pbData.item_type or 2;

    -- self.sellType = pbData.price_type;
    -- self.itemSell = pbData.boxid;
    self.price_type = pbData.price_type or 1;

    self.price_effect_id = pbData.price_effect_id or 21;

    self.itemCost = (pbData.price_effect_value or 50)  * self.itemCount;

    -- optional uint32 boxid = 10; //第几格
    -- optional bool isBought = 20; //是否售罄
    -- optional uint32 item_type = 30; //商品类型
    -- optional uint32 itemid = 40;
    -- optional uint32 count = 50;
    -- optional uint32 discount = 60; //折扣(1-10)
    -- optional uint32 price_type = 70;
    -- optional uint32 price_effect_id = 80;
    -- optional uint32 price_effect_value = 90;

	-- if needUpdate then
		-- self:loadCsvData();

        self:loadItemCsv()
	-- end
end

function VShopItem:loadCsvData()
	if not self.scheme then return end;
    -- local csvShop = gData:readCsv("prop_shop.csv");
    -- local shopProp = csvShop:lineDataWithKey(self.scheme);

    local csvShop = gData:LoadShopCsv()

    local shopProp = csvShop[""..self.scheme]
    
    if not shopProp then
        gLog("prop_shop.csv miss ID:%d", self.scheme);
        return;
    end
    self.thingid = shopProp[1];
--    self.itemName = shopProp[2];
    self.itemCount = shopProp[2];
    self.shopType = shopProp[4];
    self.discount = shopProp[5]/100;
    self.itemType = shopProp[6]
    
    if self.itemType == 2 then
        self:loadItemCsv()
    elseif self.itemType == 3 then
--        self:loadSuitCsv()
    elseif self.itemType == 4 then     
        
    end
    
    -- self.displayPrice = self.itemCost * self.discount;
end

function VShopItem:loadItemCsv(parameters)
    -- local csvItem = gData:readCsv("prop_item.csv");
    -- local itemProp = csvItem:lineDataWithKey(self.thingid);

    local csvItem = gData:LoadItemCsv()

    local itemProp = csvItem[""..self.thingid]

    if not itemProp then
        gLog("prop_item.csv miss ID:%d", self.thingid)
        return;
    end

    self.itemName = itemProp.name;
    self.type = itemProp.clientResType;
    self.sellType = itemProp.sellType
    self.itemSell = itemProp.sell
    -- self.costType = itemProp.costType
    -- self.itemCost = itemProp.cost * self.itemCount;
    self.itemImage = itemProp.image;
    self.itemDesc = itemProp.desc;
    self.quality = itemProp.quality;
    if self.type == 7 then
        self.equipment = VEquipmentInfo:new();
        local csv_pe = gData:readCsv("prop_equipment.csv");
        if csv_pe == nil then
            cclog("prop_equipment.csv miss")
            return
        end
        
        local prop_pe = csv_pe:lineDataWithKey(self.thingid);
        self.equipment:loadDataWithProp(prop_pe);
         
    end
end

function VShopItem:loadSuitCsv(parameters)
    local csvItem = gData:readCsv("prop_suit.csv");
    local itemProp = csvItem:lineDataWithKey(self.thingid);
    if not itemProp then
        gLog("prop_suit.csv miss ID:%d", self.thingid)
        return;
    end
    self.itemName = itemProp[1];
    self.hp = itemProp[4]
    self.atc = itemProp[5]
    self.def = itemProp[6]
    self.speed = itemProp[7]
    self.type = 4
    self.sellType = itemProp[8]
    self.itemSell = itemProp[9]
    self.costType = itemProp[10]
    self.itemCost = itemProp[11] * self.itemCount;
    self.itemImage = itemProp[12];
    self.itemDesc = itemProp[13];
    self.quality = 1--itemProp[11];
end

function VShopItem:loadPlantCsv(parameters)
    local plantOutCsv = gData:readCsv("prop_plant.csv");
    local plantOut = plantOutCsv:lineDataWithKey(self.thingid);
    if not plantOut then 
        gLog("prop_plant.csv miss ID:%d", self.thingid);
        return;
    end

    local descCsv = gData:readCsv("plant_desc.csv");
    local desc = descCsv:linesWithKeyRowValues(plantOut.classType, plantOut.quality);
    if not desc then 
        gLog("vShopInfo plant_desc.csv miss ID:%d", self.thingid);
        return;
    end
    self.itemName = desc.name;
    self.itemImage = desc.image;
    self.itemDesc = desc.description;
    self.itemCost = desc.buyPrice * self.itemCount;
    self.costType = desc.buyType;
    self.itemSell = desc.sellPrice;
    self.sellType = desc.sellType;
    self.quality = desc.quality;
    
    self.type = self:GetPlantType()
    if self.type == 0 then
        self.isWarPlant = true;
    end

    if not self.isWarPlant then
        local productCsv = gData:readCsv("plant_product.csv");
        local product = productCsv:lineDataWithKey(self.thingid);
        self.growSpeedHour = product.produceSpeed
        self.growSpeedSec = product.produceSpeed/3600;
        self.growMax = product.produceMax;       
    end

    local plantWarCsv = gData:readCsv("prop_creature_plant.csv");
    local plantWar = plantWarCsv:lineDataWithKey(self.thingid);
    if not plantWar then
        gLog("prop_creature_plant.csv miss ID:%d", self.thingid);
        return;
    end

    self.hp = plantWar.hp;
    self.atc = plantWar.atk;
    self.def = plantWar.def;
    self.aspd = plantWar.aspd;
end

function VShopItem:GetPlantType()
    local productCsv = gData:readCsv("plant_product.csv");
    local product = productCsv:lineDataWithKey(self.thingid);
    if not product then 
        return 0
    else
        return product.produceType
    end
end

----------------------------------------------

VShopInfo = vclass("ShopInfo")

function VShopInfo:synWithPbData(pbData)
	self.expireTime = pbData.expire_time;
	self.shopItems = {};
	if pbData.infos then
		local iter = VDataIter();
	    while pbData.infos:Travel(iter) do
	    	local item = VShopItem:new();
	    	item:synWithPbData(iter:Data());
	    	table.insert(self.shopItems, item);
	    end
	end
end

----------------------------------------------

VRoleShopInfo = vclass("RoleShopInfo")

function VRoleShopInfo:synWithPbData(pbData)
	self.shopItemCount = pbData.shop_item_count;
	if pbData.shop_info then
		self.shopInfo = VShopInfo:new();
		self.shopInfo:synWithPbData(pbData.shop_info);
	end

	if pbData.secret_shop_info then
		self.secretShop = VShopInfo:new();
		self.secretShop:synWithPbData(pbData.secret_shop_info);
	end
end