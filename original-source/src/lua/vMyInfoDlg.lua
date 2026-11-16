
require "vAlterIDDlg"
require "vAlterPhotoDlg"
require "vMyInfoManageDlg"

VMyInfoDlg = VClass("MyInfoDlg", VMsgBox)

function VMyInfoDlg:Init(attr)
    self.super.Init(self, attr)
    self.accountInfo = gData.accountInfo
end

function VMyInfoDlg:onPush()
    self("backBtn").onClick = "node:Parent():onCloseClick()"
    if self.userInfo.isSelf then
        self:ShowMyInfo()
    else
        self:ShowOtherInfo()
    end
end

function VMyInfoDlg:SetHeadImageInfo(headImage, userBriefInfo)
--    cclog("~~~~~~userBriefInfo.image~~~~~"..userBriefInfo.image)
    headImage:setHead(userBriefInfo.id, userBriefInfo.image, nil, nil)
    
--    headImage.image = gData:headImage(self.userInfo.roleInfo.id, self.userInfo.roleInfo.image, true);
    headImage:SetHeadImageShader("zhezhao1.png")

--    headImage.image = gData:headImage(userBriefInfo.userid, userBriefInfo.image, nil)
--    local u_mask = {}
--    u_mask.type = "sampler2D"
--    u_mask.value = "touxiangkuangzhezhao.png"
--
--    local params = {};
--    params.u_mask = u_mask
--    headImage.headImage:Set_Shader("mask.fsh", "", true, params);
--    headImage:SetHeadImageShader()

--    txtVIP.text = "v"..userBriefInfo.vipInfo[0];
end

function VMyInfoDlg:ShowMyInfo()
    self("txIDMyI").text = "ID : "..self.userInfo.roleInfo.id
    self("txNameVMyI").text = " "..self.accountInfo.name
    self("txNickVMyI").text = " "..self.userInfo.roleInfo.nick or ""
    self("txSexVMyI").text = " "..self:GetSexTextwithNum(self.userInfo.roleInfo.sex)
    
    self:SetHeadImageInfo(self("imgHeadMyInfoDlg"), self.userInfo.roleInfo)
    
--    self:SetHeadImageInfo(self("imgHeadMyInfoDlg"), self.userInfo.roleInfo)
--    self("imgHeadMyInfoDlg"):setHead(self.userInfo.roleInfo.userid, self.userInfo.roleInfo.image, nil, nil)
    --    self("txNumMyI").text = self.userInfo.roleInfo.desc
    self("txSafeVMyI").text = self.accountInfo:GetSafeLevel()
    
    self("imgShowMyI").visible = 1

    local itemCommon = gData:LoadItemCommon()

    -- if self.userInfo.roleInfo.nickChange ~= nil and self.userInfo.roleInfo.nickChange ~= 0 then
    --         self("imgNickResMyI").visible = 1
    --         self("txNickResMyI").text = itemCommon.nickCost or 499
    -- else
    --     self("imgNickResMyI").visible = 0
    -- end
end

function VMyInfoDlg:ShowOtherInfo()
    
    self("txIDOMyI").text = "ID："..self.userInfo.roleInfo.id
    self("txNickVOMyI").text = self.userInfo.roleInfo.nick or ""
    self("txSexVOMyI").text = self:GetSexTextwithNum(self.userInfo.roleInfo.sex)
    self("imgHeadOMyI").image = gData:headImage(self.userInfo.roleInfo.id, self.userInfo.roleInfo.image, true);
    
    self:SetHeadImageInfo(self("imgHeadOMyI"), self.userInfo.roleInfo)
    --    self("txNumMyI").text = self.userInfo.roleInfo.desc
    if gData:isMyFriend(self.userInfo.roleInfo.id) then
        self("btnAddFriendOMyI").gray = 1
    end
    
    self("imgShowOtherMyI").visible = 1
end

