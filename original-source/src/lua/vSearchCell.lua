VSearchCell = VClass("SearchCell", VTableViewCell)

function VSearchCell:Recover(count, cellType)
    self.info = {}
    
    for i = 1, count do
        local item = self("imgBackGroundBagCSearchC"..i)
        item("txSaySearchC").text = ""
        item("txTimeSearchC").text = ""
        item("imgRedBtnSearchC").visible = 0
        
            item("txMassegeSearchC").visible = false
            item("btnAddSearchC").visible = false

        item.visible = false
    end
end

function VSearchCell:UpDataCell(count, userid)
    for i = 1, count do
    local item = self("imgBackGroundBagCSearchC"..i)
        if self.info[i] and self.info[i].userid == userid then
            local isFriend = gData:isMyFriend(userid)
            item("txMassegeSearchC").visible = isFriend
            item("btnAddSearchC").visible = not isFriend
            self.info[i].hasAdd = isFriend
        else
            item("txMassegeSearchC").visible = (self.info[i] and self.info[i].hasAdd)
            item("btnAddSearchC").visible = not (self.info[i] and self.info[i].hasAdd)
        end
    end
end

function VSearchCell:SetInfo(idx, count, data)
    for i = 1, count do
        local info = data[idx * count + i]

        if info then
            info.pos = idx
            
            local item = self("imgBackGroundBagCSearchC"..i)

            local manager = gData.chatInfo:managerWithId(info.userid)
            if manager then
                if string.len(manager:newestMessage()) > 105 then
                    item("txSaySearchC").text = stringSub(manager:newestMessage(), 1, 102).."..."
                else
                    item("txSaySearchC").text = manager:newestMessage()
                end
                
            end
            
            item("txTimeSearchC").text = self:GetSexString(info.sex)--os.date("最后登录 %Y-%m-%d", info.last_login_time);
            -- self("txNameFriendl").offset = {10, -25}
            item("txLevelSearchC").text = "Lv"..info.level


            if info.newCount ~= 0 and info.newCount ~= nil then
                item("imgRedBtnSearchC").visible = 1
                item("txtUnreadBtnSearchC").text = info.newCount
            end

            
            local headImage = item("imgFriendSearchC")
    -- self("imgPlantDexPlayerO").image = gData:headImage(self.info.userid, self.info.image)
    headImage:setHead(info.userid, info.image, nil, gData:GetVipLevel(info.charge or 0))
    
    headImage:SetHeadImageShader()

            item("txNickSearchC").text = info.nick

            if info.hasAdd then
                item("txMassegeSearchC").visible = true
            else
                item("btnAddSearchC").visible = true
            end

            if self.info[i] then
                self.info[i] = info
            else
                table.insert(self.info, info)
            end

            item.visible = true
        end
    end
end

function VSearchCell:GetSexString(sex)
    if sex ~= 2 then
        return "女"
    else
        return "男"
    end
end

function VSearchCell:onOpenPlayerOperateDlg(index)
    self.info.newCount = 0
    self("imgRedBtnSearchC").visible = 0
    local dlg = VNode("vPlayerOperateDlg.vui")
    -- dlg:SetUserInfo(self.info[index], gView()("societyDlg"))
    local friendList = gData.userInfo.friendInfos.friends

    if friendList[self.info[index].userid] then
        dlg:SetUserInfo(self.info[index], 1, gView()("societyDlg"), "ReqFriendDelCallBack")
    else
        dlg:SetUserInfo(self.info[index], 1, gView()("societyDlg"), "ReqFriendAddCallBack")
    end
    gView():Push(dlg)
end

function VSearchCell:onAddFriend(index)
    if gData.userInfo.enemyInfos:isEnemy(self.info[index].userid) then
        gWindow:showTip("不能添加仇人为好友")
        return
    end

    if gData.userInfo.friendInfos:friendCount() < gData.userInfo.friendInfos.friendLimit then
        gView()("societyDlg"):ReqFriendAdd(self.info[index])
    else
        gWindow:showTip("好友已达到上限,无法添加")
        return
    end
end