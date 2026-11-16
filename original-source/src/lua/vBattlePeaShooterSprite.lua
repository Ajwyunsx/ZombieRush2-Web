-- vBattlePeaShooterSprite.lua
-- 豌豆射手
VBattlePeaShooterSprite = vclass("BattlePeaShooterSprite", VBattlePlantSprite)

function VBattlePeaShooterSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattlePeaShooterSprite:initPlantSprite()
	self.armatureName = self.imageName.."Body";
	VBattlePlantSprite.initPlantSprite(self);

	local childName = self.imageName.."Child";
	self.armatureChild = VArmature:createArmature(childName);
	self.armature:getBone("portNode"):addDisplay(self.armatureChild, 1);
	self.armature:getBone("portNode"):changeDisplayWithIndex(1, true);
	self.armature:getBone("portNode"):setIgnoreMovementBoneData(true);
end

function VBattlePeaShooterSprite:attackAnimation( )
	if self.armatureChild then
		self.armatureChild:play("attack",-1,0);
	end
end

function VBattlePeaShooterSprite:attackSound( )
	gBattleView:playSound("battle_bullet_shoot_", 3);
end

-- 豌豆2级 剧毒豌豆【绿】
---------------------------------------  BattlePoisonPeaSprite  ---------------------------------------
VBattlePoisonPeaSprite = vclass("BattlePoisonPeaSprite", VBattlePeaShooterSprite)

function VBattlePoisonPeaSprite:initialize( battleCreature )
	VBattlePeaShooterSprite.initialize(self, battleCreature);
end

-- 豌豆3级 寒冰豌豆【蓝】
---------------------------------------  BattleSnowPeaSprite  ---------------------------------------
VBattleSnowPeaSprite = vclass("BattleSnowPeaSprite", VBattlePeaShooterSprite)

function VBattleSnowPeaSprite:initialize( battleCreature )
	VBattlePeaShooterSprite.initialize(self, battleCreature);
end

-- 豌豆4级 狙击豌豆【紫】
---------------------------------------  BattleSnipeShooterSprite  ---------------------------------------
VBattleSnipeShooterSprite = vclass("BattleSnipeShooterSprite", VBattlePeaShooterSprite)

function VBattleSnipeShooterSprite:initialize( battleCreature )
	VBattlePeaShooterSprite.initialize(self, battleCreature);
end

-- 豌豆5级 转基因豌豆【金】
---------------------------------------  BattleThreepeaterSprite  ---------------------------------------
VBattleThreepeaterSprite = vclass("BattleThreepeaterSprite", VBattlePlantSprite)

function VBattleThreepeaterSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end
