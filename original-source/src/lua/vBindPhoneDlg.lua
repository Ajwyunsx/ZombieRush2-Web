
VBindPhoneDlg = VClass("BindPhoneDlg", VMsgBox)

function VBindPhoneDlg:Init(attr)
    self.super.Init(self, attr)
    self.accountInfo = gData.accountInfo
    self.timeSpace = 60
end

function VBindPhoneDlg:onPush()
    local txtimePhone = self("txtimePhone")
    txtimePhone.text = self.timeSpace
end

function VBindPhoneDlg:setRoleInfo(info)
    self.roleInfo = info
end

function VBindPhoneDlg:onCloseClick()
    local edtPhoneNumBindPhone = self("edtPhoneNumBindPhone")
    local edtCodeBindPhone = self("edtCodeBindPhone")

    if (edtPhoneNumBindPhone.visible and edtPhoneNumBindPhone:getText() ~= "") or
        (edtCodeBindPhone.visible and edtCodeBindPhone:getText() ~= "") then
        gWindow:showConfirmTip("手机绑定未完成,确定返回吗", "确定", "取消", self, "onClick", nil, "确定返回吗?")
        return
    end
    
    self:onClick()
end

function VBindPhoneDlg:RecoveGetCode(parameters)
    self:StopTimer("ShowNextGetCodeTime");
    local txtimePhone = self("txtimePhone")

    txtimePhone.visible = 0
    self("imgGetCodeBindPhone").visible = 1

    local btnGetCodeBindPhone = self("btnGetCodeBindPhone")
    btnGetCodeBindPhone.touch = 1
    btnGetCodeBindPhone.gray = 0
    txtimePhone.text = self.timeSpace
end

function VBindPhoneDlg:ShowNextGetCodeTime(parameters)
    local txtimePhone = self("txtimePhone")
    local time = tonumber(txtimePhone.text) - 1
    if time <= 0 then
        self:StopTimer("ShowNextGetCodeTime");
        txtimePhone.visible = 0
        self("imgGetCodeBindPhone").visible = 1
        
        local btnGetCodeBindPhone = self("btnGetCodeBindPhone")
        btnGetCodeBindPhone.touch = 1
        btnGetCodeBindPhone.gray = 0
        txtimePhone.text = self.timeSpace
    else
        txtimePhone.text = time
    end
end

function VBindPhoneDlg:onOKClick()
    local code = self("edtCodeBindPhone"):getText()
    local phoneNum = self("edtPhoneNumBindPhone"):getText()

    if code ~= "" and phoneNum ~= "" then
        local aParam = {}
        aParam.value = phoneNum
        aParam.code = tonumber(code)
        aParam.binding_type = 10
        gView()("myInfoManageDlg"):ReqAccountBinding2(aParam)
        gWindow:showWaitTip()
    else
        gWindow:showTip("请输入验证码和电话", 1);
    end
end

function VBindPhoneDlg:onGetCodeClick()
    
    local phoneNum = self("edtPhoneNumBindPhone"):getText()

    if phoneNum ~= "" then
        local aParam = {}
        aParam.value = phoneNum
        aParam.binding_type = 10
        gView()("myInfoManageDlg"):ReqAccountBinding(aParam)
        gWindow:showWaitTip()
        
        self("txtimePhone").visible = 1

        self("imgGetCodeBindPhone").visible = 0
        
        local btnGetCodeBindPhone = self("btnGetCodeBindPhone")
        btnGetCodeBindPhone.touch = 0
        btnGetCodeBindPhone.gray = 1
        cclog("验证码获取时间间隔"..self.timeSpace)
        self:StartTimer("ShowNextGetCodeTime", 1, self.timeSpace - 1, 0)
    else
        gWindow:showTip("请输入要绑定的电话号码", 1);
    end
end