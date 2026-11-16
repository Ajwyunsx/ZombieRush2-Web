-- vBattleThiefZombieSprite.lua

-- 黑暗阳光猎手（白）
---------------------------------------  BattleSunHunterZombieSprite  ---------------------------------------
VBattleSunHunterZombieSprite = vclass("BattleSunHunterZombieSprite", VBattleMonsterSprite)

function VBattleSunHunterZombieSprite:initialize( battleCreature )
	VBattleMonsterSprite.initialize(self, battleCreature);
end

function VBattleSunHunterZombieSprite:getShootPos( )
	return self.armature:getBonePos("shootNode");
end

function VBattleSunHunterZombieSprite:attackAnimation( )
	self.isAttacking = true;
	self.animationType = ECreatureAnimationType.ANIMATION_ATTACK;
	-- self.armature:stop();
	self.armature:play("attack", 0.1, 0);
end

-- 重伤
function VBattleSunHunterZombieSprite:halfLifeAnimation( )
	return;
end


-- 囚犯小偷（绿）
---------------------------------------  BattlePrisonerZombieSprite  ---------------------------------------
VBattlePrisonerZombieSprite = vclass("BattlePrisonerZombieSprite", VBattleSunHunterZombieSprite)

function VBattlePrisonerZombieSprite:initialize( battleCreature )
	VBattleSunHunterZombieSprite.initialize(self, battleCreature);
end

-- 混混小偷（蓝）
---------------------------------------  BattleGangsterZombieSprite  ---------------------------------------
VBattleGangsterZombieSprite = vclass("BattleGangsterZombieSprite", VBattleSunHunterZombieSprite)

function VBattleGangsterZombieSprite:initialize( battleCreature )
	VBattleSunHunterZombieSprite.initialize(self, battleCreature);
end

-- 重伤
function VBattleGangsterZombieSprite:halfLifeAnimation( )
	VBattleMonsterSprite:halfLifeAnimation(self);
end

-- 罗宾汉（紫）
---------------------------------------  BattleRobinHoodZombieSprite  ---------------------------------------
VBattleRobinHoodZombieSprite = vclass("BattleRobinHoodZombieSprite", VBattleSunHunterZombieSprite)

function VBattleRobinHoodZombieSprite:initialize( battleCreature )
	VBattleSunHunterZombieSprite.initialize(self, battleCreature);
end

function VBattleRobinHoodZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
end

-- 鬼面弓手（金）
---------------------------------------  BattleDeathZombieSprite  ---------------------------------------
VBattleDeathZombieSprite = vclass("BattleDeathZombieSprite", VBattleSunHunterZombieSprite)

function VBattleDeathZombieSprite:initialize( battleCreature )
	VBattleSunHunterZombieSprite.initialize(self, battleCreature);
end

function VBattleDeathZombieSprite:doSkill( battleCreature )
	VBattleMonsterSprite.doSkill(self, battleCreature);

	self.armature:play("skill", -1, 0);
	self.skillPos = battleCreature:GetPos();
end

function VBattleDeathZombieSprite:showArrowAnimation( )
	local num = math.floor(self.skillPos / 10);

	local timeList = {};
	local timeMap = {};
	for i=1,num*3 do
		table.insert(timeList, math.ceil(i / 2));
	end
	local count = num*3;
	for i=1,num*3 do
		local index = math.random(1, count);
		timeMap[i] = timeList[index];
		timeList[index] = timeList[count];
		count = count - 1;
	end

	local allTime = num*3 *0.1;
	local index = 1;
	local moveTime = 0.35;
	local lightLevel = (gBattleView.maxLevel - self.road) * 100;

	for i=1,num do
		for j=1, 3 do
			local arrowImg = gBattleView.battleLayer:Push(VImage{image="GhostArrowBullet.png", scale=self.armatureScale*1.8, level=lightLevel});
			local randomRotation = math.random(-88, -40);
			arrowImg:setRotation(randomRotation);

			local endPosX = (i * gBattleView.cellNum - gBattleView.cellNum/2 + (2-j)*math.random(2,4)) * gBattleView.cellMinPixW;
			local endPoxY = (self.road - 1) * gBattleView.cellPixH + math.random(-20, 20) * 0.1 * gBattleView.cellMinPixH;

			local startPosY = gBattleView:getContentSize().height + arrowImg:getContentSize().height;
			local distanceY = startPosY - endPoxY;
			local distanceX = distanceY / math.tan(math.rad(math.abs(randomRotation)));
			local startPosX = endPosX + distanceX;

			arrowImg:setAnchorPoint(cc.p(0,0.5));
			arrowImg:setPosition(startPosX, startPosY);

			local delay = (timeMap[index] - 1) * 0.12;
			arrowImg:RunAction{{"delayTime", delay}, {"moveTo", moveTime, endPosX, endPoxY}, {"delayTime", 0.5}, {"fadeTo", 0.8, 0}}; -- {"delayTime", allTime - delay}
			index = index + 1;
		end
	end
end
