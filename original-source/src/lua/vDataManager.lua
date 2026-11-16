--vDataManager.lua

VDataManager = vclass("DataManager");

function VDataManager:initialize()
	gRes:LoadUserData();--must be front of accountInfo initialize
	self:loadConfig();
end

function VDataManager:initInfo()
	self.csvCache = {};            --csv缓存
	self.userBriefCache = {};      --用户摘要信息缓存
    self:AddCustomInfo()
 	self.accountInfo = VAccountInfo:new();    --账号信息
    self.offlineData = VOffline:new(); --离线数据
 	self.timeDev = 0;                         --服务器时间差
    self.actionOver = true
 	self.chatInfo = VChatInfo:new();          --聊天信息
    self.noticeManager = VNoticeManager:new();    --主界面通知数据
    self:addShortCut();
 	gClient:setUserid(self.accountInfo.id);       --给消息封包层，设置用户的账号ID
    self.readEvents = nil; --记录已经看过的活动id
end

--向桌面添加快捷方式，限android
function VDataManager:addShortCut()
    if self.accountInfo.isAddShortCut and self.accountInfo.isAddShortCut ~= 0 then
    else
        gSys:addShortCut();
        self.accountInfo:setDidAddShortCut(1);
    end
end

--创建用户角色信息
function VDataManager:initUserInfo()
	self.userInfo = VUserInfo:new();
end

--获取当前时间
function VDataManager:currentTime()
	return os.time() + self.timeDev;
end

--登录时，完成用户角色信息全量同步后调用
function VDataManager:DidSynData()
	self.notifyInfo = VSysNotifyInfo:new();
end

--登录时，完成用户角色信息全量同步后调用
function VDataManager:DidChatData()
    -- body
    self.chatNotifyInfo = VWorldChatNotifyInfo:new();
end

--已经进入到农场主界面后调用
function VDataManager:DidEnterMainView()	
	if not self.offlineData:isOffline() then	
        self:loadHeartBeatVer();
        self.battleBriefLogs = VBattleBriefLogs:new();
        if not self.battleRankQuery then
            self.battleRankQuery = VBattleRankQuery:new();
        end
        self.battleBarrierInfo = VBattleBarrierInfo:new();
 	    self:realLogQuery(0, true);
 	    self:checkDefendBattleBriefLog(0, true);
        self.readEvents = self:loadReadEvents();
        if not gData.offlineData.offline then
 	        self:startHeartBeat();
        end
 	end
    gLog("DidEnterMainView");
end

---------------------------------------------------------------------
-- Csv
---------------------------------------------------------------------
--读取配置表数据，如果缓存中没有，则载入。
--@farce：true:忽略缓存
function VDataManager:readCsv( name, farce )
	-- if gRes:Platform() == "win32" then farce = true end
	if self.csvCache[name] == nil or farce then self.csvCache[name] = self:loadCsvWithName(name); end
	return self.csvCache[name];
end

--从字符串中读取配置表数据，如果缓存中有，则返回缓存数据。
--@farce：true:忽略缓存
function VDataManager:readCsvFromString( aString, name, farce )
	-- if gRes:Platform() == "win32" then farce = true end
	if self.csvCache[name] == nil or farce then self.csvCache[name] = self:loadCsvWithString(aString, name); end
	return self.csvCache[name];
end

--从缓存中读取配置表数据
function VDataManager:readCsvCache( name )
    return self.csvCache[name];
end

function VDataManager:loadCsvWithName(name)
	local csvData = VCSVData:new(name);
	csvData:LoadCsvFile();
	return csvData;
end

function VDataManager:loadCsvWithString(aString, name)
	local csvData = VCSVData:new(name);
	csvData:LoadCsvString(aString);
	return csvData;
end

function VDataManager:LoadPlantBaseCsv( ... )
	-- body
	self.prop_plant = self.prop_plant or CreateCsvCacheByCsvNameAndKeys("prop_plant.csv", 0)

	return self.prop_plant
end

function VDataManager:LoadPlantDescritionCsv(  )
    self.prop_plant_type = self.prop_plant_type or CreateCsvCacheByCsvNameAndKeys("prop_plant_type.csv", 0, 1)

	return self.prop_plant_type
end

function VDataManager:LoadPlantProductCsv(  )
    self.plant_product = self.plant_product or CreateCsvCacheByCsvNameAndKeys("plant_product.csv", 0)

	return self.plant_product
end

function VDataManager:LoadPlantBattleCsv(  )
    self.prop_creature_plant = self.prop_creature_plant or CreateCsvCacheByCsvNameAndKeys("prop_creature_plant.csv", 0)

	return self.prop_creature_plant
end

function VDataManager:LoadPlantDeComposeCsv(  )
    self.plant_decompose = self.plant_decompose or CreateCsvCacheByCsvNameAndKeys("plant_decompose.csv", 0)

	return self.plant_decompose
end

function VDataManager:LoadPlantLvUpCsv(  )
    self.plant_levelup = self.plant_levelup or CreateCsvCacheByCsvNameAndKeys("plant_levelup.csv", 0)

	return self.plant_levelup
end

function VDataManager:LoadPlantSkillchangeCsv(  )
    self.plant_upstar_skillchange = self.plant_upstar_skillchange or CreateCsvCacheByCsvNameAndKeys("plant_upstar_skillchange.csv", 0)

	return self.plant_upstar_skillchange
end

function VDataManager:LoadMonsterBaseCsv( ... )
	-- body
	self.prop_monster = self.prop_monster or CreateCsvCacheByCsvNameAndKeys("prop_monster.csv", 0)

	return self.prop_monster
end

function VDataManager:LoadMonsterDescritionCsv(  )
    self.prop_monster_type = self.prop_monster_type or CreateCsvCacheByCsvNameAndKeys("prop_monster_type.csv", 0, 1)

	return self.prop_monster_type
end

function VDataManager:LoadMonsterBattleCsv(  )
    self.prop_creature_monster = self.prop_creature_monster or CreateCsvCacheByCsvNameAndKeys("prop_creature_monster.csv", 0)

	return self.prop_creature_monster
end

function VDataManager:LoadMonsterDeComposeCsv(  )
    self.monster_decompose = self.monster_decompose or CreateCsvCacheByCsvNameAndKeys("monster_decompose.csv", 0)

	return self.monster_decompose
end

function VDataManager:LoadMonsterLvUpCsv(  )
    self.monster_levelup = self.monster_levelup or CreateCsvCacheByCsvNameAndKeys("monster_levelup.csv", 0)

	return self.monster_levelup
end

function VDataManager:LoadMonsterSkillchangeCsv(  )
    self.monster_upstar_skillchange = self.monster_upstar_skillchange or CreateCsvCacheByCsvNameAndKeys("monster_upstar_skillchange.csv", 0)

	return self.monster_upstar_skillchange
end

function VDataManager:LoadItemCsv( ... )
	-- body
	self.prop_item = self.prop_item or CreateCsvCacheByCsvNameAndKeys("prop_item.csv", 0)

	return self.prop_item
end

function VDataManager:LoadShopCsv( ... )
	-- body
	self.prop_shop = self.prop_shop or CreateCsvCacheByCsvNameAndKeys("prop_shop.csv", 0)

	return self.prop_shop
end

function VDataManager:LoadActionCsv( ... )
	-- body
	-- self.action_effect = self.action_effect or CreateCsvCacheByCsvNameAndKeys("action_effect.csv", 0)
    if self.action_effect then
        return self.action_effect
    end

    local csv = gData:readCsv("action_effect.csv");
    local lineData = csv:allData();

    if not lineData then 
        return;
    end
    
    local count = table.getn(lineData)
    
    self.action_effect = {}
    
    for var=1, count do
        local effect = {}
        effect.id = lineData[var].id
        effect.effectType = lineData[var].effectType;
        effect.effectid = lineData[var].effectid;
        effect.effectValue = lineData[var].effectValue;
        effect.effectAddtion = lineData[var].effectAddtion
        -- table.insert(self.action_effect, effect)
        self.action_effect[""..effect.id] = self.action_effect[""..effect.id] or {}
        local action_effect = self.action_effect[""..effect.id]
        table.insert(action_effect, effect)
    end

	return self.action_effect
end

---------------------------------------------------------------------
-- LoadItemCommon
---------------------------------------------------------------------
function VDataManager:LoadItemCommon(parameters)
    local item_commonCsv = gData:readCsv("item_common.csv");
    local item_common = item_commonCsv:lineData(0);
    if not item_common then 
        gLog("item_common.csv miss ID:%d", 0);
        return nil;
    end
    return item_common
end

---------------------------------------------------------------------
-- LoadUserCommon
function VDataManager:LoadUserCommon()
    local csv = gData:readCsv("user_common.csv");
    local lineData = csv:lineData(0);
    if not lineData then 
        gLog("user_common.csv miss ID:%d", 0);
        return nil;
    end
    return lineData;
end


---------------------------------------------------------------------
-- prop_time 时间方案
local function ConvertStringToTime( strTime )
    local t = {};
    local y,_ = string.find(strTime, "/", idx);
    t.year = tonumber(string.sub(strTime, 1, y-1));
    local m,_ = string.find(strTime, "/", y+1);
    t.month = tonumber(string.sub(strTime, y+1, m-1));
    local d,de = string.find(strTime, " ", m+1);
    t.day = tonumber(string.sub(strTime, m+1, d-1));
    local h,_ = string.find(strTime, ":", de+1);
    t.hour = tonumber(string.sub(strTime, de+1, h-1));
    t.min = tonumber(string.sub(strTime, h+1));
    return os.time(t);
