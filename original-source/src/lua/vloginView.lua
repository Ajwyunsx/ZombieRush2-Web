--vloginView.lua

require "vZoneCell"
require "vfindAccount"
require "vAccountFindEmail"
require "vAccountFindCellPhone"

VLoginView = VClass("LoginView", VView)

--更新取版本号变量
--getPackageFinishFlag = nil;
--更新服务器列表变量
gUpdatingZoneList = false; 
--点开始的时候才取列表
--gStartGame = nil;

function updateFinished()
	cclog("updateFinish");
	
	gData:initUserInfo();
	if gView().updateFinish then 
		gView():updateFinish();
	end
end

function zoneListUpdateFinish()
	if gView() == gMainView or gView() == gBattleView then
		return;
	end
	gView().zoneListRetry = false;
	gView():setEnterEnable(true);
	gView():showZone();
	gView().updatingZoneList = false;
    gUpdatingZoneList = true; 

    if gStartGame then
        gView():startGameLogic1();
    end
end

function zoneListUpdateFailed()
	if gView() == gMainView or gView() == gBattleView then
		return;
	end
	gView():setEnterEnable(true);
	gView():setLoadingText("");
	gView().zoneListFailed = true;
	if gView().zoneListRetry then
		-- gWindow:showTip("获取服务器列表失败!");
		gView().zoneListRetry = false;
		gWindow:showConfirmTip("主人，网络不给力，要进入单机模式么？", "进入单机", "重试", gView(), "chooseOffline", "chooseOnline", "出错拉");
	else
		gView().zoneListRetry = false;
	end
	gView().updatingZoneList = false;
        gUpdatingZoneList = false; 
end

function UpdateLuaLoadFailed()
	gView():setEnterEnable(true);
	gView():setLoadingText("");
	gWindow:showTip("获取升级文件失败!");
end

function FailResetUi()
    if gView() and gView().resetUI then
        gView():resetUI();
    end
end

function VLoginView:showZone()
	local lastZoneId = gData.accountInfo.lastZoneId;
	if not lastZoneId then lastZoneId = 0 end;
	self.zoneInfos = gData:readCsvCache("zonelist");
	self:changeZoneInfo(lastZoneId);
	self:reloadZoneList();
	self:checkNoticeFlag();
	self:setLoadingText("");
	self.btnZoneInfo.visible = 1;

	self:updateLastZoneInfo(lastZoneId);

	if self.zoneListFailed then
		self.zoneListFailed = nil;
		self:startGameAction();
	end
end

function VLoginView:updateLastZoneInfo( zoneId )
	local nameLabel = self("lastZoneName");
	local numberLabel = self("lastZoneNumber");
	local stateLabel = self("lastZoneState");
	if zoneId ~= 0 then 
		local item = self.zoneInfos:lineDataWithKey(zoneId);
		if not item then
			stateLabel.visible = 0;
			numberLabel.visible = 0;
			nameLabel.visible = 0;
			return;
		end;
		local zoneId = item[0];
		local zoneName = item[1];
		local zoneState = item[2];
		local zoneTag = item[3];

		nameLabel.text = zoneName;
		numberLabel.text = tostring(zoneId).."区";

		if zoneTag == 1 then
			stateLabel.text = "新区"	
			stateLabel.color = {0,255,0};
		elseif zoneTag == 2 then
			stateLabel.text = "推荐"
			stateLabel.color = {0,255,0};
		else
			if zoneState > 80 then
				stateLabel.text = "爆满"
				stateLabel.color = {255,0,0};
			elseif zoneState > 50 then
				stateLabel.text = "繁忙"
				stateLabel.color = {255,0,0};
			else
				stateLabel.text = "流畅"
				stateLabel.color = {0,255,0};
			end
		end
	else
		stateLabel.visible = 0;
		numberLabel.visible = 0;
		nameLabel.visible = 0;
	end
end

function VLoginView:showAdView()
	local webView = VNode("vwebView.vui");
	webView.url = gResAllUrl.."notice/notice.html";
	self:Push(webView);
end

function VLoginView:closeAdView()
	local webView = self("WebView");
	if webView then
		webView:closeView();
	end
