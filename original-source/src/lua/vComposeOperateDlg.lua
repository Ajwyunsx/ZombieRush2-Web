VComposeOperateDlg = VClass("ComposeOperateDlg",VMsgBox)


function VComposeOperateDlg:onPush()
    self("artUp"):play("idle")
 self.imgComposeDexLvUp = self("imgComposeDexLvUp");
 self.txtComposeLevel = self("txtComposeLevel");
 self.txTitleComposeIO = self("txTitleComposeIO");

 self.mi_atkText = self("mi_atkText");
-- self.mi_defText = self("mi_defText");
 self.mi_hpText = self("mi_hpText");
 self.mi_speedText = self("mi_speedText");
 self.mi_spaceText = self("mi_spaceText");
    self.txTimeSpace1 = self("txTimeSpace1");
 self.mi_atkBaseText = self("mi_atkBaseText");
-- self.mi_defBaseText = self("mi_defBaseText");
 self.mi_hpBaseText = self("mi_hpBaseText");
 self.mi_speedBaseText = self("mi_speedBaseText");

--    self.sunl_exploinText = self("sunl_exploinText");
--    self.suitl_exploinText = self("suitl_exploinText");
--    self.time_exploinText = self("time_exploinText");
--    self.lv_exploinText = self("lv_exploinText");

 self.imgDexDComposeIO = self("imgDexDComposeIO");

    if self.info.nextLevelId ~= 0 then
     self.txTitleComposeIO.text = "升至"..(self.info.level+1).."星";
 else
     self.txTitleComposeIO.text = "当前品质最大等级";
 end

 local amt = VArmature{jsonName = self.info.image, animation="idle", layout="Down", offset={0,-15} ,scale=0.6};
 amt:setScaleX(-0.6);
 self.imgDexDComposeIO:Push(amt);
 
 
--    local count = self.info.level
--    for var = 1, count do
--        self("imgStarC"..var).visible = 1
--    end
--    
--    count = self.info.level + 1
--    for var = 1, count do
--        self("imgStarAC"..var).visible = 1
--    end

-- local imgName = gData:getCreatureInsigniaImageName(self.info:getStrengthenPoint(), self.info.suitInfo.thingid, self.info.quality);
-- self.imgComposeDexLvUp.image = imgName;
 self.txtComposeLevel.text = self.info.level;

 self.mi_atkText.text = self.info.atk
-- self.mi_defText.text = self.info.def
 self.mi_hpText.text = self.info.hp
 self.mi_speedText.text = self.info.speed
-- self.mi_spaceText.text = "+"..self.info.nextLvUpCost.userExp

    if self.info.nextLevelId ~= 0 then
--     local ComposeInfo = self.info.nextComposeInfo;
     
        local battleCsv = gData:readCsv("prop_creature_monster.csv");
    local battleLineData = battleCsv:lineDataWithKey(self.info.nextLevelId);
    if not battleLineData then
        return;
    end
        
        self.mi_atkBaseText.text = battleLineData.atk
        if battleLineData.atk > self.info.atk then
         self.mi_atkBaseText.color = {49,123,30};
     end
--        self.mi_defBaseText.text = battleLineData.def
--        if battleLineData.def > self.info.def then
--         self.mi_defBaseText.color = {117,193,33};
--     end
        self.mi_hpBaseText.text = battleLineData.hp
        if battleLineData.hp > self.info.hp then
            self.mi_hpBaseText.color = {49,123,30};
     end
        self.mi_speedBaseText.text = battleLineData.speed
        if battleLineData.speed > self.info.speed then
            self.mi_speedBaseText.color = {49,123,30};
     end
 else
     self("mi_hpArrow").visible = 0;
     self("mi_atkArrow").visible = 0;
--     self("mi_defArrow").visible = 0;
     self("mi_speedArrow").visible = 0;
     self("bu_sunLevel").visible = 0;
     self("bu_coinLayer").visible = 0;
     self("btUpComposeIO").visible = 0;
 end

