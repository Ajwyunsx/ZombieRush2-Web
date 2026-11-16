require "vLevelInfoDlg"


VLevelDlg = VClass("LevelDlg", VMsgBox)

function VLevelDlg:Init(attr)
    VNode.Init(self, attr);
    if not attr.size then self.size = {1024,576}; end
    if not attr.fill then self.fill = _VLayout.Full; end
    if not attr.touch then self.touch = true end
    self:NeedEvent(Eff_onEnter+Eff_onExit);
    if gWindow.needAction then
        if not gData.levelNoAction then
            
            self.pushAction = {{"hide"},{"scaleTo", 0, 0, 0},{"show"},{"@pushActionOpacity", 0},{"scaleTo", 0.1, 1, 1},{"@pushActionOpacity", 127}};
            gData.levelNoAction = nil
        end
        --{{"fadeTo",0,0},{"scaleTo",0,0.2},{"show"},{"scaleTo",0.15,1.2},{"spawn",{"fadeTo",0.1,self.opacity},{"scaleTo",0.1,1.0}}};
        -- self.popAction = {{"fadeTo",0.1,0},{"scaleTo",0.1,0.8}};
        
        self.stopEventTime = 0.3;
    end   
end

function VLevelDlg:onPush( ... )
	-- body

    self.txtime = self("txtime")
	
	if not self.info then
	    return 
	end
	
    local dungeonInfo = gData.userInfo.dungeonInfo
    
    self("txChatTitleT").text = self.info.name

    self("txStarhas").text = dungeonInfo:GetChapterStar(self.info.id).."/"
    self.starHas = dungeonInfo:GetChapterStar(self.info.id)
    self("txStarAll").text = self.info.count;
--    self("farmBtn").visible = gData.offlineData:isEnterFarmBtnVisible();
    
    if gData.userInfo.dungeonInfo:CheckChaptersPass(self.info.id) and self.info.nextChapter then
        self("nextBtn").visible = 1
    end
    
    gData.levelNoAction = nil

    self:InitMapFace()

    self:CheckExtraShopTip()

    
end


function VLevelDlg:CheckExtraShopTip( ... )
    -- body
    local time = gData.userInfo.dungeonInfo.extraShop.time

    if not time then
        return
    end

    local dungeonInfo = gData.userInfo.dungeonInfo

    local timeSpace = gData:currentTime() - time

    cclog("1~~~~~~~~~~~~~~~~~~~~~~~")

    local purchase = dungeonInfo:GetPurchase(dungeonInfo.extraShopid) or 0
    local timeLimit = gData.userInfo.dungeonInfo.timeLimit
    if time and timeSpace < timeLimit and purchase == 0 then
        cclog("2~~~~~~~~~~~~~~~~~~~~~~~")
        -- local levelDlg = gView()("levelDlg")
        -- if levelDlg then
            self:ShowExtraShopTip()
        -- end
    else
    end
end

function VLevelDlg:InitMapFace( ... )
    -- body
    local dungeonInfo = gData.userInfo.dungeonInfo
    local levels = dungeonInfo:GetLevelSortList(self.info.id)
    for i = 1, 11 do
        local lylevel = self("lylevel"..i)
        lylevel("imglevel").image = self:GetLevelImage(i, levels[i])
        self:InitStarFace(i, levels[i])
        self:InitLightFace(i, levels[i])
        self:InitLineFace(i, levels[i])
        lylevel.info = levels[i]
        if dungeonInfo:CheckLevelOpen(levels[i].id) then
            lylevel.onClick = "node:Parent(2):CheckOpenDlg("..i..")"
            lylevel.touch = 1
        elseif i == 11 then
            lylevel.onClick = "node:Parent(2):ShowUnlockTip("..i..")"
            lylevel.touch = 1
        end
    end
end

function VLevelDlg:ShowUnlockTip( index )
    -- body
    local lylevel = self("lylevel"..index)
    local levelinfo = lylevel.info
    gWindow:showNormalTip("当前关卡需要"..levelinfo.starLimit.."星星才可解锁,请继续收集星星", "提示")
end

