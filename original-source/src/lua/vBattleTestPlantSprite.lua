--vBattleTestPlantSprite.lua

VBattleTestPlantSprite = vclass("BattleTestPlantSprite")

function VBattleTestPlantSprite:initialize( battleCreature )
	self.id = battleCreature:GetId();
	self.mId = battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_ID);
	self.pos = battleCreature:GetPos();
	self.road = battleCreature:GetRoad();
	self.imageName = battleCreature.m_image;
	self.armatureScale = battleCreature.m_scale * 0.01;
	self.speedScale = battleCreature.m_speedScale * 0.01;
	self.animationType = ECreatureAnimationType.ANIMATION_NULL;

	self.creatureType = battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_RACE);
	self.moveType = battleCreature:GetAttr(ECreatureAttr.CREATURE_ATTR_MOVE_TYPE);
	-- self.speed = battleCreature:GetFloatAttr(ECreatureAttr.CREATURE_ATTR_MOVE_SPEED);
	self.level = battleCreature.m_level;
	self.insigniaImage = battleCreature.insigniaImage;

	self.armatureName = self.imageName;
	self:createSprite();
end

function VBattleTestPlantSprite:createSprite( )
	self:initPlantSprite();

	-- 添加徽章
	self:initInsigniaSprite();
	-- 设置血条
	self:setHpImage();
	-- 设置睡觉Zzz
	self:setSleepIcon();
	-- 发呆动画
	self:delayStay();
end

function VBattleTestPlantSprite:initPlantSprite()
	-- self.armature = gBattleView.battleLayer:Push(VArmature:createArmature(self.armatureName, "", "DownLeft"));
	-- self.armature = VArmature:createArmature(self.armatureName, "", "DownLeft");
	self.armature = gBattleView.battleLayer:Push(VImage{image=self.imageName.."S.png"});
	self.armature:setAnchorPoint(cc.p(0.5,0));
	self.armature.scale = self.armatureScale;
	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.PLANT_LEVEL - self.road);
	self.armature:ReLayout();

	self.posPoint = cc.p((self.pos - gBattleView.cellNum/2 ) * gBattleView.cellMinPixW, (self.road - 1) * gBattleView.cellPixH);
	self.armature:setPosition(self.posPoint.x, self.posPoint.y);


	self.armature.r = self.armature:getColor().r;
	self.armature.g = self.armature:getColor().g;
	self.armature.b = self.armature:getColor().b;
end

function VBattleTestPlantSprite:initInsigniaSprite( )
	local insigniaScale = 1;
	local temp = VImage{image="battleCreatureLevel0.png", scale=insigniaScale};
	local offy = 0 - (self.road - 1) * gBattleView.cellPixH - gBattleView.cellMinPixH;
	local offx = (self.pos - 10) * gBattleView.cellMinPixW + temp:getContentSize().width * insigniaScale * 0.5;

	if not self.level then
		self.level = 0;
	end
	local imageName = "battleCreatureLevel"..self.level..".png";

	self.insigniaNode = VImage{image=imageName, layout="DownLeft", level=self.armature.level, offset={offx, offy}, scale=insigniaScale};
	gBattleView.battleLayer:Push(self.insigniaNode);
end

function VBattleTestPlantSprite:setHpImage( )
	local level = (gBattleView.maxLevel - self.road) * EAnimationSpriteLevel.PLANT_LEVEL + 10;
	self.lifeImage = self.armature:Push(VImage{image="hpSlot.png", level=level, visible=0});
	self.lifeImage:setAnchorPoint(cc.p(0.5,0));
	self.hpImage = VImage{image="hpSlotGreen.png", layout="Left"};
	self.hpImage:setAnchorPoint(cc.p(0,0.5));
	self.lifeImage:Push(self.hpImage);
	-- self.lifeImage:ReLayout();

	self:setHpPosition();
end

function VBattleTestPlantSprite:setHpPosition( )
	self.lifeImage:setPosition(0, self.armature:getContentSize().height);
	-- self.lifeImage:setPosition(self.armature:getPositionX() - self.lifeImage:getAnchorPoint().x * self.lifeImage:getContentSize().width, self.armature:getContentSize().height);
end

function VBattleTestPlantSprite:delHpImage( )
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