end

local function ConvertStringToHour( strTime )
    local h,_ = string.find(strTime, ":", 1);
    local hour = tonumber(string.sub(strTime, 1, h-1)) or 0;
    local m,_ = string.find(strTime, ":", h+1);
    local min = tonumber(string.sub(strTime, h+1), m-1) or 0;
    -- local sec = tonumber(string.sub(strTime, m+1)) or 0;
    return hour*3600+min*60;
end


--@param id 方案ID号
function VDataManager:IsTimeInForce( id )
    local csv = self:readCsv("prop_time.csv");
    local linesData = csv:linesWithRowValue(0,id);
    local timeCsv = {};
    for i,v in ipairs(linesData) do 
        if not timeCsv[v[1]] then
            timeCsv[v[1]] = {};
        end
        table.insert(timeCsv[v[1]], v);
    end
    local flag = 0;
    local curTime = self:currentTime();
    local result = false;
    for i,v in pairs(timeCsv) do 
        for t,p in ipairs(v) do 
            
            if p[2] == 1 then --天
                local bt = ConvertStringToTime(p[3]);
                local et = ConvertStringToTime(p[4]);
                if curTime < bt or curTime > et then
                    result = false;
                    break;
                end
            elseif p[2] == 2 then --星期
                local temp = os.date("*t", curTime);
                local bt = p[3];
                local et = p[4];
                if (temp.wday-1) < bt or (temp.wday-1) > et then
                    result = false;
                    break;
                end
            elseif p[2] == 3 then   --小时
                local bt = ConvertStringToHour(p[3]);
                local et = ConvertStringToHour(p[4]);
                local temp = os.date("*t", curTime);
                local ct = temp.hour*3600 + temp.min*60;
                if ct < bt or ct > et then
                    result = false;
                    break;
                end
           --elseif p[2] == 4 then   --注册/数
           --elseif p[2] == 5 then   --开服/数
            end
            result = true;
        end
        if result then 
            break;
        end
    end
    return result;
end



---------------------------------------------------------------------
-- 字符串处理
---------------------------------------------------------------------
--计算utf8包括中文字符在内的字符串,返回字符个数,中文字符也算一个
function VDataManager:CaleChineseLen(str)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
--            if not tmp then
--                return cnt;
--            end
        local i=#arr;
        while arr[i] do           
            if tmp >= arr[i] then left=left-i;break;end
            i=i-1;
        end
        cnt=cnt+1;
    end
    return cnt;
end


--去掉字符串首尾空格
function VDataManager:Trim(str)
    local byte = string.sub(str, 1, 1)
    
    if byte ==  " " then
        str = string.sub(str, 2, -1)
    end
    
    byte = string.sub(str, -1, -1)

    if byte ==  " " then
        str = string.sub(str, 1, -2)
    end
    
    return str
end


---------------------------------------------------------------------
-- Training
---------------------------------------------------------------------
function VDataManager:LoadTraining(parameters)
    return gData:readCsv("prop_trainning.csv");
end

function VDataManager:StepAllTrainning()
    local trainCsv = self:LoadTraining()
    local count = trainCsv:lineCount()
    local lastTrainid = 0
    
    for var = 0, count - 1 do
        local key = trainCsv:lineData(var, 0)
        if lastTrainid < key then
            lastTrainid = key
        end
    end
    
    gData.userInfo.roleInfo:UpDataTraining(lastTrainid)    --.training = self.trainInfo.id 
    local aParam = {}
    aParam.training_id = lastTrainid
    
    gTrain = false
    gReq:MsgReqTrainingComplete(nil, nil, aParam)
    cclog("跳过新手引导")
    gWindow:showTip("跳过新手引导", 1);
end

function VDataManager:CloseTrainning(VIEW)
    self.actionOver = true
    self.steptrainning = false
    if gMainView then
        gMainView.manorView:SetMove(true)
    end
    
    if VIEW == "TRAINLAYER" then
        if gMainView then
--            gMainView.manorView:SetMove(true)
            cclog("RunNextTrainning删除")
            local trainingLayer = gView()("trainingLayer")
            if trainingLayer then
                trainingLayer:Delete()
            end
        end
    end
end

function VDataManager:RunTrainning(trainid, VIEW)   
--    local tableName, btName, itemName, cellNum = self:TrainInfoBtNameFormat("tbPlantBag;imgBackGroundBagC;lyrBagCell1;1")
--    cclog("tableName, btName, pos"..tableName.."~~~~~~~~~"..btName.."~~~~~~~~~"..(itemName or "没有itemName").."~~~~~~~~~"..cellNum)
    if gData.userInfo.roleInfo.initTrain then
        -- cclog("initTrain为true"..gData.userInfo.roleInfo.training)
    else
        -- cclog("initTrain为false"..gData.userInfo.roleInfo.training)
    end
    
    cclog("判断是否进入新手引导了")
    
    if not gMainView then
        cclog("无农场")
        return false
    end
    
    local trainingLayer = gView()("trainingLayer")
    
    if VIEW ~= "TRAINLAYER" and trainingLayer ~= nil then
        return false
    end
    
    if VIEW == "TRAINLAYER" then
        cclog("TRAINLAYER设置self.actionOver为true")
        self.actionOver = true
    end
    
    if not gTrain or
    (gMainView:hasMsgBox() and VIEW ~= "TRAINLAYER" and VIEW ~= "BASECAMP") or
    (gMainView.activityDlg and gMainView.activityDlg.visible and VIEW ~= "TRAINLAYER") then
        cclog("你干的好事~~~~~~~~调用者"..(VIEW or "MAIN"))
        self:CloseTrainning(VIEW)
        return false
    end 
    
    local ChatView = gView()("ChatView")
    if ChatView and ChatView.isOpen then
        ChatView:openChatView()
    end
    
    cclog("trainid~~~~~~~~"..(trainid or -1))
    local trainCsv = self:LoadTraining()
    local key = 1
    if trainid then
        key = trainid + 1
    else
        key = (gData.userInfo.roleInfo.training or 0) + 1
    end
    local trainInfo = trainCsv:lineDataWithKey(key)
    

    if trainInfo == nil then
        cclog("没有新手任务了")
        self:CloseTrainning(VIEW)
        return false
    end
    
    cclog("RunTrainning设置场景信息了:"..trainInfo.btName.."~~~~~~~~~~~~~~"..trainInfo.retiveArea)
    
    if trainid ~= nil then
        if trainid ~= trainInfo.limitid then
            cclog("前置任务未完成"..trainid.."~~~~~~~~~~"..trainInfo.limitid)
            self:CloseTrainning(VIEW)
            return false
        end
    end
    
    if self.action ~= nil then
        cclog("self.action条件为false")
    end
    
    if not self.actionOver then
        cclog("self.actionOver条件为false")
    end
    
    if trainInfo.x ~= -1 or trainInfo.btName ~= -1 then
        if self.action == nil and self.actionOver then
            self.actionOver = false
            self.action = gDtr:getScheduler():scheduleScriptFunc( 
                function () VCallBack(gData, "StartTrainning", trainid, VIEW, trainInfo); end, 1, false);
            
        end
    elseif self.actionOver then
        self:StartTrainning(trainid, VIEW, trainInfo)
    end
end