function VMyInfoDlg:headImageDidChanged()
    self("imgHeadMyInfoDlg").image = gData:headImage(self.userInfo.roleInfo.id, self.userInfo.roleInfo.image, true);
    self("imgHeadMyInfoDlg"):SetHeadImageShader("zhezhao1.png")
end

function VMyInfoDlg:SetRoleInfo(info)
    self.userInfo = info
end

function VMyInfoDlg:onCloseClick()
    local edNameMyI = self("edNameMyI")
    local edNickMyI = self("edNickMyI")
    local lyrCheckSex = self("lyrCheckSex")
    
    if (edNameMyI.visible and edNameMyI:getText() ~= "") or
        (edNickMyI.visible and edNickMyI:getText() ~= "") or
        lyrCheckSex.visible then
        gWindow:showConfirmTip("信息修改未保存，确定要返回么", "确定", "取消", self, "onClick", nil, "确定返回吗?")
        return
    end
    
    self:onClick()
end

function VMyInfoDlg:GetSexTextwithNum(sexNum)
    if sexNum == 2 then
        return "男"
    else
        return "女"
    end
end

function VMyInfoDlg:onNameClick()
    if self.accountInfo:IsFirstAlterAccount() then
        local alterIDDlg = VNode("vAlterIDDlg.vui");
--        alterIDDlg:setRoleInfo(self.userInfo.roleInfo);
        alterIDDlg:SetDlgAttribute(self.userInfo.roleInfo, self, "ReqAccountUpdate")
        gView():Push(alterIDDlg);
    else
        local bl = self("edNameMyI").visible
        if bl then
            local newName = self("edNameMyI"):getText()

            local aParam = {}
            aParam.old_psw = self.accountInfo.psw
--            if (aParam.old_psw ~= nil or aParam.old_psw ~= "") and newName ~= "" then
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
            
                aParam.new_name = newName
                self:ReqAccountUpdate(aParam)
--            else
                           gWindow:showWaitTip()
--            end
            self("edNameMyI").text = ""
            self("imgNameMyI").image = "xiugai.png"
        else
            self("edNameMyI").placeHolder = self.accountInfo.name
            self("imgNameMyI").image = "queding.png"
        end
        self("edNameMyI").visible = not bl
        self("txNameVMyI").visible = bl
    end  
end

function VMyInfoDlg:onNickClick()
--    local alterNickDlg = VNode("vAlterNickDlg.vui");
--    alterNickDlg:setRoleInfo(self.userInfo.roleInfo);
--    self:Push(alterNickDlg);
    cclog("昵称:"..(self.userInfo.roleInfo.nick or "ffffffffffffffffffffff"))
    local itemCommon = gData:LoadItemCommon()
    if (self.userInfo.roleInfo.nickChange ~= nil and self.userInfo.roleInfo.nickChange ~= 0) and gData:attrValue(AttrType.AttrTypeCurrency) < (itemCommon.nickCost or 499) then
        gWindow:showMoneyLackDlg(itemCommon.nickCost)
        return
    end
    
    local bl = self("edNickMyI").visible
    if bl then
        local nick = self("edNickMyI"):getText()
        
        nick = gData:Trim(nick)
        
        cclog("昵称长度:"..nick)
        
        local len = gData:CaleChineseLen(nick)

        cclog("字符长度:"..len)
        
        if len < 1 then
            gWindow:showTip("昵称不能为空", 1);
            return
        end  
        if len > 12 then
            gWindow:showTip("昵称最长6个中文，或者12个英文和数字", 1);
            return
        end
        
        local aParam = {}
        aParam.nick = nick
        self("edNickMyI").text = "" 
        self("imgNickMyI").image = "xiugai.png"

        self("imgNickResMyI").visible = 0
        -- if self.userInfo.roleInfo.nickChange ~= nil and self.userInfo.roleInfo.nickChange ~= 0 then
        --     gWindow:showPayTip("修改昵称吗？", "修改昵称需要消耗"..(itemCommon.nickCost or 499).."钻石", (itemCommon.nickCost or 499), self, "ReqPlayerUpdate", aParam);
        -- else
            self:ReqPlayerUpdate(aParam)
        -- end
        
        
    else
        self("edNickMyI").placeHolder = self.accountInfo.nick
        self("imgNickMyI").image = "queding.png"

         if self.userInfo.roleInfo.nickChange ~= nil and self.userInfo.roleInfo.nickChange ~= 0 then
            self("imgNickResMyI").visible = 1
            self("txNickResMyI").text = itemCommon.nickCost or 499
        end
        
        
    end
    self("edNickMyI").visible = not bl
    self("txNickVMyI").visible = bl
