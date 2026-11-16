-- vBattleThiefBulletSprite.lua

-- 小偷僵尸 石头子弹
---------------------------------------  BattleStoneBulletSprite  ---------------------------------------
VBattleStoneBulletSprite = vclass("BattleStoneBulletSprite", VBattleBulletSprite);

function VBattleStoneBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleStoneBulletSprite:setBulletScale( )
	self.imageScale = 0.4;
end

function VBattleStoneBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);
	self.image:setPosition(self.pos.x, self.pos.y);
end

-- 攻击，飞行
function VBattleStoneBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doThorwMove(self, targetSprite, target, gBattleView.cellPixH * 0.7);
end

function VBattleStoneBulletSprite:hitSound( )
	gBattleView:playSound("battle_cornBullet_hit_", 2);
end

-- 销毁
function VBattleStoneBulletSprite:die( target, isClean )	self:hitSound();
	VBattleBulletSprite.doDel(self);
end

-- 囚犯弓箭子弹
---------------------------------------  BattleArrowBulletSprite  ---------------------------------------
VBattleArrowBulletSprite = vclass("BattleArrowBulletSprite", VBattleStoneBulletSprite);

function VBattleArrowBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleArrowBulletSprite:setBulletScale( )
	local zombie = gBattleView.MonsterList[self.parentId];
	if zombie then
		self.imageScale = zombie.armatureScale * 0.8;
	else
		self.imageScale = 0.7;
	end
end

function VBattleArrowBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);
	self.image:setPosition(self.pos.x, self.pos.y);
	self.image:setRotation(35);
end

-- 攻击，飞行
function VBattleArrowBulletSprite:attack( targetSprite, target )
	self.randomRotation = -100;
	self.halfTimePre = 0.45;
	VBattleBulletSprite.doThorwMove(self, targetSprite, target, gBattleView.cellPixH * 0.8);
end

-- 铁球子弹
---------------------------------------  BattleIronBallBulletSprite  ---------------------------------------
VBattleIronBallBulletSprite = vclass("BattleIronBallBulletSprite", VBattleArrowBulletSprite);

function VBattleIronBallBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleIronBallBulletSprite:setBulletScale( )
	local zombie = gBattleView.MonsterList[self.parentId];
	if zombie then
		self.imageScale = zombie.armatureScale * 1.5;
	else
		self.imageScale = 0.9;
	end
end

function VBattleIronBallBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);
	self.image:setPosition(self.pos.x, self.pos.y);
	self.image:setRotation(50);
end

-- 攻击，飞行
function VBattleArrowBulletSprite:attack( targetSprite, target )
	self.randomRotation = -100;
	self.halfTimePre = 0.45;
	VBattleBulletSprite.doThorwMove(self, targetSprite, target, gBattleView.cellPixH * 0.5);
end

-- 罗宾汉普攻弓箭子弹
---------------------------------------  BattleRedArrowBulletSprite  ---------------------------------------
VBattleRedArrowBulletSprite = vclass("BattleRedArrowBulletSprite", VBattleArrowBulletSprite);

function VBattleRedArrowBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleRedArrowBulletSprite:setBulletScale( )
	local zombie = gBattleView.MonsterList[self.parentId];
	if zombie then
		self.imageScale = zombie.armatureScale * 1;
	else
		self.imageScale = 0.6;
	end
end

function VBattleRedArrowBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);
	self.image:setPosition(self.pos.x, self.pos.y);
	self.image:setRotation(35);
end


-- 罗宾汉技能弓箭子弹
---------------------------------------  BattleGreenArrowBulletSprite  ---------------------------------------
VBattleGreenArrowBulletSprite = vclass("BattleGreenArrowBulletSprite", VBattleArrowBulletSprite);

function VBattleGreenArrowBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleGreenArrowBulletSprite:setBulletScale( )
	local zombie = gBattleView.MonsterList[self.parentId];
	if zombie then
		self.imageScale = zombie.armatureScale * 1.6;
	else
		self.imageScale = 0.9;
	end
end

function VBattleGreenArrowBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);
	self.image:setPosition(self.pos.x, self.pos.y);
	self.image:setRotation(35);
end

-- 鬼面子弹
---------------------------------------  BattleGhostArrowBulletSprite  ---------------------------------------
VBattleGhostArrowBulletSprite = vclass("BattleGhostArrowBulletSprite", VBattleArrowBulletSprite);

function VBattleGhostArrowBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleGhostArrowBulletSprite:setBulletScale( )
	local zombie = gBattleView.MonsterList[self.parentId];
	if zombie then
		self.imageScale = zombie.armatureScale * 1.2;
	else
		self.imageScale = 1;
	end
end

function VBattleGhostArrowBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);
	self.image:setPosition(self.pos.x, self.pos.y);
	self.image:setRotation(35);
end