--vwindow.lua

require "vshowtip"
require "vconfirmtip"
require "vwaittip"
require "vreturntip"
require "vMoneyLackDlg"
require "vCostLackDlg"
require "vNormalTip"
require "vRewardTip"
require "vUpperLimitTip"
require "vBattleFaildTip.lua"

VWindow = VClass("Window", VNode)

function VWindow:onCreate(attr)
    local scene = cc.Scene:createWithPhysics()
    if gDtr:getRunningScene() then
        gDtr:replaceScene(scene)
    else
        gDtr:runWithScene(scene)
    end
    return scene;
end
function VWindow:Init( attr )
	VNode.Init(self, attr);
	self:InitKeyListener();
	self.needAction = true;
end
function VWindow:onKeyBack()
	local view = self:view(-1);
	if view then
		if view:onKeyBack() then
			return;
		end
		self:Pop()
	end
end
function VWindow:onKeyMenu()
end

function VWindow:jumpToLoginView()
	self:Replace("vloginView.vui");
	gMainView = nil;
end

function VWindow:Replace(view, func)
	self:Push(view, function(...)
		self:view(-2):Delete();
		if func then func(...) end
	end)
end
function VWindow:onBackground()
	if gMainView or gBattleView then
		gData.offlineData:saveOfflineData();
	end
	gLog("onBackground");
end

function VWindow:onForeground()
	gLog("onForeground");
	if gMainView then
		gMainView:onForeground()
	end
end

function VWindow:Pop(cnt, func)
	if self:viewCount() > 0 then
		self:view(-1):doPop(func);
	end
end

function VWindow:viewCount()
	local n = 0;
	local childrenCount = self:Count();
	for i=0,childrenCount-1 do
		local child = self(i);
		if child.isView then
			n = n + 1;
		end
	end
	return n;
end

function VWindow:view(n)
	if not n then n = -1 end;
	local childrenCount = self:Count();
	local k = 0;

	for i=childrenCount-1,0,-1 do
		local child = self(i);
		if child.isView then
			k = k -1;
			if n == k then
				return child;
			end
		end
	end
	return nil;
end

function VWindow:startTimeOut(timeOut)
	self:StartTimer("requestTimeOut", 0, 0, timeOut);
end

function VWindow:requestTimeOut()
	self:RunAction{{"delayTime", 0.1}, {"@VUiOnSocketTimeOut"}};
end

function VWindow:stopTimeOut()
	self:StopTimer("requestTimeOut");
end

function VWindow:showTip(msg, delay)
	local tip = VNode("vshowtip.vui")
	tip:setDelay(delay);
	tip("texShowTip").text = msg;
	gView():Push(tip);

    gAudio:playEffect("sys_warning.ogg");
end

function VWindow:showConfirmTip(msg, okTip, cancelTip, delegate, okCallBack, cancelCallBack, title, ...)
	if not msg then return end;
	local tip = VNode("vconfirmtip.vui")
	tip:setMsg(msg, okTip, cancelTip, title);
	tip:setDelegateCallBack(delegate, okCallBack, cancelCallBack)
	tip:setExtandParam(...);
	gView():Push(tip);
end

function VWindow:closeConfirmtip()
	local tip = self("confirmtip");
	if tip then tip:doPop() end;
end

function VWindow:showWaitTip(msg, timeOut, delegate, timeOutCallBack)
	self:closeWaitTip();
	local tip = VNode("vwaittip.vui")
	tip:setMsg(msg);
	tip.timeOut = timeOut;
	tip:setDelegateCallBack(delegate, timeOutCallBack);
	gView():Push(tip);
end

function VWindow:closeWaitTip()
	local tip = self("waittip");
	if tip then tip:closeTip() end;
end

function VWindow:showReturnTip(returnInfo)
	local tip = VNode("vreturntip.vui")
	tip:setReturnInfo(returnInfo);
	gView():Push(tip);
end

function VWindow:checkNeedShowReturn(returnInfo)
	if returnInfo.rtis and returnInfo.rtis:Count() > 0 then
		local needShow = false;
		local newIter = VDataIter();
		while returnInfo.rtis:Travel(newIter) do
	    	local thingInfo = newIter:Data();
	    	if thingInfo.type == ThingType.ThingTypeItem and 
	    		thingInfo.count > 0 then
	    		needShow = true;
	    	end
	    end
	    if needShow then
	    	self:showReturnTip(returnInfo);
	    end
	end
end

function VWindow:openCloud( node, func )
	if not self.transformLayer then
		self.transformLayer = VTransformLayer{layout="Center", visible=0};
		self:Push(self.transformLayer);
	end
	if self.transformLayer:isVisible() then
		self.transformLayer:openCloud( node, func );
	end
end

