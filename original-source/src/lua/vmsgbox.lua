--vmsgbox.lua

VMsgBox = VClass("MsgBox", VNode)

function VMsgBox:onCreate(attr)
    if not attr.color then attr.color = {0,0,0,205} end
    return VLayer.onCreate(self, attr);
end

function VMsgBox:Init(attr)
    VNode.Init(self, attr);
    if not attr.size then self.size = {800,450}; end
    if not attr.fill then self.fill = _VLayout.Full; end
    if not attr.touch then self.touch = true end
    self:NeedEvent(Eff_onEnter+Eff_onExit);
    if gWindow.needAction then
        self.pushAction = {{"hide"},{"scaleTo", 0, 0, 0},{"show"},{"@pushActionOpacity", 0},{"scaleTo", 0.1, 1, 1},{"@pushActionOpacity", 205}};

        --{{"fadeTo",0,0},{"scaleTo",0,0.2},{"show"},{"scaleTo",0.15,1.2},{"spawn",{"fadeTo",0.1,self.opacity},{"scaleTo",0.1,1.0}}};
        -- self.popAction = {{"fadeTo",0.1,0},{"scaleTo",0.1,0.8}};
        self.stopEventTime = 0.3;
    end
end

function VMsgBox:pushActionOpacity( opacity )
    self:setOpacity(opacity);
end



function VMsgBox:onClick()
	-- gView():Pop();
    self:doPop();
end

function VMsgBox:onShow()

end

function VMsgBox:onPopBase()
    if self.onPop then self:onPop() end
    local last = gView(-2);
    if last and last.isMsgBox then
        last:onShow();
    end
end

function VMsgBox:onPopFinish()
    local last = gView(-2);
    if last and last.isMsgBox then
    else
        gView():onShow();
    end
end
