
VOutLineLogDlg = VClass("OutLineLogDlg", VMsgBox)


function VOutLineLogDlg:SetLogList(logList)
    self.attacked_userids = gData.userInfo.roleInfo.dayInfo.attacked_userids
    self.logList = logList;
end


function VOutLineLogDlg:onPush()
    self("titleText").text = "您被攻击了！";
    self.tbv = self("tbv");
    self.tbv.delegate = self;

end
function VOutLineLogDlg:onPushFinish(  )
    self:loadAttackersInfo();
end

--读取攻击者的基础信息
function VOutLineLogDlg:loadAttackersInfo( )
    local userids = {};
    for i,v in ipairs(self.logList) do
        table.insert(userids, v.attacker.userid);
    end
    gData:userBriefInfo(userids, self, "InitDlg");
end

function VOutLineLogDlg:InitDlg(  )
    self.tbv.number = #self.logList;
    self.tbv:reloadData();
end

function VOutLineLogDlg:onCell( idx, t, cell )
    idx = idx + 1;
    local info = self.logList[idx];
    cell:updateWithInfo(info);
end

--点击查看日志详情
function VOutLineLogDlg:onLogBtnClick(  )
    local node = VNode("vPVPOptionDlg.vui");
    gView():Push(node);
    node:onOptionBtnClick(node._layerIndex.log);
end

VOutLineLogDlgCell = VClass("OutLineLogDlgCell", VTableViewCell);

function VOutLineLogDlgCell:updateWithInfo( info )
    if info.result == 1 then
        self("resultImg").image = "shibaijiaobiao.png";
    else
        self("resultImg").image = "shenglijiaobiao.png";
    end
    local baseInfo = gData:briefCache(info.attacker.userid);
    if baseInfo then
        local vipLevel = gData:GetVipLevel(baseInfo.charge);
        self("headImg"):setHead(baseInfo.userid, baseInfo.image, nil, vipLevel);
        self("headImg"):SetHeadImageShader();
        self("headImg").onClick = "node:Parent(2):OpenPlayerOpDlg("..info.attacker.userid..")";
        self("attackerName").text = baseInfo.nick;
        self("attackerLevel").text = "Lv"..baseInfo.level;
    end

    self("sunText").text = info.spoils.sunshine;
    self("coinText").text = info.spoils.gold;
    self("suitText").text = info.spoils.itemCount;
end

function VOutLineLogDlgCell:OpenPlayerOpDlg( userid )
    if userid == gData.userInfo.userid then return end;
    local info = gData:briefCache(userid);
    gData:OpenPlayerOpDlg(info);
end