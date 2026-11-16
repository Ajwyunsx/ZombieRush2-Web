
VBindEmailDlg = VClass("BindEmailDlg", VMsgBox)

function VBindEmailDlg:Init(attr)
    self.super.Init(self, attr)
    self.accountInfo = gData.accountInfo
    self.timeSpace = 60
end

function VBindEmailDlg:onPush()
    if self.accountInfo:IsFirstBindEmail() then
        self("lyrStep").visible = 0
        self("edtEmailNumBindEmail").visible = 0
        self("edtCodeBindEmail").visible = 0
        self("lyrFirstBind").visible = 1
        self("edtEmailBindEmail").visible = 1
        self("edtEmailBindEmail").inputMode = _VEditorInputMode.Email
    else
        self("lyrStep").visible = 1
        self("edtEmailNumBindEmail").visible = 1
        self("edtCodeBindEmail").visible = 1
        self("lyrFirstBind").visible = 0
        self("edtEmailBindEmail").visible = 0
        self("edtEmailNumBindEmail").inputMode = _VEditorInputMode.Email
        local txtimeEmail = self("txtimeEmail")
        txtimeEmail.text = self.timeSpace
    end
end

function VBindEmailDlg:setRoleInfo(info)
    self.roleInfo = info
end

function VBindEmailDlg:onCloseClick()
    local edtEmailNumBindEmail = self("edtEmailNumBindEmail")
    local edtEmailBindEmail = self("edtEmailBindEmail")
    local edtCodeBindEmail = self("edtCodeBindEmail")

    if (edtEmailNumBindEmail.visible and edtEmailNumBindEmail:getText() ~= "") or
        (edtCodeBindEmail.visible and edtCodeBindEmail:getText() ~= "") or
        (edtEmailBindEmail.visible and edtEmailBindEmail:getText() ~= "") then
        gWindow:showConfirmTip("邮箱绑定未完成,确定返回吗", "确定", "取消", self, "onClick", nil, "确定返回吗?")
        return
    end
    
    self:onClick()
end

function VBindEmailDlg:ShowNextGetCodeTime(parameters)
    local txtimeEmail = self("txtimeEmail")
    local time = tonumber(txtimeEmail.text) - 1
    if time <= 0 then
        self:StopTimer("ShowNextGetCodeTime");
        txtimeEmail.visible = 0
        self("imgGetCodeBindEmail").visible = 1
        
        local btnGetCodeBindEmail = self("btnGetCodeBindEmail")
        btnGetCodeBindEmail.touch = 1
        btnGetCodeBindEmail.gray = 0
        txtimeEmail.text = self.timeSpace
    else
        txtimeEmail.text = time
    end
end

function VBindEmailDlg:RecoveGetCode(parameters)
    self:StopTimer("ShowNextGetCodeTime");
    local txtimeEmail = self("txtimeEmail")

    txtimeEmail.visible = 0
    self("imgGetCodeBindEmail").visible = 1

    local btnGetCodeBindEmail = self("btnGetCodeBindEmail")
    btnGetCodeBindEmail.touch = 1
    btnGetCodeBindEmail.gray = 0
    txtimeEmail.text = self.timeSpace
end

function VBindEmailDlg:onOKClick()
    if self.accountInfo:IsFirstBindEmail() then
        self:onGetCodeClick()
    else
        local code = self("edtCodeBindEmail"):getText()
        local emailNum = self("edtEmailNumBindEmail"):getText()
    
        if code ~= "" and emailNum ~= "" then
            local aParam = {}
            aParam.value = emailNum
            aParam.code = tonumber(code)
            aParam.binding_type = 20
            gView()("myInfoManageDlg"):ReqAccountBinding2(aParam)
            gWindow:showWaitTip()
        else
            gWindow:showTip("请输入验证码和Email地址", 1);
        end
    end
end

function VBindEmailDlg:onGetCodeClick()
    local Email = self("edtEmailNumBindEmail"):getText()
    
    if not self.accountInfo:IsFirstBindEmail() and not self.accountInfo:IsBindPhone() then
        gWindow:showTip("请先绑定手机", 1);
        return
    end
    
    if Email == "" or Email == nil then
        Email = self("edtEmailBindEmail"):getText()
    else
    
    end

    if Email ~= nil and Email ~= "" then
    
        
        
        local aParam = {}
        aParam.value = Email
        aParam.binding_type = 20
        gView()("myInfoManageDlg"):ReqAccountBinding(aParam)
        gWindow:showWaitTip()
        self("txtimeEmail").visible = 1
   
        self("imgGetCodeBindEmail").visible = 0
        
        local btnGetCodeBindEmail = self("btnGetCodeBindEmail")
        btnGetCodeBindEmail.touch = 0
        btnGetCodeBindEmail.gray = 1
        
        self:StartTimer("ShowNextGetCodeTime", 1, self.timeSpace - 1, 0)
    else
        gWindow:showTip("请输入Email地址", 1);
    end
    
end