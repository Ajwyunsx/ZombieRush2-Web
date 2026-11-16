
VAlterIDDlg = VClass("AlterIDDlg", VMsgBox)

function VAlterIDDlg:Init(attr)
    self.super.Init(self, attr)
    self.accountInfo = gData.accountInfo
end

function VAlterIDDlg:onPush()
    self("artUp"):play("idle")
    self.edtNewIDFAlterID = self("edtNewIDFAlterID");
    if self.accountInfo:IsFirstAlterAccount() then
        self("lyrFirstAlter").visible = 1
        self("edtNewIDFAlterID").visible = 1;
        self("edtPassWordFAlterID").visible = 1;
--        self("txTitleAlterID").text = "修改账号/密码"
    else
        self("lyrAlterIDD").visible = 1
        self("edtNewIDAlterID").visible = 1;
--        self("txTitleAlterID").text = "修改账号/密码"
    end
    
    self("txIDFAlterID").text = self.accountInfo.name
end

function VAlterIDDlg:SetDlgAttribute(info, delege, callBack)
	self.roleInfo = info
    self.delege = delege
    self.callBack = callBack
end

function VAlterIDDlg:setRoleInfo(info)
    self.roleInfo = info
end

function VAlterIDDlg:onCloseClick()
    local edtNewIDFAlterID = self("edtNewIDFAlterID")
    local edtPassWordFAlterID = self("edtPassWordFAlterID")

    if edtNewIDFAlterID:getText() ~= "" or
        edtPassWordFAlterID:getText() ~= "" then
        gWindow:showConfirmTip("修改信息还没保存,确定退出吗", "确定", "取消", self, "onClick", nil, "确定退出吗")
        return
    end
    self:onClick()
end

function VAlterIDDlg:onSaveClick()
    local newName = self.edtNewIDFAlterID:getText();
    local newPsw = self("edtPassWordFAlterID"):getText()
    cclog("修改账号"..newName.."~~~~~~"..newPsw)
    
    local aParam = {}
    
    aParam.old_psw = self.accountInfo.psw
    
--    if newPsw ~= "" and self.accountInfo:IsFirstAlterAccount() then
    aParam.new_psw = makePswMd5(newPsw)
    
    if newName ~= "" then
        aParam.new_name = newName
        
        newName = gData:Trim(newName)
        
        local len = gData:CaleChineseLen(newName)
        
        cclog("字符长度:"..len)
        
        if len < 1 then
            gWindow:showTip("账号名不能为空", 1);
            return
        end  
        if len > 12 then
            gWindow:showTip("账号最长6个中文，或者12个英文和数字", 1);
            return
        end
    end
    
    if string.len(newPsw) < 4 or string.len(newPsw) > 16 then
        gWindow:showTip("密码长度需要在4到16个字符之间", 1);
        return
    end
    
    cclog("第一次修改账号密码")
--    elseif not self.accountInfo:IsFirstAlterAccount() then
--        newName = self("edtNewIDAlterID"):getText()
--        if newName == "" then
--            return
--        end
--        
--        aParam.new_name = newName
--    end
    
    cclog("发送修改账号密码请求")
--    gWindow:showWaitTip("Req...");
--    gView()("myInfoDlg"):ReqAccountUpdate(aParam)
    VCallBack(self.delege, self.callBack, aParam)
    gWindow:showWaitTip()
--    self:onClick()
end