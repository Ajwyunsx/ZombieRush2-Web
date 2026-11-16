require "vComposeOperateDlg"

VComposeLvUpCell = VClass("ComposeLvUpCell", VTableViewCell)

function VComposeLvUpCell:Recover(count)
    self.info = {}
    
    self("cardImg").image = "AdvanceBasicZombie1.png"
    self("sunText").text = ""
    self("suitUseText").text = ""
    self("suitHasText").text = ""
    self("cardImg").offset = {0,11}
    self("suitHasText").color = {255, 0, 0}
    self("sunBgImage")("lyres1").visible = 0
    -- for var = 1, 5 do --
    --     local imgStarC = self("imgStarC"..var)
    --     imgStarC.visible = 0
    -- end
end

function VComposeLvUpCell:SetInfo(idx, count, data)
    local cardImg = self("cardImg")
    cardImg.image = "carddiban"..data.quality..".png" --data.quality
    -- if data.quality >= 5 then
    --     cardImg.offset = {2,-1}
    -- end
    
    local suitUse = 99999999
    local suitHas = 0
    
    for key, var in ipairs(data.effect) do
    	if var.effectType == RES_DATA_TYPE.ResDataTypeAttr then
            self("sunBgImage")("lyres1").visible = 1
            self("sunImage").image = gData:getResoureIconByID(RES_DATA_TYPE.ResDataTypeAttr, AttrType.AttrTypeSunshine)
            self("sunText").text = self:GetResCost(var.effectValue)
        elseif var.effectType == RES_DATA_TYPE.ResDataTypeItem then
            self("suitImage").image = gData:getResoureIconByID(RES_DATA_TYPE.ResDataTypeItem, var.effectid)
            suitUse = self:GetResCost(var.effectValue)
            local item = gData.userInfo.bagInfos:itemThingid(var.effectid)
            if item then
                suitHas = item.amount
            end

            if suitUse == 0 then
                self("suitHasText").visible = 0
                self("suitUseText").text = suitUse
            else
                self("suitUseText").text = " / "..suitUse
                self("suitHasText").text = suitHas
                self("suitHasText").visible = 1
            end
        end
    end
    
    -- for var = 1, data.level do --
    --     local imgStarC = self("imgStarC"..var)
    -- 	imgStarC.visible = 1
    -- end

    if (data.level or 0) > 0 then
        self("imgStarC").visible = 1
        self("txlevel").text = data.level
    else
        self("imgStarC").visible = 0
    end


    self("imgItemPlantC").image = data.image.."L.png"
    self("imgItemPlantC").fit = {-1, -1}
    self("txNamePlantC").text = data.name
--    self("suitHasText").text = data.image

    if suitUse <= suitHas then
    	self("suitHasText").color = {7, 131, 25}
    end

    self.info = data

end

function VComposeLvUpCell:GetResCost(vaule)
	if vaule < 0 then
	   return -vaule
	else
        return vaule
	end
end

function VComposeLvUpCell:onOpenComposeOperateDlg()
   local dlg = VNode("vCardLevelUpDlg.vui")
   dlg:setCardInfo(self.info, 2)
   gView():Push(dlg)
    -- local dlg = VNode("vLvUpChangeDlg.vui")
    -- local monsterInfo = gData.userInfo.monsterInfo.monsterInfos[self.info.id]
    -- dlg:SetInfo(monsterInfo)
    -- gView():Push(dlg)
end