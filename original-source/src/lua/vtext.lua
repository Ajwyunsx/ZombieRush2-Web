--vtext.lua

_VTextFontType = {
    system = 1,
    ttf = 2,
    bmp = 3
}

_VTextAlign = VEnum{
    Left = 0,
    Top = 0,

    Center = 1,

    Right = 2,
    Bottom = 2,
}

VText = VClass("Text", VNode)
function VText:onCreate(attr)
    return cc.Label:create();
end

function VText:Init(attr)
    if not attr.font then self.font = "Arial" end;
    VText.super.Init(self, attr);
    if not attr.text then
        self.text = "" 
    else
        if self.format then
            local sn = tonumber(text);
            if sn and sn > 100000 then
                sn = math.modf(sn/10000);
                text = tostring(sn).."万";
            end
        end
    end
    if not attr.fontSize then self.fontSize = 25 end;
    if not attr.alignV then self.alignV = "Center" end;
end

function VText:on_text(text)
    if self.format then
        local sn = tonumber(text);
        if sn and sn > 100000 then
            sn = math.modf(sn/10000);
            text = tostring(sn).."万";
        end
    end
    self:setString(text);
    self:NeedReLayout();
end

function VText:on_font(font)
    if string.find(font, ".ttf") then
        self.fontType = _VTextFontType.ttf;
    elseif string.find(font, ".fnt") then
        self.fontType = _VTextFontType.bmp;
    else
        self.fontType = _VTextFontType.system;
    end

    if self.fontType == _VTextFontType.ttf then
        local ttfConfig = {};
        ttfConfig.fontFilePath = font;
        ttfConfig.fontSize = self.fontSize;
        ttfConfig.glyphs = 0;
        self:setTTFConfig(ttfConfig);
    elseif self.fontType == _VTextFontType.bmp then
        self:setBMFontFilePath(font);
    elseif self.fontType == _VTextFontType.system then
        self:setSystemFontName(font);
    end
    self:NeedReLayout();
end

function VText:on_fontSize(fontSize)
    if self.fontType == _VTextFontType.ttf then
        local ttfConfig = self:getTTFConfig();
        if ttfConfig then
            ttfConfig.fontSize = fontSize;
            self:setTTFConfig(ttfConfig);
        end
    elseif self.fontType == _VTextFontType.bmp then
    elseif self.fontType == _VTextFontType.system then
        if type(fontSize) == "string" then
            self:setSystemFontSize(FontSize[fontSize]);
        else
            self:setSystemFontSize(fontSize);
        end
    end
    self:NeedReLayout();
end

function VText:on_color(color)
    if type(color) == "string" then
        -- self:setTextColor(FontColor.fc_qianzong);
        -- self:updateDisplayedColor(Var{134, 0, 48});
        self:setColor(FontColor[color]);
    -- else
        -- self:setTextColor(color);
        -- self:updateDisplayedColor(color);
        -- self:setColor(color);
    end
    -- self:setCascadeColorEnabled(true);
    self:NeedReLayout();
end

function VText:on_size(size)
    self:setDimensions(size.width, size.height);
    self:NeedReLayout();
end

function VText:on_align(alignment)
    self:setHorizontalAlignment(_VTextAlign(alignment));
    self:NeedReLayout();
end

function VText:on_alignV(alignment)
    self:setVerticalAlignment(_VTextAlign(alignment));
    self:NeedReLayout();
end

function VText:on_shadow(size)
    local color = Var{0,0,0};
    if self.effectColor then color = self.effectColor end;
    self:enableShadow(color, size);
    self:NeedReLayout();
end

function VText:on_outline(size)
    local color = Var{0,0,0};
    if self.effectColor then color = self.effectColor end;
    self:enableOutline(color, size);
    self:NeedReLayout();
end

function VText:on_glow(glow)
    local color = Var{0,0,0};
    if self.effectColor then color = self.effectColor end;
    local ttfConfig = self:getTTFConfig();
    if ttfConfig then
        ttfConfig.distanceFieldEnabled = true;
        self:setTTFConfig(ttfConfig);
    end
    self:enableGlow(color);
    self:NeedReLayout();
end

function VText:on_effectColor(color)
    if self.shadow then
        self:enableShadow(color, self.shadow);
    elseif self.outline then
        self:enableOutline(color, self.outline);
    elseif self.glow then
        self:enableGlow(color);
    end
    self:NeedReLayout();
end

-----------  刷新数字文本动画  -----------
function VText:changeNumAnimation( num )
    if num == tonumber(self:getString()) then
        return;
    end

    local runTimes = 20;
    local actionTime = 1;
    self.finalNum = num;

    local dif = self.finalNum - tonumber(self:getString());
    if math.abs(dif) < runTimes then
        runTimes = math.abs(dif);
    end

    local pTime = actionTime / runTimes;
    local pDif = math.floor(dif / runTimes);

    if runTimes > 1 then
        runTimes = runTimes - 1;
    end
    self:updateNumAnimation(runTimes, pTime, pDif);
end

function VText:updateNumAnimation( runTimes, pTime, pDif )
    if runTimes == 1 then
        self:setString(self.finalNum);
    else
        self:setString(tonumber(self:getString()) + pDif);
    end

    runTimes = runTimes - 1;
    if runTimes > 0 then
        self:RunAction{{"delayTime", pTime}, {"@updateNumAnimation", runTimes, pTime, pDif}};
    end
    self:NeedReLayout();
end
-----------  刷新数字文本动画 End  -----------