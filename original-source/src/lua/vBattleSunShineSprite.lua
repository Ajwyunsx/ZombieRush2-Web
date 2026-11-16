--vBattleSunShineSprite.lua

VBattleSunShineSprite = vclass("BattleSunShineSprite")

function VBattleSunShineSprite:initialize( battleCreature, sunshineData )
	self.mId = sunshineData.id;
	self.value = sunshineData.value;
	self.imagetouch = 1;

	if battleCreature and battleCreature ~= "" then
		self.isFromCreature = true;
		self.pos = battleCreature:GetPos();
		self.road = battleCreature:GetRoad();

		local plantSprite = gBattleView.PlantList[battleCreature:GetId()];
		local plantSunPos = plantSprite:getSunPos();

		local randomX = 0;
		local leftOrRight = math.random(1,2);
		if leftOrRight == 1 then
			randomX = math.random(-25,-10);
		else
			randomX = math.random(10,25);
		end
		local randomY = math.random(0,15) * 0.1;
		
		self.startPos = gBattleView:convertToNodeSpace(plantSunPos);
		self.middleHight = 3*gBattleView.cellMinPixH;
		self.middlePos = cc.p(self.startPos.x + randomX*0.1*gBattleView.cellMinPixW, self.startPos.y + self.middleHight);

		local plantPosX = (battleCreature:GetPos() - gBattleView.cellNum/2 ) * gBattleView.cellMinPixW;
		local endPos = cc.p(plantPosX + randomX*0.15*gBattleView.cellMinPixW, (self.road - 1) * gBattleView.cellPixH + randomY*gBattleView.cellMinPixH);
		self.endPos = gBattleView.sunshineLayer:convertToNodeSpace(gBattleView.battleLayer:convertToWorldSpace(endPos));

		if leftOrRight == 1 then
			if self.endPos.x > self.startPos.x then
				self.endPos.x = self.startPos.x;
			end	
		else
			if self.startPos.x > self.endPos.x then
				self.endPos.x = self.startPos.x;
			end	
		end
	else
		self.isFromCreature = false;
		local leftOrRight = math.random(1,2);
		if leftOrRight == 1 then
			self.pos = math.random(8,36);
		else
			self.pos = math.random(52,72);
		end
		self.road = math.random(1,4);
		local randomY = math.random(0, 4);

		local x = (self.pos - gBattleView.cellNum/2 ) * gBattleView.cellMinPixW;
		self.startPos = gBattleView.sunshineLayer:convertToNodeSpace(gBattleView.battleLayer:convertToWorldSpace(cc.p(x, 0)));
		self.startPos.y = gBattleView.sunshineLayer:getContentSize().height+gBattleView.sunshinePixH*0.5;
		self.endPos = gBattleView.sunshineLayer:convertToNodeSpace(gBattleView.battleLayer:convertToWorldSpace(cc.p(x, (self.road - 1) * gBattleView.cellPixH + randomY*gBattleView.cellMinPixH)));
	end
	
	self:createSprite();
end

