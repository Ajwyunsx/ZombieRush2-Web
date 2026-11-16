--vBattleObjectSprite.lua

VBattleObjectSprite = vclass("BattleObjectSprite")

function VBattleObjectSprite:create( battleObject, battleUnit )
	-- self:createSprite();
end

function VBattleObjectSprite:createSprite( )
	
end

function VBattleObjectSprite:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	if evt == "" then
	end
end

function VBattleObjectSprite:deleteSprite( )
	-- if self.armature then
	-- 	self.armature:Delete();
	-- 	self.armature = nil;
	-- end
end

function VBattleObjectSprite:stopAllAnimation( )
	
end

function VBattleObjectSprite:die( )

end

-- 火焰区域
---------------------------------------  BattleFireObjectSprite  ---------------------------------------
VBattleFireObjectSprite = vclass("BattleFireObjectSprite", VBattleObjectSprite)

function VBattleFireObjectSprite:initialize( battleObject, battleUnit )
	-- VBattleObjectSprite.initialize(self, battleObject);
	self.bulletId = battleUnit:GetId();	
end

function VBattleFireObjectSprite:die( )
	local bulletSprite = gBattleView.BulletList[self.bulletId];
	if bulletSprite then
		bulletSprite:removeFire();
	end
end

-- 定时炸弹
---------------------------------------  BattleBombObjectSprite  ---------------------------------------
VBattleBombObjectSprite = vclass("BattleBombObjectSprite", VBattleObjectSprite)

function VBattleBombObjectSprite:initialize( battleObject, battleUnit )
	-- VBattleObjectSprite.initialize(self, battleObject);
	self.bulletId = battleUnit:GetId();
	local bulletSprite = gBattleView.BulletList[self.bulletId];
	if bulletSprite then
		bulletSprite:resetPosition(battleObject);
	end
end

function VBattleBombObjectSprite:die( )
	local bulletSprite = gBattleView.BulletList[self.bulletId];
	if bulletSprite then
		bulletSprite:removeBomb();
	end
end

-- 黑洞
---------------------------------------  BattleBlackHoleObjectSprite  ---------------------------------------
VBattleBlackHoleObjectSprite = vclass("BattleBlackHoleObjectSprite", VBattleObjectSprite)

function VBattleBlackHoleObjectSprite:initialize( battleObject, battleUnit )
	-- VBattleObjectSprite.initialize(self, battleObject);
	self.bulletId = battleUnit:GetId();
	local bulletSprite = gBattleView.BulletList[self.bulletId];
	if bulletSprite then
		bulletSprite:setBlackHole(battleObject);
	end
end
