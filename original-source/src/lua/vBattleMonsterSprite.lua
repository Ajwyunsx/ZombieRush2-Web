--vBattleMonsterSprite.lua

VBattleMonsterSprite = vclass("BattleMonsterSprite")

local local_bit = gBit;

function VBattleMonsterSprite:initialize( battleCreature )
	self.id = battleCreature:GetId();
	self.mId = battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ID);
	self.pos = battleCreature:GetPos();
	self.road = battleCreature:GetRoad();
	self.imageName = battleCreature.m_image;
	self.moveType = battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE);
	self.animationType = ECreatureAnimationType.ANIMATION_NULL;
	self.isReadyEnter = battleCreature.isReadyEnter;

	self.creatureType = battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE);
	self.attackType = battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_TYPE);
	self.speed = battleCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED);
	self.attackRange = battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE);
	self.armatureScale = battleCreature.m_scale * 0.01;
	if gBattleView.battleInfo.attackType ~= BattleType.BattleTypeEvp then
		if gBattleView.scaleTest then
			if gBattleView.useTestScale then
				self.armatureScale = gBattleView.scaleTestValue * 0.01;
			end
			gBattleView:showBattleTestScale(battleCreature.m_scale, gBattleView.scaleTestValue);
		end
	end
	self.moveSpeedScale = battleCreature.m_speedScale;
	self.playMoveSpeed = 1 / (self.moveSpeedScale / self.speed);

	self.monsterBulletId = {};
	self.halfLife = false;
	self.isAttacking = false;
	self.valid = true;
	self.isStop = false;					-- 被定身 停止
	self.isChangeSpeed = true;		-- 速度发生变化

	if battleCreature.parentId then
		self.parentId = battleCreature.parentId;
	end

	self:createSprite();
end

function VBattleMonsterSprite:isValid( )
	return self.valid;
end

function VBattleMonsterSprite:createSprite( )
	self.armature = VArmature:createArmature(self.imageName, "", "DownLeft");
	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.MONSTER_LEVEL - self.road);
	self.armature.scale = self.armatureScale;--gBattleView.spriteScale;
	if self.isHide then
		self.armature.visible = 0;
	end
	gBattleView.battleLayer:Push(self.armature);
	self.armature:ReLayout();

	self.armatureAnchorPoint = self.armature:getAnchorPoint();
	self.armature.r = self.armature:getColor().r;
	self.armature.g = self.armature:getColor().g;
	self.armature.b = self.armature:getColor().b;
	
	local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
		self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
	end 
	self.armature:setEventCallFunc(callBack);

	self:initMonsterSprite();
end

function VBattleMonsterSprite:initMonsterSprite( )
	local posx = 0;
	local posy = 0;
	if self.isReadyEnter then
		posx = gBattleView("battleLayer"):getContentSize().width + self.armature:getContentSize().width*self.armature:getAnchorPoint().x * 0.2;
		posy = gBattleView("carLayer"..self.road):getPositionY();
	else
		posx = self.pos * gBattleView.cellMinPixW;
		posy = (self.road - 1) * gBattleView.cellPixH;
	end
	self.armature:setPosition(posx, posy);
	self:setHpImage();
end

function VBattleMonsterSprite:setHpImage( )
	local level = 100;
	self.lifeImage = self.armature:Push(VImage{image="hpSlot.png", level=level, visible=0});
	self.lifeImage:setAnchorPoint(cc.p(0.5,1));
	self.hpImage = VImage{image="hpSlotGreen.png", layout="Left"};
	self.hpImage:setAnchorPoint(cc.p(0,0.5));
	self.lifeImage:Push(self.hpImage);
	self.lifeImage:ReLayout();
	
	self:setHpPosition();
end

function VBattleMonsterSprite:setHpPosition( )
	local bonePos = self.armature:getBonePos("head");
	local boneSize = self.armature:getBoneSize("head");
	local pos = self.armature:convertToNodeSpace(cc.p(bonePos.x + boneSize.width * 0.5 * self.armatureScale, bonePos.y + boneSize.height * self.armatureScale + 6));
	self.lifeImage:setPosition(pos.x, pos.y);
end

function VBattleMonsterSprite:delHpImage( )
	if self.hpImage then
		self.hpImage:stopAllActions();
		self.hpImage:Delete();
		self.hpImage = nil;		
	end
	if self.lifeImage then
		self.lifeImage:stopAllActions();
		self.lifeImage:Delete();
		self.lifeImage = nil;		
	end
end

function VBattleMonsterSprite:setMonsterBullet( bulletId )
	table.insert(self.monsterBulletId, bulletId);
end

function VBattleMonsterSprite:getShootPos( )
	return cc.p(self.armature:getPositionX(), self.armature:getPositionY());
end

function VBattleMonsterSprite:changeSpeedScale( speedScale, battleCreature )
	self.isChangeSpeed = true;
	self:continueAnimation(battleCreature);
end

function VBattleMonsterSprite:continueAnimation( battleCreature )
	-- 没有被定身
	if not self.isStop then
		if battleCreature:GetAction() == ECreatureAction.ACTION_MOVE then
			self:walk(battleCreature, self.targetPlant);
			self.isChangeSpeed = false;
		end
	end
