-- vBattleIMPSprite.lua

-- 小僵尸（白）
---------------------------------------  BattleIMPSprite  ---------------------------------------
VBattleIMPSprite = vclass("BattleIMPSprite", VBattleMonsterSprite)

function VBattleIMPSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleIMPSprite:initMonsterSprite( )
	self.anchorPx = 0.6;
	self.anchorPy = 0.09;
	self.armature:setAnchorPoint(cc.p(0.5,0.5));
	local Gargantuar = gBattleView.MonsterList[self.parentId];
	local pos = gBattleView.battleLayer:convertToNodeSpace(Gargantuar.armature:getBonePos("handNode"));
	self.armature:setPosition(pos.x-2, pos.y-11);
	self.armature:setRotation(-80);
end

function VBattleIMPSprite:stayAnimation( )
	self.armature:stop();
end

function VBattleIMPSprite:setHpPosition( )
	self.lifeImage:setPosition(-self.lifeImage:getContentSize().width * 0.2, self.armature:getContentSize().height);
end

function VBattleIMPSprite:showHpAnimation( battleCreature )
	if self.isFlying then
		return;
	end
	if self.valid and not self.lifeImage then
		self:setHpImage();
	end

	VBattleMonsterSprite.showHpAnimation(self, battleCreature);
end

-- 重伤
function VBattleIMPSprite:halfLifeAnimation( )
	if not self.halfLife then
		self.halfLife = true;

		local boneList = {"leftHand"};
		self.armature:changeDisplay("leftForearm", nil, 1);
		self:setStumpAnimation(boneList);
	end
end

function VBattleIMPSprite:walkAnimation( )
	self:impIsStartAction();
	VBattleMonsterSprite.walkAnimation(self);
end

function VBattleIMPSprite:attack( )
	self:impIsStartAction();

	VBattleMonsterSprite.attack(self);
end

function VBattleIMPSprite:impIsStartAction( )
	if self.isFlying then
		self.isFlying = false;
		self.armature:setAnchorPoint(cc.p(self.anchorPx, self.anchorPy));
		self.armature:setRotation(0);

		local posX = self.pos * gBattleView.cellMinPixW;
		local posY = (self.road - 1) * gBattleView.cellPixH;
		self.armature:setPosition(posX, posY);
	end
end

function VBattleIMPSprite:doingSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	gBattleView:playSound("battle_IMP_Fly_", 2);

	self.isFlying = true;
	local posX = self.pos * gBattleView.cellMinPixW;
	local posY = (self.road - 1) * gBattleView.cellPixH + self.armature:getContentSize().height * math.abs(self.armature:getAnchorPoint().y - self.anchorPy) * self.armature.scale;

	local x = math.abs(self.armature:getPositionX() - posX);
	local y = math.abs(self.armature:getPositionY() - posY);

	local moveTime = 0.1;
	self.allTime = 0.6;
	self.speedY = 0;	-- 初始垂直速度为0
	self.accY = -2 * y / math.pow(self.allTime, 2);
	self.flytime = self.allTime;
	self.throwSpeed = x / self.allTime;

	local moveX = 0 - self.throwSpeed * moveTime;
	local moveY = self.speedY * moveTime + 0.5 * self.accY * moveTime * moveTime;
	local rotation = -80 + (self.allTime - self.flytime) / self.allTime * -280;
	if self.isAttack then
		rotation = 0 - rotation;
		moveX = 0 - moveX;
	end
	self.armature:RunAction({"sequence", {"spawn",{"moveBy", moveTime, moveX, moveY}, {"rotateTo", moveTime, rotation}}, {function(node) VBattleIMPSprite.flying(node, self, moveTime) end}});
end

function VBattleIMPSprite.flying( node, monster, moveTime )
	monster.flytime = monster.flytime - moveTime;

	if monster.flytime > 0 then
		monster.speedY = monster.speedY + monster.accY * moveTime;
		local moveX = 0 - monster.throwSpeed * moveTime;
		local moveY = monster.speedY * moveTime + 0.5 * monster.accY * moveTime * moveTime;
		local rotation = -80 + (monster.allTime - monster.flytime) / monster.allTime * -280;

		monster.armature:RunAction({"sequence", {"spawn",{"moveBy", moveTime, moveX, moveY}, {"rotateTo", moveTime, rotation}}, {function(node) VBattleIMPSprite.flying(node, monster, moveTime) end}});
	else
		monster.armature:stopAllActions();
		monster:impIsStartAction();
	end
end

-- 火焰小僵尸（绿）
---------------------------------------  BattleFireIMPSprite  ---------------------------------------
VBattleFireIMPSprite = vclass("BattleFireIMPSprite", VBattleIMPSprite)

function VBattleFireIMPSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 寒冰小僵尸（蓝）
---------------------------------------  BattleFrozenIMPSprite  ---------------------------------------
VBattleFrozenIMPSprite = vclass("BattleFrozenIMPSprite", VBattleIMPSprite)

function VBattleFrozenIMPSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end
