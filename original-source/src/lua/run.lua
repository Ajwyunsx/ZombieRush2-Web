--run.lua

require "vui"--加载大部分公用模块
require "vloginView"
require "vMainView"
require "vBattleView"

function run()
    --预先缓存大图plist文件数据
    loadImagePlist("activityImg");
    loadImagePlist("activity2");
    loadImagePlist("BattleViewResImg");
    loadImagePlist("commonResImg");
    loadImagePlist("farmMainImg");
    loadImagePlist("FarmResImg");
    loadImagePlist("loginRobViewImg");
    loadImagePlist("MonsterIconImg");
    loadImagePlist("PlantIconImg");
    loadImagePlist("otherIconImg");
    loadImagePlist("OtherViewImg");
    loadImagePlist("wordImg");
    loadImagePlist("smallImageImg");
    loadImagePlist("pvpImg");
    loadImagePlist("banner");
    loadImagePlist("storeAndShop");
    loadImagePlist("lottery");
    loadImagePlist("chapter");
    loadImagePlist("myinfo");
    
    math.randomseed(os.time());
    if gRes:Platform() == "android" then
        cclog = gLog;
    elseif gRes:Platform() == "ios" or gRes:Platform() == "mac" then
        gLog = cclog;
    end
    cclog("version = %s", gRes:Version());

    --加载登陆界面前，如果本地的更新包的版本号比程序内部版本号高，就载入更新包。
    --主要是为了更新选区之前的部分逻辑和界面，比如登陆界面。
    gLog("gVersion = %d", gVersion);
    local lastZoneIdVersion = gUpdate:readVersionFromLastZoneId();
	local localversion = lastZoneIdVersion[gUpdateLuaFileName];
    if localversion then
        gLog("localversion = %s", localversion);
    end

	if localversion and localversion > gVersion then
		local lastZoneId = gData.accountInfo.lastZoneId;
	    if lastZoneId and gRes:GetFileLen(lastZoneId.."/"..gUpdateLuaFileName) > 0 then
			gRes:ReadResData(lastZoneId.."/"..gUpdateLuaFileName, _VPath.Public);
			gDidLoadLastZoneLua = true;
		end
	end

    gWindow:Push("vloginView.vui");
end

function loadImagePlist(name)
	gRes:RegisterImagePlist(name..".plist");
	-- gRes:SpriteFrame(name);
end
