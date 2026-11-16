VPageTable = VClass("PageTable", VLayer)


function VPageTable:Init( attr )
    VNode.Init(self, attr);
    self:NeedEvent(Eff_onEnter);
    self.firstIndex = 0
    self.clip = 1
    self.touch = 1
    self.cells = {}
    self.move = true
end

function VPageTable:onPush()
--	if self.cell ~= "" and self.cell then
--	    local cell
--	end
    self:initCellNumber()
    
    if self.cellNumber ~= 0 then
        for var = 0, self.cellNumber - 1 do
            self:createCell(var)
        end
        
        self.firstCell = self.cells[1]
    end
end

function VPageTable:setCellNumber(num)
    self.number = num 
end

function VPageTable:setDelegate(delegate)
    self.delegate = delegate
end

function VPageTable:reloadData(parameters)
    
    if self.delegate and self.delegate.onCell then
    
        for var = 0, self.cellNumber - 1 do
            local index = self.firstIndex % (self.cellNumber - 1 ) + 1 + var
            
            local cell = self.cells[index]
            
            cell.index = self.firstIndex + var
            cell.visible = 1

            self.delegate:onCell(self.firstIndex + var, self, cell)          
        end
    end
end



function VPageTable:initCellNumber(parameters)
	self.cellNumber = 0
	
    if self.cell == nil or self.cell == "" then
        return
    end
	
    local cell = VNode(self.cell);
    
    if not cell then
        return
    end

    if not cell.size then
        cclog("setCellSize")
        cell.size = self.size
    end
    
    self.cellSize = cell.size
    
    if self.direction == "Hor" then
        self.cellNumber = math.ceil(self.size.width / cell.size.width) + 1
    else
        self.cellNumber = math.ceil(self.size.height / cell.size.height) + 1
    end
    
    cclog("cellNumber"..self.cellNumber)
end

function VPageTable:createCell(index)
    local cell = VNode(self.cell);
    
    if not cell.size then
        cclog("setCellSize")
        cell.size = self.size
    end

    self:initCell(cell, index)
    
    cell:Travel(function( node )
        if node.touch then
            cclog("set node.touch")
            node:InitListener(false);
            node._cellIdx = index;
            node.tableView = self;
        end
    end, true);

    self:Push(cell);

    table.insert(self.cells, cell)
end

function VPageTable:initCell(cell, index)
    if not cell.size then
        cclog("setCellSize")
        cell.size = self.size
    end
    
    cell.layout = "UpLeft"
    
    local width = cell.size.width 
    local height = cell.size.height
    
    if self.direction == "Hor" then
        cell.offset = {index * width, 0}
    else
        cell.offset = {0, index * height}
    end
    
    cell.visible = 0
end

function VPageTable:GetCellFinalPosition(cell, x, y, offset)
    if self.direction == "Hor" then
        if offset.x <= 0 and (- x) >= self.cellSize.width then
            cclog("左边出去了~~~~"..cell.index)
            x = x + self.cellNumber * self.cellSize.width
            self.firstIndex = self.firstIndex + 1
            cell.index = self.firstIndex + self.cellNumber - 1
            self.delegate:onCell(cell.index, self, cell)
        elseif offset.x > 0 and x > self.size.width then
            cclog("右边出去了~~~~"..cell.index)
            x = x - self.cellNumber * self.cellSize.width
            self.firstIndex = self.firstIndex - 1
            cell.index = self.firstIndex
            self.delegate:onCell(cell.index, self, cell)
        end
    else
        if offset.y <= 0 and (- y) >= self.cellSize.height then
            y = y - self.size.height -self.cellSize.height
            self.firstIndex = self.firstIndex - 1
            cell.index = self.firstIndex - 1
        elseif offset.y > 0 and y >= self.size.height then
            y = y + self.size.height
            self.firstIndex = self.firstIndex + 1
            cell.index = self.firstIndex + self.cellNumber - 1
        end
    end
    
    if self.firstIndex == cell.index then
        cclog("setfirstCell")
        self.firstCell = cell
    end
    
    return x, y
end

function VPageTable:UpdataMovingCell(cell, x, y, offset)
    local ret = self:checkBoundingBreak(offset)
    
    if ret then
        cclog("boundingBreak")
        return
    end
    
	local x, y = self:GetCellFinalPosition(cell, x, y, offset)
    cell:setPosition(cc.p(x, y));
end

function VPageTable:checkBoundingBreak(offset)
    if self.direction == "Hor" then
        cclog("firstIndex~~~~~"..self.firstIndex)
        
        if self.tmp.firstIndex == 0 and self.tmp.x + offset.x > 0 then
            return true
        end 
        
        
        
        if self.tmp.firstIndex + self.cellNumber - 1 >= self.number and self.tmp.x + (self.cellNumber - 1)  * self.cellSize.width + offset.x < self.size.width then
            return true
        end
    else
        if self.firstIndex == 0 and self.firstCell.position.y + self.cellSize.height + offset.y >= self.size.height then
            return true
        end 

        if self.firstIndex + self.cellNumber - 1 >= self.number and self.firstCell.position.y + offset.y <= 0  then
            return true
        end
    end
    
    return false
