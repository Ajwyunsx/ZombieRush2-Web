--vPlantBagDlg.lua

require "vPlantViewCell"
--require "vplantResCell"
--require "vplantWarCell"

VPlantBagDlg = VClass("PlantBagDlg", VMsgBox)

function VPlantBagDlg:Init(attr)
    VPlantBagDlg.super.Init(self, attr)
    self.rowCount = 5
    
--    self:InitPlantBagDlg()
    
end


function VPlantBagDlg:onPush()
    self("artUp"):play("idle")
    self.data = VFormatData:new()

    self.data:InitPlants()    
    self.lastTableBt = self("btnAllPlantBag")
    self.lastTableBt.type = "ALLPLANT"
    self:ReloadTable("ALLPLANT")
end


function VPlantBagDlg:onCell(idx, t, cell)
    self:SetCellInfo(idx, cell, t.type)
end

function VPlantBagDlg:SetCellInfo(idx, cell, type)
    cell:Recover(self.rowCount, type)
    local i = 1
    for var = idx * self.rowCount + 1, idx * self.rowCount + self.rowCount do

        local info = self:GetTableInfo(var, type)

        local lyrBagCell = cell("lyrBagCell"..i)

        cell:SetInfo(info, i, idx, var, self.openCount, type)

        i = i + 1
    end
end


function VPlantBagDlg:GetTableInfo(i, type)
    local info
    
    if type == "PLANTRES" then
        info = self.data.plantRes[i]
    elseif type == "ALLPLANT" then
        info = self.data.plants[i]
    else
        info = self.data.plantWar[i]
    end
    
    return info
end


function VPlantBagDlg:ChageTable( type )
    if self.lastTableBt.type == type then
        return
    end

    self.lastTableBt.image = "cebianyeka.png"
    self.lastTableBt("txTextBag").color = {95,104,154}
    local btnBag = nil

    if type == "PLANTRES" then
        btnBag = self("btnResBag")
        self.data:InitPlantRess()
    elseif type == "ALLPLANT" then
        btnBag = self("btnAllPlantBag")
        self.data:InitPlants()
    else
        btnBag = self("btnDefBag")
        self.data:InitPlantWars()
    end

    btnBag.image = "cebianyekaxuanzhong.png"
    self.lastTableBt = btnBag
    btnBag.type = type
    btnBag("txTextBag").color = {240,149,15}
    self:ReloadTable(type)
end

function VPlantBagDlg:GetCellCount(type)
    local count = 0
    
    if type == "ALLPLANT" then
        count = table.getn(self.data.plants)
    elseif type == "PLANTRES" then
        count = table.getn(self.data.plantRes)
    else
        count = table.getn(self.data.plantWar)
    end

    local num, remainder = math.modf(count / 5)
    
    if remainder ~= 0 then
        num = num + 1
    end
    
    return num
end

function VPlantBagDlg:onCellSize(parameters)
    return 445, 97
end

function VPlantBagDlg:ReloadTable( type )
    
    local count = self:GetCellCount(type)
    
    if count == 0 then
        self("tbPlantBag").visible = false;
        self("txNonePlantBag").visible = true;
    else
        self("tbPlantBag").visible = true;
        self("txNonePlantBag").visible = false;
    end

    local tbPlantBag = self("tbPlantBag");
    tbPlantBag.type = type
    tbPlantBag.number = count;
    tbPlantBag.delegate = self;
    tbPlantBag:reloadData();
end


function VPlantBagDlg:onbtnCloseClick( )
   self:onClick()
end

function VPlantBagDlg:onClick()
--    local currentView = gView(-2)
--    if currentView then
--        currentView.visible = 1
--    end
    VPlantBagDlg.super.onClick(self)
end