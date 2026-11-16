--edit.lua

function vreload()
    VUiSetNodeAttr = nil;
    VUiOnNodeDelete = nil;
    VView.onPushFinishBase = nil;
	vLuaFlush(true);
    if gEditMode then
    	function VUiSetNodeAttr(node, name, value)
    		node[name] = value;
    		node._attr[name] = value;
    	end
	   	function VUiOnNodeDelete(node)
    		if gPreTouchNode == node then gPreTouchNode = nil; end
    		if gCurrTouchNode == node then gCurrTouchNode = nil; end
    	end
        function VUiOnTouchEvent(name, node, touch)
            node[name.."Base"](node, touch)
        end
     	function VView:onPushFinishBase()
		    if self.onPushFinish then self:onPushFinish() end
		    if edit_SceneChanged then edit_SceneChanged() end
		end
		function VView:onPopFinishBase()
		    if self.stopEventTime then self:OpenEvent(); end
		    self:Delete();
		    if self.onPopFinish then self:onPopFinish() end
		    if edit_SceneChanged then edit_SceneChanged() end
		end
		function edit_SetToTouch( node )
			if node ~= gCurrTouchNode then
		    	gPreTouchNode = gCurrTouchNode;
		    	gCurrTouchNode = node;
		    end
		end
		function VNode:onTouchBase(touch)
		    local touchBegin = self:getParent():convertTouchToNodeSpace(touch);
		    self.touchOffset = cc.pSub(self.position, touchBegin);
		    if self ~= gCurrTouchNode then
		    	edit_SetToTouch(self);
		    	if edit_ControlSelected then edit_ControlSelected(self._vnode); end
		    end
		    self._move_flag = false;
		    self._touch_flag = true;
		end
		function VNode:onMoveBase(touch)
		    local location = self:getParent():convertTouchToNodeSpace(touch);
		    self.position = cc.pAdd(location, self.touchOffset);
		    self._move_flag = true;
		end
		function VNode:onLeaveBase(touch)
		    if self._move_flag then
		    	self:SaveOffset();
		    	if edit_ControlChanged then edit_ControlChanged(self._vnode) end
		    end
		    self._touch_flag = false;
		end
        function VNode:SaveToData(data)
        	local deal;
        	local cnt = self:Count();
        	for i=1,cnt do
        		local node = self(i-1);
        		if node and node.isVUi then
        			if i == 1 then
        				data = data or Var();
        				data:Append(self._attr);
        				deal = data:Get(-1);
        			end
        			node:SaveToData(data:Item(-1));
        		end
        	end
        	if not deal then
        		data:Append(self._attr);
        		deal = data:Get(-1);
        	end
        	if deal then
        		deal:Insert(0, deal.class, deal.name);
        		deal:Remove("class");
        		deal:Remove("name");
        		deal:Remove("isVUi");
        		_ChangeToLayoutName(deal, "fit");
        		_ChangeToLayoutName(deal, "fill");
        	end
        	return data;
        end
		function edit_DrawNode()
			if gPreTouchNode and gPreTouchNode:IsValid() then
				gPreTouchNode:DrawRect(1);
			end
			if gCurrTouchNode and gCurrTouchNode:IsValid() then
				gCurrTouchNode:DrawRect(gCurrTouchNode._touch_flag and 2 or 0);
			end
		end
	end
	local name = gView() and gView().name;
	if name then
		name = "v"..name..".vui";
		gWindow:Replace(name);
	end
end
function _ChangeToLayoutName( attr, key )
	if attr[key] then
		local s = _VLayout(gFormat("%d,%d", attr[key].x, attr[key].y));
		if s then
			attr[key] = s;
		end
	end
end
function vedit_Layout(layout)
	if gCurrTouchNode and gCurrTouchNode:IsValid() then
		local attr = gCurrTouchNode._attr;
		attr:Remove("offset");
		attr:Remove("step");
		attr:Remove("offsetP");
		attr:Remove("place");
		gCurrTouchNode.layout = layout;
		if gPreTouchNode and gPreTouchNode:IsValid() and
		   gPreTouchNode ~= gCurrTouchNode:Parent() and
		   gCurrTouchNode.relative ~= gPreTouchNode.name then
			gCurrTouchNode.relative = gPreTouchNode.name;
		else
			attr:Remove("relative");
		end
		if edit_ControlChanged then edit_ControlChanged(gCurrTouchNode._vnode) end
	end
