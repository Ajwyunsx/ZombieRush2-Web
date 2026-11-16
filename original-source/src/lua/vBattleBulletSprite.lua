--vBattleBulletSprite.lua

---------------------------------------  BattleBulletSprite  ---------------------------------------

VBattleBulletSprite = vclass("BattleBulletSprite");

function VBattleBulletSprite:initialize( battleBullet, pos, parent )
	self.id = battleBullet:GetId();
	self.type = battleBullet.m_prop.id;
	self.speed = battleBullet.m_prop.speed;
	self.road = battleBullet:GetRoad();
	self.isAttack = battleBullet:GetIsAttack();
	self.attackType = battleBullet.m_prop.attack_type;
	self.bulletName = battleBullet.m_prop.image;
	self.imageName = battleBullet.m_prop.image..".png";

	self.pos = gBattleView.battleLayer:convertToNodeSpace(pos);
	self.distance = self.speed * gBattleView.cellMinPixW;

	self:setParentData(parent);
	self:setBulletLevel();
	self:setBulletScale();
	self:createSprite();
	self.image.data = self;
end

function VBattleBulletSprite:setParentData( battleCreature )
	if battleCreature then
		self.parentId = battleCreature:GetId();
		self.parentRoad = battleCreature:GetRoad();
	end
end

function VBattleBulletSprite:setBulletLevel( )
	self.imageLevel = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.BULLET_LEVEL - self.road);
end

function VBattleBulletSprite:setBulletScale( )
	self.imageScale = 0.6;
end

function VBattleBulletSprite:createSprite( )
	self.image = gBattleView.battleLayer:Push(VImage{image=self.imageName, scale=self.imageScale, level=self.imageLevel});
end

function VBattleBulletSprite:stopAllAnimation( )
	if self.image then
		self.image:stopAllActions();
	end
end

function VBattleBulletSprite:getBulletRect( )
	local bulletW = self.image:getContentSize().width;
	local bulletH = self.image:getContentSize().height;
	local bulletX = self.image:getPositionX() - bulletW/2;
	local bulletY = self.image:getPositionY() + bulletH / 2;
	return cc.rect(bulletX, bulletY, bulletW-4, bulletH);
end

-- 攻击，飞行
function VBattleBulletSprite:attack( targetSprite, target )
	-- 子类实现
end

function VBattleBulletSprite:hitSound( )
	-- 子类实现
end

-- 销毁
function VBattleBulletSprite:die( target, isClean )
	if isClean then
		self:doDel();
	end
end

function VBattleBulletSprite:deleteSprite( )
	if self.image then
		self.image:Delete();
	end
end

---------------------------------------  豌豆子弹直线动画  ---------------------------------------
function VBattleBulletSprite:doPeaLineMove( )
	local actionTime = 0.1;
	-- 子弹飞行速度减少1帧速度
	local moveSpeed = self.distance * actionTime;
	if self.isAttack then
		self.image:RunAction({"repeatForever", {"sequence", {"moveBy", actionTime, -moveSpeed, 0}, {VBattleBulletSprite.checkOutSide, self.image}}});
	else
		if self.endPosY then
			local distanceY = self.endPosY - self.image:getPositionY();
			self.image:RunAction({"spawn", {"moveBy", actionTime*2.5, 0, distanceY}, {"repeat", -1, {"sequence", {"moveBy", actionTime, moveSpeed, 0}, {VBattleBulletSprite.checkOutSide, self.image}}}});
		else
			self.image:RunAction({"repeatForever", {"sequence", {"moveBy", actionTime, moveSpeed, 0}, {VBattleBulletSprite.checkOutSide, self.image}}});
		end
	end
end

---------------------------------------  子弹直线+旋转动画  ---------------------------------------
function VBattleBulletSprite:doLineRotateMove( )
	local actionTime = 0.1;
	-- 子弹飞行速度减少1帧速度
	local moveSpeed = self.distance * actionTime;
	local angle = 360 * actionTime / 4;

	if self.isAttack then
		self.image:RunAction({"repeatForever", {"sequence", {"spawn", {"moveBy", actionTime, -moveSpeed, 0}, {"rotateBy", actionTime, angle}}, {VBattleBulletSprite.checkOutSide, self.image}}});
	else
		if self.endPosY then
			local distanceY = self.endPosY - self.image:getPositionY();
			self.image:RunAction({"spawn", {"moveBy", actionTime*2.5, 0, distanceY}, {"repeat", -1, {"sequence", {"spawn", {"moveBy", actionTime, moveSpeed, 0}, {"rotateBy", actionTime, angle}}, {VBattleBulletSprite.checkOutSide, self.image}}}});
		else
			self.image:RunAction({"repeatForever", {"sequence", {"spawn", {"moveBy", actionTime, moveSpeed, 0}, {"rotateBy", actionTime, angle}}, {VBattleBulletSprite.checkOutSide, self.image}}});
		end
	end
end

