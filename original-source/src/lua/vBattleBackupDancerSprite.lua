-- vBattleBackupDancerSprite.lua

VBattleBackupDancerSprite = vclass("BattleBackupDancerSprite", VBattleMonsterSprite)

function VBattleBackupDancerSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleBackupDancerSprite:initMonsterSprite( )
	local posx = self.pos * gBattleView.cellMinPixW;
	local posy = (self.road - 1) * gBattleView.cellPixH;
	self.armature:setPosition(posx, posy);
	self:setHpImage();
end

function VBattleBackupDancerSprite:setHpPosition( )
	local pos = cc.p(2, 198);
	self.lifeImage:setPosition(pos.x, pos.y);
end

function VBattleBackupDancerSprite:stayAnimation( )
	self.armature:stop();
end

function VBattleBackupDancerSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:play("summon", -1, 0);
end