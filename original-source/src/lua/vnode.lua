--vnode.lua

function VUiCreate(attr)
    local class = _G["V"..attr.class];
    if class then
        return class:new(attr);
    end
    gLog("[LUA ERROR]VUiCreate(%s) not find!", attr.class);
end
function VUiCheckFunction(t, k)
    local func = t[k];
    if type(func) == "string" then
        func = "return function(node,touch,view) "..func.." end";
        func = loadstring(func)();
        t[k] = func;
    end
    return func;
end
function VUiOnNodeDelete() end
function VUiOnTouchEvent(name, node, touch)
    local func = VUiCheckFunction(node, name);
    if func and func(node, touch, node:getView()) then
        return
    end
    if node:IsValid() then
        return node[name.."Base"](node, touch)
    end
end
function VUiActionCallBack( node, func, ... )
    if type(func) == "string" then
        if node[func] then
            node[func](node, ...)
        elseif _G[func] then
            _G[func](...);
        end
    else
        func(...);
    end
end

function VUiIsInRect(node, touch)
    if node["IsInRectLua"] then
        return node["IsInRectLua"](node, touch);
    end
    return;
end
function VUiOnEnter(node)
    node:onPushBase()
end
function VUiOnExit( node )
    node:onPopBase()
end

function VUiOnKeyBack(node)
    node:onKeyBack();
end
function VUiOnKeyMenu(node)
    node:onKeyMenu();
end
function VUiOnBackground()
    if gWindow then
        gWindow:onBackground()
    end
end
function VUiOnForeground()
    if gWindow then
        gWindow:onForeground()
    end
end
function VUiOnTimer(node, name, dt)
    node[name](node, dt);
end

function _VNode__index(t, k)
    local v = t.this[k] or t.self[k];
    if not v then
        v = t._vnode["Get_"..k];
        if v then
            return v(t._vnode)
        end
        v = t._vnode[k];
        if v then
            local func = function(self,...) return v(self._vnode,...); end
            t.this[k] = func;
            return func;
        end
        v = t._node[k];
        if v then
            local func = function(self,...) return v(self._node,...); end
            t.this[k] = func;
            return func;
        end
    end
    return v;
end
function _VNode__newindex(t, k, v)
    local func = t._vnode["Set_"..k];
    if func then
        func(t._vnode, v);
    else
        t.this[k] = v;
    end
    func = t.self["on_"..k];
    if func then
        func(t, v)
    end
end
function _VClass__call(t, attr)
    attr = attr or {}
    if type(attr) == "table" then
        if attr._cobj then
            if attr._vnode then
                return attr;
            end
        elseif not attr.class then
            attr.class = attr[1] and attr[1].class or t.class;
            attr[1] = nil;
        end
    elseif type(attr) == "userdata" and attr.This then
        local vnode = attr:This();
        return vnode and _vclass_mapping_[vnode:Id()];
    end
    local id = cc.VBuilder:FromAttr(attr);
    return _vclass_mapping_[id];
end
function _VClass__index(t, k)
    local v;
    while t do
        v = rawget(t,k);
        if v then break; end
        t = t.super;
    end
    return v;
end
function VClass(name, super)
    local obj = _G["V"..name];
    if not obj then
        if super then
            obj = {super = super, class = name, ["is"..name] = true}
            setmetatable(obj, {__call = _VClass__call,  __index = _VClass__index});
        else
            obj = setmetatable({class = name}, {__call = _VClass__call});
        end
        _G["V"..name] = obj;
    end
    return obj;
end

VNode = VClass("Node")
function VNode:new(attr)
    local node = {self = self, this = {}}
    local _vnode = cc.VNode:Create(attr);
    node._attr = _vnode:Attr();
    local _node = self.onCreate(node, node._attr);
    _vnode:SetNode(_node);
    node._node = _node;
    node._vnode = _vnode;
    node._cobj = _node;
    node._cid = _vnode:Id();
    node._name = attr.name;
    node.child = setmetatable({},{__index = function(_,k) return _vnode:Child(k) end});
    setmetatable(node, {__call = function(_,k) return _vnode:Child(k,1) end, __index = _VNode__index, __newindex = _VNode__newindex});
    _vclass_mapping_[node._cid] = node;
    node:InitNode()
    return node;
end
function VNode:IsValid()
    return _vclass_mapping_[self._cid] == self;
end
function VNode:onCreate(attr)
    return cc.Node:create();