function VWindow:closeCloud( node, func )
	if not self.transformLayer then
		self.transformLayer = VTransformLayer{layout="Center", visible=0};
		self:Push(self.transformLayer);
	end
	if not self.transformLayer:isVisible() then
		self.transformLayer:closeCloud( node, func );
	end
end


--提示资源不足对话框
--[[
	costInfo为不足资源的数组，最多只取前2项
	delegate 	委托类
	callBack 	回调方法
	...			参数
	数组项[1],[2]包含以下字段
	costInfo[1].thingid 物品id
	costInfo[1].type  	物品type
	costInfo[1].count 	物品数量
]]
function VWindow:showCostLackDlg(costInfo, delegate, callBack, ...)
	local cl = VNode("vCostLackDlg.vui");
	cl.costInfo = costInfo;
	cl.delegate = delegate;
	cl.callBack = callBack;
	cl.params = {...};
	gView():Push(cl);
end

--提示元宝不足对话框
function VWindow:showMoneyLackDlg(money)
	local ml = VNode("vMoneyLackDlg.vui");
	local vcoin = math.ceil((money - gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency))/10);
	ml.tip = "您的钻石不足"..money..",请充值获得钻石！您还需要充值"..vcoin.."元。";
	ml.title = "钻石不足";
	ml("okTip").text = "去充值";
	ml.delegate = gView();
	ml.callBack = "Push";
	ml.params = {"vPaymentDlg.vui"};
	gView():Push(ml);
end

--显示工人不足提示
function VWindow:showFarmerLackTip()
	local tip = "工人不足，是否购买一个工人！";
	local title = "工人不足";
	local delegate = gView();
	local callBack = "Push";
	local params = "vBuyFarmerDlg.vui";
	local okTip = "购买";
	local cancelTip = "取消";
	self:showConfirmTip(tip, okTip, cancelTip, delegate, callBack, "f1111", title, params);
end

--获得物品通用提示
function VWindow:showReWardTip( ri, title, desc, delegate, callBack)
	local returnInfo = VReturnInfo:new();
	returnInfo:synWithPbData(ri);
	local items = returnInfo:GetReWardItems();
	if next(items) then
		local rewardTip = VNode("vRewardTip.vui");
		rewardTip:setItemInfo(items, title, desc, delegate, callBack);
		gView():Push(rewardTip);
	else
		self:showNormalTip("很抱歉，您什么都没有获得！")
	end
end

--资源超出上限提示
function VWindow:showUpperlimitTip( limitInfo, delegate, callBack, ... )
	local node = VNode("vUpperLimitTip.vui");
	node:setLimitInfo(limitInfo, delegate, callBack, {...});
	gView():Push(node);
end

function VWindow:closeAttackInfoDlg()
	local tip = self("attackInfo");
	if tip then tip:onClick() end;
end

--消耗元宝通用提示
function VWindow:showPayTip(title, msg, money, delegate, callBack, ...)
	return VCallBack(delegate, callBack, ...);
	-- local pt = VNode("vCommonMsgBox_D.vui");
	-- local bgImg = pt("bgImg");
	-- bgImg.touch = 1;
	-- if title then
	-- 	local titleText = VText{text=title, fontSize=25, color={90,40,0},
	-- 	 layout="Up", offset={0,45}};
	-- 	bgImg:Push(titleText);
	-- end
	-- if msg then
	-- 	local tipText = VText{text=msg, fontSize=22, color={90,40,0},
	-- 	 layout="Up", size={360,100}, alignV="Up", offset={0,100}};
	-- 	bgImg:Push(tipText);
	-- end
	-- local cancelBtn = VButton{image="tankuanganniu3.png", layout="LeftDown", text="取消",
	--  		textColor={255,255,255}, offset={90,-45}, onClick="node:Parent(2):doPop()"};
	-- local sureBtn = VButton{name="sureBtn",image="tankuanganniu3.png", layout="RightDown",offset={-90,-45}};
	-- local okTip = VRichText{layout="Center", offset={0,-3}, scale=0.8};
	-- okTip:InsertElementImage(1,cc.c3b(255,255,255),255,"zuanshi.png");
	-- okTip:InsertElementText(1,cc.c3b(255,255,255),255,(" "..money), nil, 35);

	-- sureBtn:Push(okTip);
	-- sureBtn.params = {...};
	-- sureBtn.delegate = delegate;
	-- sureBtn.callBack = callBack;
	-- sureBtn.onClick = 
	-- 	function(node, touch, view)
	-- 		VCallBack(node.delegate, node.callBack, unpack(node.params));
	-- 		node:Parent(2):doPop();
	-- 	end 
	-- bgImg:Push(cancelBtn);
	-- bgImg:Push(sureBtn);

	-- gView():Push(pt);
end

