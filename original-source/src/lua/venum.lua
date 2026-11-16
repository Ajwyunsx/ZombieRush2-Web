--venum.lua

function VEnum(t)
	return setmetatable(t, {__call = function(_, k) return type(k) == "string" and t[k] or k end})
end

_VPath = VEnum{
	Private = 0,
	Protect = 1,
	Public = 2,
}

_VLayout = VEnum{
	Full 	= {1,1},
	Fill 	= {-1,-1},
	Max 	= {1,-1},
	Min 	= {-1,1},
	FitW 	= {1,0},
	FitH 	= {0,1},
	["1,1"] 	= "Full",
	["-1,-1"] 	= "Fill",
	["1,-1"] 	= "Max",
	["-1,1"] 	= "Min",
	["1,0"] 	= "FitW",
	["0,1"] 	= "FitH",
}

Eff_onEnter = 2;
Eff_onExit = 4;

_VTags = {
    fscale = 1001
}

_VCtrlOP = VEnum{
	None = 0,
	Add = 1,
	Del = 2,
	Rep = 3,
};

_VTouchType = VEnum{
	Block = 0,
	Building = 1,
	PlantSelect = 2,
	PlantReceive = 3,
	Field = 4,
	Banner = 5,
}

function nop() end

GameFunction = {
	["basecamp_info"] = 1,
	["basecamp_levelup"] = 2,
	["store_info"] = 3,
	["store_levelup"] = 4,
	["store_train"] = 5,
	["armycamp_info"] = 6,
	["armycamp_levelup"] = 7,
	["laboratory_info"] = 27,
	["laboratory_levelup"] = 28,
	["laboratory_research"] = 29,
	["altar_info"] = 46,
	["altar_levelup"] = 47,


	["plant_info"] = 11,
	["plant_levelup"] = 12,
	["plant_havest"] = 13,
	["plant_retrieve"] = 14,
	["plant_strengthen"] = 31,

	["farm_plant"] = 10,
	["farm_add_field"] = 19,

	["sys_event"] = 20,
	["sys_event_roulette_plant"] = 21,
	["sys_event_signin"] = 30,
	["sys_event_quest"] = 33,
	["sys_event_roulette_monster"] = 24,
	["sys_event_achievement"] = 34,

	["sys_rob"] = 15,
	["sys_rob_search"] = 22,
	["sys_rob_scorerank"] = 23,
	["sys_rob_battle"] = 16,

	["sys_chat"] = 26,
	["sys_chat_speak"] = 35,
	
	["sys_bag"] = 17,
	["sys_add_farmer"] = 18,
	["sys_log"] = 25,
	["sys_shop"] = 32,
	["sys_vip"] = 36,
	["sys_recharge"] = 37,
	["sys_rechargeAdd"] = 9,
	["sys_scoreBar"] = 39,
	["sys_setting"] = 45,
	["levelup_accelerate"] = 42,
	["levelup_cancel"] = 43,
	["havest_accelerate"] = 44,
}

EventId = {
	["quest_finish_on"] = 1,
	["quest_finish_off"] = 2,
	["user_levelup"] = 3,
	["achievement_on"] = 4,
	["achievement_off"] = 5,
	["armycamp_full_on"] = 6,
	["armycamp_full_off"] = 7,
	["sign_on"] = 8,
	["sign_off"] = 9,
	["vip_change"] = 10,
	["shop_refresh_on"] = 11,
	["shop_refresh_off"] = 12,
	["plant_lottery_on"] = 13,
	["plant_lottery_off"] = 14,
	["package_on"] = 15,
	["package_off"] = 16,
	["openFunc_on"] = 17,
	["monster_lottery_on"] = 18,
	["monster_lottery_off"] = 19,
}

--通知类型
NoticeType = {
	["finish_monster_star"] = 101,
	["quest"] = 102,
	["achievement_finish"] = 103,
	["check_in"] = 104,
	["free_draw_card"] = 106,
	["battle_end"] = 107,
	["battle_begin"] = 108,
	["shop_refresh"] = 109,
}

NoticeQuestType = {
	["quest_new"] = 0,
	["quest_finish"] = 1,
}

--抽战旗方式
BannerLotteryType = {
	["type_pu"] = 1,
	["type_zuan"] = 2,
}

FontSize = {
	["fs_32"] = 24,
	["fs_26"] = 22,
	["fs_22"] = 18,
	["fs_18"] = 16,
	["fs_14"] = 14,
}

FontColor = {
	["fc_1_"] = cc.c3b(251,231,198),
	["fc_2_"] = cc.c3b(254,224,183),
	["fc_3_"] = cc.c3b(252,238,19),
	["fc_4_"] = cc.c3b(160,90,2),
	["fc_5_"] = cc.c3b(147,113,67),
	["fc_6_"] = cc.c3b(124,78,44),
	["fc_7_"] = cc.c3b(93,57,0),
	["fc_8_"] = cc.c3b(84,43,13),
	["fc_9_"] = cc.c3b(223,77,64),
	["fc_10_"] = cc.c3b(209,27,14),
	["fc_11_"] = cc.c3b(226,0,1),
	["fc_12_"] = cc.c3b(138,22,9),
	["fc_13_"] = cc.c3b(103,35,14),
	["fc_14_"] = cc.c3b(47,110,29),
	["fc_15_"] = cc.c3b(21,82,23),
}

PartnerChannel = {
	CHANNEL_I4 = 108;			-- 爱思
	CHANNEL_7659 = 109;			-- 7659快用
	CHANNEL_XY = 110;			-- XY
    CHANNEL_ZH = 112;           --海马
	CHANNEL_IA = 175;			-- i苹果
    CHANNEL_XX = 113;			-- xx助手
    CHANNEL_LE8 = 114;			-- 乐8
    CHANNEL_ITOOLS = 115;			-- itools
    CHANNEL_TONGBU = 116;			-- 同步推
    CHANNEL_BAIDU91 = 117;			-- 百度91
}

function getPartnerChannel( )
	local channel = 0;
	if gPackage == 1005 then
		channel = PartnerChannel.CHANNEL_I4;
	elseif gPackage == 1009 then
		channel = PartnerChannel.CHANNEL_XY;
    elseif gPackage == 1012 then
        channel = PartnerChannel.CHANNEL_ZH;
	elseif gPackage == 1014 then
		channel = PartnerChannel.CHANNEL_IA;
	elseif gPackage == 1015 then
		channel = PartnerChannel.CHANNEL_7659;
    elseif gPackage == 1016 then
        channel = PartnerChannel.CHANNEL_XX;
    elseif gPackage == 1017 then
        channel = PartnerChannel.CHANNEL_TONGBU;
    elseif gPackage == 1018 then
        channel = PartnerChannel.CHANNEL_ITOOLS;
    elseif gPackage == 1019 then
        channel = PartnerChannel.CHANNEL_LE8;
    elseif gPackage == 1013 then
    	channel = PartnerChannel.CHANNEL_BAIDU91;
    end

	return channel;
end

idx_vip_accProduce = 4; --vip特权,每日加速成熟限制次数索引
idx_vip_attackLimit = 6; --vip特权,进攻战场数索引
idx_vip_defendLimit = 7; --vip特权,协防战场数索引