end

function VBattleMonsterSprite:stopAllAnimation( )
	if self.armature and self.valid then
		self.armature:stopAllActions();
		self.armature:stop();
	end
end

-- 站
function VBattleMonsterSprite:stay( )
	self.isAttacking = false;
	self.armature:stopAllActions();
	self:stayAnimation();
end

function VBattleMonsterSprite:stayAnimation( )
	self.animationType = ECreatureAnimationType.ANIMATION_IDLE;
	self:playStayAnimation();
end

function VBattleMonsterSprite:playStayAnimation( )
	self.armature:play("idle");
end

-- 进场
function VBattleMonsterSprite:doEnter( )
	self:stay();

	-- local posx1 = gBattleView("carLayer"..self.road):getPositionX();
	-- local posy1 = gBattleView("carLayer"..self.road):getPositionY();
	local posx2 = 9 * gBattleView.cellNum * gBattleView.cellMinPixW;
	local posy2 = (self.road - 1) * gBattleView.cellPixH;

	local actionTime = 1.2;
	-- local starPosx = self.armature:getPositionX();
	-- local len1 = starPosx - posx1;
	-- local len2 = starPosx - posx2;
	-- local time1 = actionTime * (len1/len2);
	-- local time2 = actionTime - time1;

	-- self.armature:RunAction{{"moveTo", time1, posx1, posy1}, {"moveTo", time2, posx2, posy2}};
	self.armature:RunAction{{"moveTo", actionTime, posx2, posy2}};

	gBattleView("carArmature"..self.road).isOpen = true;
	gBattleView("carArmature"..self.road):play("open");
	gBattleView("touchLayer"..self.road):RunAction{{"delayTime", actionTime}, {function(node) VBattleMonsterSprite.finishEnter(node, self) end}};
end

function VBattleMonsterSprite.finishEnter( node, monster )
	if monster.isReadyEnter then
		monster.isReadyEnter = false;
	end

	if gBattleView then
		if gBattleView.battleInfo.attackType == BattleType.BattleTypeEvp then
			gBattleView("carArmature"..monster.road):play("back2", nil, 0);
		else
			gBattleView("carArmature"..monster.road):play("back", nil, 0);
		end
	end
end

-- 走路
function VBattleMonsterSprite:walk( battleCreature, plant )
	if self.isStop then
		return;
	end
	
	if battleCreature:GetAction() ~= ECreatureAction.ACTION_MOVE or battleCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) ~= 0 then
		return;
	end
	
	self.attackTarget = nil;

	if self.isReadyEnter then
		posx = 90 * gBattleView.cellMinPixW;
		posy = (self.road - 1) * gBattleView.cellPixH;
		self.armature:setPosition(posx, posy);
		self.isReadyEnter = false;
	end

	if self.isAttacking then
		self.delayRun = true;
		self.delayMonster = battleCreature;
		self.delayPlant = plant;
		return;
	end

	self:cleanChildSprite();

	self:walkAnimation();

	self:runWalkAction(battleCreature, plant);
end

function VBattleMonsterSprite:walkAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_MOVE then
		self.animationType = ECreatureAnimationType.ANIMATION_MOVE;
		self.armature:play("walk");
	end
end

function VBattleMonsterSprite:runWalkAction( battleCreature, plant )
	if self.isBlackHoleAnimation then
		return;
	end

	local isRunEnd = false;
	local actionTime = 0;
	local monsterSpeed = battleCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED) * gBattleView.battleInfo.inerval;
	self.playMoveSpeed = 1 / (self.moveSpeedScale / monsterSpeed);
	self.armature:setSpeedScale(self.playMoveSpeed);

	if plant then
		self.targetPlant = plant;
		local plantPos = plant:getPosX();
		local monsterPos = battleCreature:GetPos();
		local distance = (monsterPos - plant.pos - self.attackRange) * gBattleView.msec_unit;
		if distance < 0 then
			distance = 0;
		end
		plantPos = plantPos + battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ATTACK_RANGE) * gBattleView.cellMinPixW + self.armature:getContentSize().width * self.armatureScale * self.armature:getAnchorPoint().y;

		if (distance) > 0 then
			actionTime = ((distance / monsterSpeed) + 1) * (gBattleView.battleInfo.inerval / gBattleView.msec_unit);
			self.walkRate = actionTime / math.abs(self.armature:getPositionX() - plantPos);
			self.armature:RunAction{{"moveTo", actionTime, plantPos, self.armature:getPositionY()}, {function(node) VBattleMonsterSprite.arriveTargetPlant(node, self, battleCreature) end}};
			-- cclog("**** actionTime = %f , plantPos = %f, self.armature:getPositionY() = %f, self posX = %f", actionTime, plantPos, self.armature:getPositionY(), self.armature:getPositionX());
		else
			isRunEnd = true;
		end
	else
		isRunEnd = true;
	end

	if isRunEnd then
		local distance = battleCreature:GetPos() * gBattleView.msec_unit;
		local endPos = self.armature:getContentSize().width * self.armatureScale * self.armature:getAnchorPoint().y;
		actionTime = (distance / monsterSpeed) * (gBattleView.battleInfo.inerval / gBattleView.msec_unit);
		self.walkRate = actionTime / math.abs(self.armature:getPositionX() - endPos);
		self.armature:RunAction{{"moveTo", actionTime, endPos, self.armature:getPositionY()}, {function(node) VBattleMonsterSprite.finishWalkAction(node, self) end}};
	end
