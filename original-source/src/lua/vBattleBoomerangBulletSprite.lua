-- vBattleBoomerangBulletSprite.lua

VBattleBoomerangBulletSprite = vclass("BattleBoomerangBulletSprite", VBattleBulletSprite)

function VBattleBoomerangBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleBoomerangBulletSprite:createSprite( )
	self.image = gBattleView.battleLayer:Push(VArmature:createArmature(self.imageName));

	self.image:setAnchorPoint(cc.p(0.5,0));
	self.image.scale = self.imageScale;
	self.image.level = self.imageLevel;
	self.image:ReLayout();
	self.image:setPosition(self.pos.x+self.image:getContentSize().width/2, self.pos.y);
	self.image:play("move");
end

-- 攻击，飞行
function VBattleBoomerangBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doBoomerangRotationMove(self, targetSprite, target);
end

function VBattleBoomerangBulletSprite:hitSound( )
	gBattleView:playSound("battle_boomerang_bullet_hit");
end

-- 销毁
function VBattleBoomerangBulletSprite:die( target, isClean )
	VBattleBulletSprite.doDel(self);
end