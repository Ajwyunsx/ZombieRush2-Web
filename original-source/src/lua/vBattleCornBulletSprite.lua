-- vBattleCornBulletSprite.lua
require "vBattleMelonBulletSprite"

-- 玉米子弹
---------------------------------------  BattleCornBulletSprite  ---------------------------------------
VBattleCornBulletSprite = vclass("BattleCornBulletSprite", VBattleBulletSprite);

function VBattleCornBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleCornBulletSprite:setBulletScale( )
	self.imageScale = 1;
end

function VBattleCornBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);
	self.image:setPosition(self.pos.x, self.pos.y);
end

-- 攻击，飞行
function VBattleCornBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doThorwMove(self, targetSprite, target, 2 * gBattleView.cellPixH);
end

function VBattleCornBulletSprite:hitSound( )
	gBattleView:playSound("battle_cornBullet_hit_", 2);
end

-- 销毁
function VBattleCornBulletSprite:die( target, isClean )
	self:hitSound();
	VBattleBulletSprite.doDel(self);
end

-- 糯玉米子弹
---------------------------------------  BattleGlutinousBulletSprite  ---------------------------------------
VBattleGlutinousBulletSprite = vclass("BattleGlutinousBulletSprite", VBattleCornBulletSprite);

function VBattleGlutinousBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

-- 糯玉米技能子弹
---------------------------------------  BattleGlutinousSkillBulletSprite  ---------------------------------------
VBattleGlutinousSkillBulletSprite = vclass("BattleGlutinousSkillBulletSprite", VBattleCornBulletSprite);

function VBattleGlutinousSkillBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

-- 孢子玉米子弹
---------------------------------------  BattleSporeCornBulletSprite  ---------------------------------------
VBattleSporeCornBulletSprite = vclass("BattleSporeCornBulletSprite", VBattleMelonBulletSprite);

function VBattleSporeCornBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "SporeCornExplode";
end

-- 熔岩玉米子弹
---------------------------------------  BattleLavaBulletSprite  ---------------------------------------
VBattleLavaBulletSprite = vclass("BattleLavaBulletSprite", VBattleMelonBulletSprite);

function VBattleLavaBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "LavaExplode";
end

-- 肥皂玉米子弹
---------------------------------------  BattleSoapCornBulletSprite  ---------------------------------------
VBattleSoapCornBulletSprite = vclass("BattleSoapCornBulletSprite", VBattleMelonBulletSprite);

function VBattleSoapCornBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "SoapCornExplode";
end

function VBattleSoapCornBulletSprite:setBulletScale( )
	self.imageScale = 1;
end

function VBattleSoapCornBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);
	self.image:setPosition(self.pos.x, self.pos.y);
end

-- 橄榄球子弹
-- 瑞宇说 当目标过近的时候 可以接受这个违反物理运动轨迹的橄榄球动画 2015/06/01 16:38:44 设计如此
---------------------------------------  BattleFootBallBulletSprite  ---------------------------------------
VBattleFootBallBulletSprite = vclass("BattleFootBallBulletSprite", VBattleCornBulletSprite)

function VBattleFootBallBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

-- 攻击，飞行
function VBattleFootBallBulletSprite:attack( targetSprite, target )
	self.incrementY = -gBattleView.cellPixH*0.2;
	VBattleBulletSprite.doThorwMove(self, targetSprite, target, gBattleView.cellPixH*0.3);
end