end

function VBattleMonsterSprite.arriveTargetPlant( node, moster, battleCreature )
	if not moster.targetPlant then
		local pos = -1;
		local plant = nil;
		for k,v in pairs(gBattleView.PlantList) do
			if v.road == moster.road and local_bit:_and(moster.attackType, v.moveType) ~= 0 and v.pos > pos then
				pos = v.pos;
				plant = v;
			end
		end
		moster:walk(battleCreature, plant);
	end
end

function VBattleMonsterSprite.finishWalkAction( node, moster )
	moster:walkEnd();
end

function VBattleMonsterSprite:walkEnd( )
	if self.isStop then
		return;
	end
	
	self.armature:setSpeedScale(self.playMoveSpeed);
	self:walkAnimation();

	local diffX = (self.armature:getPositionX() - gBattleView("endLayer"..self.road):getPositionX());
	if diffX <= 0 then
		diffX = 20;
	end
	
	if self.walkRate <= 0 then
		self.walkRate = 10 / (self.speed * gBattleView.battleInfo.inerval);
	end

	local actionTime = diffX * self.walkRate;
	self.armature:RunAction{{"moveTo", actionTime, gBattleView("endLayer"..self.road):getPositionX(), self.armature:getPositionY()}, {VBattleMonsterSprite.moveEnd, self.armature, self.id}};
end

function VBattleMonsterSprite.moveEnd( node, id )
	if gBattleView then
		local sprite = gBattleView.MonsterList[id];
		sprite.valid = false;
		-- sprite:stay();
		gBattleView:monsterMoveEnd(sprite.road);
		gBattleView:monsterIsValid();
		local diffX = sprite.armature:getPositionX() - 20;
		sprite.armature:RunAction{{"sequence", {"spawn", {"moveTo", 0.5, diffX, sprite.armature:getPositionY()}, {"fadeTo", 0.5, 0}}, {function(node) VBattleMonsterSprite.moveEndDelete(node, sprite) end}}};
	end
end

function VBattleMonsterSprite.moveEndDelete( node, moster )
	moster.armature:Delete();
	moster.armature = nil;
end

-- 受伤闪烁
function VBattleMonsterSprite:doDamageAnimation( battleCreature )
	self:showHpAnimation(battleCreature);

	if gShowBloomAnimation then
		self.armature:Set_bloom(true, 0.2);
	else
		self.armature:setColor(cc.c3b(255,220,220));
	end
	self.armature.callBackDelegate = self;
	self.armature.callBackFunc = "resetSelfColor";
	self.armature:StartTimer("armatureCallBackFunc", 0.1);
end

function VBattleMonsterSprite:resetSelfColor( )
	self.armature:StopTimer("armatureCallBackFunc");
	if gShowBloomAnimation then
		self.armature:Set_bloom(false);
	else
		self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
	end
end

-- 扣血动画
function VBattleMonsterSprite:showHpAnimation( battleCreature )
	if self.lifeImage and self.hpImage then
		self.lifeImage:RunAction{{"show"}, {"delayTime", 2}, {"hide"}};
		local hpPer = battleCreature:GetHp() / battleCreature:GetRawHp();
		self.hpImage:RunAction({"scaleTo", 0, hpPer, 1});
	end
end

-- 重伤
function VBattleMonsterSprite:halfLifeAnimation( )
	if not self.halfLife then
		self.halfLife = true;

		local boneList = {"leftHand", "leftForearm"};
		self:setStumpAnimation(boneList);
	end
end

