-- vBattleSnowPeaSprite.lua
-- 寒冰射手
VBattleSnowPeaSprite = vclass("BattleSnowPeaSprite", VBattlePlantSprite)

function VBattleSnowPeaSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleSnowPeaSprite:initPlantSprite()
	self.armatureName = self.imageName.."Body";
	VBattlePlantSprite.initPlantSprite(self);

	local childName = self.imageName.."Child";
	self.armatureChild = VArmature:createArmature(childName);
	self.armature:getBone("portNode"):addDisplay(self.armatureChild, 1);
	self.armature:getBone("portNode"):changeDisplayWithIndex(1, true);
	self.armature:getBone("portNode"):setIgnoreMovementBoneData(true);
end

function VBattleSnowPeaSprite:setHpPosition( )
	self.lifeImage:setPosition(0, self.armature:getContentSize().height + 10);
end

function VBattleSnowPeaSprite:attackAnimation( )
	self.armatureChild:play("attack", -1, 0);
end

function VBattleSnowPeaSprite:attackSound( )
	gBattleView:playSound("battle_bullet_shoot_", 3);
end