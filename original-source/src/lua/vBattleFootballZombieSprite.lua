-- vBattleFootballZombieSprite.lua

-- 橄榄球僵尸（白）
---------------------------------------  BattleSuicideZombieSprite  ---------------------------------------
VBattleFootballZombieSprite = vclass("BattleFootballZombieSprite", VBattleMonsterSprite)

function VBattleFootballZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 橄榄球四分卫（绿）
---------------------------------------  BattleQuarterBackZombieSprite  ---------------------------------------
VBattleQuarterBackZombieSprite = vclass("BattleQuarterBackZombieSprite", VBattleMonsterSprite)

function VBattleQuarterBackZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleQuarterBackZombieSprite:getShootPos( )
	return self.armature:getBonePos("shootNode");
end

function VBattleQuarterBackZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:StopAction();
	self.armature:play("skill", nil, 0);
end

-- 橄榄球队长僵尸（蓝）
---------------------------------------  BattleFootballLeaderSprite  ---------------------------------------
VBattleFootballLeaderSprite = vclass("BattleFootballLeaderSprite", VBattleMonsterSprite)

function VBattleFootballLeaderSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
	self.isRush = false;
end

function VBattleFootballLeaderSprite:walkAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_MOVE then
		self.animationType = ECreatureAnimationType.ANIMATION_MOVE;
		if self.isRush then
			self.armature:play("walk");
		else
			self.armature:play("skill");
		end
	end
end

function VBattleFootballLeaderSprite:addRushBuff( battleCreature )
	self.isRush = true;
	if self.animationType == ECreatureAnimationType.ANIMATION_MOVE then
		self.armature:play("skill");
	end
end

function VBattleFootballLeaderSprite:delRushBuff( battleCreature )
	self.isRush = false;
	if self.animationType == ECreatureAnimationType.ANIMATION_MOVE then
		self.armature:play("walk");
	end
end

-- 狂野橄榄球僵尸（紫）
---------------------------------------  BattleWildnessFootballSprite  ---------------------------------------
VBattleWildnessFootballSprite = vclass("BattleWildnessFootballSprite", VBattleMonsterSprite)

function VBattleWildnessFootballSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleWildnessFootballSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
end

-- 地狱男爵僵尸（金）
---------------------------------------  BattleHellboyZombieSprite  ---------------------------------------
VBattleHellboyZombieSprite = vclass("BattleHellboyZombieSprite", VBattleMonsterSprite)

function VBattleHellboyZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
	self.getHell = false;
	self.actionString = "";
end

function VBattleHellboyZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:StopAction();
	self.armature:play("skill", nil, 0);
end

function VBattleHellboyZombieSprite:doArmatureAnimation( animation )
	local actionName = animation..self.actionString;
	self.armature:play(actionName);
end

function VBattleHellboyZombieSprite:walkAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_MOVE then
		self.animationType = ECreatureAnimationType.ANIMATION_MOVE;
		self:doArmatureAnimation("walk");
	end
end

function VBattleHellboyZombieSprite:attackAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_ATTACK then
		self.animationType = ECreatureAnimationType.ANIMATION_ATTACK;
		self:doArmatureAnimation("attack");
	end
end

-- 瑞司机say 不管谁放的男爵buff 照样播放着火动画 2015/05/05 15:00:24
function VBattleHellboyZombieSprite:addHellBoyBuff( battleCreature )
	self.actionString = "2";
end

function VBattleHellboyZombieSprite:delHellBoyBuff( battleCreature )
	self.actionString = "";
end

function VBattleHellboyZombieSprite:finishWalkAnimation()
	if self.animationType == ECreatureAnimationType.ANIMATION_MOVE then
		self:doArmatureAnimation("walk");
	end
end

function VBattleHellboyZombieSprite:finishAttackAnimation()
	if self.delayRun then
		VBattleMonsterSprite.finishAttackAnimation(self);
	else
		if self.animationType == ECreatureAnimationType.ANIMATION_ATTACK then
			self:doArmatureAnimation("attack");
		end
	end
end
