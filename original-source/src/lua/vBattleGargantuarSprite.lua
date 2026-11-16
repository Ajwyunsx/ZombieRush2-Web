-- vBattleGargantuarSprite.lua

-- 伽刚特尔（白）
---------------------------------------  BattleGargantuarSprite  ---------------------------------------
VBattleGargantuarSprite = vclass("BattleGargantuarSprite", VBattleMonsterSprite)

function VBattleGargantuarSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleGargantuarSprite:setHpPosition( )
	local bonePos = self.armature:getBonePos("head");
	local boneSize = self.armature:getBoneSize("head");
	local pos = self.armature:convertToNodeSpace(cc.p(bonePos.x + boneSize.width * 0.5 * self.armatureScale + 20, bonePos.y + boneSize.height * self.armatureScale + 20));
	self.lifeImage:setPosition(pos.x, pos.y);
end

-- 重伤
function VBattleGargantuarSprite:halfLifeAnimation( )
	return;
end

function VBattleGargantuarSprite:dieAndStumpAnimation( )
	return;
end

function VBattleGargantuarSprite:attackSound( )
	gBattleView:playSound("battle_Gargantuar_attack_plant");
end

function VBattleGargantuarSprite:dieSound( )
	if not self.dieSoundDirty then
		self.dieSoundDirty = true;
		gBattleView:playSound("battle_Gargantuar_die");
	end
end

function VBattleGargantuarSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:play("throw", -1, 0);
end

-- 火巨人（绿）
---------------------------------------  BattleFireGiantSprite  ---------------------------------------
VBattleFireGiantSprite = vclass("BattleFireGiantSprite", VBattleGargantuarSprite)

-- 重伤
function VBattleFireGiantSprite:halfLifeAnimation( )
	VBattleMonsterSprite.halfLifeAnimation(self);
end

function VBattleFireGiantSprite:attackSound( )
	gBattleView:playSound("battle_Gargantuar_attack_plant");
end

function VBattleFireGiantSprite:dieAndStumpAnimation( )
	VBattleMonsterSprite.dieAndStumpAnimation(self);
end

-- 冰巨人（蓝）
---------------------------------------  BattleIceGiantSprite  ---------------------------------------
VBattleIceGiantSprite = vclass("BattleIceGiantSprite", VBattleGargantuarSprite)

-- 重伤
function VBattleIceGiantSprite:halfLifeAnimation( )
	VBattleMonsterSprite.halfLifeAnimation(self);
end

function VBattleIceGiantSprite:attackSound( )
	gBattleView:playSound("battle_Gargantuar_attack_plant");
end

function VBattleIceGiantSprite:dieAndStumpAnimation( )
	VBattleMonsterSprite.dieAndStumpAnimation(self);
end

-- 石巨人（紫）
---------------------------------------  BattleStoneGiantSprite  ---------------------------------------
VBattleStoneGiantSprite = vclass("BattleStoneGiantSprite", VBattleGargantuarSprite)


function VBattleStoneGiantSprite:addRebirthBuff( battleCreature )
	self.isStop = true;
	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.BULLET_LEVEL - self.road);
	self.armature:stopAllActions();
	self:removeAllBuffAnimation();
	self.battleCreature = battleCreature;
	self.armature:setSpeedScale(1);
	self.armature:play("rebirth");
end

function VBattleStoneGiantSprite:delRebirthBuff( battleCreature )
	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.MONSTER_LEVEL - self.road);
end

function VBattleStoneGiantSprite:rebirthOver( )
	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.MONSTER_LEVEL - self.road);
	self.isStop = false;
	if self.battleCreature:GetAction() == ECreatureAction.ACTION_MOVE then
		local monsterSpeed = self.battleCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED) * gBattleView.battleInfo.inerval;
		self.playMoveSpeed = 1 / (self.moveSpeedScale / monsterSpeed);
		self.armature:setSpeedScale(self.playMoveSpeed);
		self.armature:play("walk");
		self:continueAnimation(self.battleCreature);
	elseif self.battleCreature:GetAction() == ECreatureAction.ACTION_ATTACK then
		self.armature:play("attack");
	else
		self.armature:play("idle");
	end
end

function VBattleStoneGiantSprite:delBlackHoleBuff( battleCreature )
	VBattleMonsterSprite.removeBlackHoleAnimation(self,battleCreature);
	VBattleMonsterSprite.delBlackHoleBuff(self,battleCreature);
end
-- 绿巨人（金）
---------------------------------------  BattleTheHulkSprite  ---------------------------------------
VBattleTheHulkSprite = vclass("BattleTheHulkSprite", VBattleMonsterSprite)

function VBattleTheHulkSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
	self.readyWalk = false;
	self.isJumping = false;
end

-- 重伤
function VBattleTheHulkSprite:halfLifeAnimation( )
	return;
end

function VBattleTheHulkSprite:walk( battleCreature, plant )
	if self.isJumping then
		self.walkTargetCreature = battleCreature;
		self.walkTargetPlant = plant;
		self.readyWalk = true;
	else
		VBattleMonsterSprite.walk(self, battleCreature, plant);
	end
end

function VBattleTheHulkSprite:doingSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.isJumping = true;
	self.armature:play("jump", -1, 0);

	local posx = battleCreature:GetPos() * gBattleView.cellMinPixW;
	local posy = (self.road - 1) * gBattleView.cellPixH;
	local delayTime = 0.4;
	local actionTime = 0.56;

	self.armature:RunAction{{"delayTime", delayTime}, {"moveTo", actionTime, posx, posy}};
end

function VBattleTheHulkSprite:finishJump( )
	self.isJumping = false;
	self.isAttacking = false;
	if self.readyWalk then
		self.readyWalk = false;
		VBattleMonsterSprite.walk(self, self.walkTargetCreature, self.walkTargetPlant);
	else
		self.armature:play("idle");
	end
end