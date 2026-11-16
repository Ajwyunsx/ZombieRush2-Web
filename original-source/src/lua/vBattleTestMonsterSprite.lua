--VBattleTestMonsterSprite.lua

VBattleTestMonsterSprite = vclass("BattleTestMonsterSprite")

local local_bit = gBit;

function VBattleTestMonsterSprite:initialize( battleCreature )
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
	self.armatureScale = 0.7;
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

function VBattleTestMonsterSprite:isValid( )
	return self.valid;
end

function VBattleTestMonsterSprite:createSprite( )
	self.armature = VImage{image=self.imageName.."L.png"};
	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.MONSTER_LEVEL - self.road);
	self.armature.scale = self.armatureScale;--gBattleView.spriteScale;
	if self.isHide then
		self.armature.visible = 0;
	end
	self.armature:setAnchorPoint(cc.p(0.5,0));
	gBattleView.battleLayer:Push(self.armature);
	self.armature:ReLayout();
	-- gBattleView.batchNode:addChild(self.armature);

	self.armatureAnchorPoint = self.armature:getAnchorPoint();
	self.armature.r = self.armature:getColor().r;
	self.armature.g = self.armature:getColor().g;
	self.armature.b = self.armature:getColor().b;
	
	self:initMonsterSprite();
end

function VBattleTestMonsterSprite:initMonsterSprite( )
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

function VBattleTestMonsterSprite:setHpImage( )
	local level = (gBattleView.maxLevel - self.road) * EAnimationSpriteLevel.MONSTER_LEVEL + 10;

	self.lifeImage = self.armature:Push(VImage{image="hpSlot.png", layout="Up", level=level, visible=0});
	self.lifeImage:setAnchorPoint(cc.p(0.5,1));
	self.hpImage = VImage{image="hpSlotGreen.png", layout="Left"};
	self.hpImage:setAnchorPoint(cc.p(0,0.5));
	self.lifeImage:Push(self.hpImage);
	self.lifeImage:ReLayout();
	
	self:setHpPosition();
end

function VBattleTestMonsterSprite:setHpPosition( )
	-- local armatureSize = self.armature:getContentSize();
	-- local pos = self.armature:convertToNodeSpace(cc.p(bonePos.x + boneSize.width * 0.5 * self.armatureScale, bonePos.y + boneSize.height * self.armatureScale + 6));
	-- self.lifeImage:setPosition(pos.x, pos.y);
end

function VBattleTestMonsterSprite:delHpImage( )
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

function VBattleTestMonsterSprite:setMonsterBullet( bulletId )
	table.insert(self.monsterBulletId, bulletId);
end

function VBattleTestMonsterSprite:getShootPos( )
	return cc.p(self.armature:getPositionX(), self.armature:getPositionY()+self.armature:getContentSize().height);
end

function VBattleTestMonsterSprite:changeSpeedScale( speedScale, battleCreature )
	self.isChangeSpeed = true;
	self:continueAnimation(battleCreature);
end

function VBattleTestMonsterSprite:continueAnimation( battleCreature )
	-- 没有被定身
	if not self.isStop then
		if battleCreature:GetAction() == ECreatureAction.ACTION_MOVE then
			self:walk(battleCreature, self.targetPlant);
			self.isChangeSpeed = false;
		end
	end
end

function VBattleTestMonsterSprite:stopAllAnimation( )
	if self.armature and self.valid then
		self.armature:stopAllActions();
	end
end

-- 站
function VBattleTestMonsterSprite:stay( )
	self.isAttacking = false;
	self.armature:stopAllActions();
	self:stayAnimation();
end

function VBattleTestMonsterSprite:stayAnimation( )
	self.animationType = ECreatureAnimationType.ANIMATION_IDLE;
end

-- 进场
function VBattleTestMonsterSprite:doEnter( )
	self:stay();

	local posx2 = 90 * gBattleView.cellMinPixW;
	local posy2 = (self.road - 1) * gBattleView.cellPixH;
	local actionTime = 1.2;
	self.armature:RunAction{{"moveTo", actionTime, posx2, posy2}};

	gBattleView("carArmature"..self.road).isOpen = true;
	gBattleView("carArmature"..self.road):play("open");
	gBattleView("touchLayer"..self.road):RunAction{{"delayTime", actionTime}, {function(node) VBattleTestMonsterSprite.finishEnter(node, self) end}};
