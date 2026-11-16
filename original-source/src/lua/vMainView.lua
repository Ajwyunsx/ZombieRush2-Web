--vmain.lua
require "vManorView"
require "vFarmLayer"
require "vShopDlg"
require "vBagDlg"
require "vOperationLayer"

require "vLaboratoryDlg"
require "vHomingRoadAmt"
require "vHomingRoad"
require "vBuyFarmerDlg"

require "vActivityDlg"
require "vPaymentDlg"

require "vMyInfoDlg"

require "vSystemSetDlg"
require "vSystemNoticeLayer"
require "vWorldChatNoticeLayer"
require "vOutLineLogDlg"
require "vPrivatChatDlg"
require "vBuildingInfoDlg"
require "vBuildingUpgradeDlg"

require "vEventEntryDlg"

require "vNoticeInfoCell"
require "vSocietyDlg"
require "vBannerInfoDlg"
require "vChapterDlg"

require "vChooseLayer"
require "vCardLevelUpDlg.lua"


VMainView = VClass("MainView", VView)

EBattleRequestType = {
	Observe = 1,
	Attack = 2,
	Revenge = 3,
	Replay = 4,
	Dungeon = 5,
	Group = 6,
}

function VMainView:onPush()
	
	gAudio:playMusic("enterGame.ogg", true);


	if not self.userInfo then
		self.userInfo = gData.userInfo;
	end
	
	gMainView = self;

	self.manorView = self("manorView");
	self.imgChatView = self("imgChatView");
	self.imgRedTip = self("imgRedTip");
	self.txtUnreadTip = self("txtUnreadTip");

	self.texSunValue = self("texSunValue");
	self.texGoldValue = self("texGoldValue");
	self.texCurrenyValue = self("texCurrenyValue");
	self.texFarmerValue = self("texFarmerValue");
	self.txtVIPTitle = self("txtVIPTitle");
	self.texSunLimit = self("texSunLimit");
	self.texGoldLimit = self("texGoldLimit");
	self.texLevelNumber = self("texLevelNumber");
	self.returnSelfFarm = self("returnSelfFarm");
	self.friendBtn = self("friendBtn");
	self.btnCurrenyAdd = self("btnCurrenyAdd");


	self.imgHead = self("imgHead");
	self.btnFarmerAdd = self("btnFarmerAdd");
	self.imgLogRedBtn = self("imgLogRedBtn");
	self.txtLogUnread = self("txtLogUnread");

	self.btnMoreFunc = self("btnMoreFunc");
	self.texUpdateApk = self("texUpdateApk");
	self.btnUpdateApk = self("btnUpdateApk");
	self.btnStore = self("btnStore");
	self.btnBag = self("btnBag");
	self.btnSpecial = self("btnSpecial");
	self.btnSysMenu = self("btnSysMenu");
	self.btnBattle = self("btnBattle");
	self.pveBtn = self("pveBtn");
	self.cardBtn = self("cardBtn");

	self.layOperation = self("layOperation");

	self.eventAndNoticeLayer = self("eventAndNoticeLayer");
	self.qiandao = self("btnQiandao");
	self.huodong = self("btnHuodong");


	--战旗
	self.layerBanner = self("layerBanner");
	self.map = VHLMap:new();
	self.activityTips = {};
	self.amt = {};
	self:searchSelfRankPos();
	self:loadUserInfo(self.userInfo);
	self:openUserFunction();

	if not gData.userInfo.farmEntered then
		self.guideImageIndex = 1;
		self.guideImageMax = 9;
		self.guideBg = VImage{name="imgGuideBg", image="guideBg.jpg", layout="Center", fit="Full"};
		self.guide = VImage{name="imgGuide", image="guide1.png", layout="Center", fit="Full", onClick="gView():nextGuide()", touch = 1};
		self:Push(self.guideBg);
		self.guideBg:Push(self.guide);
	end
	
	local dungeonInfo = gData.userInfo.dungeonInfo

	if gData.offlineData:isOffline() or dungeonInfo.needShow or (not gData.userInfo.farmEntered) then
        local ChapterDlg = VNode("vChapterDlg.vui");
        gAutoShowLevelDlg = dungeonInfo.levelShow;
        gView():Push(ChapterDlg);
        if dungeonInfo.levelShow then
	        local dlg = VNode("vLevelDlg.vui")
	        dlg:SetDlgInfo(dungeonInfo.levelShow)
	        gView():Push(dlg)


	        local purchaseShow = dungeonInfo.purchaseShow

	        if purchaseShow and dungeonInfo.tipShow ~= 1 and dungeonInfo:CheckShopValid(purchaseShow.id, 2) then
	        	-- local dlg = VNode("vDungeonShopDlg.vui")
	        	-- dlg:SetDlgInfo(purchaseShow, 2)
	        	-- gView():Push(dlg)
	        	dungeonInfo.purchaseShow = false
	        	dungeonInfo:OpenShopDlg(purchaseShow.id, 2)
	        elseif purchaseShow and dungeonInfo.tipShow == 1 and dungeonInfo:CheckShopValid(purchaseShow.id, 2) then
	        	dungeonInfo.tipShow = false
	        	-- gWindow:showBattleFaildTip(1, purchaseShow, 2)
	        	dungeonInfo.purchaseShow = false
	        	dungeonInfo:OpenShopDlg(purchaseShow.id, 2)
	        elseif dungeonInfo.tipShow == 2 then
	        	dungeonInfo.tipShow = false
	        	local vipInfo = self.userInfo.roleInfo.vipInfo;
				if vipInfo[0] < 1 then
					gWindow:showBattleFaildTip(2);
				elseif vipInfo[0] < 3 then
					gWindow:showBattleFaildTip(3);
				elseif vipInfo[0] < 5 then
					gWindow:showBattleFaildTip(4);
				else
				end
	        elseif dungeonInfo.tipShow == 3 then
	        	dungeonInfo.tipShow = false
	        	gWindow:showFinalBattleFaildTip()
	        end
    	end
	end

	if gData.showLog then
		local dlg = VNode("vPVPOptionDlg.vui")
    	gView():Push(dlg)
		dlg:onOptionBtnClick(5)
	end

	self:activityInfoQuery();

	if not self.hasloadLastMessage then
		gData.chatInfo:LoadLastMessageList()
		self.hasloadLastMessage = true
	end

	if not gData.offlineData.offline then
		if self.dungeonTip and dungeonInfo:GetLevelRecord(11001) > 0 then
	 		self.dungeonTip:doPop();
	 		self.dungeonTip = nil;
	 	end
	 	if not self.dungeonTip and dungeonInfo:GetLevelRecord(11001) == 0 then
	 		self.dungeonTip = VImage{name="dungeonTip", image="battleHandArrow.png", layout="UpOut", rotate=-90, scale=0.8, offset={10,0}};
	 		self.dungeonTip:RunAction{"repeatForever", {"sequence", {"moveBy", 0.5, 0, -20}, {"moveBy", 0.5, 0, 20}}};
	 		self.pveBtn:Push(self.dungeonTip);
	 	end
	end

	cclog("vmain on push")
end

function VMainView:showAdView()
	local webView = VNode("vwebView.vui");
	webView.url = gResAllUrl.."notice/notice"..gZoneid..".html?channel="..gReq.channelID;
	self:Push(webView);
end

function VMainView:closeAdView()
	local webView = self("WebView");
	if webView then
		webView:closeView();
	end
end

function VMainView:checkNoticeFlag() --检查是否有弹出公告
        if gForceOffline then
           return;
        end
	local noticeUrl = gResAllUrl.."notice/notice"..gZoneid;
	downLoadFile(noticeUrl, nil, "gView():noticeCheckFinish(gLua:Param())")
end

function VMainView:notice()
	if gData.userInfo.farmEntered then
		self:checkNoticeFlag();
	end
end

function VMainView:noticeCheckFinish(msg)
	if msg then
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
end

function VMainView:CheckShopRefresh( ... )
	-- body
	local shop = gData.userInfo.roleInfo.roleShopInfo.shopInfo;

	if not shop then
		return
	end

	local time = shop.expireTime - gData:currentTime()

	if time > 0 then
		self.shop_refresh = gDtr:getScheduler():scheduleScriptFunc( 
                function () VCallBack(self, "shopRefreshNotice"); end, time, false);
	else
		self:shopRefreshNotice()
	end
end

function VMainView:shopRefreshNotice( ... )
	-- body
	if self.shop_refresh then
		gDtr:getScheduler():unscheduleScriptEntry(self.shop_refresh)
        self.resTime = nil;
	end

	gData.noticeManager:cover(NoticeType.shop_refresh, 1)
