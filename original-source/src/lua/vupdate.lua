-- vupdate.lua

require "vZipUpdate"

VUpdate = vclass("Update");


_VUpdateState = {
	noUpdate = 0,
    forceUpdate = 1,
    chooseUpdate = 2,
}

function VUpdate:initialize()
	self.versionList = {};
end

--读取本地版本号信息
function VUpdate:loadVersionFromFile()
	self.versionList = {};
	local var = Var();
	local fileName = addZonePath("ver.log");
	var:FromFile(fileName, false, false, _VPath.Public);

	local iter = VDataIter();
	while var:Travel(iter) do
		local key = iter:Name();
		local value = iter:Data();
		self.versionList[key] = value;
	end
end

--从上次登陆过的区，读取版本号
function VUpdate:readVersionFromLastZoneId()
	local logPath = "ver.log";
	local lastZoneId = gData.accountInfo.lastZoneId;
	if lastZoneId then
		logPath = lastZoneId.."/"..logPath;
	end
    local var = Var();
	local fileName = logPath;
	var:FromFile(fileName, false, false, _VPath.Public);
	return var;
end

--保存版本号信息
function VUpdate:saveVersionToFile()
	local var = Var(self.versionList);
	local fileName = addZonePath("ver.log");
	var:SaveFile(fileName);
end

--检查服务器状态，及版本号信息，由资源服务器中的update.lua来调用。
function VUpdate:update()
	self:checkServerState();
end

function VUpdate:checkServerState() -- 判断是否维护状态
	if (gForceEnter and gForceEnter == "1") or not gState or gState == 0 then
		self:checkClientVerion();
	else
		if gState == 1 then
			if gNotice and gNotice ~= "" then
				gWindow:showNormalTip(gNotice, nil , "Center");
			else
				gWindow:showNormalTip("服务器维护中，请稍后重试", nil , "Center");
			end
			FailResetUi();
			return;
		elseif gState == 2 then
			if gNotice and gNotice ~= "" then
				local webView = VNode("vwebView.vui");
				webView.url = gNotice;
				gView():Push(webView);
			else
				gWindow:showNormalTip("服务器维护中，请稍后重试", nil , "Center");
			end
			FailResetUi();
			return;
		else
			self:checkClientVerion();
		end
	end
end

--获取服务器列表信息
function VUpdate:updateZoneList()
	self:checkGZoneUrl();
	downLoadFile(gZoneUrl, nil, "gUpdate:updateZoneListFinish(gLua:Param(), 1)")
end

--读取本地文件，如果存在，切换gZoneUrl
function VUpdate:checkGZoneUrl()
	if gRes:Platform() == "android" then
		if gRes:GetFileLen("url.txt") > 0 then
           	local urlData =  self:loadGZoneUrlFromPub();
            if urlData then
            	if urlData.url then
                	gZoneUrl = urlData.url;
                end
                if urlData.forceEnter then
                	gForceEnter = urlData.forceEnter;
                end
            end
        end
    elseif gRes:Platform() == "ios" then
		local function callBackGetZoneUrl(url)
			if url then
				gZoneUrl = url;
			end
		end
		local args = {fileName="url.txt", listener=callBackGetZoneUrl};
		gSys:callObjcFunc("getZoneUrl", args);
	end
end

function VUpdate:loadGZoneUrlFromPub()
    if gRes:Platform() == "android" then
        local urlData = Var();
        urlData:FromFile("url.txt", false, false, _VPath.Public);
        return urlData;
	end
end

--获取服务器列表信息返回
function VUpdate:updateZoneListFinish(msg, times)
	local ret = msg:Number("ret");
	if ret == 0 then
		local content = msg:String("content");
		gData:readCsvFromString(content, "zonelist", true);
		zoneListUpdateFinish();
	else
		if gZoneUrlReserve and times <= 2 then
			downLoadFile(gZoneUrlReserve, nil, "gUpdate:updateZoneListFinish(gLua:Param(), 2)");
		else
			zoneListUpdateFailed();
			cclog("update zone list get error");
		end
	end
end

--检查apk安装包版本号
function VUpdate:checkClientVerion()
	self.updateState = _VUpdateState.noUpdate;

	if gRes:Platform() == "android" then
		local localExeVersion = gRes:Version();
		cclog("oldexeversion = %s", localExeVersion);

		if versionCompare(localExeVersion, exe_version_new) == -1 then
			cclog("we have a new client version %s to update", exe_version_new);
			self.apkFileName = "vfarm".."_"..exe_version_new..".apk";
			if versionCompare(localExeVersion, exe_version_min) == -1 then
				cclog("client update force");
				self.updateState = _VUpdateState.forceUpdate;
			else
				cclog("client update choose");
				self.updateState = _VUpdateState.chooseUpdate;
			end
		end
	end
	self:checkUpdateState();
end

function VUpdate:checkUpdateState()
	if self.updateState == _VUpdateState.forceUpdate then
		self:getUpdateFile();
	elseif self.updateState == _VUpdateState.chooseUpdate then
		gWindow:showConfirmTip("有新的客户端可以更新", "确定", "取消", self, "getUpdateFile", "cancelApkUpdate")
		-- self:checkResUpdate();
	elseif self.updateState == _VUpdateState.noUpdate then
		self:checkResUpdate();
	end
end

function VUpdate:cancelApkUpdate()
	self:checkResUpdate()
end

function VUpdate:loadResFile(fileName)
	if gRes:GetFileLen(fileName) > 0 then
		self:reloadResFile(fileName);
	else
		self:getResFile(fileName);
	end
end


-- exe_version_new = "1.0.1"
-- exe_version_min = "1.0.0"

-- gNewImageZipList = {"vfarm001.zip"};
-- gNewImageZipVersions = {["vfarm001.zip"] = 1};

