
require "vAlterPassWordDlg"
require "vBindPhoneDlg"
require "vBindStatusDlg"
require "vBindEmailDlg"

VMyInfoManageDlg = VClass("MyInfoManageDlg", VMsgBox)

function VMyInfoManageDlg:Init(attr)
    self.super.Init(self, attr)
    self.accountInfo = gData.accountInfo
end

function VMyInfoManageDlg:onPush()
--    self("titliText").image = "guanlizhanghu.png";
    self("txStatusMyInfoM").text = self.accountInfo:GetSafeLevel()
    self:SetItemInfo((not self.accountInfo:IsFirstAlterAccount()), "PassWordD", "未修改初始密码", "已修改初始密码")
    self:SetItemInfo(self.accountInfo.email, "EmailBindD", "未绑定邮箱", self.accountInfo.email)
    self:SetItemInfo(self.accountInfo.mobile, "PhoneD", "未绑定手机", self.accountInfo.mobile)
    self:SetItemInfo(self.accountInfo.id_card_number, "StatusD", "未实名认证", self.accountInfo.id_card_number)
end

function VMyInfoManageDlg:SetItemInfo(bl, itemName, contentF, contentT)
    if bl then
        self("tx"..itemName.."1MyInfoM").text = self:HideInfo(itemName, contentT)
        self("tx"..itemName.."1MyInfoM").color = "fc_14_"
        self("img"..itemName.."MyInfoM").image = "gerenziliaoyixuangai.png"
        self("img"..itemName.."3MyInfoM").image = "xiugai1.png"
    else
        self("tx"..itemName.."1MyInfoM").text = contentF
        self("tx"..itemName.."1MyInfoM").color = "fc_10_"
        self("img"..itemName.."MyInfoM").image = "gerenziliaoweixiugai.png"
        self("img"..itemName.."3MyInfoM").image = "bangding.png"
    end
end

function VMyInfoManageDlg:HideInfo(infoType, info)
    local text = info
    if infoType == "EmailBindD" then
        local start, endle = string.find(text, "@")
        if start and endle then
            local str = ""
            if start - 1 <= 4 then
                local count = math.ceil((start - 1) / 2)
                cclog("count"..count)
                str = string.sub(text, 1, start - 1 - count)
                for var = 1, count do
                    str = str.."*"
                end
                
                str = str.."@"
            else
                str = string.sub(text, 1, start - 5).."****@"
            end
            
            text = str..string.sub(text, endle + 1, -1)
        end
        
        
    elseif infoType == "PhoneD" then
        text = string.sub(text, 1, - 5).."****"
	    
    elseif infoType == "StatusD" then
        text = string.sub(text, 1, - 5).."****"    
	end
	
    return text
end

function VMyInfoManageDlg:SetRoleInfo(info)
    self.roleInfo = info
end

function VMyInfoManageDlg:onCloseClick()
    self:onClick()
end

function VMyInfoManageDlg:onAltPassWordClick()
    if self.accountInfo:IsFirstAlterAccount() then
        local alterIDDlg = VNode("vAlterIDDlg.vui");
        alterIDDlg:SetDlgAttribute(self.roleInfo, self, "ReqAccountUpdate")
--        alterIDDlg:setRoleInfo(self.roleInfo);
        gView():Push(alterIDDlg);
    else
        local alterPassWordDlg = VNode("vAlterPassWordDlg.vui");
        alterPassWordDlg:SetDlgAttribute(self.roleInfo, self, "ReqAccountUpdate")
        gView():Push(alterPassWordDlg);
    end
end

function VMyInfoManageDlg:onBindEmailClick()
    local bindEmailDlg = VNode("vBindEmailDlg.vui");
    bindEmailDlg:setRoleInfo(self.roleInfo);
    gView():Push(bindEmailDlg);
end

function VMyInfoManageDlg:onBindPhoneClick()
    local bindPhoneDlg = VNode("vBindPhoneDlg.vui");
    bindPhoneDlg:setRoleInfo(self.roleInfo);
    gView():Push(bindPhoneDlg);
end

function VMyInfoManageDlg:onBindStatusClick()
    local bindPhoneDlg = VNode("vBindStatusDlg.vui");
    bindPhoneDlg:setRoleInfo(self.roleInfo);
    gView():Push(bindPhoneDlg);
end

function VMyInfoManageDlg:ReqAccountUpdate(aParam)
    gReq:MsgReqAccountUpdate(self, "RspReqAccountUpdateBack", aParam)
end

function VMyInfoManageDlg:RspReqAccountUpdateBack(result, rsp, req)
    if result == 0 then
        self:ReqAccountUpdateSuccess(rsp, req)
    else
        self:ReqAccountUpdateFail()
    end
end