function VDataManager:StartTrainning(trainid, VIEW, trainInfo, isSecond)
    cclog("StartTrainning调用成功")
    if self.action then
        gDtr:getScheduler():unscheduleScriptEntry(self.action)
        self.action = nil;
    end
    
    if not gMainView or
        (gMainView:hasMsgBox() and VIEW ~= "TRAINLAYER" and VIEW ~= "BASECAMP") then
        cclog("非TRAINLAYER或BASECAMP状态下有MessageBox")
        self:CloseTrainning(VIEW)
        return false
    end
    
    if not self:CheckViewLimit() then
        cclog("ViewLimit条件不满足")
        self:CloseTrainning(VIEW)
        return false
    end   

    local otherLimit = true

    if trainInfo.otherLimit ~= "" then
        otherLimit = self:CheckOrtherLimit(trainInfo, VIEW)
    end

    local nodeLimit = self:CheckTrainningNode(trainInfo)
    
    if not nodeLimit and  not self.steptrainning then
        self.action = gDtr:getScheduler():scheduleScriptFunc( 
            function () VCallBack(gData, "StartTrainning", trainid, VIEW, trainInfo, true); end, 1, false);
        cclog("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
        self.steptrainning = true
        return true
    elseif not nodeLimit and self.steptrainning and isSecond then
        self:CloseTrainning(VIEW)
        self:StepAllTrainning()
        return false
    end
    
    if self.steptrainning and not isSecond then
        return true
    end

    local resLimit = self:CheckResLimit(trainInfo)

    if gData.userInfo.manorInfo.baseCampInfo.level >= trainInfo.limitLevel and 
        resLimit and
        otherLimit and
        nodeLimit and
        gMainView then

        local trainingLayer = gView()("trainingLayer")

        if trainingLayer == nil then
            trainingLayer = VNode("vTrainingLayer.vui");
            trainingLayer:SetTrainInfo(trainInfo)
            gView():Push(trainingLayer)
            self.steptrainning = false
--            self.actionOver = true
            cclog("新手任务执行起始"..(trainid or (gData.userInfo.roleInfo.training or 0)).."~~~~~~~~调用者"..(VIEW or "MAIN"))
        elseif VIEW == "TRAINLAYER" then
            trainingLayer:SetTrainInfo(trainInfo)
            trainingLayer:SetTrainingScene()
            self.steptrainning = false
--            self.actionOver = true
            cclog("新手任务执行了:"..(trainid or (gData.userInfo.roleInfo.training or 0)).."~~~~~~~~调用者"..(VIEW or "MAIN"))
        else
            cclog("新手正在执行中"..(trainid or (gData.userInfo.roleInfo.training or 0)).."~~~~~~~~调用者"..(VIEW or "MAIN"))
        end

        return true
    end

    cclog("庄园等级未达到"..gData.userInfo.manorInfo.baseCampInfo.level.."~~~~~~~~~"..trainInfo.limitLevel)
    
    self:CloseTrainning(VIEW)
    return false
end

function VDataManager:CheckResLimit(trainInfo)
	local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
    local cion = gData:attrValue(AttrType.AttrTypeMoney)
    local rankPoint = gData:attrValue(AttrType.AttrTypeRankPoint)
    
    if trainInfo.limitRes1 == 1 then
        return sunShine >= trainInfo.resCount1 
    elseif trainInfo.limitRes1 == 2 then
        return cion >= trainInfo.resCount1 
    elseif trainInfo.limitRes1 == 3 then
        return rankPoint >= trainInfo.resCount1 
    end
    
    if trainInfo.limitRes2 == 1 then
        return sunShine >= trainInfo.resCount2 
    elseif trainInfo.limitRes2 == 2 then
        return cion >= trainInfo.resCount2 
    elseif trainInfo.limitRes2 == 3 then
        return rankPoint >= trainInfo.resCount2 
    end
    
    return true
end

function VDataManager:CheckTrainningNode(trainInfo)
    cclog("VDataManager设置场景信息了:"..trainInfo.btName.."~~~~~~~~~~~~~~"..trainInfo.retiveArea)
    if trainInfo.x == -1 and trainInfo.btName == -1 then
        return true
    else
        if trainInfo.x ~= -1 then
            if trainInfo.retiveArea ~= "" then
                cclog("~~~trainInfo.retiveArea:"..trainInfo.retiveArea)
                local node = gView()(trainInfo.retiveArea)
                if not node then
                    cclog("~~~trainInfo.retiveArea:"..trainInfo.retiveArea.."返回false")
                    return false
                end
            end
            cclog("~~~trainInfo.retiveArea:"..trainInfo.retiveArea.."返回true")
            return true
        else         
--            local bt = gView()(trainInfo.btName)
            
            local tableName, btName, itemName, cellNum = self:TrainInfoBtNameFormat(trainInfo.btName)
            local bt = nil

              if tableName ~= nil then
--                local num = string.sub(trainInfo.btName, 19, -1)
--                local btName = string.sub(trainInfo.btName, 1, 18)
--                local table = gView()("tabLevelView")
                local table = gView()(tableName)
                if not table then
                    return false
                end
                
                local cell = nil
                
                cell = table:cellAtIndex(cellNum - 1)

                if not cell then
                    return false
                end
                
                if itemName == nil then
                    bt = cell(btName)
                else
                    bt = cell(itemName)(btName)
                end

            else
                bt = gView()(trainInfo.btName)
            end
            if not bt then
                cclog("~~~trainInfo.retiveArea:"..trainInfo.btName.."返回false")
                return false
            end
            cclog("~~~trainInfo.retiveArea:"..trainInfo.btName.."返回true")
            return true
        end
    end
end

function VDataManager:TrainInfoBtNameFormat(btName)
    local str = btName
    local pos = string.find(str, ";")
    local tableName = nil
    local btName = nil
    local itemName = nil
    local cellNum = nil
    if pos then
        tableName = string.sub(str, 1, pos - 1)
        str = string.sub(str, pos + 1, -1)
        pos = string.find(str, ";")
        btName = string.sub(str, 1, pos - 1)
        str = string.sub(str, pos + 1, -1)
        pos = string.find(str, ";")
        if pos then
            itemName = string.sub(str, 1, pos - 1)
            cellNum = string.sub(str, pos + 1, -1)
        else
            cellNum = str
        end
    end
    
    return tableName, btName, itemName, cellNum
end

function VDataManager:CheckOrtherLimit(trainInfo, VIEW)
    
	if trainInfo == nil then
	    return false
	end
	
	if trainInfo.otherLimit == 1 then
        local farmInfos = gData.userInfo.manorInfo.farmInfos["13"]
        if farmInfos ~= nil then
            return false
        end
        cclog("~~~~~~~~~~~~~~~~条件一")
    elseif trainInfo.otherLimit == 2 then
        local farmInfos = gData.userInfo.manorInfo.farmInfos["23"]
        if farmInfos ~= nil then
            return false
        end
        cclog("~~~~~~~~~~~~~~~~条件二")
    elseif trainInfo.otherLimit == 3 then
--        local 
    elseif trainInfo.otherLimit == 4 then
        cclog("~~~~~~~~~~~~~~~~条件4"..(VIEW or "MAIN"))
       if VIEW ~= "BASECAMP" then
           return false
       end
    elseif trainInfo.otherLimit == 5 then
        local farmInfos = gData.userInfo.manorInfo.farmInfos["13"]
        if farmInfos == nil then
            return false
        end
        cclog("~~~~~~~~~~~~~~~~条件5")
    elseif trainInfo.otherLimit == 6 then
        local farmInfos = gData.userInfo.manorInfo.farmInfos["23"]
        if farmInfos == nil then
            return false
        end
        cclog("~~~~~~~~~~~~~~~~条件6")
    elseif trainInfo.otherLimit == 7 then
        local farmInfos = gData.userInfo.manorInfo.farmInfos["33"]
        if farmInfos ~= nil then
            return false
        end
        cclog("~~~~~~~~~~~~~~~~条件7")
    elseif trainInfo.otherLimit == 8 then
        local farmInfos = gData.userInfo.manorInfo.farmInfos["33"]
        if farmInfos == nil then
            return false
        end
        cclog("~~~~~~~~~~~~~~~~条件8")
    elseif trainInfo.otherLimit == 9 then
        if not gData.userInfo.roleInfo.actInfo or (gData.userInfo.roleInfo.actInfo.id or -1) <= 1 then
            return false
        end
    elseif trainInfo.otherLimit == 10 then
        if not gData.userInfo.roleInfo.actInfo or (gData.userInfo.roleInfo.actInfo.id or -1) <= 2 then
            return false
        end
    elseif trainInfo.otherLimit == 11 then
        if not gData.userInfo.roleInfo.actInfo or (gData.userInfo.roleInfo.actInfo.id or -1) <= 3 then
            return false
        end
    elseif trainInfo.otherLimit == 12 then
--        cclog("寻找达到任务1101领奖条件")
--        local questLive = false
--        
--        for i,v in pairs(gData.userInfo.questInfos.questInfos) do
--            if v.questid == 1101 and v.state == 2 then
--                questLive = true
--            end
--        end
--        
--        if not questLive then
--            return false
--        end
        if gData:attrValue(AttrType.AttrTypeLevel) < 3 then
            return false
        end
	end
    cclog("CheckOrtherLimit返回成功")
    return true
end

function VDataManager:CheckViewLimit(trainInfo, VIEW)
    if VIEW == "RSPPLANT" then
        if trainInfo.otherLimit == 2 or
        trainInfo.otherLimit == 6 or 
        trainInfo.otherLimit == 8
        then
            return true
        else
            return false
        end
    elseif VIEW == "BASECAMP" then
        if trainInfo.otherLimit == 4 then
            cclog("BASECAMP调用返回成功")
            return true
        else
            return false
        end
    end
    
    return true
end

---------------------------------------------------------------------
-- 获取当前背包使用的格子数
---------------------------------------------------------------------
function VDataManager:GetBagUsedCount(parameters)
    local count = gData.userInfo.plantInfos:PlantCount()
    count = count + gData.userInfo.suitInfo:GetSuitCount()
    count = count + gData.userInfo.bagInfos:itemCount()
    cclog("当前背包使用的格子数:"..count)
    return count
end


---------------------------------------------------------------------
-- GetShopRefreshCost
---------------------------------------------------------------------
function VDataManager:GetShopRefreshCost(parameters)
    local refreshCsv = gData:readCsv("shop_refresh.csv");
    local cost = 0
    local count = refreshCsv:lineCount()
    local hasRefresh = gData.userInfo.roleInfo.dayInfo.shop_refresh_times
    for var = 0, count - 1 do
    	local lineData = refreshCsv:lineData(var);
    	if hasRefresh < lineData[0] then
    	    cost = lineData[1]
    	    break
    	end
    end
    
    return cost
end



---------------------------------------------------------------------
-- BriefUserInfo
---------------------------------------------------------------------
function VDataManager:AddCustomInfo()
    local customInfo = VBriefUserInfo:new()
    customInfo.userid = 10000;
    customInfo.image = "morentouxiang.png";
    customInfo.nick = "客服";
    customInfo.sex = 1;
    customInfo.level = 99;
    customInfo.vipInfo = {};
    customInfo.vipInfo[0] = 0;

    local customInfo1 = VBriefUserInfo:new()
    customInfo1.userid = 1;
    customInfo1.image = "morentouxiang.png";
    customInfo1.nick = "世界聊天";

    local customInfo2 = VBriefUserInfo:new()
    customInfo2.userid = 2;
    customInfo2.image = "morentouxiang.png";
    customInfo2.nick = "好友列表";

    self:addBriefUserInfo(customInfo1)
    self:addBriefUserInfo(customInfo2)
    self:addBriefUserInfo(customInfo)
end

--向用户摘要信息里面添加一条数据
function VDataManager:addBriefUserInfo(briefInfo)
	self.userBriefCache[briefInfo.userid] = briefInfo;
end

--读取用户摘要信息
function VDataManager:briefCache(userid)
	return self.userBriefCache[userid];
end

--请求用户摘要信息
function VDataManager:checkUserReqList(delegate, callBack)
	local count = #self.userReq;
	if count ~= 0 then
		local reqList = {}
		for i=1,10 do
			if self.userReq[1] then
				table.insert(reqList, table.remove(self.userReq, 1));
			else
				break;
			end
		end
		self:requestUserBrief(reqList, delegate, callBack);
	else
		VCallBack(delegate, callBack);
	end
end

--请求用户摘要信息接口。
--@userids：待请求的用户ID列表
function VDataManager:userBriefInfo(userids, delegate, callBack)
	if not userids then return end;
	self.userReq = {};
	local checkList = {};
	for i,v in ipairs(userids) do
		local userInfo = self.userBriefCache[v];
		if not userInfo and not checkList[v] then
			table.insert(self.userReq, v);
			checkList[v] = true;
		end
	end
	self:checkUserReqList(delegate, callBack);
end

function VDataManager:userBriefBattleInfo(delegate, callBack, userids, ...)
    if not userids or #userids == 0 then
        return
    end;
    local aParam = {}
    aParam.userids = userids;
    aParam.userDelegate = delegate;
    aParam.userCallBack = callBack;
    aParam.param = {...}
    gReq:MsgReqBriefUserBattleInfoQuery(self, "RspBriefUserBattleInfoQuery", aParam)
end

function VDataManager:RspBriefUserBattleInfoQuery(result, rsp, req)
    local userBattleInfos = {}
    
    if rsp and rsp.infos then
        local count = rsp.infos:Count()
        for var = 0, count - 1 do
            local info = rsp.infos[var]
            local bubi = VBriefUserBattleInfo:new();
            bubi:synWithPbData(info);
            userBattleInfos[info.id] = bubi;
        end
    end
    
    VCallBack(req.pamram.userDelegate, req.pamram.userCallBack, userBattleInfos, unpack(req.pamram.param));
end

function VDataManager:requestUserBrief(userids, delegate, callBack)
	local aParam = {}
	aParam.userids = userids;
	aParam.userDelegate = delegate;
	aParam.userCallBack = callBack;
	gReq:MsgReqBriefUserInfoQuery(self, "userBriefCallBack", aParam);
end

function VDataManager:userBriefCallBack(result, aMsgRspUserDataSyn, req)
	if result == 0 then

	end
	self:checkUserReqList(req.userDelegate, req.userCallBack);
end

---------------------------------------------------------------------
-- Friend Check
---------------------------------------------------------------------
function VDataManager:isMyFriend(userid)
	local friendManager = self.userInfo.friendInfos;
	return friendManager:isFriend(userid);
end

function VDataManager:addFriend(userid, delegate, callBack)
	if self:isMyFriend(userid) then
		VCallBack(delegate, callBack, 0);
	else
        if gData.userInfo.friendInfos:friendCount() < gData.userInfo.friendInfos.friendLimit then
           
        else
            gWindow:showTip("好友已达到上限,无法添加")
            return
        end

		local aParam = {};
		aParam.userid = userid;
		aParam.friendDelegate = delegate;
		aParam.friendCallback = callBack;
		gReq:MsgReqFriendAdd(self, "addFriendCallback", aParam);
	end
end

function VDataManager:addFriendCallback(result, rsp, req)
	local friendManager = self.userInfo.friendInfos;
	if result == 0 then
		friendManager:AddFriend(req.userid);

        gWindow:showNormalTip("添加好友成功", "")
	else
		-- friendManager:DelFriend(req.userid);
	end
	local delegate = req.friendDelegate;
	local callBack = req.friendCallback;
	VCallBack(delegate, callBack, result, rsp, req);
end

function VDataManager:deleteFirend(userid, delegate, callBack)
	if self:isMyFriend(userid) then
		local aParam = {};
		aParam.userid = userid;
		aParam.friendDelegate = delegate;
		aParam.friendCallback = callBack;
		gReq:MsgReqFriendDel(self, "delFriendCallback", aParam);
	else
		VCallBack(delegate, callBack, 0);
	end
end

function VDataManager:delFriendCallback(result, rsp, req)
	local friendManager = self.userInfo.friendInfos;
	if result == 0 then
		friendManager:DelFriend(req.userid);
	else
		-- friendManager:AddFriend(req.userid);
	end
	local delegate = req.friendDelegate;
	local callBack = req.friendCallback;
	VCallBack(delegate, callBack, result, rsp, req);
end

---------------------------------------------------------------------
-- Item Info search
---------------------------------------------------------------------
function VDataManager:itemInfo(itemId)
	local itemCsv = self:readCsv("prop_item.csv");
	local itemInfo = itemCsv:lineDataWithKey(itemId);
	return itemInfo;
end

---------------------------------------------------------------------
-- random user nick
---------------------------------------------------------------------
function VDataManager:randomNick()
	local nameCsv = self:readCsv("name.csv");
	local count = nameCsv:lineCount();

	local random = math.random(0, count-1);
	local nameInfo = nameCsv:lineData(random);
	local nameString = nameInfo[1];

	local preOrSuff = 0;
	random = math.random(1, 100);
	if random > 60 then
		preOrSuff = 2;
	end

	random = math.random(0, count-1);
	nameInfo = nameCsv:lineData(random);
	if preOrSuff == 0 then
		nameString = nameInfo[preOrSuff]..nameString;
	elseif preOrSuff == 2 then
		nameString = nameString..nameInfo[preOrSuff];
	end

	return nameString;
end

---------------------------------------------------------------------
-- user head image
---------------------------------------------------------------------
function VDataManager:headImage(userid, imageid, h)
    if not imageid or imageid == 0 then
        local info = nil

        if userid == gData.userInfo.userid then
            info = gData.userInfo.roleInfo
        else
            info = self.userBriefCache[userid]
        end


        if info then
            if info.sex ~= 2 then
                return "mourentouxiangW.png"
            else
                return "mourentouxiangM.png"
            end
        end

        return "mourentouxiangW.png";
	end
    if userid == gGameMasterId then
        return "kefutubiao.png";
    end
	if userid == 1 then
        return "shijiepindaotubiao.png";
	end
    if userid == 2 then
        return "haoyouliebiaotu.png";
    end
	local postData = Var();
	postData:AppendNumber(imageid, 4);
	postData:AppendNumber(userid, 4);
	postData:ToUint64();
	if h then
		return postData:String().."_h.png";
	end
	return postData:String()..".png";
end

---------------------------------------------------------------------
-- user attr value
---------------------------------------------------------------------
function VDataManager:attrValue(attrType)
	return gData.userInfo.roleInfo:attrValue(attrType);
end

---------------------------------------------------------------------
-- micrometer formatte
---------------------------------------------------------------------
function VDataManager:fmtMicrometer(amount)
	local formatted = tostring(math.floor(amount));
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d%d)", '%1,%2');
		if k == 0 then
			break;
		end
	end
	return formatted;