---------------------------------------  西瓜土豆子弹抛投动画  ---------------------------------------
function VBattleBulletSprite:doThorwMove( targetSprite, target, hightPoint )
	-- 抛物线垂直速度计算
	local moveTime = 0.1;

	self.allTime = self.speed - (3 * gBattleView.battleInfo.inerval / gBattleView.msec_unit);
	self.flytime = self.allTime;
	if self.halfTimePre then
		self.halfTime = self.allTime * self.halfTimePre;
	else
		self.halfTime = self.allTime * 0.5;
	end
	self.speedY = 2 * hightPoint / self.halfTime;
	self.accY = self.speedY / self.halfTime;
	
	-- 抛物线水平位移计算
	self.distanceX = target:GetPos() * gBattleView.cellMinPixW  - self.image:getPositionX();
	if targetSprite then
		if gSimpleVersion then
			self.distanceX = self.distanceX - targetSprite.armature:getContentSize().width * targetSprite.armature:getAnchorPoint().x * targetSprite.armature.scale * 0.8;
		else
			if targetSprite.armature:getAnimation():getCurrentMovementID() == "walk" then
				self.distanceX = self.distanceX - targetSprite.armature:getContentSize().width * targetSprite.armature:getAnchorPoint().x * targetSprite.armature.scale;
			end
		end
	else
		if target:GetAction( ) == ECreatureAction.ACTION_MOVE then
			self.distanceX = self.distanceX - self.image:getContentSize().width * self.image:getAnchorPoint().x * self.image.scale;
		end
	end

	if not self.isAttack then
		self.distanceX = math.abs(self.distanceX);
	end

	-- 动画位移&旋转计算
	local moveX = self.distanceX / self.allTime * moveTime;
	local moveY = self.speedY * moveTime - 0.5 * self.accY * math.pow(moveTime, 2);
	
	local rotation = 0;
	if self.randomRotation then
		self.isArrow = true;
		rotation = self.randomRotation * moveTime;
	else
		self.randomRotation = math.random(100, 400);
		rotation = moveTime / 1.0 * self.randomRotation;
	end

	-- cclog("*** name = "..self.bulletName..", self.allTime = "..self.allTime..", self.halfTime = "..self.halfTime..", self.speedY = "..self.speedY..", self.accY = "..self.accY);
	-- cclog("*** id ="..self.id..", distanceX = "..self.distanceX..", moveX = "..moveX..", moveY = "..moveY);

	self.image:RunAction({"sequence", {"spawn",{"moveBy", moveTime, moveX, moveY}, {"rotateBy", moveTime, rotation}}, {function(node) VBattleBulletSprite.throwing(node, self) end}});
end

function VBattleBulletSprite.throwing( image, bulletSprite )
	local moveTime = 0.1;
	bulletSprite.flytime = bulletSprite.flytime - moveTime;

	local isLowest = false;
	local currentY = bulletSprite.image:getPositionY();
	if bulletSprite.flytime <= bulletSprite.halfTime and bulletSprite.lowestY then
		if currentY <= bulletSprite.lowestY then
			bulletSprite.image:setPosition(bulletSprite.image:getPositionX(), bulletSprite.lowestY);
			isLowest = true;
		end
	end

	if bulletSprite.flytime <= 0 or isLowest then
		-- cclog("***** id ="..bulletSprite.id..", bulletSprite.flytime = "..bulletSprite.flytime..",  bulletSprite die");
		bulletSprite:die();	
	else
		bulletSprite.speedY = bulletSprite.speedY - bulletSprite.accY * moveTime;

		-- 动画位移&旋转计算
		local moveX = bulletSprite.distanceX / bulletSprite.allTime * moveTime;
		local moveY = bulletSprite.speedY * moveTime - 0.5 * bulletSprite.accY * math.pow(moveTime, 2);
		if moveY < 0 and bulletSprite.incrementY then
			moveY = moveY + bulletSprite.incrementY;
		end

		local rotation = 0;
		if bulletSprite.isArrow then
			rotation = bulletSprite.randomRotation * moveTime;
		else
			rotation = moveTime / 1.0 * bulletSprite.randomRotation;
		end
		-- cclog("***** id ="..bulletSprite.id..", bulletSprite.flytime = "..bulletSprite.flytime..", moveX = "..moveX..", moveY = "..moveY);

		bulletSprite.image:RunAction({"sequence", {"spawn",{"moveBy", moveTime, moveX, moveY}, {"rotateBy", moveTime, rotation}}, {function(node) VBattleBulletSprite.throwing(node, bulletSprite) end}});
	end
end

---------------------------------------  子弹回旋镖动画  ---------------------------------------
function VBattleBulletSprite:doBoomerangRotationMove( )
	self.startX = self.image:getPositionX();
	-- self.distance = self.distance * 0.9;
	self.image:RunAction({"repeatForever", {"spawn", {"moveBy",1, self.distance, 0}}});
end