end

function VMyInfoDlg:onSexClick()
    local bl = self("lyrCheckSex").visible
    if bl then
        local visible = self("imgSexWMyI").visible
        local aParam = {}
        if visible then          
            aParam.sex = 1
        else
            aParam.sex = 2
        end
        self:ReqPlayerUpdate(aParam)
        gWindow:showWaitTip()
        self("imgSexMyI").image = "xiugai.png"
    else
        if self.userInfo.roleInfo.sex == 1 then
            self("imgSexWMyI").visible = 1
            self("imgSexMMyI").visible = 0
        else
            self("imgSexWMyI").visible = 0
            self("imgSexMMyI").visible = 1
        end
        self("imgSexMyI").image = "queding.png"
    end
    self("lyrCheckSex").visible = not bl
    self("txSexVMyI").visible = bl
end

function VMyInfoDlg:onSafeClick()
    local myInfoManageDlg = VNode("vMyInfoManageDlg.vui");
    myInfoManageDlg:SetRoleInfo(self.userInfo.roleInfo);
    self:Push(myInfoManageDlg);
end

function VMyInfoDlg:onPhotoClick()
    gWindow:showTip("敬请期待", 1)
end


function VMyInfoDlg:AddFriendClick(parameters)
    if gData:isMyFriend(self.userInfo.roleInfo.id) then
        self("btnAddFriendOMyI").touch = 0
        gWindow:showTip("对方已是好友", 1)
        return
    end
    if gData.userInfo.friendInfos:friendCount() < gData.userInfo.friendInfos.friendLimit then
            -- gReq:MsgReqFriendAdd(self, "OpCallBack", aParam)
        else
            gWindow:showTip("好友已达到上限,无法添加")
            return
        end
	self:ReqFriendAdd()
end


function VMyInfoDlg:ReqFriendAdd()
    local aParam = {}
    aParam.userid = self.userInfo.roleInfo.id
    aParam.nick = self.userInfo.roleInfo.nick

    gReq:MsgReqFriendAdd(self, "ReqFriendAddCallBack", aParam)
end

function VMyInfoDlg:ReqFriendAddCallBack(result, rsp, req)
    if result == 0 then
        self:ReqFriendAddSuccess(rsp, req)
    else
        self:ReqFriendAddFail()
    end
end


function VMyInfoDlg:ReqFriendAddSuccess(rsp, req)
    gData.userInfo.friendInfos:AddFriend(req.userid)

--    self:InitFriendList()
--    self:ReqFriendsInfo()

    gWindow:showNormalTip(req.nick.."已成为你的好友", "添加成功")

    self("btnAddFriendOMyI").touch = 0
    
    self("btnAddFriendOMyI").gray = 1
--    local cell = self("tbSearch"):cellAtIndex(req.pos)
--
--    if cell ~= nil then
--        cell:UpDataCell()
--    end
end

function VMyInfoDlg:ReqFriendAddFail()

end


function VMyInfoDlg:onHeadCClick()
    local alterPhotoDlg = VNode("vAlterPhotoDlg.vui");
    alterPhotoDlg:setRoleInfo(self.userInfo.roleInfo);
    self:Push(alterPhotoDlg);
end