function VBattleSunShineSprite:createSprite( )
	if self.isFromCreature then
		self.imageLevel = (gBattleView.maxLevel - self.road) * EAnimationSpriteLevel.SUNSHINE_LEVEL;
	else
		self.imageLevel = (gBattleView.maxLevel + 1) * EAnimationSpriteLevel.SUNSHINE_LEVEL;
	end

	local imageName = "battleSun.png";
	if gBattleView.battleInfo.attackType ~= BattleType.BattleTypeEvp then
		imageName = "battleSunDark.png";
	end

	local sunshineScale = 1.3;
	self.image = gBattleView:Push(VImage{image=imageName, scale=sunshineScale, level=self.imageLevel, touch=0});
	self.image:setPosition(self.startPos.x, self.startPos.y);
	-- self.image.onClick = "gView('BattleView'):pickupSunshine("..self.mId..")";

	local disappearTime = gBattleResource:SunshineTimeoutParam() / gBattleView.msec_unit;
	local delay = disappearTime * 0.8;
	local repeatTime = 3;
	local fadeTime = (disappearTime - delay) / (repeatTime + 0.5);
	local rotateTime = 20;
	local rotation = 360;

	self.image.isMoveAction = true;
	if self.isFromCreature then
		local moveTime = 0.2;
		local speed = self.middleHight / moveTime;
		local moveEndTime = math.abs(self.middlePos.y - self.endPos.y) / speed;
		if moveEndTime > moveTime * 2 then
			moveEndTime = moveTime * 2;
		end
		self.image:RunAction{"sequence", 
									{"spawn",
										{"moveTo", 0, self.startPos.x, self.startPos.y},
										{"scaleTo", 0, 0.6}
									},
									{"spawn",
										{"moveTo", moveTime, self.middlePos.x, self.middlePos.y},
										{"scaleTo", moveTime*0.7, sunshineScale}
									},
									{"moveTo", moveEndTime, self.endPos.x, self.endPos.y},
									{"spawn",
										{"repeat", -1, 
											{"rotateBy", rotateTime, rotation}
										},
										{"sequence",
											{"delayTime", delay}, 
											{"repeat", repeatTime,
												{"sequence",
													{"fadeTo", fadeTime, 120},
													{"fadeTo", fadeTime, 255}
												}
											},
											{"fadeTo", fadeTime, 0},
											{function(node) VBattleSunShineSprite.removeSelfImage(node, self) end}
										}
									}
								};
	else
		local speed = self.startPos.y / disappearTime;
		local moveTime = (self.startPos.y - self.endPos.y) / speed;
		if moveTime > delay then
			delay = moveTime;
		end
		-- cclog("************ moveTime = %f ", moveTime);
		-- cclog("*********** self.startPos.x = %f, self.startPos.y = %f, self.endPos.x = %f, self.endPos.y = %f", self.startPos.x , self.startPos.y, self.endPos.x, self.endPos.y);
		self.image:RunAction{"spawn", 
								{"moveTo", 0, self.startPos.x, self.startPos.y},
								{"moveTo", moveTime, self.endPos.x, self.endPos.y},
								{"repeat", -1, 
									{"rotateBy", rotateTime, rotation}
								},
								{"sequence",
									{"delayTime", delay}, 
									{"repeat", repeatTime,
										{"sequence",
											{"fadeTo", fadeTime, 120},
											{"fadeTo", fadeTime, 255}
										}
									},
									{"fadeTo", fadeTime, 0},
									{function(node) VBattleSunShineSprite.removeSelfImage(node, self) end}
								}
							};
	end
end

function VBattleSunShineSprite.removeSelfImage( node, sunshine )
	gBattleView:removeSunshineSprite(sunshine.mId);
end

function VBattleSunShineSprite:doPickupAnimation( )
	self.isPicking = true;
	self.finalPos = cc.p(gBattleView.imgSunshine:getPositionX(), gBattleView.imgSunshine:getPositionY());
	self.image:RunAction{"sequence", 
								{"easeOut", 1.5, {"moveTo", 0.6, self.finalPos.x, self.finalPos.y}},
								{"spawn",
									{"fadeTo", 0.2, 80},
									{"scaleTo", 0.2, 0.8}
								},
								{function(node) VBattleSunShineSprite.pickupSunshine(node, self) end}
							}
end

function VBattleSunShineSprite.pickupSunshine( node, sunshine )
	gBattleView:showAddSunshineAnimation(sunshine);
	gBattleView:setSunshineView();
	gBattleView:removeSunshineSprite(sunshine.mId);
end

function VBattleSunShineSprite:setTouchUnable( )
	self.imagetouch = 0;
end

function VBattleSunShineSprite:stopAllAnimation( )
	if self.image then
		-- self.image:stopAllActions();
		self:deleteSprite();
	end
end

function VBattleSunShineSprite:deleteSprite( )
	if self.image then
		self.image:Delete();
		self.image = nil;
	end
end