end

function VLoginView:checkNoticeFlag()
	local noticeUrl = gResAllUrl.."notice/notice";
	downLoadFile(noticeUrl, nil, "gView():noticeFlagCheckFinish(gLua:Param())")
end

function VLoginView:noticeFlagCheckFinish(msg)
	local ret = msg:Number("ret");
	if ret == 0 then
		local content = msg:String("content");
		if content == "1" then
			self:showAdView();
		end
	else
		cclog("notice flag get error");
	end
end

function VLoginView:changeZoneInfo(zoneId)
	if self.zoneInfos then
		local zoneInfo = self.zoneInfos:lineDataWithKey(zoneId);
		if not zoneInfo then
			--如果没有找到分区信息，则寻找zoneTag == 1 的新区信息。
			local newZoneList = self.zoneInfos:linesWithRowValue(3, 1);
			if #newZoneList ~= 0 then
				zoneInfo = newZoneList[1];		--默认推荐一个新区
			else
				zoneInfo = self.zoneInfos:lineData(0) 	--没有找到新区，使用第一个区。
			end
		end
		local realZoneId = zoneInfo[0];
		local zoneName = zoneInfo[1];
		local zoneState = zoneInfo[2];
		local zoneTag = zoneInfo[3];
		local zoneGameIP = zoneInfo[4];
		local zoneGamePort = zoneInfo[5];
		local zoneResUrl = zoneInfo[6];
		local zoneSnsUrl = zoneInfo[7];
		local zonePayUrl = zoneInfo[8]
		local zoneSiteUrl = zoneInfo[11]
		cclog("name=%s, ip=%s, port=%d, resUrl=%s, snsUrl=%s", zoneName, zoneGameIP, zoneGamePort, zoneResUrl, zoneSnsUrl);

		gZoneid = realZoneId;
		if gServerIndex == 0 and gZoneid < 100 then
			gZoneid = 100;
		elseif gServerIndex == 3 and gZoneid == 668 then
			gZoneid = 666;
		end
		gIP = zoneGameIP;
		gPort = zoneGamePort;
		gServer = zoneGameIP..":"..tostring(zoneGamePort);
		gResAllUrl = zoneResUrl;
		gResUrl = zoneResUrl.."server"..gZoneid.."/";
		gSnsUrl = zoneSnsUrl;
		gPayUrl = zonePayUrl;
		gSiteUrl = zoneSiteUrl;
		if zonePayUrl then
			gSys:setPayAddress(zonePayUrl);
		end
		self.texZoneNumber.text = tostring(gZoneid).."区";
		self.texZoneName.text = zoneName;
		if zoneTag == 1 then
			self.texZoneState.text = "新区"	
			self.texZoneState.color = {255,168,0};

		else
			if zoneState > 80 then
				self.texZoneState.text = "爆满"
				self.texZoneState.color = {255,0,0};

			elseif zoneState > 50 then
				self.texZoneState.text = "繁忙"
				self.texZoneState.color = {255,0,0};

			else
				self.texZoneState.text = "流畅"
				self.texZoneState.color = {66,234,7};
			end
		end
		
		self.currentZoneId = gZoneid;
	end
end

function VLoginView:updateFinish()
	self.updateFinishFlag = true;
	if self.layChangeLogin:isVisible() then
		self:loginAction();
		return;
	end

	if self.packageParams and self.packageParams.newAccount then
		self:registerAction();
	else
		local id = gData.accountInfo.id;
		local psw = gData.accountInfo.psw;

		if id ~= 0 and psw ~= "" then
			self:loginAction();
		else
			self:registerAction();
		end
	end
end

function VLoginView:setEnterEnable(enable)
	self.loginButton:setEnable(enable);
	-- self.loginButton:Relayout();
	self.btnChangeRole:setEnable(enable);
	self.btnZoneInfo.touch = enable;
	self.btnLoginLoginV:setEnable(enable);
	self.btnForgetPsw:setEnable(enable);
end

function VLoginView:setLoadingText(text)
	self.textLoad.text = text;
end