end

---------------------------------------------------------------------
-- brief battle log
---------------------------------------------------------------------
function VDataManager:checkDefendBattleBriefLog(maxid, isFrist, count)
    local number = count or 30;
	local aParam = {};
	aParam.isFrist = isFrist;
	gReq:MsgReqStaticUserDataQuery(self, "defendBattleBriefLogCallBack", maxid, 
		StaticUserDataType.StaticUserDataTypeBfiefBattleLog, number, aParam);
end

function VDataManager:defendBattleBriefLogCallBack(result, rsp, req)
	local isFrist = nil;
	if req.aParam then
		isFrist = req.aParam.isFrist;
	end
	if result == 0 then
		if rsp and rsp.brief_battle_logs then
			local lastLogId = rsp.last_battle_log;
			self.battleBriefLogs.isFrist = isFrist;
			self.battleBriefLogs:addLogs(rsp.brief_battle_logs, _VLogType.all, lastLogId, true);
			if gMainView then
				gMainView:newBattleLogsComeIn();
			end
		end
	else

	end
end

---------------------------------------------------------------------
-- monster csv 
---------------------------------------------------------------------
function VDataManager:monsterInfoFinder(mLevel, mType, mQuality)
	local monsterCsv = self:readCsv("prop_monster.csv");
	local monster = monsterCsv:linesWithKeyRowValues(mLevel, mType, mQuality);
	return monster;
