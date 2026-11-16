VFriendCell = VClass("FriendCell", VTableViewCell)

function VFriendCell:Recover(count, cellType)
    self.info = {}
    
    for i = 1, count do
        local item = self("imgBackGroundBagC"..i)
        item("txSayFriendl").text = ""
        item("txTimeFriendl").text = ""
        item("imgRedBtnFriendl").visible = 0
        if cellType == "DELET" then
            item("imgMassege").visible = false
            item("btnDeletChose").visible = true
            item("imgManChatBg").visible = false
            item("txTimeFriendl").visible = true
        else
            item("imgMassege").visible = true
            item("btnDeletChose").visible = false
            item("txTimeFriendl").visible = false
        end
        item.visible = false
    end
end

function VFriendCell:SetInfo(idx, count, data, cellType)
    for i = 1, count do
        local info = data[idx * count + i]

        if info then
            local item = self("imgBackGroundBagC"..i)

            local manager = gData.chatInfo:managerWithId(info.userid)
            if manager then
                if string.len(manager:newestMessage()) > 24 then
                    item("txSayFriendl").text = stringSub(manager:newestMessage(), 1, 24).."..."
                else
                    item("txSayFriendl").text = manager:newestMessage()
                end
                item("txTimeFriendl").text = os.date("%Y-%m-%d %X", manager:newestTime());
            end

            -- self("txNameFriendl").offset = {10, -25}
            -- self("txLevelFriendl").visible = 0


            if info.newCount ~= 0 and info.newCount ~= nil then
                item("imgRedBtnFriendl").visible = 1
                item("txtUnreadBtnFriendl").text = info.newCount
            end
            
            self:SetHeadImageInfo(item("imgFriendFriendl"), info)

            item("txNickFriendl").text = info.nick

            item("txSexFriendl").text = self:GetSexString(info.sex)
            
            if cellType == "DELET" then
                item("txLevelFriendl").text = "Lv"..(info.level or 0)--os.date("最后登录 %Y-%m-%d", info.last_login_time);
                item("txTimeFriendl").text = os.date("最后登录 %Y-%m-%d", info.last_login_time); --"LV"..(info.level or 0)
                local deleteChoise = gView()("friendManageDlg"):GetDeletChoise()
                if deleteChoise[info.userid] then
                    item("imgManChatBg").visible = true
                end
                
                item("lyname").step = {0,-1}
                item("txNickFriendl").fontSize = "fs_14"
                item("lysex").step = {0,0}
                item("txSexFriendl").color = "fc_6_"
                item("txSexFriendl").fontSize = "fs_14"
                item("lytime").step = {0,0.96}
                item("txTimeFriendl").color = "fc_6_"
                item("txTimeFriendl").fontSize = "fs_14"
                item("lytime"):ReLayout();
            else
                item("txLevelFriendl").text = "Lv"..(info.level or 0)
                item("lyname").step = {0,-0.6}
                item("txNickFriendl").fontSize = "fs_18"
                item("lysex").step = {0,0.6}
                item("txSexFriendl").color = "fc_8_"
                item("txSexFriendl").fontSize = "fs_18"
            end

            -- info.hasAdd = gData:isMyFriend(info.userid)
            -- self("imgBackGroundFriendl").visible = 1

            table.insert(self.info, info)

            item.visible = true
        end
    end
end

function VFriendCell:GetSexString(sex)
    if sex ~= 2 then
        return "女"
    else
        return "男"
    end
end

function VFriendCell:SetHeadImageInfo(headImage, userBriefInfo)
    headImage:setHead(userBriefInfo.userid, userBriefInfo.image, nil, gData:GetVipLevel(userBriefInfo.charge))
    
    headImage:SetHeadImageShader()
    
--    local u_mask = {}
--    u_mask.type = "sampler2D"
--    u_mask.value = "zhezhao2.png"
--
--    local params = {};
--    params.u_mask = u_mask
--    headImage.headImage:Set_Shader("mask.fsh", "zhezhao2.png", true, params);

--    txtVIP.text = "v"..userBriefInfo.vipInfo[0];
end

function VFriendCell:UpDataMessage( manager, itemIndex )
    -- body
    local item = self("imgBackGroundBagC"..itemIndex)

    if string.len(manager:newestMessage()) > 105 then
        item("txSayFriendl").text = stringSub(manager:newestMessage(), 1, 102).."..."
    else
        item("txSayFriendl").text = manager:newestMessage()
    end
    item("txTimeFriendl").text = os.date("%Y-%m-%d %X", manager:newestTime());
    local privatChatDlg = gView()("privatChatDlg");
    if not privatChatDlg then
        item("imgRedBtnFriendl").visible = 1
        item("txtUnreadBtnFriendl").text = manager.newCount
    end
end

function VFriendCell:onOpenPlayerOperateDlg(index)
    local dlg = VNode("vPlayerOperateDlg.vui")
    -- dlg:SetUserInfo(self.info[index], gView()("societyDlg"))
    
    dlg:SetUserInfo(self.info[index], 1, gView()("societyDlg"), "ReqFriendDelCallBack")
    gView():Push(dlg)
end

function VFriendCell:DeletChoise( index )
    -- body
    local item = self("imgBackGroundBagC"..index)
    local visible = item("imgManChatBg").visible

    if visible ~= true then
        gView()("friendManageDlg"):DeletChoise(self.info[index])
        item("imgManChatBg").visible = true
    else
        gView()("friendManageDlg"):DeletUnChoise(self.info[index])
        item("imgManChatBg").visible = false
    end
end

function VFriendCell:onOpenChatDlg( index )
    gView()("imgDOpen").visible = 0
    self:CheckUnReadMessage(index)
    local societyDlg = gView("societyDlg")
    societyDlg:CheckUnReadMessage(self.info[index].userid)

    gMainView:openChatDlg(self.info[index].userid);
end

function VFriendCell:CheckUnReadMessage( index )
    -- body
    self.info[index].newCount = 0
    local item = self("imgBackGroundBagC"..index)
    item("imgRedBtnFriendl").visible = 0
end