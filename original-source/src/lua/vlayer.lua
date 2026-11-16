--vlayer.lua

VLayer = VClass("Layer", VNode)
function VLayer:onCreate(attr)
    local node = attr.color and cc.LayerColor:create(attr.color) or cc.Layer:create();
    node:ignoreAnchorPointForPosition(false)
    return node;
end

function VLayer:onClickAudio()
    if self.audioEffect then
        gAudio:playEffect(self.audioEffect);
    else
        gAudio:playEffect("sys_common.ogg");
    end
end