function VBattleMonsterSprite:setStumpAnimation( boneList )
	if not gShowStumpAnimation then
		return;
	end
	if not self.armature then
		return;
	end

	local isLeftHand = false;
	local isHead = false;
	local armatureSize = self.armature:getContentSize();
	local armatureAnchorPoint = self.armature:getAnchorPoint();
	local boneLayer = gBattleView.battleLayer:Push(VLayer{size={armatureSize.width, armatureSize.height}, scale=self.armatureScale, level = self.armature.level});
	boneLayer:setAnchorPoint(cc.p(armatureAnchorPoint.x, armatureAnchorPoint.y));
	boneLayer:setPosition(self.armature:getPositionX(), self.armature:getPositionY());

	for i=1,#boneList do
		local name = boneList[i];
		local bone = self.armature:getBone(name);

		if bone then
			local renderNode = bone:getDisplayRenderNode();
			if renderNode then
				local imageName = bone:getBoneCurrentImageName();

				local boneImage = boneLayer:Push(VImage{image=imageName});
				local boneAnchorPoint = self.armature:getBoneAnchorPoint(name);
				boneImage:setAnchorPoint(cc.p(boneAnchorPoint.x, boneAnchorPoint.y));

				if gGetArmatureBoneScale then
					local scaleX = bone:getBoneScaleX();
					if scaleX then
						boneImage:setScaleX(scaleX);
					end
					local scaleY = bone:getBoneScaleY();
					if scaleY then
						boneImage:setScaleY(scaleY);
					end
				end

				local skewX = bone:getBoneSkewX();
				local skewY = bone:getBoneSkewY();
				boneImage:setRotationSkewX(skewX * (math.pi * 0.1 * 180));
				boneImage:setRotationSkewY(-skewY * (math.pi * 0.1 * 180));

				local posX = bone:getBonePositionX() + armatureSize.width * armatureAnchorPoint.x;
				local posY = bone:getBonePositionY() + armatureSize.height * armatureAnchorPoint.y;
				boneImage:setPosition(posX, posY);
				if name == "leftHand" then
					isLeftHand = true;
					boneLayer.moveDown = posY * self.armatureScale;
				elseif name == "head" then
					isHead = true;
					boneLayer.moveDown = (posY - boneImage:getContentSize().height/2) * self.armatureScale;
				end
			end
		end
	end

	for i=1,#boneList do
		local name = boneList[i];
		local bone = self.armature:getBone(name);
		if bone then
			self.armature:changeDisplay(name, nil, -1);
		end
	end

	if isLeftHand then
		local downTime = 0.6;
		boneLayer:Travel(function( node )
			node:RunAction{{"delayTime", 1.6 + downTime}, {"fadeTo", 0.1, 0}};
		end, true);
		boneLayer:RunAction{
			{"easeOut", 3, {"moveBy", 0.4, 0, 10}}, 
			{"easeIn", 2, {"moveBy", downTime, 0, -boneLayer.moveDown-10}}, 
			{"moveBy", 0.2, 0, 5},
			{"delayTime", 2.5}, 
			{"fadeTo", 0.5, 0}
		};
	elseif isHead then
		local downTime = 0.6;
		local moveRange = 0;
		if math.random(0,1)==0 then
			moveRange = math.random(-70,-30);
		else
			moveRange = math.random(30,70);
		end
		boneLayer:Travel(function( node )
			node:RunAction{{"delayTime", 1.6 + downTime}, {"fadeTo", 0.1, 0}};
		end, true);
		boneLayer:RunAction{
			{"spawn",
				{"sequence",
					{"easeOut", 3, {"moveBy", 0.4, 0, 10}}, 
					{"easeIn", 2, {"moveBy", downTime, 0, -boneLayer.moveDown-10}}, 
					{"easeIn", 1/3, {"moveBy", 0.2, 0, 10}}, 
					{"easeIn", 3, {"moveBy", 0.2, 0, -10}}, 
					{"easeIn", 1/3, {"moveBy", 0.1, 0, 5}}, 
					{"easeIn", 3, {"moveBy", 0.1, 0, -5}}, 
				},
				{"moveBy", downTime+1.0, moveRange, 0},
			},
			{"delayTime", 1.7}, 
			{"fadeTo", 0.5, 0}
		};
	else
		boneLayer:Delete()
	end
end

-- 攻击
function VBattleMonsterSprite:attack( target )
	if self.isStop then
		return;
	end
	self.armature:stopAllActions();
	self.armature:setSpeedScale(1);
	self:cleanChildSprite();
	if target then
		self.attackTarget = target;
	else
		self.attackTarget = self.targetPlant;
	end
	self:attackAnimation();
end

function VBattleMonsterSprite:attackAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_ATTACK then
		self.animationType = ECreatureAnimationType.ANIMATION_ATTACK;
		self.isAttacking = true;
		self.armature:play("attack");
	end
end

function VBattleMonsterSprite:finishAttackAnimation( )
	if self.delayRun then
		self.isAttacking = false;
		self.delayRun = false;
		self:walk(self.delayMonster, self.delayPlant);
		self.delayMonster = nil;
		self.delayPlant = nil;
	else
		if not self.attackTarget or not self.attackTarget["GetId"] or not self.attackTarget:GetId() or not gBattleView.PlantList[self.attackTarget:GetId()] then
			self.isAttacking = false;
			self:playStayAnimation();
			self.animationType = ECreatureAnimationType.ANIMATION_IDLE;
		end
	end
end

function VBattleMonsterSprite:cleanChildSprite( )
	if self["delEvilAnimation"] then
		self:delEvilAnimation();
	end
	if self["cleanMagicLight"] then
		self:cleanMagicLight();
	end
end

-- 秒杀 飞出屏幕外
function VBattleMonsterSprite:flyAway( )
	if self.valid then
		self.valid = false;
		self.armature:StopAction();
		
		if self.butterImage then
			self.butterImage:Delete();
			self.butterImage = nil;
		end
		self:delHpImage();
		self:flyAwayAnimation();
	end
end

function VBattleMonsterSprite:flyAwayAnimation( )
	local windowSize = gWindow:getContentSize();

	local posx = windowSize.width + 100 - self.armature:getPositionX();
	local posy = posx * math.atan(20);
	self.armature:RunAction{{"rotateBy", 0, 60}, {"moveBy", 1, posx, posy}, {VBattleMonsterSprite.finishDieAnimation, self.armature}};
end