function VLoginView:apkDownloadProgress(progress)
	local progressString = gFormat("正在下载安装包...(%d%%)", progress);
	self:setLoadingText(progressString);
end

function VLoginView:onShow()
	
end

function VLoginView:onForeground()
	VView.onForeground(self);
	if gAudio:getMusicOff() == 1 and gAudio:isMusicPlaying() then
		gAudio:pauseMusic();
	end
end

function VLoginView:onPush()
	if gForTest then
		gDtr:setDisplayStats(true);
	end
	gDtr:setAnimationInterval(1.0 / 50.0);

	gAudio:playMusic("beginGame.ogg", true);
	gData:stopHeartBeat();

	self.loginButton = self("loginButton");
	self.ok = true; --动画控制参数(由于)

	self.btnZoneInfo = self("btnZoneInfo");
	self.texZoneNumber = self("texZoneNumber");
	self.texZoneName = self("texZoneName");
	self.textLoad = self("textLoad");
	self.texZoneState = self("texZoneState");
	self.tabZoneList = self("tabZoneList");
	self.layBgGray = self("layBgGray");

	self.layChangeLogin = self("layChangeLogin")
	self.edtRoleLoginV = self("edtRoleLoginV")
	self.edtPassWordLoginV = self("edtPassWordLoginV")
	self.btnChangeRole = self("btnChangeRole")
	self.btnLoginLoginV = self("btnLoginLoginV");
	self.btnForgetPsw = self("btnForgetPsw");

	self.tabZoneList.delegate = self;

	self("btnSever").visible = 0;
	self("btnsetting").visible = 0;
	self("btnChangeRole").visible = 0;
	
    if getPackageFinishFlag ~= nil then
       self:setInitBtnStatus();	  
       if not gForceOffline then
           if not gUpdatingZoneList then
             self:getZoneList();
           end
        end
    else
        if gVerSurf == nil or gVerUrl == nil or gSys:isNetworkConnected() == true then
            self:setInitBtnStatus();	
            if not gForceOffline then
                if not gUpdatingZoneList then
                  self:getZoneList();
                end
            end
        else
            self:setLoadingText("");
        end
    end    

	self("loginArmature"):addParticleBone("particleNode", "dihuo.plist");
	self("loginArmature"):addParticleBone("particleNode", "huoxing.plist");
end
function VLoginView:setInitBtnStatus()
    if not gForceOffline then
        self("btnSever").visible = 1;
	    self("btnsetting").visible = 1;
	    if gPartnerLogin then
			self("btnChangeRole").visible = 0;
		else
			self("btnChangeRole").visible = 1;
		end
		self:setEnterEnable(false);      
	else
		self("btnWeb").visible = 0;
		self("btnSever").visible = 0;
		self("btnsetting").visible = 0;
		self("btnChangeRole").visible = 0;
	end   
end

function VLoginView:getZoneList()
        gUpdatingZoneList = true;
		gUpdate:updateZoneList();
		self.updatingZoneList = true;
		self:setLoadingText("正在更新分区列表...");
		self:StartTimer("updateZoneListTimer", 10.0);
end

function VLoginView:updateZoneListTimer()
	self:StopTimer("updateZoneListTimer");
	if self.updatingZoneList then
		cclog("zoneListUpdateFailed");
		zoneListUpdateFailed();
	end
end

function VLoginView:reloadZoneList()
	if self.zoneInfos then
		self.tabZoneList.number = math.ceil(self.zoneInfos:lineCount()/2);
		self.tabZoneList:reloadData();
	end
end

function VLoginView:onCell(idx, vTable, cell)
	if vTable == self.tabZoneList then
		if self.zoneInfos then
			for i=1, 2 do
				local n = idx * 2 + i;
				local item = self.zoneInfos:lineData(n-1);
				cell:reloadItem(item,i);
			end
		end
	end
end

function VLoginView:ZoneInfoAction()
	if self.tabZoneList:isVisible() then
		self.tabZoneList.visible = 0;
		self.layBgGray.visible = 0;
	else
		self.tabZoneList.visible = 1;
		self.layBgGray.visible = 1;
	end
end

function VLoginView:CloseZoneInfo()
	self.tabZoneList.visible = 0;
	self.layBgGray.visible = 0;
