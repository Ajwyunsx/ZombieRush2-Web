--vOperationLayer.lua

VOperationLayer = VClass("OperationLayer", VLayer)

function VOperationLayer:showLayer()
    if self.bts then
        for i,button in ipairs(self.bts) do
            local x, y = button:getPosition();
            button:RunAction{{"delayTime", (i-1)*0.05}, {"easeOut", 1.5, {"moveTo", 0.15, x, y+79}}};
        end
    end
    self:RunAction({{"fadeTo", 0, 0}, {"show"}, {"fadeTo", 0.15, 255}}, 1, true);
    gMainView.manorView:didChoosed(self.tab, self.type);
    gMainView:showLeftBtn(false);
end

function VOperationLayer:closeLayer()
    if self.bts then
        for i,button in ipairs(self.bts) do
            local x, y = button:getPosition();
            button:RunAction{{"delayTime", (i-1)*0.05}, {"easeIn", 1.5, {"moveTo", 0.15, x, y-79}}};
        end
    end

    self:RunAction({{"fadeTo", 0.15, 0}, {"hide"}}, 1, true);
    self:RunAction({{"delayTime", 0.2}, {self, "CleaUpLayer"}}, 2);
    gMainView:showLeftBtn(true);
end

function VOperationLayer:CleaUpLayer()
    gMainView.manorView:didUnChoose(self.tab, self.type);
	if self.bts then
        for i,button in ipairs(self.bts) do
            button:Delete();
        end
        -- local count = table.getn(self.bts)
        -- for var = 1, count do
        --     self.bts[var]:Delete()
        --     self.bts[var] = nil
        -- end
        self.bts = nil
        self.buttons = nil
        self.tab = nil
        self.type = nil
    end

    self("txNameOperate").text = nil
end

function VOperationLayer:layoutButton()

    self.bts = {}
    self("txNameOperate").text = self.title.text
    
    self("txNameOperate").color = self.title.color
    local count = table.getn(self.buttons)
    local num1, num2= math.modf(count / 2)
    
    for var,v in ipairs(self.buttons) do
        local bt = VButton{name = "btOperate"..var, image="mv_jianzhuanniu.png", layout="Center", step={0,1}, offset={-(num1 + num2 - 0.5) * 82, 10}, onClick = self.buttons[var].onClick}
        local img = VImage{name="imgInfoOperate", image = self.buttons[var].icon, layout="Center", offset={0,-16}}
        local tx = VImage{name = "txInfoOperate", image = self.buttons[var].descText, layout="Down", offset={0,-8}}
        if self.buttons[var].cost ~= nil then
            img.layout = "Up"
            img.offset = {0, 25}
            img.scale = 0.8
            local cost = VText{name = "txInfoOperate", outline=2, effectColor={0,0,0}, text = self.buttons[var].cost, layout="Up", offset={0,2}, fontSize=20, level=100}
            bt:Push(cost)
        end
        
        if self.buttons[var].limitText ~= nil then
            local tx1 = VText{name = "txInfoOperate1", text = self.buttons[var].limitText, layout="Center", size={85,70}}
            bt:Push(tx1)
        end
        
        bt:Push(img)
        bt:Push(tx)
        if self.buttons[var].gray == nil then
            bt.onClick = "gView('layOperation'):OperationCallBack("..var..")";
        else
            bt.gray = self.buttons[var].gray
        end    
        num1 = num1 - 1
        table.insert(self.bts,bt)
        self:Push(bt)
        
        if self.buttons[var].cost ~= nil then
            
        end
    end
end

function VOperationLayer:OperationCallBack(var)
    VCallBack(self.buttons[var].delegate, self.buttons[var].callBack, self.buttons[var].extend);
    self:closeLayer();
end

--function VOperationLayer:setFarmInfo(farmInfo, isSelf)
--    if self.visible and self.farmInfo == farmInfo then
--        return false;
--    end
--    self.isSelf = isSelf;
--    self.farmInfo = farmInfo;
--    self:layoutButton();
--    return true;
--end

function VOperationLayer:CheckOperationLay(buttons, title, tab, type)
--    if self.visible  then
        if buttons == nil or table.getn(buttons) == 0 then
            cclog("~~~~~~~~~~~~~按钮列表都不传,是点空地了吧")
            return false
        elseif tab == nil and type == nil then --非实体建筑，如：战旗
            if self.buttons and not self.tab and not self.type then
                self:CleaUpLayer();
                return false;
            else 
                self:CleaUpLayer();
            end
        else
            if self.tab == tab and self.type == type then
                cclog("~~~~~~~~~~~~~2222222222")
                self:CleaUpLayer()
                return false
            else 
                self:CleaUpLayer()
            end
        end
--    else
--         if buttons == nil then
--            return false
--         else
--         end    
--    end
    self.tab = tab
    self.type = type
    self.buttons = buttons;
    self.title = title;
    self:layoutButton();
    return true;
end