end

function VPageTable:LetfAlign(parameters)
    self:copyCurrentFirstCellPos()
    
    local offset = {x = 0, y = 0}
    
    for var = 1, self.cellNumber do
        local index = (self.tmp.firstIndex + var - 1) % self.cellNumber + 1
        local cell = self.cells[index]

--        cclog(cell.position.x.."~~~~~~~~"..cell.position.y.."~~~~~~~~~"..cell.index)
        if cell.position.x < 0 then
            local x = -self.cellSize.width
            local y = self.tmp.y        
            cell:RunAction{"sequence", {"moveTo", 1, -self.cellSize.width, self.tmp.y}}--, {self, "UpdataMovingCell", cell, -self.cellSize.width, self.tmp.y, offset}}
        elseif cell.position.x > 0 then
            local x = cell.position.x - cell.position.x % self.cellSize.width
            local y = self.tmp.y
            cell:RunAction{"sequence", {"moveTo", 1, x, y}}--, {self, "UpdataMovingCell", cell, x, y, offset}}
        end
--        cclog(cell.position.x.."~~~~~~~~"..cell.position.y.."~~~~~~~~~"..cell.index)
    end
end

function VPageTable:RightAlign(parameters)
    self:copyCurrentFirstCellPos()
    
    local offset = {x = 0, y = 0}
    
    for var = 1, self.cellNumber do
        local index = (self.tmp.firstIndex + var - 1) % self.cellNumber + 1
        local cell = self.cells[index]

        --        cclog(cell.position.x.."~~~~~~~~"..cell.position.y.."~~~~~~~~~"..cell.index)
        if cell.position.x < 0 then
            local x = 0
            local y = self.tmp.y        
            cell:RunAction{"sequence", {"moveTo", 1, x, y}}--, {self, "UpdataMovingCell", cell, x, y, offset}}
        elseif cell.position.x > 0 then
            local x = cell.position.x + (self.cellSize.width - cell.position.x % self.cellSize.width)
            local y = self.tmp.y
            cell:RunAction{"sequence", {"moveTo", 1, x, y}}--, {self, "UpdataMovingCell", cell, x, y, offset}}
        end
        --        cclog(cell.position.x.."~~~~~~~~"..cell.position.y.."~~~~~~~~~"..cell.index)
    end
end

function VPageTable:onTouchBase(touch)
    cclog("VPageTable:onTouchBase")
--    if not self:IsInRect(touch) then
--        return false;
--    end
--    VPageTable.super.onTouchBase(self, touch);
    self:copyCurrentFirstCellPos()
    
    for var = 1, self.cellNumber do
        local index = (self.tmp.firstIndex + var - 1) % self.cellNumber + 1
        local cell = self.cells[index]
        cell:StopAction()
    end
    
    return true
end

function VPageTable:onMoveBase(touch)
--    VPageTable.super.onMoveBase(self, touch);
--    cclog("VPageTable:onMoveBase")
    local offset = touch:getDelta();
--    local point1 = touch:getPreviousLocationInView();
--    local point2 = touch:getLocationInView();
--    local preDistance = cc.pGetLength(cc.pSub(point1, point2));
--    cclog("================================一次移动事件====================================")
    if self.direction == "Hor" then
        if offset.x ~= 0 then
            if offset.x < 0 then
                offset.x = -3
            else
                offset.x = 3
            end
            
            self:copyCurrentFirstCellPos()

            for var = 1, self.cellNumber do
                local index = (self.tmp.firstIndex + var - 1) % self.cellNumber + 1
                local cell = self.cells[index]
                
--                cclog(cell.position.x.."~~~~~~~~"..cell.position.y.."~~~~~~~~~"..cell.index)
                self:UpdataMovingCell(cell, cell.position.x + offset.x, cell.position.y, offset)
--                cclog(cell.position.x.."~~~~~~~~"..cell.position.y.."~~~~~~~~~"..cell.index)
            end
            
        end
    else
        if offset.y ~= 0 then
            for var = 1, self.number + 1 do
                local cell = self.cells[var]
--                cclog(cell.position.x.."~~~~~~~~"..cell.position.y)
                self:UpdataMovingCell(cell, cell.position.x, cell.position.y + offset.y, offset)
            end
        end
    end
    
--    cclog("================================移动事件结束====================================")
end

function VPageTable:copyCurrentFirstCellPos()
	self.tmp = {}
    self.tmp.x = self.firstCell.position.x
    self.tmp.y = self.firstCell.position.y
    self.tmp.firstIndex = self.firstIndex
--    cclog("==============="..self.tmp.x.."~~~~~~~~"..self.tmp.y.."=================")
end

function VPageTable:onLeaveBase(touch)
    cclog("VPageTable:onLeaveBase")
--    VPageTable.super.onLeaveBase(self, touch);
--    local offset = touch:getDelta();
--    
--    cclog("offset.x"..offset.x)
--    if self.firstCell.position.x < self.tmp.x then
--        cclog("================================LetfAlign=====================================")
--        self:LetfAlign()
--    elseif self.firstCell.position.x > self.tmp.x then
--        cclog("================================RightAlign=====================================")
--        self:RightAlign()
--    end
end