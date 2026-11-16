VLevelHelpInfoDlg = VClass("VLevelHelpInfoDlg", VMsgBox)

function VLevelHelpInfoDlg:onPush(parameters)
	if self.showType == 4 then
        self("lyfs").visible = 1
    elseif self.showType == 3 then
        self("lyjg").visible = 1
	end
end

function VLevelHelpInfoDlg:SetShowType(showType)
    self.showType = showType
end