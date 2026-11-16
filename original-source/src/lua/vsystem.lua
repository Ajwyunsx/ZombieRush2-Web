--vsystem.lua
if gPackage == 1006 and gAndriodClass_normal == nil then
	gAndriodClass = "com/vikings/zombiefarm/uucun/AppActivity"
else
	gAndriodClass = "com/vikings/zombiefarm/AppActivity"
end

VSystem = vclass("system")

function VsystemHeadImageCallBack(path)
	VCallBack(gSys.delegate, gSys.callBack, path);
	gSys.delegate = nil;
	gSys.callBack = nil;
end

--java调用lua的callback
function VsystemLuaCallBack(nodeNameString)
	if nodeNameString and string.len(nodeNameString) > 0 then
		local node = gView()(nodeNameString);
		if node and node.javacall then
			node:javacall();
		end
	end
end

function VsystemLuaCallBackCharge(desc)
	local node = gView()("VRechargeCenterDlg");
	if node and node.javacall then
		node:javacall(desc);
	end
end

function VSystem:callJavaFunc(func, args, sig)
	if gRes:Platform() == "android" then
		return luaj.callStaticMethod(gAndriodClass, func, args, sig);
	end
end

function VSystem:callJavaFunction( packageName, className, funcName, args, sig )
	if gRes:Platform() == "android" then
		return luaj.callStaticMethod(packageName..className, funcName, args, sig);
	end
end

function VSystem:callObjcFunc(func, args)
	if gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		return luaoc.callStaticMethod("AppController", func, args);
	end
end

function VSystem:openSite(url)
	if gRes:Platform() == "android" then
		local args = {url};
		local sig = "(Ljava/lang/String;)V"
		self:callJavaFunc("openSite", args, sig);
	end
end

function VSystem:callPhone(phoneString)
	if gRes:Platform() == "android" then
		local args = {phoneString};
		local sig = "(Ljava/lang/String;)V"
		self:callJavaFunc("callPhone", args, sig);
	end
end

function VSystem:openWebView(url, params, x, y, width, height)
	if gRes:Platform() == "android" then
		local args = {url,params, x, y, width, height};
		local sig = "(Ljava/lang/String;Ljava/lang/String;IIII)V"
		self:callJavaFunc("openWebPage", args, sig);
	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local args = {url=url, params=params, x=x, y=y, width=width, height=height};
		self:callObjcFunc("openWebPage", args);
	end
end

function VSystem:doWebCmd(cmd)
	if gRes:Platform() == "android" then
		local args = {cmd};
		local sig = "(Ljava/lang/String;)V"
		self:callJavaFunc("doWebPage", args, sig);
	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local args = {cmd=cmd};
		self:callObjcFunc("doWebCmd", args);
	end
end

function VSystem:openCamera(delegate, callBack)
	self.delegate = delegate;
	self.callBack = callBack;
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()V"
		self:callJavaFunc("takePhoto", args, sig);
	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local args = {};
        local function callBackCamera(imgFileName)
            if imgFileName == "false" then
                gWindow:showTip("请在设置中允许使用相机和照片", 1.5);
            else
                VsystemHeadImageCallBack(imgFileName);
            end
        end
        self:callObjcFunc("openCameraAction", {listener = callBackCamera});
	end
end

function VSystem:openPhotos(delegate, callBack)
	self.delegate = delegate;
	self.callBack = callBack;
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()V"
		self:callJavaFunc("selectImage", args, sig);
	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local args = {};
        local function callBackPhotos(imgFileName)
            if imgFileName == "false" then
                gWindow:showTip("请在设置中允许使用照片", 1.5);
            else
                VsystemHeadImageCallBack(imgFileName);
            end
        end
        self:callObjcFunc("openPhotoAction", {listener = callBackPhotos});
	end
end

function VSystem:reboot()
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()V"
		self:callJavaFunc("reboot", args, sig);
	end
end

function VSystem:installPack(path)
	if gRes:Platform() == "android" then
		local args = {path};
		local sig = "(Ljava/lang/String;)V"
		self:callJavaFunc("installPack", args, sig);
	end
end

function VSystem:getImsiNumb()
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()Ljava/lang/String;"
		local ok, ret = self:callJavaFunc("getImsi", args, sig);
		if not ok then
			gLog("luaj error :%d", ret);
		end
		return ret
	end
end

function VSystem:getExtend()
	local frameSize = gDtr:getOpenGLView():getFrameSize();
	if gRes:Platform() == "android" then
		local args = {frameSize.width, frameSize.height};
		local sig = "(II)Ljava/lang/String;"
		local ok, ret = self:callJavaFunc("getExtend", args, sig);
		if not ok then
			gLog("luaj error :%d", ret);
		end
		return ret
	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local extend = Var();
		local function callBackGetExtend(datainfo)
			extend.os = datainfo.os;
			extend.ssid = datainfo.ssid;
			extend.memery = datainfo.memery;
			extend.clientVer = getClientVersion();
			extend.phoneType = datainfo.platform;
			extend.screenW = frameSize.width;
			extend.screenH = frameSize.height;
			extend.udid = datainfo.deviceType;
		end
		self:callObjcFunc("getExtend", {listener = callBackGetExtend});
		return extend:ToString();
	elseif gRes:Platform() == "win32" then
		local extend = Var();
		extend.phoneType = "win32";
		return extend:ToString();
	end
end

