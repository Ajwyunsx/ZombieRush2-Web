VClipNode = VClass("ClipNode", VNode);

function VClipNode:onCreate( attr )
    return cc.ClippingNode:create();
end


function VClipNode:Init( attr )
    --设定遮罩的模式true显示没有被遮起来的纹理   如果是false就显示遮罩起来的纹理  
    if not attr.inverted then attr.inverted=true end
    self:setInverted(attr.inverted);
    --设置遮罩图片的透明度取值范围
    self:setAlphaThreshold(0);

    self.stencilImg = VImage{name="stencilImg", image=attr.stencil};
    self:setStencil(self.stencilImg);
end


