-- vBattleBoomZombieSprite.lua

-- 玩偶匣僵尸（白）
---------------------------------------  BattleLeatherZombieSprite  ---------------------------------------
VBattleBoomZombieSprite = vclass("BattleBoomZombieSprite", VBattleMonsterSprite)

function VBattleBoomZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
	self.specialEnterEffect = true;
end

function VBattleBoomZombieSprite:walkAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_MOVE then
		self.animationType = ECreatureAnimationType.ANIMATION_MOVE;
		if self.specialEnterEffect then
			self.specialEnterEffect = false;
			gBattleView:playSound("battle_BoomZombie_start");
		end
		self.armature:play("walk");
	end
end

function VBattleBoomZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	gBattleView:playSound("battle_BoomZombie_before_", 2);
	self.valid = false;
	self.armature:StopAction();
	self.armature:play("boom", 0.1, 0);
end

-- 消防员僵尸（绿）
---------------------------------------  BattleFiremenZombieSprite  ---------------------------------------
VBattleFiremenZombieSprite = vclass("BattleFiremenZombieSprite", VBattleBoomZombieSprite)

function VBattleFiremenZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
	self.specialEnterEffect = true;
end
-- 自杀袭击僵尸（蓝）
---------------------------------------  BattleSuicideZombieSprite  ---------------------------------------
VBattleSuicideZombieSprite = vclass("BattleSuicideZombieSprite", VBattleBoomZombieSprite)

function VBattleSuicideZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleSuicideZombieSprite:walkAnimation( )
	VBattleMonsterSprite.walkAnimation(self);
end

function VBattleSuicideZombieSprite:doSkill( battleCreature )
	VBattleBoomZombieSprite.doSkill(self, battleCreature);
end

-- 疯狂科学家僵尸（紫）
---------------------------------------  BattleCrazyScientistSprite  ---------------------------------------
VBattleCrazyScientistSprite = vclass("BattleCrazyScientistSprite", VBattleBoomZombieSprite)
function VBattleCrazyScientistSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
	self.specialEnterEffect = true;
end

-- 炸弹投手（金）
---------------------------------------  BattleBombPitcherSprite  ---------------------------------------
VBattleBombPitcherSprite = vclass("BattleBombPitcherSprite", VBattleBoomZombieSprite)

function VBattleBombPitcherSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleBombPitcherSprite:walkAnimation( )
	VBattleMonsterSprite.walkAnimation(self);
end

function VBattleBombPitcherSprite:attackAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_ATTACK then
		self.animationType = ECreatureAnimationType.ANIMATION_ATTACK;
		self.armature:play("boom", 0.1, 0);
	end
end

function VBattleBombPitcherSprite:getShootPos( )
	return self.armature:getBonePos("shootNode");
end

function VBattleBombPitcherSprite:halfLifeAnimation( )
	return;
end