-- 回旋镖碰撞后减速动画
function VBattleBulletSprite:doRotationImpactAnimation( battleBullet )
	local currentX = self.image:getPositionX();
	local size = self.image:getContentSize();
	local limitPos = gBattleView.battleLayer:convertToWorldSpace(cc.p(9 * gBattleView.cellNum * gBattleView.cellMinPixW - size.width, 0));
	-- cclog("*** actionTime = %f,  endX = %f, x = %f, limitPos.x = %f", actionTime, endX, x, limitPos.x);

	local endX = 0;
	if (currentX + 2 * gBattleView.cellNum * gBattleView.cellMinPixW) > limitPos.x then
		endX = limitPos.x;
	else
		endX = currentX + 2 * gBattleView.cellNum * gBattleView.cellMinPixW;
	end
	
	local actionTime = (endX - currentX) / self.distance;
	if actionTime < 0 then
		actionTime = 0.1;
	end
	local rotation = actionTime / 1.0 * 1080;
	local stayTime = 0.2;--(1 - actionTime) * 2;
	-- local stayRotation = stayTime / 1.0 * 1080;

	-- cclog("*** actionTime = %f,  endX = %f", actionTime, endX);
	self.image:RunAction({"sequence", {"spawn", {"easeOut", 1.5, {"moveTo", actionTime, endX, self.pos.y}}}, {VBattleBulletSprite.finishRotationImpactAnimation, self.image, self.distance, self.startX}});
	-- self.image:RunAction({"sequence", {"spawn", {"moveBy", actionTime, endX, 0}, {"rotateBy", actionTime, rotation}}, {"rotateBy", stayTime, stayRotation}, {"spawn", {"moveTo", actionTime, x, self.pos.y}, {"rotateBy", actionTime, rotation}}, {VBattleBulletSprite.finishRotationImpactAnimation, self.image, self.distance}});
end

function VBattleBulletSprite.finishRotationImpactAnimation( node, distance, startX )
	local moveX = math.abs(node:getPositionX() - startX);
	local runTime = moveX / distance;
	-- node:RunAction({"repeatForever", {"spawn", {"moveBy",0.2, -distance*0.2, 0}, {"rotateBy", 0.2, 1080*0.2}}, {VBattleBulletSprite.checkOutSide, node, startX}});
	node:RunAction({"sequence", {"spawn", {"moveBy", runTime, -moveX, 0}}, {VBattleBulletSprite.boomerangBulletOutSide, node}});
end

function VBattleBulletSprite.boomerangBulletOutSide( image, startX )
	gBattleView:removeBulletSprite(image.data.id);
end


---------------------------------------  闪电子弹动画  ---------------------------------------
function VBattleBulletSprite:doLightningMove( targetSprite, target )
	if targetSprite then
		local diffX = self.image:getPositionX() - targetSprite.armature:getPositionX() + 30;
		local tempImage = VImage{image=self.imageName};
		local widthScale = diffX / tempImage:getContentSize().width;
		local angle = 15;
		if self.angle then
			angle = self.angle;
		end
		tempImage:Delete();
		
		if not self.hitImage then
			local hitX = targetSprite.armature:getPositionX();
			local hitY = self.image:getPositionY() - diffX * math.sin(math.rad(angle));
			local hitImageName = self.bulletName.."Hit1.png";
			self.hitImage = gBattleView.battleLayer:Push(VImage{image=hitImageName, scale=0, level=self.imageLevel});
			self.hitImage:setAnchorPoint(cc.p(0.5,0.5));
			self.hitImage:setPosition(hitX, hitY);
		end

		self.imageIndex = 1;
		self.image:RunAction{{"scaleTo",0,0,self.imageScale}, {"rotateTo", 0, (360 - angle) }, {"scaleTo", 0.1, widthScale, self.imageScale}, {function(node) VBattleBulletSprite.changeLightning(node, self) end}};
		self.hitImage:RunAction{{"delayTime", 0.1}, {"scaleTo", 0.1, self.imageScale*0.9, self.imageScale*0.9}};
	else
		gBattleView:removeBulletSprite(self.id);
	end
end

function VBattleBulletSprite.changeLightning( image, bulletSprite )
	bulletSprite.imageIndex = bulletSprite.imageIndex + 1;
	if bulletSprite.imageIndex > 3 then
		bulletSprite.imageIndex = 1;
	end

	local bulletName = bulletSprite.bulletName..bulletSprite.imageIndex..".png";
	local hitImageName = bulletSprite.bulletName.."Hit"..bulletSprite.imageIndex..".png";

	bulletSprite.image:setTexture(bulletName);
	bulletSprite.hitImage:setTexture(hitImageName);
	bulletSprite.image:RunAction{{"delayTime", 0.02}, {function(node) VBattleBulletSprite.changeLightning(node, bulletSprite) end}};
end

-- 子弹默认销毁动画
function VBattleBulletSprite:doDel( )
	if self.image then
		self.image:stopAllActions();
		self.image:Delete();
		self.image = nil;
	end
end

-----------------------

-- 子弹超出屏幕移除
function VBattleBulletSprite.checkOutSide( image )
	local windowSize = gWindow:getContentSize();

	if image:getPositionX() < 0 or image:getPositionY() < 0 or image:getPositionX() > windowSize.width or image:getPositionY() > windowSize.height then
		gBattleView:removeBulletSprite(image.data.id, nil, true);
	end
end