-- 死亡
function VBattleMonsterSprite:die( )
	if self.valid then
		self.valid = false;
		self.armature:StopAction();
		self:removeAllBuffAnimation();

		if self.butterImage then
			self.butterImage:Delete();
			self.butterImage = nil;
		end

		if self.animationType ~= ECreatureAnimationType.ANIMATION_DIE then
			self.animationType = ECreatureAnimationType.ANIMATION_DIE;
			self:delHpImage();

			self:dieAndStumpAnimation();
			self:dieAnimation();
		end
	end
end

function VBattleMonsterSprite:dieAnimation( )
	self.armature:setSpeedScale(1);
	self:cleanChildSprite();
	self.armature:stop();
	self.armature:play("dead", 0.1, 0);
end

function VBattleMonsterSprite:dieAndStumpAnimation( )
	local boneList = {"head", "jaw"};
	self:setStumpAnimation(boneList);
end

function VBattleMonsterSprite.finishDieAnimation( node )
	node:StopAction();
	node:stopAllActions();
	node:Delete();
	node = nil;

	if gBattleView then
		gBattleView:monsterIsValid();
	end
end

function VBattleMonsterSprite:deleteSprite( )
	if self.armature then
		self.armature:Delete();
		self.armature = nil;
	end
end

function VBattleMonsterSprite:finishShootAnimation( )
	self.isAttacking = false;
	if self.delayRun then
		self.delayRun = false;
		self:walk(self.delayMonster, self.delayPlant);
		self.delayMonster = nil;
		self.delayPlant = nil;
	else
		self:playStayAnimation();
		self.animationType = ECreatureAnimationType.ANIMATION_IDLE;
	end
end

-- 爆炸震动屏幕
function VBattleMonsterSprite:boomShakeView( )
	local posX = gBattleView:getPositionX();
	local posY = gBattleView:getPositionY();
	gBattleView:RunAction{{"moveTo", 0.08, posX+7, posY+7}, {"moveTo", 0.08, posX, posY}};
end

-- 释放技能
function VBattleMonsterSprite:doSkill( battleCreature )
	self.armature:stopAllActions();
	self.armature:setSpeedScale(1);
	self.animationType = ECreatureAnimationType.ANIMATION_SKILL;
end

-- 添加Buff
function VBattleMonsterSprite:addBuff( battleCreature, buffId )
	local pProp = gBattleResource:GetBuffProp(buffId);
	if not pProp then return; end
	self:setBuffSpeedAnimation(battleCreature,pProp);

	for i,v in ipairs(pProp.m_buffAnimation) do
		local buffAnimationId = gBattleMonsterSpriteMgr:GetBuff(v);
		if buffAnimationId and self["add"..buffAnimationId] then
			self["add"..buffAnimationId](self, battleCreature, buffId);
		end
	end
end

-- 清除Buff
function VBattleMonsterSprite:delBuff( battleCreature, buffId )
	local pProp = gBattleResource:GetBuffProp(buffId);
	if not pProp then return; end
	self:setBuffSpeedAnimation(battleCreature,pProp);
	
	for i,v in ipairs(pProp.m_buffAnimation) do
		local buffAnimationId = gBattleMonsterSpriteMgr:GetBuff(v);
		if buffAnimationId and self["del"..buffAnimationId] then
			-- self:setBuffSpeedAnimation(battleCreature,pProp);
			self["del"..buffAnimationId](self, battleCreature);
		end
	end
end

function VBattleMonsterSprite:removeAllBuffAnimation( )
	self:removeDizzinessAnimation();
	self:removeBlackHoleAnimation();
	self:removeShamanBuffAnimation();
end

-- buff影响移动速度动画
function VBattleMonsterSprite:setBuffSpeedAnimation( battleCreature, pProp )
	local speed = 0;
	for i,v in ipairs(pProp.m_effects) do
		if v.expressionId == EBattleEffect.EFFECT_MODIFY_ATTR and
			v.params[1] == ECreatureAttr.CREATURE_ATTR_MOVE_SPEED then
			speed = v.params[3];
		end
	end

	if speed ~= 0 then
		self:changeSpeedScale(speed, battleCreature);
	end
end

-- 帧事件回调
function VBattleMonsterSprite:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	if evt == "finishDie" then
		self.armature:RunAction{{"delayTime", 0.7}, {"fadeTo", 0.5, 0}, {VBattleMonsterSprite.finishDieAnimation, self.armature}};
	elseif evt == "finishShoot" then
		self:finishShootAnimation();
	elseif evt == "stopLightning" then
		self:cleanChildSprite();
	elseif evt == "finishSummon" then
		if self["danceAnimation"] then
			self:danceAnimation();
		end	
	elseif evt == "attackSound" then
		self:attackSound();
	elseif evt == "dieSound" then
		self:dieSound();
	elseif evt == "boomSound" then
		self:boomSound();
	elseif evt == "showEvilBuff" then
		if self["showEvilBuffAnimation"] then
			self:showEvilBuffAnimation()
		end
	elseif evt == "finishEvil" then
		self:cleanChildSprite();
	elseif evt == "turnLeft" then
		self.isRight = false;
	elseif evt == "turnRight" then
		self.isRight = true;
	elseif evt == "boomShake" then
		self:boomShakeView();
	elseif evt == "finishWalk" then
		if self["finishWalkAnimation"] then
			self:finishWalkAnimation();
		end
	elseif evt == "finishAttack" then
		if self["finishAttackAnimation"] then
			self:finishAttackAnimation();
		end
	elseif evt == "showThunderbolt" then
		if self["showThunderboltAnimation"] then
			self:showThunderboltAnimation();
		end
	elseif evt == "showArrow" then
		if self["showArrowAnimation"] then
			self:showArrowAnimation();
		end
	elseif evt == "rebirthOver" then
		if self["rebirthOver"] then
			self:rebirthOver();
		end
	elseif evt == "finishJump" then
		if self["finishJump"] then
			self:finishJump();
		end		
	end
