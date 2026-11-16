--=====================================
--vBattleLog.lua
--=====================================
require "vBattleLogCell"
--=====================================
VBattleLogDlg = VClass("BattleLogDlg", VLayer)
--=====================================
function VBattleLogDlg:Init( attr )
	VBattleLogDlg.super.Init( self, attr );
	
	self.maxReq = 10;
    self.maxCells = 30;
	
	self.attacked_userids = gData.userInfo.roleInfo.dayInfo.attacked_userids;
    self.battleBriefLogs = gData.battleBriefLogs;
	self.tblBattleLogList = {};
	self.tblBattleLogDetailInfoList = {};
end
function VBattleLogDlg:InitLayer( )
	if ( self.battleBriefLogs ~= nil ) then
--		self.battleBriefLogs:setAllNewLogOff(_VLogType.defend);
--		self.battleBriefLogs:setAllNewLogOff(_VLogType.attack);
        self.battleBriefLogs:setAllNewLogOff(_VLogType.all);
	end
	self:ShowLayer();
--	self:requireStaticUserData();
    self:getStaticUserDataQuery("begin")
    gData.showLog = false
	self.visible = 1
end

function VBattleLogDlg:HideLayer(parameters)
    self.visible = 0
end

function VBattleLogDlg:ShowLayer()
	self.tbBattleLogListView = self("battleLogTbView");
	self.tbBattleLogListView.delegate = self;
	self:reloadLogsListView();
end
function VBattleLogDlg:onTableLeave( tbView )
	if ( self:getLogCount() >= self.maxCells ) then
		self.tbBattleLogListView:cancelLoading();
	else
		self:requireStaticUserData();
	end
end
function VBattleLogDlg:onCell(idx, t, cell)
	local info = self.tblBattleLogList[idx + 1];
	if ( info == nil ) then
		return;
	end
   info.userid = info.attacker.userid;
   cell:setCellType(info.group);
    if (self.attacked_userids[info.userid] ~= nil) then
        info.isRevenge = true;
    else
        info.isRevenge = false;
    end
    cell:setBriefLogInfo(info, idx);
    cell:setParentType("LOG");
    cell:recover();
    cell:setInfo(info);
	
end

function VBattleLogDlg:onBtnCloseClick( )
    self:onClick();
end
function VBattleLogDlg:onClick()
	self:Parent(2):onClick();
end
--=====================================
function VBattleLogDlg:getLogCount()
    return #self.tblBattleLogList;
end
function VBattleLogDlg:updateLogsData()
	if ( self.battleBriefLogs ~= nil ) then
--		local tblDefList =  self.battleBriefLogs:opLogArray(_VLogType.defend);
--		local tblAtcList =  self.battleBriefLogs:opLogArray(_VLogType.attack);
        self.tblBattleLogList = self.battleBriefLogs:opLogArray(_VLogType.all);
--		self.tblBattleLogList = {};
--		for key,value in pairs( tblDefList ) do
--			value.group = "DEF";
--			table.insert( self.tblBattleLogList, value );
--		end
--		for key,value in pairs( tblAtcList ) do
--			value.group = "ATC";
--			table.insert( self.tblBattleLogList, value );
--		end
		
--		table.sort( self.tblBattleLogList, function( objA, objB ) return objA.time > objB.time;  end );
	end
