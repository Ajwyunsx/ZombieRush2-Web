-- vBattleBuffSprite.lua

-- 通用buff
---------------------------------------  BattleBuffSprite  ---------------------------------------
VBattleBuffSprite = vclass("BattleBuffSprite")

function VBattleBuffSprite:initialize( targetSprite )

end

function VBattleBuffSprite:setBuffScale( targetSprite )
	self.scale = 1;
end

-- 挂在头顶的buff
function VBattleBuffSprite:createUpBuffSprite( targetSprite )
	if not targetSprite then
		return;
	else
		if not targetSprite.armature then
			return;
		else
			if targetSprite:isInstanceOf(VBattleMonsterSprite) then
				if not targetSprite.valid then
					return;
				end
			end
		end
	end

	self:setBuffScale(targetSprite);
	self.armature = targetSprite.armature:Push(VArmature:createArmature(self.armatureName, "", "DownLeft"));
	self.armature.level = 100;--targetSprite.armature.level + 1;
	self.armature.scale = self.scale;
	self.armature:ReLayout();

	local getHead = false;
	if targetSprite["isValid"] and targetSprite:isValid() then
		if targetSprite.armature:getBone("head") then
			if targetSprite.armature:getBone("head"):getDisplayRenderNode() then
				getHead = true;
				local boneNode = targetSprite.armature:getBone("head"):getDisplayRenderNode();
				local anchorPoint = boneNode:getAnchorPoint();
				local bonePos = targetSprite.armature:getBonePos("head");
				local boneSize = targetSprite.armature:getBoneSize("head");

				local pos = targetSprite.armature:convertToNodeSpace(cc.p(bonePos.x + boneSize.width * anchorPoint.x * targetSprite.armatureScale, bonePos.y + boneSize.height * anchorPoint.y * targetSprite.armatureScale));
				self.armature:setPosition(pos.x, pos.y);
			end
		end
	end

	if not getHead then
		self.armature:setPosition(0, targetSprite.armature:getContentSize().height);
	end

	self.armature:play("show");	
end

-- 挂在底下的buff
function VBattleBuffSprite:createDownBuffSprite( targetSprite )
	self:setBuffScale(targetSprite);
	self.armature = targetSprite.armature:Push(VArmature:createArmature(self.armatureName, "", "DownLeft"));
	self.armature.level = 100;--targetSprite.armature.level + 1;
	self.armature.scale = self.scale;
	self.armature:ReLayout();
	self.armature:setPosition(0, 0);
end

function VBattleBuffSprite:setFrameEvent( )
	local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
		self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
	end 
	self.armature:setEventCallFunc(callBack);
	self.armature:play("show");	
end

-- 帧事件回调
function VBattleBuffSprite:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
	if evt == "finishBuff" then
		self:remove();
	end
end

function VBattleBuffSprite:remove( )
	if self.armature then
		self.armature:Delete();
		self.armature = nil;
	end
end

-- 通用增益buff
---------------------------------------  BattleUsefulBuffSprite  ---------------------------------------
VBattleUsefulBuffSprite = vclass("BattleUsefulBuffSprite", VBattleBuffSprite)

function VBattleUsefulBuffSprite:initialize( targetSprite )
	self.armatureName = "UsefulBuff";
	VBattleBuffSprite.createDownBuffSprite(self, targetSprite);
	VBattleBuffSprite.setFrameEvent(self);
end

-- 通用减益buff
---------------------------------------  BattleUselessBuffSprite  ---------------------------------------
VBattleUselessBuffSprite = vclass("BattleUselessBuffSprite", VBattleBuffSprite)

function VBattleUselessBuffSprite:initialize( targetSprite )
	self.armatureName = "UselessBuff";
	VBattleBuffSprite.createDownBuffSprite(self, targetSprite);
	VBattleBuffSprite.setFrameEvent(self);
end

-- 眩晕buff
---------------------------------------  BattleDizzinessBuffSprite  ---------------------------------------
VBattleDizzinessBuffSprite = vclass("BattleDizzinessBuffSprite", VBattleBuffSprite)

function VBattleDizzinessBuffSprite:initialize( targetSprite )
	self.armatureName = "DizzinessBuff";
	VBattleBuffSprite.createUpBuffSprite(self, targetSprite);
end

-- 彼岸菊 Debuff
---------------------------------------  BattleOtherShoreBuffSprite  ---------------------------------------
VBattleOtherShoreBuffSprite = vclass("BattleOtherShoreBuffSprite", VBattleBuffSprite)

function VBattleOtherShoreBuffSprite:initialize( targetSprite )
	self.armatureName = "OtherShoreBuff";
	VBattleBuffSprite.createDownBuffSprite(self, targetSprite);
	VBattleBuffSprite.setFrameEvent(self);
end

-- 血腥海棠 Debuff
---------------------------------------  BattleBloodyBuffSprite  ---------------------------------------
VBattleBloodyBuffSprite = vclass("BattleBloodyBuffSprite", VBattleBuffSprite)

function VBattleBloodyBuffSprite:initialize( targetSprite )
	self.armatureName = "BloodyBuff";
	VBattleBuffSprite.createUpBuffSprite(self, targetSprite);
	VBattleBuffSprite.setFrameEvent(self);
end

function VBattleBloodyBuffSprite:setBuffScale( targetSprite )
	self.scale = 1.5;
end

-- 萨满菊花 Debuff
---------------------------------------  BattleShamanMumBuffSprite  ---------------------------------------
VBattleShamanMumBuffSprite = vclass("BattleShamanMumBuffSprite", VBattleBuffSprite)

function VBattleShamanMumBuffSprite:initialize( targetSprite )
	self.armatureName = "ShamanMumBuff";
	VBattleBuffSprite.createDownBuffSprite(self, targetSprite);
	self.armature:play("show");	
end

function VBattleShamanMumBuffSprite:setBuffScale( targetSprite )
	self.scale = 1;
	self.scale = self.scale * (1 / targetSprite.armature.scale);
end