--消耗元宝通用提示
function VWindow:showPayTip2(title, msg, money, delegate, callBack, ...)
	local pt = VNode("vCommonMsgBox_D.vui");
	local bgImg = pt("bgImg");
	bgImg.touch = 1;
	if title then
		local titleText = VText{text=title, fontSize=22, color={90,40,0},
		 layout="Up", offset={0,35}};
		bgImg:Push(titleText);
	end
	if msg then
		local tipText = VText{text=msg, fontSize=18, color={90,40,0},
		 layout="Up", size={320,100}, alignV="Up", offset={0,85}};
		bgImg:Push(tipText);
	end
	local cancelBtn = VButton{image="tankuanganniu3.png", layout="LeftDown", text="取消",
	 		textColor={255,255,255}, offset={70,-30}, onClick="node:Parent(2):doPop()"};
	local sureBtn = VButton{name="sureBtn",image="tankuanganniu3.png", layout="RightDown",offset={-70,-30}};
	local okTip = VRichText{layout="Center", offset={0,-3}, scale=0.8};
	okTip:InsertElementImage(1,cc.c3b(255,255,255),255,"icon_zuanshi.png");
	okTip:InsertElementText(1,cc.c3b(255,255,255),255,(" "..money), nil, 35);

	sureBtn:Push(okTip);
	sureBtn.params = {...};
	sureBtn.delegate = delegate;
	sureBtn.callBack = callBack;
	sureBtn.onClick = 
		function(node, touch, view)
			VCallBack(node.delegate, node.callBack, unpack(node.params));
			node:Parent(2):doPop();
		end 
	bgImg:Push(cancelBtn);
	bgImg:Push(sureBtn);

	gView():Push(pt);
end

function VWindow:showNormalTip( context, title )
	local nt = VNode("vCommonMsgBox_D.vui");
	if context then
		local tipText = VText{text=context, fontSize=18, color={90,40,0},
		 layout="Up", size={360,100}, alignV="Up", offset={0,80}};
		nt("bgImg"):Push(tipText);
	end
	if title then
		local titleText = VText{text=title, fontSize=22, color={90,40,0},
		 layout="Up", offset={0,35}};
		nt("bgImg"):Push(titleText);
	end
	local btmTip = VText{text="点击任意位置关闭", fontSize=15, layout="Down", offset={0,-30},
					 color={147,113,67}}
	nt("bgImg"):Push(btmTip);
	gView():Push(nt);
end


-- 显示成就动画
function VWindow:achievementAnimation(squ)
	local delayTime = 0;
	for i,v in ipairs(squ) do
		delayTime = delayTime + (i-1)*5;
		self:RunAction({{"delayTime",delayTime},{"@showAchievementAnimation", v.image, v.name}}, i);
	end
end

-- 显示成就动画
function VWindow:showAchievementAnimation( imageName, textName )
	local achieveLayer = VLayer{layout="Down", size={300,120}, fill={-1,-1}, level=300};
	local achieveBg = VImage{name="achieveBg", image="chengjiuban.png", layout="Up"};
	local achieveIcon = achieveBg:Push(VImage{name="achieveIcon", image=imageName, layout="Left", fit={0,-0.5}, offset={12,13}});
	local achieveText = achieveBg:Push(VText{text=textName, relative="achieveIcon", layout="RightOut", offset={12,0}, fontSize=16, outline=2, effectColor={0,0,0}});
	achieveLayer:Push(achieveBg);

	-- local achieveWhiteBg = achieveLayer:Push(VImage{image="chengjiuban2.png", layout="Up", visible=0});
	-- local achieveLeftLight = VImage{image="chengjiuguang.png", relative="achieveBg", layout="UpRight", offset={-12,14}};
	-- achieveLeftLight:setAnchorPoint(cc.p(0,0.5));
	-- achieveLeftLight:setScaleX(-1);
	-- achieveLayer:Push(achieveLeftLight);
	-- achieveLeftLight:ReLayout();
	local achieveRightLight = VImage{image="chengjiuguang.png", relative="achieveBg", layout="DownLeft", offset={0,4}};
	achieveRightLight:setAnchorPoint(cc.p(0,0.5));
	achieveLayer:Push(achieveRightLight);
	achieveRightLight:ReLayout();
	gView():Push(achieveLayer);

	local windowWidth = self:getContentSize().width;
	-- local upPos = achieveLayer:convertToNodeSpace(cc.p(-10, achieveLeftLight:getPositionY()));
	local downPos = achieveLayer:convertToNodeSpace(cc.p(windowWidth+10, achieveRightLight:getPositionY()));
	-- achieveLeftLight:RunAction{{"hide"}, {"moveTo", 0, upPos.x, upPos.y}, {"show"}, {"moveTo", 0.5, achieveLeftLight:getPositionX(), achieveLeftLight:getPositionY()}, {"delayTime", 0.2}, {"fadeTo", 0.2, 0}};
	achieveRightLight:RunAction{{"hide"}, {"moveTo", 0, downPos.x, downPos.y}, {"show"}, {"moveTo", 0.5, achieveRightLight:getPositionX(), achieveRightLight:getPositionY()}, {"delayTime", 0.2}, {"fadeTo", 0.2, 0}};
	-- achieveWhiteBg:RunAction{{"fadeTo", 0, 0}, {"show"}, {"delayTime", 0.5}, {"fadeTo", 0.2, 255}, {"delayTime", 0.4}, {"fadeTo", 0.5, 0}};
	achieveBg:RunAction{{"hide"}, {"delayTime", 0.5}, {"show"}, {"delayTime", 2}, {"fadeTo", 1, 0}};
	achieveIcon:RunAction{{"delayTime", 3}, {"fadeTo", 1, 0}};
	achieveText:RunAction{{"delayTime", 3}, {"fadeTo", 1, 0}};

	for i=1,8 do
		local achieveIcon = achieveBg:Push(VImage{image="chengjiuxing.png", visible=0});
		local randomX = math.random(10, 260);
		local randomY = math.random(10, 80);
		local randomScale = 1+ math.random(1, 50) * 0.01;
		achieveIcon:RunAction{{"scaleTo", 0, randomScale}, {"moveTo", 0, randomX, randomY}, {"fadeTo", 0, 0}, {"delayTime", 1.2 + i*0.15}, {"show"}, {"fadeTo", 0.3, 255}, {"fadeTo", 0.3, 0}, {"delete"}};
	end

	achieveLayer:RunAction{{"delayTime", 4.5}, {"delete"}};