end

function VLoginView:ChangeRole()
    self.layChangeLogin.visible = 1
    self.edtRoleLoginV.visible = 1;
    self.edtPassWordLoginV.visible = 1;

    local accountName = gData.accountInfo.name;
	local psw = gData.accountInfo.psw;
	if accountName then
		self.edtRoleLoginV.text = accountName;
		-- self.edtPassWordLoginV.text = psw;
	end
end

function VLoginView:closeChangeView()
	self.layChangeLogin.visible = 0
    self.edtRoleLoginV.visible = 0;
    self.edtPassWordLoginV.visible = 0;
end

function VLoginView:zoneChoosed(zoneid)
	self:StartTimer("CloseZoneInfo", 0.01, 0);
	self:changeZoneInfo(zoneid);
end

function VLoginView:startGameAction()
    if gSys:isNetworkConnected()==false then
        self:startGameOffline();
    elseif gVerSurf == nil or gVerUrl == nil then
        self:startGameLogic(); 
    elseif  getPackageFinishFlag == false then
        getPackageVerLogo();
    else
        self:startGameLogic();
    end
end
function VLoginView:startGameLogic()  
    gStartGame = true;
    self:setInitBtnStatus();
    if not gForceOffline then
        if not gUpdatingZoneList then            
            if self.zoneListFailed then
		      self:retryUpdateZoneList();
		    else
              self:getZoneList();
	        end           
         else
            self: startGameLogic1();
         end	  
    else
       self: startGameLogic1();
    end
    --VLoginView:startGameLogic1();
end
function VLoginView:startGameLogic1()    
	self:closeAdView();
	self.ok = true;
	if gSys:isNetworkConnected() and (not gForceOffline) then
		if gPartnerLogin then
			gSys:packageLoginAction(self);
		else
			self:startGameLoginAction();
		end
	else
		self:startGameOffline();
	end
end

function VLoginView:startGameLoginAction( )
	if self.zoneListFailed then
		self:retryUpdateZoneList();
		return;
	end
	self.zoneListRetry = false;
	gRes:makeDir(tostring(gZoneid));
	if self.updateFinishFlag then
		self:updateFinish();
	else
		gUpdate:getUpdateLua();
		self:setLoadingText("正在检查更新...");
	end
	self:setEnterEnable(false);
	gData.offlineData:setOffline(false);
end

function VLoginView:loginPackageSuccessIniOS(params)
	self.packageParams = params;
	-- 有绑定游戏账号且跟本地存的一致 直接登录
	if self.packageParams.getGameId then
		self:startGameLoginAction();
	else
		-- 找回账号
		self.packageParams.findAccount = true;
		local channel = getPartnerChannel();
		gReq:MsgReqAccountRestore2(self, "packageAccoutCallBack", 3, self.packageParams.userId, nil, channel);
	end
end

function VLoginView:packageAccoutCallBack(result, rsp, req)
	gWindow:closeWaitTip();
	if result == 0 and rsp and rsp.accountid and rsp.psw then
		-- 登录
		self:startGameLoginAction();
	else
		self.packageParams.newAccount = true;
		-- 找不到账号 清空账号信息 重新注册
		self:startGameLoginAction();
	end
end

--当失败时重置动画及UI
function VLoginView:resetUI()
    gStartGame = false;
	self.ok = false;
	self.loginButton.visible = 1;
	self("loginSlot").visible = 0;
	self("loginSlotGreen"):RunAction{{"hide"}};
	self("loginGreenPoint"):ReLayout();
	self("loginGreenPoint"):stopAllActions();
	self("loginSlotPointLayer").visible = 0;
	self("loginSlotLayer"):RunAction{{"hide"}};
	self:setEnterEnable(true);
    self:setLoadingText("");
end

function VLoginView:retryUpdateZoneList()
	self.zoneListRetry = true;
	gUpdate:updateZoneList();
	self.textLoad.text = "正在更新分区列表...";
	self:setEnterEnable(false);
end

function VLoginView:chooseOffline()
	self:startGameOffline();
end

function VLoginView:chooseOnline()
	self:retryUpdateZoneList();
