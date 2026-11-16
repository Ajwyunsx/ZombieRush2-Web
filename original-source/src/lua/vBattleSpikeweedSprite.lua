-- vBattleSpikeweedSprite.lua
-- 地刺（白）
---------------------------------------  BattleSpikeweedSprite  ---------------------------------------
VBattleSpikeweedSprite = vclass("BattleSpikeweedSprite", VBattlePlantSprite)

function VBattleSpikeweedSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleSpikeweedSprite:setHpPosition( )
	self.lifeImage:setPosition(0, self.armature:getContentSize().height + 10);
end

function VBattleSpikeweedSprite:attackSound( )
	gBattleView:playSound("battle_Spikeweed_attack");
end

-- 刚棘陷阱（绿）
---------------------------------------  BattleSpikerockSprite  ---------------------------------------
VBattleSpikerockSprite = vclass("BattleSpikerockSprite", VBattleSpikeweedSprite)

function VBattleSpikerockSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 荆棘陷阱（蓝）
---------------------------------------  BattleSpikeweedSprite  ---------------------------------------
VBattleThornsTrapSprite = vclass("BattleThornsTrapSprite", VBattlePlantSprite)

function VBattleThornsTrapSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleThornsTrapSprite:setHpPosition( )
	self.lifeImage:setPosition(0, self.armature:getContentSize().height + 10);
end

function VBattleThornsTrapSprite:attackSound( )
	gBattleView:playSound("battle_Spikeweed_attack");
end

-- 捕蝇草（紫）
---------------------------------------  BattleLadyEnforcersSprite  ---------------------------------------
VBattleLadyEnforcersSprite = vclass("BattleLadyEnforcersSprite", VBattleThornsTrapSprite)

function VBattleLadyEnforcersSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end
function VBattleLadyEnforcersSprite:doSkill( battleCreature )
	VBattlePlantSprite.doSkill(self, battleCreature);

	self.armature:StopAction();
	self.armature:play("skill");
end
function VBattleLadyEnforcersSprite:addLadyEnforcersHold( battleCreature )
	self.armature:pause();
	gDtr:getActionManager():pauseTarget(self.armature);
end
function VBattleLadyEnforcersSprite:delLadyEnforcersHold( battleCreature )
	self.armature:resume();
	gDtr:getActionManager():resumeTarget(self.armature);
end
-- 太岁（金）
---------------------------------------  BattleTaiSuiSprite  ---------------------------------------
VBattleTaiSuiSprite = vclass("BattleTaiSuiSprite", VBattlePlantSprite)

function VBattleTaiSuiSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleTaiSuiSprite:doSkill( battleCreature )
	VBattlePlantSprite.doSkill(self, battleCreature);

	self.armature:StopAction();
	self.armature:play("skill", nil, 0);
end
