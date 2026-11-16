
VAlterPassWordDlg = VClass("AlterPassWordDlg", VMsgBox)

function VAlterPassWordDlg:Init(attr)
    self.super.Init(self, attr)
    self.accountInfo = gData.accountInfo
end

function VAlterPassWordDlg:onPush()
    
end

function VAlterPassWordDlg:SetDlgAttribute(info, delege, callBack)
    self.roleInfo = info
    self.delege = delege
    self.callBack = callBack
end

function VAlterPassWordDlg:setRoleInfo(info)
    self.roleInfo = info
end

function VAlterPassWordDlg:onCloseClick()
    self:onClick()
end

function VAlterPassWordDlg:onSaveClick()
    local oldPsw = self("edtOldPassWordAlterPassWord"):getText()
    local newPsw = self("edtNewPassWordAlterPassWord"):getText()
    local newPswT = self("edtPassWordTAlterPassWord"):getText()
    
    
    
    cclog("修改密码"..oldPsw.."~~~~~~"..newPsw)

    local aParam = {}
    
    if oldPsw == newPsw then
        gWindow:showTip("新密码不能和旧密码一致", 1);
        return
    end
--    aParam.old_psw = self.accountInfo.psw
    if string.len(oldPsw) < 4 or string.len(oldPsw) > 16 then
        gWindow:showTip("旧密码不符合要求,长度需要在4到16个字符之间", 1);
        return
    end
    if string.len(newPsw) < 4 or string.len(newPsw) > 16 then
        gWindow:showTip("新密码不符合要求,长度需要在4到16个字符之间", 1);
        return
    end
    if newPsw ~= newPswT then
        gWindow:showTip("两次输入密码不一致", 1);
        return
    end

--    if newPsw ~= "" and oldPsw ~= "" then
        aParam.new_psw = makePswMd5(newPsw)
        aParam.old_psw = makePswMd5(oldPsw)
--    else
--        return
--    end

--    gView()("myInfoDlg"):ReqAccountUpdate(aParam)
    VCallBack(self.delege, self.callBack, aParam)
    gWindow:showWaitTip()
--    self:onClick()
end