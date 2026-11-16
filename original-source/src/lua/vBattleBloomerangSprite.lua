-- vBattleBloomerangSprite.lua
-- 回旋镖射手
VBattleBloomerangSprite = vclass("BattleBloomerangSprite", VBattlePlantSprite)

function VBattleBloomerangSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleBloomerangSprite:attackSoundOnFrameEvent( )
	gBattleView:playSound("battle_boomerang_bullet_shoot");
end