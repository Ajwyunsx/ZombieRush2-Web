-- vBattleFlagZombieSprite.lua

VBattleFlagZombieSprite = vclass("BattleFlagZombieSprite", VBattleMonsterSprite)

function VBattleFlagZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleFlagZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	gBattleView:playSound("battle_FlgZombie_ShakingFlag");
	self.armature:play("shakingFlag", -1, 0);
end

function VBattleFlagZombieSprite:showEvilBuffAnimation( )
	self.evilArmature = VArmature:createArmature("evilBuffAnimation");
	self.evilArmature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.BULLET_LEVEL - self.road);
	gBattleView.battleLayer:Push(self.evilArmature);
	self.evilArmature:ReLayout();
	local pos = gBattleView.battleLayer:convertToNodeSpace(self.armature:getBonePos("head"));
	local w = self.armature:getBoneSize("head").width * self.armatureScale * 0.5;
	self.evilArmature:setPosition(pos.x + w, pos.y + 40);
	self.evilArmature:play("buf", -1, 0);
end

function VBattleFlagZombieSprite:delEvilAnimation( )
	if self.evilArmature then
		self.evilArmature:Delete();
		self.evilArmature = nil;
	end
end