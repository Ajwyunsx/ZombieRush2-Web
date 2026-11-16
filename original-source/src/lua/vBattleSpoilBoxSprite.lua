--vBattleSpoilBoxSprite.lua

VBattleSpoilBoxSprite = vclass("BattleSpoilBoxSprite")

function VBattleSpoilBoxSprite:create( road )
	self.road = road;
	
	self:createSprite();
end

function VBattleSpoilBoxSprite:createSprite( )
	self.armature = VArmature:createArmature("spoilBoxArmature");
	gBattleView.battleLayer:Push(self.armature);

	self.armature.level = (gBattleView.maxLevel - self.road) * (EAnimationSpriteLevel.PLANT_LEVEL -1 - self.road);

	local scaleX = gWindow:getContentSize().width / 1024;
	local scaleY = gWindow:getContentSize().height / 576;
	self.armature.scale = math.min(0.75, math.min(scaleX, scaleY));
	self.armature:ReLayout();

	local endNode = gBattleView("endBoxLayer");
	local posx = endNode:getPositionX() + ( 1- self.armature.scale) * self.armature:getContentSize().width;
	local posy = (self.road - 1) * gBattleView.cellPixH;
	self.armature:setPosition(posx, posy);

	local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
		self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
	end 
	self.armature:setEventCallFunc(callBack);

	self.armature:play("close", -1, 0);
end

-- 显示宝箱动画
function VBattleSpoilBoxSprite:showSpoilBoxAnimation( isGetSpoils )
	if isGetSpoils then
		self.armature:play("showSpoil", -1, 0);
	else
		self.armature:play("open", -1, 0);
	end
end

function VBattleSpoilBoxSprite:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	if evt == "finishSpoil" then
		self.armature:RunAction{{"fadeTo", 0.7, 0}, {function(node) VBattleSpoilBoxSprite.finishAnimation(node, self, self.road) end}};
	elseif evt == "finishOpen" then
		self.armature:RunAction{{"delayTime", 1.5}, {"fadeTo", 0.5, 0}, {function(node) VBattleSpoilBoxSprite.finishAnimation(node, self, self.road) end}};
	end
end

function VBattleSpoilBoxSprite.finishAnimation( node, boxSprite, road )
	boxSprite.armature:Delete();
	boxSprite.armature = nil;
	if gBattleView then
		gBattleView:finishOpenBox(road);
	end
end

function VBattleSpoilBoxSprite:deleteSprite( )
	if self.armature then
		self.armature:Delete();
		self.armature = nil;
	end
end