end

function VBattleMonsterSprite:getDropPos( )
	local bone = self.armature:getBone("body");
	if bone then
		return self.armature:getBonePos("body");
	else
		return cc.p(self.armature:getPositionX(), self.armature:getPositionY() + self.armature:getContentSize().height * 0.5);
	end
end
---------------------------------------  音效处理  ---------------------------------------

function VBattleMonsterSprite:walkSound( )
	
end

function VBattleMonsterSprite:attackSound( )
	gBattleView:playSound("battle_zombie_attack_plant_", 3);
end

function VBattleMonsterSprite:dieSound( )
	gBattleView:playSound("battle_zombie_die_", 2);
end

function VBattleMonsterSprite:boomSound( )
	gBattleView:playSound("battle_BoomZombie_Boom");
end

---------------------------------------  BattleMonsterSpriteMgr  ---------------------------------------

VBattleMonsterSpriteMgr = vclass("BattleMonsterSpriteMgr");

function VBattleMonsterSpriteMgr:initialize( )
	self.m_buffAnimations = {};

	self.m_buffAnimations[EBuffAnimationType.BUFF_SLOW_DOWN] = "SlowDownBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_BUTTER_DOWN] = "ButterStopDownBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_EVIL] = "EvilBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_HELLBOY] = "HellBoyBuff";	
	self.m_buffAnimations[EBuffAnimationType.BUFF_TAISUI_UP] = "TaiSuiUpBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_BEAT_BACK] = "BeatBackBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_MODIFY_HP_MAX] = "ModifyHpMaxBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_DIZZINESS] = "DizzinessBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_RUSH] = "RushBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_USEFUL] = "UsefulBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_USELESS] = "UselessBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_BLACK_HOLE] = "BlackHoleBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_OTHER_SHORE] = "OtherShoreBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_BLOODY] = "BloodyBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_REBIRTH] = "RebirthBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_SHAMAN] = "ShamanBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_POISON] = "PoisonBuff";
	self.m_buffAnimations[EBuffAnimationType.BUFF_STAY_DAZE] = "StayDazeBuff";

end

function VBattleMonsterSpriteMgr:GetBuff( id )
	return self.m_buffAnimations[id];
end

---------------------------------------  减速动画  ---------------------------------------
function VBattleMonsterSprite:addSlowDownBuff( battleCreature, buffId )
	self.armature.r = 170;
	self.armature.g = 170;
	self.armature.b = 255;
	self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
end

function VBattleMonsterSprite:delSlowDownBuff( battleCreature, buffId )
	self.armature.r = 255;
	self.armature.g = 255;
	self.armature.b = 255;
	self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
end

---------------------------------------  黄油定身动画  ---------------------------------------
function VBattleMonsterSprite:addButterStopDownBuff( battleCreature, buffId )
	self.armature:pause();
	self.isStop = true;
	gDtr:getActionManager():pauseTarget(self.armature);
	-- self.tempBattleCreatureData = battleCreature;

	if self.armature and self.armature:getBone("head") then
		local level = (gBattleView.maxLevel - self.road) * EAnimationSpriteLevel.MONSTER_LEVEL;
		self.butterImage = self.armature:Push(VImage{image="halfButterBullet.png", level=level});

		local bonePos = self.armature:getBonePos("head");
		local butterSize = self.butterImage:getContentSize();
		local anchorPoint = self.butterImage:getAnchorPoint();
		local pos = nil;
		if self.isRight then
			pos = self.armature:convertToNodeSpace(cc.p(bonePos.x - butterSize.width * anchorPoint.x * self.armatureScale, bonePos.y + butterSize.height * anchorPoint.y));
		else
			pos = self.armature:convertToNodeSpace(cc.p(bonePos.x + butterSize.width * anchorPoint.x * self.armatureScale, bonePos.y + butterSize.height * anchorPoint.y));
		end
		self.butterImage:setPosition(pos.x, pos.y);
	end
end

function VBattleMonsterSprite:delButterStopDownBuff( battleCreature, buffId )
	if self.butterImage then
		self.butterImage:Delete();
		self.butterImage = nil;
	end
	self.armature:resume();
	gDtr:getActionManager():resumeTarget(self.armature);
	self.isStop = false;
	-- if self.isChangeSpeed then
		self:continueAnimation(battleCreature);		
	-- end
end

