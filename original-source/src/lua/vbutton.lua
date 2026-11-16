--vbutton.lua

_VButtonState = {
    normal = 1,
    highlighted = 2,
    selected = 3,
}
VButton = VClass("Button", VNode)

function VButton:Init(attr)
    if attr.image then--底图
        if attr.size then
            self.scaleImage = VImage9{layout="Center", image=attr.image};
        else
            self.scaleImage = VImage{layout="Center", image=attr.image};
        end
        self:Push(self.scaleImage);
    end
    if attr.topImage then--顶图
        self.imgTop = VImage{layout="Center", image=attr.topImage};
        self:Push(self.imgTop);
    end
    if attr.text then--文本
        self.label = VText{layout="Center", text=attr.text};
        self:Push(self.label);
    end

    VButton.super.Init(self, attr);
    if not attr.touch then self.touch = true end;
    if not attr.fscale then self.fscale = 0.9 end;
    if not attr.move then self.move = true end;
    self.anchor = cc.p(0.5, 0.5);

    if self.scaleImage and not attr.size then
        self.size = self.scaleImage.size;
    end

    if not attr.image and not attr.size then self.fill = {-1,-1} end;

    self:setButtonState(_VButtonState.normal);
end

function VButton:setButtonState(state)
    if self.ButtonState == state then return end;
    self.ButtonState = state;

    if self.ButtonState == _VButtonState.normal then
        if self.image then
            self:changeImage(self.image);
        elseif self.normalImage then
            self:changeImage(self.normalImage);
        end
        if self.text then
            self.label.text = self.text;
        end
    elseif self.ButtonState == _VButtonState.highlighted then
        if self.focusImage then
            self:changeImage(self.focusImage);
        end
        if self.focusText then
            self.label.text = self.focusText;
        end
    end
end

function VButton:on_topImage(image)
    if not image then
        self.imgTop.visible = 0;
    else
        self.imgTop.visible = 1;
    end
    self.imgTop.image = image;
end

function VButton:on_image(image)
    self:changeImage(image);
end

function VButton:changeImage(image)
    --修正不兼容vui中未设定image属性报错的bug
    self.scaleImage.image = image;
    -- if not self.scaleImage then
    --    if self.size then
    --         self.scaleImage = VImage9{layout="Center", image=img};
    --     else
    --         self.scaleImage = VImage{layout="Center", image=img};
    --     end
    --     self:Push(self.scaleImage);
    -- else
    --     self.scaleImage.image = img;
    -- end
    if self.gray then self.gray = self.gray; end
end

function VButton:on_flipX(flipX)
    self.scaleImage.flipX = flipX;
end

function VButton:on_flipY(flipY)
    self.scaleImage.flipY = flipY;
end

function VButton:on_size(size)
    self.scaleImage.size = size;
end

function VButton:on_color(color)
    self.scaleImage.color = color;
end

function VButton:sizeChange()
    self.label:DoSizeChange();
    self:ReLayout();
end

function VButton:on_text(text)
    if text and text ~= "" then
        self.label.text = text;
        self.label.visible = 1;
        self:sizeChange();
    else
        if self.label then
            self.label.visible = 0;
        end
    end
end

function VButton:on_fontSize(fontSize)
    self.label.fontSize = fontSize;
    self:sizeChange();
end

function VButton:on_font(font)
    self.label.font = font;
    self:sizeChange();
end

function VButton:on_textColor(color)
    self.label.color = color;
end

function VButton:on_textOffset(offset)
    self.label.offset = offset;
end

function VButton:on_shadow(size)
    self.label.shadow = size;
end

function VButton:on_outline(size)
    self.label.outline = size;
end

function VButton:on_glow(glow)
    self.label.glow = glow;
end

function VButton:on_effectColor(color)
    self.label.effectColor = color;
end

function VButton:onTouchBase(touch)
    if self.tableView then--确保tableview中的按钮，只响应在tableview中的touch事件
        if not self.tableView:IsInRect(touch) then
            return false;
        end
    end
    VButton.super.onTouchBase(self, touch);
    self:setButtonState(_VButtonState.highlighted);
    self.pressCount = 0;
    self:StartTimer("buttonPressed");
end

--长按处理
function VButton:buttonPressed(dt)
    self.pressCount = self.pressCount + 1;
    local step = 10 - math.modf(self.pressCount/5);
    if step<=1 or self.pressCount%step == 0 then
        if self.onRepeat then
            local func = VUiCheckFunction(self, "onRepeat");
            if func and func(self, touch, self:getView()) then
                return;
            end
        end
    end
end

function VButton:onMoveBase(touch)
    VButton.super.onMoveBase(self, touch);
    if self:IsInRect(touch) then
        self.isTouchMovedIn = true;
        if self.ButtonState ~= _VButtonState.highlighted then
            self:onFscaleTouch();
            self:StartTimer("buttonPressed");
        end
        self:setButtonState(_VButtonState.highlighted);
    else
        self.isTouchMovedIn = false;
        if self.ButtonState ~= _VButtonState.normal then
            self:onFscaleLeave();
            self:StopTimer("buttonPressed");
        end
        self:setButtonState(_VButtonState.normal);
    end
end

function VButton:onLeaveBase(touch)
    self:setButtonState(_VButtonState.normal);
    self:StopTimer("buttonPressed");
    VButton.super.onLeaveBase(self, touch);
    self.isTouchMovedIn = false;
end

function VButton:onClickAudio()
    if self.audioEffect then
        gAudio:playEffect(self.audioEffect);
    else
        gAudio:playEffect("sys_common.ogg");
    end
end

function VButton:setEnable(enable)
    if enable then
        self.gray = 0;
        self.touch = 1;
    else
        self.gray = 1;
        self.touch = 0;
    end
end