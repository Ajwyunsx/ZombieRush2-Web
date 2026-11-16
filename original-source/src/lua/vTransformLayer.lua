--vTransformLayer.lua

VTransformLayer = VClass("TransformLayer", VLayer)

-- function VTransformLayer:onCreate(attr)
-- 	return gWindow:Push(VLayer{layout="Center", size={800,480}, level=200, touch=1, visible=0});
-- end

function VTransformLayer:Init(attr)
	VLayer.Init(self, attr);
	self.level = 200;
	self.touch = true;
end

function VTransformLayer:addCloudImage( )
	self.fillLayer = self:Push(VLayer{size={800,480}, fill={1,1}, layout="Center", visible=0});

	local layerSize = self.fillLayer:getContentSize();
	local scaleX = layerSize.width / 800;
	local scaleY = layerSize.height / 450;
	local finalScale = math.max(scaleX, scaleY);
	finalScale = math.max(finalScale, 1);

	self.leftCloud = self.fillLayer:Push(VImage{name="leftCloud", image="qieping-5.png", scale=finalScale, layout="Center", step={-0.357,0}});
	self:setActionPos(self.leftCloud, -layerSize.width);
	self.rightCloud = self.fillLayer:Push(VImage{name="rightCloud", image="qieping-4.png", scale=finalScale, layout="Center", step={0.285,0}});
	self:setActionPos(self.rightCloud, layerSize.width);
	self.plantLeftHand = self.fillLayer:Push(VImage{name="plantLeftHand", image="qieping-3.png", relative="leftCloud", layout="Right", scale=finalScale, step={0.69, 0.2}});
	self:setActionPos(self.plantLeftHand, -layerSize.width);
	self.zombieRightHand = self.fillLayer:Push(VImage{name="zombieRightHand", image="qieping-1.png", relative="rightCloud", layout="Left", scale=finalScale, step={1.26, 0.12}});
	self:setActionPos(self.zombieRightHand, layerSize.width);
	self.zombieLeftHand = self.fillLayer:Push(VImage{name="zombieLeftHand", image="qieping-2.png", relative="rightCloud", layout="Left", scale=finalScale, step={-0.04, 0.44}, visible=0});
	self:setActionPos(self.zombieLeftHand, layerSize.width);

	self.actionNodeList = {self.leftCloud, self.rightCloud, self.plantLeftHand, self.zombieRightHand};
end

function VTransformLayer:setActionPos( node, width )
	node.startX = node:getPositionX();
	node.startY = node:getPositionY();
	node.endX = node:getPositionX() + width*0.7;
end

function VTransformLayer:openCloud( node, func )
	if self.leftCloud == nil or self.rightCloud == nil then
		self:addCloudImage();
	end
	
	self:RunAction{{"delayTime", 0.7}, {"hide"}, {"@VCallBack", node, func}};
	for i,actionNode in ipairs(self.actionNodeList) do
		actionNode:RunAction{{"delayTime", 0.1}, {"moveTo", 0.5, actionNode.endX, actionNode.startY}};
	end
	self.fillLayer:RunAction{{"show"}};

	self.zombieLeftHand:stopAllActions();
	self.zombieLeftHand:RunAction{{"delayTime", 0.05}, {"hide"}};
end

function VTransformLayer:closeCloud( node, func )
	if self.leftCloud == nil or self.rightCloud == nil then
		self:addCloudImage();
	end

	self:RunAction{{"show"}, {"delayTime", 0.7}, {"@VCallBack", node, func}};
	for i,actionNode in ipairs(self.actionNodeList) do
		actionNode:RunAction{{"moveTo", 0, actionNode.endX, actionNode.startY}, {"moveTo", 0.5, actionNode.startX, actionNode.startY}};
	end
	self.fillLayer:RunAction{{"delayTime", 0.05}, {"show"}};
	
	self.zombieLeftHand:stopAllActions();
	self.zombieLeftHand:RunAction{{"hide"}, {"delayTime", 0.5}, {"show"}};
end

function VTransformLayer:isRunAction( )
	if self.leftCloud:HasAction() or self.rightCloud:HasAction() then
		return true;
	else
		return false;
	end
end