-- 进度条属性
--percentage 	必填，进度条初始进度，取值范围0-100
--type 			必填，进度条类型，0为时钟旋转进度条，1为横向进度条
--direction 	必填，进度条方向，0为正常方向，1为逆向



VProgcessTimer = VClass("ProgcessTimer", VNode)

function VProgcessTimer:onCreate(attr)
	local sprite = cc.Sprite:create(attr.image);
	local node = cc.ProgressTimer:create(sprite);
    return node;
end

function VProgcessTimer:Init(attr)
	VProgcessTimer.super.Init(self, attr);
	self:setType(self.type);
	self:setReverseDirection(self.direction);
	if self.type == 1 then
		self:setMidpoint(cc.p(0,0.5));
		self:setBarChangeRate((cc.p(1,0)));
	elseif self.type == 0 then
	end
	self:setPercentage(0);
	self:setPercentage(self.percentage);
end

function VProgcessTimer:on_percentage(percentage)
	if percentage then
		self:setPercentage(percentage);
	end
end

--进度条增长动画
--time 动画用时
--toPercentage 目标进度值(0-100)
--node 回调的node，当node没有传参时，不进行回调
--callback 回调的方法
function VProgcessTimer:IncreaseAction(time,toPercentage,node,callback)
	self:stopAllActions();
	self.percentage = self:getPercentage();
	self.toPercentage = toPercentage;
	self.oneStep = (self.toPercentage - self.percentage)/(time*12);

	self:RunAction{{"repeat",time*12,{{"delayTime",1/12},{"@IncreaseStep"}}},{node,callback}};
end

function VProgcessTimer:IncreaseStep( )
    self.percentage = self.percentage + self.oneStep;
end	

function VProgcessTimer:StopIncreaseAction()
	self:stopAllActions();
end