-- if self.info.nextLvUpCost.sunCost ~= 0 and self.info.nextLvUpCost.coinCost == 0 then
--     self("bu_sunLevel").visible = 0;
--     self("bu_coinLayer").offset = {80,-50};
--     self.bu_coinNumText.text = self.info.nextLvUpCost.sunCost;
--     self("bu_coinImage").image = "yangguang.png";
-- elseif self.info.nextLvUpCost.sunCost == 0 and self.info.nextLvUpCost.coinCost ~= 0 then
--     self("bu_sunLevel").visible = 0;
--     self("bu_coinLayer").offset = {80,-50};
--     self.bu_coinNumText.text = self.info.nextLvUpCost.coinCost;
--     self("bu_coinImage").image = "qianbi.png"
-- else
--     self.bu_sunNumText.text = self.info.nextLvUpCost.sunCost;
--     self.bu_coinNumText.text = self.info.nextLvUpCost.coinCost;
-- end
--    self.sunl_exploinText.text = self:GetResCost(self.info.effect[1].effectValue)
--    self.suitl_exploinText.text = self:GetResCost(self.info.effect[2].effectValue)
--    self.lv_exploinText.text = "需要实验室等级"..self.info.labLevel
    
    
    self.txTimeSpace1.time = self.info.timeCost;
    
    self("txdecsTitle").text = self.info.skillDesc--"定时"
    
    local limit = #self.info.effect
    
    for var = 1, limit do
        self("imgResCostI"..var).image = gData:getResoureIconByID(self.info.effect[var].effectType, self.info.effect[var].effectid)
        self("txResCost"..var).text =  math.abs(self.info.effect[var].effectValue)
    end
    
-- if self:CheckCanLvUp() then    
--     self("btUpComposeIO").visible = 1;
-- else
    self("txLvLimit").text = "研究所达到"..self.info.labLevel.."级"
--     self("txLimitComposeIO").visible = 1
-- end
    
--    self.time_exploinText.time = self.info.timeCost;
end

function VComposeOperateDlg:GetResCost(vaule)
    if vaule < 0 then
        return -vaule
    else
        return vaule
    end
end

function VComposeOperateDlg:CheckCanLvUp()
    if self.info.labLevel > gData.userInfo.manorInfo.laboratory.level then
--        gWindow:showTip("需要实验室等级"..self.info.nextLvUpCost.labLevel, 1);
        return false
    end
    
    return true
end

function VComposeOperateDlg:SetComposeInfo(info)
	self.info = info
end

function VComposeOperateDlg:ComposeLvUp(parameters)
    
    if self.info.nextLevelId == 0 then
        gWindow:showTip("已经满级了", 1)
        return 
    end
    
    if not self:CheckCanLvUp() then
        gWindow:showTip("需要研究所"..self.info.labLevel.."级", 1);
        return
    end
    
--    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
--    local coin = gData:attrValue(AttrType.AttrTypeMoney)
--    local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
 --   cclog(self.info.id)
 --   local item = gData.userInfo.bagInfos:itemThingid(self.info.effect[2].effectid)
 --   local suit = 0
    
 --   if item then
 --       suit = item.amount
 --   end

 --   if suit < math.abs(self.info.effect[2].effectValue) then
 --       gWindow:showTip("材料不足", 1)
  --      return
  --  end

  -- local lacks = {}
--
--    --    self:CheckCostInfos(21, 1, plant.nextLevelCost[3], plant.nextLevelCost[4], 2, plant.nextLevelCost[5])
 --  if sunShine < self:GetResCost(self.info.effect[1].effectValue) then
  --     local res = {}
     --  res.thingid = 21
   --    res.type = 1
   --    res.count = self:GetResCost(self.info.effect[1].effectValue) - sunShine
  --     table.insert(lacks, res)
  -- end
--    if coin < self:GetResCost(self.info.effect[2].effectValue) then
--        local res = {}
--        res.thingid = 20
--        res.type = 1
--        res.count = self.info.nextLvUpCost.coinCost - coin
--        table.insert(lacks, res)
--    end
--    --    if piece < plant.nextLevelCost[5] then
--    --        local res = {}
--    --        res.thingid = plant.nextLevelCost[4]
--    --        res.type = 2
--    --        res.count = plant.nextLevelCost[5]
--    --        table.insert(lacks, res)
--    --    end
--
  -- if table.getn(lacks) ~= 0 then
 --      gWindow:showCostLackDlg(lacks, gView()("laboratoryDlg"), "ReqManorPlantLevelUp", self.info)
  --     self:onClick()
  --     return
  -- end

    -- if sunShine < self:GetResCost(self.info.effect[1].effectValue) or suit < self:GetResCost(self.info.effect[2].effectValue) then
    --     gWindow:showTip("阳光不足或材料不足", 1)
    --     return
    -- end
    local res = {}

   for k,v in pairs(self.info.effect) do
        local infoi = {}
        infoi.type = v.effectType;
        infoi.id = v.effectid;
        infoi.cost = math.abs(v.effectValue)
        table.insert(res, infoi)
   end
    

   if not gData:CheckResConsume(res, gView()("laboratoryDlg"), "ReqManorPlantLevelUp", self.info) then
        self:onClick();
       return 
   end
    
    gView()("laboratoryDlg"):ReqManorPlantLevelUp(self.info)
    self:onClick()
end

function VComposeOperateDlg:onClick()
    --    local currentView = gView(-2)
    --    if currentView then
    --        currentView.visible = 1
    --    end
    VComposeOperateDlg.super.onClick(self)
end



