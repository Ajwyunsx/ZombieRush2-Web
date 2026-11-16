--vMessageCell.lua

VMessageCell = VClass("MessageCell", VTableViewCell)

function VMessageCell:SetHeadImageInfo(headImage, txtVIP, userBriefInfo)
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

function VMessageCell:SetMsgSize( info )

    -- if info.sizeS then 
    --  cclog("1~~~~~~~~~~~~~")
    --  return 780, info.sizeS.height;
    -- end

    -- cclog("2~~~~~~~~~~~~~")

    local msgText = VText{fontSize=18};

    msgText.text = info.context;
    local size = msgText.size;
    -- -- gLog("msgText height = "..size.height..", width = "..size.width);
    local h;

    local lineCont = math.ceil(size.width/450);
    h = (size.height + 10) * (lineCont - 1) + 80;
    w = math.min(450, size.width);
    return cc.size(w,h);

    
end

function VMessageCell:loadMessage(message)
	self.imgHead = self("imgHead");
	self.imgContextBG = self("imgContextBG");
	self.texContext = self("texContext");
	self.texNick = self("texNick");
	self.texTime = self("texTime");
	self.txtVIPTitle = self("txtVIPTitle");

	self.message = message;

    if not message.sizeS then
        message.sizeS = self:SetMsgSize(message)
    end

    self("lybg").size = {650, message.sizeS.height};
    
    -- self
    self.texContext.text = message.context;
    self.texContext:setDimensions(message.sizeS.width,message.sizeS.height)
	-- local newContextHeight = self.texContext.size.height;
 --    local newContextWidth = self.texContext.size.width + 50;
 --    local scaleHeight = math.max(newContextWidth / 500, 1)
 --    if newContextWidth > 500 then
 --        newContextHeight = newContextHeight * math.ceil(scaleHeight)
 --        self.texContext:setDimensions(450, newContextHeight)
 --        newContextWidth = 500
 --    end
	-- if newContextHeight > 42 then
	-- 	-- self.size = {self.size.width, 100+(newContextHeight-42)};
 --        -- self("lyss").size = {self.size.width, 100+(newContextHeight-42)};
	-- else
	-- 	-- self.size = {self.size.width, 100};
 --        -- self("lyss").size = {self.size.width, 100};
	-- end

	local userBriefInfo = gData:briefCache(message.from)
	if userBriefInfo and userBriefInfo.nick ~= "" then
		self.texNick.text = userBriefInfo.nick;
	else
		self.texNick.text = message.from;
	end

	if userBriefInfo then
        self:SetHeadImageInfo(self.imgHead, self.txtVIPTitle, userBriefInfo)
    elseif message.from == gData.userInfo.userid then
        self:SetHeadImageInfo(self.imgHead, self.txtVIPTitle, gData.userInfo.roleInfo)
	end

	if message.from == gData.userInfo.userid then
		self.texNick.text = gData.userInfo.roleInfo.nick;
	end
	self.texTime.text = os.date("%Y-%m-%d %X", message.time);

	if message.from == gData.userInfo.userid then
		self.imgHead.layout = "RightUp";
        self.imgHead.offset = {-35,3};

        --      self.imgContextBG:setScaleX(-1);
self.imgContextBG.image = "liaotiankuang2.png"
        -- local image = VImage{name="tmp", image="liaotiankuang2.png"}
        
        self.imgContextBG.size = {message.sizeS.width+80, message.sizeS.height-30};--{newContextWidth, math.ceil(image.size.height * scaleHeight)}
        self.imgContextBG.layout = "RightDown"
        self.imgContextBG.step = {0, 1}
        self.imgContextBG.offset = {0,5};
        self.texNick.layout = "LeftUp"
        self.texNick.step = {-1, 0}
        self.texNick.offset = {-10, 0}
        self.texTime.layout = "LeftOut"
        self.texTime.offset = {-7,0};


	else
		 self.imgHead.layout = "LeftUp";
        self.imgHead.offset = {0,3};

        self.imgContextBG.image = "liaotiankuang1.png"
        local image = VImage{name="tmp", image="liaotiankuang1.png"}
        self.imgContextBG.size = {message.sizeS.width+80, message.sizeS.height-30};---{newContextWidth, math.ceil(image.size.height * scaleHeight)}
        --      self.imgContextBG:setScaleX(1);
        self.imgContextBG.layout = "DownLeft"
        self.imgContextBG.step = {0, 1}
        self.imgContextBG.offset = {0,5};
        self.texNick.layout = "RightUp"
        self.texNick.step = {1, 0}
        self.texNick.offset = {10, 0}
        self.texTime.layout = "RightOut"
        self.texTime.offset = {7,0};

	end

	if gListDynamicCellHight then
		self:setLayoutState(0);
	end
end

function VMessageCell:headImageAction()
	local info = {}
    info.userid = self.message.from;
    
    if info.userid == gData.userInfo.roleInfo.id then
        return
    end
    
    local userBriefInfo = gData:briefCache(self.message.from)
    if userBriefInfo then
    	info.image = userBriefInfo.image
	    info.level = userBriefInfo.level
	    info.sex = userBriefInfo.sex
	    info.nick = userBriefInfo.nick
    end
    
    if gView()("societyDlg") then

        local dlg = VNode("vPlayerOperateDlg.vui")

        local friendList = gData.userInfo.friendInfos.friends
        
        if friendList[info.userid] then
            dlg:SetUserInfo(info, nil, gView()("societyDlg"), "ReqFriendDelCallBack")
        else
            dlg:SetUserInfo(info, nil, gView()("societyDlg"), "ReqFriendAddCallBack")
        end

        -- dlg:SetUserInfo(info, gView()("societyDlg"))
        gView():Push(dlg)
    end
end
