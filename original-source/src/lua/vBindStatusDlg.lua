
VBindStatusDlg = VClass("BindStatusDlg", VMsgBox)

function VBindStatusDlg:Init(attr)
    self.super.Init(self, attr)
    self.accountInfo = gData.accountInfo
    self.timeSpace = 60
end

function VBindStatusDlg:onPush()
    local txtimeStatus = self("txtimeStatus")
    txtimeStatus.text = self.timeSpace
end

function VBindStatusDlg:setRoleInfo(info)
    self.roleInfo = info
end

function VBindStatusDlg:onCloseClick()
    local edtStatusNumBindStatus = self("edtStatusNumBindStatus")
    local edtCodeBindStatus = self("edtCodeBindStatus")

    if (edtStatusNumBindStatus.visible and edtStatusNumBindStatus:getText() ~= "") or
        (edtCodeBindStatus.visible and edtCodeBindStatus:getText() ~= "") then
        gWindow:showConfirmTip("实名认证未完成,确定返回吗", "确定", "取消", self, "onClick", nil, "确定返回吗?")
        return
    end
    
    self:onClick()
end

function VBindStatusDlg:RecoveGetCode(parameters)
    self:StopTimer("ShowNextGetCodeTime");
    local txtimeStatus = self("txtimeStatus")

    txtimeStatus.visible = 0
    self("imgGetCodeBindStatus").visible = 1

    local btnGetCodeBindStatus = self("btnGetCodeBindStatus")
    btnGetCodeBindStatus.touch = 1
    btnGetCodeBindStatus.gray = 0
    txtimeStatus.text = self.timeSpace
end

function VBindStatusDlg:ShowNextGetCodeTime(parameters)
    local txtimeStatus = self("txtimeStatus")
    local time = tonumber(txtimeStatus.text) - 1
    if time <= 0 then
        self:StopTimer("ShowNextGetCodeTime");
        txtimeStatus.visible = 0
        self("imgGetCodeBindStatus").visible = 1

        local btnGetCodeBindStatus = self("btnGetCodeBindStatus")
        btnGetCodeBindStatus.touch = 1
        btnGetCodeBindStatus.gray = 0
        txtimeStatus.text = self.timeSpace
    else
        txtimeStatus.text = time
    end
end

function VBindStatusDlg:onOKClick()
    local code = self("edtCodeBindStatus"):getText()
    local statusNum = self("edtStatusNumBindStatus"):getText()

    if code ~= "" and statusNum ~= "" then
        local aParam = {}
        aParam.value = statusNum
        aParam.code = tonumber(code)
        aParam.binding_type = 30
        gView()("myInfoManageDlg"):ReqAccountBinding2(aParam)
        gWindow:showWaitTip()
    else
        gWindow:showTip("请输入验证码和身份证号", 1);
    end
end

function VBindStatusDlg:onGetCodeClick()
    if not self.accountInfo:IsBindPhone() then
        gWindow:showTip("请先绑定手机", 1);
        return
    end
    local statusNum = self("edtStatusNumBindStatus"):getText()

    if statusNum ~= "" then
        local aParam = {}
        aParam.value = statusNum
        aParam.binding_type = 30
        gView()("myInfoManageDlg"):ReqAccountBinding(aParam)
        
        self("txtimeStatus").visible = 1

        self("imgGetCodeBindStatus").visible = 0

        local btnGetCodeBindStatus = self("btnGetCodeBindStatus")
        btnGetCodeBindStatus.touch = 0
        btnGetCodeBindStatus.gray = 1

        self:StartTimer("ShowNextGetCodeTime", 1, self.timeSpace - 1, 0)
        
        gWindow:showWaitTip()
    else
        gWindow:showTip("请输入身份证号码", 1);
    end
end