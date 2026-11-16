--vCardLevelUpDlg.lua

VCardLevelUpDlg = VClass("CardLevelUpDlg", VMsgBox);

function VCardLevelUpDlg:setCardInfo( cardInfo, aType )
	self.cardInfo = cardInfo;
	self.aType = aType;
end

function VCardLevelUpDlg:onPush(  )
	self("artUp"):play("idle")
	if self.aType ==  1 then
		local plantInfo = self.cardInfo.plantInfo;
		local leftItem = self("leftCardImg");
		leftItem.image = "carddiban"..plantInfo.quality..".png";
		leftItem("cardName").text = plantInfo.plantName;
		leftItem("iconImg").image = plantInfo.plantImage.."S.png";
		local level = plantInfo.plantLevel;
		
		if level > 0 then
			leftItem("starImg").visible = 1
			leftItem("txlevel").text = level
		else
			leftItem("starImg").visible = 0
		end

		local rightItem = self("rightCardImg");
		rightItem.image = "carddiban"..plantInfo.quality..".png";
		rightItem("cardName").text = plantInfo.plantName;
		rightItem("iconImg").image = plantInfo.plantImage.."S.png";
		local level = plantInfo.plantLevel + 1;
		

		if level > 0 then
			rightItem("starImg").visible = 1
			rightItem("txlevel").text = level
		else
			rightItem("starImg").visible = 0
		end

		self("descText").text = string.gsub(plantInfo.skillDesc,"\\n", "\n");

		self("conditionText1").text = "庄园达到"..plantInfo.labLevel.."级";
		self("conditionText2").text = gData:transformTimeToString(plantInfo.timeCost);

		for var = 1, 2 do
			if plantInfo.effect[var] then
		        self("conditionIcon"..(var+2)).image = gData:getResoureIconByID(plantInfo.effect[var].effectType, plantInfo.effect[var].effectid)
		        if plantInfo.effect[var].effectType == 2 then
		        	local count = gData.userInfo.bagInfos:itemCountThingid(plantInfo.effect[var].effectid);
              local use = math.abs(plantInfo.effect[var].effectValue)
              if use == 0 then
                self("conditionIcon"..(var+2)).visible = 0
                -- self("conditionText"..(var+2)).text =  math.abs(plantInfo.effect[var].effectValue);
                self("conditionText"..(var+2)).visible = 0
              else

		        	   self("conditionText"..(var+2)).text =  count.."/"..use;
		          end
            else
		        	self("conditionText"..(var+2)).text =  math.abs(plantInfo.effect[var].effectValue);
		        end
		    
		    else
		    	self("conditionIcon"..(var+2)).visible = 0;
		        self("conditionText"..(var+2)).visible = 0;
		    end
	    end

	    self("sureBtn").onClick = "node:Parent(3):onPlantLevelUpClick()";
	else
		local leftItem = self("leftCardImg");
		leftItem.image = "carddiban"..self.cardInfo.quality..".png";
		leftItem("cardName").text = self.cardInfo.name;
		leftItem("iconImg").image = self.cardInfo.image.."L.png";
		local level = self.cardInfo.level;
		

		if level > 0 then
			leftItem("starImg").visible = 1
			leftItem("txlevel").text = level
		else
			leftItem("starImg").visible = 0
		end

		local rightItem = self("rightCardImg");
		rightItem.image = "carddiban"..self.cardInfo.quality..".png";
		rightItem("cardName").text = self.cardInfo.name;
		rightItem("iconImg").image = self.cardInfo.image.."L.png";
		local level = self.cardInfo.level + 1;
		
		if level > 0 then
			rightItem("starImg").visible = 1
			rightItem("txlevel").text = level
		else
			rightItem("starImg").visible = 0
		end

		self("descText").text = string.gsub(self.cardInfo.skillDesc,"\\n", "\n");

		self("conditionText1").text = "研究所达到"..self.cardInfo.labLevel.."级";
		self("conditionText2").text = gData:transformTimeToString(self.cardInfo.timeCost);

		for var = 1, 2 do
			if self.cardInfo.effect[var] then
		        self("conditionIcon"..(var+2)).image = gData:getResoureIconByID(self.cardInfo.effect[var].effectType, self.cardInfo.effect[var].effectid)
		        if self.cardInfo.effect[var].effectType == 2 then
		        	local count = gData.userInfo.bagInfos:itemCountThingid(self.cardInfo.effect[var].effectid);
		        	local use = math.abs(self.cardInfo.effect[var].effectValue)
              if use == 0 then
                self("conditionIcon"..(var+2)).visible = 0
                -- self("conditionText"..(var+2)).text =  math.abs(self.cardInfo.effect[var].effectValue);
                self("conditionText"..(var+2)).visible = 0
                
              else
                self("conditionText"..(var+2)).text =  count.."/"..use;
		          end
            else
		        	self("conditionText"..(var+2)).text =  math.abs(self.cardInfo.effect[var].effectValue);
		        end
		    else
		    	self("conditionIcon"..(var+2)).visible = 0;
		        self("conditionText"..(var+2)).visible = 0;
		    end
	    end

	    self("sureBtn").onClick = "node:Parent(3):onMonsterLevelUpClick()";
	end