end

function VBattleTestMonsterSprite.finishEnter( node, monster )
	if monster.isReadyEnter then
		monster.isReadyEnter = false;
	end

	if gBattleView then
		gBattleView("carArmature"..monster.road):play("back", nil, 0);
	end
end

-- 走路
function VBattleTestMonsterSprite:walk( battleCreature, plant )
	if self.isStop then
		return;
	end

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

function VBattleTestMonsterSprite:walkAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_MOVE then
		self.animationType = ECreatureAnimationType.ANIMATION_MOVE;
	end
end

function VBattleTestMonsterSprite:runWalkAction( battleCreature, plant )
	if self.isBlackHoleAnimation then
		return;
	end

	local isRunEnd = false;
	local actionTime = 0;
	local monsterSpeed = battleCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED) * gBattleView.battleInfo.inerval;
	self.playMoveSpeed = 1 / (self.moveSpeedScale / monsterSpeed);

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
			self.armature:RunAction{{"moveTo", actionTime, plantPos, self.armature:getPositionY()}, {function(node) VBattleTestMonsterSprite.arriveTargetPlant(node, self, battleCreature) end}};
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
		self.armature:RunAction{{"moveTo", actionTime, endPos, self.armature:getPositionY()}, {function(node) VBattleTestMonsterSprite.finishWalkAction(node, self) end}};
	end
end

function VBattleTestMonsterSprite.arriveTargetPlant( node, moster, battleCreature )
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

function VBattleTestMonsterSprite.finishWalkAction( node, moster )
	moster:walkEnd();
end

function VBattleTestMonsterSprite:walkEnd( )
	if self.isStop then
		return;
	end
	
	-- self.armature:setSpeedScale(self.playMoveSpeed);
	self:walkAnimation();

	local diffX = (self.armature:getPositionX() - gBattleView("endLayer"..self.road):getPositionX());
	if diffX <= 0 then
		diffX = 20;
	end
	
	if self.walkRate <= 0 then
		self.walkRate = 10 / (self.speed * gBattleView.battleInfo.inerval);
	end

	local actionTime = diffX * self.walkRate;
	self.armature:RunAction{{"moveTo", actionTime, gBattleView("endLayer"..self.road):getPositionX(), self.armature:getPositionY()}, {VBattleTestMonsterSprite.moveEnd, self.armature, self.id}};
end

function VBattleTestMonsterSprite.moveEnd( node, id )
	if gBattleView then
		local sprite = gBattleView.MonsterList[id];
		sprite.valid = false;
		-- sprite:stay();
		gBattleView:monsterMoveEnd(sprite.road);
		gBattleView:monsterIsValid();
		local diffX = sprite.armature:getPositionX() - 20;
		sprite.armature:RunAction{{"sequence", {"spawn", {"moveTo", 0.5, diffX, sprite.armature:getPositionY()}, {"fadeTo", 0.5, 0}}, {function(node) VBattleTestMonsterSprite.moveEndDelete(node, sprite) end}}};
	end
end

function VBattleTestMonsterSprite.moveEndDelete( node, moster )
	moster.armature:Delete();
	moster.armature = nil;
end

-- 受伤闪烁
function VBattleTestMonsterSprite:doDamageAnimation( battleCreature )
	self:showHpAnimation(battleCreature);

	-- if gShowBloomAnimation then
	-- 	self.armature:Set_bloom(true, 0.1);
	-- else
		self.armature:setColor(cc.c3b(255,220,220));
	-- end
	self.armature.callBackDelegate = self;
	self.armature.callBackFunc = "resetSelfColor";
	self.armature:StartTimer("imageCallBackFunc", 0.1);
end

function VBattleTestMonsterSprite:resetSelfColor( )
	self.armature:StopTimer("imageCallBackFunc");
	-- if gShowBloomAnimation then
	-- 	self.armature:Set_bloom(false);
	-- else
		self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
	-- end
end

