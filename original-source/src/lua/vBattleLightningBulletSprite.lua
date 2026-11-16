-- vBattleLightningBulletSprite.lua

-- 闪电子弹
---------------------------------------  BattleMagicLightningBulletSprite  ---------------------------------------
VBattleMagicLightningBulletSprite = vclass("BattleMagicLightningBulletSprite", VBattleBulletSprite)

function VBattleMagicLightningBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleMagicLightningBulletSprite:createSprite( )
	self.imageName = self.bulletName.."1.png";
	VBattleBulletSprite.createSprite(self);

	self.image:setAnchorPoint(cc.p(1,0.5));
	self.image:setScaleX(0);
	self.image:setScaleY(self.imageScale);
	self.image.level = self.imageLevel;
	self.image:ReLayout();
	self.image:setPosition(self.pos.x, self.pos.y);
end

-- 攻击，飞行
function VBattleMagicLightningBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doLightningMove(self, targetSprite, target);
end

function VBattleMagicLightningBulletSprite:die( target, isClean )
	VBattleBulletSprite.doDel(self);

	if self.hitImage then
		self.hitImage:stopAllActions();
		self.hitImage:Delete();
		self.hitImage = nil;
	end
end

-- 黑魔法闪电子弹
---------------------------------------  BattleDarkMagicLightningBulletSprite  ---------------------------------------
VBattleDarkMagicLightningBulletSprite = vclass("BattleDarkMagicLightningBulletSprite", VBattleMagicLightningBulletSprite)

function VBattleDarkMagicLightningBulletSprite:initialize( battleBullet, pos, parent )
	VBattleMagicLightningBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleDarkMagicLightningBulletSprite:createSprite( )
	self.bulletName = "ThunderboltBullet";
	VBattleMagicLightningBulletSprite.createSprite(self);
	self.angle = 0;
end

-- 甘道夫 小火球子弹
---------------------------------------  BattleSmallFireBallBulletSprite  ---------------------------------------
VBattleSmallFireBallBulletSprite = vclass("BattleSmallFireBallBulletSprite", VBattleBulletSprite)

function VBattleSmallFireBallBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleSmallFireBallBulletSprite:createSprite( )
	self.imageName = "FireBallBullet1.png";
	-- self.imageScale = 1;
	VBattleBulletSprite.createSprite(self);
	local childImage = self.image:Push(VImage{image="FireBallBullet.png", layout="Down", scale=self.image.scale});

	self.image:setRotation(135);
	self.image:setPosition(self.pos.x, self.pos.y);
end

-- 攻击，飞行
function VBattleSmallFireBallBulletSprite:attack( targetSprite, target )
	self.randomRotation = -200;
	self.halfTimePre = 0.3;
	VBattleBulletSprite.doThorwMove(self, targetSprite, target, gBattleView.cellPixH*0.05);
	self.accY = self.accY * 1.3;
end

function VBattleSmallFireBallBulletSprite:die( target, isClean )
	VBattleBulletSprite.doDel(self);
end

-- 甘道夫 大火球子弹
---------------------------------------  BattleBigFireBallBulletSprite  ---------------------------------------
VBattleBigFireBallBulletSprite = vclass("BattleBigFireBallBulletSprite", VBattleMelonBulletSprite)

function VBattleBigFireBallBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "FireBallBulletExplode";
end

function VBattleBigFireBallBulletSprite:createSprite( )
	self.imageName = "FireBallBullet1.png";
	local zombie = gBattleView.MonsterList[self.parentId];
	local childScale = 1;
	if zombie then
		self.imageScale = zombie.armatureScale * 3;
		childScale = zombie.armatureScale * 2;
	else
		self.imageScale = 1.2;
		childScale = self.imageScale;
	end

	VBattleBulletSprite.createSprite(self);
	local childImage = self.image:Push(VImage{image="FireBallBullet.png", layout="Down", scale=childScale});

	self.image:setRotation(90);
	self.image:setAnchorPoint(cc.p(0,0));
	self.image:setPosition(self.pos.x, self.pos.y);
	gBattleView.impactBulletList[self.id] = self;
end

function VBattleBigFireBallBulletSprite:getBulletRect( )
	local bulletW = self.image:getContentSize().width;
	local bulletH = self.image:getContentSize().height;
	local bulletX = self.image:getPositionX() - bulletW/2;
	local bulletY = self.image:getPositionY() - bulletH / 2;
	return cc.rect(bulletX, bulletY, bulletW-4, bulletH);
end

-- 攻击，飞行
function VBattleBigFireBallBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doPeaLineMove(self);
end

function VBattleBigFireBallBulletSprite:die( target )
	self:doMelonBulletDel();
end

function VBattleBigFireBallBulletSprite:hitSound( )
	-- gBattleView:playSound("battle_melonBullet_hit_", 2);
end

-- 雷神子弹
---------------------------------------  BattleThunderboltBulletSprite  ---------------------------------------
VBattleThunderboltBulletSprite = vclass("BattleThunderboltBulletSprite", VBattleMagicLightningBulletSprite)

function VBattleThunderboltBulletSprite:initialize( battleBullet, pos, parent )
	VBattleMagicLightningBulletSprite.initialize(self, battleBullet, pos, parent);
end
