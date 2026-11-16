--config.lua

gVersion = 138;

--游戏id
gGameId = 6;

--更新脚本
gUpdateFileName = "update.lua";
gUpdateLuaFileName = "vfarmLua.res";
gUpdateCsvFileName = "vfarmCsv.res";

gServerIndex = 4;---0:测试服，1:内测1，2:内测2，3:内测2预发布, 4：公测
gVerUrl = "http://res.farm.vk51.com/version/"
if gServerIndex == 1 then
	gZoneUrl = "http://beta.res.farm.vk51.com/server";
	-- gZoneUrlReserve = "";	--备用取服务器列表地址
	gTrain = false  			-- 是否开启新手引导
	gForTest = false;	
elseif gServerIndex == 2 then
	gZoneUrl = "http://beta.res.farm.vk51.com/2/server";
	gTrain = false  			-- 是否开启新手引导
	gForTest = false;
elseif gServerIndex == 3 then
	gZoneUrl = "http://alpha.res.vk51.com/farm/res/1/server";
	gTrain = false  			-- 是否开启新手引导
	gForTest = false;
elseif gServerIndex == 4 then
	if gNewServer == 1 then
		gZoneUrl = "http://res.farm.vk51.com/server_2"
	else
		gZoneUrl = "http://res.farm.vk51.com/server"
	end
	gTrain = false  			-- 是否开启新手引导
	gForTest = false;
else
	-- gZoneUrl = "http://192.168.15.204/res_nc/server";
	gZoneUrl = "http://szkmol.xicp.net:8181/res_nc/server";
	-- gZoneUrlReserve = "";	--备用取服务器列表地址
	gReadLocalCsv = false;		-- 是否读取本地配置
	gForTest = true;			-- 测试开关
	gOpenBattleLog = false;		-- 战斗日志开关
	gTrain = false;  				-- 是否开启新手引导
	gBattleScaleTest = false;	-- 战场调试骨骼大小开关 测试专用
end

gGameMasterId = 10000;
gGameMasterPhone = "075526615524";

if gForceOffline == nil then
  gForceOffline = true;	--单机开关   防止重新加载的时候重置  加上判断
end

gNotifyTime = 30000		-- 推送消息间隔周期, 单位毫秒

gRate = 100;			--RMB兑换游戏钻石的兑率

gResRate = 10           --RMB与vip积分的兑换率 1元=10钻石=10vip积分

gHeartBeatInterval = 30;	--心跳的时间间隔/s，nil表示不进行心跳。

gSimpleVersion = false;		-- 简单版战场

gCanPay = true; --是否无支付SDK版本