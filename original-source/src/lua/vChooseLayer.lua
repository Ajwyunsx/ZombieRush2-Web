VChooseLayer = VClass("ChooseLayer", VLayer)

function VChooseLayer:Init(attr)
	VLayer.Init(self, attr);
	self.armatureImage = nil;
	self.armature = nil;
	self:initAnim(attr);
end

function VChooseLayer:initAnim(attr)
	if attr.armatureImage then
		self.armatureImage = VImage{image=attr.armatureImage, layout="Down", scale=2}
		self:Push(self.armatureImage);
	end
end

function VChooseLayer:changeArmtureImage(image)
	if self.armatureImage then
		self.armatureImage.image = image;
	end
end

function VChooseLayer:showChoosedAnimation()
	self:closeChoosedAnimation();
	if not self.animationArrow then
		self.animationArrow = VImage{name = "imgArrow", layout = "Up", image = "xuanzhongjiantouda.png", offset={0,-80}};
		self:Push(self.animationArrow);
	end

	self.animationArrow:RunAction{"repeatForever", {"sequence", {"moveBy", 0.3, 0, 15}, {"moveBy", 0.3, 0, -15}}}
	self.animationArrow.visible = true;
	self:RunAction{{"scaleTo",0.1, self.fscale}, {"scaleTo",0.1, 1.0}};
	--金库木有骨骼动画
	if self.armature ~= nil then
		self.armature:RunAction{"repeat", -1, {"sequence", {"tintTo", 0.65, 150, 150, 150}, {"tintTo", 0.65, 255, 255, 255}}};
	end

	if self.armatureImage ~= nil then
		self.armatureImage:RunAction{"repeat", -1, {"sequence", {"tintTo", 0.65, 150, 150, 150}, {"tintTo", 0.65, 255, 255, 255}}};
	end
end

function VChooseLayer:closeChoosedAnimation()
	if self.animationArrow then
		self.animationArrow:stopAllActions();
		self.animationArrow:ReLayout();
		self.animationArrow.visible = false;
		--金库木有骨骼动画
		if self.armature ~= nil then
			self.armature:stopAllActions();
			self.armature.color = {255, 255, 255};
		end

		if self.armatureImage ~= nil then
			self.armatureImage:stopAllActions();
			self.armatureImage.color = {255, 255, 255};
		end
	end
end

function VChooseLayer:didChoosed()
		self:showChoosedAnimation();
end

function VChooseLayer:didUnChoose()
		self:closeChoosedAnimation();
end

function VChooseLayer:checkClick(touch)
	if self:IsInRect(touch) then
		local func = VUiCheckFunction(self, "onClick");
        if func then
            func(self, touch, self:getView());
            func = VUiCheckFunction(self, "onClickAudio");
            if func then
                func(self, touch);
            end
            return _VTouchType.Banner;
        end
	end
	return false;
end