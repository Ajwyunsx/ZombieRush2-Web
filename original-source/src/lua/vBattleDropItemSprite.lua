--vBattleDropItemSprite.lua

VBattleDropItemSprite = vclass("BattleDropItemSprite")

function VBattleDropItemSprite:initialize( battleCreature, pvpDropData )
	self.mId = pvpDropData.id;
	self.userId = pvpDropData.userId;
	self.type = pvpDropData.type;
	self.thingId = pvpDropData.thingId;
	self.imgName = "suipian.png";
	local itemInfo = gData:itemInfo(self.thingId);
	if itemInfo then
		self.imgName = itemInfo.image;
	end
	self.scale = 1;
	self.count = pvpDropData.count;
	self.imagetouch = 1;

	self.isFromCreature = true;
	self.pos = battleCreature:GetPos();
	self.road = battleCreature:GetRoad();

	local creatureSprite = nil;
	if battleCreature:GetIsAttack() then
		creatureSprite = gBattleView.MonsterList[battleCreature:GetId()];
	else
		creatureSprite = gBattleView.PlantList[battleCreature:GetId()];
	end

	local dropPos = creatureSprite:getDropPos();

	local randomX = 0;
	while randomX > -10 and randomX < 10 do
		randomX = math.random(-35,35);
	end
	local randomY = math.random(0,50) * 0.1;
	self.startPos = gBattleView:convertToNodeSpace(dropPos);
	self.middleHight = 3*gBattleView.cellMinPixH;
	self.middlePos = cc.p(self.startPos.x + randomX*0.1*gBattleView.cellMinPixW, self.startPos.y + self.middleHight);

	local plantPosX = (battleCreature:GetPos() - gBattleView.cellNum/2 ) * gBattleView.cellMinPixW;
	local endPos = cc.p(plantPosX + randomX*0.15*gBattleView.cellMinPixW, (self.road - 1) * gBattleView.cellPixH);
	self.endPos = gBattleView.sunshineLayer:convertToNodeSpace(gBattleView.battleLayer:convertToWorldSpace(endPos));

	self:createSprite();
end

function VBattleDropItemSprite:createSprite( )
	self.imageLevel = (gBattleView.maxLevel - self.road) * EAnimationSpriteLevel.DROP_LEVEL;

	local tempImage = VImage{image="suipianguang.png"};
	self.image = gBattleView:Push(VLayer{size={tempImage:getContentSize().width, tempImage:getContentSize().height, scale=0, level=self.imageLevel, touch=0}});
	tempImage:Delete();

	self.lightImage = self.image:Push(VImage{image="suipianguang.png", layout="Center", scale=self.scale});
	local diImage = self.image:Push(VImage{image="suipianguangdi.png", layout="Center", scale=self.scale});
	self.endPos.y = self.endPos.y + diImage:getContentSize().height/2;

	local tempImage = VImage{image=self.imgName};
	local scaleX = diImage:getContentSize().width / tempImage:getContentSize().width;
	local scaleY = diImage:getContentSize().height / tempImage:getContentSize().height;
	tempImage:Delete();

	local itemImage = diImage:Push(VImage{image=self.imgName, layout="Center"});
	itemImage:setScaleX(scaleX);
	itemImage:setScaleY(scaleY);

	self.image:setPosition(self.startPos.x, self.startPos.y);

	local disappearTime = 5;
	local delay = disappearTime * 0.8;
	local repeatTime = 3;
	local fadeTime = (disappearTime - delay) / (repeatTime + 0.5);

	self.image.isMoveAction = true;
	
	local moveTime = 0.2;
	local speed = self.middleHight / moveTime;
	local moveEndTime = math.abs(self.middlePos.y - self.endPos.y) / speed;
	if moveEndTime > moveTime * 2 then
		moveEndTime = moveTime * 2;
	end
	self.image:RunAction{"sequence", 
								{"spawn",
									{"moveTo", 0, self.startPos.x, self.startPos.y},
									{"scaleTo", 0, self.scale*0.6}
								},
								{"spawn",
									{"moveTo", moveTime, self.middlePos.x, self.middlePos.y},
									{"scaleTo", moveTime*0.7, self.scale}
								},
								{"moveTo", moveEndTime, self.endPos.x, self.endPos.y},
								{"sequence",
									{"delayTime", delay}, 
									{"repeat", repeatTime,
										{"sequence",
											{"fadeTo", fadeTime, 120},
											{"fadeTo", fadeTime, 255}
										}
									},
									{function(node) VBattleDropItemSprite.autoPickup(node, self) end}
								}
							};
	self.lightImage:RunAction{{"delayTime", moveTime*0.8}, {"repeat", -1, {"rotateBy", 10, 360}}};
end

function VBattleDropItemSprite.autoPickup( node, dropItem )
	gBattleView:pickupDropItem(dropItem.mId);
end

function VBattleDropItemSprite:doPickupAnimation( )
	self.isPicking = true;
	self.finalPos = cc.p(self.endPos.x, self.endPos.y + 50);
	self.image:RunAction{"sequence", 
								{"easeOut", 1, {"moveTo", 0.5, self.finalPos.x, self.finalPos.y}},
								{"spawn",
									{"fadeTo", 0.2, 80},
									{"scaleTo", 0.2, self.scale*0.8}
								},
								{function(node) VBattleDropItemSprite.pickupDropItem(node, self) end}
							}
end

function VBattleDropItemSprite.pickupDropItem( node, dropItem )
	gBattleView:addDropItem(dropItem.mId);
	gBattleView:removeDropItemSprite(dropItem.mId);
end

function VBattleDropItemSprite:setTouchUnable( )
	self.imagetouch = 0;
end

function VBattleDropItemSprite:stopAllAnimation( )
	if self.image then
		self:deleteSprite();
	end
end

function VBattleDropItemSprite:deleteSprite( )
	if self.image then
		self.lightImage:stopAllActions();
		self.image:stopAllActions();
		self.image:Delete();
		self.image = nil;
	end
end

