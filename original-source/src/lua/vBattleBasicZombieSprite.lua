-- vBattleBasicZombieSprite.lua

-- 普通僵尸（白）
---------------------------------------  BattleBasicZombieSprite  ---------------------------------------
VBattleBasicZombieSprite = vclass("BattleBasicZombieSprite", VBattleMonsterSprite)

function VBattleBasicZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 门板僵尸（绿）
---------------------------------------  BattleScreenDoorZombieSprite  ---------------------------------------
VBattleScreenDoorZombieSprite = vclass("BattleScreenDoorZombieSprite", VBattleMonsterSprite)

function VBattleScreenDoorZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 皮甲僵尸（蓝）
---------------------------------------  BattleLeatherZombieSprite  ---------------------------------------
VBattleLeatherZombieSprite = vclass("BattleLeatherZombieSprite", VBattleMonsterSprite)

function VBattleLeatherZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 斯巴达僵尸（紫）
---------------------------------------  BattleSpartaZombieSprite  ---------------------------------------
VBattleSpartaZombieSprite = vclass("BattleSpartaZombieSprite", VBattleMonsterSprite)

function VBattleSpartaZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 美国队长（金）
---------------------------------------  BattleCaptainZombieSprite  ---------------------------------------
VBattleCaptainZombieSprite = vclass("BattleCaptainZombieSprite", VBattleMonsterSprite)

function VBattleCaptainZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleCaptainZombieSprite:initMonsterSprite()
	local childName = self.imageName.."Child";
	self.armatureChild = VArmature:createArmature(childName);
	self.armature:getBone("portNode"):addDisplay(self.armatureChild, 1);
	self.armature:getBone("portNode"):changeDisplayWithIndex(1, true);
	self.armature:getBone("portNode"):setIgnoreMovementBoneData(true);
	self.armatureChild:play("idle");

	VBattleMonsterSprite.initMonsterSprite(self);
end

function VBattleCaptainZombieSprite:doingSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
end

function VBattleCaptainZombieSprite:dieAnimation( )
	-- self.armature:getBone("portNode"):changeDisplayWithIndex(0, true);
	self.armatureChild:stop();
	VBattleMonsterSprite.dieAnimation(self);
end
