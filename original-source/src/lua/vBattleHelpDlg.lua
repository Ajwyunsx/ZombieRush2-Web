VBattleHelpDlg = VClass("BattleHelpDlg", VMsgBox)

function VBattleHelpDlg:onPush( ... )
	-- body
	self("artUp"):play("idle")
	if self.page == 1 then
		self("btnpageup").gray = 1
		self("txpageup").color = {255,255,255}
		self("btnpageup").touch = 0
	else
		self("btnpageup").gray = 0
		self("txpageup").color = "fc_2_"
		self("btnpageup").touch = 1
	end

	if self.page == self.lastPage then
		self("btnpagedown").gray = 1
		self("txpagedown").color = {255,255,255}
		self("btnpagedown").touch = 0
	else
		self("btnpagedown").gray = 0
		self("txpagedown").color = "fc_2_"
		self("btnpagedown").touch = 1
	end

	cclog("~~~~~~~~~~~~"..self.battleHelp[self.page].type.."~~~~~~~~~~~"..self.battleHelp[self.page].thingid)

	local image, name, quality, desc = gData:getResoureIconByID(self.battleHelp[self.page].type, self.battleHelp[self.page].thingid)

	if self.amt then
		self.amt:doPop()
	end

	cclog("~~~~~~~~~~~~"..image.."~~~~~~~~~~~"..name)

		self.amt = VArmature{jsonName = desc.image, animation="idle", layout="Center"};
		self.amt.scale = self:getAmtSpeedAndScale(desc.image)
		self.amt.scale = gData:GetFitScale(self.amt, self("imgDexDGiftsO"))

    	self("imgDexDGiftsO"):Push(self.amt);


	self("txDexGiftsO1").text = name--self.battleHelp[self.page].title

	local decs = self.battleHelp[self.page].desc
	if decs and decs ~= "" then
		self("txdescribe").text = decs
	else
		local skill = self:GetSkillchange(self.battleHelp[self.page].type, self.battleHelp[self.page].thingid)
		self("txdescribe").text = string.gsub(skill,"\\n", "\n")

	end

	self("txDexd").text = self.battleHelp[self.page].typeDecs

	self:ShowButtonFace()
end

function VBattleHelpDlg:ShowButtonFace( ... )
	-- body
	local dungeonInfo = gData.userInfo.dungeonInfo
	local rt = dungeonInfo:CheckBattleHelpDlgShow(self.info.id)
	if rt then
		self("lybtE").visible = 1
		self("lybt").visible = 0
	else
		self("lybtE").visible = 0
		self("lybt").visible = 1
	end
end

function VBattleHelpDlg:GetSkillchange(type, id)
	local skillchange
	if type == RES_DATA_TYPE.ResDataTypePlant then

    	skillchange = gData:readCsv("plant_upstar_skillchange.csv");
    else

    	skillchange = gData:readCsv("monster_upstar_skillchange.csv");
    end

    local skill = skillchange:lineDataWithKey(self.battleHelp[self.page].thingid);
    cclog("self.thingid"..self.battleHelp[self.page].thingid)
    if not skill then
        return
    end
    return skill[2] or ""
end

function VBattleHelpDlg:getAmtSpeedAndScale(image)
    local speed, scale;
    local acCsv = gData:readCsv("animation_creature.csv");
    scale = acCsv:lineDataWithKey(image,2)/ 100 or 1;
    speed = acCsv:lineDataWithKey(image,5)/100 or 1;
    return scale;
end

function VBattleHelpDlg:SetInfo( info )
	-- body
	self.info = info
	self.battleHelp = info.battleHelp
	self.page = 1
	self.lastPage = #info.battleHelp
end

function VBattleHelpDlg:onOK( ... )
	-- body
	if self.page >= self.lastPage then
		local dungeonInfo = gData.userInfo.dungeonInfo

		if dungeonInfo:GetPurchase(self.info.id) == 0 then
			local dlg = VNode("vBattleHelpShopDlg.vui")
	        dlg:SetInfo(self.info)
	        dlg.delegate = self.delegate;
	        dlg.callBack = self.callBack;
	        if self.delegate then
	        	dlg.level = self.delegate.maxLevel * EAnimationSpriteLevel.HIGH_LEVEL;
	    	end
	        gView():Push(dlg)
			self:doPop()
		else
			self:onClose()
		end

		return
	end

	self.page = self.page + 1
	self:onPush()
end

function VBattleHelpDlg:onPageUp( ... )
	-- body
	self.page = self.page - 1
	self:onPush()
end

function VBattleHelpDlg:onPageDown( ... )
	-- body
	self.page = self.page + 1
	self:onPush()
end

function VBattleHelpDlg:onClose( ... )
	if self.delegate and self.callBack then
		VCallBack(self.delegate, self.callBack);
	end
	VBattleHelpDlg.super.onClick(self)
end

function VBattleHelpDlg:onClick( ... )
	
end