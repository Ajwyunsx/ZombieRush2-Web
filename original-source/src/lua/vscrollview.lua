--vscrollview.lua

VScrollView = VClass("ScrollView", VNode)

function VScrollView:onCreate(attr)
	local node = nil;
	if not attr.viewSize then
		local glView = gDtr:getOpenGLView();
		local frameSize = glView:getFrameSize()
		node = cc.ScrollView:create(cc.size(frameSize.width+40, frameSize.height));
		self.viewSize = cc.size(frameSize.width, frameSize.height);
	else
		node = cc.ScrollView:create(attr.viewSize);	
	end
	node:ignoreAnchorPointForPosition(false);
	return node;
end

function VScrollView:Init( attr )
	VNode.Init(self, attr);
	self:setNoBounce(true);
end