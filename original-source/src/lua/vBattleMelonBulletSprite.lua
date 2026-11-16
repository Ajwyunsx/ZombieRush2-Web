-- vBattleMelonBulletSprite.lua

-- 西瓜子弹
---------------------------------------  BattleMelonBulletSprite  ---------------------------------------
VBattleMelonBulletSprite = vclass("BattleMelonBulletSprite", VBattleBulletSprite)

function VBattleMelonBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "MelonExplode";
end

function VBattleMelonBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);

	self.image:setRotation(65);	
	self.image:setPosition(self.pos.x, self.pos.y);
end

-- 攻击，飞行
function VBattleMelonBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doThorwMove(self, targetSprite, target, 2 * gBattleView.cellPixH);
end

function VBattleMelonBulletSprite:hitSound( )
	gBattleView:playSound("battle_melonBullet_hit_", 2);
end

-- 销毁
function VBattleMelonBulletSprite:die( target, isClean )
	if isClean then
		VBattleBulletSprite.doDel(self);
	else
		self:doMelonBulletDel();
	end
end

function VBattleMelonBulletSprite:deleteExplode( )
	if self.explodeArmature then
		self.explodeArmature:Delete();
		self.explodeArmature = nil;
		gBattleView:removeBulletId(self.id);
	end
end

-- 西瓜子弹销毁动画
function VBattleMelonBulletSprite:doMelonBulletDel( )
	if self.image then
		self:hitSound();

		self.image:stopAllActions();
		self:addExplodeArmature();

		self.image:Delete();
		self.image = nil;
	end
end

function VBattleMelonBulletSprite:addExplodeArmature( )
	if self.explodeName then
		local pos = cc.p(self.image:getPositionX(), self.image:getPositionY());
		-- pos.x = pos.x - self.image:getContentSize().width*self.image:getAnchorPoint().x;

		self.explodeArmature = gBattleView.battleLayer:Push(VArmature:createArmature(self.explodeName));
		-- self.explodeArmature:setAnchorPoint(cc.p(0.5,0));
		self.explodeArmature.scale = self.image.scale;
		self.explodeArmature.level = self.imageLevel;
		self.explodeArmature:ReLayout();
		self.explodeArmature:setPosition(pos.x, pos.y);

		local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
			self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
		end 
		self.explodeArmature:setEventCallFunc(callBack);

		self.explodeArmature:play("explode",-1,0);
	end
end

function VBattleMelonBulletSprite:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	if evt == "finishExplode" then
		self:deleteExplode();
	end
end

-- 火焰西瓜子弹
---------------------------------------  BattleFireMelonBulletSprite  ---------------------------------------
VBattleFireMelonBulletSprite = vclass("BattleFireMelonBulletSprite", VBattleMelonBulletSprite)

function VBattleFireMelonBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "FireMelonExplode";
	self.lowestY = (self.road - 1) * gBattleView.cellPixH + gBattleView.cellMinPixH * 0.75;
end

function VBattleFireMelonBulletSprite:setBulletScale( )
	self.imageScale = 0.8;
end

function VBattleFireMelonBulletSprite:addExplodeArmature( )
	if self.explodeName then
		local pos = cc.p(self.image:getPositionX(), (self.road - 0.1) * gBattleView.cellPixH);

		self.explodeArmature = gBattleView.battleLayer:Push(VArmature:createArmature(self.explodeName));
		-- self.explodeArmature:setAnchorPoint(cc.p(0.5,0));
		self.explodeArmature.scale = self.image.scale;
		self.explodeArmature.level = self.imageLevel;
		self.explodeArmature:ReLayout();
		self.explodeArmature:setPosition(pos.x, pos.y);

		local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
			self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
		end 
		self.explodeArmature:setEventCallFunc(callBack);

		self.explodeArmature:play("explode",-1,0);
	end
end

function VBattleFireMelonBulletSprite:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	if evt == "finishExplode" then
		if self.explodeArmature then
			self.explodeArmature:play("fire");
		end
	end
end

function VBattleFireMelonBulletSprite:removeFire( )
	self.explodeArmature:RunAction{{"fadeTo", 0.3, 0}, {function(node) VBattleFireMelonBulletSprite.finishRemoveAniamtion(node, self) end}};
end

function VBattleFireMelonBulletSprite.finishRemoveAniamtion( node, bulletSprite )
	bulletSprite:deleteExplode();
end

-- 寒冰西瓜子弹
---------------------------------------  BattleWinterMelonBulletSprite  ---------------------------------------
VBattleWinterMelonBulletSprite = vclass("BattleWinterMelonBulletSprite", VBattleMelonBulletSprite)

function VBattleWinterMelonBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "WinterMelonExplode";
end