end

---------------------------------------------------------------------
-- plant csv 
---------------------------------------------------------------------
function VDataManager:plantInfoFinder(mLevel, mType, mQuality)
	local plantCsv = self:readCsv("prop_plant.csv");
	local plant = plantCsv:linesWithKeyRowValues(mLevel, mType, mQuality);
	return plant;
end

---------------------------------------------------------------------
-- user syn flag
---------------------------------------------------------------------
function VDataManager:enableStopUserSyn(enable)
	self.stopUserSynFlag = enable;
end

---------------------------------------------------------------------
-- heart beat
---------------------------------------------------------------------
function VDataManager:loadHeartBeatVer()
	local var = Var();
	local fileName = addUserPath("logVer.log");
	var:FromFile(fileName, false, false, _VPath.Public);
	self.notifyVer = var.notifyVer or 0;
	self.maxRealLogId = var.maxRealLogId or "0";
	self.maxMsgId = var.maxMsgId or "0";
	self.maxBattleId = var.maxBattleId or "0";
end

function VDataManager:saveHeartBeatVer()
	local var = {}
	var.notifyVer = self.notifyVer;
	var.maxRealLogId = self.maxRealLogId;
	var.maxMsgId = self.maxMsgId;
	var.maxBattleId = self.maxBattleId;
	var = Var(var);
	local fileName = addUserPath("logVer.log");
	var:SaveFile(fileName);
end

function VDataManager:startHeartBeat()
    if gHeartBeatInterval then
        gHeartBeatReqing = nil;
    	self:stopHeartBeat();
    	self.heartBeatHandle = gDtr:getScheduler():scheduleScriptFunc( 
    		function () VCallBack(gData, "heartBeatLoop"); end, gHeartBeatInterval, false);
    end
end

function VDataManager:stopHeartBeat()
	if self.heartBeatHandle then
		gDtr:getScheduler():unscheduleScriptEntry(self.heartBeatHandle)
        self.heartBeatHandle = nil;
	end
end

function VDataManager:heartBeatLoop()
	if not gHeartBeatReqing and not gBattleView then
		gReq:MsgReqHeartbeat(self, "heartBeatCallBack");
	end
end

function VDataManager:heartBeatCallBack(result, rsp, req)
	if result == 0 then
		local current_time = rsp.current_time;
		self.timeDev = current_time - os.time();

		local user_ver = rsp.user_ver;
		if not self.stopUserSynFlag then
			self.userInfo:checkVersion(user_ver, true);
		end

		local needFlush = false;

		-- local notify_ver = rsp.notify_ver;
		-- if notify_ver > self.notifyVer then
		-- 	self:sysNotifiyQuery();
		-- 	self.notifyVer = notify_ver;
		-- 	needFlush = true;
		-- end

		local max_id_real_log = rsp.max_id_real_log;
        if max_id_real_log then
    		if max_id_real_log > self.maxRealLogId then
    			self:realLogQuery(self.maxRealLogId);
    			self.maxRealLogId = max_id_real_log;
    			needFlush = true;
    		end
        end

		local max_id_message = rsp.max_id_message;
        if max_id_real_log then
    		if max_id_message > self.maxMsgId then
    			self:messageLogQuery();
    			self.maxMsgId = max_id_message;
    			needFlush = true;
    		end
        end

		local max_battle_log = rsp.max_battle_log;
		if max_battle_log > self.maxBattleId then
			self:checkDefendBattleBriefLog(0);
			self.maxBattleId = max_battle_log;
			needFlush = true;
		end

		if needFlush then
			self:saveHeartBeatVer();
		end

        --记录在线时间
        self:SaveLastExitTime(current_time);
	end
end

function VDataManager:messageLogQuery()
	gReq:MsgReqStaticUserDataQuery(self, "messageLogCallBack", self.maxMsgId, StaticUserDataType.StaticUserDataTypeMessage, 20);
end

function VDataManager:messageLogCallBack(result, rsp, req)
	if result == 0 and rsp then
		local message_infos = rsp.message_infos;--Is list
		if message_infos then
			local iter = VDataIter();
			while message_infos:Travel(iter) do
				local message = iter:Data();
				self.chatInfo:addMessage(message);
			end
			if gMainView then
				gMainView:newMessageComeIn();
			end
		end
	end
end

-- function VDataManager:sysNotifiyQuery()
-- 	gReq:MsgReqStaticUserDataQuery(self, "sysNotifiyCallBack", self.notifyVer, StaticUserDataType.StaticUserDataTypeNotify, 20);
-- end

-- function VDataManager:sysNotifiyCallBack(result, rsp, req)
-- 	if result == 0 and rsp then
-- 		local notify_infos = rsp.notify_infos;--Is list
-- 		self.notifyInfo:clearAllNotify()
-- 		if notify_infos then
-- 			local chatChange = false;
-- 			local iter = VDataIter();
-- 			while notify_infos:Travel(iter) do
-- 				local notify = iter:Data();
-- 				if notify.type == 1 or notify.type == 2 then
-- 					self.notifyInfo:addNotifyInfo(notify)
-- 				elseif notify.type == 3 then
-- 					self.chatInfo:addMessageNotifier(notify);
-- 					chatChange = true;
-- 				end
-- 			end

-- 			if chatChange then
-- 				if gMainView then
-- 					gMainView:newMessageComeIn();
-- 				end
-- 			end
-- 		end
-- 		if gMainView then
-- 			gMainView:newNotifyInfoComeIn();
-- 		end
-- 	end
-- end


--------服务器主动推送
function VDataManager:ServerNotifyAction( result, rsp )
    -- body
    local infos = rsp.infos;--Is list

    if infos then
        local iter = VDataIter();
        while infos:Travel(iter) do
            local info = iter:Data();
            if info.action == NotifyAction.NotifyActionChat then
                local message = {}
                message.time = gData:currentTime();
                message.from = info.userid;
                message.context = info.param;
                message.id = info.params[0]
                self.chatInfo:addMessage(message);
                self.chatInfo:AddLastMessage(message);
                
                if gMainView then
                    gMainView:newMessageComeIn();
                end
                
            elseif info.action == NotifyAction.NotifyActionGroupBattleEnd then
                self:ActionGroupBattleEnd(info);
            elseif info.action == NotifyAction.NotifyActionGroupBattleChange then
                self:ActionGroupBattleChange(info);
            elseif info.action == NotifyAction.NotifyActionGroupBattleChat then
                self:ActionGroupBattleChat(info);
            elseif info.action == NotifyAction.NotifyActionUserDataChange then
                --差量同步所有的用户数据，ver传负数为保证和当前数据版本不同
                self.userInfo:checkVersion(-1000,false);
            elseif info.action == NotifyAction.NotifyActionWorldChat then
                cclog("NotifyAction.NotifyActionWorldChat")
                local worldChatDlg = gView()("WorldChatDlg")
                
                local message = {}
                message.time = gData:currentTime();
                message.userId = info.userid;
                message.nick = info.nick or info.userid;
                message.msg = info.param;

                if worldChatDlg then
                    
    --                    message.id = info.params[0]
                
                    worldChatDlg:addMessage(message)
                end

                self:WorldChatNotify(message)
                
                if gMainView then
                   gMainView:newMessageComeIn();
                end
            elseif info.action == NotifyAction.NotifyActionGroupBattleAttacked then
                self:NotifyActionGroupBattleAttacked(info);
            elseif info.action == NotifyAction.NotifyActionUserNotify then
                self:NotifyActionUserNotify(info);
            end
        end
    end
end

--用户数据变化通知

--团战结束通知
function VDataManager:ActionGroupBattleEnd( info )
    local battleid = info.params[0];
    self.userInfo.roleInfo.roleBattleInfo:AddNewFinishInfo(battleid);
    local clanWar = gView()("clanWar");
    if clanWar and clanWar.groupBattleInfo and clanWar.groupBattleInfo.id == battleid then
        clanWar:ActionGroupBattleChange();
    end

    local pvpDlg = gView()("pvpOptionDlg");
    if pvpDlg then
        pvpDlg:Synchronism(battleid);
    else
        local param = {};
        param.syn_flag = 1;
        param.data_type = GameDataType.DataTypeRoleInfo;
        gReq:MsgReqUserDataSyn(self, "SynchronismRespone", param);
    end
end

--团战变化通知
function VDataManager:ActionGroupBattleChange( info )
    local clanWar = gView()("clanWar");
    local battleid = info.params[0];
    if clanWar and clanWar.groupBattleInfo and clanWar.groupBattleInfo.id == battleid then
        clanWar:ActionGroupBattleChange();
    end
end

--团战聊天通知
function VDataManager:ActionGroupBattleChat( info )
    local clanWar = gView()("clanWar");
    local battleid = info.params[0];
    if clanWar and clanWar.groupBattleInfo.id == battleid then
        clanWar:ActionGroupBattleChat(info);
    end
end

--被打结束通知
function VDataManager:NotifyActionGroupBattleAttacked(info )
    local logid = info.params[0];
    self:checkDefendBattleBriefLog(0,nil,1);
    self.maxBattleId = logid;
end