---------------------------------------  恶魔buff动画  ---------------------------------------
function VBattleMonsterSprite:addEvilBuff( battleCreature, buffId )
	if self.armature and self.armature:getBone("head") then
		local level = (gBattleView.maxLevel - self.road) * EAnimationSpriteLevel.MONSTER_LEVEL;
		self.evilImage = self.armature:Push(VImage{image="evilBuffEffect.png", level=level});

		local bonePos = self.armature:getBonePos("head");
		local butterSize = self.evilImage:getContentSize();
		local anchorPoint = self.evilImage:getAnchorPoint();
		local pos = self.armature:convertToNodeSpace(cc.p(bonePos.x + butterSize.width * anchorPoint.x * gBattleView.spriteScale, bonePos.y + butterSize.height * anchorPoint.y));
		self.evilImage:setPosition(pos.x, pos.y + 15);
		self.evilImage:RunAction{{"sequence", {"fadeTo", 0, 0}, {"show"}, {"fadeTo", 0.5, 255}, {function(node) VBattleMonsterSprite.evilBuffAnimation(node, self.evilImage) end}}};
	end
end

function VBattleMonsterSprite:delEvilBuff( battleCreature, buffId )
	if self.evilImage then
		self.evilImage:Delete();
		self.evilImage = nil;
	end
end

function VBattleMonsterSprite.evilBuffAnimation( node, image )
	image:RunAction({"repeatForever", {"sequence", {"fadeTo", 0.3, 120}, {"fadeTo", 0.7, 255}}});
end

---------------------------------------  太岁顶起buff动画  ---------------------------------------
function VBattleMonsterSprite:addTaiSuiUpBuff( battleCreature, buffId )
	self.armature:stopAllActions();

	local posx = battleCreature:GetPos() * gBattleView.cellMinPixW;
	local posy = (self.road - 1) * gBattleView.cellPixH;

	self.armature:RunAction{{"moveBy", 0.1, 0, 30}, {"jumpTo", 0.3, posx, posy, 30}};
end

function VBattleMonsterSprite:delTaiSuiUpBuff( battleCreature, buffId )
	self:walk(battleCreature, self.targetPlant);
end

---------------------------------------  娃娃菜击退buff动画  ---------------------------------------
function VBattleMonsterSprite:addBeatBackBuff( battleCreature, buffId )
	self:stayAnimation();
	self.armature:stopAllActions();

	local actionTime = 0.5;
	local pProp = gBattleResource:GetBuffProp(buffId);
	if pProp then
		for i,effect in ipairs(pProp.m_effects) do
			if effect.expressionId == 2 and effect.params[1] == ECreatureStatus.CREATURE_STATUS_HOLD then
				actionTime = effect.params[1] * 0.6;
			end
		end
	end

	local posx = battleCreature:GetPos() * gBattleView.cellMinPixW;
	local posy = (self.road - 1) * gBattleView.cellPixH;

	self.armature:RunAction{{"jumpTo", actionTime, posx, posy, 20}};
end

function VBattleMonsterSprite:delBeatBackBuff( battleCreature, buffId )
	self:walk(battleCreature, self.targetPlant);
end
---------------------------------------  修改血量上限buff动画  ---------------------------------------
function VBattleMonsterSprite:addModifyHpMaxBuff( battleCreature )
	if self.lifeImage and self.hpImage then
		local hpPer = battleCreature:GetRawHp() / battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
		self.lifeImage:setScaleX(hpPer);
		hpPer = battleCreature:GetHp() / battleCreature:GetRawHp();
		self.hpImage:RunAction({"scaleTo", 0, hpPer, 1});
	end
end

function VBattleMonsterSprite:delModifyHpMaxBuff( battleCreature )
	if self.lifeImage and self.hpImage then
		local hpPer = battleCreature:GetRawHp() / battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_LIFE);
		self.lifeImage:setScaleX(hpPer);
		hpPer = battleCreature:GetHp() / battleCreature:GetRawHp();
		self.hpImage:RunAction({"scaleTo", 0, hpPer, 1});
	end
end

---------------------------------------------  眩晕定身buff动画  -----------------------------------------
function VBattleMonsterSprite:addDizzinessBuff( battleCreature )
	if self.dizziness then
		return;
	end
	self.armature:pause();
	self.isStop = true;
	gDtr:getActionManager():pauseTarget(self.armature);
	self.dizziness = VBattleDizzinessBuffSprite:new(self);
end

function VBattleMonsterSprite:delDizzinessBuff( battleCreature )
	self.armature:resume();
	gDtr:getActionManager():resumeTarget(self.armature);
	self.isStop = false;
	self:continueAnimation(battleCreature);
	self:removeDizzinessAnimation();
end

function VBattleMonsterSprite:removeDizzinessAnimation( )
	if self.dizziness then
		self.dizziness:remove();
		self.dizziness = nil;
	end
end

---------------------------------------------  通用增益buff动画  -----------------------------------------
function VBattleMonsterSprite:addUsefulBuff( battleCreature )
	VBattleUsefulBuffSprite:new(self, false);
end

function VBattleMonsterSprite:delUsefulBuff( battleCreature )
end

---------------------------------------------  通用减益debuff动画  -----------------------------------------
function VBattleMonsterSprite:addUselessBuff( battleCreature )
	VBattleUselessBuffSprite:new(self, true);
end

function VBattleMonsterSprite:delUselessBuff( battleCreature )
end

