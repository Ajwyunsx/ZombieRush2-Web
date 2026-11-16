-- vBattleWallNutSprite.lua

-- 土豆（白）
---------------------------------------  BattleWallNutSprite  ---------------------------------------
VBattleWallNutSprite = vclass("BattleWallNutSprite", VBattlePlantSprite)

function VBattleWallNutSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleWallNutSprite:setHpPosition( )
	self.lifeImage:setPosition(0, self.armature:getContentSize().height - 4);
end

-- 受伤闪烁
function VBattleWallNutSprite:doDamageAnimation( battleCreature )
	VBattlePlantSprite.doDamageAnimation(self, battleCreature);
	if self.isSleeping then
		return;
	end
	self.armature:changeDisplay("eye", nil, 1);
	self.armature:RunAction{{"delayTime", 0.5}, {VBattleWallNutSprite.doNoDamageAnimation, self.creatureType, self.armature}};
end

function VBattleWallNutSprite.doNoDamageAnimation( creatureType, plantArmature )
	plantArmature:changeDisplay("eye", nil, 0);
	if gShowBloomAnimation then
		plantArmature:Set_bloom(false);
	end
end

function VBattleWallNutSprite:injuryAnimation( plantCreature )
	if self.isSleeping then
		return;
	end
	if plantCreature.m_fLife < plantCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * 1/3 then
		self.armature:stop();
		self.armature:changeDisplay("body", nil, 2);
		self.armature:play("idle");
	 elseif plantCreature.m_fLife < plantCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * 2/3 then
 		self.armature:stop();
	 	self.armature:changeDisplay("body", nil, 1);
	 	self.armature:play("idle");
	 end
end
-- 土豆爸爸（绿）
---------------------------------------  BattleNutFatherSprite  ---------------------------------------
VBattleNutFatherSprite = vclass("BattleNutFatherSprite", VBattlePlantSprite)
function VBattleNutFatherSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleNutFatherSprite:setHpPosition( )
	self.lifeImage:setPosition(0, self.armature:getContentSize().height - 4);
end

-- 受伤闪烁
function VBattleNutFatherSprite:doDamageAnimation( battleCreature )
	VBattlePlantSprite.doDamageAnimation(self, battleCreature);
	if self.isSleeping then
		return;
	end
	self.armature:changeDisplay("eye", nil, 1);
	self.armature:RunAction{{"delayTime", 0.5}, {VBattleNutFatherSprite.doNoDamageAnimation, self.creatureType, self.armature}};
end

function VBattleNutFatherSprite.doNoDamageAnimation( creatureType, plantArmature )
	plantArmature:changeDisplay("eye", nil, 0);
	if gShowBloomAnimation then
		plantArmature:Set_bloom(false);
	end
end

function VBattleNutFatherSprite:injuryAnimation( plantCreature )
	if self.isSleeping then
		return;
	end
	if plantCreature.m_fLife < plantCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * 1/3 then
	 	self.armature:stop();
	 	self.armature:changeDisplay("body", nil, 2);
	 	self.armature:play("idle");
	elseif plantCreature.m_fLife < plantCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * 2/3 then
	 	self.armature:stop();
	 	self.armature:changeDisplay("body", nil, 1);
	 	self.armature:play("idle");
	end
end

-- 坚甲土豆（蓝）
---------------------------------------  BattleIronNutSprite  ---------------------------------------
VBattleIronNutSprite = vclass("BattleIronNutSprite", VBattleNutFatherSprite)
function VBattleIronNutSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end
-- 星辰土豆（紫色）
---------------------------------------  BattleStarNutSprite  ---------------------------------------
VBattleStarNutSprite = vclass("BattleStarNutSprite", VBattleNutFatherSprite)
function VBattleStarNutSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end
-- 飞凰蛋（金）
---------------------------------------  BattlePhoenixEggSprite  ---------------------------------------
VBattlePhoenixEggSprite = vclass("BattlePhoenixEggSprite", VBattlePlantSprite)

function VBattlePhoenixEggSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattlePhoenixEggSprite:setHpPosition( )
	self.lifeImage:setPosition(0, self.armature:getContentSize().height - 4);
end

function VBattlePhoenixEggSprite:injuryAnimation( plantCreature )
	if self.isSleeping then
		return;
	end
	if plantCreature.m_fLife < plantCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * 1/3 then
	 	self.armature:stop();
	 	self.armature:changeDisplay("body", nil, 2);
	 	self.armature:play("idle");
	elseif plantCreature.m_fLife < plantCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE) * 2/3 then
	 	self.armature:stop();
	 	self.armature:changeDisplay("body", nil, 1);
	 	self.armature:play("idle");
	end
end

function VBattlePhoenixEggSprite:addRebirthBuff( )
	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.BULLET_LEVEL - self.road);

	self.armature:stop();
	self.armature:play("rebirth");
end

function VBattlePhoenixEggSprite:rebirthOverOnFrameEvent( )
	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.PLANT_LEVEL - self.road);

	self.armature:stop();
	self.armature:changeDisplay("body", nil, 0);
	self.armature:play("idle");
end