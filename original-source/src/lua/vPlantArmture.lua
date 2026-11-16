--vPlantArmture.lua
require "vProgcessTimer"

VPlantArmture = VClass("PlantArmture", VArmature)

function VPlantArmture:setFarmInfo(farmInfo, isSelf, scale)
    self.isSelf = isSelf;
    self.scaleCom = scale
    self.farmInfo = farmInfo;
    self:showStatus();

end

function VPlantArmture:delayStay( )
    local randomDuration = math.random(0,20)
    
    self:play("idle");
--    self:pause();
    self:getAnimation():gotoAndPlay(randomDuration);
end
