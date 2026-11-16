
vYeePayDlg = VClass("YeePayDlg", VMsgBox);

function vYeePayDlg:onPush( )
    self.tbv = self("tbv");
    if self.cardType == 2 then
        self.moneyList = {50,100};
    elseif self.cardType == 3 then
        self.moneyList = {20,30,50,100,300,500};
    else
        self.moneyList = {10,30,100,300,20,50,200,500};
    end
    
    self.choose = 1;
    self.tbv.delegate = self;
    self.tbv.number = #self.moneyList;
    self.tbv:setTouchEnabled(false);
    self.tbv:reloadData();
end




function vYeePayDlg:onYeePayBtnClick() --type: 1,移动  2电信， 3联通
	local cardNo = self("rc_cardIdEditor"):getText();
	local cardPsw = self("rc_cardPswEditor"):getText();
	if cardNo == "" or cardPsw == "" then
		gWindow:showTip("卡号密码不能为空！", 1);
		return;
	end
    local money = self.moneyList[self.choose] * gRate;

    local params = string.format("{ \"sid\": %d, \"client_ver\":%s, \"payUserId\":%d,\"goodsName\":\"%s\", \"cardType\":%d, \"card\":\"%s\", \"pwd\":\"%s\"}",
    gZoneid, getClientVersion(), self.payUserId, (money*gResRate.."钻石"), self.cardType, cardNo, cardPsw);
    gSys:pay(2, self.userId, money, params);
end

function vYeePayDlg:onCell( idx, t, cell )
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

function vYeePayDlg:onCheckBoxClick( n )
    if n == self.choose then return end
    local idx1 = math.floor((self.choose-1)/3);
    local idx2 = math.floor((n-1)/3);
    self.choose = n;

    self.tbv:updateCellAtIndex(idx1);
    self.tbv:updateCellAtIndex(idx2);
end
function vYeePayDlg:onPayCallBack( )
	self("rc_cardIdEditor").text = nil;
	self("rc_cardPswEditor").text = nil;
end