--跑马灯通知
function VDataManager:NotifyActionUserNotify( info )
    if not self.notifyInfo then
        self.notifyInfo = VSysNotifyInfo:new();
    end

    local notify = {};
    notify.id = info.params[0];
    notify.type = 0;
    notify.start = tonumber(info.params[1]);
    notify.duration = tonumber(info.params[2]);
    notify.message = tostring(info.param);
    self.notifyInfo:addNotifyInfo(notify);
    if gMainView then
        gMainView:newNotifyInfoComeIn();
    end
end


--世界聊天通知
function VDataManager:WorldChatNotify( info )
    -- body
    if not self.chatNotifyInfo then
        self.chatNotifyInfo = VWorldChatNotifyInfo:new()
    end

    self.chatNotifyInfo:addNotifyInfo(info);
    
    if gMainView then
        -- gMainView:newNotifyInfoComeIn();
        gMainView("lyrWorldChatNotice"):StartShow()
    end
end

function VDataManager:realLogQuery(maxLogId, isFrist)
	local aParam = {};
	aParam.isFrist = isFrist;
	gReq:MsgReqStaticUserDataQuery(self, "realLogQueryCallBack", maxLogId, StaticUserDataType.StaticUserDataTypeRealLog, 20, aParam);
end

function VDataManager:realLogQueryCallBack(result, rsp, req)
	local isFrist = nil;
	if req.aParam then
		isFrist = req.aParam.isFrist;
	end

	if result == 0 and rsp then
		local log_infos = rsp.log_infos;--Is list
		if log_infos then 
			if isFrist then
				self.firstLevelUpInfo = {};
				local iter = VDataIter();
				while log_infos:Travel(iter) do
					local logInfo = iter:Data();
					if logInfo.type == LT.LtLevelup then
						table.insert(self.firstLevelUpInfo, logInfo);
					end
				end
				if gMainView then
					gMainView:newLevelUpInfoComeIn();
				end
			end
--            local iter = VDataIter();
--            while log_infos:Travel(iter) do
--                local logInfo = iter:Data();
--                if isFrist then
--                    self.firstLevelUpInfo = self.firstLevelUpInfo or {};
--                    if logInfo.type == LT.LtLevelup then
--                        table.insert(self.firstLevelUpInfo, logInfo);
--                    end
--                elseif logInfo.type == LT.LtFriendAdd then
----                    self.addFriendNotic = self.addFriendNotic or {};
--                end
--            end
--            
--            if gMainView and isFrist then
--                gMainView:newLevelUpInfoComeIn();
--            end
		end
	end
end


--获取资源名称和图标
--[[
enum type
{
	RES_DATA_TYPE_ATTR = 1;	//属性//看下面的属性定义
	RES_DATA_TYPE_ITEM = 2;	//物品//从prop_item找
	RES_DATA_TYPE_SUIT = 3; //套装//从prop_suit找
	RES_DATA_TYPE_PLANT = 4; //植物//从prop_plant找
	RES_DATA_TYPE_ARM = 5;	//士兵//从prop_creature_monster.csv找
}
用户属性定义：
{
	ATTR_TYPE_EXP = 2;		//玩家经验	
	ATTR_TYPE_LEVEL = 6;		//玩家等级
	ATTR_TYPE_CURRENCY = 7;		//元宝	
	ATTR_TYPE_MONEY = 20;		//金币	
	ATTR_TYPE_SUNSHINE = 21;	//阳光
}
]]

function VDataManager:getResoureIconByID(type, id)
	if type and id then
		if type == RES_DATA_TYPE.ResDataTypeAttr then
			if id == AttrType.AttrTypeExp then
				return "icon_jinbi.png","经验";
			elseif id == AttrType.AttrTypeLevel then
				return "icon_jinbi.png","等级";
			elseif id == AttrType.AttrTypeCurrency then
                cclog("getResoureIconByID")
                return "icon_zuanshi.png","钻石";
			elseif id == AttrType.AttrTypeMoney then
                return "icon_yibi.png","银币";
			elseif id == AttrType.AttrTypeSunshine then
                return "icon_jinbi.png","金币";
			elseif id == AttrType.AttrTypeRankPoint then
			elseif id == AttrType.AttrTypeStamina then
			elseif id == AttrType.AttrTypeCharge then
			elseif id == AttrType.AttrTypeBattleScore then
                return "icon_jifen.png","战功";
			elseif id == AttrType.AttrTypeRouletteTimes then
			end
		elseif type == RES_DATA_TYPE.ResDataTypeItem then
			-- local csvData = gData:readCsv("prop_item.csv");
			-- local lineData = csvData:lineDataWithKey(id);

			local csvData = gData:LoadItemCsv()

    local lineData = csvData[""..id]
			
            
            if lineData then 
                return lineData.image,lineData.name,lineData.quality,lineData;
            end
        elseif type == RES_DATA_TYPE.ResDataTypePlant then
            -- local csvData = gData:readCsv("prop_plant.csv");
            -- local lineData = csvData:lineDataWithKey(id);

            local csvData = gData:LoadPlantBaseCsv()

        local lineData = csvData[""..id]

            if lineData then
                -- local descCsv = gData:readCsv("prop_plant_type.csv");
                -- local desc = descCsv:linesWithKeyRowValues(lineData.classType, lineData.quality);

                local descCsv = gData:LoadPlantDescritionCsv()

    local desc = descCsv[lineData.classType..lineData.quality]

                if not desc then 
                    return "", "";
                end
                
                return desc.image.."S.png",desc.name,desc.quality, desc, lineData;
            else
                return "", "";
            end
        elseif type == RES_DATA_TYPE.ResDataTypeArm then
            -- local csvData = gData:readCsv("prop_monster.csv");
            -- local lineData = csvData:lineDataWithKey(id);

            local csvData = gData:LoadMonsterBaseCsv()

    local lineData = csvData[""..id]

            if lineData then
                -- local descCsv = gData:readCsv("prop_monster_type.csv");
                -- local desc = descCsv:linesWithKeyRowValues(lineData.monsterClass, lineData.quality);

                local descCsv = gData:LoadMonsterDescritionCsv()

    local desc = descCsv[lineData.monsterClass..lineData.quality]

                if not desc then 
                    return "", "";
                end
                
                return desc.image.."L.png",desc.name,desc.quality, desc, lineData;
            else
                return "", "";
            end
		elseif type == RES_DATA_TYPE.ResDataTypeVipLevel then
		elseif type == RES_DATA_TYPE.ResDataTypeCurrencyCost then
		end
	end

	return "",""
end


-- 读取植物基础配置数据
function VDataManager:getBriefPlantCsvData( propId )
	local plantProp = {};
	local plantCsv = gData:readCsv("prop_plant.csv");
	local plantData = plantCsv:lineDataWithKey(propId);
	
	if plantData then
		plantProp.id = propId;
		plantProp.level = plantData.level;
		plantProp.classType = plantData.classType;
		plantProp.quality = plantData.quality;
		
		local plantTypeCsv = gData:readCsv("prop_plant_type.csv");
		local plantTypeData = plantTypeCsv:linesWithKeyRowValues(plantProp.classType, plantProp.quality);
		
		if plantTypeData then
			plantProp.name = plantTypeData.name;
			plantProp.image = plantTypeData.image;
		else
			return nil;
		end
		
		local plantBattleCsv = gData:readCsv("prop_creature_plant.csv");
		local plantBattleData = plantBattleCsv:lineDataWithKey(plantProp.id);
		
		if plantBattleData then
			plantProp.cost = plantBattleData["consume"];
			return plantProp;
		else
			return nil;
		end
	else
		return nil;
	end
end

-- 读取怪物基础配置数据
function VDataManager:getBriefMonsterCsvData( propId )
	local monsterProp = {};
	local monsterCsv = gData:readCsv("prop_monster.csv");
	local monsterData = monsterCsv:lineDataWithKey(propId);

	if monsterData then
		monsterProp.id = propId;
		monsterProp.level = monsterData.level;
		monsterProp.classType = monsterData.monsterClass;
		monsterProp.quality = monsterData.quality;

		local monsterTypeCsv = gData:readCsv("prop_monster_type.csv");
		local monsterTypeData = monsterTypeCsv:linesWithKeyRowValues(monsterProp.classType, monsterProp.quality);

		if monsterTypeData then
			monsterProp.name = monsterTypeData.name;
			monsterProp.image = monsterTypeData.image;
		else
			return nil;
		end

		local monsterCsv = gData:readCsv("prop_creature_monster.csv");
		local monsterBattleData = monsterCsv:lineDataWithKey(monsterProp.id);

		if monsterBattleData then
			monsterProp.cost = monsterBattleData["consume"];
		else
			return nil;
		end

		return monsterProp;
	else
		return nil;
	end
end

function VDataManager:getBriefMonsterPropWithMonsterInfo( monsterInfo )
    local monsterProp = {};
    monsterProp.id = monsterInfo.thingid;
    monsterProp.level = monsterInfo.level;
    monsterProp.classType = monsterInfo.monsterClass;
    monsterProp.quality = monsterInfo.quality;
    monsterProp.name = monsterInfo.name;
    monsterProp.image = monsterInfo.image;
    return monsterProp;
end

