--vWorldMessageCell.lua

VWorldMessageCell = VClass("WorldMessageCell", VTableViewCell)


function VWorldMessageCell:SetHeadImageInfo(headImage, txtVIP, userBriefInfo)
    headImage:setHead(userBriefInfo.userid, userBriefInfo.image, nil, userBriefInfo.vipInfo[0])
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

function VWorldMessageCell:loadWorldMessage(message)
    self.imgHead = self("imgHead");
    self.imgContextBG = self("imgContextBG");
--    self.layContextBg = self("layContextBg");
    self.texContext = self("texContext");
    self.texNick = self("texNick");
    self.texTime = self("texTime");
    self.txtVIPTitle = self("txtVIPTitle");

    self.message = message;
    
    self.texContext:setDimensions(0, 0)
    
    
    if string.find(message.msg, "SetHelpMsg") then
        local battleid = "老数据战场id"
        local nick = "老数据战场昵称"
        local userid = "老数据战场id"
        local battleType = 1
        
        local start, endle = string.find(message.msg, "SetHelpMsg")
        local str = string.sub(message.msg, endle + 1, -1)
        start, endle = string.find(str, "~")
        if start then
            battleid = string.sub(str, 1, start - 1)
        end
        
        if endle then
        str = string.sub(str, endle + 1, -1)
        start, endle = string.find(str, "~")
            if start then
                nick = string.sub(str, 1, start - 1)
            end
        end
        
        if endle then
        str = string.sub(str, endle + 1, -1)
        start, endle = string.find(str, "~")
            if start then
                userid = string.sub(str, 1, start - 1)
            end
        end
        
        if endle then
            battleType = string.sub(str, endle + 1, -1)
        end
        
        if tonumber(battleType) == 1 then
            self.texContext.text = "我在掠夺"..nick.."(ID:"..userid..")，赶快跟我一起抢肥羊。"
        elseif tonumber(battleType) == 2 then
            self.texContext.text = "我被"..nick.."(ID:"..userid..")攻击，快来协助我，一起刷碎片。"
        elseif tonumber(battleType) == 3 then
            self.texContext.text = "我在协助"..nick.."(ID:"..userid..")进攻，赶快跟我一起抢肥羊。"
        elseif tonumber(battleType) == 4 then
            self.texContext.text = "我在协助"..nick.."(ID:"..userid..")防守，快来协助我，一起刷碎片。"
        end
        
--        local battleid = string.sub(message.msg, endle + 1, -1)
        
--        self.texContext.text = "请求战斗援助[战场ID:"..battleid.."]"
        if message.userId ~= gData.userInfo.userid then
            self.imgContextBG.touch = 1
            self.imgContextBG.onClick = "node:Parent():Reinforcement()"
        end
    else   
        self.texContext.text = message.msg;
        self.imgContextBG.touch = 0
        self.imgContextBG.onClick = nil
    end
    
    local newContextHeight = self.texContext.size.height;
    local newContextWidth = self.texContext.size.width + 50;
    local scaleHeight = math.max(newContextWidth / 500, 1)

    if newContextWidth > 500 then
        newContextHeight = newContextHeight * math.ceil(scaleHeight)
        self.texContext:setDimensions(450, newContextHeight)
        newContextWidth = 500
    end
    
    if newContextHeight > 42 then
        self.size = {self.size.width, 110+(newContextHeight-42)};
    else
        self.size = {self.size.width, 110};
    end
    
    local userBriefInfo = gData:briefCache(message.userId)
    
   
    if userBriefInfo and userBriefInfo.nick ~= "" then
        if message.userId == gData.userInfo.userid then
            self.texNick.text = gData.userInfo.roleInfo.nick
        else
            self.texNick.text = userBriefInfo.nick;
        end
    else
        if message.userId == gData.userInfo.userid then
            self.texNick.text = gData.userInfo.userid
        else
            self.texNick.text = message.userId;
        end
    end

    if userBriefInfo then
        self:SetHeadImageInfo(self.imgHead, self.txtVIPTitle, userBriefInfo)
    end

    if userBriefInfo and userBriefInfo.vipInfo then
        local vipLevel = userBriefInfo.vipInfo[0];
        if vipLevel > 0 then
            self.texContext.color = {255,0,0};
        else
            self.texContext.color = {255,255,255};
        end
    end

    self.texTime.text = os.date("%Y-%m-%d %X", message.time);
    
    

    if message.userId == gData.userInfo.userid then
        self.imgHead.layout = "RightUp";
        self.imgHead.offset = {-5,0};

        --      self.imgContextBG:setScaleX(-1);
        self.imgContextBG.image = "liaotiankuang2.png"
        local image = VImage{name="tmp", image="liaotiankuang2.png"}
        
        self.imgContextBG.size = {newContextWidth, math.ceil(image.size.height * scaleHeight)}
        self.imgContextBG.layout = "RightDown"
        self.imgContextBG.step = {0, 1}
        self.imgContextBG.offset = {0,5};
        self.texNick.layout = "LeftUp"
        self.texNick.step = {-1, 0}
        self.texNick.offset = {-10, 0}
        self.texTime.layout = "LeftOut"
        self.texTime.offset = {-7,0};

