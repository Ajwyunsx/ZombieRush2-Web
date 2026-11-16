--vNoticeInfoCell.lua

VNoticeInfoCell = VClass("NoticeInfoCell", VTableViewCell)

function VNoticeInfoCell:loadNoticeInfo(data)
    self.data = data;
    self("noticeImage").image = data:getImage();
    self("noticeCount").text = data.count;
end

function VNoticeInfoCell:onDoEvent()
	if not self.data  or not gMainView then return end
	gMainView:onDoEvent(self.data);
end