-- 读取生物徽章图标
function VDataManager:getCreatureInsigniaImageName( currentPoint, classType, quality, isPlant )
	if not currentPoint then
		local plantString = "不是植物";
		if isPlant then
			plantString = "是植物";
		end
		local msg = "currentPoint = nil, classType = "..classType.. ",  quality = "..quality..",  isPlant = "..plantString;
		gWindow:showConfirmTip(msg, "", nil, nil, nil, nil, "读取生物徽章图标方法异常");

		currentPoint = 0;
	end

	local maxValue =0;
	if isPlant then
		local plant_pbCsv = gData:readCsv("plant_strengthen.csv");
		local pbInfo = plant_pbCsv:linesWithKeyRowValues(classType, quality);
		maxValue = pbInfo.maxHp + pbInfo.maxDef + pbInfo.maxAtk + pbInfo.maxAspd;
	else
		local monster_pbCsv = gData:readCsv("suit_attrlimit.csv");
		local pbInfo = monster_pbCsv:linesWithKeyRowValues(classType, quality);
		maxValue = pbInfo.maxHp + pbInfo.maxDef + pbInfo.maxAtc + pbInfo.maxSpeed;
	end

	local percent = (currentPoint / maxValue) * 100;
	local rank_Csv = gData:readCsv("image_creature_rank.csv");
	local rankInfo = rank_Csv:allData();
	local imageName = "";
	for i,v in ipairs(rankInfo) do 
		if quality == v[0] then
			if percent >= v[1]then
				imageName = v[2];
			else
				break;
			end
		end
	end
	return imageName;
end


--计算加速时间需要的钻石
function VDataManager:getTimeAccelerateCost(aType, leftTime, maxTime)

	local line = self:LoadItemCommon();
	local f = 0;
	if aType == LEVELUP_TYPE.LevelupPlant then
		f = line.plantSpe;
	elseif aType == LEVELUP_TYPE.LevelupBuilding then
		f = line.buildSpe;
	elseif aType == LEVELUP_TYPE.LevelupMonster then
		f = line.monsterSpe;
	elseif aType == 100 then
		f = line.eggSpe;
	else
		cclog("类型错误！");
	end
	local p1 = line.diamondRatio1/1000;
	local p2 = line.diamondRatio2/1000;
	return math.ceil(leftTime/(math.pow(maxTime,p1)*p2)*f);
end

--根据品质获取名字颜色
function VDataManager:getNameColorByQuality(quality)
	if quality == 1 then
        return {255,255,255};
    elseif quality == 2 then
        return {90,255,0};
    elseif quality == 3 then
        return {0,246,255};
    elseif quality == 4 then
        return {216,99,255};
    elseif quality == 5 then
        return {255,255,0};
    else
    	return {255,255,255};
    end
end

--根据怪物类型和品质获取基因图标
function VDataManager:getMonsterSuitImage(mType, quality)
	if mType == 1 then
		return "SuitBasicZombie"..quality..".png";
	elseif mType == 2 then
		return "SuitDiggerZombie"..quality..".png";
	elseif mType == 3 then
		return "SuitBoomZombie"..quality..".png";
	elseif mType == 4 then
		return "SuitZombieYeti"..quality..".png";
	elseif mType == 5 then
		return "SuitDancingZombie"..quality..".png";
	elseif mType == 6 then
		return "SuitFlagZombie"..quality..".png";
	elseif mType == 7 then
		return "SuitGargantuar"..quality..".png";
	end
end

---------------------------------------------------------------------
-- AudioEngine
---------------------------------------------------------------------
function VDataManager:loadConfig()
	local var = Var();
	local fileName ="config.config";
	var:FromFile(fileName, false, false, _VPath.Public);
	gAudio:setMusicOff(var.musicOff);
	gAudio:setEffectOff(var.effectOff);
end

function VDataManager:saveConfig()
	local var = {}
	var.musicOff = gAudio.musicOff;
	var.effectOff = gAudio.effectOff;
	var = Var(var);
	local fileName = "config.config";
	var:SaveFile(fileName);
end

--保存本次最后在线的时间
function VDataManager:SaveLastExitTime( time )
    local var = Var();
    var.lastExitTime = time;
    local fileName = gZoneid.."/"..gData.userInfo.userid.."/".."user.dat";
    var:SaveFile(fileName);
end
--读取上次离线信息
function VDataManager:LoadLastExitTime(  )
    local var = Var();
    local fileName = gZoneid.."/"..gData.userInfo.userid.."/".."user.dat";
    var:FromFile(fileName, false, false, _VPath.Public);
    return var.lastExitTime or 0;
end

--添加看过的活动
function VDataManager:addReadEvents(id)
    if not self.readEvents then
       self.readEvents = self:loadReadEvents();
    end
    table.insert(self.readEvents, id);
    self:saveReadEvents();
end

--保存看过的活动
function VDataManager:saveReadEvents()
    if self.readEvents then
        local var = Var();
        for i,v in ipairs(self.readEvents)do
            var[tostring(i)] = v;
        end
        local fileName = gZoneid.."/"..gData.userInfo.userid.."/".."event.dat";
        var:SaveFile(fileName);
    end
end

--读取所有看过的活动
function VDataManager:loadReadEvents()
    local var = Var();
    local fileName = gZoneid.."/"..gData.userInfo.userid.."/".."event.dat";
    var:FromFile(fileName, false, false, _VPath.Public);
    local list = {};
    local i = 0;
    while(var[tostring(i)])
    do
        table.insert(list, var[tostring(i)])
        i = i+1;
    end
    return list;
end

function VDataManager:isReadEvent(id)
    local isRead = false;
    if not self.readEvents then
        self.readEvents = self:loadReadEvents();
    end
    for i=1, #self.readEvents do
        if self.readEvents[i] == id then
            isRead = true;
            break;
        end
    end
    return isRead;
end

--将时间(秒)按照格式转换为字符串
function VDataManager:transformTimeToString(time)
    local day = math.modf(time/86400);
    local hour = math.modf(time/3600);
    local min = math.modf(time/60);
    if day > 0 then
        local h1 = time%86400;
        local s = string.format("%02d天%02d小时",day,h1%3600);
        return s;
    elseif hour > 0 then
        local m1 = time%3600;
        local s = string.format("%02d小时%02d分",hour,m1%60);
        return s;
    else
        local sec = time%60;
        local s = string.format("%02d分%02d秒",min,sec);
        return s;
    end
end


--获取第二天的更新时刻
--return int curtime
function VDataManager:GetNextDayTime()
    local curTime = self:currentTime();
    local GMT8_SECONDS = (60 * 60 * 8);
    local A_DAY_SECONDS = (60 * 60 * 24);
    local FIVE_HOUR_SECONDS = (60 * 60 * 5);
    local nTodaySeconds = (curTime + GMT8_SECONDS) % A_DAY_SECONDS;
    if nTodaySeconds < FIVE_HOUR_SECONDS then
        return curTime + FIVE_HOUR_SECONDS - nTodaySeconds;
    else
        return curTime + A_DAY_SECONDS - nTodaySeconds + FIVE_HOUR_SECONDS;
    end
end


------发送求援信息   参数说明: id:战场id, userid:对方id, battleType: 主攻:1, 主防:2, 助攻:3, 助防:4
function VDataManager:SetHelpMsg(id, userid, battleType)
    if not gData.userInfo.roleInfo:isFunctionOpen(GameFunction.sys_chat_speak) then
        gWindow:showTip("该功能暂未开放！",1);
        return;
    end
    
    if not battleType then
        cclog("消息发送失败, 求援发送者角色身份未知")
        return 
    end
    
    local info = self.userBriefCache[userid]
    

    local context = "SetHelpMsg"..(id or " ").."~"..(info.nick or " ").."~"..(userid or " ").."~"..battleType

    gReq:MsgReqMessagePost(self, "messageSendCallBack", 0, context, 2);
end

function VDataManager:messageSendCallBack( result )
    if result == 0 then
        gWindow:showNormalTip("您的求援信息已经发送到世界频道。","求援成功！");
    end
end


------根据vip积分获得vip等级
function VDataManager:GetVipLevel(charge)
    if not charge then
        return nil
    end
    local vipCsv = gData:readCsv("user_vip.csv");
    local vipInfo = nil
    local iter = VDataIter()
    while vipCsv.var:Travel(iter) do
        local item = iter:Data();
        if item[1] > charge then
            break;
        else
            vipInfo = item;
        end
    end

    return vipInfo[0]
end

function VDataManager:OpenPlayerOpDlg(info, type, delegate, callBack, ...)
    local dlg = VNode("vPlayerOperateDlg.vui")
    dlg:SetUserInfo(info, type, delegate, callBack, ...)
    gView():Push(dlg)
end

function VDataManager:getResoureCount(rType, rid)
     if rType and rid then
        if rType == RES_DATA_TYPE.ResDataTypeAttr then
            return gData.userInfo.roleInfo:attrValue(rid);
        elseif rType == RES_DATA_TYPE.ResDataTypeItem then
            local itemInfo = gData.userInfo.bagInfos:itemThingid(rid);
            if not itemInfo or itemInfo.amount < 0 then
                return 0 ;
            else
                return itemInfo.amount;
            end
        elseif rType == RES_DATA_TYPE.ResDataTypeSuit then

        elseif rType == RES_DATA_TYPE.ResDataTypePlant then

        elseif rType == RES_DATA_TYPE.ResDataTypeArm then

        end
    end
end