-- gNewResList = {"vfarmLua.res", "vfarmCsv.res"}
-- gNewResListEncode = {["vfarmLua.res"] = 1, ["vfarmCsv.zip"] = 0, ["vfarmCsv.res"] = 1}
-- gNewResVersionList = {["vfarmLua.res"] = 3, ["vfarmCsv.zip"] = -1, ["vfarmCsv.res"] = -1}
-- gState = 0; 0正常，1：提示维护，2：弹出url
-- gNotice = "服务器维护中";

-- gUpdate:update();

--检查资源版本号，脚本，配置表，图片
function VUpdate:checkResUpdate()
	if gNewResList and #gNewResList~=0 then
		local fileName = table.remove(gNewResList, 1); --vfarmLua.res
		local zoneFileName = addZonePath(fileName); --zoneId/fileName
		local currentVer = self.versionList[fileName];
		local newVer = gNewResVersionList[fileName];
		local needLoadRes = true;
		local needLoadServer = true;
		if fileName == "vfarmLua.res" then
			-- if gReadLocalLua then
			-- 	needLoadRes = false;
			-- end
			if currentVer then
				gClientVer = currentVer;
			else
				gClientVer = gVersion;
			end
			
			if newVer and newVer ~= -1 and gClientVer >= newVer then
				needLoadRes = false;
			end
		elseif fileName == "vfarmCsv.res" then
			if gReadLocalCsv then
				needLoadServer = false;
			end
		end

		if not needLoadRes then --不需要更新lua文件
			--如果预先加载了上次选择区的Lua包，此处需要再把本地的Lua包加载回来。。。。
			--参看run()
			if gDidLoadLastZoneLua then
				if gRes:Platform() == "android" then
					gRes:ReadResData("1.res");
				else
					vLuaReloadLocal();
				end
			end
			self:checkResUpdate();
			return;
		end

		if not needLoadServer then --不需要更新csv文件
			if gRes:GetFileLen(zoneFileName) > 0 then
				self:reloadResFile(fileName);
				self:checkResUpdate();
			else
				self:getResFile(fileName);
			end
			return;
		end

		if not newVer or not currentVer or newVer == -1 then
			self:getResFile(fileName);
		elseif currentVer < newVer then
			self:getResFile(fileName);
		else
			if gRes:GetFileLen(zoneFileName) > 0 then
				self:reloadResFile(fileName);
				self:checkResUpdate();
			else
				self:getResFile(fileName);
			end
		end
		return;
	end
	gZipUpdate:loadVersionFromFile();
	gZipUpdate:checkImageUpdate();
end

--重新载入脚本，配置表文件。
function VUpdate:reloadResFile(resfilename)
	local encode = true;
	if gNewResListEncode[resfilename] == 0 then
		encode = false;
	end
	resfilename = addZonePath(resfilename);
	if encode then
		gRes:ReadResData(resfilename, _VPath.Public);
	else
		gRes:UnZipResFile(resfilename);
	end
	gLua:Flush();
	-- gZipUpdate:checkImageUpdate();
end

--下载资源文件
function VUpdate:getResFile(fileName)
	local url = gResUrl..fileName;
	downLoadFile(url, addZonePath(fileName), "gUpdate:resFileDownloadFinish(gLua:Param())");
end

--下载资源文件返回
function VUpdate:resFileDownloadFinish(msg)
	local ret = msg:Number("ret");
	if ret == 0 then
		local fileName = msg:String("filename");
		fileName = removeZonePath(fileName);
		local newVer = gNewResVersionList[fileName];
		if newVer then
			self.versionList[fileName] = newVer;
			self:saveVersionToFile();
		end
		self:reloadResFile(fileName);
		-- gRes:RemoveFile(fileName);
	else
		cclog("get Res File error");
	end
	self:checkResUpdate();
end

--从资源服务器上获取升级脚本，即update.lua
function VUpdate:getUpdateLua()
	local url = gResUrl..gUpdateFileName;
	cclog(gResUrl..gUpdateFileName);
	downLoadFile(url, nil, "gUpdate:updateLuaDownloadFinish(gLua:Param())")
end

--从资源服务器上获取升级脚本返回，执行update.lua
function VUpdate:updateLuaDownloadFinish(msg)
	local ret = msg:Number("ret");
	if ret == 0 then
		self:loadVersionFromFile();
		local content = msg:String("content");
		gLua:DoString(content);
	else
		UpdateLuaLoadFailed();
		cclog("update lua get error");
	end
end

--下载新的安装包，限android
function VUpdate:getUpdateFile()
	if gRes:Platform() == "ios" then

	else
		local url = gResUrl..self.apkFileName;
		downLoadFile(url, self.apkFileName, "gUpdate:apkDownloadFinish(gLua:Param())", "gUpdate:apkDownloadProgress(gLua:Param())", 1);
	end
end

--下载新的安装包返回，限android
function VUpdate:apkDownloadFinish(msg)
	local ret = msg:Number("ret");
	if ret == 0 then
		gWindow:showConfirmTip("新客户端下载完成，点击确定安装", "确定", nil, self, "installNewClient", nil)
		cclog('apk download finish');
	else
		cclog('apk download error');
	end
end

--安装新的apk包，限android
function VUpdate:installNewClient()
	if gRes:Platform() == "android" then
		local path = gRes:FilePath(self.apkFileName, _VPath.Public);
		gSys:installPack(path);
		self.apkFileName = nil;
	else
		self:checkResUpdate();
	end
end

--apk包下载进度回调，限android
function VUpdate:apkDownloadProgress(msg)
	local progress = msg:Number("progress")
	cclog("progress = %d", progress);
	gView():apkDownloadProgress(progress);
end