end

function VMainView:nextGuide()
	self.guideImageIndex = self.guideImageIndex + 1;
	if self.guideImageIndex <= self.guideImageMax then
		self.guide.image = "guide"..self.guideImageIndex..".png";
	else
		self.guideBg:doPop();
		self.guide = nil;
		self.guideBg = nil;
		self:checkNoticeFlag();
	end
end

function VMainView:loadUserInfo(userInfo)
	if not userInfo then return end;
	self.userInfo = userInfo;

	self.manorView:loadUserInfo(self.userInfo);

	self:refreshUserMoney();
	self:refreshUserHeadImage();
	self:refreshUserInfo();
	self:refreshProtectTime();
	self:refreshAttackInfo();
	self:refreshBuilding();
	if self.userInfo.isSelf then
		-- self("imgCurreny").visible = 1;

		-- self.btnBag.visible = 1;
		-- self.btnSpecial.visible = 1;
		-- self.btnSysMenu.visible = 1;
		self("LeftOpLayer").visible = 1;
		self.btnFarmerAdd.visible = 1;
        self.eventAndNoticeLayer.visible = 1;

        self.returnSelfFarm.visible = 0;
        self.friendBtn.visible = 0;
        self.btnStore:setEnable(true);
        self.btnCurrenyAdd:setEnable(true);

        self:refreshNoticeInfos();
        self.userInfo.manorInfo:checkWorkingFarmer();
	else
		-- self("imgCurreny").visible = 0;
		-- self.btnBag.visible = 0;
		-- self.btnSpecial.visible = 0;
		-- self.btnSysMenu.visible = 0;
		self("LeftOpLayer").visible = 0;
		self.btnFarmerAdd.visible = 0;
		self.eventAndNoticeLayer.visible = 0;

		self.returnSelfFarm.visible = 1;
		self.friendBtn.visible = 1;
		self.btnStore:setEnable(false);
        self.btnCurrenyAdd:setEnable(false);

		if self.activityDlg and self.activityDlg:isVisible() then
			self.activityDlg:hideDlg();
		end

		if gData:isMyFriend(self.userInfo.userid) then
			self.friendBtn:setEnable(false);
			self.friendBtn.gray = 1
		else
			self.friendBtn:setEnable(true);
		end
	end
	self:refreshFarmerValue();
	self:checkUpAPKButton();
	self:setBannerImage();
end

function VMainView:setBannerImage()
	if self.userInfo and self.userInfo.roleInfo then
		self.layerBanner:changeArmtureImage(self.userInfo.roleInfo:getBannerImageInMainView());
	end
end


function VMainView:checkUpAPKButton()
	if self.userInfo.isSelf and gUpdate.apkFileName then
		self.btnUpdateApk.visible = 1;

		if gRes:GetFileLen(gUpdate.apkFileName) > 0 then
			self.isUpdateApk = 2;
			self.texUpdateApk.text = "完成";
		end
	else
		self.btnUpdateApk.visible = 0;
	end
end

function VMainView:onPushFinishBase()
	VView.onPushFinishBase(self);

    self:CheckNewBagItem();

    gData:RunTrainning();

    self.isLogin = true;
    self:ResetMonsterAmt();
end

function VMainView:activityInfoQuery()
	cclog("activityInfoQuery");
	gReq:MsgReqActivityInfoQuery(self, "activityInfoQueryResponeBackground");
end

function VMainView:activityInfoQueryResponeBackground(result, rsp)
	if result == 0 then
		cclog("同步活动数据完成");	
	else
		cclog("同步活动数据失败");
	end
end

function VMainView:noticeFlagCheckFinish()
	--do nothing
end

function VMainView:newNotifyInfoComeIn()
	self("lyrSystemNotice"):StartShow()
end

function VMainView:newBattleLogsComeIn()
	-- local newNumber = gData.battleBriefLogs:newNumbers(_VLogType.defend)
	-- if newNumber > 0 then
	-- 	self.imgLogRedBtn.visible = 1;
	-- 	self.txtLogUnread.text = newNumber;
	-- end
	self:ShowOutLineLog();
end

function VMainView:newLevelUpInfoComeIn()
	self:ShowLvUpNotic();
end

function VMainView:ShowLvUpNotic()
    if gData.firstLevelUpInfo ~= nil then
        local count = table.getn(gData.firstLevelUpInfo)

        for var = 1, count do
            local levelInfo = gData.firstLevelUpInfo[var]
            local text = self:GetLevelNoticeText(levelInfo)
            local action = gView():Push(VText{name = "levelNotice"..var, text = text, layout = "Center", step = {0, 2}, visible = 0})
--            local action = gView():Push(VText{name = "levelNotice"..var, text = "四点多法", layout = "Center", step = {0, -1}, visible = 0})
            action:RunAction{{"sequence", {"delayTime", var - 1 + (var - 1) * 0.5}, {"show"}, {"moveBy", 3, 0, 50}, {"delete"}}}
        end

        gData.firstLevelUpInfo = nil
    end
end

function VMainView:ShowOutLineLog()

    local logList = gData.battleBriefLogs:opLogArray(_VLogType.defend)
    gData.battleBriefLogs.isFrist = false;


    if next(logList) then
        local outLineLog = {};
        for i,v in ipairs(logList) do
        	if v.isNew then
        		v.isNew = false;
        		table.insert(outLineLog, v);
        	end
        end
        if next(outLineLog) then
            local dlg = VNode("vOutLineLogDlg.vui")
            dlg:SetLogList(outLineLog)
            self:Push(dlg)
        end
    end
end

function VMainView:GetLevelNoticeText(levelInfo)
    local text = ""
	if levelInfo.target == LEVELUP_TYPE.LevelupPlant then
       
        local info = gData.userInfo.manorInfo:farmInfoWithId(levelInfo.value)
        if info then
        	text = info.plantInfo.plantLevel.."级"..info.plantInfo.plantName.."升级完成"	
        end
	elseif levelInfo.target == LEVELUP_TYPE.LevelupBuilding then

        local info = gData.userInfo.manorInfo:GetBuildingLevelInfo(tonumber(levelInfo.value))
        if info then
            text = info.lv.."级"..info.nameb.."升级完成"
        end
	elseif levelInfo.target == LEVELUP_TYPE.LevelupMonster then

        local info = gData.userInfo.monsterInfo:GetMonsterWithid(tonumber(levelInfo.value))
--        local info = gData.userInfo.armyTechInfos:arymTechInfoWithMonsterId(tonumber(levelInfo.value))
        if info then
            text = info.level.."级"..info.name.."升级完成"
        end
	end
	
	return text
end

function VMainView:onShow()
	cclog("vmain on show")
	
	gData:RunTrainning()
	
	self:refreshUserMoney();
	self:refreshNoticeInfos();
	self:setBannerImage();
end

function VMainView:onHide()
	cclog("vmain on hide")
end

function VMainView:onPop()
	gEvent:removeAllEvent();
	cclog("vmain on pop")
end

function VMainView:onForeground()
	VView.onForeground(self);
	self.manorView:onForeground();

	self:refreshUserMoney();
	self:refreshUserInfo();
	self:refreshProtectTime();
	self:refreshAttackInfo();
	self:refreshBuilding();

	if self.userInfo.isSelf then
		self.userInfo:checkVersion(0);
	end

	if gAudio:getMusicOff() == 1 and gAudio:isMusicPlaying() then
		gAudio:pauseMusic();
	end
	gReq:MsgReqGameEnter(self, "", gData.userInfo.userid, true);
end

function VMainView:onKeyBack()
	local node = self(-1);
	if node and node.isMsgBox then
		self:Pop()
		return true;
	else
		return false;
	end
end

function VMainView:refreshAttackInfo()
	-- if not self.userInfo.isSelf then return end
	-- if self.userInfo:isAttack() then
	-- 	self.testAttack.visible = 1;
	-- 	self.testAttackTime.visible = 1;
	-- 	self.testAttack.text = "正在被"..self.userInfo.roleInfo.defendInfo.attacker.."打";
	-- 	self.testAttackTime.time = self.userInfo.roleInfo.defendInfo:attackLeftTime();
	-- else
	-- 	self.testAttack.visible = 0;
	-- 	self.testAttackTime.visible = 0;
	-- end
end

function VMainView:refreshProtectTime()
	-- self.testProtectTime.time = self.userInfo.roleInfo:protectTime();
end

function VMainView:refreshUserHeadImage()
	self.imgHead:setHead(self.userInfo.userid, self.userInfo.roleInfo.image, nil, vipLevel);
	self.imgHead:SetHeadImageShader("mv_zhezhao.png");
