-- vBattleMelonPultSprite.lua

-- 西瓜投手
---------------------------------------  BattleMelonPultSprite  ---------------------------------------
VBattleMelonPultSprite = vclass("BattleMelonPultSprite", VBattlePlantSprite)

function VBattleMelonPultSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleMelonPultSprite:setHpPosition( )
	self.lifeImage:setPosition(0, self.armature:getContentSize().height - 30);
end

function VBattleMelonPultSprite:attackSound( )
	gBattleView:playSound("battle_bullet_shoot_", 3);
end

-- 燃烧西瓜
---------------------------------------  BattleFireMelonSprite  ---------------------------------------
VBattleFireMelonSprite = vclass("BattleFireMelonSprite", VBattleMelonPultSprite)

function VBattleFireMelonSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 工程西瓜
---------------------------------------  BattleEngineerMelonSprite  ---------------------------------------
VBattleEngineerMelonSprite = vclass("BattleEngineerMelonSprite", VBattleMelonPultSprite)

function VBattleEngineerMelonSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 冰冻西瓜
---------------------------------------  BattleWinterMelonSprite  ---------------------------------------
VBattleWinterMelonSprite = vclass("BattleWinterMelonSprite", VBattleMelonPultSprite)

function VBattleWinterMelonSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 时空西瓜
---------------------------------------  BattleSpaceMelonSprite  ---------------------------------------
VBattleSpaceMelonSprite = vclass("BattleSpaceMelonSprite", VBattleMelonPultSprite)

function VBattleSpaceMelonSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleSpaceMelonSprite:doSkill( battleCreature )
	VBattlePlantSprite.doSkill(self, battleCreature);
	self.armature:StopAction();
	self.armature:play("attack", -1, 0);
end