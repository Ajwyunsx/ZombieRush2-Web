-- vBattleBonkChoySprite.lua

-- 白菜（白）
---------------------------------------  BattleBonkChoySprite  ---------------------------------------
VBattleBonkChoySprite = vclass("BattleBonkChoySprite", VBattlePlantSprite)

function VBattleBonkChoySprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleBonkChoySprite:attackAnimation( plantCreature, targetCreature )
	-- 菜问弱最后一击可以击杀对方时，使用2号勾拳动画
	if self:isLastShot(plantCreature, targetCreature) then
		self.armature:play("attack2", -1, 0);
	else
		-- 平时攻击动画随机
		local random = math.random(0, 100);
		if random < 10 then
			self.armature:play("attack2", -1, 0);
		else
			self.armature:play("attack", -1, 0);
		end
	end
end

function VBattleBonkChoySprite:isLastShot( plantCreature, targetCreature )
	return false;
	-- if targetCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_INV) == 1 then
	-- 	return false;
	-- end

	-- local attack = plantCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_ATTACK);
	-- local defend = targetCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_DEFEND);
	-- local damage = attack - defend;
	-- local nMinDamage = gBattleResource:MinDamageParam() * attack / 100;
	-- if damage < nMinDamage then
	-- 	damage = nMinDamage;
	-- end

	-- -- 进攻方修正
	-- damage = damage * (1 + plantCreature:GetAttackDamageX()) * plantCreature:GetAttackDamageY();
	-- -- 防守方修正
	-- damage = damage * (1 + targetCreature:GetAttackDamageX()) * targetCreature:GetAttackDamageY();

	-- damage = math.floor(damage);
	-- if  damage >= targetCreature.m_fLife then
	-- 	return true;
	-- end
end

function VBattleBonkChoySprite:attackSound( )
	gBattleView:playSound("battle_BonkChoy_attack");
end

-- 白菜荣（绿）
---------------------------------------  BattleCousinCabbageSprite  ---------------------------------------
VBattleWingCabbageSprite = vclass("BattleWingCabbageSprite", VBattleBonkChoySprite)

function VBattleWingCabbageSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleWingCabbageSprite:attackAnimation( plantCreature, targetCreature )
	self.armature:play("attack", -1, 0);
end

function VBattleWingCabbageSprite:doSkill( battleCreature )
	VBattlePlantSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
end

-- 请叫我表哥（蓝）
---------------------------------------  BattleCousinCabbageSprite  ---------------------------------------
VBattleCousinCabbageSprite = vclass("BattleCousinCabbageSprite", VBattleWingCabbageSprite)

function VBattleCousinCabbageSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

function VBattleCousinCabbageSprite:doingSkill( battleCreature, targetCreature )
	local targetSprite = gBattleView.MonsterList[targetCreature:GetId()];
	if targetSprite and targetSprite:isValid() then
		targetSprite:flyAway();
	end
end

-- 娃娃菜（紫）
---------------------------------------  BattleBabyCabbageSprite  ---------------------------------------
VBattleBabyCabbageSprite = vclass("BattleBabyCabbageSprite", VBattleWingCabbageSprite)

function VBattleBabyCabbageSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end

-- 千叶圣白（金）
---------------------------------------  BattleThousandCabbageSprite  ---------------------------------------
VBattleThousandCabbageSprite = vclass("BattleThousandCabbageSprite", VBattleWingCabbageSprite)

function VBattleThousandCabbageSprite:initialize( battleCreature )
	VBattlePlantSprite.initialize(self, battleCreature);
end
