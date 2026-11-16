VItemData = vclass("FormatData");


function VItemData:CreateWithFarmData(data)  
    self:CreateWithPlantData(data.plantInfo)
    self.statusInfo = data.statusInfo
    self.farm = data
    self.posx = data.pos.x
    self.posy = data.pos.y
end


function VItemData:CreateWithPlantData(data)
    self.name = data.plantName--..data.plantLevel.."V"
    self.image = data.plantImage.."S.png"
    self.armture = data.plantImage
    self.level = data.plantLevel
    self.desc = data.plantDesc
    self.cost = data.plantCost
    self.sell = data.plantSell
    self.costType = data.costType
    self.sellType = data.sellType
    self.quality = data.quality
    self.id = data.id
    self.thingid = data.thingid
    self.life = data.plantLife
    self.atc = data.plantAtc
    self.def = data.plantDef
    self.aspd = data.plantAspd;
    self.count = 1
    self.type = data.resType
    self.classType = data.classType
    self.thingType = data.thingType
    self.isUse = 2
    self.quality = data.quality
    self.growSpeedHour = data.growSpeedHour
    self.growSpeedSec = data.growSpeedSec
    self.growMax = data.growMax
    self.accelerateValue = data.accelerateValue
    self.strengthenPoint = data.strengthenPoint
    self.sort = data.sort
    self.plant = data
end

function VItemData:CreateWithSuitData(data)
    self.name = data.materName
    self.image = data.image or "RW_Box.png"
    self.desc = data.desc
    self.cost = data.payPrice
    self.sell = data.sellPrice
    self.isUse = 2
    self.sellType = data.sellType
    self.costType = data.payType
    self.quality = data.quality
    self.id = data.id
    self.thingid = data.thingid
    self.life = data.hp
    self.atc = data.atk
    self.def = data.def
    self.speed = data.speed
    self.materType = data.materType
    self.count = 1
    self.type = 4
    self.suit = data
    
    self.sort = data.sort
    self.thingType = data.thingType
end

function VItemData:CreateWithMonster(data)
    self.name = data.name--..data.plantLevel.."V"
    self.image = data.image.."L.png"
    self.armture = data.image
    self.quality = data.quality
    self.level = data.level
    self.monster = data
end

function VItemData:CreateWithOtherData(data)
    self.name = data.itemName
    self.image = data.itemImage or "RW_Box.png"--data.itemImage.."Icon.png"
    self.desc = data.itemDesc
    self.cost = data.cost
    self.sell = data.sell
    self.isUse = data.isUse
    self.sellType = data.sellType
    self.costType = data.costType
    self.quality = data.quality
    self.id = data.id
    self.thingid = data.itemid
    --    itemData.life = var.life
    --    itemData.atc = var.plantAct
    --    itemData.def = var.plantDes
    self.count = data.amount
    self.type = data.resType
    self.limit = data.limit
    self.levelLimit = data.levelLimit
    self.thingType = ThingType.ThingTypeItem
    self.advanceInfo = data.advanceInfo
    self.sort = data.sort
    self.isShow = data.isShow
    if data.resType == 7 then    
            self.suitid = data.equipment.suitid
            self.monsterid = data.equipment.monsterid
            self.atc = data.equipment.atk
            self.def = data.equipment.def
        self.life = data.equipment.hp
            self.speed = data.equipment.speed
            self.bag = data
    end
end



function VItemData:CreateWithFriendData(data)
    self.userid = data.id or data.userid
    self.image = data.image
    self.level = data.level
    self.sex = data.sex
    self.nick = data.nick
    self.charge = data.charge
    self.friend = data
    self.last_login_time = data.last_login_time
end

function VItemData:CreateWithShopData(data)
    self.id = data.scheme
    self.thingid = data.thingid
    self.name = data.itemName
    self.desc = data.itemDesc
    self.image = data.itemImage or "RW_Box.png"
    self.itemType = data.itemType
    self.price_type = data.price_type;

    self.price_effect_id = data.price_effect_id;
    if data.itemType == 4 then
        self.image = data.itemImage.."L.png"
    end
    self.count = data.itemCount
    self.sell = data.itemSell
    self.discount = data.discount
    self.sellType = data.sellType
    self.cost = data.itemCost
    self.costType = data.costType
    self.quality = data.quality
    self.type = data.type
    self.life = data.hp;
    self.atc = data.atk;
    self.def = data.def;
    self.aspd = data.aspd;
    self.speed = data.speed
    if data.type == 7 then    
        self.suitid = data.equipment.suitid
        self.monsterid = data.equipment.monsterid
        self.atc = data.equipment.atk
        self.def = data.equipment.def
        self.life = data.equipment.hp
        self.speed = data.equipment.speed
        self.bag = data
    end
--    self.thingType = data.thingType
end



VFormatData = vclass("FormatData");

function VFormatData:InitAll(parameters)
    if self.all ~= nil then
        return
    end
    self.all = {}

