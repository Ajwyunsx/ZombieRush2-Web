-- vBattleDancingZombieSprite.lua

-- 舞者僵尸（白）
---------------------------------------  BattleDancingZombieSprite  ---------------------------------------
VBattleDancingZombieSprite = vclass("BattleDancingZombieSprite", VBattleMonsterSprite)

function VBattleDancingZombieSprite:initialize( battleCreature )
	self:checkIsSummonZombie(battleCreature);
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 检查是否召唤怪
function VBattleDancingZombieSprite:checkIsSummonZombie( battleCreature )
	local isSummon = false;
	for i,v in ipairs(battleCreature.m_buffs) do
		local buffProp = gBattleResource:GetBuffProp(v.m_id);
		for i,v in ipairs(buffProp.m_buffAnimation) do
			if v == EBuffAnimationType.BUFF_DANCE then
				isSummon = true;
				break;
			end
		end
	end
	if isSummon then
		self.isHide = true;
	else
		self.specialEnterEffect = true;
	end
end

function VBattleDancingZombieSprite:initMonsterSprite( )
	VBattleMonsterSprite.initMonsterSprite(self);
	if self.isHide then
		self:initSummonArmature();
	end
end

-- 显示召唤僵尸
function VBattleDancingZombieSprite:showSummonZombie( )
	self.armature.visible = 1;
end

-- 初始化召唤动画
function VBattleDancingZombieSprite:initSummonArmature( )
	self.summonArmature = VArmature:createArmature("SummonArmature", "", "DownLeft");
	self.summonArmature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.MONSTER_LEVEL - self.road);
	self.summonArmature.scale = self.armatureScale;
	gBattleView.battleLayer:Push(self.summonArmature);
	self.summonArmature:ReLayout();
	self.summonArmature:setPosition(self.pos * gBattleView.cellMinPixW, (self.road - 1) * gBattleView.cellPixH);
	
	local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
		self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
	end 
	self.summonArmature:setEventCallFunc(callBack);
	self.summonArmature:play("summon", -1, 0);

	-- 召唤怪 移除光效
	self.armature:changeDisplay("light", nil, -1);
end

function VBattleDancingZombieSprite:removeSummonArmature( )
	if self.summonArmature then
		self.summonArmature:Delete();
		self.summonArmature = nil;
	end
end

function VBattleDancingZombieSprite:doEnter( )
	VBattleMonsterSprite.doEnter(self);
	self.armature:play("walkBack");
end

function VBattleDancingZombieSprite:walkAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_MOVE then
		self.animationType = ECreatureAnimationType.ANIMATION_MOVE;
		if self.specialEnterEffect then
			self.armature:play("walkBack");
		else
			self.armature:play("walk");
		end
	end
end

function VBattleDancingZombieSprite:attackAnimation( )
	if self.specialEnterEffect then
		self.specialEnterEffect = false;
		self:setHpPosition();
	end

	VBattleMonsterSprite.attackAnimation(self);
end

function VBattleDancingZombieSprite:dieAnimation( )
	self.armature:setSpeedScale(1);
	self:cleanChildSprite();
	self.armature:play("dead", 0.1, 0);
	if self.specialEnterEffect then
		self.armature:setScaleX(-self.armatureScale);
	end
end

function VBattleDancingZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	gBattleView:playSound("battle_DancingZombie_skill");
	if self.specialEnterEffect then
		self.specialEnterEffect = false;
		self:setHpPosition();
	end
	self.armature:play("summon", -1, 0);
end

function VBattleDancingZombieSprite:danceAnimation( )
	if self.valid then
		self.armature:play("dance");
	end
end

-- 帧事件回调
function VBattleDancingZombieSprite:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	VBattleMonsterSprite.onFrameEvent(self,bone,evt,originFrameIndex,currentFrameIndex);

	if evt == "showZombie" then
		self:showSummonZombie();
	elseif evt == "startDanceing" then
		self:danceAnimation();
	elseif evt == "finishSummonGround" then
		self:removeSummonArmature();
	end
