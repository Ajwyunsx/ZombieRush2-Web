-- vBattleKernelPultSprite.lua

-- 玉米投手（白）
---------------------------------------  BattleFireMelonSprite  ---------------------------------------
VBattleKernelPultSprite = vclass("BattleKernelPultSprite", VBattlePlantSprite)

function VBattleKernelPultSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleKernelPultSprite:attackSound( )
	gBattleView:playSound("battle_bullet_shoot_", 3);
end

-- 糯玉米（绿）
---------------------------------------  BattleGlutinousCornSprite  ---------------------------------------
VBattleGlutinousCornSprite = vclass("BattleGlutinousCornSprite", VBattleKernelPultSprite)

function VBattleGlutinousCornSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleGlutinousCornSprite:doSkill( battleCreature )
	VBattlePlantSprite.doSkill(self, battleCreature);
	self.armature:StopAction();
	self.armature:play("skill", nil, 0);
end

-- 孢子玉米（蓝）
---------------------------------------  BattleSporeCornSprite  ---------------------------------------
VBattleSporeCornSprite = vclass("BattleSporeCornSprite", VBattleKernelPultSprite)

function VBattleSporeCornSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 熔岩玉米（紫）
---------------------------------------  BattleLavaCornSprite  ---------------------------------------
VBattleLavaCornSprite = vclass("BattleLavaCornSprite", VBattleKernelPultSprite)

function VBattleLavaCornSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 墨西哥玉米（金）
---------------------------------------  BattleMexicoCornSprite  ---------------------------------------
VBattleMexicoCornSprite = vclass("BattleMexicoCornSprite", VBattleKernelPultSprite)

function VBattleMexicoCornSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end
