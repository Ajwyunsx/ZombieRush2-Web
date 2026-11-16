VFreeGiftDlg = VClass("FreeGiftDlg", VMsgBox)

function VFreeGiftDlg:onPush( ... )
	-- self("artUp"):play("idle")

    local card = VPlantInfo.createPlantInfoById(20010);

    self("imgItemPlantC").image = card.plantImage.."S.png"

    self("txname").text = card.plantName

    if card.plantLevel > 0 then
        self("imgStarC").visible = 1
        self("txlevel").text = card.plantLevel
    end

    self("cardImg").image = "carddiban"..card.quality..".png"
end

function VFreeGiftDlg:SetDlgInfo( info )
    -- body
    self.info = info
end

function VFreeGiftDlg:GetGift( ... )
    -- body
    local dungeonInfo = gData.userInfo.dungeonInfo
    dungeonInfo:SaveFreeGiftToFile()

    if dungeonInfo:CheckFreeGiftDlgOpen(self.info.id) then
        dungeonInfo:OpenFreeGiftDlg(self.info.id)
    elseif dungeonInfo:CheckShop2ValidEx(self.info.id) then
        dungeonInfo:OpenShop2DlgEx(self.info.id)
    else
        local dlg = gView()("levelDlg")
        if dlg then
            dlg:OpenLevelInfoDlg(self.info)
        end
    end

    self:onClose()
end

function VFreeGiftDlg:onClose(parameters)
    
    VFreeGiftDlg.super.onClick(self)
end