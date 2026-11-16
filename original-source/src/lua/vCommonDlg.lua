--vCommonDlg.lua

VCommonDlg = VClass("CommonDlg", VLayer)

function VCommonDlg:setTitleImage(tileImage)
	self("titliText").image = tileImage;
end