end

function VMainView:refreshUserMoney()
	local money = self.userInfo.roleInfo:attrValue(AttrType.AttrTypeMoney);
	local maxMoney = self.userInfo.manorInfo.storeInfo.coinMax or 1;

	-- if self.isLogin and money ~= self.texGoldValue.curValue then
	-- 	self:showAddCoinAcion(self.texGoldValue.curValue, money);
	-- else
		self.texGoldValue.text = money;
		self.texGoldValue.curValue = money;
	-- end

	local sunshine = self.userInfo.roleInfo:attrValue(AttrType.AttrTypeSunshine);
	local maxSunshine = self.userInfo.manorInfo.storeInfo.sunshineMax or 1;

	-- if self.isLogin and sunshine ~= self.texSunValue.curValue then
	-- 	self:showAddSunAcion(self.texSunValue.curValue, sunshine);
	-- else
		self.texSunValue.text = sunshine;
		self.texSunValue.curValue = sunshine;
	-- end

	if sunshine == maxSunshine then
		self.texSunValue.color = {255,0,0};
	else
		self.texSunValue.color = {255,255,255};
	end

	if money == maxMoney then
		self.texGoldValue.color = {255,0,0};
	else
		self.texGoldValue.color = {255,255,255};
	end
	
	self.texGoldLimit.text = maxMoney;
	self.texSunLimit.text = maxSunshine;
	if self.userInfo.isSelf then 
		self.texCurrenyValue.text = self.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency);
	else
		self.texCurrenyValue.text = "*****";
	end
	self("sunLayer"):ReLayout();
	self("coinLayer"):ReLayout();
end

function VMainView:refreshFarmerValue()
	local curCount = self.userInfo.manorInfo:idleFarmer();
	local limitCount = self.userInfo.manorInfo.farmerCount;

	self.texFarmerValue.text = curCount.."/"..limitCount;
	local cost = self.userInfo.manorInfo:farmerNextCost();
	if not cost then
		self("btnFarmerAdd").visible = 0;
	end
end

function VMainView:refreshUserInfo()
	local userLevel = self.userInfo.roleInfo:attrValue(AttrType.AttrTypeLevel);
	self.texLevelNumber.text = userLevel;
	
	local vipInfo = self.userInfo.roleInfo.vipInfo;
	local vipLevel = vipInfo[0];
	self.txtVIPTitle.text = "v"..vipLevel;
end

function VMainView:refreshBuilding(buildingType, isFinish)
	if buildingType then
		self.manorView:refreshBuilding(buildingType, isFinish);
	else
        self.manorView:refreshBuilding(BUILDING_TYPE.BuildingStore); self.manorView:refreshBuilding(BUILDING_TYPE.BuildingAltar);
		self.manorView:refreshBuilding(BUILDING_TYPE.BuildingLaboratory);
		self.manorView:refreshBuilding(BUILDING_TYPE.BuildingBasecamp);
	end
end

function VMainView:getInfoUI(callBack)
	local btn = {};
	btn.extend = "信息";
	btn.descText = "mv_zixinxi.png";
	btn.icon = "mv_xinxi.png";
	btn.delegate = self;
    btn.callBack = callBack;
	return btn;
end

function VMainView:getStopLevelupUI(callBack)
	local btn = {};
	btn.extend = "停止升级";
	btn.descText = "mv_ziquxiao.png";
	btn.icon = "mv_ziquxiaoanniu.png";
	btn.delegate = self;
    btn.callBack = callBack;
	return btn;
end

function VMainView:getAccelerateUI(leftTime, maxTime, callBack)
	local btn = {};
	btn.extend = "立刻完成";
	btn.descText = "mv_zilijiwancheng.png";
	btn.icon = "mv_zilijiwanchenganniu.png";
	btn.cost = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupBuilding, leftTime, maxTime);
	btn.delegate = self;
    btn.callBack = callBack;
    return btn;
end

function VMainView:getLevelupUI(callBack)
	local btn = {};
	btn.extend = "升级";
	btn.descText = "mv_shengjizi.png";
	btn.icon = "mv_shengji.png";
	btn.delegate = self;
    btn.callBack = callBack;
    return btn;
end

