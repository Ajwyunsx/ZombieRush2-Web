
VLvUpChangeDlg = VClass("LvUpChangeDlg", VMsgBox)

function VLvUpChangeDlg:onPush()
--    cclog("tupian:"..(self.info.armyTechInfo.image or "IIIIIIIIIIIIIIIIII"))
--    self("imgOldMonster").image = self.info.armyTechInfo.image.."S.png";
--    self("imgOldFrame").image = "beijingkuang"..self.info.oldInfo.Attribute.LvUp..".png";
--    self("imgNewMonster").image = self.info.armyTechInfo.image.."S.png";
--    self("imgNewFrame").image = "beijingkuang"..self.info.newInfo.Attribute.LvUp..".png";
 --    local amt = VArmature{jsonName = self.info.image, animation="idle", layout="Down", offset={0,-15} ,scale=0.6};
 -- amt:setScaleX(-0.6);
 --    self("imgPlantDexDLvUp"):Push(amt);
    
 --    local info = self:GetLastLvInfo()
    
 --    local count = info.level
 --    for var = 1, count do
 --        self("imgStarC"..var).image = "kapaixingxing.png"
 --    end
 --    self("txLifeLvUp").text = info.hp
 --    self("txAtcLvUp").text = info.atk
 --    self("txDefLvUp").text = info.speed

 --    local count = self.info.level
 --    for var = 1, count do
 --        self("imgStarAC"..var).image = "kapaixingxing.png"
 --    end
 --    self("txLifeNumLvUp").text = self.info.hp
 --    self("txAtcNumLvUp").text = self.info.atk
 --    self("txDefNumLvUp").text = self.info.speed
    

 --    if self.info.atk > info.atk then
 --        self("txAtcNumLvUp").color = {49,123,30};
 --    end
    
 --    if self.info.hp > info.hp then
 --        self("txLifeNumLvUp").color = {49,123,30};
 --    end
   
 --    if self.info.speed > info.speed then
 --        self("txDefNumLvUp").color = {49,123,30};
 --    end
    self("txc").text = self.info.name.."成功升到"..self.info.level.."星!"
    self("imgl"):RunAction{"sequence", {"repeat", -1, {"rotateBy", 8, 360}}};
    
end

function VLvUpChangeDlg:GetLastLvInfo(parameters)
    local info = nil
    local csv = gData:readCsv("prop_monster.csv");
    local count = csv:lineCount();
    
    for var = 0, count - 1 do
        local lineData = csv:lineData(var)
        if lineData.nextLevelId == self.info.thingid then
            local battleCsv = gData:readCsv("prop_creature_monster.csv");
            local battleLineData = battleCsv:lineDataWithKey(lineData.id);
            if not battleLineData then
                return;
            end
            info = {}
            info.level = lineData.level
            info.hp = battleLineData.hp
            info.atk = battleLineData.atk
            info.speed = battleLineData.speed
        end
    end
    
    return info
end

function VLvUpChangeDlg:SetInfo(info)
	self.info = info
end

function VLvUpChangeDlg:onClick()
    local payTip = gView()("payTip")
    if payTip ~= nil then
        payTip:onPayBtnClick()
    end

--    self:ShowNewLvUpChange()

    VLvUpChangeDlg.super.onClick(self)
end

function VLvUpChangeDlg:ShowNewLvUpChange( ... )
	-- body
	
	local infos =  gData.userInfo.manorInfo.levelFinishs
	for k, v in pairs(infos) do
		local monsters = gData.userInfo.monsterInfo.monsterInfos or {};
    	
        local info = monsters[v.id]
    	if info then
    		local dlg = VNode("vLvUpChangeDlg.vui")
    		dlg:SetInfo(info)
    		gView():Push(dlg)
    		gData.userInfo.manorInfo:DelLevelUpFinishNotice(info.id, LEVELUP_TYPE.LevelupMonster)
    		gData.noticeManager:modify(NoticeType.finish_monster_star, -1)
    		break
    	end
	end  
end