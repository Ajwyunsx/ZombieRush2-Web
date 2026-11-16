--vfriendInfo.lua

VEnemyInfo = vclass("EnemyInfo")

function VEnemyInfo:Initialize(userid)
    self.userid = userid
    self.time = 0
    self.attack_win = 0
    self.attack_lose = 0
    self.defend_win = 0
    self.defend_lose = 0
end

function VEnemyInfo:synWithPbData(pbData)
    self.userid = pbData.info.bi.userid;
    self.time = pbData.info.bi.time or 0
    self.attack_win = pbData.info.bi.attack_win or 0
    self.attack_lose = pbData.info.bi.attack_lose or 0
    self.defend_win = pbData.info.bi.defend_win or 0
    self.defend_lose = pbData.info.bi.defend_lose or 0
end

VEnemyManager = vclass("EnemyManager")

function VEnemyManager:initialize()
    self.enemys = {};

    self:LoadUserCommon()
end

function VEnemyManager:synWithPbData(pbData)
    self.total_count = pbData.total_count
    local infos = pbData.infos;
    local iter = VDataIter();
    while infos:Travel(iter) do
        local exenemys = iter:Data();
        if exenemys.ctrl.op == _VCtrlOP.None or 
            exenemys.ctrl.op == _VCtrlOP.Rep or
            exenemys.ctrl.op == _VCtrlOP.Add then
            if not self.enemys[exenemys.info.bi.userid] then
                self.enemys[exenemys.info.bi.userid] = VEnemyInfo:new();
            end
            self.enemys[exenemys.info.bi.userid]:synWithPbData(exenemys);
        elseif exenemys.ctrl.op == _VCtrlOP.Del then
            self.enemys[exenemys.info.bi.userid] = nil;
        end
    end
end

function VEnemyManager:LoadUserCommon( ... )
    -- body
    local csv = gData:readCsv("user_common.csv");
    local lineData = csv:lineData(0);
    if not lineData then 
        gLog("user_common.csv miss ID:%d", 0);
        return nil;
    end

    self.enemyLimit = lineData.enemyLimit
end

function VEnemyManager:AddEnemy(userid)
    local enemys = VEnemyInfo:new();
    enemys:Initialize(userid)
    self.enemys[userid] = enemys
end

function VEnemyManager:DelEnemy(userid)
    if self.enemys[userid] then
        self.enemys[userid] = nil
    end
end

function VEnemyManager:EnemyCount()
    local count = 0;
    for k,v in pairs(self.enemys) do
        count = count + 1;
    end
    return count;
end

function VEnemyManager:isEnemy(userid)
    if self.enemys[userid] then
        return true;
    end
    return false;
end