--        self.layContextBg.offset = {-35,-10};
    else
        self.imgHead.layout = "LeftUp";
        self.imgHead.offset = {5,0};

        self.imgContextBG.image = "liaotiankuang1.png"
        local image = VImage{name="tmp", image="liaotiankuang1.png"}
        self.imgContextBG.size = {newContextWidth, math.ceil(image.size.height * scaleHeight)}
        --      self.imgContextBG:setScaleX(1);
        self.imgContextBG.layout = "DownLeft"
        self.imgContextBG.step = {0, 1}
        self.imgContextBG.offset = {0,5};
        self.texNick.layout = "RightUp"
        self.texNick.step = {1, 0}
        self.texNick.offset = {10, 0}
        self.texTime.layout = "RightOut"
        self.texTime.offset = {7,0};

--        self.layContextBg.offset = {28,-10};
    end

    if gListDynamicCellHight then
        self:setLayoutState(0);
    end
end

function VWorldMessageCell:headImageAction()
    local info = {}
    info.userid = self.message.userId;

    if info.userid == gData.userInfo.roleInfo.id then
        return
    end
    
    local userBriefInfo = gData:briefCache(self.message.userId)
    if userBriefInfo then
        info.image = userBriefInfo.image
        info.level = userBriefInfo.level
        info.sex = userBriefInfo.sex
        info.nick = userBriefInfo.nick
        info.charge = userBriefInfo.charge
    else
        return
    end

    local dlg = VNode("vPlayerOperateDlg.vui")

    local friendList = gData.userInfo.friendInfos.friends
    -- local enemyList = gData.userInfo.enemyInfos.enemys
    
    if friendList[info.userid] then
        dlg:SetUserInfo(info, 1, gView()("societyDlg"), "ReqFriendDelCallBack")
    else
        dlg:SetUserInfo(info, 1, gView()("societyDlg"), "ReqFriendAddCallBack")
    end

    -- dlg:SetUserInfo(info, gView()("societyDlg"))
    gView():Push(dlg)
end

function VWorldMessageCell:Reinforcement()

    local start, endle = string.find(self.message.msg, "SetHelpMsg")
--    local battleid = string.sub(self.message.msg, endle + 1, -1)
--    cclog("~~~~~message.msg"..self.message.msg)
    local str = string.sub(self.message.msg, endle + 1, -1)
    start, endle = string.find(str, "~")
    if not start then
        return
    end
    local battleid = string.sub(str, 1, start - 1)
    
    ShowGroupBattleDlgByAssistId(battleid, self.message.userId)
end