end

function VLoginView:startGameOffline()
    --单机加载本地的配置
	local lastZoneId = gData.accountInfo.lastZoneId;
	if lastZoneId and gRes:GetFileLen(lastZoneId.."/"..gUpdateLuaFileName) > 0 then
		gRes:ReadResData(lastZoneId.."/"..gUpdateLuaFileName, _VPath.Public);
	end
    if lastZoneId and gRes:GetFileLen(lastZoneId.."/"..gUpdateCsvFileName) > 0 then
		gRes:ReadResData(lastZoneId.."/"..gUpdateCsvFileName, _VPath.Public);
	end

	gData.offlineData:setOffline(true);
	gData.offlineData:loadOfflineData();
	gData.userInfo.roleInfo:loadLevelCSV();
	self:setLoadingText("进入单机模式...");
	self.finishLoginAnimation = true;
    self:enterMainView();
end

function VLoginView:startAccountNameAction()
	local accountName = self.edtRoleLoginV:getText()
    local psw = self.edtPassWordLoginV:getText()
    if accountName == "" then
    	gWindow:showTip("请输入账号名");
    	return;
    end
    if psw == "" then
    	gWindow:showTip("请输入密码");
    	return;
    end
	self:startGameAction();
end

function VLoginView:loginAction()
	if self.layChangeLogin:isVisible() then
		self.layChangeLogin.visible = 0;
		local accountName = self.edtRoleLoginV:getText()
		local psw = self.edtPassWordLoginV:getText()
		local md5Psw = makePswMd5(psw);
		gClient:setUserid(0);
		gReq:MsgReqLogin(self, "loginRespones", accountName, md5Psw);
    	else
		local accountid = gData.accountInfo.id;
		local psw = gData.accountInfo.psw;
		gClient:setUserid(accountid);
    		gReq:MsgReqLogin(self, "loginRespones", nil, psw);
    	end
    self:setLoadingText("正在登录...");
    self:loadingAnimation();
end

function VLoginView:loadingAnimation()
	if not self.loginButton then
		return;
	end

	self.loginButton.visible = 0;
	self("loginSlot").visible = 1;
	self("loginSlotGreen"):setAnchorPoint(cc.p(0,0.5));
	self("loginSlotGreen"):ReLayout();
	self("loginSlotGreen"):RunAction{{"show"}};

	self("loginSlotLayer").fill = {0.01, 1};
	self("loginSlotLayer").fillx = 0.01;
	self("loginSlotLayer"):RunAction{{"hide"}, {"delayTime", 0.001}, {"show"}, {self, "finishSlotAnimation"}};

	self.slotParticleNode = cc.ParticleSystemQuad:create("ladinglizi.plist");
	self.slotParticleNode:setPosition(0, self("loginSlot"):getContentSize().height/2);
	self("loginSlot"):addChild(self.slotParticleNode);

	-- self("loginSlotPointLayer"):RunAction{{"hide"}, {"delayTime", 0.001}, {"show"}};
	self("loginSlotPointLayer").fill = {0.01, 1};
	self("loginSlotPointLayer").visible = 1;
	-- self("loginGreenPoint"):RunAction{{"hide"}, {"delayTime", 0.001}, {"show"},};
end

function VLoginView:finishSlotAnimation( )
	local addFillx = 0.02;
	self("loginSlotLayer").fillx = self("loginSlotLayer").fillx + addFillx;
	self("loginSlotLayer").fill = {self("loginSlotLayer").fillx, 1};
	self("loginSlotPointLayer").fill = {self("loginSlotLayer").fillx, 1};
	if self("loginSlotLayer").fillx < 1 then
		local size = self("loginSlot"):getContentSize();
		local x = size.width * self("loginSlotLayer").fillx;
		self.slotParticleNode:setPosition(x, size.height/2);
		-- local moveX = addFillx * size.width;
		-- self("loginGreenPoint"):RunAction{{"show"}, {"moveBy", 0, moveX, 0}};
		self("loginGreenPoint"):RunAction({"repeatForever", {"sequence", {"rotateBy", 5, 360}}});
		self("loginSlotLayer"):RunAction{{"delayTime", 0.001}, {self, "finishSlotAnimation"}};
	else
		self.finishLoginAnimation = true;
		if self.readyEnterMainView then
			self:enterMainViewAnimation();
		end
	end
