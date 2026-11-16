
VAlipayDlg = VClass("AlipayDlg", VMsgBox);

function VAlipayDlg:onPush( )
    if gPackage == 1005 then
        self("titleText").text = "爱思充值";
    elseif gPackage == 1006 then
        self("titleText").text = "充值";
    elseif gPackage == 1009 then
        self("titleText").text = "XY充值";
    elseif gPackage == 1012 then
        self("titleText").text = "海马充值";
    elseif gPackage == 1013 then
        self("titleText").text = "91充值";
    elseif gPackage == 1014 then
        self("titleText").text = "飓风互动充值";
    elseif gPackage == 1015 then
        self("titleText").text = "快用充值";
    elseif gPackage == 1016 then
        self("titleText").text = "XX充值";
    elseif gPackage == 1017 then
        self("titleText").text = "同步推充值";
    elseif gPackage == 1018 then
        self("titleText").text = "itools充值";
    elseif gPackage == 1019 then
        self("titleText").text = "乐8充值";
    elseif gPackage == 1020 then
        self("titleText").text = "uc充值";
    elseif self.channel == 11 then
        self("titleText").text = "网银充值";
    elseif self.channel == 1 then
        self("titleText").text = "支付宝充值";
    elseif self.channel == 107 then
        self("titleText").text = "微信支付";
    end
    self.inputEditor = self("inputEditor");
end


function VAlipayDlg:SureBtnClick(  )
    local money = self.inputEditor:getText();
    if not money or money == "" then
        gWindow:showTip("请输入充值金额！", 2);
        return;
    end
    self.inputEditor.text = "";


    local params = string.format("{ \"sid\":%d, \"client_ver\":\"%s\", \"payUserId\":%d, \"goodsName\":\"%s\"}", gZoneid, getClientVersion(), self.payUserId, (money*gResRate.."钻石"));
    gSys:pay(self.channel, self.userId, tonumber(money)*gRate, params);

    self:doPop();
end

-- function VAlipayDlg:initData( )

-- end