-- 扣血动画
function VBattleTestMonsterSprite:showHpAnimation( battleCreature )
	if self.lifeImage and self.hpImage then
		self.lifeImage:RunAction{{"show"}, {"delayTime", 2}, {"hide"}};
		local hpPer = battleCreature:GetHp() / battleCreature:GetRawHp();
		self.hpImage:RunAction({"scaleTo", 0, hpPer, 1});
	end
end

-- 重伤
function VBattleTestMonsterSprite:halfLifeAnimation( )
	-- if not self.halfLife then
	-- 	self.halfLife = true;

	-- 	local boneList = {"leftHand", "leftForearm"};
	-- 	self:setStumpAnimation(boneList);
	-- end
end

function VBattleTestMonsterSprite:setStumpAnimation( boneList )
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
			moveRange = math.random(70,30);
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
function VBattleTestMonsterSprite:attack( )
	self.armature:stopAllActions();
	-- self.armature:setSpeedScale(1);
	self:cleanChildSprite();

	self:attackAnimation();
end

function VBattleTestMonsterSprite:attackAnimation( )
	if self.animationType ~= ECreatureAnimationType.ANIMATION_ATTACK then
		self.animationType = ECreatureAnimationType.ANIMATION_ATTACK;
	end
		self:showActionName("攻击");
end

function VBattleTestMonsterSprite:cleanChildSprite( )
	if self["delEvilAnimation"] then
		self:delEvilAnimation();
	end
	if self["cleanMagicLight"] then
		self:cleanMagicLight();
	end
end

function VBattleTestMonsterSprite:cleanMagicLight( )
	if #self.monsterBulletId > 0 then
		for i=#self.monsterBulletId,1,-1 do
			gBattleView:removeBulletSprite(self.monsterBulletId[i]);
		end
	end
end

-- 秒杀 飞出屏幕外
function VBattleTestMonsterSprite:flyAway( )
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

function VBattleTestMonsterSprite:flyAwayAnimation( )
	local windowSize = gWindow:getContentSize();

	local posx = windowSize.width + 100 - self.armature:getPositionX();
	local posy = posx * math.atan(20);
	self.armature:RunAction{{"rotateBy", 0, 60}, {"moveBy", 1, posx, posy}, {VBattleTestMonsterSprite.finishDieAnimation, self.armature}};
end

-- 死亡
function VBattleTestMonsterSprite:die( )
	if self.valid then
		self.valid = false;
		self.armature:StopAction();
		-- self:removeDizzinessAnimation();
		-- self:removeBlackHoleAnimation();

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

function VBattleTestMonsterSprite:dieAnimation( )
	-- self.armature:setSpeedScale(1);
	self:cleanChildSprite();
	-- self.armature:play("dead", 0.1, 0);


	self.armature:StopAction();
	self.armature:stopAllActions();
	self.armature:Delete();
	self.armature = nil;

	if gBattleView then
		gBattleView:monsterIsValid();
	end
end

function VBattleTestMonsterSprite:dieAndStumpAnimation( )
	-- local boneList = {"head", "jaw"};
	-- self:setStumpAnimation(boneList);
end

function VBattleTestMonsterSprite.finishDieAnimation( node )
	node:StopAction();
	node:stopAllActions();
	node:Delete();
	node = nil;

	if gBattleView then
		gBattleView:monsterIsValid();
	end
end

function VBattleTestMonsterSprite:deleteSprite( )
	if self.armature then
		self.armature:Delete();
		self.armature = nil;
	end
end

function VBattleTestMonsterSprite:finishShootAnimation( )
	self.isAttacking = false;
	if self.delayRun then
		self.delayRun = false;
		self:walk(self.delayMonster, self.delayPlant);
		self.delayMonster = nil;
		self.delayPlant = nil;
	else
		-- self.armature:play("idle");
		self.animationType = ECreatureAnimationType.ANIMATION_IDLE;
	end
end

-- 爆炸震动屏幕
function VBattleTestMonsterSprite:boomShakeView( )
	local posX = gBattleView:getPositionX();
	local posY = gBattleView:getPositionY();
	gBattleView:RunAction{{"moveTo", 0.08, posX+7, posY+7}, {"moveTo", 0.08, posX, posY}};
