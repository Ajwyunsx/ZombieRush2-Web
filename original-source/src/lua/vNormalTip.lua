VNormalTip = VClass("NormalTip", VMsgBox)

function VNormalTip:setMsgColor(color)
	self("nt_msgText").color = color;
end