end
function VNode:InitNode()
    self.onFscaleTouch = nop;
    self.onFscaleLeave = nop;
    self.onMoveTouchBegin = nop;
    self.onMoveTouchMove = nop;
    self.onMoveTouchLeave = nop;
    self:Init(self._attr);
end
function VNode:Init(attr)
    if attr.fit then attr.fit = _VLayout(attr.fit) end
    if attr.fill then attr.fill = _VLayout(attr.fill) end
    local iter = VDataIter()
	while attr:Travel(iter) do
        self[iter:Name()] = iter:Data();
	end
end
function VNode:Count()
    return self:getChildrenCount();
end
function VNode:getView()
    if self.isView then
        return self;
    end
    local parent = self:Parent();
    if parent then 
        return parent:getView();
    else
        return nil;        
    end
end
function VNode:getMsgBox()
    if self.isMsgBox then
        return self;
    end
    return self:Parent():getMsgBox();
end
function VNode:Push(param, func)
    node = VNode(param);
    if node then
        node.onPushFinish = func;
        self:addChild(node);
        node:ReLayout();
        return node;
    end
    cclog("Push(%s) err!", Var(param):ToString());
end
function VNode:Pop(cnt, func)
    if self:Count() > 0 then
        cnt = cnt or 1;
        if cnt < 0 then cnt = self:Count() + cnt end
        if cnt > 0 then
            for i=2,cnt do
                local node = self.child[-2];
                if node then
                    node:Delete();
                end
            end
            self(-1):doPop(func);
        end
    end
end
function VNode:doPop(func)
    self.onPopFinish = func;
    if self.popAction then
        if self.stopEventTime then self:StopEvent(self.stopEventTime); end
        self:RunAction{self.popAction,{"@onPopFinishBase"}};
        return true;
    end
    self:onPopFinishBase();
end
function VNode:onPopFinishBase()
    if self.stopEventTime then self:OpenEvent(); end
    self:Delete();
    if self.onPopFinish then self:onPopFinish() end
end
function VNode:onPushFinishBase()
    if self.onPushFinish then self:onPushFinish() end
end
function VNode:onPushBase()
    if self.isView then self:ReLayout(); end;
    if self.onPush then self:onPush() end
    if self.pushAction then
        if self.stopEventTime then self:StopEvent(self.stopEventTime); end
        self.visible = false;
        self:ReLayout();
        self:RunAction{self.pushAction,{"delayTime",0.1},{"@onPushFinishBase"}}
    else
        self:StartTimer("onPushFinishBase",0,0);
    end
end
function VNode:onPopBase()
    if self.onPop then self:onPop() end
end

function VNode:StopEvent(delay)
    self:getEventDispatcher():setEnabled(false);
    if delay then
        self:StartTimer("OpenEvent", delay, 0);
    end
end
function VNode:OpenEvent()
    self:getEventDispatcher():setEnabled(true);
end
function VNode:onKeyBack()
end
function VNode:onKeyMenu()
end
function VNode:onTouchesBase(touches)
end
function VNode:onMovesBase(touches)
end
function VNode:onLeavesBase(touches)
end
function VNode:onCancelsBase(touches)
end
function VNode:onTouchBase(touch)
    if self._cellIdx then
        if VNode._cellNode then
            return false;--避免tableViewCell里的按钮点击重叠
        end
        VNode._cellNode = self;
    end
    self:onFscaleTouch()
    self:onMoveTouchBegin(touch);
    self._winpos = self:getWinPos(-1);
end
function VNode:onMoveBase(touch)
    self:onMoveTouchMove(touch);
end
function VNode:onLeaveBase(touch)
    VNode._cellNode = nil;
    self:onFscaleLeave()
    self:onMoveTouchLeave(touch);

    if touch and self.onClick then
        local isTouched = false;
        if self.preScale and self.scale ~= self.preScale then
            if self.isTouchMovedIn then
                isTouched = true;
            end
        end

        if not isTouched and self:IsInRect(touch) then
            isTouched = true;
        end

        if isTouched then
            local pos = cc.pSub(self:getWinPos(-1), self._winpos or self:getWinPos(-1));
            local difPix = 3;
            if self.isMoveAction then
                difPix = 40;
            end
            if (math.abs(pos.y) < difPix and math.abs(pos.x) < difPix) then
                local func = VUiCheckFunction(self, "onClick");
                if func then
                    local aFunc = VUiCheckFunction(self, "onClickAudio");
                    if aFunc then
                        aFunc(self, touch);
                    end
                    func(self, touch, self:getView());
                end
            end
        end
    end