end

function VBattleDancingZombieSprite:setHpPosition( )
	if self.specialEnterEffect then
		self.lifeImage:setPosition(0, self.armature:getContentSize().height + 10);
	else
		self.lifeImage:setPosition(0, self.armature:getContentSize().height + 10);
	end
end
-- 嘻哈舞者（绿）
---------------------------------------  BattleHipHopZombieSprite  ---------------------------------------
VBattleHipHopZombieSprite = vclass("BattleHipHopZombieSprite", VBattleDancingZombieSprite)

function VBattleHipHopZombieSprite:initialize( battleCreature )
	VBattleDancingZombieSprite.initialize(self, battleCreature);
end

function VBattleHipHopZombieSprite:dieAndStumpAnimation( )
	local boneList = {"head", "jaw", "leftHair", "rightHair"};
	self:setStumpAnimation(boneList);
end

function VBattleHipHopZombieSprite:setHpPosition( )
	if self.specialEnterEffect then
		self.lifeImage:setPosition(self.lifeImage:getContentSize().width * 0.7, self.armature:getContentSize().height + 10);
	else
		self.lifeImage:setPosition(-self.lifeImage:getContentSize().width * 0.2, self.armature:getContentSize().height + 10);
	end
end
-- 西服舞者（蓝）
---------------------------------------  BattleSuitDancingZombieSprite  ---------------------------------------
VBattleSuitDancingZombieSprite = vclass("BattleSuitDancingZombieSprite", VBattleDancingZombieSprite)

function VBattleSuitDancingZombieSprite:initialize( battleCreature )
	VBattleDancingZombieSprite.initialize(self, battleCreature);
end

function VBattleSuitDancingZombieSprite:dieAndStumpAnimation( )
	local boneList = {"head", "jaw", "leftHair", "rightHair"};
	self:setStumpAnimation(boneList);
end

function VBattleSuitDancingZombieSprite:setHpPosition( )
	if self.specialEnterEffect then
		self.lifeImage:setPosition(self.lifeImage:getContentSize().width * 0.3, self.armature:getContentSize().height);
	else
		self.lifeImage:setPosition(0, self.armature:getContentSize().height);
	end
end
-- 猫王（紫）
---------------------------------------  BattleElvisZombieSprite  ---------------------------------------
VBattleElvisZombieSprite = vclass("BattleElvisZombieSprite", VBattleDancingZombieSprite)

function VBattleElvisZombieSprite:initialize( battleCreature )
	VBattleDancingZombieSprite.initialize(self, battleCreature);
end

function VBattleElvisZombieSprite:setHpPosition( )
	if self.specialEnterEffect then
		self.lifeImage:setPosition(0, self.armature:getContentSize().height);
	else
		self.lifeImage:setPosition(-self.lifeImage:getContentSize().width * 0.3, self.armature:getContentSize().height);
	end
end
-- 杰克逊（金）
---------------------------------------  BattleJacksonZombieSprite  ---------------------------------------
VBattleJacksonZombieSprite = vclass("BattleJacksonZombieSprite", VBattleDancingZombieSprite)

function VBattleJacksonZombieSprite:initialize( battleCreature )
	VBattleDancingZombieSprite.initialize(self, battleCreature);
end

function VBattleJacksonZombieSprite:dieAndStumpAnimation( )
	local boneList = {"head", "jaw", "leftHair1", "leftHair2", "leftHair3", "leftHair4", "rightHair"};
	self:setStumpAnimation(boneList);
end

function VBattleJacksonZombieSprite:setHpPosition( )
	if self.specialEnterEffect then
		self.lifeImage:setPosition(self.lifeImage:getContentSize().width * 1, self.armature:getContentSize().height + 10);
	else
		self.lifeImage:setPosition(self.lifeImage:getContentSize().width * 0.2, self.armature:getContentSize().height + 10);
	end
end