function VDataManager:IsResoureUpperLimit(rType, rid, count)
   if rType and rid and count then
        if rType == RES_DATA_TYPE.ResDataTypeAttr then
            if rid == AttrType.AttrTypeMoney then
                local limit = gData.userInfo.manorInfo.storeInfo.coinMax;
                local cur = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeMoney) + count;
                if cur > limit then
                    return cur - limit;
                end
            elseif rid == AttrType.AttrTypeSunshine then
                local limit = gData.userInfo.manorInfo.storeInfo.sunshineMax;
                local cur = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeSunshine) + count;
                if cur > limit then
                    return cur - limit;
                end
            end
        elseif rType == RES_DATA_TYPE.ResDataTypeItem then

        elseif rType == RES_DATA_TYPE.ResDataTypeSuit then
        elseif rType == RES_DATA_TYPE.ResDataTypePlant then

        elseif rType == RES_DATA_TYPE.ResDataTypeArm then

        end
    end
end


-----获取适应缩放比例,  node 为需要缩放比例的节点, relative 为参照节点
function VDataManager:GetFitScale( node, relative)
    -- body

    if node.getContentSize and relative.getContentSize then
        local width = node:getContentSize().width * (node.scale or 1)
        local height = node:getContentSize().height * (node.scale or 1)

        local widthR = relative:getContentSize().width * (relative.scale or 1)
        local heightR = relative:getContentSize().height * (relative.scale or 1)

        return math.max(math.min(widthR / width, 1) * 0.9, math.min(heightR / height, 1) * 0.9) * (node.scale or 1)
    end

    return 1
end


-----检查需消耗的资源是否充足
function VDataManager:CheckResConsume( res, delegate, callBack, ... )
    -- body
    if type(res) == "table"then

        local lack = {}

        for k,v in pairs(res) do

            local resType = v.type
            local id = v.id
            local cost = math.abs(v.cost)
            
            cclog((resType or -1).."~~~~~~~~~~~~~~~~~~~~~~~~~"..(id or -1))

            if resType and id then
                if resType == RES_DATA_TYPE.ResDataTypeAttr then

                    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
                    local coin = gData:attrValue(AttrType.AttrTypeMoney)
                    local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
                    local JF = gData:attrValue(AttrType.AttrTypeBattleScore)

                    if id == AttrType.AttrTypeCurrency then
                        if cost > YB then
                            gWindow:showMoneyLackDlg(cost)
                            return false
                        end
                    elseif id == AttrType.AttrTypeMoney then
                        cclog("1~~~~~~~~~~~~~~~~~~~ffffff"..(cost or -1).."~~~~~~~~~~~"..(coin or -1))
                        if cost > coin then
                            local costInfo = {}
                             cclog("1~~~~~~~~~~~~~~~~~~~ffffff")
                            costInfo.thingid = id
                            costInfo.type = resType
                            costInfo.count = cost - coin

                            table.insert(lack, costInfo)
                        end
                    elseif id == AttrType.AttrTypeSunshine then
                        cclog("1~~~~~~~~~~~~~~~~~~~ffffff"..(cost or -1).."~~~~~~~~~~~"..(sunShine or -1))
                        if cost > sunShine then
                            cclog("2~~~~~~~~~~~~~~~~~~~ffffff")
                            local costInfo = {}

                            costInfo.thingid = id
                            costInfo.type = resType
                            costInfo.count = cost - sunShine

                            table.insert(lack, costInfo)
                        end
                    elseif id == AttrType.AttrTypeBattleScore then
                        if cost > JF then
                            gWindow:showTip("战功不足", 1)
                            return false
                        end
                    end
                elseif resType == RES_DATA_TYPE.ResDataTypeItem then
                    local item = gData.userInfo.bagInfos:itemThingid(id);
                    if (not item and cost ~= 0) or (item and cost > item.amount) then
                        --cclog("item.amount~~~~~~~~~"..item.amount.."cost~~~~~~~~~~~~"..cost)
                        local csvData = gData:readCsv("prop_item.csv");
                        local lineData = csvData:lineDataWithKey(id);
                        
                        if not lineData then
                            gWindow:showTip("物品"..(id or -1).."不存在", 1)
                            return false
                        end
                         cclog("3~~~~~~~~~~~~~~~~~~~ffffff")
                            local costInfo = {}

                            costInfo.thingid = id
                            costInfo.type = resType
                            local amount = 0
                            if item then
                                amount = item.amount
                            end

                            costInfo.count = cost - amount

                            table.insert(lack, costInfo)

                        -- gWindow:showTip(lineData.name.."不足", 1)
                        -- return false
                    end
                end              
            end
        end

        cclog("~~~~~~~~~~~~~~~~~~~~~~~~~lack"..table.getn(lack))
        if #lack > 0 then

            for k,v in pairs(lack) do
                local info = self:GetDirectBuyInfo(v.type, v.thingid );

                if not info then
                    local image, name= gData:getResoureIconByID(v.type, v.thingid);
                    gWindow:showTip(name.."不足", 1)
                    return false;
                end
            end

           
            gWindow:showCostLackDlg(lack, delegate, callBack, unpack({...}))
            
            return false
        end

        return true
    end

    return false
end

function VDataManager:GetDirectBuyInfo( type, id )
    -- body
    local info ={};
    local csvData = gData:readCsv("item_direct_buy.csv");
    local lineData = csvData:lineDataWithKey(id);
    if not lineData then
        -- cclog("can not find the id:%d in file item_direct_buy.csv", id);
        return;
    end
    info.image = gData:getResoureIconByID(type, id);
    -- info.image = "cangku.png"; --lineData[2];
    info.scale = lineData[3]/lineData[2];
    return info;
end


function VDataManager:ShowBattleHelpDlg( levelid, delegate, callBack )
    -- body
    cclog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~levelid"..(levelid or -1))


    local dungeonInfo = gData.userInfo.dungeonInfo

    local info = dungeonInfo:GetLevelCsvInfo(levelid)

    local star = dungeonInfo:GetLevelRecord(levelid)

    local rt = dungeonInfo:CheckBattleHelpDlgShow(levelid)

    if star == 0 and delegate and callBack then
        if info.battleHelp then
            local dlg = VNode("vBattleHelpDlg.vui")
            dlg:SetInfo(info)
            dlg.delegate = delegate;
            dlg.callBack = callBack;
            dlg.level = delegate.maxLevel * EAnimationSpriteLevel.HIGH_LEVEL;
            gView():Push(dlg)
            return true;
        elseif rt then
            local dlg = VNode("vBattleHelpShopDlg.vui")
            dlg:SetInfo(info)
            dlg.delegate = delegate;
            dlg.callBack = callBack;
            dlg.level = delegate.maxLevel * EAnimationSpriteLevel.HIGH_LEVEL;
            gView():Push(dlg)
            return true;
        end

        return false
    else
        return false;
    end
end


function VDataManager:UpDataMainInterFaceWithVipChage( ... )
    -- body
    local plantlotteryDlg = gView()("plantlotteryDlg")

    if plantlotteryDlg then
        plantlotteryDlg:VipChageNotic()
    end

    local corpselotteryDlg = gView()("corpselotteryDlg")

    if corpselotteryDlg then
        corpselotteryDlg:VipChageNotic()
    end

end
function VDataManager:GetLevelCostInfo( levelInfo, purchase )
    -- body
    local dungeonInfo = gData.userInfo.dungeonInfo

    if not levelInfo or not purchase then
        return false
    end

    if not levelInfo.shop or not levelInfo.shop[purchase] then
        return false
    end

    local costInfo = {}

    if gPackage == 1000 then
    local phoneType = gSys:GetPhoneNet();
    if phoneType == 100 then
        costInfo.discountCost = levelInfo.shop[purchase].discountCostYd
        costInfo.discount = levelInfo.shop[purchase].discountYd
        costInfo.cardCost = levelInfo.shop[purchase].cardCostYd
        costInfo.shopName = levelInfo.shop[purchase].shopNameYd
    elseif phoneType == 102 then
       costInfo.discountCost = levelInfo.shop[purchase].discountCostDx
        costInfo.discount = levelInfo.shop[purchase].discountDx
        costInfo.cardCost = levelInfo.shop[purchase].cardCostDx
        costInfo.shopName = levelInfo.shop[purchase].shopNameDx
    elseif phoneType == 101 then
        costInfo.discountCost = levelInfo.shop[purchase].discountCostLt
        costInfo.discount = levelInfo.shop[purchase].discountLt
        costInfo.cardCost = levelInfo.shop[purchase].cardCostLt
        costInfo.shopName = levelInfo.shop[purchase].shopNameLt
    end
    elseif dungeonInfo:CheckExraPackage() then
        costInfo.discountCost = levelInfo.shop[purchase].discountCostOt
        costInfo.discount = levelInfo.shop[purchase].discountOt
        costInfo.cardCost = levelInfo.shop[purchase].cardCostOt
        costInfo.shopName = levelInfo.shop[purchase].shopNameOt
    else
        costInfo.discountCost = levelInfo.shop[purchase].discountCostSk
        costInfo.discount = levelInfo.shop[purchase].discountSk
        costInfo.cardCost = levelInfo.shop[purchase].cardCostSk
        costInfo.shopName = levelInfo.shop[purchase].shopNameSk
    end
    return costInfo
end