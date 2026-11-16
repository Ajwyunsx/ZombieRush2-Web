-- vBattleMagicZombieSprite.lua

-- 魔术师（白）
---------------------------------------  BattleMagicZombieSprite  ---------------------------------------
VBattleMagicZombieSprite = vclass("BattleMagicZombieSprite", VBattleMonsterSprite)

function VBattleMagicZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleMagicZombieSprite:initMonsterSprite( )
	VBattleMonsterSprite.initMonsterSprite(self);
	-- 出场时候棒子上需要粒子效果
	self.armature:addParticleBone("magicWand", "magicParticle.plist");
end

function VBattleMagicZombieSprite:getShootPos( )
	return self.armature:getBonePos("shootNode");
end

function VBattleMagicZombieSprite:attackAnimation( )
	self.isAttacking = true;
	self.animationType = ECreatureAnimationType.ANIMATION_ATTACK;
	-- self.armature:stop();
	self.armature:play("attack", 0.1, 0);
end

function VBattleMagicZombieSprite:cleanMagicLight( )
	-- cclog("**** VBattleMagicZombieSprite:cleanMagicLight");
	if #self.monsterBulletId > 0 then
		for i=#self.monsterBulletId,1,-1 do
			gBattleView:removeBulletSprite(self.monsterBulletId[i]);
		end
	end
end

-- 黑魔法师（绿）
---------------------------------------  BattleDarkMagicZombieSprite  ---------------------------------------
VBattleDarkMagicZombieSprite = vclass("BattleDarkMagicZombieSprite", VBattleMagicZombieSprite)

function VBattleDarkMagicZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleDarkMagicZombieSprite:initMonsterSprite( )
	VBattleMonsterSprite.initMonsterSprite(self);
end

function VBattleDarkMagicZombieSprite:dieAndStumpAnimation( )
	local boneList = {"head", "jaw", "headCap"};
	self:setStumpAnimation(boneList);
end

-- 占卜师（蓝）
---------------------------------------  BattleAugurZombieSprite  ---------------------------------------
VBattleAugurZombieSprite = vclass("BattleAugurZombieSprite", VBattleMonsterSprite)

function VBattleAugurZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 重伤
function VBattleAugurZombieSprite:halfLifeAnimation( )
	return;
end

function VBattleAugurZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
end

function VBattleAugurZombieSprite:finishAttackAnimation()
	self.armature:play("idle");
end

-- 甘道夫（紫）
---------------------------------------  BattleGandalfZombieSprite  ---------------------------------------
VBattleGandalfZombieSprite = vclass("BattleGandalfZombieSprite", VBattleMonsterSprite)

function VBattleGandalfZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

-- 重伤
function VBattleGandalfZombieSprite:halfLifeAnimation( )
	return;
end

function VBattleGandalfZombieSprite:getShootPos( )
	return self.armature:getBonePos("shootNode");
end

function VBattleGandalfZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
end

-- 雷神托尔（金）
---------------------------------------  BattleThorZombieSprite  ---------------------------------------
VBattleThorZombieSprite = vclass("BattleThorZombieSprite", VBattleMagicZombieSprite)

function VBattleThorZombieSprite:initialize( battleCreature )
	VBattleMagicZombieSprite.initialize(self, battleCreature);
end

function VBattleThorZombieSprite:initMonsterSprite( )
	VBattleMonsterSprite.initMonsterSprite(self);
end

function VBattleThorZombieSprite:dieAndStumpAnimation( )
	local boneList = {"head", "jaw", "headCap"};
	self:setStumpAnimation(boneList);
end

function VBattleThorZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);
	VBattleMagicZombieSprite.cleanMagicLight(self);

	self.armature:play("skill", -1, 0);
	self.skillPos = battleCreature:GetPos();
end

function VBattleThorZombieSprite:showThunderboltAnimation( )
	local lightLevel = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.BULLET_LEVEL - self.road);
	local num = math.floor(self.skillPos / 10);
	for i=num,1,-1 do
		local randomIndex = math.random(1,3);
		local imageName = "ThunderboltBullet"..randomIndex..".png";
		local lightImg = gBattleView.battleLayer:Push(VImage{image=imageName, scale=self.armatureScale, level=lightLevel});
		lightImg.imageIndex = randomIndex;
		lightImg.imageName = "ThunderboltBullet";
		lightImg.pos = i * gBattleView.cellNum;
		lightImg:setAnchorPoint(cc.p(0,0.5));
		lightImg:setRotation(-90);
		local posPoint = cc.p((i * gBattleView.cellNum - gBattleView.cellNum/2) * gBattleView.cellMinPixW , gBattleView:getContentSize().height / self.armatureScale);
		lightImg:setPosition(posPoint.x, posPoint.y);

		local posy = (self.road - 1) * gBattleView.cellPixH + gBattleView.cellPixH/2;
		local moveTime = 0.1;
		local delayTime = 0.05;
		local repeatTime = moveTime / delayTime;
		lightImg:RunAction{"sequence", 
								{"delayTime", 0.03 * (num-i)},
								{"spawn",
									{"moveTo", moveTime, posPoint.x, posy},
									{"repeat", repeatTime,
										{"sequence",
											{"delayTime", delayTime}, 
											{function(node) VBattleThorZombieSprite.changeLightning(node, lightImg) end}
										}
									}
								},
								{function(node) VBattleThorZombieSprite.finishMoveDown(node, lightImg, self) end}
							};
	end
end

function VBattleThorZombieSprite.changeLightning( node, imageNode )
	imageNode.imageIndex = imageNode.imageIndex + 1;
	if imageNode.imageIndex > 3 then
		imageNode.imageIndex = 1;
	end

	local imageName = imageNode.imageName..imageNode.imageIndex..".png";
	imageNode:setTexture(imageName);
end

function VBattleThorZombieSprite.finishMoveDown( node, imageNode, sprite )
	local lightLevel = (gBattleView.maxLevel - sprite.road) * (EAnimationSpriteLevel.BULLET_LEVEL - sprite.road);
	local hitImg = gBattleView.battleLayer:Push(VImage{image="ThunderboltBulletHit1.png", scale=sprite.armatureScale, level=lightLevel});
	hitImg.imageName = "ThunderboltBulletHit";
	hitImg.imageIndex = 1;

	local posPoint = cc.p((imageNode.pos - gBattleView.cellNum/2 ) * gBattleView.cellMinPixW, (sprite.road - 1) * gBattleView.cellPixH + gBattleView.cellPixH/2);
	hitImg:setPosition(posPoint.x, posPoint.y);

	local allTime = 0.4;
	local delayTime =0.05;
	local repeatTime = allTime / delayTime;

	imageNode:setAnchorPoint(cc.p(0,0.5));
	imageNode:RunAction{"sequence", 
								{"spawn",
									{"sequence", 
										{"delayTime", allTime*0.95}, 
										{"scaleTo", allTime*0.05, 0, 1},
									},
									{"repeat", repeatTime,
										{"sequence",
											{"delayTime", delayTime}, 
											{function(node) VBattleThorZombieSprite.changeLightning(node, imageNode) end}
										}
									}
								},
								{"delete"};
							};

	hitImg:RunAction{"sequence", 
								{"spawn",
									{"sequence", 
										{"delayTime", allTime*0.9}, 
										{"scaleTo", allTime*0.1, 0.5, 0.5},
									},
									{"repeat", repeatTime,
										{"sequence",
											{"delayTime", delayTime}, 
											{function(node) VBattleThorZombieSprite.changeLightning(node, hitImg) end}
										}
									}
								},
								{"delete"};
							};
end