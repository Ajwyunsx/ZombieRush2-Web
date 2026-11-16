-- vBattlePeaBulletSprite.lua

-- 绿色豌豆
---------------------------------------  BattleGreenPeaBulletSprite  ---------------------------------------
VBattleGreenPeaBulletSprite = vclass("BattleGreenPeaBulletSprite", VBattleBulletSprite)

function VBattleGreenPeaBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.delColor = cc.c3b(189,255,0);
end

function VBattleGreenPeaBulletSprite:setBulletScale( )
	self.imageScale = 0.8;
end

function VBattleGreenPeaBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);

	self.image:setAnchorPoint(cc.p(0, 0));
	self.image:setPosition(self.pos.x+self.image:getContentSize().width/2, self.pos.y);

	gBattleView.impactBulletList[self.id] = self;
end

-- 攻击，飞行
function VBattleGreenPeaBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doPeaLineMove(self);
end

function VBattleGreenPeaBulletSprite:hitSound( )
	gBattleView:playSound("battle_peaBullet_hit_", 3);
end

-- 销毁
function VBattleGreenPeaBulletSprite:die( target, isClean )
	if isClean then
		VBattleBulletSprite.doDel(self);
	else
		self:doPeaDel(target);
	end
end

function VBattleGreenPeaBulletSprite:doPeaDel( target )
	if self.image then
		self:hitSound();
		self.delIndex = 0;
		self.delRandom = math.random(1,2);

		self.image:RunAction{{"delayTime", 0.02}, {function(node) VBattleGreenPeaBulletSprite.doChangePeaBulletImage(node, self) end}};

		if self.delRandom == 1 then
			self.image:setAnchorPoint(cc.p(0.81, 0.3));
		elseif self.delRandom == 2 then
			self.image:setAnchorPoint(cc.p(0.86, 0.42));
		end
		self.finalX = self.image:getPositionX();
		self.finalY = self.image:getPositionY();
	end
end

function VBattleGreenPeaBulletSprite.doChangePeaBulletImage( image, bullet )
	bullet.delIndex = bullet.delIndex + 1;
	if bullet.delIndex <= 5 then
		bullet.image:setPosition(bullet.finalX, bullet.finalY);
		bullet.image:setScaleX(bullet.imageScale * 1.2);
		bullet.image:setScaleY(bullet.imageScale * 1.2);
		bullet.image:setTexture("peaBullet"..bullet.delRandom..bullet.delIndex..".png");
		bullet.image:setColor(bullet.delColor);
		bullet.image:RunAction{{"delayTime", 0.05}, {function(node) VBattleGreenPeaBulletSprite.doChangePeaBulletImage(node, bullet) end}};	
	else
		bullet.image:stopAllActions();
		bullet.image:Delete();
		bullet.image = nil;
	end
end

-- 蓝色豌豆
---------------------------------------  BattleBluePeaBulletSprite  ---------------------------------------
VBattleBluePeaBulletSprite = vclass("BattleBluePeaBulletSprite", VBattleGreenPeaBulletSprite)

function VBattleBluePeaBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.delColor = cc.c3b(0,247,255);
end

function VBattleBluePeaBulletSprite:createSprite( )
	VBattleGreenPeaBulletSprite.createSprite(self);

	self.particleNode = cc.ParticleSystemQuad:create("SnowPeaParticle.plist");
	self.particleNode:setPosition(cc.p(0,self.image:getContentSize().height/2));
	self.image:addChild(self.particleNode);
	self.particleNode:runAction(cc.Sequence:create(cc.FadeTo:create(0,0), cc.DelayTime:create(1), cc.FadeTo:create(0,255)));
end

function VBattleBluePeaBulletSprite:doPeaDel( target )
	if self.image and self.particleNode then
		self.image:removeChild(self.particleNode);
	end

	VBattleGreenPeaBulletSprite.doPeaDel(self, target);
end

-- 绿色豌豆 毒子弹
---------------------------------------  BattlePoisonPeaBulletSprite  ---------------------------------------
VBattlePoisonPeaBulletSprite = vclass("BattlePoisonPeaBulletSprite", VBattleGreenPeaBulletSprite)

function VBattlePoisonPeaBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.delColor = cc.c3b(189,7,245);
end

function VBattlePoisonPeaBulletSprite:setBulletScale( )
	self.imageScale = 1.1;
end

function VBattlePoisonPeaBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);

	self.image:setAnchorPoint(cc.p(0, 0));
	self.image:setPosition(self.pos.x+self.image:getContentSize().width/2, self.pos.y + 6);

	gBattleView.impactBulletList[self.id] = self;

	local flyImageName = "PoisonPeaBulletFly.png";
	local imageWidth = self.image:getContentSize().width;
	local delayTime = 0.07;
	local actionTime = 0.15;
	self.flyNodeList = {};

	for i=1,2 do
		local flyNode = self.image:Push(VImage{image=flyImageName, layout="Left", scale=self.imageScale});
		table.insert(self.flyNodeList, flyNode);
		flyNode:RunAction{{"fadeTo", 0, 0},
							{"delayTime", (i-1)*delayTime},
							{"repeat", -1, 
								{"sequence", 
									{"fadeTo", 0, 255};
									{"spawn", 
										{"moveBy", actionTime, -imageWidth, 0},
										{"fadeTo", actionTime, 0},
										{"sequence",
											{"delayTime", actionTime/2},
											{"scaleTo", actionTime/2, 1.3}
										}
									},
									{"moveBy", 0, imageWidth, 0},
									{"scaleTo", 0, 1}
								}
							}
						};
	end
end

function VBattlePoisonPeaBulletSprite:doPeaDel( target )
	if self.image then
		for i,v in ipairs(self.flyNodeList) do
			v:stopAllActions();
			v:Delete();			
		end
	end

	VBattleGreenPeaBulletSprite.doPeaDel(self, target);
end

-- 黄色豌豆 阻击子弹
---------------------------------------  BattleSnipePeaBulletSprite  ---------------------------------------
VBattleSnipePeaBulletSprite = vclass("BattleSnipePeaBulletSprite", VBattleGreenPeaBulletSprite)

function VBattleSnipePeaBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.delColor = cc.c3b(244,252,61);
end

function VBattleSnipePeaBulletSprite:setBulletScale( )
	self.imageScale = 0.9;
end

function VBattleSnipePeaBulletSprite:createSprite( )
	VBattleGreenPeaBulletSprite.createSprite(self);

	local flyImageName = "SnipePeaBulletFly.png";
	local imageWidth = self.image:getContentSize().width;
	local delayTime = 0.1;
	local actionTime = 0.2;
	self.flyNodeList = {};

	for i=1,2 do
		local flyNode = self.image:Push(VImage{image=flyImageName, layout="Left", scale=self.imageScale});
		table.insert(self.flyNodeList, flyNode);
		flyNode:RunAction{{"fadeTo", 0, 0},
							{"delayTime", (i-1)*delayTime},
							{"repeat", -1, 
								{"sequence", 
									{"fadeTo", 0, 255};
									{"spawn", 
										{"moveBy", actionTime, -imageWidth*1.5, 0},
										{"fadeTo", actionTime, 120},
										{"sequence",
											{"delayTime", actionTime*0.4},
											{"scaleTo", actionTime*0.6, 1.6}
										}
									},
									{"moveBy", 0, imageWidth*1.5, 0},
									{"scaleTo", 0, 1}
								}
							}
						};
	end
end

function VBattleSnipePeaBulletSprite:doPeaDel( target )
	if self.image then
		for i,v in ipairs(self.flyNodeList) do
			v:stopAllActions();
			v:Delete();			
		end
	end

	VBattleGreenPeaBulletSprite.doPeaDel(self, target);
end

-- 三头子弹
---------------------------------------  BattlePeaterPeaBulletSprite  ---------------------------------------
VBattlePeaterPeaBulletSprite = vclass("BattlePeaterPeaBulletSprite", VBattleGreenPeaBulletSprite)

function VBattlePeaterPeaBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
	self.delColor = cc.c3b(244,252,61);
end

function VBattlePeaterPeaBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);

	self.image:setAnchorPoint(cc.p(0, 0));
	if self.parentRoad and self.road ~= self.parentRoad then
		local y = (self.parentRoad - 1) * gBattleView.cellPixH;
		local distance = math.abs(self.pos.y - y);

		if self.road > self.parentRoad then
			self.endPosY = self.pos.y + gBattleView.cellPixH;
			self.pos.y = self.pos.y + distance * 0.8;
		else
			self.endPosY = self.pos.y - gBattleView.cellPixH;
			self.pos.y = self.pos.y - distance * 0.8;
		end
	end
	self.image:setPosition(self.pos.x+self.image:getContentSize().width/2, self.pos.y);
	gBattleView.impactBulletList[self.id] = self;


	local flyImageName = "PeaterPeaBulletFly.png";
	local imageWidth = self.image:getContentSize().width;
	local delayTime = 0.1;
	local actionTime = 0.1;
	self.flyNodeList = {};

	for i=1,2 do
		local flyNode = self.image:Push(VImage{image=flyImageName, layout="Left", scale=self.imageScale, offset={-imageWidth*0.8, 0}});
		table.insert(self.flyNodeList, flyNode);
		flyNode:RunAction{{"fadeTo", 0, 0},
							{"delayTime", (i-1)*delayTime},
							{"repeat", -1, 
								{"sequence", 
									{"fadeTo", 0, 255};
									{"spawn", 
										{"moveBy", actionTime, -imageWidth*0.5, 0},
										{"fadeTo", actionTime, 0},
										{"sequence",
											{"delayTime", actionTime/2},
											{"scaleTo", actionTime/2, 1.3}
										}
									},
									{"moveBy", 0, imageWidth*0.5, 0},
									{"scaleTo", 0, 1}
								}
							}
						};
	end
end

function VBattlePeaterPeaBulletSprite:doPeaDel( target )
	if self.image then
		for i,v in ipairs(self.flyNodeList) do
			v:stopAllActions();
			v:Delete();			
		end
	end

	VBattleGreenPeaBulletSprite.doPeaDel(self, target);
end

-- 血腥海棠子弹
---------------------------------------  BattleBloodyBulletSprite  ---------------------------------------
VBattleBloodyBulletSprite = vclass("BattleBloodyBulletSprite", VBattleBulletSprite)

function VBattleBloodyBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleBloodyBulletSprite:createSprite( )
	self.image = gBattleView.battleLayer:Push(VArmature:createArmature(self.bulletName, "", "DownLeft"));
	self.image.scale = self.imageScale
	self.image.level = self.imageLevel;
	self.image:ReLayout();

	self.image:setPosition(self.pos.x, self.pos.y+self.image:getContentSize().height*self.image:getAnchorPoint().y*self.imageScale);
	gBattleView.impactBulletList[self.id] = self;
end

-- 攻击，飞行
function VBattleBloodyBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doPeaLineMove(self);
	self.image:play("move");
end

-- 销毁
function VBattleBloodyBulletSprite:die( target, isClean )
	self.image:stop();
	VBattleBulletSprite.doDel(self);
end

-- 歌手菊花子弹
---------------------------------------  BattleSingBulletSprite  ---------------------------------------
VBattleSingBulletSprite = vclass("BattleSingBulletSprite", VBattleBulletSprite)

function VBattleSingBulletSprite:initialize( battleBullet, pos, parent )
	VBattleBulletSprite.initialize(self, battleBullet, pos, parent);
end

function VBattleSingBulletSprite:createSprite( )
	VBattleBulletSprite.createSprite(self);

	self.image:setAnchorPoint(cc.p(0.5, 0.5));
	self.image:setPosition(self.pos.x, self.pos.y+self.image:getContentSize().height*self.image.scale/3);

	gBattleView.impactBulletList[self.id] = self;
end

-- 攻击，飞行
function VBattleSingBulletSprite:attack( targetSprite, target )
	VBattleBulletSprite.doLineRotateMove(self);
end

-- 销毁
function VBattleSingBulletSprite:die( target, isClean )
	VBattleBulletSprite.doDel(self);
end

