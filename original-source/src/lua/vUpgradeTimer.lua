--vUpgradeTimer.lua

VUpgradeTimer = VClass("UpgradeTimer", VNode)

function VUpgradeTimer:Init(attr)
	self.textProgress = VTimeText{layout="Center", step={0,1}, auto=attr.auto, prefix="", effectColor={0,0,0}, outline=2};

	VNode.Init(self, attr);
	self:NeedEvent(Eff_onEnter);

	if attr.bgImage then
		self.imgBg = VImage{layout="Center", image=attr.bgImage};
		self:Push(self.imgBg);
	end

	if attr.image then
		self.imgProgress = VProgcessTimer{layout="Center", image=attr.image, type=1};
		self:Push(self.imgProgress);
	end

	self:Push(self.textProgress);
	self.leftTime = attr.leftTime;
	self.maxTime = attr.maxTime;
end

function VUpgradeTimer:onPush()
	
end

function VUpgradeTimer:on_auto(auto)
	self.textProgress.auto = auto;
end

function VUpgradeTimer:on_font(font)
	self.textProgress.font = font;
end

function VUpgradeTimer:on_fontSize(fontSize)
	self.textProgress.fontSize = fontSize
end

function VUpgradeTimer:on_fontColor(color)
	self.textProgress.color = color
end

function VUpgradeTimer:on_textStep(step)
	self.textProgress.step = step;
end

function VUpgradeTimer:setTimer(leftTime, maxTime)
	self.leftTime = leftTime;
	self.maxTime = maxTime;

	self.textProgress.time = self.leftTime;
	if self.leftTime and self.maxTime then
		local passTime = self.maxTime - self.leftTime;
		self.percent = passTime/self.maxTime * 100;
		if self.imgProgress then
			self.imgProgress.percentage = self.percent;
			if self.auto == 1 then
				self.imgProgress:IncreaseAction(self.leftTime, 100);
			end
		end
	end
end

function VUpgradeTimer:startTimer()
	self.textProgress:startCountDown();
	self.imgProgress:IncreaseAction(self.leftTime, 100);
end

function VUpgradeTimer:stopTimer()
	self.textProgress:stopCountDown();
	if self.imgProgress then
		self.imgProgress:StopIncreaseAction();
	end
end