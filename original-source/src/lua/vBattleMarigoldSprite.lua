-- vBattleMarigoldSprite.lua
-- 金盏花
VBattleMarigoldSprite = vclass("BattleMarigoldSprite", VBattlePlantSprite)

function VBattleMarigoldSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 歌手菊花（绿）
---------------------------------------  BattleSingerMumSprite  ---------------------------------------
VBattleSingerMumSprite = vclass("BattleSingerMumSprite", VBattlePlantSprite)

function VBattleSingerMumSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end
function VBattleSingerMumSprite:doSkill( battleCreature )
	VBattlePlantSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
end

--彼岸菊（蓝）
---------------------------------------  BattleOtherShoreSprite  ---------------------------------------
VBattleOtherShoreSprite = vclass("BattleOtherShoreSprite", VBattleSingerMumSprite)

function VBattleOtherShoreSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 菊花萨满（紫）
---------------------------------------  BattleShamanMumSprite  ---------------------------------------
VBattleShamanMumSprite = vclass("BattleShamanMumSprite", VBattleSingerMumSprite)

function VBattleShamanMumSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 血腥红菊（金）
---------------------------------------  BattleBloodySprite  ---------------------------------------
VBattleBloodySprite = vclass("BattleBloodySprite", VBattlePlantSprite)

function VBattleBloodySprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end
function VBattleBloodySprite:doSkill( battleCreature )
	VBattlePlantSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
end