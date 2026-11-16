
VNotePayDlg = VClass("NotePayDlg", VMsgBox);

function VNotePayDlg:onPush( )
    self:initData();

    self.tbv = self("p_rechargeTbv");
    self.tbv.number = 3;
    self.tbv.delegate = self;
    self.tbv:setTouchEnabled(false);
    self.tbv:reloadData();
end

function VNotePayDlg:onCell(idx, t, cell)
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
			item("chooseMoney").onClick = "gView('notePayDlg'):onCheckBoxClick("..n..")";
		else
			item.visible = 0;
		end
	end
end


function VNotePayDlg:initData( )
    self.moneyList = {2,4,6,8,10};
    self.channel = 304;
    self.choose = 1;
end

function VNotePayDlg:onCheckBoxClick(n)
	if n == self.choose then return end
	local idx1 = math.floor((self.choose-1)/3);
	local idx2 = math.floor((n-1)/3);
	self.choose = n;

	self.tbv:updateCellAtIndex(idx1);
	self.tbv:updateCellAtIndex(idx2);
end

function VNotePayDlg:PayBtnClick(  )
	local money = self.moneyList[self.choose];
	if gPackage == 1003  then
		local params = tostring(getClientVersion());
		gSys:pay(self.channel, 1, money*100, params);
	else
		local params = string.format("{ \"sid\":%d, \"client_ver\":\"%s\", \"payUserId\":%d, \"goodsName\":\"%s\"}", gZoneid, getClientVersion(), self.payUserId, (money*gResRate.."钻石"));
		gSys:pay(self.channel, self.userId, money*gRate, params);
	end
end