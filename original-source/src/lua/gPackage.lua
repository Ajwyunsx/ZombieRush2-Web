--gPackage.lua
gPackage = 1020;	--渠道ID 	1000：移动和游戏渠道包，


					--			1001：电信单机渠道包， 
					--			1002：联通单机渠道包
					--			1003：斯凯单机渠道包
					--          1004：聚乐付渠道包
					--          1005：爱思渠道包
					--          1006：UUC渠道包
					--			1007: 翔云付	
					--			1008: 明天动力渠道包
					--          1009：XY渠道包
					--			1010: 乐途
					--			1011: 斯凯
					--			1012:海马
					--			1013:百度91
					--			1014:i苹果
					--			1015:快用
                    --          1016：xx
                    --          1017：同步推
                    --          1018：itools
                    --          1019:乐8
                    --          1020:uc

gRechargeChannels = { 1020 };

gNewServer = 1;

gSwitchRechargeChannel = true;

gWechatPay = false;	-- 是否有微信支付

gAndriodClass_normal = true; --是否非改包名的路径(用于uucun)

gBranch = 3;	-- 分支号 0为主版本 2为2-2 3为2-3 gBranch为nil默认为2-2(用于区分植物、僵尸等动画缩放)

gSkull = true;  -- 翻皮版本

if gPackage == 1005 
	or gPackage == 1009
    or gPackage == 1012
	or gPackage == 1013
	or gPackage == 1014
	or gPackage == 1015
    or gPackage == 1016
    or gPackage == 1017
    or gPackage == 1018
    or gPackage == 1019 then
	gPartnerLogin = true;		-- 第三方登录
end

gPackageVersion = 100;    --判断是走单机还是网游    服务器的版本小于这个走单机，大于走网游
getPackageFinishFlag = nil
if gPackage == 1000 then
	gVerSurf = "defaultver"; --  取版本后缀
elseif gPackage == 1020 then
	gVerSurf = "215";
end

gUpdateNewFileName="update.lua"

