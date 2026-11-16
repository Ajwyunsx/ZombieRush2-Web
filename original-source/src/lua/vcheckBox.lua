--vcheckBox.lua

VCheckBox = VClass("CheckBox", VButton)

function VCheckBox:setSelected(isSelected)
	self.selected = isSelected;

	if self.selected then
		if self.selectedImage then
            self:changeImage(self.selectedImage);
        end
        if self.selectedText then
            self.label.text = self.selectedText;
        end
	else
		if self.image then
            self:changeImage(self.image);
        elseif self.normalImage then
            self:changeImage(self.normalImage);
        end
        if self.text then
            self.label.text = self.text;
        end
	end
end

function VCheckBox:onTouchBase(touch)
    VButton.super.onTouchBase(self, touch);
    self:setButtonState(_VButtonState.highlighted);
end

function VCheckBox:onMoveBase(touch)
    VButton.super.onMoveBase(self, touch);
    if self:IsInRect(touch) then
        if self.ButtonState ~= _VButtonState.highlighted then
            self:onFscaleTouch();
        end
        self:setButtonState(_VButtonState.highlighted);
    else
        if self.ButtonState ~= _VButtonState.normal then
            self:onFscaleLeave();
        end
        self:setButtonState(_VButtonState.normal);
        self:setSelected(self.selected);
    end
end

function VCheckBox:onLeaveBase(touch)
	self:setButtonState(_VButtonState.normal);
	if self:IsInRect(touch) then
		if self.selected then
			self:setSelected(false);
		else
			self:setSelected(true);
		end
	else
		self:setSelected(self.selected);
	end

    VButton.super.onLeaveBase(self, touch);
end