function VLevelDlg:GetLevelImage( index, levelinfo )
    -- body
    local dungeonInfo = gData.userInfo.dungeonInfo
    local csv = gData:readCsv("dungeon_client.csv");
    local lineData = csv:lineDataWithKey(levelinfo.id);
    if not lineData then
        return "bossguan.png";
    end
    if dungeonInfo:CheckLevelOpen(levelinfo.id) then
        return lineData[1];     
    else
        return lineData[2];
    end
end



function VLevelDlg:InitStarFace( index, levelinfo )
    -- body
    local lylevel = self("lylevel"..index)
    local dungeonInfo = gData.userInfo.dungeonInfo
    local record = dungeonInfo:GetLevelRecord(levelinfo.id)
    for i = 1, record do
        lylevel("imageStar"..i).image = "guanqiaxiaoxing1.png"
    end
end

function VLevelDlg:InitLightFace( index, levelinfo )
    -- body
    local lylevel = self("lylevel"..index)
    local dungeonInfo = gData.userInfo.dungeonInfo

    if dungeonInfo:CheckLevelOpen(levelinfo.id) and dungeonInfo:GetLevelRecord(levelinfo.id) == 0 and not dungeonInfo:CheckLevelOpen(levelinfo.nextLevel) then
        local imgclevel = lylevel("imgclevel")
        if imgclevel then
            imgclevel.visible = 1
            imgclevel:RunAction{"repeat", -1, {"sequence", {"spawn", {"fadeTo", 0, 255}, {"scaleTo", 0, 1, 1}}, {"spawn", {"fadeTo", 1, 0}, {"scaleTo", 1, 1.4, 1.4}}}};
        end
    end
end

function VLevelDlg:InitLineFace( index, levelinfo )
    -- body
    local imgLine = self("imgLine"..index)
    local dungeonInfo = gData.userInfo.dungeonInfo
    if dungeonInfo:CheckLevelOpen(levelinfo.id) then
        imgLine.visible = 1
        if not levelinfo.nextLevel then
            self("imgLine"..(index + 1)).visible = 1
        end
        if levelinfo.extraLevel and dungeonInfo:CheckLevelOpen(levelinfo.extraLevel) then
            self("imgLine12").visible = 1
        end
    end
end

function VLevelDlg:SetDlgInfo( info )
	-- body
    gData.userInfo.dungeonInfo.levelShow = info
	self.info = info
end


function VLevelDlg:ExtraLevelClick(index)
    local item = self("lylevel"..index)
    local info = item.info
    
    local extraLock = true
    local actInfos = gData.userInfo.dungeonInfo.actInfos
    if self.starHas >= info.starLimit and
        actInfos[info.chapter].campaignInfo[info.id] then
        extraLock = false
    end
                    
    
    if extraLock and self.starHas >= info.starLimit then
        
    elseif extraLock then
        
	else
        self:OpenLevelInfoDlg(index)
	end
end

function VLevelDlg:CheckOpenDlg( index )
    -- body
    local info = self("lylevel"..index).info
    local dungeonInfo = gData.userInfo.dungeonInfo

    if dungeonInfo:CheckFreeGiftDlgOpen(info.id) then
        dungeonInfo:OpenFreeGiftDlg(info.id)
    elseif dungeonInfo:CheckShop2ValidEx(info.id) then
        dungeonInfo:OpenShop2DlgEx(info.id)
    else
        self:OpenLevelInfoDlg(info)
    end
end

function VLevelDlg:OpenLevelInfoDlg(info)

    local dungeonInfo = gData.userInfo.dungeonInfo
    local purchase = dungeonInfo:GetPurchase(info.id)
    local star = dungeonInfo:GetLevelRecord(info.id)
	local rt = dungeonInfo:CheckShopValid(info.id, 1)
    if star == 0 and purchase == 0 and rt then
        dungeonInfo:OpenShopDlg(info.id, 1)
        return
    end

    --新增特殊商店，提示充值购买VIP1  非单机情况下
    if info.id == dungeonInfo.extendShopid 
    and gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCharge) < 100 and gForceOffline == false then
        
        gWindow:showBattleFaildTip(2, info, 1);
        return;
    end
    
    local dlg = VNode("vLevelInfoDlg.vui")
    dlg:SetDlgInfo(info)
    gView():Push(dlg)

    -- gData:ShowBattleHelpDlg(info.id)
end

