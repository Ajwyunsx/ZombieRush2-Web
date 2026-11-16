VAlipayView = VClass("AlipayView", VMsgBox);


function VAlipayView:onPush(  )
	self.tbv = self("tbv");

    self.moneyList = {10,30,50,100,300,500,1000};

    
    self.choose = 1;
    self.tbv.delegate = self;
    self.tbv.number = #self.moneyList;
    self.tbv:setTouchEnabled(false);
    self.tbv:reloadData();
end


function VAlipayView:onCell( idx, t, cell )
	for i=1,3 do
        local n = idx * 3 + i;
        local money = self.moneyList[n];
        local item = cell("noteLayer"..i);
        if money then 
            item("moneyText").text = money.."元充值";
            if self.choose == n then
                item("checkImg").visible = 1;
            else
                item("checkImg").visible = 0;
            end
            item("chooseMoney").onClick = "node:Parent(6):onCheckBoxClick("..n..")";
        else
            item.visible = 0;
        end
    end
end

--点击金额勾选框响应函数
function VAlipayView:onCheckBoxClick( n )
	if n == self.choose then return end
    local idx1 = math.floor((self.choose-1)/3);
    local idx2 = math.floor((n-1)/3);
    self.choose = n;
    local money = self.moneyList[n];
    self.tbv:updateCellAtIndex(idx1);
    self.tbv:updateCellAtIndex(idx2);
    self("rc_cardIdEditor"):setText(money);
end


--点击确定充值按钮响应函数
function VAlipayView:onPayBtnClick(  )
	local moneyText = self("rc_cardIdEditor"):getText();
	local money = tonumber(moneyText);
	if not money or money <= 0 then
		gWindow:showTip("充值金额不正确！");
		return;
	end
	self("rc_cardIdEditor").text = "";

    local params = string.format("{ \"sid\":%d, \"client_ver\":\"%s\", \"payUserId\":%d, \"goodsName\":\"%s\"}", gZoneid, getClientVersion(), self.payUserId, (money*gResRate.."钻石"));    
    gSys:pay(self.channel, self.userId, tonumber(money)*gRate, params);
    self:doPop();
end