end
function VBattleLogDlg:reloadLogsListView()
	self:updateLogsData();
	if ( #self.tblBattleLogList > 0 ) then
		self("txNoneLogD").visible = 0;
	else
		self("txNoneLogD").visible = 1;
	end
	if ( self.tbBattleLogListView ~= nil ) then
		self.tbBattleLogListView.number = math.min( #self.tblBattleLogList, self.maxCells );
		if ( self.tbBattleLogListView.number > 0 and self.tbBattleLogListView.number < self.maxCells) then
--			self.tbBattleLogListView:resetTableLoading(10);
		end
		self.tbBattleLogListView:reloadData();
	end
end

function VBattleLogDlg:requireStaticUserData(bShowWait)
	if (bShowWait == nil) then
		bShowWait = true;
	end
	if (bShowWait) then
		gWindow:showWaitTip();
	end
--	self:getStaticUserDataQuery("DEF");
	self:getStaticUserDataQuery("ATC");
end
function VBattleLogDlg:getStaticUserDataQuery( strType )
	if ( self.battleBriefLogs == nil ) then
		return;
	end
	local aParam = {};
	local reqCount = self.maxReq;
--	if ( strType  == "DEF" )then
--        aParam.data_type = StaticUserDataType.StaticUserDataTypeBfiefBattleLogDefend;
--	    aParam.id = self.battleBriefLogs:lastId(_VLogType.defend);
--	else
--        aParam.data_type = StaticUserDataType.StaticUserDataTypeBfiefBattleLogAttack
--		aParam.id = self.battleBriefLogs:lastId(_VLogType.attack);
--	end
    
    aParam.data_type = StaticUserDataType.StaticUserDataTypeBfiefBattleLog
    
    if strType == "begin" then
        aParam.id = 0--self.battleBriefLogs:lastId(_VLogType.all);
    else
        aParam.id = self.battleBriefLogs:lastId(_VLogType.all);
    end
    
    aParam.count = reqCount;
    self:reqStaticUserDataQuery(aParam);
end
function VBattleLogDlg:reqStaticUserDataQuery(aParam)
    gReq:MsgReqStaticUserDataQuery(self, "reqStaticUserDataQueryBack", aParam.id, aParam.data_type, aParam.count)
    self("txNoneLogD").visible = 0;
end
function VBattleLogDlg:reqStaticUserDataQueryBack(result, rsp, req)
    if ( result == 0 ) then
        self:reqStaticUserDataQuerySuccess(rsp, req);
	else
		gWindow:closeWaitTip();
    end
end
function VBattleLogDlg:reqStaticUserDataQuerySuccess(rsp, req)
    if (rsp ~= nil and req ~= nil) then
        local datas = rsp.brief_battle_logs;
        if req.data_type == StaticUserDataType.StaticUserDataTypeBfiefBattleLogDefend then     
            if ( datas ~= nil ) then
                self:updataLog(_VLogType.defend, datas);
            end
--            self:refreshLogsListView(datas, req.id:String());
            if datas then
            self.reqCount = (self.reqCount or 0) + datas:Count();
            end
        else
            if datas ~= nil then
                self:updataLog(_VLogType.all, datas);  
            end
            
            if datas then
            self.reqCount = (self.reqCount or 0) + datas:Count();
            
            
            
--            else
--                gWindow:closeWaitTip();
            end
            
            self:refreshLogsListView(datas, req.id:String());
            
        end 
    end
end
function VBattleLogDlg:refreshLogsListView(datas, id)
    
	local count = 0
--    if (datas ~= nil) then
--        count = datas:Count();
--    end
    if (self.reqCount or 0) > 0 then
        count = self.reqCount
    end

    if ( id == "0" ) then
        self:reloadLogsListView();
    else
        if ( count > 0 ) then
			self:updateLogsData();
            self.tbBattleLogListView:addCellNum(count);
        else
            --gWindow:showTip("没有数据了", 1);
        end
    end
    
    self.reqCount = 0 
    
	gWindow:closeWaitTip();
end
function VBattleLogDlg:updataLog(logType, datas)
    if logType == _VLogType.all and #(self.battleBriefLogs:opLogArray(_VLogType.all) ) == 0 then
        self.battleBriefLogs:addLogs(datas, logType, nil, true);
    else
        self.battleBriefLogs:addLogs(datas, logType);
    end
end

function VBattleLogDlg:viewBattleLogDetailInfo( info )
	
end
function VBattleLogDlg:reqBattleLogInfoQuery(info,bShowWait)
    gReq:MsgReqBattleLogQuery(info.id, self, "reqBattleLogInfoQueryBack", info.result);
	
	if ( bShowWait == nil ) then
		bShowWait = true;
	end
	if ( bShowWait ) then
		gWindow:showWaitTip();
	end
end
function VBattleLogDlg:reqBattleLogInfoQueryBack(result, rsp, req)
    if result == 0 then
        self:reqBattleLogInfoQuerySuccess(rsp, req);
    end
	gWindow:closeWaitTip();
end
function VBattleLogDlg:reqBattleLogInfoQuerySuccess(rsp, req)
    if ( rsp ~= nil and rsp.info) then
        local battleLogInfo = VBattleLogInfo:new(rsp.info);
        local dlg = VNode("vLogDetailDlg.vui");
        dlg.result = req.result;
        dlg:SetLogInfo(battleLogInfo, req.BattleInfo);
        gView():Push(dlg);
    end
end







