--vFieldImage.lua

require "vFarmUpDlg"
require "vPlantBagDlg"

VFieldImage = VClass("FieldImage", VImage)

function VFieldImage:SetPos(i, j, ratio)
    local posx, posy = self:GetPosWithOffset(i, j, ratio)

    self.offset = {posx, posy}
end

function VFieldImage:GetPosWithOffset(i, j, ratio)

    local posx = (ratio.x * j + (ratio.x - 1) * i) * self.size.width + ratio.revisex * (1 - ratio.x) * self.size.width
    local posy = (j * ratio.y + (1 - ratio.y) * i) * self.size.height - i * ratio.revisey * self.size.height

    return posx, posy
end

function VFieldImage:Init( attr )
    -- body
    VFieldImage.super.Init(self, attr)
    -- self.drag = 1
    self.lock = true
    self.free = true
    self.deviation = {}
    self.deviation.x = 0.1
    self.deviation.y = 0.1
end


function VFieldImage:onClick(touch)
    -- body
    gFarm = gFarm or self:getView()("farmLayer")
    local touchPoint = touch:getLocation()

    local locationInNode = self:convertToNodeSpace(touchPoint)
    local s = self:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)

    if cc.rectContainsPoint1(rect, locationInNode, gFarm.ratio, self.deviation) then
        if self.lock then
            gView():Push("vFarmUpDlg.vui")
        elseif self.free then
            gFarm:SetCurrentTouchPos(self.pos.x, self.pos.y)
            local node = VNode("vPlantBagDlg.vui")
            node.DlgType = "ALLPLANT"
            gView():Push(node)
        end
    end
end

function VFieldImage:checkClick(touch)
    if not self.isSelf then return end;
    if self:IsInRect(touch) then
        self:onClick(touch);
        return _VTouchType.Field;
    end
    return false;
end