end

-- 释放技能
function VBattleTestMonsterSprite:doSkill( battleCreature )
	self.armature:stopAllActions();
	-- self.armature:setSpeedScale(1);
	self.animationType = ECreatureAnimationType.ANIMATION_SKILL;
	self:showActionName("技能");
end

function VBattleTestMonsterSprite:doingSkill( battleCreature )
	self.armature:stopAllActions();
	-- self.armature:setSpeedScale(1);
	self.animationType = ECreatureAnimationType.ANIMATION_SKILL;
	self:showActionName("技能");
end

-- 添加Buff
function VBattleTestMonsterSprite:addBuff( battleCreature, buffId )
	local pProp = gBattleResource:GetBuffProp(buffId);
	if not pProp then return; end
	self:setBuffSpeedAnimation(battleCreature,pProp);

	for i,v in ipairs(pProp.m_buffAnimation) do
		local buffAnimationId = gBattleTestMonsterSpriteMgr:GetBuff(v);
		if buffAnimationId and self["add"..buffAnimationId] then
			self["add"..buffAnimationId](self, battleCreature, buffId);
		end
	end
end

-- 清除Buff
function VBattleTestMonsterSprite:delBuff( battleCreature, buffId )
	local pProp = gBattleResource:GetBuffProp(buffId);
	if not pProp then return; end
	self:setBuffSpeedAnimation(battleCreature,pProp);
	
	for i,v in ipairs(pProp.m_buffAnimation) do
		local buffAnimationId = gBattleTestMonsterSpriteMgr:GetBuff(v);
		if buffAnimationId and self["del"..buffAnimationId] then
			-- self:setBuffSpeedAnimation(battleCreature,pProp);
			self["del"..buffAnimationId](self, battleCreature);
		end
	end
end

-- buff影响移动速度动画
function VBattleTestMonsterSprite:setBuffSpeedAnimation( battleCreature, pProp )
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

function VBattleTestMonsterSprite:getDropPos( )
	return cc.p(self.armature:getPositionX(), self.armature:getPositionY());

	-- local bone = self.armature:getBone("body");
	-- if bone then
	-- 	return self.armature:getBonePos("body");
	-- else
	-- 	return cc.p(self.armature:getPositionX(), self.armature:getPositionY() + self.armature:getContentSize().height * 0.5);
	-- end
end
---------------------------------------  音效处理  ---------------------------------------

function VBattleTestMonsterSprite:walkSound( )
	
end

function VBattleTestMonsterSprite:attackSound( )
	gBattleView:playSound("battle_zombie_attack_plant_", 3);
end

function VBattleTestMonsterSprite:dieSound( )
	gBattleView:playSound("battle_zombie_die_", 2);
end

function VBattleTestMonsterSprite:boomSound( )
	gBattleView:playSound("battle_BoomZombie_Boom");
end

---------------------------------------  BattleMonsterSpriteMgr  ---------------------------------------

VBattleTestMonsterSpriteMgr = vclass("BattleMonsterSpriteMgr");

function VBattleTestMonsterSpriteMgr:initialize( )
	self.m_buffAnimations = {};

	self.m_buffAnimations[EBuffAnimationType.BUFF_SLOW_DOWN] = "SlowDownBuff";

end

function VBattleTestMonsterSpriteMgr:GetBuff( id )
	return self.m_buffAnimations[id];
end

---------------------------------------  减速动画  ---------------------------------------
function VBattleTestMonsterSprite:addSlowDownBuff( battleCreature, buffId )
	self.armature.r = 170;
	self.armature.g = 170;
	self.armature.b = 255;
	self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
end

function VBattleTestMonsterSprite:delSlowDownBuff( battleCreature, buffId )
	self.armature.r = 255;
	self.armature.g = 255;
	self.armature.b = 255;
	self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
end




function VBattleTestMonsterSprite:showActionName( actionString )
	local actionText = self.armature:Push(VText{text=actionString, color={255,0,0}, fontSize="26", scale=3, layout="Up"});
	actionText:RunAction{{"moveBy", 1, 0, 40}, {"fadeTo", 0.5, 0}, {"delete"}};
end