--太阳祭坛
function VMainView:openAltar()
	if not self.userInfo.isSelf then
		gWindow:showTip("当前建筑内容属科技机密,不可以查看");
		return;
	end

	local info = {};

    if self.userInfo.roleInfo:isFunctionOpen(GameFunction.altar_info) then
		table.insert(info, self:getInfoUI("onClickAltarCallBack"));
	end

	local mi = self.userInfo.manorInfo;
	if mi.altarInfo.canUpgrade and self.userInfo.roleInfo:isFunctionOpen(GameFunction.altar_levelup) then
		local time  = mi:levelUpTime(BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
		if time > 0 then
			if self.userInfo.roleInfo.isFunctionOpen(GameFunction.levelup_cancel) then
				table.insert(info, self:getStopLevelupUI("onClickAltarCallBack"));
			end

			if self.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_accelerate) then
				local leftTime = mi:levelUpTime(BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
                local maxTime = mi.altarInfo.upgradeTime;
				table.insert(info, self:getAccelerateUI(leftTime, maxTime, "onClickAltarCallBack"));
			end
		else
			table.insert(info, self:getLevelupUI("onClickAltarCallBack"));
		end
	end

	local title = {};
	title.color = {255,255,255};
	title.text = "太阳祭坛"..mi.altarInfo.level.."级"
	self:ShowOperationLay(info, title, BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
end

function VMainView:onClickAltarCallBack(t)
	if t == "信息" then
		local bd = VNode("vBuildingInfoDlg.vui");
		bd:SetBuildingType(BUILDING_TYPE.BuildingAltar);
        self:Push(bd);
	elseif t == "升级" then
        local bu = VNode("vBuildingUpgradeDlg.vui");
        bu:SetBuildingType(BUILDING_TYPE.BuildingAltar);
        self:Push(bu);
	elseif t == "停止升级" then
		local itemCommon = gData:LoadItemCommon();
		local percent = itemCommon.retResScale;
		local msg = "停止升级只会返还"..percent.."%的费用！";
		local title = "停止升级吗？"
		gWindow:showConfirmTip(msg, "确定", "取消", self, "LevelUpCancel", "", title,
            BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
	elseif t== "立刻完成" then
		local mi = self.userInfo.manorInfo;
		local maxTime = mi.altarInfo.upgradeTime;
        local leftTime = mi:levelUpTime(BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
		local vcoin = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupBuilding, leftTime, maxTime);
		local msg = "立刻完成需要消耗"..vcoin.."钻石！";
		local title = "立刻完成升级吗？";
		gWindow:showPayTip(title, msg, vcoin, self, "LevelUpAccelerate",
            BUILDING_TYPE.BuildingAltar, LEVELUP_TYPE.LevelupBuilding);
	end
end

--金库
function VMainView:openVaults()
	if not self.userInfo.isSelf then		
		gWindow:showTip("当前建筑内容属科技机密,不可以查看");
		return;
	end

	local info = {};
    if self.userInfo.roleInfo:isFunctionOpen(GameFunction.store_info) then
		table.insert(info, self:getInfoUI("onClickVaultsCallBack"));
	end

	local mi = self.userInfo.manorInfo;
    if mi.storeInfo.canUpgrade and self.userInfo.roleInfo:isFunctionOpen(GameFunction.store_levelup) then
        local time = mi:levelUpTime(BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
		if time > 0 then
			if self.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_cancel) then
				table.insert(info,self:getStopLevelupUI("onClickVaultsCallBack"));
			end

			if self.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_accelerate) then
                local leftTime = mi:levelUpTime(BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
                local maxTime = mi.storeInfo.upgradeTime;
				table.insert(info, self:getAccelerateUI(leftTime, maxTime, "onClickVaultsCallBack"));
			end
		else
			table.insert(info, self:getLevelupUI("onClickVaultsCallBack"));
		end
	end

	local title = {};
	title.color = {255,255,255};
    title.text = "金库"..mi.storeInfo.level.."级";
    self:ShowOperationLay(info, title, BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
end

function VMainView:onClickVaultsCallBack(t)
	if t == "升级" then
        local bd = VNode("vBuildingUpgradeDlg.vui");
		bd:SetBuildingType(BUILDING_TYPE.BuildingStore);
        self:Push(bd);
	elseif t == "停止升级" then
		local itemCommon = gData:LoadItemCommon();
		local percent = itemCommon.retResScale;
		local msg = "停止升级只会返还"..percent.."%的费用！";
		local title = "停止升级吗？"
		gWindow:showConfirmTip(msg, "确定", "取消", self, "LevelUpCancel", "", title,
            BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
	elseif t== "立刻完成" then
		local mi = self.userInfo.manorInfo;
		local maxTime = mi.storeInfo.upgradeTime;
        local leftTime = mi:levelUpTime(BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
		local vcoin = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupBuilding, leftTime, maxTime);
		local msg = "立刻完成需要消耗"..vcoin.."钻石！";
		local title = "立刻完成升级吗？";
		gWindow:showPayTip(title, msg, vcoin, self, "LevelUpAccelerate",
            BUILDING_TYPE.BuildingStore, LEVELUP_TYPE.LevelupBuilding);
	elseif t == "信息" then
		local bd = VNode("vBuildingInfoDlg.vui");
		bd:SetBuildingType(BUILDING_TYPE.BuildingStore);
        self:Push(bd);
	end
end

function VMainView:onOpenMyInfoDlg()
    local myInfoDlg = VNode("vMyInfoDlg.vui");
    myInfoDlg:SetRoleInfo(self.userInfo);
    self:Push(myInfoDlg);
end

--研究所
function VMainView:openCollege()
	if not self.userInfo.isSelf then
		gWindow:showTip("当前建筑内容属科技机密,不可以查看");
		return;
	end

	local info = {};
	if self.userInfo.roleInfo:isFunctionOpen(GameFunction.laboratory_info) then
		table.insert(info, self:getInfoUI("onClickCollegeCallBack"));
	end


	local mi = self.userInfo.manorInfo;
	if mi.laboratory.canUpgrade and self.userInfo.roleInfo:isFunctionOpen(GameFunction.laboratory_levelup) then
		if mi:levelUpTime(BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding) > 0 then
			if self.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_cancel) then
				table.insert(info,self:getStopLevelupUI("onClickCollegeCallBack"));
			end

			if self.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_accelerate) then
				local maxTime = mi.laboratory.upgradeTime;
				local leftTime = mi:levelUpTime(BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding);
				table.insert(info, self:getAccelerateUI(leftTime, maxTime, "onClickCollegeCallBack"));
			end
		else
			table.insert(info, self:getLevelupUI("onClickCollegeCallBack"));
		end
	end

	if self.userInfo.roleInfo:isFunctionOpen(GameFunction.laboratory_research) then
		local btn3 = {};
		btn3.icon = "mv_shengxing.png";
		btn3.delegate = self;
		btn3.callBack = "onClickCollegeCallBack";
		btn3.extend = "研究所";
		btn3.descText = "mv_zishengxing.png";
		table.insert(info,btn3);
	end

	local title = {};
	title.color = {255,255,255};
	title.text = "研究所"..mi.laboratory.level.."级"
	self:ShowOperationLay(info, title, BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding);
end

function VMainView:onClickCollegeCallBack(t)
	if t == "研究所" then
	--		self:Push("vLaboratoryDlg.vui");
        local bu = VNode("vLaboratoryDlg.vui");
        self:Push(bu);
	elseif t == "升级" then
		local bd = VNode("vBuildingUpgradeDlg.vui");
		bd:SetBuildingType(BUILDING_TYPE.BuildingLaboratory);
        self:Push(bd);
	elseif t == "信息" then
		local bd = VNode("vBuildingInfoDlg.vui");
		bd:SetBuildingType(BUILDING_TYPE.BuildingLaboratory);
        self:Push(bd);
	elseif t == "停止升级" then
		local itemCommon = gData:LoadItemCommon();
		local percent = itemCommon.retResScale;
		local msg = "停止升级只会返还"..percent.."%的费用！";
		local title = "停止升级吗？"
		gWindow:showConfirmTip(msg, "确定", "取消", self, "LevelUpCancel", "", title,
			 BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding);
	elseif t== "立刻完成" then
		local mi = self.userInfo.manorInfo;
		local maxTime = mi.laboratory.upgradeTime;
		local leftTime = mi:levelUpTime(BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding);
		local vcoin = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupBuilding, leftTime, maxTime);
		local msg = "立刻完成需要消耗"..vcoin.."钻石！";
		local title = "立刻完成升级吗？";
		gWindow:showPayTip(title, msg, vcoin, self, "LevelUpAccelerate",
			BUILDING_TYPE.BuildingLaboratory, LEVELUP_TYPE.LevelupBuilding);
	end
end


--庄园
function VMainView:openBaseCamp()
	if not self.userInfo.isSelf then
		gWindow:showTip("当前建筑内容属科技机密,不可以查看");
		return;
	end
	
	local info = {};
	if self.userInfo.roleInfo:isFunctionOpen(GameFunction.basecamp_info) then
		table.insert(info, self:getInfoUI("onClickBaseCampCallBack"));
	end

	local mi = self.userInfo.manorInfo;
	if mi.baseCampInfo.canUpdate and self.userInfo.roleInfo:isFunctionOpen(GameFunction.basecamp_levelup) then
		if mi:levelUpTime(BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding) > 0 then
			if self.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_cancel) then
				table.insert(info,self:getStopLevelupUI("onClickBaseCampCallBack"));
			end

			if self.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_accelerate) then
				local maxTime = mi.baseCampInfo.upgradeTime;
				local leftTime = mi:levelUpTime(BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding);
				table.insert(info, self:getAccelerateUI(leftTime, maxTime, "onClickBaseCampCallBack"));
			end
		else
			table.insert(info, self:getLevelupUI("onClickBaseCampCallBack"));
		end
	end
	local title = {};
	title.text = "庄园"..mi.baseCampInfo.level.."级";
	title.color = {255,255,255};
	self:ShowOperationLay(info, title, BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding);
end

function VMainView:onClickBaseCampCallBack(t)
	if t == "信息" then
		local bd = VNode("vBuildingInfoDlg.vui");
		bd:SetBuildingType(BUILDING_TYPE.BuildingBasecamp);
        self:Push(bd);
	elseif t == "升级" then
		local bd = VNode("vBuildingUpgradeDlg.vui");
		bd:SetBuildingType(BUILDING_TYPE.BuildingBasecamp);
        self:Push(bd);
	elseif t == "停止升级" then
		local itemCommon = gData:LoadItemCommon();
		local percent = itemCommon.retResScale;
		local msg = "停止升级只会返还"..percent.."%的费用！";
		local title = "停止升级吗？"
		gWindow:showConfirmTip(msg, "确定", "取消", self, "LevelUpCancel", "", title,
			 BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding);
	elseif t== "立刻完成" then
		local mi = self.userInfo.manorInfo;
		local maxTime = mi.baseCampInfo.upgradeTime;
		local leftTime = mi:levelUpTime(BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding);
		local vcoin = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupBuilding, leftTime, maxTime);
		local msg = "立刻完成需要消耗"..vcoin.."钻石！";
		local title = "立刻完成升级吗？";
		gWindow:showPayTip(title, msg, vcoin, self, "LevelUpAccelerate",
			BUILDING_TYPE.BuildingBasecamp, LEVELUP_TYPE.LevelupBuilding);
	end
end

function VMainView:LevelUpAccelerate(id, types)

	local mi = self.userInfo.manorInfo;
	local leftTime = mi:levelUpTime(id, types);

	if leftTime <= 0 then
		return;
	end
	local maxTime = 0;
	if id == BUILDING_TYPE.BuildingBasecamp then
		maxTime = mi.baseCampInfo.upgradeTime;
	elseif id == BUILDING_TYPE.BuildingLaboratory then
		maxTime = mi.laboratory.upgradeTime;
	elseif id == BUILDING_TYPE.BuildingAltar then
		maxTime = mi.altarInfo.upgradeTime;
    elseif id == BUILDING_TYPE.BuildingStore then
        maxTime = mi.storeInfo.upgradeTime;
	end
	local cost = gData:getTimeAccelerateCost(types, leftTime, maxTime);
	local curVCoin = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency);

	if cost > curVCoin then
		gWindow:showMoneyLackDlg(cost-curVCoin);
		return;
	end

	if self.manorView:isLevelOping(id) then
		gWindow:showTip("哎呀，操作太快了.");
		return;
	end
	self.manorView:setLevelOpreation(id, true);
	if id == BUILDING_TYPE.BuildingBasecamp then
		self.manorView.btnBaseCamp:levelUpFinishAnimation();
		self.userInfo.manorInfo.baseCampInfo:levelUpFinish(self.userInfo.isSelf);
	elseif id == BUILDING_TYPE.BuildingLaboratory then
		self.manorView.btnCollege:levelUpFinishAnimation();
		self.userInfo.manorInfo.laboratory:levelUpFinish(self.userInfo.isSelf);
	elseif id == BUILDING_TYPE.BuildingAltar then
		self.manorView.btnAltar:levelUpFinishAnimation();
		self.userInfo.manorInfo.altarInfo:levelUpFinish(self.userInfo.isSelf);
    elseif id == BUILDING_TYPE.BuildingStore then
        self.manorView.btnVaults:levelUpFinishAnimation();
        self.userInfo.manorInfo.storeInfo:levelUpFinish(self.userInfo.isSelf);
	end
	self:refreshBuilding(id);
	gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
	gData:enableStopUserSyn(true);
	self.userInfo.manorInfo:cancelLevelUp(id, types);
	gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeCurrency, -cost);
	gReq:MsgReqLevelUpAccelerate(self, "LevelUpAccelerateCallBack", id, types, nil, nil, cost);
	gWindow:showTip("加速成功！", 1);
