require "vEventEntryCell"

VEventEntryDlg = VClass("EventEntryDlg", VMsgBox);

function VEventEntryDlg:Init( attr )
	VEventEntryDlg.super.Init(self, attr);
	self.rowCount = 2;
	self.datas = {};
end

function VEventEntryDlg:onPush()
	self.layer = self("layer1");
	self.tbEventEntry = self("tbEventEntry");
	self:tidyData();
	self.tbEventEntry:reloadData();
end

function VEventEntryDlg:tidyData()
	self.datas = gData.userInfo.eventEntryInfos:getInfos();
	self.tbEventEntry.delegate = self;
	self.tbEventEntry.number =  math.ceil(#self.datas / self.rowCount);
end

function VEventEntryDlg:onCell(idx, table, cell)
	if table == self.tbEventEntry then
		for i=1,self.rowCount do
            local cellIdx = idx*self.rowCount + i;
            if cellIdx <= #self.datas then
            	local data = self.datas[cellIdx];
            	cell:reload(idx, i, data);
            else
            	cell:lockCell(idx, i, true);
            end
        end
	end
end

function VEventEntryDlg:onClick()
	
end

function VEventEntryDlg:javacall()
	gReq:MsgReqActivityInfoQuery(self, "activityInfoQueryRespone");
end

function VEventEntryDlg:activityInfoQueryRespone(result)
	if result == 0 and self and self.tbEventEntry then
		self:tidyData();
		self.tbEventEntry:reloadData();
	end
end