function VLevelDlg:onClose(parameters)
    gData.userInfo.dungeonInfo.levelShow = nil
    VLevelDlg.super.onClick(self)
    chapterdlg = gView()("chapterDlg");
    if chapterdlg then
        chapterdlg:CheckEnterFarmConfirm();
    end
end

function VLevelDlg:onNextChatper(parameters)
    local chapters = gData.userInfo.dungeonInfo.chapters
    gData.levelNoAction = true
    local dlg = VNode("vLevelDlg.vui")
    dlg:SetDlgInfo(chapters[self.info.nextChapter])--self.info.nextChapter
   
    gView():Push(dlg)
    self:doPop()
end

function VLevelDlg:OpenExtraShop( )
    -- body
    local dungeonInfo = gData.userInfo.dungeonInfo
    local id = dungeonInfo.extraShopid

    dungeonInfo:OpenShopDlg(id, 1)

end

function VLevelDlg:ShowExtraShopTip( ... )
    -- body
    local timeSpace = gData:currentTime() - gData.userInfo.dungeonInfo.extraShop.time
    local timeLimit = gData.userInfo.dungeonInfo.timeLimit

    if not self:InitExtraShopCostInfo() then
        return
    end

    if (timeSpace < timeLimit or self:CheckRecharge()) 
        and gData.userInfo.dungeonInfo:GetPurchase(gData.userInfo.dungeonInfo.extraShopid) == 0 then
        
            self.time = timeLimit - timeSpace
            self.txtime.text = self:GetTimeStr()
            self("btBuy").visible = 1
            self:StopTimer("UpdataExtraTime");

        if self.time <= 0 then
            self.time = 2
        end

        self:StartTimer("UpdataExtraTime", 1, self.time - 1, 1);
    end
end

function VLevelDlg:UpdataExtraTime( ... )
    -- body
    self.time = self.time - 1

    if self.time <= 0 then
        if not self:CheckRecharge() then
            self("btBuy").visible = 0
        end
        self:StopTimer("UpdataExtraTime");
    else
        -- os.time(self.time)
        self.txtime.text = self:GetTimeStr()
    end
end

function VLevelDlg:CheckRecharge( ... )
    -- body
    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local charge = gData:attrValue(AttrType.AttrTypeCharge);

    local cost = self.cardCost

    if tonumber(self.discount) < 10 then
        cost = self.discountCost
    end

    local id = gData.userInfo.dungeonInfo.extraShopid
    local chapterid = gData.userInfo.dungeonInfo:GetActInfosID(id)
    local info = gData.userInfo.dungeonInfo.chapters[chapterid].levels[id]

    return (YB >= cost * gResRate) and (charge >= cost * gResRate) and info.shop[2].buyClass == 2
end

function VLevelDlg:InitExtraShopCostInfo()
    local id = gData.userInfo.dungeonInfo.extraShopid
        local chapterid = gData.userInfo.dungeonInfo:GetActInfosID(id)
        local info = gData.userInfo.dungeonInfo.chapters[chapterid].levels[id]

    local costInfo = gData:GetLevelCostInfo(info, 2)

    if not costInfo then
        return false
    end
    

    self.discountCost = costInfo.discountCost
        self.discount = costInfo.discount
        self.cardCost = costInfo.cardCost
        self.shopName = costInfo.shopName

    cclog("self.discountCost~~~~~~~~~~~~~"..(self.discountCost or -1))
    cclog("self.discount~~~~~~~~~~~~~"..(self.discount or -1))
    cclog("self.cardCost~~~~~~~~~~~~~"..(self.cardCost or -1))
    cclog("self.shopName~~~~~~~~~~~~~"..(self.shopName or -1))
    cclog("gPackage~~~~~~~~~~~~~"..(gPackage or -1))

    return true
end

function VLevelDlg:GetTimeStr( ... )
    -- body
    if self:CheckRecharge() then
        return "可领取"
    end

    local timeTable = os.date("!*t", self.time);
    local timeString = "";
    if timeTable.hour < 10 then
        timeTable.hour = "0"..timeTable.hour;
    end
    if timeTable.min < 10 then
        timeTable.min = "0"..timeTable.min;
    end
    if timeTable.sec < 10 then
        timeTable.sec = "0"..timeTable.sec;
    end
    timeString = timeString..timeTable.hour..":";
    timeString = timeString..timeTable.min..":";
    timeString = timeString..timeTable.sec;

    return timeString
end