end

function VMainView:LevelUpCancel(id, type)
	if self.manorView:isLevelOping(id) then
		gWindow:showTip("哎呀，操作太快了.");
		return;
	end
	self.manorView:setLevelOpreation(id, true);

	local mi = self.userInfo.manorInfo;
	local leftTime = mi:levelUpTime(id, type);
	if leftTime <= 0 then
		return;
	end

	gData.userInfo.manorInfo:enableStopHeartBeatSyn(true);
	gData:enableStopUserSyn(true);
	self.userInfo.manorInfo:cancelLevelUp(id, type);
	self:refreshBuilding(id);
	gReq:MsgReqLevelUpCancel(self, "LevelUpCancelCallBack", id, type);
	gWindow:showTip("取消成功！", 1);
end

--立刻完成回调
function VMainView:LevelUpAccelerateCallBack(result, rsp, req)

	local id = req.id:ToInt();

	if result == 0 then
		self.userInfo.manorInfo:removeLevelUpInfo(id,req.type);
	else
		self.userInfo.manorInfo:revertCancelLevelUp(id,req.type);
		if id == BUILDING_TYPE.BuildingBasecamp then
			self.userInfo.manorInfo.baseCampInfo:revertLevelUpFinish(self.userInfo.isSelf);
		elseif id == BUILDING_TYPE.BuildingLaboratory then
			self.userInfo.manorInfo.laboratory:revertLevelUpFinish(self.userInfo.isSelf);
		elseif id == BUILDING_TYPE.BuildingAltar then
			self.userInfo.manorInfo.altarInfo:revertLevelUpFinish(self.userInfo.isSelf);
        elseif id == BUILDING_TYPE.BuildingStore then
            self.userInfo.manorInfo.storeInfo:revertLevelUpFinish(self.userInfo.isSelf);
		end

		gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeCurrency, req.cost);
		self:refreshBuilding(id);
	end
end

--停止升级回调
function VMainView:LevelUpCancelCallBack(result, rsp, req)
	local id = req.id:ToInt();
	if result == 0 then
		self.userInfo.manorInfo:removeLevelUpInfo(id,req.type);
	else
		self.userInfo.manorInfo:revertCancelLevelUp(id,req.type);
		self:refreshBuilding(id);
	end
end


--战旗
function VMainView:openBanner()
	if not self.userInfo.isSelf then
		gWindow:showTip("当前战旗内容属科技机密,不可以查看");
		return;
	end

	local isOpen, openLevel  = self.userInfo:isBannerFuncOpen();

	if not isOpen and openLevel then
		gWindow:showNormalTip("战旗:可以大幅度提升植物和僵尸的战斗力\n\n解锁条件:庄园达到"..openLevel.."级时解锁", nil, "Left");
		return;
	end
	
	local info = {};
	local btn3 = {};
	btn3.icon = "mv_zhanqi.png";
	btn3.delegate = self;
	btn3.callBack = "onClickBannerCallBack";
	btn3.extend = "战旗";
	btn3.descText = "mv_zhanqizi.png";
	table.insert(info,btn3);

	local title = {};
	title.color = {255,255,255};
	title.text = "战旗"
	self:ShowOperationLay(info, title, nil, nil);
end


function VMainView:onClickBannerCallBack(t)
	if t=="战旗" then
		if gData.userInfo.bannerInfos:count() > 0 then
			local bannerInfoDlg = VNode("vBannerInfoDlg.vui");
			gView():Push(bannerInfoDlg);
		else
			gWindow:showConfirmTip("你当前没有任何战旗，请先获得一支战旗再打开战旗建筑。",  "抽取战旗","取消", self,  "openBannerLottery", nil, "抽战旗");
		end
	end
end

function VMainView:openBannerLottery()
	local bannerlotteryDlg = VNode("vBannerlotteryDlg.vui");
	bannerlotteryDlg:setCallBack(self, nil);
	gView():Push(bannerlotteryDlg);
end

function VMainView:addToMyFriend(userid)
    gData:addFriend(userid, self, "ReqFriendAddCallBack");
end

function VMainView:ReqFriendAddCallBack(result, rsp, req)
	if result == 0 then
		if not self.userInfo.isSelf then
			self.friendBtn.gray = 1
			self.friendBtn:setEnable(false);
		end 
	else
	end
end


-- 搜索自己的排名
function VMainView:searchSelfRankPos( )
	if gData.offlineData:isOffline() then
		return;
	end
	if not gData.battleRankQuery then
		gData.battleRankQuery = VBattleRankQuery:new();
	end

	if gData.battleRankQuery.pos == -1 then
		gReq:MsgReqUserRankInfoQuery(0, 10, UserRankType.UserRankTypeBattleScore, self, "getUserRankInfoQueryRsponse");
	end
end

function VMainView:getUserRankInfoQueryRsponse( result, aMsgRspUserRankInfoQuery, req )
	if result == 0 then
		gData.battleRankQuery:synWithPbData(aMsgRspUserRankInfoQuery, 0);
		local idList = gData.battleRankQuery:getNoneUserId(0, 10);
		gData:userBriefInfo(idList);
	end
end

---------------------------------------------- 战斗相关 ---------------------------------------------
-- 打开掠夺界面
function VMainView:openRobView()
	local csv = gData:readCsv("dungeon_function_control.csv");
	local lineData = csv:lineDataWithKey(1);
	local openid = lineData[1];
	local tip = lineData[2];
	if gData.userInfo.dungeonInfo:GetLevelRecord(openid) > 0 then
		self:Push("vPVPOptionDlg.vui");
	else
		gWindow:showTip(tip, 2);
	end
end

-- 是否有兵去开打
function VMainView:haveArmForAttack( requestType )
	local checkZmobie = true;
	if requestType == EBattleRequestType.Dungeon then
		local campaignCsv = gData:readCsv("prop_campaign.csv");
		local campaignData = campaignCsv:lineDataWithKey(self.battleTargetId);
		local attackType = campaignData:Get(3);

		if attackType == BattleType.BattleTypePve then
			checkZmobie = true;
		elseif attackType == BattleType.BattleTypeEvp then
			checkZmobie = false;
		end
	end

	if checkZmobie then
		if gData.userInfo.monsterInfo.monsterInfos then
			if getMapCount(gData.userInfo.monsterInfo.monsterInfos)  > 0 then
				return true;
			end
		end	
	else
		local plantCount = 0;
		if gData.userInfo.plantInfos.plants then
			plantCount = plantCount + getMapCount(gData.userInfo.plantInfos.plants);
		end

		if gData.userInfo.manorInfo.farmInfos then
			plantCount = plantCount + getMapCount(gData.userInfo.manorInfo.farmInfos);
		end
		if plantCount > 0 then
			return true;
		end
	end

	gWindow:showTip("没有僵尸无法攻击", 2);
	return false;
end

-- 发送战斗相关请求&过场动画
function VMainView:sendBattleRequest( id, requestType, battleId,  groupMemberInfo)
	self.battleTargetId = id;
	self.ObserveTargetInfo = groupMemberInfo;
	if requestType == EBattleRequestType.Replay then
		gWindow:closeCloud(self, "sendBattleLogRequest");
	else
		if gData.offlineData:isOffline() and requestType == EBattleRequestType.Dungeon then
		-- if requestType == EBattleRequestType.Dungeon then
			gWindow:closeCloud(self, "startSingleGame");
		else
			if self:haveArmForAttack(requestType) then
				if requestType == EBattleRequestType.Observe then
					if battleId then
						self.targetBattleId = battleId;
						self.ObserveTargetInfo.targetBattleId = battleId;
					end
					gWindow:closeCloud(self, "observeOtherUserBattle");
				elseif requestType == EBattleRequestType.Attack then
					gWindow:closeCloud(self, "sendAttackUserIdRequest");
				elseif requestType == EBattleRequestType.Revenge then
					gWindow:closeCloud(self, "sendRevengeUserIdRequest");
				elseif requestType == EBattleRequestType.Dungeon then
					gWindow:closeCloud(self, "sendDungeonStartRequest");
				elseif requestType == EBattleRequestType.Group then
					self.targetBattleId = battleId;
					gWindow:closeCloud(self, "sendGroupBattleAttackRequest");
				end
			end
		end
	end
