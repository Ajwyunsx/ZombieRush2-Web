--vAccountFindCellPhone.lua
VAccountFindCellPhone = VClass("AccountFindCellPhone", VMsgBox)

function VAccountFindCellPhone:onPush()
	self("titliText").image = "shoujizhaohui.png";
	self.edtCellPhone = self("edtCellPhone");
	self.edtCodeCellPhone = self("edtCodeCellPhone");
	self.edtPswCellPhone = self("edtPswCellPhone");
    self.txtimeCellPhone = self("txtimeCellPhone")
    self.timeSpace = 60
    self.txtimeCellPhone.text = self.timeSpace
end

function VAccountFindCellPhone:ShowNextGetCodeTime(parameters)
    local txtimeCellPhone = self.txtimeCellPhone
    local time = tonumber(txtimeCellPhone.text) - 1
    if time <= 0 then
        txtimeCellPhone.visible = 0

        local btnGetCodeCellPhone = self("btnGetCodeCellPhone")
        btnGetCodeCellPhone.topImage = "huoquyanzhengma.png"
        btnGetCodeCellPhone.touch = 1
        btnGetCodeCellPhone.gray = 0
        txtimeCellPhone.text = self.timeSpace
    else
        txtimeCellPhone.text = time
    end
end

function VAccountFindCellPhone:onGetCodeClick()
	local cellPhone = self.edtCellPhone:getText();
	if not isPhoneNumber(cellPhone) then
		gWindow:showTip("请输入正确的手机号码");
		return;
	end
	gReq:MsgReqAccountRestore(self, "cellPhoneFindAccoutCallBack1", 1, cellPhone);
	
    self.txtimeCellPhone.visible = 1

    local btnGetCodeCellPhone = self("btnGetCodeCellPhone")
    btnGetCodeCellPhone.topImage = nil;
    btnGetCodeCellPhone.touch = 0
    btnGetCodeCellPhone.gray = 1

    self:StartTimer("ShowNextGetCodeTime", 1, self.timeSpace - 1, 0)
	
	gWindow:showWaitTip("正在获取验证码...");
end

function VAccountFindCellPhone:cellPhoneFindAccoutCallBack1(result, rsp, req)
	gWindow:closeWaitTip();
	if result == 0 then
		self.cellPhone = req.value;
		local leftTime = rsp.remain_count;
		local msgString = gFormat("验证码已经发送至您的手机，\n今日找回次数剩余%d次", leftTime);
		gWindow:showConfirmTip(msgString, "确定", nil, nil, nil);
	end
end

function VAccountFindCellPhone:onOKClick()
	-- if not self.cellPhone then
	-- 	gWindow:showTip("请先获取验证码");
	-- 	return;
	-- end
	if not self.cellPhone then
		self.cellPhone = self.edtCellPhone:getText();
	end

	local code = self.edtCodeCellPhone:getText();
	if code == "" then
		gWindow:showTip("请输入正确的验证码");
		return;
	end

	-- local psw = self.edtPswCellPhone:getText();
	-- if psw == "" then
	-- 	gWindow:showTip("请输入密码");
	-- 	return;
	-- end

	gReq:MsgReqAccountRestore2(self, "cellPhoneAccoutCallBack2", 1, self.cellPhone, tonumber(code));
	gWindow:showWaitTip("正在找回账号...");
end

function VAccountFindCellPhone:cellPhoneAccoutCallBack2(result, rsp, req)
	gWindow:closeWaitTip();
	if result == 0 then
		gView():startGameAction();
		self:onClick();
	end
end



