--voffline.lua

VOffline = vclass("Offline");

gOfflineDataFileName = "vOfflineData.dat";
gLastActInfoFileName = "vLastServerData.dat";

function VOffline:initialize()
	self.offline = false;        --单机游戏
    self.encodeOffline = false;  --加密
end

--设置是否为单机模式
function VOffline:setOffline(value)
    self.offline = value;
end

--是否为单机模式
function VOffline:isOffline()
    return self.offline;
end

--获取离线存档路径
function VOffline:getOfflineDataPath()
    --if gForceOffline then
    --    return "OfflineData/";
    --end
    local lastZoneId = gData.accountInfo.lastZoneId or 0;
    local lastRoleId = gData.accountInfo.lastRoleId or 0;
    local path = "";
    if lastZoneId ~= 0 and lastRoleId ~= 0 then
        path = lastZoneId.."/"..lastRoleId.."/";
    end
    return path;
end

--获取离线存档文件名
function VOffline:getOfflineDataFileName()
    return self:getOfflineDataPath()..gOfflineDataFileName;
end

--获取上次服务器关卡数据存档文件名
function VOffline:getLastActInfoFileName()
    return self:getOfflineDataPath()..gLastActInfoFileName;
end

--获取空存档文件名
function VOffline:getEmptyDataFileName()
    return gOfflineDataFileName;
end

--是否有服务器关卡数据存档文件
function VOffline:hasOfflineDataFile()
    return gRes:GetFileLen(gData.offlineData:getOfflineDataFileName()) > 0;
end

--获取空存档文件名
function VOffline:hasEmptyDataFile()
    return gRes:GetFileLen(gData.offlineData:getEmptyDataFileName()) > 0
end

--读取离线存档
function VOffline:loadOfflineData()
    gData:initUserInfo();
    local fileName = self:getOfflineDataFileName();
    if gRes:GetFileLen(fileName) > 0 then
        local var = Var();
        var:FromFile(fileName, false, encodeOffline, _VPath.Public);
        gData.userInfo:loadOfflineData(var);
        self:saveOfflineData();--todo:test
    else --首次进入，使用初始卡牌表
        self:newOfflineData();
    end
end

--保存离线存档
function VOffline:saveOfflineData()
    local var = gData.userInfo:saveOfflineData();
    var = Var(var);
    gRes:makeDir(self:getOfflineDataPath());
    var:SaveFile(self:getOfflineDataFileName(), false, encodeOffline);
end

--获取关卡离线增量数据
function VOffline:getDeltaOfflineData()
	local deltaData = {};

    local lastServerData0 = Var();
    lastServerData0:FromFile(self:getLastActInfoFileName(), false, encodeOffline, _VPath.Public);
    local lastServerData = VDungeonInfo:new();
    lastServerData:synWithPbData(lastServerData0);

    local localData0 = Var();
    localData0:FromFile(self:getOfflineDataFileName(), false, encodeOffline, _VPath.Public);
    local localData = VDungeonInfo:new();
    localData:synWithPbData(localData0.acts);

    for actid,act in pairs(localData.actInfos) do
        local actdata = {};
        local actchanged = false;
        actdata.id = actid;
        actdata.pass = 0;
        actdata.campaignInfo = {};
        for campid,camp in pairs(act.campaignInfo) do
    		local local_camp = camp;
    		local needsUpdate = false;
    		if lastServerData.actInfos and lastServerData.actInfos[actid] and 
                lastServerData.actInfos[actid].campaignInfo and 
                lastServerData.actInfos[actid].campaignInfo[campid] then
                local server_camp = lastServerData.actInfos[actid].campaignInfo[campid];
     			if server_camp.record < local_camp.record then
    				needsUpdate = true;
    			elseif (local_camp.purchase and local_camp.purchase > 0) and (server_camp.purchase == nil or server_camp.purchase == 0 or 
                    local_camp.purchase > server_camp.purchase) then
   					needsUpdate = true;
                end
    		else
    			needsUpdate = true;
    		end
    		if needsUpdate then
                table.insert(actdata.campaignInfo, local_camp);
                actchanged = true;
    		end
    	end
        if actchanged then
            table.sort(actdata.campaignInfo, 
                function(a,b)
                    return a.id < b.id;
                end);
            table.insert(deltaData, actdata);
        end
    end
    table.sort(deltaData, 
        function(a,b)
            return a.id < b.id;
        end);

    return deltaData;
