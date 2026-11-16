require "vFriendManageDlg"

VSocietyCell = VClass("SocietyCell", VTableViewCell)

function VSocietyCell:Recover(count)
	self.info = {}

	for i = 1, count do
		local item = self("imgBackGroundBagC"..i)
        if item then
    		item("txSaySocietyC").text = ""
        	item("txTimeSocietyC").text = ""
            item("imgRedBtnSocietyC").visible = 0
        	item.visible = false
        end
	end
end

function VSocietyCell:SetInfo(idx, count, data)
	for i = 1, count do
		local info = data[idx * count + i]

		if info then
				local item = self("imgBackGroundBagC"..i)

                if not item then
                    return
                end

		        local manager = gData.chatInfo:managerWithId(info.userid)
		        
		        if manager then
		            if string.len(manager:newestMessage()) > 10 then
		                item("txSaySocietyC").text = stringSub(manager:newestMessage(), 1, 10).."..."
		            else
		                item("txSaySocietyC").text = manager:newestMessage()
		            end
                   
                    item("txTimeSocietyC").text = self:ShowTimeText(manager:newestTime())
		        end
		            
		            -- self("txNameSocietyC").offset = {10, -25}
		            -- self("txLevelSocietyC").visible = 0
		        
		        
		        if info.newCount ~= 0 and info.newCount ~= nil then
		            item("imgRedBtnSocietyC").visible = 1
		            item("txtUnreadBtnSocietyC").text = info.newCount
		        elseif info.userid == 2 then
--		            local newCount = gData.chatInfo:unReadCount() - self:GetMessageCountWithUserid(10000)
--		            if newCount ~= 0 then
--                        item("imgRedBtnSocietyC").visible = 1
--                        item("txtUnreadBtnSocietyC").text = newCount
--                    end
		        end
		        
            self:SetHeadImageInfo(item("imgFriendSocietyC"), info)
		        item("txNickSocietyC").text = info.nick
		        
		    table.insert(self.info, info)
		    
		    item.visible = true

		    if info.flag == "WORLD" then
		    	item("imgFriendSocietyC").onClick = "node:Parent(2):onOpenWorldChatDlg("..i..")"
		    	item.onClick = "node:Parent():onOpenWorldChatDlg("..i..")"
		    elseif info.flag == "CUSTOM" then
		    	item("imgFriendSocietyC").onClick = "node:Parent(2):onOpenChatDlg("..i..")"
		    elseif info.flag == "LIST" then
		    	item("imgFriendSocietyC").onClick = "node:Parent(2):onOpenFriendManageDlg("..i..")"
		    	item.onClick = "node:Parent():onOpenFriendManageDlg("..i..")"
		    end
    	end
    end
end

function VSocietyCell:GetMessageCountWithUserid(userid)
    local manager = gData.chatInfo:managerWithId(userid)
    local count = 0

    if manager and manager.newCount > 0 then
        count = manager.newCount
    end

    return count
end

function VSocietyCell:SetHeadImageInfo(headImage, userBriefInfo)
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

function VSocietyCell:ShowTimeText(time)
    local timeText = ""
    local timeSpace = self:CalcTimeSpace(gData:currentTime(), time)
    
    local hour = 0
    local min = 0
    
    if timeSpace.day > 0 and timeSpace.day < 2 then
        return "昨天"
    elseif timeSpace.day >= 2 and timeSpace.day < 3 then
        return "前天"
    elseif timeSpace.day >= 3 then
        return timeSpace.day.."天前"
    else
        return os.date("%m月%d日", time);
    end
end

function VSocietyCell:CalcTimeSpace(time1, time2)
    local timeSpace = {}
    local secSpace = time1 - time2
    timeSpace.day = math.floor(secSpace / (3600 * 24))
    timeSpace.hour = math.floor((secSpace - (timeSpace.day * 3600 * 24)) / 3600)
    timeSpace.min = math.floor((secSpace - (timeSpace.day * 3600 * 24) - (timeSpace.hour * 3600)) / 60)
    timeSpace.sec = secSpace - (timeSpace.day * 3600 * 24) - (timeSpace.hour * 3600) - (timeSpace.min * 60)
    return timeSpace
end

function VSocietyCell:onOpenPlayerOperateDlg(index)
    local dlg = VNode("vPlayerOperateDlg.vui")
    local friendList = gData.userInfo.friendInfos.friends
    
    if friendList[self.info[index].userid] then
        dlg:SetUserInfo(self.info[index], 1, gView()("societyDlg"), "ReqFriendDelCallBack")
    else
        dlg:SetUserInfo(self.info[index], 1, gView()("societyDlg"), "ReqFriendAddCallBack")
    end

    gView():Push(dlg)
end

function VSocietyCell:onOpenFriendManageDlg( index )
	-- body
	 local dlg = VNode("vFriendManageDlg.vui")
    gView():Push(dlg)
end

function VSocietyCell:onOpenWorldChatDlg( index )
	-- body
	 local dlg = VNode("vWorldChatDlg.vui")
    gView():Push(dlg)
end

function VSocietyCell:onOpenChatDlg( index )
    gView()("imgDOpen").visible = 0
    self:CheckUnReadMessage(index)
    gMainView:openChatDlg(self.info[index].userid);
end

function VSocietyCell:UpDataMessage( manager, itemIndex )
    -- body
    local item = self("imgBackGroundBagC"..itemIndex)

    if manager then
        if string.len(manager:newestMessage()) > 10 then
            item("txSaySocietyC").text = stringSub(manager:newestMessage(), 1, 10).."..."
        else
            item("txSaySocietyC").text = manager:newestMessage()
        end
        item("txTimeSocietyC").text = os.date("%Y-%m-%d %X", manager:newestTime());
    end
    
    local privatChatDlg = gView()("privatChatDlg");
    if not privatChatDlg then  
        if self.info[itemIndex].userid == 2 then
--            local newCount = gData.chatInfo:unReadCount() - self:GetMessageCountWithUserid(10000)
--            if newCount ~= 0 then
--                item("imgRedBtnSocietyC").visible = 1
--                item("txtUnreadBtnSocietyC").text = newCount
--            end
        else
            item("imgRedBtnSocietyC").visible = 1
            item("txtUnreadBtnSocietyC").text = manager.newCount
            self.info[itemIndex].newCount = manager.newCount
        end
    end
end

function VSocietyCell:CheckUnReadMessage( index )
	-- body
	self.info[index].newCount = 0
    local item = self("imgBackGroundBagC"..index)
    item("imgRedBtnSocietyC").visible = 0
end