end

-- 单机关卡战斗
function VMainView:startSingleGame( )
	self:openBattleView(self.battleTargetId, EBattlePlayType.PlayAttack);
end

-- 动画关上 发送随机掠夺请求
function VMainView:observeOtherUserBattle()
	gReq:MsgReqRichOtherUserInfoQuery(self, "observeOtherUserBattleCallBack", self.battleTargetId, GameDataType.DataTypeAll);
end

-- 搜索到目标进入战斗界面 出错打开动画界面
function VMainView:observeOtherUserBattleCallBack(result, aMsgRspRichOtherUserInfoQuery, req)
	if result == 0 then
		self:openBattleView(aMsgRspRichOtherUserInfoQuery, EBattlePlayType.PlayObserve);
	else
		gWindow:openCloud();
	end
end

-- 掠夺指定id请求
function VMainView:sendAttackUserIdRequest( )
	gReq:MsgReqAttack( self.battleTargetId, BattleType.BattleTypePlunder, self, "getAttackUserIdRsponse" );
end
-- 掠夺指定id返回
function VMainView:getAttackUserIdRsponse( result, aMsgRspAttack, req )
	if result == 0 then
		self:openBattleView(aMsgRspAttack, EBattlePlayType.PlayAttack);
	else
		gWindow:openCloud();
	end
end

-- 复仇请求
function VMainView:sendRevengeUserIdRequest( )
	gReq:MsgReqAttack( self.battleTargetId, BattleType.BattleTypeRevenge, self, "getRevengeUserIdRsponse" );	
end
-- 复仇返回
function VMainView:getRevengeUserIdRsponse( result, aMsgRspAttack, req )
	if result == 0 then
		self:openBattleView(aMsgRspAttack, EBattlePlayType.PlayAttack);
	else
		gWindow:openCloud();
	end
end

-- 打关卡副本请求
function VMainView:sendDungeonStartRequest( )
	gReq:MsgReqDungeonStart(self.battleTargetId, self, "getDungeonStartRsponse");
end

-- 副本请求返回
function VMainView:getDungeonStartRsponse( result, MsgRspDungeonStart, req )
	if result == 0 then
		self:openBattleView(MsgRspDungeonStart, EBattlePlayType.PlayAttack);
	else
		gWindow:openCloud();
	end
end

-- 打团战请求
function VMainView:sendGroupBattleAttackRequest( )
	gReq:MsgReqGroupBattleAttack(self.battleTargetId, self.targetBattleId, self, "getGroupBattleAttackRsponse");
end

-- 团战开打请求返回
function VMainView:getGroupBattleAttackRsponse( result, aMsgRspGroupBattleAttack, req )
	if result == 0 then
		self:openBattleView(aMsgRspGroupBattleAttack, EBattlePlayType.PlayAttack);
	else
		gWindow:openCloud();
	end
end

-- 发送战斗日志请求
function VMainView:sendBattleLogRequest( )
	gReq:MsgReqBattleLogQuery(tostring(self.battleTargetId), self, "getBattleLogInfoQueryResponse");
end

-- 战斗回放 进入战斗界面
function VMainView:getBattleLogInfoQueryResponse( result, aMsgRspBattleLogQuery, req )
	if result == 0 then
		local data = aMsgRspBattleLogQuery.info;
		self:openBattleView(aMsgRspBattleLogQuery.info, EBattlePlayType.PlayReplay);
	end
end

-- 进入战斗界面
function VMainView:openBattleView(info, playType)
	gWindow:Replace("vBattleView.vui", function() gBattleView:enterBattleView(info, playType, self.ObserveTargetInfo); end);
	gMainView = nil;
	gAudio:playMusic("battle_start.ogg", true);

	-- if playType == EBattlePlayType.PlayObserve then
	-- 	gBattleView:getTargetAndShow(info.info, info.time);
	-- elseif playType == EBattlePlayType.PlayReplay then
	-- 	gBattleView:replayBattle(info);
	-- elseif playType == EBattlePlayType.PlayAttack then
	-- 	gBattleView:startBattle(info);
	-- end
end

-- 打开新手战斗界面
function VMainView:gotoNewbieBattleView( )
	gWindow:closeCloud(self, "openNewbieBattleView");
end

function VMainView:openNewbieBattleView( )
	local battleInfo = VBattleInfo:new();
	battleInfo:initForNewbie();
	local battleResult = VBattleResult:new();
	battleResult:initForNewbie(battleInfo.road, battleInfo.monsters, battleInfo.monsterTechs);
	
	gWindow:Replace("vBattleView.vui", function() gBattleView:replayNewbieBattle(battleInfo, battleResult); end);
	gMainView = nil;
	gAudio:playMusic("battle_start.ogg", true);
	-- gBattleView:replayNewbieBattle(battleInfo, battleResult);
end

---------------------------------------------- 战斗相关 ---------------------------------------------

function VMainView:jumpToOther(userid)
	-- self.layOperation:closeLayer();
	
	-- local messageView = self("MessageView");
	-- if messageView then
	-- 	messageView:closeMessageView();
	-- end
	gView():CloseAllMsgBox()

	self.requestUserid = userid;
	-- self.chatView:closeChatView();
	gWindow:closeCloud(self, "requestOtherUserInfo");
end

function VMainView:requestOtherUserInfo()
	gReq:MsgReqRichOtherUserInfoQuery(self, "otherUserCallBack", self.requestUserid, GameDataType.DataTypeAll);
	self.requestUserid = nil;
end

function VMainView:otherUserCallBack(result, aMsgRspRichOtherUserInfo, req)
	if result == 0 then
		local userInfo = VOtherUserInfo:new();
		userInfo:synWithPbData(aMsgRspRichOtherUserInfo);
		self:otherUserJump(userInfo)
	end
end

function VMainView:otherUserJump(userInfo)
	self:loadUserInfo(userInfo);
	self:ResetMonsterAmt();
	gWindow:openCloud()
end

function VMainView:backToSelfMainView()
	self:loadUserInfo(gData.userInfo);
	self:ResetMonsterAmt();
	self:openUserFunction();
	gWindow:openCloud()
end

function VMainView:addFriendClick()
	self:addToMyFriend(self.userInfo.userid);
end

function VMainView:openShop()
	self:Push("vShopDlg.vui");	
end

function VMainView:BacktoSelfFarm(  )
	self:manorViewTouched(_VTouchType.Block);
	gWindow:closeCloud(self, "backToSelfMainView");
end

function VMainView:openSpecial(node)
	if not self.activityDlg then
		self.activityDlg = VNode("vActivityDlg.vui");
		self.activityDlg.activityTips = self.activityTips;
		self("LeftOpLayer"):Push(self.activityDlg);
	else
		if self.activityDlg:isVisible() then
			self.activityDlg:hideDlg();
		else
			self.activityDlg.activityTips = self.activityTips;
			self.activityDlg:showDlg();
		end
	end
end

function VMainView:openSysMenu()	
	local systemSetDlg = VNode("vSystemSetDlg.vui");
   systemSetDlg:SetRoleInfo(gData.userInfo.roleInfo);
   gView():Push(systemSetDlg);
end


function VMainView:openUpateApkFile()
	if not self.isUpdateApk then
		gWindow:showConfirmTip("有新的客户端可以更新", "确定", "取消", self, "getUpdateFile", "")	
	elseif self.isUpdateApk == 2 then
		gWindow:showConfirmTip("新客户端下载完成，点击确定安装", "确定", "取消", self, "installNewClient", "")
	end
end

function VMainView:installNewClient()
	local path = gRes:FilePath(gUpdate.apkFileName, _VPath.Public);
	gSys:installPack(path);
	gUpdate.apkFileName = nil;
	gDtr:endToLua();
end

function VMainView:getUpdateFile()
	self.isUpdateApk = 1;
	if gRes:Platform() == "ios" then

	else
		local url = gResUrl..gUpdate.apkFileName;
		downLoadFile(url, gUpdate.apkFileName, "gMainView:apkDownloadFinish(gLua:Param())", "gMainView:apkDownloadProgress(gLua:Param())", 1);
	end
