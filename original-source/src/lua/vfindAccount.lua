--vfindAccount.lua

VFindAccount = VClass("FindAccount", VMsgBox)

function VFindAccount:mailFindAction()
	local emailFind = VNode("vAccountFindEmail.vui");
	gView():Push(emailFind);
	self:onClick();
end

function VFindAccount:cellphoneFindAction()
	local emailFind = VNode("vAccountFindCellPhone.vui");
	gView():Push(emailFind);
	self:onClick();
end