function VMyInfoDlg:ChooseSex(imgSexMyI1, imgSexMyI2)
    local bl = self(imgSexMyI1).visible
    if bl ~= true then
        self(imgSexMyI1).visible = not bl
        self(imgSexMyI2).visible = bl
    end
end

function VMyInfoDlg:ReqPlayerUpdate(aParam)
    gWindow:showWaitTip()
    
    gReq:MsgReqPlayerUpdate(self, "RspPlayerUpdateCallBack", aParam)
end

function VMyInfoDlg:RspPlayerUpdateCallBack(result, rsp, req)
    if result == 0 then
        self:RspPlayerUpdateSuccess(rsp, req)
    else
        self:RspPlayerUpdateFail()
    end
end


function VMyInfoDlg:RspPlayerUpdateSuccess(rsp, req)
--    self("txNumMyI").text = req.self("txNumMyI").text
    if req.nick ~= nil and self("txNickVMyI") ~= nil then
        self("txNickVMyI").text = req.nick
    end
    if req.sex ~= nil  and self("txSexVMyI") ~= nil then
        self("txSexVMyI").text = (" "..self:GetSexTextwithNum(req.sex))


        self:headImageDidChanged();
        if gMainView then
            gMainView:refreshUserHeadImage();
        end
    end
    if req.image ~= nil  and self("imgHeadMyInfoDlg") ~= nil then
        -- self("imgHeadMyInfoDlg").image = req.image
        -- gData.userInfo.roleInfo:UpDataImage(req.image)
    end
    gWindow:closeWaitTip()
    gWindow:showTip("修改人物信息成功", 1);
end


function VMyInfoDlg:RspPlayerUpdateFail()
    gWindow:closeWaitTip()
end

function VMyInfoDlg:ReqAccountUpdate(aParam)
    gReq:MsgReqAccountUpdate(self, "RspReqAccountUpdateBack", aParam)
end

function VMyInfoDlg:RspReqAccountUpdateBack(result, rsp, req)
    
    if result == 0 then
        self:ReqAccountUpdateSuccess(rsp, req)
    else
        self:ReqAccountUpdateFail()
    end
end


function VMyInfoDlg:ReqAccountUpdateSuccess(rsp, req)
    --    self("txNumMyI").text = req.self("txNumMyI").text
    
    if req.new_name ~= nil and self("txNameVMyI") ~= nil then
        self("txNameVMyI").text = req.new_name
    end
    if req.new_psw ~= nil and self("txSafeVMyI") ~= nil then
        self("txSafeVMyI").text = self.accountInfo:GetSafeLevel()
        local myInfoManageDlg = gView()("myInfoManageDlg")
        if myInfoManageDlg ~= nil then
            myInfoManageDlg("txStatusMyInfoM").text = self.accountInfo:GetSafeLevel()
            myInfoManageDlg:SetItemInfo((not self.accountInfo:IsFirstAlterAccount()), "PassWordD", "未修改初始密码", "已修改初始密码")
        end
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

function VMyInfoDlg:ReqAccountUpdateFail()
    gWindow:closeWaitTip()
end

function VMyInfoDlg:ReqAccountBinding(aParam)
    gReq:MsgReqAccountBinding(self, "ReqAccountBindingBack", aParam)
end

function VMyInfoDlg:ReqAccountBindingBack(result, rsp, req)
    if result == 0 then
        self:ReqAccountBindingSuccess(rsp, req)
    else
        self:ReqAccountBindingFail()
    end
end


function VMyInfoDlg:ReqAccountBindingSuccess(rsp, req)
    local myInfoManageDlg = gView()("myInfoManageDlg")
    cclog("")
    if gData.accountInfo:IsFirstBindEmail() and req.binding_type == 20 then -- 20是邮箱
    cclog("111111111111111111")