function VSystem:pay(channel, userId, amount, param)
	if gCanPay ~= nil and gCanPay == false then
		gWindow:closeWaitTip();
		return;
	end
	gWindow:showWaitTip("loading...",10);
	local channelID = 1;
	if gReq and gReq.channelID then
		channelID = gReq.channelID;
	end
	if gRes:Platform() == "android" then
		local args = {channel, userId, amount, param, channelID};
		local sig = "(IIILjava/lang/String;I)V"
		self:callJavaFunc("pay", args, sig);
	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local function callBackPay(resultString)
			gWindow:closeWaitTip();
			if resultString then
				gWindow:showTip(resultString, 1.5);
			end
		end
		userId = tostring(userId);
		local args = {channel=channel, userId=userId, amount=amount, param=param, channelID=channelID, package=gPackage, payUrl=gPayUrl, rate=gRate, listener = callBackPay};
		self:callObjcFunc("openPay", args);
	end
end

function VSystem:setPayAddress(payAddress)
	if gRes:Platform() == "android" then
		local args = {payAddress};
		local sig = "(Ljava/lang/String;)V"
		local ok, ret = self:callJavaFunc("setPayAddress", args, sig);
		if not ok then
			gLog("luaj error :%d", ret);
		end
	end
end

function VSystem:addShortCut()
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()V"
		local ok, ret = self:callJavaFunc("addShortCut", args, sig);
		if not ok then
			gLog("luaj error :%d", ret);
		end
	end
end

function VSystem:stringHeightSystemFont(string, width, fontSize, align)
	if not gListDynamicCellHight then
		return 0;
	end
	fontSize = fontSize or 25;
	align = align or 0;
	if gRes:Platform() == "android" then
		local args = {string, "Arial", fontSize, align, width};
		local sig = "(Ljava/lang/String;Ljava/lang/String;III)I"
		local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxBitmap", "computeTextHeight", args, sig);
		if not ok then
			gLog("luaj error :%d", ret);
		end
		return ret;
	elseif gRes:Platform() == "mac" then
		return gRes:stringHeightSystemFont(string, width, fontSize, align);
	end
	return 0;
end

function VSystem:isNetworkConnected()
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()Z"
		local ok, ret = self:callJavaFunc("isNetworkConnected", args, sig);
		if not ok then
			gLog("luaj error :%d", ret);
		end
		return ok;
	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local ok, ret = self:callObjcFunc("isNetworkConnected");
		return ok;
	elseif gRes:Platform() == "win32" then
		return true;
	end
end

--登录成功调用此方法，保存推送相关信息
function  VSystem:setNotifyServerInfo(gameServerIP, gameServerPort, notifyTime, zoneId, userId)
	if gRes:Platform() == "android" then
		local args = {gameServerIP, gameServerPort, notifyTime, zoneId, userId};
		local sig = "(Ljava/lang/String;IIII)V";
		local ok, ret = self:callJavaFunc("setNotifyServerInfo", args, sig);
		if not ok then
			gLog("luaj error :%d", ret);
		end
	end
end


function  VSystem:setLocalNotifyCheckInfo(zoneId, userId, json)
	if gRes:Platform() == "android" then
		local args = {zoneId, userId, json};
		local sig = "(IILjava/lang/String;)V";
		self:callJavaFunc("setLocalNotifyInfo", args, sig);
	end
end

--android平台打印日志
function VSystem:log(log)
	if gRes:Platform() == "android" then
		local args = {log};
		local sig = "(Ljava/lang/String;)V";
		self:callJavaFunc("log", args, sig);
	end
end


--android平台下，获取手机的网络平台
--1，移动 2，联通 3，电信
function VSystem:GetPhoneNet()
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()I";
		local ok,netType = self:callJavaFunc("getPhoneNet", args, sig);
		return netType;
	end
end

--用默认浏览器打开指定网站
function VSystem:openWebviewByDefaultIE( url )
	if gRes:Platform() == "android" then
		local args = {url};
		local sig = "(Ljava/lang/String;)V";
		self:callJavaFunc("openWebviewByDefaultIE", args, sig);
	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local args = {url=url};
		self:callObjcFunc("openWebViewWithSafari", args);
	end
end

function VSystem:getPlatformMusicFileName( filename )
    if gRes:Platform() == "android" then
		if string.find(filename, ".ogg") then
			-- 针对老版本处理
			return filename;
		else
			return filename..".ogg";
		end
    elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		if string.find(filename, ".ogg") then
			-- 针对老版本处理
			return string.gsub(filename, "ogg", "mp3");
		else 
			return filename..".mp3";
		end
	else
		return filename;
    end
end

--------------------------------------------------------------------------
--和游戏SDK
--android平台下，退出前调用和游戏的退出接口
function VSystem:preExitGame()
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()V";
		self:callJavaFunc("preExitGame", args, sig);
	end
end 

--获取和游戏音效开关
function VSystem:isMusicEnabled( )
	if gRes:Platform() == "android" then
		local args = {};
		local sig = "()Z";
		local ok, ret = self:callJavaFunc("isMusicEnabled", args, sig);
		if ok then
			if ret then
				return 0;
			else
				return 1;
			end
		end
	end
	return 0;
end

function VSystem:packageLoginAction(delegate)
	if gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local function callBackPackageLoginAction(params)
            if params.errorString then --登录失败
                gWindow:showTip(params.errorString, 1.5);
                VCallBack(delegate, "resetUI", nil);
            else --登录成功
                VCallBack(delegate, "loginPackageSuccessIniOS", params);
            end
		end
		local args = {packageId = gPackage, listener = callBackPackageLoginAction};
		self:callObjcFunc("openPackageLoginView", args);
	end
end

function VSystem:saveThirdUserId(userId)
	if gRes:Platform() == "android" then

	elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local args = {userId=userId};
		self:callObjcFunc("saveThirdUserId", args);
	end
end

function VSystem:openPartnerAccountView()
	if gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		local args = {packageId = gPackage};
		self:callObjcFunc("openPartnerAccountView", args);
	end
end