end

function VMainView:apkDownloadFinish(msg)
	local ret = msg:Number("ret");
	if ret == 0 then
		self.isUpdateApk = 2;
		self.texUpdateApk.text = "完成";
		cclog('apk download finish');
	else
		self.isUpdateApk = nil;
		self.texUpdateApk.text = "";
		cclog('apk download error');
	end
end

function VMainView:apkDownloadProgress(msg)
	local progress = msg:Number("progress")

	self.texUpdateApk.text = gFormat("%d%%", progress);
end


function VMainView:openChatDlg(userid)
	local messageView = self("PrivatChatDlg");
	if not messageView then
		messageView = self:Push("vPrivatChatDlg.vui");
	end
	messageView:loadByUserid(userid);
	self:checkUnReadMessage();
end

function VMainView:newMessageComeIn()
    cclog("newMessageComeIn")
    
    local messageView = self("privatChatDlg");

    local societyDlg = gView()("societyDlg");
    if societyDlg and societyDlg.visible then
    	if gData.chatInfo.listNew then
    		gData.chatInfo.listNew = false
    		societyDlg:UpDataSocietyList()
    	else
        	societyDlg:UpDataMessage()
    	end
    end

    local friendManageDlg = gView()("friendManageDlg");
    if friendManageDlg and friendManageDlg.visible then
        friendManageDlg:UpDataMessage()
    end
    
    if not messageView then
        self:checkUnReadMessage();
    end

--	local messageView = self("MessageView");
	if messageView then
		messageView:checkNewMessage();
	end
end

function VMainView:manorViewTouched(touchType)
	if touchType == _VTouchType.Block or
		touchType == _VTouchType.Field or
		touchType == _VTouchType.PlantReceive then
		self.layOperation:closeLayer();
	end
	if self.activityDlg then
		self.activityDlg:hideDlg();
	end
end

--function VMainView:plantSelected(farmInfo)
--	if self.layOperation:setFarmInfo(farmInfo, self.userInfo.isSelf) then
--		self.layOperation:showLayer();
--	else
--		self.layOperation:closeLayer();
--	end
--end

function VMainView:CheckNewBagItem(parameters)
    local hasNew = false
    local newCount = 0
    
    if gData.userInfo.bagInfos.newCount and gData.userInfo.bagInfos.newCount > 0 then
        cclog("bagInfosset")
        newCount = gData.userInfo.bagInfos.newCount
	    hasNew = true
	end
    -- if gData.userInfo.suitInfo.newCount and gData.userInfo.suitInfo.newCount > 0 then
    --     cclog("suitInfoset")
    --     newCount = gData.userInfo.suitInfo.newCount
    --     hasNew = true
    -- end
    if gData.userInfo.plantInfos.newCount and gData.userInfo.plantInfos.newCount > 0 then
        cclog("plantInfosset")
        newCount = gData.userInfo.plantInfos.newCount
        hasNew = true
    end
    
    -- if not self.btnBag.tipLayer then
    --     self.btnBag.tipLayer = VImage{image="zhujiemiantishipaopao.png", offset={7,-10}, layout="UpRight"};
    --     local txCount = VText{name="txCount", text = newCount, layout="Center", fontSize = 15};
    --     self.btnBag.tipLayer:Push(txCount);
    --     self.btnBag:Push(self.btnBag.tipLayer);
    -- end
    
    -- self.btnBag.tipLayer("txCount").text = newCount
    -- self.btnBag.tipLayer.visible = hasNew
end

function VMainView:ClearUpNewBagItem(parameters)
	gData.userInfo.bagInfos.newCount = 0
    gData.userInfo.plantInfos.newCount = 0
    gData.userInfo.bagInfos.newCountItem = {}
    gData.userInfo.plantInfos.newPlantCount = {}
end


-----------------------------------------
--title: 传入主题table
--title内容如下:
--title.text:传入主题的文字
--title.color:传入主题的颜色
--id:传入操作对象的id
--type:传入操作对象的type
--buttons: 传入按钮信息的列表,个数不限
--buttons列表格式为 button[1]   button[2] ......
--元素属性如下
--button[1].callBack  回调函数
--button[1].delegate  回调函数的类
--button[1].extend  回调函数的参数
--button[1].icon  图片
--button[1].descText  按钮描述文字
--button[1].cost 消耗资源的文字
--button[1].limitText  按钮被限制时描述文字
-----------------------------------------


function VMainView:ShowOperationLay(buttons, title, tab, Otype)
  if self.layOperation:CheckOperationLay(buttons, title, tab, Otype) then
      self.layOperation:showLayer();
  else
      self.layOperation:closeLayer();
  end
end


function VMainView:vipTitleOnClick()
	if self.userInfo.isSelf then
		local p = VNode("vPaymentDlg.vui");
		self:Push(p);
	end
end

--加钻石按钮点击响应
function VMainView:onCurrenyAddBtnClick()
	if gCanPay ~= nil and gCanPay == false then
		return;
	end
	self:Push("vPaymentDlg.vui");
end

--添加工人
function VMainView:onFarmerAddBtnClick()
	local bf = VNode("vBuyFarmerDlg.vui");
	self:Push(bf);
end

--点击抽卡按钮
function VMainView:onCardBtnClick( )
	local csv = gData:readCsv("dungeon_function_control.csv");
	local lineData = csv:lineDataWithKey(2);
	local openid = lineData[1];
	local tip = lineData[2];
	if gData.userInfo.dungeonInfo:GetLevelRecord(openid) > 0 then
		self:Push("vCardlotteryDlg.vui");
	else
		gWindow:showTip(tip, 2);
	end
end


--功能开关：开放/屏蔽游戏功能
function VMainView:openUserFunction()
	if not self.userInfo.isSelf then return; end
	--活动
	-- if  self.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_event) then
	-- 	self.btnSpecial.visible = 1;
	-- else
	-- 	self.btnSpecial.visible = 0;
	-- end

	--掠夺
	if self.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_rob) then
		self.btnBattle.visible = 1;
	else
		self.btnBattle.visible = 0;
	end

	--聊天
	if self.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_chat) and (not gData.offlineData.offline) 
		and gData.offlineData:isEnterFarmBtnVisible() then
		self.imgChatView.visible = 1;
	else
		self.imgChatView.visible = 0;
	end


	-- --背包
	-- if self.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_bag) then
	-- 	self.btnBag.visible = 1;
	-- else
	-- 	self.btnBag.visible = 0;
	-- end

	--商店
	if self.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_shop) then
		self.btnStore.visible = 1;
	else
		self.btnStore.visible = 0;
	end

	--工人购买
	if self.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_add_farmer) then
		local cost = self.userInfo.manorInfo:farmerNextCost();
		if cost then
			self("btnFarmerAdd").visible = 1;
		else
			self("btnFarmerAdd").visible = 0;
		end
	else
		self("btnFarmerAdd").visible = 0;
	end



	--充值加号
	if self.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_rechargeAdd) then
		self("btnCurrenyAdd").visible = 1;
	else
		self("btnCurrenyAdd").visible = 0;
	end

	-- --设置
	-- if self.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_setting) then
	-- 	self.btnSysMenu.visible = 1;
	-- else
	-- 	self.btnSysMenu.visible = 0;
	-- end
end


--金币增加动画
function VMainView:updateGoldNumAnimation( runTimes, pTime, pDif)
    if runTimes == 1 then
        local numText = gData:fmtMicrometer(self.texGoldValue.finalNum);
        self.texGoldValue:setString(numText);
    else
    	self.texGoldValue.curValue = self.texGoldValue.curValue + pDif;
    	local numText = gData:fmtMicrometer(math.modf(self.texGoldValue.curValue));
        self.texGoldValue:setString(numText);
    end

    runTimes = runTimes - 1;
    if runTimes > 0 then
        self.texGoldValue:RunAction{{"delayTime", pTime}, {self,"updateGoldNumAnimation", runTimes, pTime, pDif}};
    else
    	self.texGoldValue.curValue = self.texGoldValue.finalNum;
    end
    -- self:NeedReLayout();
end

function VMainView:showAddCoinAcion(curValue, targetValue)
	local runTimes = 20;
    local actionTime = 1;
    local addValue = targetValue - curValue;
    if math.abs(addValue) < runTimes then
        runTimes = math.abs(addValue);
    end

    local pTime = actionTime / runTimes;
    local pDif = math.floor(addValue / runTimes);

    if runTimes > 1 then
        runTimes = runTimes - 1;
    end
    self.texGoldValue.finalNum = targetValue;
    self:updateGoldNumAnimation(runTimes, pTime, pDif);