end

function VNode:onCancelBase(touch)
    self:onLeaveBase(touch);
end

function VNode:onMoveTouchBegin(touch)
    local touchBegin = self:getParent():convertTouchToNodeSpace(touch);
    self.touchOffset = cc.pSub(self.position, touchBegin);
    self._move_flag = false;
end

function VNode:onMoveTouchMove(touch)
    local location = self:getParent():convertTouchToNodeSpace(touch);
    self.position = cc.pAdd(location, self.touchOffset);
    self._move_flag = true;
end

function VNode:onMoveTouchLeave(touch)
    if self._move_flag then
        self:SaveOffset();
    end
end

function VNode:onFscaleTouch()
    if not self:HasAction(_VTags.fscale) then
        self.preScale = self.scale;
    end
    self:RunAction({"scaleTo",0.1,self.preScale*self.fscale}, _VTags.fscale);
end
function VNode:onFscaleLeave()
    self:RunAction({"scaleTo",0.1,self.preScale}, _VTags.fscale);
end
function VNode:on_fscale(f)
    local v = f == 1 and nop;
    self.onFscaleTouch = v;
    self.onFscaleLeave = v;
end
function VNode:on_touch(b)
    self:InitListener();
end
function VNode:on_drag(b)
    local v = not b or b == 0 and nop;
    self.onMoveTouchBegin = v;
    self.onMoveTouchMove = v;
    self.onMoveTouchLeave = v;
end

function VNode:Travel( func, bAll )
    for i=0,self:Count()-1 do
        local node = self(i);
        func(node);
        if bAll and node.Travel then
            node:Travel(func, true);
        end
    end
end

function VNode:widthToAction(targetWidth, time)
    if not targetWidth then return end;
    if not time then time = 1 end;

    local processLenth = math.abs(targetWidth-self.size.width);
    if targetWidth > self.size.width then
        self.widthAdd = 1;
    else
        self.widthAdd = -1;
    end
    local interval = time/processLenth;
    self:StartTimer("sizeToInterval", interval, processLenth);
end

function VNode:sizeToInterval()
    self.size = {self.size.width+self.widthAdd, self.size.height};
end

--shader 
function VNode:Set_outline(isOn, color, radius)
    local u_outlineColor = {};
    u_outlineColor.type = "vec3";
    if color then
        color[1] = color[1]/255;
        color[2] = color[2]/255;
        color[3] = color[3]/255;
        u_outlineColor.value = color;
    else
        u_outlineColor.value = {1.0, 0.2, 0.3};
    end

    local u_radius = {};
    u_radius.type = "float";
    u_radius.value = radius or 0.001;

    local u_threshold = {};
    u_threshold.type = "float";
    u_threshold.value = 1.75;

    local params = {};
    params.u_outlineColor = u_outlineColor;
    params.u_radius = u_radius;
    params.u_threshold = u_threshold;
    self:Set_Shader("Image_outline.fsh", "ShaderPositionTextureOutline", isOn, params);
end

function VNode:Set_bloom(isOn, brightness)
    if not gShaderInterface then
        self._vnode:Set_bloom(isOn, brightness);
    else
        local brightnessData = {};
        brightnessData.type = "float";
        brightnessData.value = brightness or 0.2;

        local params = {};
        params.brightness = brightnessData;
        self:Set_Shader("Image_bloom.fsh", "ShaderPositionTextureBloom", isOn, params);
    end
end

function VNode:Set_glow(isOn, color, radius, vThreshold)
    local glowColor = {};
    glowColor.type = "vec3";
    if color then
        color[1] = color[1]/255;
        color[2] = color[2]/255;
        color[3] = color[3]/255;
        glowColor.value = color;
    else
        glowColor.value = {1.0, 1.0, 1.0};
    end

    local blurRadius = {};
    blurRadius.type = "float";
    blurRadius.value = radius or 10.0;

    local threshold = {};
    threshold.type = "float";
    threshold.value = vThreshold or 2.0;    

    local resolution = {};
    resolution.type = "vec2";
    resolution.value = {0, 0};

    local params = {};
    params.glowColor = glowColor;
    params.blurRadius = blurRadius;
    params.resolution = resolution;
    params.threshold = threshold;
    self:Set_Shader("Image_glow.fsh", "ShaderPositionTextureGlow", isOn, params);
end