function VBattleTestPlantSprite:delayStay( )
	-- if self.isSleeping then
	-- 	return;
	-- end
	-- local randomDuration = math.random(0,20)

	-- self.armature:play("idle");
	-- self.armature:getAnimation():gotoAndPlay(randomDuration);

	-- if self.armatureChild then
	-- 	self.armatureChild:play("idle");
	-- 	self.armatureChild:getAnimation():gotoAndPlay(randomDuration);
	-- end
end

function VBattleTestPlantSprite:setSleepIcon( )
	local level = (gBattleView.maxLevel - self.road) * EAnimationSpriteLevel.PLANT_LEVEL + 10;
	self.zz1 = self.armature:Push(VImage{name="zz1", image="sleepZ.png", level=level, scale=0.7, visible=0});
	self.zz2 = self.armature:Push(VImage{name="zz2", image="sleepZ.png", level=level, scale=0.7, visible=0});

	self.zz1:setAnchorPoint(cc.p(0.5,0));
	self.zz2:setAnchorPoint(cc.p(0.5,0));

	local pos = self:getSleepPos();
	self.zz1:setPosition(pos.x, pos.y);
	self.zz2:setPosition(pos.x, pos.y);
end

function VBattleTestPlantSprite:deleteSleepIcon( )
	if self.zz1 then
		self.zz1:stopAllActions();
		self.zz1:Delete();
		self.zz1 = nil;
	end
	if self.zz2 then
		self.zz2:stopAllActions();
		self.zz2:Delete();
		self.zz2 = nil;
	end
end

-- 睡觉
function VBattleTestPlantSprite:doSleep( )
	if self.isSleeping then
		return;
	end
	
	self.isSleeping = true;
	local randomDuration = math.random(0,20);
	-- local bone = self.armature:getBone("sleepNode");
	-- if bone then
	-- 	self.armature:play("sleep");
	-- 	self.armature:getAnimation():gotoAndPlay(randomDuration);
	-- 	if self.armatureChild then
	-- 		self.armatureChild:play("sleep");
	-- 		self.armatureChild:getAnimation():gotoAndPlay(randomDuration);
	-- 	end
	-- end
	randomDuration = math.random(0,7);
	self.zz1:RunAction{{"sequence", {"fadeTo", 0, 0}, {"show"}, {"delayTime", 0.1+randomDuration*0.1}, {function(node) VBattleTestPlantSprite.sleepAnimation(node, self.zz1) end}}};
	self.zz2:RunAction{{"sequence", {"fadeTo", 0, 0}, {"show"}, {"delayTime", 1.4+randomDuration*0.1}, {function(node) VBattleTestPlantSprite.sleepAnimation(node, self.zz2) end}}};
end

function VBattleTestPlantSprite.sleepAnimation( node, image )
	local x = image:getPositionX();
	local y = image:getPositionY();
	image:RunAction({"repeatForever", {"sequence", 
							{"spawn", {"scaleTo", 0, 0.4}, {"fadeTo", 0, 0}, {"rotateTo", 0, 0}, {"moveTo", 0, x, y}}, 
							{"spawn", {"scaleTo", 0.2, 0.55}, {"fadeTo", 0.2, 255},
									{"sequence", {"moveBy", 0.4, 8, 0}, {"moveBy", 0.3, 6, 8}},
									{"sequence", {"delayTime", 0.2}, {"rotateBy", 0.3, 20}}
							},
							{"spawn", {"scaleTo", 0.4, 0.7},  {"moveBy", 0.6, -18, 8}, {"rotateBy", 0.6, -60}, {"delayTime", 0.1}},
							{"spawn", {"scaleTo", 0.7, 0.35},  {"moveBy", 0.8, 20, 20}, {"rotateBy", 0.3, 15},
									{"sequence", {"delayTime", 0.4}, {"fadeTo", 0.3, 0}, {"delayTime", 0.4}}
							}
						}});
end

-- 苏醒
function VBattleTestPlantSprite:doWakeUp( )
	self.isSleeping = false;
	self:deleteSleepIcon();
	self:delayStay();
end

function VBattleTestPlantSprite:getPosX( )
	return self.pos * gBattleView.cellMinPixW;-- - gBattleView.cellPixW * 0.1;
end

function VBattleTestPlantSprite:getSunPos( )
	return cc.p(self.armature:getPositionX(), self.armature:getPositionY()+self.armature:getContentSize().height*0.5);
end

function VBattleTestPlantSprite:getShootPos( isSecond )
	return cc.p(self.armature:getPositionX(), self.armature:getPositionY()+self.armature:getContentSize().height*0.5);
end