end

--阳光增加动画
function VMainView:showAddSunAcion(curValue, targetValue)
	local runTimes = 20;
    local actionTime = 1;
    local addValue = targetValue - curValue;
    if math.abs(addValue) < runTimes then
        runTimes = math.abs(addValue);
    end

    local pTime = actionTime / runTimes;
    local pDif = math.floor(addValue / runTimes);

    if runTimes > 1 then
        runTimes = runTimes - 1;
    end
    self.texSunValue.finalNum = targetValue;
    self:updateSunNumAnimation(runTimes, pTime, pDif);
end

function VMainView:updateSunNumAnimation( runTimes, pTime, pDif)
    if runTimes == 1 then
        local numText = gData:fmtMicrometer(self.texSunValue.finalNum);
        self.texSunValue:setString(numText);
    else
    	self.texSunValue.curValue = self.texSunValue.curValue + pDif;
    	local numText = gData:fmtMicrometer(math.modf(self.texSunValue.curValue));
        self.texSunValue:setString(numText);
    end

    runTimes = runTimes - 1;
    if runTimes > 0 then
        self.texSunValue:RunAction{{"delayTime", pTime}, {self,"updateSunNumAnimation", runTimes, pTime, pDif}};
    else
    	self.texSunValue.curValue = self.texSunValue.finalNum;
    end
end
-----------------------------主界面通知 begin--------------------------------
function VMainView:refreshNoticeInfos()
	--设置签到
	local checkIn = gData.noticeManager.checkIn;
	if checkIn.count > 0 then
		self.qiandao("imageCntBg").visible = 1;
		self.qiandao("textCnt").text = checkIn.count;
	else
		self.qiandao("imageCntBg").visible = 0;
	end
	--设置活动
		local csv = gData:readCsv("user_common.csv");
    	local lineData = csv:lineData(0);
   		if lineData and lineData.eventOpen == 1 then 
   			self.huodong.visible = 1;
        	local startCnt, rewardCnt = gData.userInfo.eventEntryInfos:getNoticeCnt();
			if rewardCnt > 0 then
				self.huodong("imageCntBg").visible = 1;
				self.huodong("textCnt").text = rewardCnt;
			else
				self.huodong("imageCntBg").visible = 0;
			end
		else
			self.huodong.visible = 0;
  		end
		
	--设置通知
	local datas = gData.noticeManager.noticeInfos;
	local datasCount = #datas;
	for i=1, 10 do
		local cell = self("btnEvent"..i);
		if i <= datasCount then
			cell.visible = 1;
			cell.image = datas[i]:getImage();
			cell.onClick = "gView():onDoEvent("..datas[i].dType..")"
			if datas[i].count > 0 then
				cell("imageCntBg").visible = 1;
				cell("textCnt").text = datas[i].count;
			else
				cell("imageCntBg").visible = 0;
			end
			
		else
			cell.visible = 0;
		end
	end
end

function VMainView:openCheckIn()
	self:Push("vSigninDlg.vui");
end

function VMainView:onDoEvent(dType)
	if dType == NoticeType.quest then
		self:Push("vQuestDlg.vui");
	elseif dType == NoticeType.finish_monster_star then
		self:Push("vLaboratoryDlg.vui");
	elseif dType == NoticeType.free_draw_card then
		local csv = gData:readCsv("dungeon_function_control.csv");
		local lineData = csv:lineDataWithKey(2);
		local openid = lineData[1];
		local tip = lineData[2];
		if gData.userInfo.dungeonInfo:GetLevelRecord(openid) > 0 then
			self:Push("vCardlotteryDlg.vui");
		else
			gWindow:showTip(tip, 2);
		end
	elseif dType == NoticeType.achievement_finish then
		self:Push("vAttainmentDlg.vui")
	elseif dType == NoticeType.battle_end or dType == NoticeType.battle_begin then
		local node = VNode("vPVPOptionDlg.vui");
		self:Push(node);
		node:onOptionBtnClick(node._layerIndex.battlefield);
	elseif dType == NoticeType.shop_refresh then
		self:Push("vShopDlg.vui");
	end
end

-----------------------------主界面通知  end--------------------------------

------------------------------活动 begin------------------------------------

function VMainView:openEventEntry()
	if self.userInfo.isSelf then
		gWindow:showWaitTip("loading...");
		gReq:MsgReqActivityInfoQuery(self, "activityInfoQueryRespone");
	end
end

function VMainView:activityInfoQueryRespone(result)
	gWindow:closeWaitTip();
	if result == 0 then
		local p = VNode("vEventEntryDlg.vui");
		self:Push(p);
	end
end
------------------------------活动 end--------------------------------------

--战斗结束之后，打开团战界面
function VMainView:openGroupBattleDlg( groupBattleInfo, isWin )
	self:Push("vPVPOptionDlg.vui");
	local info = VRichGroupBattleInfo:new();
	info:synWithPbData(groupBattleInfo);
	ShowGroupBattleDlgByGroupBattleInfo(info);

	if not isWin then
		local vipInfo = self.userInfo.roleInfo.vipInfo;
		if vipInfo[0] < 1 then
			gWindow:showBattleFaildTip(2);
		elseif vipInfo[0] < 3 then
			gWindow:showBattleFaildTip(3);
		elseif vipInfo[0] < 5 then
			gWindow:showBattleFaildTip(4);
		else
			gWindow:showFinalBattleFaildTip();
		end
	end
	-- 关闭过渡窗口
	gWindow:openCloud();
end

function VMainView:openChatView()
    local plantlotteryDlg = VNode("vSocietyDlg.vui");
    gView():Push(plantlotteryDlg);
end

function VMainView:checkUnReadMessage()
    local unread = gData.chatInfo:unReadCount();
    if unread ~= 0 then
        self.imgRedTip.visible = 1;
        self.txtUnreadTip.text = unread;
    else
        self.imgRedTip.visible = 0;
    end
end

function VMainView:showLeftBtn( isShow )
	self.pveBtn.visible = isShow;
	self.btnBattle.visible = isShow;
	self.cardBtn.visible = isShow;
end

function VMainView:openVipDlg(  )
	local node = self:Push("vPaymentDlg.vui");
	node:showVipLayer();
end

function VMainView:ResetMonsterAmt( )
    if gForceOffline then
       return;
    end
	for i,v in ipairs(self.amt) do 
		v:doPop();
	end
	self.amt = {};
	if not next(self.userInfo.monsterInfo.monsterInfos) then
		return;
	end
	local amts = {};
	for i,mi in pairs(self.userInfo.monsterInfo.monsterInfos) do
		table.insert(amts, mi);
	end
	local count = math.min(5, #amts);
	local idx = 0;
	while idx < count do
		local index = math.random(1,#amts);
		if type(amts[index]) == "table" then
			local image = amts[index].image;
			local pos = self.map:getRandPos();
			local p = self.map:getRealPos(pos);
			local scale,speed = self:getMonsterAmtScaleAndSpeed(image);
			local amt = VHomingRoadAmt{jsonName=image, animation="walk", scale=scale/100, layout="Downleft"};
			
			local monsterSpeed = speed*80/1000;
			local playMoveSpeed = speed/speed;
			amt:setSpeedScale(playMoveSpeed);

			self.manorView:Push(amt);
			amt:setPosition(p);
			
			amt:setSpeedAndScale(monsterSpeed, scale/100);
			amt:Run(self.map,pos);
			amts[index] = 0;
			idx = idx + 1;
			table.insert(self.amt, amt);
		end
	end
end

function VMainView:getMonsterAmtScaleAndSpeed( amt )
	local csv = gData:readCsv("animation_creature.csv");
	local lineData = csv:lineDataWithKey(amt);
	if lineData then
		return lineData[2],lineData[3];
	end
end

function VMainView:showGoldCameFrom( )
	self("shabixuqiu").visible = 1;
	self("shabixuqiu1").visible = 1;
end

function VMainView:showYinCameFrom( )
	self("shabixuqiu").visible = 1;
	self("shabixuqiu2").visible = 1;
end

function VMainView:showZuanCameFrom( )
	self("shabixuqiu").visible = 1;
	self("shabixuqiu3").visible = 1;
end

function VMainView:shabixuqiuyincang( )
	self("shabixuqiu").visible = 0;
	self("shabixuqiu1").visible = 0;
	self("shabixuqiu2").visible = 0;
	self("shabixuqiu3").visible = 0;
end

function VMainView:openTargetBattleId( battleId )
	ShowGroupBattleDlgByAssistId(battleId);
	-- 关闭过渡窗口
	gWindow:openCloud();
end