end

function VCardLevelUpDlg:CheckCanLvUp()
    if self.cardInfo.plantInfo.labLevel > gData.userInfo.manorInfo.baseCampInfo.level then
        return 1
    end

    if gData.userInfo.manorInfo:idleFarmer() == 0 then
        local mi = gData.userInfo.manorInfo;

        if mi:farmerNextCost() then
            gWindow:showFarmerLackTip();
        else
        end
        return 2
    end
    return 0
end


function VCardLevelUpDlg:onPlantLevelUpClick()
    if gFarm and gFarm:isLevelOping(self.cardInfo) then
        gWindow:showTip("哎呀，操作太快了.");
        return;
    end
    
    if self:CheckCanLvUp() == 1 then
        gWindow:showTip("需要庄园"..self.cardInfo.plantInfo.labLevel.."级", 1);
        return
    elseif self:CheckCanLvUp() == 2 then
        gWindow:showTip("工人都在忙碌中，没有空闲的工人", 1);
        return
    end
    
    local plant = self.cardInfo.plantInfo;

    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local coin = gData:attrValue(AttrType.AttrTypeMoney)

    local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)

   --  cclog("plant.effect"..plant.effect[1].effectid)

   --  local item = gData.userInfo.bagInfos:itemThingid(plant.effect[2].effectid)
   --  local suit = 0

   --  if item then
   --      suit = item.amount
   --  end

   --   if suit < math.abs(plant.effect[2].effectValue) then
   --      gWindow:showTip("材料不足", 1)
   --      return
   --  end
    

   -- local lacks = {}
   -- if plant.effect[1].effectid == 21 and sunShine < math.abs(plant.effect[1].effectValue) then
   --     local War = {}
   --     War.thingid = 21
   --     War.type = 1
   --      War.count = math.abs(plant.effect[1].effectValue) - sunShine
   --     table.insert(lacks, War)
   -- end
   
   --  if plant.effect[1].effectid == 20 and coin < math.abs(plant.effect[1].effectValue) then
   --      local res = {}
   --      res.thingid = 20
   --      res.type = 1
   --      res.count = math.abs(math.abs(plant.effect[1].effectValue) - coin)
   --      table.insert(lacks, res)
   --  end

   -- if table.getn(lacks) ~= 0 then
   --     gWindow:showCostLackDlg(lacks, gFarm, "ReqPlantLvUp", self.cardInfo)
   -- else
   --      gFarm:ReqPlantLvUp(self.cardInfo)
   -- end

   local res = {}

   for k,v in pairs(plant.effect) do
		local infoi = {}
		infoi.type = v.effectType;
		infoi.id = v.effectid;
		infoi.cost = math.abs(v.effectValue)
		table.insert(res, infoi)
   end
	

   if not gData:CheckResConsume(res, gFarm, "ReqPlantLvUp", self.cardInfo) then
   		self:onClick();
       return 
   end

   gFarm:ReqPlantLvUp(self.cardInfo)
    self:onClick();
end


function VCardLevelUpDlg:onMonsterLevelUpClick( )
	   
    if self.cardInfo.nextLevelId == 0 then
        gWindow:showTip("已经满级了", 1)
        return 
    end
    if self.cardInfo.labLevel > gData.userInfo.manorInfo.laboratory.level then
	    gWindow:showTip("需要研究所"..self.cardInfo.labLevel.."级", 1);
        return 
    end

  --  local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
  --  cclog(self.cardInfo.id)
  --  local item = gData.userInfo.bagInfos:itemThingid(self.cardInfo.effect[2].effectid)
  --  local suit = 0
    
  --  if item then
 --       suit = item.amount
  --  end

  --  if suit < math.abs(self.cardInfo.effect[2].effectValue) then
 --       gWindow:showTip("材料不足", 1)
  --      return
  --  end
  --  local function GetResCost(vaule)
	--    if vaule < 0 then
	--        return -vaule
	--    else
	--        return vaule
	--    end
	--end
   --	local lacks = {}
  --	if sunShine < GetResCost(self.cardInfo.effect[1].effectValue) then
   --    local res = {}
   --    res.thingid = 21
   --    res.type = 1
  --     res.count = GetResCost(self.cardInfo.effect[1].effectValue) - sunShine
  --     table.insert(lacks, res)
  -- end

  -- if table.getn(lacks) ~= 0 then
  --     gWindow:showCostLackDlg(lacks, gView()("laboratoryDlg"), "ReqManorPlantLevelUp", self.cardInfo)
  --     self:onClick()
   --    return
  -- end
  local res = {}

   for k,v in pairs(self.cardInfo.effect) do
        local infoi = {}
        infoi.type = v.effectType;
        infoi.id = v.effectid;
        infoi.cost = math.abs(v.effectValue)
        table.insert(res, infoi)
   end
    

   if not gData:CheckResConsume(res, gView()("laboratoryDlg"), "ReqManorPlantLevelUp", self.cardInfo) then
        self:onClick();
       return 
   end

    gView()("laboratoryDlg"):ReqManorPlantLevelUp(self.cardInfo);

    self:onClick();
end

