-- vBattleSunFlowerSprite.lua

-- 向日葵
VBattleSunFlowerSprite = vclass("BattleSunFlowerSprite", VBattlePlantSprite)

function VBattleSunFlowerSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 修女向日葵（绿）
---------------------------------------  VBattleNunFlowerSprite  ---------------------------------------
VBattleNunFlowerSprite = vclass("BattleNunFlowerSprite", VBattlePlantSprite)

function VBattleNunFlowerSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleNunFlowerSprite:doSkill( battleCreature )
	VBattlePlantSprite.doSkill(self, battleCreature);
	self.armature:StopAction();
	self.armature:play("skill", nil, 0);
end

-- 葵花御姐（蓝）
---------------------------------------  VBattleAdultLadySprite  ---------------------------------------
VBattleAdultLadySprite = vclass("BattleAdultLadySprite", VBattleNunFlowerSprite)

function VBattleAdultLadySprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleAdultLadySprite:doingSkill( battleCreature, targetCreature )
	if targetCreature:GetIsAttack() then
		return;
	end
	local targetSprite = gBattleView.PlantList[targetCreature:GetId()];
	if targetSprite then
		targetSprite:addUsefulBuff( targetCreature );
	end
end

-- 烈焰向日葵（紫）
---------------------------------------  VBattleFlamesFlowerSprite  ---------------------------------------
VBattleFlamesFlowerSprite = vclass("BattleAdultLadySprite", VBattleNunFlowerSprite)

function VBattleFlamesFlowerSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 吱悠悠的转（金）
---------------------------------------  VBattleBigPinwheelSprite  ---------------------------------------
VBattleBigPinwheelSprite = vclass("BattleBigPinwheelSprite", VBattleNunFlowerSprite)

function VBattleBigPinwheelSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleBigPinwheelSprite:wind( )
	local armatureSize = self.armature:getContentSize();
	local armatureAnchorPoint = self.armature:getAnchorPoint();
	local windLayer = gBattleView.battleLayer:Push(VLayer{size={armatureSize.width, armatureSize.height}, scale=self.armatureScale, level = self.armature.level});
	windLayer:setAnchorPoint(cc.p(armatureAnchorPoint.x, armatureAnchorPoint.y));
	windLayer:setPosition(self.armature:getPositionX(), self.armature:getPositionY());

	local speed = 3.3 * gBattleView.cellPixW;
	local actionTime = 2;

	local nodeList = {"windNode", "windNode2"};
	local scaleList = {1.67, 1};
	for i,v in ipairs(nodeList) do
		local nodeName = v;
		local imageName = self.armature:getBone(nodeName):getBoneCurrentImageName();
		local boneAnchorPoint = self.armature:getBoneAnchorPoint(nodeName);

		local windImage = windLayer:Push(VImage{image=imageName, scale=scaleList[i]});
		-- local pos = gBattleView.battleLayer:convertToNodeSpace(self.armature:getBonePos(nodeName));
		-- local pos = self.armature:getBonePos(nodeName);
		-- pos.x = pos.x+windImage:getContentSize().width*boneAnchorPoint.x*scaleList[i];
		-- pos.y = pos.y+windImage:getContentSize().height*boneAnchorPoint.y*scaleList[i];
		-- windImage:setPosition(cc.p(pos.x, pos.y));
		local posX = self.armature:getBone(nodeName):getBonePositionX() + armatureSize.width * armatureAnchorPoint.x;
		local posY = self.armature:getBone(nodeName):getBonePositionY() + armatureSize.height * armatureAnchorPoint.y;
		windImage:setPosition(posX, posY);

		windImage:RunAction{"sequence", {"delayTime", actionTime*0.75}, {"fadeTo", actionTime*0.25, 0}};
	end

	windLayer:RunAction{{"easeOut", 1, {"moveBy", actionTime, actionTime*speed, 0}}, {"delayTime", 0.1}, {"delete"}};
end
