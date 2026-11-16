--vAccountFindEmail.lua
VAccountFindEmail = VClass("AccountFindEmail", VMsgBox)

function VAccountFindEmail:onPush()
	self("titliText").image = "youxiangzhaohui.png";
	self.edtEmailAddress = self("edtEmailAddress");
	self.edtCodeEmailFind = self("edtCodeEmailFind");
	self.edtPswEmailFind = self("edtPswEmailFind");
    self.txtimeEmailFind = self("txtimeEmailFind")
    self.timeSpace = 60
    self.txtimeEmailFind.text = self.timeSpace
    
end

function VAccountFindEmail:ShowNextGetCodeTime(parameters)
    local txtimeEmailFind = self.txtimeEmailFind
    local time = tonumber(txtimeEmailFind.text) - 1
    if time <= 0 then
        txtimeEmailFind.visible = 0

        local btnGetCodeEmailFind = self("btnGetCodeEmailFind")
        btnGetCodeEmailFind.topImage = "huoquyanzhengma.png";
        btnGetCodeEmailFind.touch = 1
        btnGetCodeEmailFind.gray = 0
        -- txtimeEmailFind.text = "";
    else
        txtimeEmailFind.text = time
    end
end

function VAccountFindEmail:onGetCodeClick()
	local email = self.edtEmailAddress:getText();
	if not isEmail(email) then
		gWindow:showTip("请输入正确的邮箱地址");
		return;
	end
	gReq:MsgReqAccountRestore(self, "emailFindAccoutCallBack1", 2, email);
	
    self.txtimeEmailFind.visible = 1
    
    local btnGetCodeEmailFind = self("btnGetCodeEmailFind")
    btnGetCodeEmailFind.topImage = nil
    btnGetCodeEmailFind.touch = 0
    btnGetCodeEmailFind.gray = 1

    self:StartTimer("ShowNextGetCodeTime", 1, self.timeSpace - 1, 0)
    
	gWindow:showWaitTip("正在获取验证码...");
end

function VAccountFindEmail:emailFindAccoutCallBack1(result, rsp, req)
	gWindow:closeWaitTip();
    
	if result == 0 then
		self.email = req.value;
		local leftTime = rsp.remain_count;
		local msgString = gFormat("验证码已经发送至您的邮箱，\n今日找回次数剩余%d次", leftTime);
		gWindow:showConfirmTip(msgString, "确定", nil, nil, nil);
	end
end

function VAccountFindEmail:onOKClick()
	-- if not self.email then
	-- 	gWindow:showTip("请先获取验证码");
	-- 	return;
	-- end

	if not self.email then
		self.email = self.edtEmailAddress:getText();
	end

	local code = self.edtCodeEmailFind:getText();
	if code == "" then
		gWindow:showTip("请输入正确的验证码");
		return;
	end

	-- local psw = self.edtPswEmailFind:getText();
	-- if psw == "" then
	-- 	gWindow:showTip("请输入密码");
	-- 	return;
	-- end

	gReq:MsgReqAccountRestore2(self, "emailFindAccoutCallBack2", 2, self.email, tonumber(code));
	gWindow:showWaitTip("正在找回账号...");
end

function VAccountFindEmail:emailFindAccoutCallBack2(result, rsp, req)
	gWindow:closeWaitTip();
	if result == 0 then
		gView():startGameAction();
		self:onClick();
	end
end