end

function VLoginView:registerAction()
	gReq:MsgReqAccountRegister(self, "registerRspones");
	self:setLoadingText("正在注册账号...");
end

function VLoginView:findAccountAction()
	cclog("findAccount");
end

function VLoginView:registerRspones(result, rsp)
	if result == 0 then
		self:loginAction();
	else
		-- self:setEnterEnable(true);
		-- self:setLoadingText("");
		self:resetUI();
	end
end

function VLoginView:loginRespones(result, rsp)
	if result == 0 then
		gData.accountInfo:setLastZoneId(self.currentZoneId);
		local zoneUserIds = gData.accountInfo:useridWithZoneid(self.currentZoneId);
		if #zoneUserIds > 0 then
			cclog("game enter1:"..zoneUserIds[1]);
			self:gameEneter(zoneUserIds[1]);
		else
			self:registerRole();
		end
		if self.layChangeLogin:isVisible() then
			self:closeChangeView();
		end
	else
        if result == 41 then
        	self:registerAction();
        else
        	-- self:setEnterEnable(true);
        	-- self:setLoadingText("");
        	self:resetUI();
        end
	end
end

function VLoginView:registerRole()
	local randomNick = gData.offlineData:getNickName();
	gReq:MsgReqRoleRegister(self, "registerRoleRespone", randomNick);
	self.textLoad.text = "正在注册角色...";
end

function VLoginView:registerRoleRespone(result, rsp)
	cclog("registerRoleRespone");
	if result == 0 then
		cclog("self.currentZoneId:"..self.currentZoneId);
		local zoneUserIds = gData.accountInfo:useridWithZoneid(self.currentZoneId);
		if #zoneUserIds > 0 then
			cclog("game enter2:"..zoneUserIds[1]);
			self:gameEneter(zoneUserIds[1]);
		end
	else
		self:resetUI();
		-- self:setEnterEnable(true);
		-- self:setLoadingText("");
	end
end

function VLoginView:gameEneter(userid)
	gRes:makeDir(tostring(gZoneid).."/"..userid);
	gReq:MsgReqGameEnter(self, "enterGameRespone", userid, false);
	gData.accountInfo:setLastRoleId(userid);
	self.textLoad.text = "正在进入游戏...";
	if self.packageParams then
		if self.packageParams.findAccount then
			gSys:saveThirdUserId(self.packageParams.userId);
		end
		if self.packageParams.newAccount then
			local aParam = Var();
			aParam.binding_type = BindingType.BindingPartnerid;
			aParam.value = self.packageParams.userId;
			aParam.partner_channel = getPartnerChannel();
			gReq:MsgReqAccountBinding2(self, "ReqAccountBindingBack", aParam);
		end
	end
end

function VLoginView:enterGameRespone(result, rsp)
	if result == 0 then
		--跑马灯信息

		self.notify_infos = rsp.notify_infos;
	
		if gData.offlineData:hasOfflineDataFile() then
			self:uploadOfflineData();
		elseif gData.offlineData:hasEmptyDataFile() then
			gData.offlineData:moveOfflineData();
			self:uploadOfflineData();
		else
			self:synchronizeAll();
		end
	else
		self:resetUI();
		-- self:setEnterEnable(true);
		-- self:setLoadingText("");
	end
end

function VLoginView:uploadOfflineData()
	cclog("uploadOfflineData");
	local data = gData.offlineData:getDeltaOfflineData();
	if next(data) then
		gReq:MsgReqDungeonReport(self, "uploadOfflineDataRespone", data);
	else
		self:uploadOfflineDataRespone(0, nil);
	end;
	self.textLoad.text = "同步本地数据...";
end

function VLoginView:uploadOfflineDataRespone(result, rsp)
    if result == 0 then
	   cclog("uploadOfflineDataRespone");
	   self:synchronizeAll()
	else
        self:resetUI();
	end
end