end
function vedit_LayoutPos(name, x, y)
	if gCurrTouchNode and gCurrTouchNode:IsValid() then
		if name == "offset" then
			gCurrTouchNode:SaveOffset();
		end
		local attr = gCurrTouchNode[name];
		gCurrTouchNode[name] = attr and {attr.x+x, attr.y+y} or {x,y};
		if edit_ControlChanged then edit_ControlChanged(gCurrTouchNode._vnode) end
	end
end
_VEditLayout = VEnum{
	DownLeftOut = "LeftDownOut",
	DownRightOut = "RightDownOut",
	LeftDownOut = "DownLeftOut",
	RightDownOut = "DownRightOut",
	UpLeftOut = "LeftUpOut",
	UpRightOut = "RightUpOut",
	LeftUpOut = "UpLeftOut",
	RightUpOut = "UpRightOut",
}
vedit_func = {
	[27] = function() gWindow:onKeyBack(); end,
	[32] = function() vreload(); end,
	[96] = function()
		local layout = gCurrTouchNode.layout;
		if string.sub(layout,-3) ~= "Out" then
			if layout ~= "Center" then
				gCurrTouchNode.layout = layout.."Out";
			end
		else
			gCurrTouchNode.layout = _VEditLayout(layout) or layout;
		end
		if edit_ControlChanged then edit_ControlChanged(gCurrTouchNode._vnode) end
	end,
	[33] = function() vedit_LayoutPos("step", 0, -1) end,
	[34] = function() vedit_LayoutPos("step", 0, 1) end,
	[35] = function() vedit_LayoutPos("step", 1, 0) end,
	[36] = function() vedit_LayoutPos("step", -1, 0) end,
	[37] = function() vedit_LayoutPos("offset", -1, 0) end,
	[38] = function() vedit_LayoutPos("offset", 0, -1) end,
	[39] = function() vedit_LayoutPos("offset", 1, 0) end,
	[40] = function() vedit_LayoutPos("offset", 0, 1) end,
	['a'] = function() vedit_Layout("DownLeft") end,
	['b'] = function() vedit_Layout("Down") end,
	['c'] = function() vedit_Layout("DownRight") end,
	['d'] = function() vedit_Layout("Left") end,
	['e'] = function() vedit_Layout("Center") end,
	['f'] = function() vedit_Layout("Right") end,
	['g'] = function() vedit_Layout("UpLeft") end,
	['h'] = function() vedit_Layout("Up") end,
	['i'] = function() vedit_Layout("UpRight") end,
	['S'] = function()
		if gView().name ~= "temp" then
			local data = gView():SaveToData();
			local path = gView()._attr.saveFilePath or gRes:FilePath("v"..gView().name..".vui");
			data:SaveFile(path, true);
		elseif edit_SaveFile then
			edit_SaveFile();
		end
	end,
	['R'] = function()
		local name = gView() and gView().name;
		if name then
			name = "v"..name..".vui";
			gWindow:Push(name);
		end
	end,
	['V'] = function()
		gWindow:view():ReLayout();
		if edit_ViewChanged then edit_ViewChanged() end
    end,
    [9] = function()
        gEditMode = not gEditMode;
        vreload();
        if edit_DesignModeChanged then edit_DesignModeChanged(gEditMode); end
    end,
    ['D'] = function()
    	gCurrTouchNode:Delete();
    	gCurrTouchNode = nil;
    	if edit_ViewChanged then edit_ViewChanged() end
    end,
}
function VUiOnKeyUp(key)
    if gEditMode or key == 9 or key == 32 then
    	local func = vedit_func[key] or vedit_func[string.char(key)];
    	if func then
    		func();
    	end 
    end
end

function VUiOnDragFile(x, y, filename)
	_edit_node_id = _edit_node_id or 0;
	local node = gView():Push(VImage{name = "img_".._edit_node_id,image=filename,touch=1,drag=1,isVUi=1});
	_edit_node_id = _edit_node_id + 1;
	node:setWinPos(Var{x,y},-1);
	if edit_ViewChanged then edit_ViewChanged() end
end
