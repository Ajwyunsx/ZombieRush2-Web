--VTableView.lua

VTableViewCell = VClass("TableViewCell", VNode)

function VTableViewCell:onCreate(attr)
	attr.layout = "None";
	return cc.TableViewCell:new();
end

------------------------------------------------------------------

VTableView = VClass("TableView", VNode)

_VTableViewDir = VEnum{
    None = -1,
    Hor = 0,
    Ver = 1,
    Both = 2,
}
_VTableViewOrder = VEnum{
    Down = 0,
    Up = 1,
}
_VTableViewLeave = VEnum{
    None = -1,
    Up = 0,
    Down = 1,
}

function VTableView:onCreate(attr)
	local node = cc.TableView:create(attr.size);
	node:ignoreAnchorPointForPosition(false);
	return node;
end
function VTableView:Init( attr )
	VNode.Init(self, attr);
	self:NeedEvent(Eff_onEnter);
	self:setDelegate();
	self:registerScriptHandler(VTableView.doCell, cc.TABLECELL_AT_INDEX);
	self:registerScriptHandler(VTableView.doNumber, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
	self:registerScriptHandler(VTableView.doCellSize, cc.TABLECELL_SIZE_FOR_INDEX);
	self:registerScriptHandler(VTableView.doScroll, cc.SCROLLVIEW_SCRIPT_SCROLL);
	self:registerScriptHandler(VTableView.doCellWillRecycle, cc.TABLECELL_WILL_RECYCLE);

	if attr.cell then
		self.cellAttr = Var():FromFile(attr.cell);
		self.cellSize = self.cellAttr[0].size;
	end
	if not attr.order then self.order = 0 end
	if not self.number then self.number = 0 end

	self.refreshNum = attr.refreshNum or -1;
	if self.refreshNum ~= -1 then
		self.downLabel = VText{text="", fontSize=24};
		self:Push(self.downLabel);
		if self.isDown == 1 then
			self.upLabel = VText{text="", fontSize=24};
			self:Push(self.upLabel);
			self.upLabel.upText = attr.upText or "下拉刷新";
			self.upLabel.loseText = attr.loseText or "松开刷新";
		else
			self.downLabel:setPosition(cc.p(attr.size.width/2, -14));
			self.downLabel.upText = attr.upText or "上拉刷新";
			self.downLabel.loseText = attr.loseText or "松开刷新";
		end
	end
end
function VTableView:onPushBase()
	if not self.delegate then
		self.delegate = self:Parent();
	end
	if self.number > 0 then
		if self.delegate.onCell then
			self:reloadData();
		end
	end
end
function VTableView:on_direction( dir )
	self:setDirection(_VTableViewDir(dir));
end
function VTableView:on_order( order )
	self:setVerticalFillOrder(_VTableViewOrder(order));
end

function VTableView:on_touch(b)
    self:InitListener(false);
end

--设置原生的touchlistener是否吞噬事件
--不是上面那个listener
function VTableView:on_swallow(swallow)
	self:setTouchSwallow(swallow);
end

function VTableView:doNumber( t )
	self = VNode(self);
	return self.number;
end

function VTableView:doCell(idx, t, cell)
	self = VNode(self);
	cell = VNode(self:dequeueCell() or self.cellAttr);
	if self.delegate and self.delegate.onCell then
		self.delegate:onCell(idx, self, cell);
	end
	if VNode._cellNode then
		VNode._cellNode:onLeaveBase()
	end
	cell:Travel(function( node )
		if node.touch then
			node:InitListener(false);
			node._cellIdx = idx;
			node.tableView = self;
		end
	end, true);
	return cell._cobj;
end

function VTableView:doCellSize(idx, t)
	self = VNode(self);
	if self.delegate and self.delegate.onCellSize then
		return self.delegate:onCellSize(idx, self);
	end
	return self.cellSize.width, self.cellSize.height;
end

function VTableView:doCellWillRecycle(cell)
	cell = VNode(cell);
	cell:Travel(function( node )
		if node.isButton and node.preScale then
			node.scale = node.preScale;
		end
	end, true);
end

function VTableView:doScroll( view )
	self = VNode(self);
	if self.refreshNum ~= -1 and self.number >= self.refreshNum then
		local pos = self:getContentOffset();
		if pos.y < 0 and self.isDown ~= 1 then
			return;
		end
		-- local offY = 0 - (self:getContentSize().height - self:getViewSize().height);
		-- if pos.y > firstLine or offY - pos.y > firstLine then
			if pos.y > 40 or (self.offY and self.offY - pos.y > 40) then
				if pos.y > 0 then
					self.downLabel:setString(self.downLabel.loseText);
					self.refreshType = _VTableViewLeave.Down;
				else
					self.upLabel:setString(self.upLabel.loseText);
					self.refreshType = _VTableViewLeave.Up;
				end
				self.isRefresh = true;
			else
				if pos.y >= 0 then
					self.downLabel:setString(self.downLabel.upText);
				else
					if self.isDown == 1 then
						self.upLabel:setString(self.upLabel.upText);
					end
				end
				self.isRefresh = false;
			end
		-- 	label:setVisible(true);
		-- else
		-- 	self.isRefresh = false;
		-- 	label:setVisible(false);
		-- end
	end
end

function VTableView:onLeaveBase(touch)
	if self.isRefresh and self.delegate and self.delegate.onTableLeave then
		self.isRefresh = false;
		return self.delegate:onTableLeave(self, self.refreshType);
	end
end

function VTableView:cancelLoading()
	self.refreshNum = -1;
	self.downLabel:setVisible(false);
end

function VTableView:resetTableLoading( num )
	self.refreshNum = num;
	self.downLabel:setVisible(true);
end

function VTableView:addCellNum( num, scrollIndex )
	local firstIndex = self.number;
	self.number = self.number + num;

	if self.refreshType == _VTableViewLeave.Up then
		for i=0,num do
			self:insertCellAtIndex(i);
		end		
		local lastIndex = num;
		for i=0,num + 1 do
			self:updateCellAtIndex(i);
		end

		self:setPullLabelPos();
		self:scrollToCell(num);
	elseif self.refreshType == _VTableViewLeave.Down then
		for i=firstIndex,self.number do
			self:insertCellAtIndex(i);
		end

		local lastIndex = firstIndex - num - 5;
		if lastIndex < 0 then
			lastIndex = 0;
		end
		for i=lastIndex,firstIndex do
			self:updateCellAtIndex(i);
		end

		if scrollIndex then
			firstIndex = firstIndex + scrollIndex - 1;
		end

		self:scrollToCell(firstIndex);
	else
        for i = 0, num - 1 do      
            self:insertCellAtIndex(firstIndex + i);
        end

        self:reloadData();

        self:scrollToCell(self.number);
	end
	-- self:reloadData();
end

function VTableView:scrollToCell( index )
	local direction = self:getDirection();
	local verticalFillOrder = self:getVerticalFillOrder();
	local currentOffset = self:getContentOffset();
	local offsetX = 0;
	local offsetY = 0;
	
	if direction == _VTableViewDir.Ver then
		if verticalFillOrder == _VTableViewOrder.Down then
			offsetY = 0 - self:getCellsTotalHeight(self.number - index - 1);
			if currentOffset.y > offsetY then
				offsetY = offsetY + self:getViewSize().height;
			end
			-- offsetY = -self.cellSize.height * (self.number - index - 1);
		else
			offsetY = 0 - self:getCellsTotalHeight(index);
			-- offsetY = -self.cellSize.height * index;
		end
	else
		if verticalFillOrder == _VTableViewOrder.Down then
			offsetX = 0 - self:getCellsTotalHeight(self.number - index - 1);
			-- offsetX = -self.cellSize.height * (self.number - index - 1);
		else
			offsetX = 0 - self:getCellsTotalHeight(index);
			-- offsetX = -self.cellSize.height * index;
		end
	end

	local maxInset = self:maxContainerOffset();
	local minInset = self:minContainerOffset();
	offsetX = math.min(offsetX, maxInset.x);
	offsetX = math.max(offsetX, minInset.x);
	offsetY = math.min(offsetY, maxInset.y);
	offsetY = math.max(offsetY, minInset.y);

	self:setContentOffset(cc.p(offsetX, offsetY), false);
end

function VTableView:getCellsTotalHeight( index )
	local totalHeight = 0;
	for i=0,index do
		local w,h = self:doCellSize(i);
		totalHeight = totalHeight + h;
	end
	return totalHeight;
end

function VTableView:setPullLabelPos( )
	if self.isDown == 1 then
		self.upLabel:setPosition(cc.p(self.size.width/2, self:getContentSize().height + 14));
		self.offY = 0 - (self:getContentSize().height - self:getViewSize().height);
	end
end