-- 定时炸弹西瓜子弹
---------------------------------------  BattleBombMelonBulletSprite  ---------------------------------------
VBattleBombMelonBulletSprite = vclass("BattleBombMelonBulletSprite", VBattleMelonBulletSprite)

function VBattleBombMelonBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "BombExplode";
end

-- 定时炸弹销毁动画
function VBattleBombMelonBulletSprite:doMelonBulletDel( )
	if self.image then
		self:hitSound();
		self:addExplodeArmature();
	end
end

function VBattleBombMelonBulletSprite:deleteExplode( )
	if self.explodeArmature then
		self.explodeArmature:Delete();
		self.explodeArmature = nil;
	end
end

function VBattleBombMelonBulletSprite:resetPosition( battleObject )
	local x = 0;
	if self.explodeArmature then
		x = self.explodeArmature:getPositionX();
	else
		x = (battleObject:GetPos() - gBattleView.cellNum/2 ) * gBattleView.cellMinPixW;
	end
	local posPoint = cc.p(x, (battleObject:GetRoad() - 1) * gBattleView.cellPixH + self.image:getContentSize().height * (self.imageScale * 0.8) * 0.5);
	self.image:RunAction{{"rotateTo", 0, 0}, {"scaleTo", 0, self.imageScale * 0.8}, {"moveTo", 0.3, posPoint.x, posPoint.y}};
end

function VBattleBombMelonBulletSprite:removeBomb( )
	self.image.scale = self.imageScale;
	VBattleMelonBulletSprite.doMelonBulletDel(self);
end

-- 时空西瓜子弹
---------------------------------------  BattleSpaceMelonBulletSprite  ---------------------------------------
VBattleSpaceMelonBulletSprite = vclass("BattleSpaceMelonBulletSprite", VBattleMelonBulletSprite)

function VBattleSpaceMelonBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "SpaceMelonExplode";
end

-- 时空西瓜子弹
---------------------------------------  BattleBlackHoleMelonBulletSprite  ---------------------------------------
VBattleBlackHoleMelonBulletSprite = vclass("BattleBlackHoleMelonBulletSprite", VBattleMelonBulletSprite)

function VBattleBlackHoleMelonBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "SpaceMelonExplode";
end

function VBattleBlackHoleMelonBulletSprite:createSprite( )
	self.imageName = "SpaceMelonBullet.png";
	VBattleBulletSprite.createSprite(self);
	-- self.image:setRotation(65);	
	self.image:setPosition(self.pos.x, self.pos.y);
	self.randomRotation = 1000;
end

function VBattleBlackHoleMelonBulletSprite:doMelonBulletDel( )
	if self.image then
		self:hitSound();
		self.image:stopAllActions();
		if not self.explodeArmature and self.explodeName == "BlackHoleExplode" then
			self:addExplodeArmature();
		end
	end
end

function VBattleBlackHoleMelonBulletSprite:deleteExplode( )
	if self.explodeName == "SpaceMelonExplode" then
		if self.explodeArmature then
			self.explodeArmature:Delete();
			self.explodeArmature = nil;
		end
	elseif self.explodeName == "BlackHoleExplode" then
		VBattleMelonBulletSprite.deleteExplode(self);
	end
end

function VBattleBlackHoleMelonBulletSprite:setBlackHole( battleObject )
	local x = 0;
	if self.explodeArmature then
		x = self.explodeArmature:getPositionX();
	else
		x = (battleObject:GetPos() - gBattleView.cellNum/2 ) * gBattleView.cellMinPixW;
	end
	local pos = cc.p(x, (battleObject:GetRoad() - 1 + 0.5) * gBattleView.cellPixH);

	self.image.visible = 0;
	self.image:setPosition(pos.x, pos.y);
	self.explodeName = "BlackHoleExplode";
	if not self.explodeArmature and self.explodeName == "BlackHoleExplode" then
		self:addExplodeArmature();
		self.explodeArmature.level = (gBattleView.maxLevel - self.road);
	end
end

-- 炸弹人子弹
---------------------------------------  BattleBombPitcherBulletSprite  ---------------------------------------
VBattleBombPitcherBulletSprite = vclass("BattleBombPitcherBulletSprite", VBattleMelonBulletSprite)

function VBattleBombPitcherBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.explodeName = "BombPitcherExplode";
end

function VBattleBombPitcherBulletSprite:setBulletScale( )
	self.imageScale = 1.0;
end

function VBattleBombPitcherBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);

	-- self.image:setAnchorPoint(cc.p(0.54,0.56));
	self.image:setRotation(-60);	
	self.image:setPosition(self.pos.x-4, self.pos.y+14);
end

-- 攻击，飞行
function VBattleBombPitcherBulletSprite:attack( targetSprite, target )
	self.randomRotation = -120;
	self.halfTimePre = 0.33;
	VBattleBulletSprite.doThorwMove(self, targetSprite, target, gBattleView.cellPixH * 0.1);
end