function VLoginView:synchronizeAll()
	cclog("synchronizeAll");
	local param = {};
	param.syn_flag = 0;
	param.data_type = GameDataType.DataTypeAll;
	gReq:MsgReqUserDataSyn(self, "synchronizeRespone", param);
	gData.userInfo:initialize();--先清掉数据再同步
	gData.offlineData:loadOtherData();--更新farmEntered等客户端本地状态
	self.textLoad.text = "正在同步角色信息...";
end

function VLoginView:synchronizeRespone(result, rsp)
	if result == 0 then
		gData:DidSynData();
		gData:DidChatData()
		local iter = VDataIter();
		local needSave = false;
		if self.notify_infos then
			while self.notify_infos:Travel(iter) do
				local notify = iter:Data();
				local message = VMessage:new();
				message:loadWithNotify(notify);
				if message:expireTime() > 0 then
					table.insert(gData.notifyInfo.notifyArray, message);
				else
					needSave = true;
				end
			end
			if needSave then
				gData.notifyInfo:saveToFile();
			else
				gData.notifyInfo:sortMessage();
			end
		end
		self:enterMainView();
	else
		self:resetUI();
		-- self:setEnterEnable(true);
		-- self:setLoadingText("");
	end
end

function VLoginView:enterMainView()
	self.readyEnterMainView = true;
	if self.finishLoginAnimation then
		self:enterMainViewAnimation();
	end
end

function VLoginView:enterMainViewAnimation( )
	gSys:doWebCmd("close");
	--保存推送所需要的信息
	if gIP and gPort then
		gSys:setNotifyServerInfo(gIP, gPort, gNotifyTime, gZoneid, gData.userInfo.userid);
	end
	gWindow:closeCloud(self, "goToMainView");
end

function VLoginView:goToMainView()
	local mainView = VNode("vMainView.vui");
	gWindow:Replace(mainView, function() gData:DidEnterMainView(); gWindow:openCloud(); gMainView:notice(); end);
end

function VLoginView:forgetPswAction()
	self:closeChangeView();
	local findView = VNode("vfindAccount.vui");
	self:Push(findView);
end

function VLoginView:openWebPage()
	if gSiteUrl then
		gSys:openSite(gSiteUrl);
	end
end

function VLoginView:openClientServerPhone()
	local clientString = gFormat("点击确定拨打官方客服电话\n%s", gGameMasterPhone);
	gWindow:showConfirmTip(clientString, "确定", "取消", self, "callClientServerPhone")
end

function VLoginView:callClientServerPhone()
	gSys:callPhone(gGameMasterPhone);
end

function VLoginView:openSettingView()
	local systemSetDlg = VNode("vGameSetDlg.vui");
    gView():Push(systemSetDlg);
end
function getPackageVerLogo()
    if gVerSurf == nil or gVerUrl == nil then
        return
    end
	downLoadFile(gVerUrl..gVerSurf, nil, "if gView() == gMainView or gView() == gBattleView then return end;gView():getPackageVerCheckFinish(gLua:Param(),2)")
end

function getPackageVerInit()
    if gVerSurf == nil or gVerUrl == nil or getPackageFinishFlag ~= nil then
        return
    end
	downLoadFile(gVerUrl..gVerSurf, nil, "if gView() == gMainView or gView() == gBattleView or gStartGame ~= nil then return end;gView():getPackageVerCheckFinish(gLua:Param(),1)")
end

function VLoginView:getPackageVerCheckFinish(msg,times)    
	local ret = msg:Number("ret");
	if ret == 0 then
		local content = msg:String("content");
        if(tonumber(content) < gPackageVersion) then
            gForceOffline = true;
        else
            gForceOffline = false;
        end            
        getPackageFinishFlag = true;
	else
        getPackageFinishFlag = false;
		cclog("package ver get error");
	end   
     if times == 2 then
        self:startGameLogic();              
    elseif times == 1 then
        if self ~= nil and self.ok ~= nil then            
            self:setInitBtnStatus();
	    if not gUpdatingZoneList and gForceOffline == false then
            	self:getZoneList();
            end
        end          
    end		
end
--获取服务器的版本号，加载就执行
getPackageVerInit();