--        myInfoManageDlg("txEmailBindD1MyInfoM").text = req.value
        self.accountInfo:UpDataEmail(req.value)  
        if myInfoManageDlg ~= nil then
            cclog("2222222222222")
            myInfoManageDlg:SetItemInfo(self.accountInfo.email, "EmailBindD", "未绑定邮箱", self.accountInfo.email)
            myInfoManageDlg("txStatusMyInfoM").text = self.accountInfo:GetSafeLevel()
        end
        if gView()("bindEmailDlg") ~= nil then
            cclog("33333333333333333")
            gView()("bindEmailDlg"):onClick()
        end
        
        gWindow:showTip("邮箱绑定成功", 1);
    else
        gWindow:showTip("验证码短信已经发送", 1);
    end
    if self("txSafeVMyI") ~= nil then
        cclog("4444444444444444")
        self("txSafeVMyI").text = self.accountInfo:GetSafeLevel()
    end
    gWindow:closeWaitTip()
end


function VMyInfoDlg:ReqAccountBindingFail()
    gWindow:closeWaitTip()
end

function VMyInfoDlg:ReqAccountBinding2(aParam)
    gReq:MsgReqAccountBinding2(self, "ReqAccountBinding2Back", aParam)
end

function VMyInfoDlg:ReqAccountBinding2Back(result, rsp, req)
    if result == 0 then
        self:ReqAccountBinding2Success(rsp, req)
    else
        self:ReqAccountBinding2Fail()
    end
end


function VMyInfoDlg:ReqAccountBinding2Success(rsp, req)
    gWindow:closeWaitTip()
    
    local myInfoManageDlg = gView()("myInfoManageDlg")
--    if myInfoManageDlg ~= nil then
        if req.binding_type == BindingType.BindingEmail then
--            myInfoManageDlg("txEmailBindD1MyInfoM").text = req.value
        self.accountInfo:UpDataEmail(req.value)
            if gView()("bindEmailDlg") ~= nil then
                gView()("bindEmailDlg"):onClick()
            end
            if myInfoManageDlg ~= nil then
                myInfoManageDlg:SetItemInfo(self.accountInfo.email, "EmailBindD", "未绑定邮箱", self.accountInfo.email)
            myInfoManageDlg("txStatusMyInfoM").text = self.accountInfo:GetSafeLevel()
            end
            
        gWindow:showTip("邮箱绑定成功", 1);
        elseif req.binding_type == BindingType.BindingMobile then
--            myInfoManageDlg("txPhoneD1MyInfoM").text = req.value
        self.accountInfo:UpDataPhone(req.value)
            if gView()("bindPhoneDlg") ~= nil then
                gView()("bindPhoneDlg"):onClick()
            end
            if myInfoManageDlg ~= nil then
            myInfoManageDlg:SetItemInfo(self.accountInfo.mobile, "PhoneD", "未绑定手机", self.accountInfo.mobile)
            myInfoManageDlg("txStatusMyInfoM").text = self.accountInfo:GetSafeLevel()
            end
        gWindow:showTip("手机绑定成功", 1);
        elseif req.binding_type == BindingType.BindingIdcard then
--            myInfoManageDlg("txStatusD1MyInfoM").text = req.value
        self.accountInfo:UpDataIDCard(req.value)
            if gView()("bindStatusDlg") ~= nil then
                gView()("bindStatusDlg"):onClick()
            end
            if myInfoManageDlg ~= nil then
            myInfoManageDlg:SetItemInfo(self.accountInfo.id_card_number, "StatusD", "未实名认证", self.accountInfo.id_card_number)
            myInfoManageDlg("txStatusMyInfoM").text = self.accountInfo:GetSafeLevel()
            end
        gWindow:showTip("实名认证成功", 1);
        end
        
--    end
    
    if self("txSafeVMyI") ~= nil then
        self("txSafeVMyI").text = self.accountInfo:GetSafeLevel()
    end
    
end


function VMyInfoDlg:ReqAccountBinding2Fail()
    gWindow:closeWaitTip()
end