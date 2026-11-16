--vshowtip.lua

VShowTip = VClass("ShowTip", VNode)

function VShowTip:Init(attr)
	VNode.Init(self, attr);
	self:NeedEvent(Eff_onEnter);
	self:setDelay(attr.delay);
end

function VShowTip:setDelay(delay)
	if not delay then delay = 1 end;
    if gWindow.needAction then
        self.pushAction = {{"scaleTo",0,0.3,0.5},{"show"},{"scaleTo",0.1,1.1,1.1},{"scaleTo",0.1,1.0,1.0},{"delayTime",delay},{"fadeTo",0.3,0},{"delete"}};
    end
end