---------------------------------------------  黑洞吸引动画  -----------------------------------------
function VBattleMonsterSprite:addBlackHoleBuff( battleCreature )
	if self.isBlackHoleAnimation then
		return;
	end
	self.armature:stopAllActions();
	if self.animationType ~= ECreatureAnimationType.ANIMATION_MOVE then
		self.armature:pause();
	end
	self.isStop = true;
	self.isBlackHoleAnimation = true;
	if battleCreature.blackHoleId then
		self.blackHoleId = battleCreature.blackHoleId;
	end
	local endPosX = battleCreature:GetPos() * gBattleView.cellMinPixW;
	local distance = endPosX - self.armature:getPositionX();
	if not self.walkRate then
		self.walkRate = 10 / (battleCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED) * gBattleView.battleInfo.inerval);
	end
	local moveTime = distance * self.walkRate * 0.5;
	if moveTime > 0.6 then
		moveTime = 0.6;
	end
	local actionTime = 1;
	self.armature:RunAction{{"spawn", 
								{"moveBy", moveTime, distance, 0},
								{"sequence", 
									{"delayTime", moveTime},
									{function(node) VBattleMonsterSprite.readyForRotate(node, self) end},
									{"spawn", 
										{"scaleTo", actionTime, 0.2},
										{"rotateBy", actionTime, 360}
									},
									{function(node) VBattleMonsterSprite.removeInBlackHole(node, self) end}
								}
							}};
end

function VBattleMonsterSprite.readyForRotate( node, sprite )
	sprite.inHolePosX = sprite.armature:getPositionX();
	sprite.inHolePosY = sprite.armature:getPositionY();
	sprite.armature:setAnchorPoint(cc.p(sprite.armatureAnchorPoint.x,0.5));

	local getBlackHole = false;
	if sprite.blackHoleId then
		local objSprite = gBattleView.ObjectList[sprite.blackHoleId];
		if objSprite then
			local bulletSprite = gBattleView.BulletList[objSprite.bulletId];
			if bulletSprite then
				if bulletSprite.explodeArmature and bulletSprite.explodeName == "BlackHoleExplode" then
					sprite.armature:setPosition(bulletSprite.explodeArmature:getPositionX(), bulletSprite.explodeArmature:getPositionY());
					getBlackHole = true;
				end
			end
		end
	end

	if not getBlackHole then
		sprite.armature:setPosition(sprite.inHolePosX, sprite.inHolePosY+ (0.5-sprite.armatureAnchorPoint.y)*sprite.armature:getContentSize().height*sprite.armatureScale);
	end
end

function VBattleMonsterSprite.removeInBlackHole( node, sprite )
	sprite:removeBlackHoleAnimation();
	sprite.armature.visible = 0;
end

function VBattleMonsterSprite:removeBlackHoleAnimation( )
	if self.isBlackHoleAnimation then
		self.isBlackHoleAnimation = false;
		self.armature.visible = 1;
		self.armature:RunAction{{"rotateTo", 0, 0}, {"scaleTo", 0, self.armatureScale}};
		self.armature:setAnchorPoint(self.armatureAnchorPoint);
		self.armature:setPosition(self.inHolePosX, self.inHolePosY);
	end
end

function VBattleMonsterSprite:delBlackHoleBuff( battleCreature )
	self.armature.visible = 1;
	if battleCreature:GetStatus(ECreatureStatus.CREATURE_STATUS_HOLD) == 0 then
		self.isStop = false;
		self.armature:resume();
		self:continueAnimation(battleCreature);
	end
end

---------------------------------------------  彼岸菊Debuff动画  -----------------------------------------
function VBattleMonsterSprite:addOtherShoreBuff( battleCreature )
	VBattleOtherShoreBuffSprite:new(self);
end

function VBattleMonsterSprite:delOtherShoreBuff( battleCreature )
end

---------------------------------------------  血腥海棠Debuff动画  -----------------------------------------
function VBattleMonsterSprite:addBloodyBuff( battleCreature )
	VBattleBloodyBuffSprite:new(self);
end

function VBattleMonsterSprite:delBloodyBuff( battleCreature )
end

---------------------------------------------  萨满菊花Debuff动画  -----------------------------------------
function VBattleMonsterSprite:addShamanBuff( battleCreature )
	if self.shamanBuff then
		return;
	end
	self.shamanBuff = VBattleShamanMumBuffSprite:new(self);
end

function VBattleMonsterSprite:delShamanBuff( battleCreature )
	self:removeShamanBuffAnimation();
end

function VBattleMonsterSprite:removeShamanBuffAnimation( )
	if self.shamanBuff then
		self.shamanBuff:remove();
		self.shamanBuff = nil;
	end
end

---------------------------------------------  豌豆中毒Debuff动画  ---------------------------------------
function VBattleMonsterSprite:addPoisonBuff( battleCreature )
	self.armature.r = 160;
	self.armature.g = 14;
	self.armature.b = 214;
	self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
end

function VBattleMonsterSprite:delPoisonBuff( battleCreature )
	self.armature.r = 255;
	self.armature.g = 255;
	self.armature.b = 255;
	self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
end

---------------------------------------------  不做事发呆buff动画  ---------------------------------------
function VBattleMonsterSprite:addStayDazeBuff( battleCreature )
	self:stay();
end

function VBattleMonsterSprite:delStayDazeBuff( battleCreature )

end