end

function VWindow:showLoadingAnimation( )
	if not self.loadingLayer then
		self.loadingLayer = VLayer{layout="Center", size={800,480}, fit="Full", level=500, color={0,0,0,120}, touch=1, visible=0};
		self.flowerLoadingArmature = VArmature:createArmature("flowerLoadingArmature", "", "Center");
		self.flowerLoadingArmature.scale = 0.7;
		self.loadingLayer:Push(self.flowerLoadingArmature);
		self:Push(self.loadingLayer);
	end

	self.loadingLayer.visible = 1;
	self.flowerLoadingArmature:play("loading");
end

function VWindow:closeLoadingAnimation()
	if self.loadingLayer then
		self.loadingLayer.visible = 0;
	end
	if self.flowerLoadingArmature then
		self.flowerLoadingArmature:stop();
	end
end

--战败VIP提示
--[[
	tipid:1,关卡 2，vip1 3,vip3 4,vip5
	info:tipid为1时传
	purchase:tipid为1时传
]]
function VWindow:showBattleFaildTip( tipid, info, purchase)
	local node = VNode("vBattleFaildTip.vui");
	node.tipid = tipid;
	node.info = info
	node.purchase = purchase
	gView():Push(node);
end

--战败提示高级
function VWindow:showFinalBattleFaildTip(  )
	local tip = VMsgBox{name="finalBattleFaildTip"};
	local layer = VImage{name="bgLayer", image="tankuang6.png", layout="Center"};
	layer.touch = 1;
	local cancelBtn = VButton{name="cancelBtn", image="tankuanganniu2.png", text="关闭", layout="Down"};
	cancelBtn.offset = {0,-20};
	cancelBtn.onClick = "node:Parent(2):doPop()";

	local title = VImage{name="titleImg", image="ftbiaoti.png", layout="Up", offset={0,-15}};
	layer:Push(title);

	local chouka = VButton{name="chouka", image="ftchouka.png"};
	chouka.layout = "Center";
	chouka.offset = {-80,-40};
	chouka.onClick = "view:Push('vCardlotteryDlg.vui');node:Parent(2):doPop();";
	layer:Push(chouka);

	local laboratory = VButton{name="laboratory", image="ftshengxing.png"};
	laboratory.layout = "Center";
	laboratory.offset = {80,-40};
	laboratory.onClick = "view:Push('vLaboratoryDlg.vui');node:Parent(2):doPop();";
	layer:Push(laboratory);

	local shop = VButton{name="shop", image="ftshangdian.png"};
	shop.layout = "Center";
	shop.offset = {-80,20};
	shop.onClick = "view:Push('vShopDlg.vui');node:Parent(2):doPop();";
	layer:Push(shop);

	local banner = VButton{name="banner", image="ftzhanqi.png"};
	banner.layout = "Center";
	banner.offset = {80,20};
	banner.onClick = "view:Push('vBannerInfoDlg.vui');node:Parent(2):doPop();";
	layer:Push(banner);

	layer:Push(cancelBtn);
	layer:Push(rechargeBtn);
	tip:Push(layer);
	
	gView():Push(tip);
end