--    local plants = gData.userInfo.plantInfos:GetSortPlant()
--    
--    
--    for key, var in ipairs(plants) do
--        local data = VItemData:new()
--        data:CreateWithPlantData(var)
--        data.posx = 0
--        data.posy = 0
--        table.insert(self.all, data)
--    end
--    
--
--    local suitInfos = gData.userInfo.suitInfo:GetSortsuits()
--    
--    for key, var in ipairs(suitInfos) do
--        local data = VItemData:new()
--        data:CreateWithSuitData(var)
--        data.posx = 0
--        data.posy = 0
--        table.insert(self.all, data)
--    end

    local bagInfos = gData.userInfo.bagInfos:GetSortbagItems()

    for key, var in ipairs(bagInfos) do
        if var.isShow  ~= 0 then
            local count = math.ceil(var.amount / var.limit)
            local tmp = var.amount
            for index = 1, count do
                local data = VItemData:new()
                data:CreateWithOtherData(var)
                data.count = math.min(var.limit, tmp)
                tmp = tmp - var.limit
                data.posx = 0
                data.posy = 0
            	table.insert(self.all, data)
            end
        end
    end
    
    table.sort(self.all,
        function(a,b)
            return a.sort < b.sort;
        end);
end

function VFormatData:InitGifts()
    if self.gifts ~= nil then
        return
    end
    
    local bagInfos = gData.userInfo.bagInfos:GetSortbagItems()
    
    self.gifts = {}
    
    for key, var in ipairs(bagInfos) do
        if var.isShow ~= 0 and var.resType == 2 then
            local count = math.ceil(var.amount / var.limit)
            local tmp = var.amount
            for index = 1, count do
                local data = VItemData:new()
                data:CreateWithOtherData(var)
                data.count = math.min(var.limit, tmp)
                tmp = tmp - var.limit
                data.posx = 0
                data.posy = 0
                table.insert(self.gifts, data)
            end
        end
    end

    table.sort(self.gifts,
        function(a,b)
            return a.sort < b.sort;
        end);
end


function VFormatData:InitProperty()
    if self.property ~= nil then
        return
    end
    local bagInfos = gData.userInfo.bagInfos:GetSortbagItems()

    self.property = {}

    for key, var in ipairs(bagInfos) do
        if var.isShow ~= 0 and var.resType == 1 then
            local count = math.ceil(var.amount / var.limit)
            local tmp = var.amount
            for index = 1, count do
                local data = VItemData:new()
                data:CreateWithOtherData(var)
                data.count = math.min(var.limit, tmp)
                tmp = tmp - var.limit
                data.posx = 0
                data.posy = 0
                table.insert(self.property, data)
            end
        end
    end

    table.sort(self.property,
        function(a,b)
            return a.sort < b.sort;
        end);
end



function VFormatData:InitFarmPlant()
    if self.farmPlants ~= nil then
        return
    end
    
    self.farmPlants = {}

    local farmInfos = gData.userInfo.manorInfo.farmInfos     

    for key, var in ipairs(farmInfos) do
        local data = VItemData:new()
        data:CreateWithFarmData(var)
        table.insert(self.farmPlants, data)
    end
end

function VFormatData:InitPlants()
    if self.plants ~= nil then
        return
    end

    self.plants = {}

    local plants = gData.userInfo.plantInfos:GetSortPlant()     

    for key, var in ipairs(plants) do
        local data = VItemData:new()
        data:CreateWithPlantData(var)
        data.posx = 0
        data.posy = 0
        table.insert(self.plants, data)
    end
end

function VFormatData:InitSuits()
    if self.suitInfos ~= nil then
        return
    end

    self.suitInfos = {}

    local suitInfos = gData.userInfo.suitInfo:GetSortsuits() --gData.userInfo.suitInfo:GetSortsuits()--测试数据

    for key, var in ipairs(suitInfos) do
        local data = VItemData:new()
        data:CreateWithSuitData(var)
        data.posx = 0
        data.posy = 0
        table.insert(self.suitInfos, data)
    end
end

function VFormatData:InitOthers()
    if self.others ~= nil then
        return
    end

    self.others = {}

    local others = gData.userInfo.bagInfos:GetSortbagItems()--测试数据

    for key, var in ipairs(others) do
        if var.isShow ~= 0 and var.resType == 3 then
            local count = math.ceil(var.amount / var.limit)
            local tmp = var.amount
            for index = 1, count do
                local data = VItemData:new()
                data:CreateWithOtherData(var)
                data.count = math.min(var.limit, tmp)
                tmp = tmp - var.limit
                data.posx = 0
                data.posy = 0
                table.insert(self.others, data)
            end
        end
    end
    
    table.sort(self.others,
        function(a,b)
            return a.sort < b.sort;
        end);
end

function VFormatData:InitPlantRess()
    if self.plantRes ~= nil then
        return
    end

    self.plantRes = {}

    local plantInfos = gData.userInfo.plantInfos:GetSortPlant()     

    for key, var in ipairs(plantInfos) do   
        if var.resType ~= 0 then
            local data = VItemData:new()
            data:CreateWithPlantData(var)
            data.posx = 0
        data.posy = 0
            table.insert(self.plantRes, data)
            --            self.plantRes[key] = var
        end
    end
end

function VFormatData:InitPlantWars()
    if self.plantWar ~= nil then
        return
    end

    self.plantWar = {}


    local plantInfos = gData.userInfo.plantInfos:GetSortPlant()     

    for key, var in ipairs(plantInfos) do   
        if var.resType == 0 then
            local data = VItemData:new()
            data:CreateWithPlantData(var)
            data.posx = 0
        data.posy = 0
            table.insert(self.plantWar, data)
            --            self.plantRes[key] = var
        end
    end
end


