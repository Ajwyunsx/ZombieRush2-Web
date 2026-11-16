
--卡牌详情界面
-- aType:1植物，2怪物  ID：怪物/植物 thingid
function showCardInfoDlgById(id, aType) 
	if aType == 2 then
		local ci = VNode("vCardInfoDlg.vui");
		local card = VMonsterInfo.createMonsterInfoById(id);
		ci:setCardInfo(card,2);
		gView():Push(ci);
	elseif aType == 1 then
		local ci = VNode("vCardInfoDlg.vui");
		local card = VPlantInfo.createPlantInfoById(id);
		ci:setCardInfo(card,1);
		gView():Push(ci);
	end
end


--显示团战界面
function ShowGroupBattleDlgByAssistInfo( assistInfo )
	local cdlg = VNode("vClanWarDlg.vui");
	cdlg:SetAssistInfo(assistInfo);
	gView():Push(cdlg);
end

--显示团战界面
function ShowGroupBattleDlgByAssistId( battleid, assistid)
	local cdlg = VNode("vClanWarDlg.vui");
	local assistInfo = {};
	assistInfo.battleid = battleid;
	assistInfo.assistTarget = assistid;
	cdlg:SetAssistInfo(assistInfo);
	gView():Push(cdlg);
end

function ShowGroupBattleDlgByGroupBattleInfo( groupBattleInfo )
	local cdlg = VNode("vClanWarDlg.vui");
	cdlg:SetGroupBattleInfo(groupBattleInfo);
	gView():Push(cdlg);
end


function GetItemCountTip( count )
	local img = VImage{name="tip", image="zhujiemiantishipaopao.png", fit={-0.4,-0.4}};
	local countText = VText{name="count", text=count, layout="Center", fontSize=12, fit={-0.6,-0.6}};
	img:Push(countText);
	return img;
end

--发送弱联网充值数据给服务器
local function recordPayInfoForOffline( money )
	local dataVar = Var();
	dataVar.userId = gData.userInfo.userid;
	dataVar.sid = gZoneid;
	dataVar.client_ver = getClientVersion();
	dataVar.payUserId = gData.userInfo.userid;
	dataVar.game = 6;

	local dataString = dataVar:ToString();
	local postUrl = gPayUrl.."/charge/orderQuery";
	gNet:Post{url = postUrl, data = dataString, onFinish = function () VCallBack(self, "snsPostCallBack", gLua:Param()); end};
	gWindow:showWaitTip("loading...");
end

function PayAtOffLine( money )
	local channel = -1;
	if gPackage == 1000 or gPackage == 1020 then
		local phoneType = gSys:GetPhoneNet();
		if phoneType == 100 then
			channel = 1016;
		elseif phoneType == 102 then
			channel = 1004;
		elseif phoneType == 101 then
			channel = 1005;
		end
	elseif gPackage == 1003 then
		channel = 304;
    elseif gPackage == 1004 then
        channel = 1018;
    elseif gPackage == 1006 then
    	channel = 1019;
    elseif gPackage == 1007 then
    	channel = 1020;
    elseif gPackage == 1008 then
    	channel = 1021;
    elseif gPackage == 1010 then
        channel = 1022;
    elseif gPackage == 1011 then
    	channel = 304;
	end
	
    local params = string.format("{ \"sid\": %d, \"client_ver\":\"%s\"}",
    gZoneid or 0, getClientVersion());
	gSys:pay(channel, gData.userInfo.userid, money*100, params);
end




--充值完成回调
function VRechargeCallBack(param)
	gWindow:closeWaitTip();
	local msg = Var();
	msg:FromString(param);
	if msg.channel == 2 then
		local ypDlg = gView()("yeePayDlg");
		if ypDlg then
			ypDlg:onPayCallBack();
		end
	elseif msg.channel == 1016 or msg.channel == 1004 or msg.channel == 1005 
		or msg.channel==304 or msg.channel == 1018 or msg.channel == 1019 
		or msg.channel==1020 or msg.channel==1021 or msg.channel == 1022 
		or gData.userInfo.dungeonInfo:CheckExraPackage() then
		local dungeonShopDlg = gView()("dungeonShopDlg")
		local bttleFaildTip = gView()("bttleFaildTip")
		local extraShopDlg = gView()("extraShopDlg")
		local extraGiftDlg = gView()("extraGiftDlg")
		local extraGiftSecDlg = gView()("extraGiftSecDlg")
		local battleHelpShopDlg = gView()("battleHelpShopDlg")
		if dungeonShopDlg then
			dungeonShopDlg:SendSMSBack(msg.ok)
		elseif bttleFaildTip then
			bttleFaildTip:SendSMSBack(msg.ok)
		elseif extraShopDlg then
			extraShopDlg:SendSMSBack(msg.ok)
		elseif extraGiftDlg then
			extraGiftDlg:SendSMSBack(msg.ok)
		elseif extraGiftSecDlg then
			extraGiftSecDlg:SendSMSBack(msg.ok)
		elseif battleHelpShopDlg then
			battleHelpShopDlg:SendSMSBack(msg.ok)
		end
	end
    local phoneType = gSys:GetPhoneNet();
	if not msg.ok and msg.error then 
        if phoneType == 102 then
        else
		gWindow:showTip(msg.error);
        end
		return;
	end
end

----和游戏退出回调
function AndGameExit()
	-- local handle = gDtr:getScheduler():scheduleScriptFunc(
	-- 	function()
	-- 		gDtr:getScheduler():unscheduleScriptEntry(handle);
	-- 		gDtr:endToLua();
	-- 	end, 5, false);
end


function CreateCsvCacheByCsvNameAndKeys( name, ... )
    local info = {};
    local csv = gData:readCsv(name);
    local data = csv:allData();
    for i,v in ipairs(data) do 
        local mapKey = "";
        for ik,vk in ipairs({...}) do 
        	local kk = csv:rowName(vk);
            mapKey = mapKey..v[kk];
        end
        info[mapKey] = v;
    end
    return info;
end


function ShowItemInfoDlg( itemType, itemid )
	if itemType == RES_DATA_TYPE.ResDataTypePlant then
		showCardInfoDlgById(itemid,1);
	elseif itemType == RES_DATA_TYPE.ResDataTypeArm then
		showCardInfoDlgById(itemid,2);
	elseif itemType == RES_DATA_TYPE.ResDataTypeItem then
		
	end
end
