--vimage9.lua

VImage9 = VClass("Image9", VNode)

function VImage9:onCreate(attr)
    return cc.Scale9Sprite:create();
end

function VImage9:on_image(image)
    self:changeImage(image);
    self:DoSizeChange();
end

function VImage9:on_size(size)
	self.scaleSize = size;
end

function VImage9:changeImage(image)
	local pFrame = gRes:SpriteFrame(image);
	local batchNode = nil;
	
	if pFrame then
		batchNode = cc.SpriteBatchNode:createWithTexture(pFrame:getTexture(), 9);
		self:updateWithBatchNode(batchNode, pFrame:getRect(), pFrame:isRotated(), cc.rectZero());
	else
		batchNode = cc.SpriteBatchNode:create(image, 9);
		self:updateWithBatchNode(batchNode, cc.rectZero(), false, cc.rectZero());
	end

	if self.scaleSize then
		self.size = self.scaleSize;
	end
end

function VImage9:on_capInset(rect)
	self:setCapInsets(cc.rect(rect.x, rect.y, rect.width, rect.height));
end

function VImage9:onClickAudio()
    if self.audioEffect then
        gAudio:playEffect(self.audioEffect);
    else
        gAudio:playEffect("sys_common.ogg");
    end
end

function VImage9:setEnable(enable)
	if enable then
        self.gray = 0;
        self.touch = 1;
    else
        self.gray = 1;
        self.touch = 0;
    end
end