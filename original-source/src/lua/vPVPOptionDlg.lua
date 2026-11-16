require "vRobOptionLayer"
require "vBattlefiledLayer"
require "vBattleLogDlg"
require "vPvpFriendLayer"
require "vPvpEnemyLayer"
require "vClanWarDlg"
require "vChatLayer"
require "vBattlefiledLog"

VPVPOptionDlg = VClass("PVPOptionDlg", VMsgBox);

function VPVPOptionDlg:onPush()
	self.roleInfo = gData.userInfo.roleInfo;
	self.attackLimit = self.roleInfo.vipInfo[idx_vip_attackLimit];
	self.defendLimit = self.roleInfo.vipInfo[idx_vip_defendLimit];
	self("defLimit").text = "/"..self.defendLimit;
	self("atkLimit").text = "/"..self.attackLimit;

	self.robOption = self("robOption");
	self.robOption.delegate = self;
	self.battlefieldOption = self("battlefieldOption");
	self.battlefieldOption.delegate = self;
	self.battleLogOption = self("battleLogDlg");
	self.friendOption = self("friendOption");
	self.enemyOption = self("enemyOption");
	self:RefreshRes();
	self:UpdateAssitInfo();
	self:InitData();
end

function VPVPOptionDlg:onPushFinish()
	self.optionTable[self._curIndex]:InitLayer();
end

function VPVPOptionDlg:onPop()
	if self.roleInfo then
		self.roleInfo.roleBattleInfo:ClearNewFinishInfo();
		self.roleInfo.roleBattleInfo:ClearNewAssistInfo();
	end
	gData.noticeManager:clear(NoticeType.battle_begin);
	gData.noticeManager:clear(NoticeType.battle_end);
end

function VPVPOptionDlg:onForeground( )
	self:Synchronism();
end

--同步角色数据
function VPVPOptionDlg:Synchronism(  )
	local param = {};
    param.syn_flag = 1;
    param.data_type = GameDataType.DataTypeRoleInfo;
    gReq:MsgReqUserDataSyn(self, "SynchronismRespone", param);
end

function VPVPOptionDlg:SynchronismRespone( result, rsp, req )
	if result == 0 then
		self.roleInfo = gData.userInfo.roleInfo;
		self:UpdateAssitInfo();
		self.optionTable[self._curIndex]:InitLayer();
	end
end

--初始化界面数据
function VPVPOptionDlg:InitData()
	self._layerIndex = {
		["rob"] = 1,
		["friend"] = 2,
		["enemy"] = 3,
		["battlefield"] = 4,
		["log"] = 5,
	};
	self.optionTable = {
		[1] = self.robOption,
		[2] = self.friendOption,
		[3] = self.enemyOption,
		[4] = self.battlefieldOption;
		[5] = self.battleLogOption;
	};

	self._curIndex = self._layerIndex.rob;
end

--选项卡切换事件
function VPVPOptionDlg:onOptionBtnClick(option)
	if  self._curIndex == option then
		return;
	end

	for i,v in pairs(self.optionTable) do
		local optionBtn = self("option"..i);
		if i == option then
			if v.InitLayer then
				v:InitLayer();
			end
			self._curIndex = option;
			optionBtn.image = "pvpxuanxiang1.png";
			optionBtn("ttopImage").image = "lueduoxuanze"..i..".png";
			optionBtn.level = 110;
		else
			if v.HideLayer then
				v:HideLayer();
			end
			optionBtn.image = "pvpxuanxiang2.png";
			optionBtn("ttopImage").image = "lueduoweixuan"..i..".png";
			optionBtn.level = 90;
		end
	end
end

function VPVPOptionDlg:onClick( ... )
end

--刷新资源
function VPVPOptionDlg:RefreshRes( )
	local sun = self.roleInfo:attrValue(AttrType.AttrTypeSunshine);
	local coin = self.roleInfo:attrValue(AttrType.AttrTypeMoney);
	local vcoin = self.roleInfo:attrValue(AttrType.AttrTypeCurrency);
	self("sunNum").text = sun;
	self("vcoinNum").text = vcoin;
	self("coinNum").text = coin;
end

function VPVPOptionDlg:UpdateAssitInfo( )
	local attackCount,defendCount = self.roleInfo.roleBattleInfo:GetAssistCount();
	self("defCount").text = defendCount;
	self("atkCount").text = attackCount;
end

--返回玩家当前是否可以进攻
function VPVPOptionDlg:IsAssitAtkEnable(  )
	local attackCount,defendCount = self.roleInfo.roleBattleInfo:GetAssistCount();
	return attackCount < tonumber(self.attackLimit);
end

--返回玩家当前是否可以防守
function VPVPOptionDlg:IsAssitDefEnable(  )
	local attackCount,defendCount = self.roleInfo.roleBattleInfo:GetAssistCount();
	return defendCount < tonumber(self.defendLimit);
end