function VMyInfoManageDlg:ReqAccountUpdateSuccess(rsp, req)
    --    self("txNumMyI").text = req.self("txNumMyI").text
    local myInfoDlg = gView()("myInfoDlg")
    if req.new_name ~= nil and myInfoDlg ~= nil then
        myInfoDlg("txNameVMyI").text = req.new_name
    end
    if req.new_psw ~= nil then
        if myInfoDlg ~= nil then
            myInfoDlg("txSafeVMyI").text = gData.accountInfo:GetSafeLevel()
        end
        
        self("txStatusMyInfoM").text = gData.accountInfo:GetSafeLevel()
        self:SetItemInfo((not self.accountInfo:IsFirstAlterAccount()), "PassWordD", "未修改初始密码", "已修改初始密码")
    end
    
    local alterIDDlg = gView()("alterIDDlg")
    if alterIDDlg then
        alterIDDlg:doPop()
    end
    
    local alterPassWordDlg = gView()("alterPassWordDlg")
    if alterPassWordDlg then
        alterPassWordDlg:doPop()
    end
    
    gWindow:closeWaitTip()
    gWindow:showTip("修改账号成功", 1);
end

function VMyInfoManageDlg:ReqAccountUpdateFail()
    gWindow:closeWaitTip()
end

function VMyInfoManageDlg:ReqAccountBinding(aParam)
    gWindow:showWaitTip()
    gReq:MsgReqAccountBinding(self, "ReqAccountBindingBack", aParam)
end

function VMyInfoManageDlg:ReqAccountBindingBack(result, rsp, req)
    if result == 0 then
        self:ReqAccountBindingSuccess(rsp, req)
    else
        self:ReqAccountBindingFail()
    end
end


function VMyInfoManageDlg:ReqAccountBindingSuccess(rsp, req)
    local myInfoDlg = gView()("myInfoDlg")
    
    if gData.accountInfo:IsFirstBindEmail() and req.binding_type == 20 then -- 20是邮箱
        
       
            gData.accountInfo:UpDataEmail(req.value)
   
            self:SetItemInfo(self.accountInfo.email, "EmailBindD", "未绑定邮箱", self.accountInfo.email)
        self("txStatusMyInfoM").text = gData.accountInfo:GetSafeLevel()
        
        if gView()("bindEmailDlg") ~= nil then
            gView()("bindEmailDlg"):onClick()
        end

        gWindow:showTip("邮箱绑定成功", 1);
    else
        gWindow:showTip("验证码短信已经发送", 1);
    end
    if myInfoDlg ~= nil then
        myInfoDlg("txSafeVMyI").text = gData.accountInfo:GetSafeLevel()
    end
    gWindow:closeWaitTip()
end


function VMyInfoManageDlg:ReqAccountBindingFail()
    gWindow:closeWaitTip()
    local bindPhoneDlg = gView()("bindPhoneDlg")
    if  bindPhoneDlg then
        bindPhoneDlg:RecoveGetCode()
    end
    
    local bindStatusDlg = gView()("bindStatusDlg")
    if  bindStatusDlg then
        bindStatusDlg:RecoveGetCode()
    end
    
    local bindEmailDlg = gView()("bindEmailDlg")
    if  bindEmailDlg then
        bindEmailDlg:RecoveGetCode()
    end
end

function VMyInfoManageDlg:ReqAccountBinding2(aParam)
    gWindow:showWaitTip()
    gReq:MsgReqAccountBinding2(self, "ReqAccountBinding2Back", aParam)
end

function VMyInfoManageDlg:ReqAccountBinding2Back(result, rsp, req)
    if result == 0 then
        self:ReqAccountBinding2Success(rsp, req)
    else
        self:ReqAccountBinding2Fail()
    end
end


function VMyInfoManageDlg:ReqAccountBinding2Success(rsp, req)
    gWindow:closeWaitTip()

    local myInfoDlg = gView()("myInfoDlg")
    --    if myInfoManageDlg ~= nil then
    if req.binding_type == BindingType.BindingEmail then
        --            myInfoManageDlg("txEmailBindD1MyInfoM").text = req.value
        
        if gView()("bindEmailDlg") ~= nil then
            gView()("bindEmailDlg"):onClick()
        end
        
            self:SetItemInfo(self.accountInfo.email, "EmailBindD", "未绑定邮箱", self.accountInfo.email)
        self("txStatusMyInfoM").text = gData.accountInfo:GetSafeLevel()
       

        gWindow:showTip("邮箱绑定成功", 1);
    elseif req.binding_type == BindingType.BindingMobile then
        --            myInfoManageDlg("txPhoneD1MyInfoM").text = req.value
        
        if gView()("bindPhoneDlg") ~= nil then
            gView()("bindPhoneDlg"):onClick()
        end
        
        self:SetItemInfo(self.accountInfo.mobile, "PhoneD", "未绑定手机", self.accountInfo.mobile)
        self("txStatusMyInfoM").text = gData.accountInfo:GetSafeLevel()
       
        gWindow:showTip("手机绑定成功", 1);
    elseif req.binding_type == BindingType.BindingIdcard then
        --            myInfoManageDlg("txStatusD1MyInfoM").text = req.value
        
        if gView()("bindStatusDlg") ~= nil then
            gView()("bindStatusDlg"):onClick()
        end
        
        self:SetItemInfo(self.accountInfo.id_card_number, "StatusD", "未实名认证", self.accountInfo.id_card_number)
        self("txStatusMyInfoM").text = gData.accountInfo:GetSafeLevel()
        
        gWindow:showTip("实名认证成功", 1);
    end

    --    end

    if myInfoDlg ~= nil then
        myInfoDlg("txSafeVMyI").text = gData.accountInfo:GetSafeLevel()
    end

end


function VMyInfoManageDlg:ReqAccountBinding2Fail()
    gWindow:closeWaitTip()
end