function VBattleTestPlantSprite:getSleepPos( )
	return cc.p(self.armature:getPositionX(), self.armature:getPositionY()+self.armature:getContentSize().height*0.5);
end

function VBattleTestPlantSprite:stopAllAnimation( )
	self.armature:stopAllActions();
	-- self.armature:stop();
	if self.armatureChild then
		self.armatureChild:stopAllActions();
		-- self.armatureChild:stop();
	end
end

function VBattleTestPlantSprite:attack( plantCreature, targetCreature )
	self.animationType = ECreatureAnimationType.ANIMATION_ATTACK;
	self.armature:stopAllActions();
	-- self.armature:setSpeedScale(1);

	-- if self["attackSound"] then
	-- 	self:attackSound();
	-- end
	self:attackAnimation(plantCreature, targetCreature);
end

function VBattleTestPlantSprite:attackAnimation( )
	-- self.armature:play("attack", -1, 0);
	self:showActionName("攻击");
end

-- 受伤闪烁
function VBattleTestPlantSprite:doDamageAnimation( battleCreature )
	self:showHpAnimation(battleCreature);

	-- if gShowBloomAnimation then
	-- 	self.armature:Set_bloom(true, 0.2);
	-- end
	self.armature:setColor(cc.c3b(255,220,220));
	self.armature.callBackDelegate = self;
	self.armature.callBackFunc = "resetSelfBloom";
	self.armature:StartTimer("imageCallBackFunc", 0.1);
end

function VBattleTestPlantSprite:resetSelfBloom( )
	self.armature:StopTimer("imageCallBackFunc");
	self.armature:setColor(cc.c3b(self.armature.r, self.armature.g, self.armature.b));
	-- if gShowBloomAnimation then
	-- 	self.armature:Set_bloom(false);
	-- end
end

function VBattleTestPlantSprite:showHpAnimation( battleCreature )
	if self.lifeImage and self.hpImage then
		self.lifeImage:RunAction{{"show"}, {"delayTime", 2}, {"hide"}};

		local hpPer = battleCreature:GetHp() / battleCreature:GetRawHp();
		self.hpImage:RunAction({"scaleTo", 0, hpPer, 1});
	end
end

function VBattleTestPlantSprite:injuryAnimation( plantCreature )
	-- 受伤动画，目前只有土豆 其他留个坑
end

function VBattleTestPlantSprite:die( )
	self:delHpImage();
	gBattleView:playSound("battle_plant_die");
	self:stopAllAnimation();

	if self.armature then
		self.armature:Delete();
		self.armature = nil;
	end

	if self.Mushroom then
		self.Mushroom:Delete();
		self.Mushroom = nil;
	end

	if self.insigniaNode then
		self.insigniaNode:Delete();
		self.insigniaNode = nil;
	end
	gBattleView:resetDefendPlace(self.road, self.pos);
end

function VBattleTestPlantSprite:deleteSprite( )
	if self.armature then
		self.armature:Delete();
	end
	if self.insigniaNode then
		self.insigniaNode:Delete();
	end
end

function VBattleTestPlantSprite.stay( node, plant )
	-- plant.armature:setSpeedScale(plant.speedScale);	

	if plant.animationType ~= ECreatureAnimationType.ANIMATION_IDLE then
		plant.animationType = ECreatureAnimationType.ANIMATION_IDLE;
		-- if plant.armatureChild then
		-- 	plant.armatureChild:play("idle",-1,0);
		-- end
		-- plant.armature:play("idle");
	end
end

function VBattleTestPlantSprite:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	-- if evt == "finishShoot" then
	-- 	self:delayStay();
	-- elseif evt == "attackSound" then
	-- 	if self["attackSoundOnFrameEvent"] then
	-- 		self:attackSoundOnFrameEvent();
	-- 	end
	-- elseif evt == "rebirthOver" then
	-- 	if self["rebirthOverOnFrameEvent"] then
	-- 		self:rebirthOverOnFrameEvent();
	-- 	end
	-- elseif evt == "newWind" then
	-- 	if self["wind"] then
	-- 		self:wind();
	-- 	end
	-- elseif evt == "finishMushroom" then
	-- 	if self["finishMushroom"] then
	-- 		self:finishMushroom();
	-- 	end
	-- end
end