end

--保存服务器上次关卡数据
function VOffline:saveLastServerData(data)
    if data then
        gRes:makeDir(self:getOfflineDataPath());
        data:SaveFile(self:getLastActInfoFileName(), false, encodeOffline);
    end
end

--移动空存档文件到对应角色文件夹
function VOffline:moveOfflineData()
    local var = Var();
    var:FromFile(self:getEmptyDataFileName(), false, encodeOffline, _VPath.Public);
    var:SaveFile(self:getOfflineDataFileName(), false, encodeOffline);
    gRes:RemoveFile(self:getEmptyDataFileName());
end

--新建存档文件
function VOffline:newOfflineData()
    gData.userInfo:makeOfflineData();
    self:saveOfflineData(); 
end

--获取昵称
function VOffline:getNickName()
	local fileName = self:getEmptyDataFileName();
    if gRes:GetFileLen(fileName) > 0 then
        local var = Var();
        var:FromFile(fileName, false, encodeOffline, _VPath.Public);
        randomNick = var.nick;
	else
		randomNick = gData:randomNick();
	end
    return randomNick;
end

--更新本地服务器关卡数据
function VOffline:updateLastServerData(campaignInfo)
    local lastServerData0 = Var();
    lastServerData0:FromFile(self:getLastActInfoFileName(), false, encodeOffline, _VPath.Public);
    local lastServerData = VDungeonInfo:new();
    lastServerData:synWithPbData(lastServerData0);

    local campinfo = lastServerData:CreateCampaignInfo(campaignInfo);
    local actid = lastServerData:GetActInfosID(campinfo.id);
    if actid > 0 then
        if not lastServerData.actInfos[actid] then
            lastServerData.actInfos[actid] = {};
            lastServerData.actInfos[actid].id = actid;
        end
        if not lastServerData.actInfos[actid].campaignInfo then
            lastServerData.actInfos[actid].campaignInfo = {};
        end
        lastServerData.actInfos[actid].campaignInfo[campinfo.id] = campinfo;
        self:saveLastServerData(lastServerData:convert2VData());--保存上次关卡同步数据
    end
end

function VOffline:enterFarm()
    if not gData.userInfo.farmEntered then
        gData.userInfo.farmEntered = true;
        self:saveOfflineData();
    end
end  

function VOffline:uprootPlant()
    gData.userInfo.uprootPlanted = true;
    self:saveOfflineData();
end

function VOffline:hasUprooted()
    return gData.userInfo.uprootPlanted;
end

function VOffline:useBackupTroop()
    gData.userInfo.useBackupTroop = gData.userInfo.useBackupTroop + 1;
    self:saveOfflineData();
end

function VOffline:hasUseBackupTroop()
    return gData.userInfo.useBackupTroop;
end

function VOffline:isEnterFarmBtnVisible()
    if gForTest then 
        return true;
    end
    if gForceOffline then
        return false;
    end;
    act = gData.userInfo.dungeonInfo.actInfos[1];
    if not act then
        return false;
    end;
    camp = act.campaignInfo[10601]; --策划要求调整为第一章第六节通过后进入农场；
    if not camp then
        return false;
    end;
    return camp.record > 0;--2-4通关可看到按钮
end

function VOffline:loadOtherData()
    local userInfo = VUserInfo:new();
    local fileName = self:getOfflineDataFileName();
    if gRes:GetFileLen(fileName) > 0 then
        local var = Var();
        var:FromFile(fileName, false, encodeOffline, _VPath.Public);
        userInfo:loadOfflineData(var);
        gData.userInfo.farmEntered = userInfo.farmEntered;
        gData.userInfo.uprootPlanted = userInfo.uprootPlanted;
        gData.userInfo.useBackupTroop = userInfo.useBackupTroop;
    end    
end