function VBattleTestPlantSprite:showGetSpoilAnimation( resource )
	local spoilImage = "";
	if resource[AttrType.AttrTypeMoney] and resource[AttrType.AttrTypeMoney] > 0 then
		spoilImage = "qianbi.png";
		-- cclog("******** resource[AttrType.AttrTypeMoney] = %f", resource[AttrType.AttrTypeMoney]);
	elseif resource[AttrType.AttrTypeSunshine] and resource[AttrType.AttrTypeSunshine] > 0 then
		spoilImage = "yangguang.png";
		-- cclog("******** resource[AttrType.AttrTypeSunshine] = %f", resource[AttrType.AttrTypeSunshine]);
	else
		return;
	end

	local level = (gBattleView.maxLevel - self.road) * EAnimationSpriteLevel.SUNSHINE_LEVEL;
	local spoilIcon = gBattleView.battleLayer:Push(VImage{image=spoilImage, level=level, visible=1});
	spoilIcon.scale = self.armatureScale;
	spoilIcon:setAnchorPoint(cc.p(0.5, 0.5));
	spoilIcon:ReLayout();

	spoilIcon:setPosition(self.armature:getPositionX(), self.armature:getPositionY() + self.armature:getContentSize().height * 0.8 * self.armatureScale);
	spoilIcon:RunAction{{"sequence", {"fadeTo", 0, 0}, {"show"}, {"spawn", {"moveBy", 0.6, 0, 40}, {"sequence", {"fadeTo", 0.1, 255}, {"delayTime", 0.3}, {"fadeTo", 0.2, 0}}}, {"delete"}}};
end

-- 释放技能
function VBattleTestPlantSprite:doSkill( battleCreature )
	self.armature:stopAllActions();
	-- self.armature:setSpeedScale(1);
	self.animationType = ECreatureAnimationType.ANIMATION_SKILL;
	self:showActionName("技能");
end

function VBattleTestPlantSprite:doingSkill( battleCreature )
	self.armature:stopAllActions();
	-- self.armature:setSpeedScale(1);
	self.animationType = ECreatureAnimationType.ANIMATION_SKILL;
	self:showActionName("技能");
end


-- 添加Buff
function VBattleTestPlantSprite:addBuff( battleCreature, buffId )
	local pProp = gBattleResource:GetBuffProp(buffId);

	for i,v in ipairs(pProp.m_buffAnimation) do
		local buffAnimationId = gBattleTestPlantSpriteMgr:GetBuff(v);
		if buffAnimationId and self["add"..buffAnimationId] then
			self["add"..buffAnimationId](self, battleCreature, buffId);
		end
	end
end

-- 清除Buff
function VBattleTestPlantSprite:delBuff( battleCreature, buffId )
	local pProp = gBattleResource:GetBuffProp(buffId);

	for i,v in ipairs(pProp.m_buffAnimation) do
		local buffAnimationId = gBattleTestPlantSpriteMgr:GetBuff(v);
		if buffAnimationId and self["del"..buffAnimationId] then
			self["del"..buffAnimationId](self, battleCreature, buffId);
		end
	end
end

function VBattleTestPlantSprite:getDropPos( )
	return self:getSunPos();
end
---------------------------------------  BattlePlantSpriteMgr  ---------------------------------------
VBattleTestPlantSpriteMgr = vclass("BattlePlantSpriteMgr");

function VBattleTestPlantSpriteMgr:initialize( )
	self.m_buffAnimations = {};

	-- self.m_buffAnimations[EBuffAnimationType.BUFF_REBIRTH] = "RebirthBuff";
	-- self.m_buffAnimations[EBuffAnimationType.BUFF_MUSHROOM] = "MushroomBuff";
	-- self.m_buffAnimations[EBuffAnimationType.BUFF_USEFUL] = "UsefulBuff";
	-- self.m_buffAnimations[EBuffAnimationType.BUFF_USELESS] = "UselessBuff";
	-- self.m_buffAnimations[EBuffAnimationType.BUFF_MODIFY_HP_MAX] = "ModifyHpMaxBuff";
	-- self.m_buffAnimations[EBuffAnimationType.BUFF_DIZZINESS] = "DizzinessBuff";
end

function VBattleTestPlantSpriteMgr:GetBuff( id )
	return self.m_buffAnimations[id];
end


function VBattleTestPlantSprite:showActionName( actionString )
	local actionText = self.armature:Push(VText{text=actionString, color={255,0,0}, fontSize="26", scale=3, layout="Up"});
	actionText:RunAction{{"moveBy", 1, 0, 40}, {"fadeTo", 0.5, 0}, {"delete"}};
end