--vPlantlotteryDlg.lua

VPlantlotteryDlg = VClass("PlantlotteryDlg", VMsgBox)


function VPlantlotteryDlg:Init( attr )
    -- body
    VPlantlotteryDlg.super.Init(self, attr)
--    self:NeedEvent(Eff_onEnter);
--    gFarm = self
--    self.msgBoxCount = 0;   
--    self.touchPos = {}
--    self.selectedplant = nil;
--    self
end

function VPlantlotteryDlg:onClick()
    -- body
end

function VPlantlotteryDlg:onPush()
    self.vipLevel = gData.userInfo.roleInfo.vipInfo[0]
	-- local itemCommon = gData:LoadItemCommon()
	-- self("txCostlotteryDlg3").text = itemCommon.plantLotteryCost
	-- self("txCostTlotteryDlg3").text = itemCommon.plantTLotteryCost

 --    self.time = self:GetNextFreeTime()
 --    self:StartTimer("SetNextFreeTime", 0, self.time-1, 0);

 --    self("txTimelotteryDlg").text = self:transformTimeToString(self.time).."后免费";
    self("titliText").image = "chouka.png";
    self("sunText").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeCurrency))
    self.ptTime = self:GetNextFreeTime("pt")
    cclog("self.ptTime"..self.ptTime)
    self:StartTimer("SetNextFreeptTime", 0, self.ptTime-1, 0);
    self("txDesc3ptbplotteryDlg").text = self:transformTimeToString(self.ptTime).."后免费";
    local rouletteType = self:GetRouletteType(1)
    self("txptbCurrenyValue").text = rouletteType[2].." 购买"

    self.hhTime = self:GetNextFreeTime("hh")
    cclog("self.hhTime"..self.hhTime)
    self:StartTimer("SetNextFreehhTime", 0, self.hhTime-1, 0);
    self("txDesc3hhbplotteryDlg").text = self:transformTimeToString(self.ptTime).."后免费";
    rouletteType = self:GetRouletteType(2)
    self("txhhbCurrenyValue").text = rouletteType[2].." 购买"



    rouletteType = self:GetRouletteType(3)
    self("txthbCurrenyValue").text = rouletteType[2].." 购买"

    self("txDesc3thbplotteryDlg").text = "VIP"..rouletteType[6].."开放此功能"

    if rouletteType[6] > gData.userInfo.roleInfo.vipInfo[0] then
        self("imgsuo").visible = 1
        self("btnthbBuy").gray = 1
        self("btnthbBuy").touch = 0
        self("imgthbplotteryDlg").touch = 0
        self("txDesc3thbplotteryDlg").visible = 1
    else
        self("imgsuo").visible = 0
        self("btnthbBuy").gray = 0
        self("btnthbBuy").touch = 1
        self("imgthbplotteryDlg").touch = 1
        self("txDesc3thbplotteryDlg").visible = 0
    end

    
    self.imgptbplotteryDlg = self("imgptbplotteryDlg")
    self.imghhbplotteryDlg = self("imghhbplotteryDlg")
    self.imgthbplotteryDlg = self("imgthbplotteryDlg")
    self.imgptbpClotteryDlg = self("imgptbpClotteryDlg")
    self.imghhbpClotteryDlg = self("imghhbpClotteryDlg")
    self.imgthbpClotteryDlg = self("imgthbpClotteryDlg")
    -- self.hhTime = self:GetNextFreehhTime()
    -- self:StartTimer("SetNextFreehhTime", 0, self.time-1, 0);

    -- self("txDesc3hhbplotteryDlg").text = self:transformTimeToString(self.hhTime).."后免费";

    -- self.ttTime = self:GetNextFreettTime()
    -- self:StartTimer("SetNextFreettTime", 0, self.time-1, 0);

    -- self("txDesc3thbplotteryDlg").text = self:transformTimeToString(self.ttTime).."后免费";
    self.lybglotteryDlg = self("lybglotteryDlg")
    self.imgNewCard1 = self("imgNewCard1")
    self.imgNewCard2 = self("imgNewCard2")
    self.imgNewCard3 = self("imgNewCard3")
    self.imgNewCard4 = self("imgNewCard4")
    self.imgNewCard5 = self("imgNewCard5")
    
    self.cardSize = self("imgNewCard1"):getContentSize();
    self.posxC, self.posyC = 400, 381
--    self.imgNewCard1 = self("imgNewCard1")
--    self.imgNewCard1 = self("imgNewCard1")
    
    self:creatPtAmt()
    self:creatHhAmt()
    self:creatThAmt()
    
    
    self.amtSize = self("amtHh"):getContentSize();
    self.posx, self.posy = self("amtHh"):getPosition();
    cclog(self.posx.."~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"..self.posy)
    
    self.amtRepeat = true
    
end

function VPlantlotteryDlg:creatPtAmt()
    local amt = VArmature{name="amtPt", jsonName="plant1Lottery", layout="Center", offset={0, 35}, visible=0};
    self:Push(amt)
    self.amtPt = amt
    self:addAmtCallBack(amt);
end

function VPlantlotteryDlg:creatHhAmt()
    local amt = VArmature{name="amtHh", jsonName="plant2Lottery", layout="Center", offset={0, 35}, visible=0};
    self:Push(amt);
  
    self.amtHh = amt

    self:addAmtCallBack(amt);
end

function VPlantlotteryDlg:creatThAmt()
    local amt = VArmature{name="amtTh", jsonName="plant3Lottery", layout="Center", offset={0, 35}, visible=0};
  
    self:Push(amt)
    self.amtTh = amt

    self:addAmtCallBack(amt);
end

function VPlantlotteryDlg:LotteryAnimation(name)
    --    if self.gainBannerId  ~= -1 and gData.userInfo.bannerInfos.bannerInfos[self.gainBannerId] then
    --        local bannerInfo = gData.userInfo.bannerInfos.bannerInfos[self.gainBannerId];
    --        self.imageBanner:setTexture(bannerInfo:getImage());
    --    self.posxCard, self.posyCard = self("imgNewCard1"):getPosition();
    --    cclog(self.posxCard.."~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"..self.posyCard)
    --    cclog("bannerAnimation")
    
    
    if name == "amtPt" then
        self.dropCount = 5
        self.imgNewCard1:RunAction{"sequence", {"scaleTo", 0, 0.7, 0.7}, {"moveTo", 0, self.posxC, 460}, {"show"}, {"moveTo", 0.2, self.posxC, self.posyC - self.cardSize.height}, {"scaleTo", 0.2, 1, 1}, {self, "LightAnimation", 1}};
    else
        self.dropCount = 1
        local randomDuration = math.random(0,5)
        self.imgNewCard1:RunAction{"sequence", {"scaleTo", 0, 0.7, 0.7}, {"moveTo", 0, self.posxC, 460}, {"delayTime", math.abs(randomDuration - 1) / 4}, {"show"}, {"moveTo", 0.2, self.posxC, self.posyC - self.cardSize.height}, {"scaleTo", 0.2, 1, 1}, {self, "LightAnimation", 1}};
        self.imgNewCard2:RunAction{"sequence", {"scaleTo", 0, 0.7, 0.7}, {"moveTo", 0, self.posxC + self.cardSize.width + 40, self.posyC}, {"delayTime", math.abs(randomDuration - 2) / 4}, {"show"}, {"moveTo", 0.2, self.posxC + self.cardSize.width + 40, self.posyC - self.cardSize.height}, {"scaleTo", 0.2, 1, 1}, {self, "LightAnimation", 2}};
        self.imgNewCard3:RunAction{"sequence", {"scaleTo", 0, 0.7, 0.7}, {"moveTo", 0, self.posxC + 2 * self.cardSize.width + 70, self.posyC}, {"delayTime", math.abs(randomDuration - 3) / 4}, {"show"}, {"moveTo", 0.2, self.posxC + 2 * self.cardSize.width + 70, self.posyC - self.cardSize.height}, {"scaleTo", 0.2, 1, 1}, {self, "LightAnimation", 3}};
        self.imgNewCard4:RunAction{"sequence", {"scaleTo", 0, 0.7, 0.7}, {"moveTo", 0, self.posxC - self.cardSize.width - 40, self.posyC}, {"delayTime", math.abs(randomDuration - 4) / 4}, {"show"}, {"moveTo", 0.2, self.posxC - self.cardSize.width - 40, self.posyC - self.cardSize.height}, {"scaleTo", 0.2, 1, 1}, {self, "LightAnimation", 4}};
        self.imgNewCard5:RunAction{"sequence", {"scaleTo", 0, 0.7, 0.7}, {"moveTo", 0, self.posxC - 2 * self.cardSize.width - 70, self.posyC}, {"delayTime", math.abs(randomDuration - 5) / 4}, {"show"}, {"moveTo", 0.2, self.posxC - 2 * self.cardSize.width - 70, self.posyC - self.cardSize.height}, {"scaleTo", 0.2, 1, 1}, {self, "LightAnimation", 5}};
    end
--    else
--        self:resetUI();
--    end
end

function VPlantlotteryDlg:LightAnimation(index)
	if self.dropCount >= 5 then
        self.amtPt.visible= 0;
        self.amtHh.visible= 0;
        self.amtTh.visible= 0;
	    
        self.lybglotteryDlg.onClick="node:Parent():GetLotteryCard()"
	elseif self.dropCount <= 1 then
    	self.amtPt.visible= 0;
        self.amtHh.visible= 0;
        self.amtTh.visible= 0;
        self.dropCount = self.dropCount + 1
    else
        self.dropCount = self.dropCount + 1
	end
	
    local imglight = self("imglight"..index)
    imglight.visible = 1
    imglight:RunAction{"sequence", {"repeat", -1, {"rotateBy", 8, 360}}};
end

function VPlantlotteryDlg:GetLotteryCard(parameters)
    cclog("GetLotteryCard")
    self:resetUI();
end

function VPlantlotteryDlg:addAmtCallBack(amt)
    local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
        self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
    end 
    amt:setEventCallFunc(callBack);
end

function VPlantlotteryDlg:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
    cclog("onFrameEvent")
    local amt = bone:getArmature()

    if evt == "checkRsp" then
        if not self.amtRepeat then
--            if self.gainBannerId ~= -1 then
                self(amt.name):play("drop", nil, 0);
--            else
--            --                self:resetUI();
--            end
        end
    elseif evt == "finish" then
        self:LotteryAnimation(amt.name);
    end
end

function VPlantlotteryDlg:GetNextFreeTime(flag)
    local time = 0

    if flag == "pt" then
        time = (gData.userInfo.roleInfo.wheel_info.plant_primary_wheel_time or 0) - gData:currentTime()
    elseif flag == "hh" then
        time = (gData.userInfo.roleInfo.wheel_info.plant_secondary_wheel_time or 0) - gData:currentTime()
    else

    end

    if time < 0 then
    	time = 0
    end
    return time
end

--将时间(秒)按照格式转换为字符串
function VPlantlotteryDlg:transformTimeToString(time)
    local hour = math.modf(time/3600);
    local t1 = time%3600;
    local min = math.modf(t1/60);
    local sec = t1%60;
    if hour == 0 then
        local s = string.format("%02d分%02d秒",min,sec);
        return s;
    else
        local s = string.format("%02d时%02d分",hour,min);
        return s;
    end
end

-- function VPlantlotteryDlg:SetNextFreeTime(parameters)

--     local time = self:GetNextFreeTime()
        
--     if time == 0 then
--         self("txCostlotteryDlg3").visible = 0
--         self("lyrVcoinImage").visible = 0;
--         self("txCostlotteryDlg4").visible = 1
--         self("txTimelotteryDlg").visible = 0;
--     else
--         self:RecoverNextFreeTime();
--     end

   
--     -- self("imgYBlotteryDlg").visible = 0
-- end

function VPlantlotteryDlg:SetNextFreeptTime()

    local time = self:GetNextFreeTime("pt")
        
    if time == 0 then
        self("txDesc3ptbplotteryDlg").visible = 0
        self("imgptbCurrenyIcon").visible = 0
        self("imgptbFreeIcon").visible = 1
--        self("imgptbCurrenyValue").visible = 0
        self("txptbCurrenyValue").visible = 0
        self:StopTimer("SetNextFreeptTime")
    else
        self:RecoverNextFreeTime("pt");
    end

   
    -- self("imgYBlotteryDlg").visible = 0
end

function VPlantlotteryDlg:SetNextFreehhTime(parameters)

    local time = self:GetNextFreeTime("hh")
        
    if time == 0 then
        self("txDesc3hhbplotteryDlg").visible = 0
        self("imghhbCurrenyIcon").visible = 0
        self("imghhbFreeIcon").visible = 1
--        self("imghhbCurrenyValue").visible = 0
        self("txhhbCurrenyValue").visible = 0
        self:StopTimer("SetNextFreehhTime")
    else
        self:RecoverNextFreeTime("hh");
    end

   
    -- self("imgYBlotteryDlg").visible = 0
end

function VPlantlotteryDlg:RecoverNextFreeTime(flag)
    self:StopTimer("SetNextFree"..flag.."Time")
    local time = self:GetNextFreeTime(flag)
    self("txDesc3"..flag.."bplotteryDlg").text = self:transformTimeToString(time).."后免费";
    self("txDesc3"..flag.."bplotteryDlg").visible = 1
    self("tx"..flag.."bCurrenyValue").visible = 1
--    self("img"..flag.."bCurrenyValue").visible = 1
    self("img"..flag.."bCurrenyIcon").visible = 1
    self("img"..flag.."bFreeIcon").visible = 0
    self:StartTimer("SetNextFree"..flag.."Time", 1, time-1); 
end

function VPlantlotteryDlg:GetBagUsedCount(parameters)
    local count = gData.userInfo.plantInfos:PlantCount()
    count = count + gData.userInfo.suitInfo:getCount()
    count = count + gData.userInfo.bagInfos:itemCount()
    return count
end


function VPlantlotteryDlg:GetRouletteType( key )
    -- body
    local roulette_typeCsv = gData:readCsv("roulette_type.csv");
    local roulette_type = roulette_typeCsv:lineDataWithKey(key);
    if not roulette_type then 
        gLog("item_common.csv miss ID:%d", key);
        return nil;
    end
    return roulette_type
end

function VPlantlotteryDlg:Lottery(flag)
    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local aParam = {}
    cclog("type~~~~~~~~~~~~~~~~~"..flag)
    if flag == "pt" then
        local imgptbFreeIcon = self("imgptbFreeIcon")
        if not imgptbFreeIcon.visible then
            aParam.type = 2
            local rouletteType = self:GetRouletteType(1)
            local cost = rouletteType[2]
            if YB < cost then
                gWindow:showMoneyLackDlg(cost)
                return
            end
            gWindow:showPayTip("要抽植物么？", "抽植物需要消耗"..cost.."钻石", cost, self, "ReqPlantWheel", self, "ReqlotteryBack", aParam);
            return
        else
            aParam.type = 1
        end
    elseif flag == "hh" then
        local imghhbFreeIcon = self("imghhbFreeIcon")
        if not imghhbFreeIcon.visible then
            aParam.type = 4
            local rouletteType = self:GetRouletteType(2)
            local cost = rouletteType[2]
            if YB < cost then
                gWindow:showMoneyLackDlg(cost)
                return
            end
            gWindow:showPayTip("要抽植物么？", "抽植物需要消耗"..cost.."钻石", cost, self, "ReqPlantWheel", self, "ReqlotteryBack", aParam);
            return
        else
            aParam.type = 3
        end
    else
        aParam.type = 5
        local rouletteType = self:GetRouletteType(3)
            local cost = rouletteType[2]
            if YB < cost then
                gWindow:showMoneyLackDlg(cost)
                return
            end
        gWindow:showPayTip("要抽植物么？", "抽植物需要消耗"..cost.."钻石", cost, self, "ReqPlantWheel", self, "ReqlotteryBack", aParam);
        return
    end

    self:ReqPlantWheel(self, "ReqlotteryBack", aParam)
--    gWindow:showWaitTip("loading...");
end

function VPlantlotteryDlg:ReqPlantWheel(delege, callBack, aParam)
    self.lybglotteryDlg.onClick = nil
    self.lybglotteryDlg.visible = 1
    
    if aParam.type == 1 or aParam.type == 2 then
        self.imgptbplotteryDlg.visible= 0;
       
        self.imgptbpClotteryDlg:RunAction{"sequence", {"moveTo", 0, self.posx - self.amtSize.width - 50, self.posy + 50}, {"show"}, {"jumpBy", 0.5, self.amtSize.width + 50, 0, 100, 1}, {"delayTime", 0.2}, {self, "PlayAmtrue", aParam.type, aParam}};
    elseif aParam.type == 3 or aParam.type == 4 then
        self.imghhbplotteryDlg.visible= 0;

        self.imghhbpClotteryDlg:RunAction{"sequence", {"moveTo", 0, self.posx, self.posy + 50}, {"show"}, {"delayTime", 0.2}, {self, "PlayAmtrue", aParam.type, aParam}};
    else
        self.imgthbplotteryDlg.visible= 0;

        self.imgthbpClotteryDlg:RunAction{"sequence", {"moveTo", 0, self.posx + self.amtSize.width + 75, self.posy + 50}, {"show"}, {"jumpBy", 0.5, - self.amtSize.width - 75, 0, 100, 1}, {"delayTime", 0.2}, {self, "PlayAmtrue", aParam.type, aParam}};
    end
    
    
end

function VPlantlotteryDlg:PlayAmtrue(type, aParam)
    
    self.imgptbpClotteryDlg.visible = 0
    self.imghhbpClotteryDlg.visible = 0
    self.imgthbpClotteryDlg.visible = 0
    
    if type == 1 or type == 2 then
        self("amtPt").visible = 1
        self("amtPt"):play("swing")
    elseif type == 3 or type == 4 then
        self("amtHh").visible = 1
        self("amtHh"):play("swing")
    else
        self("amtTh").visible = 1
        self("amtTh"):play("swing")
    end
    
    gReq:MsgReqPlantWheel(self, "ReqlotteryBack", aParam)
   -- gWindow:showWaitTip("loading...");
    -- local req = {type=1}
    -- self:ReqlotteryBack(0, nil, req)
end

function VPlantlotteryDlg:ReqlotteryBack(result, rsp, req)
    if result == 0 then
        self:ReqlotterySuccess(rsp, req)
        
        
    else
        self:ReqlotteryFail(result, rsp, req)
    end
end

function VPlantlotteryDlg:ReqlotteryFail( ... )
    -- body
    self:resetUI();
end

function VPlantlotteryDlg:resetUI()
   
    
    self.amtPt.visible = 0;
    
    self.amtPt:stop()
--    self.amtPt:getAnimation():gotoAndPause(0)
--    self.amtPt:play("swing", nil, 0);
--    self.amtPt:setPosition(self.posx - self.amtSize.width - 50, self.posy);
    self.amtHh.visible = 0;
    self.amtHh:stop()
--    self.amtHh:getAnimation():gotoAndPause(0)
--    self.amtHh:play("swing", nil, 0);
    self.amtTh.visible = 0;
    self.amtTh:stop()
--    self.amtTh:getAnimation():gotoAndPause(0)
--    self.amtTh:play("swing", nil, 0);
    
--    self.imgptbplotteryDlg:setPosition(self.posx - self.amtSize.width - 50, self.posy)
    self.imgptbplotteryDlg.visible = 1;
--    self.imghhbplotteryDlg:setPosition(self.posx, self.posy)
    self.imghhbplotteryDlg.visible = 1;
--    self.imgthbplotteryDlg:setPosition(self.posx + self.amtSize.width + 75, self.posy)
    self.imgthbplotteryDlg.visible = 1;
    
    self.imgptbpClotteryDlg.visible = 0
    self.imghhbpClotteryDlg.visible = 0
    self.imgthbpClotteryDlg.visible = 0
    
    self.lybglotteryDlg.visible = 0
--    self.lybglotteryDlg.touch = 0
    
    for var = 1, 5 do
        local item = self("imgNewCard"..var)
        item.visible = 0
        -- item("imgStarC1").offset = {-40,13}
        -- item("imgStarC2").offset = {-20,13}
        -- item("imgStarC3").offset = {1,13}
        -- item("imgStarC4").offset = {21,13}
        -- item("imgStarC5").offset = {41,13}
        self("imglight"..var).visible = 0
    end

    rouletteType = self:GetRouletteType(3)
    self("txthbCurrenyValue").text = rouletteType[2].." 购买"

    if rouletteType[6] > gData.userInfo.roleInfo.vipInfo[0] then
        self("imgsuo").visible = 1
        self("btnthbBuy").gray = 1
        self("btnthbBuy").touch = 0
        self("imgthbplotteryDlg").touch = 0
        self("txDesc3thbplotteryDlg").visible = 1
    else
        self("imgsuo").visible = 0
        self("btnthbBuy").gray = 0
        self("btnthbBuy").touch = 1
        self("imgthbplotteryDlg").touch = 1
        self("txDesc3thbplotteryDlg").visible = 0
    end
end

function VPlantlotteryDlg:ReqlotterySuccess(rsp, req)
    gWindow:closeWaitTip()
    
    self("sunText").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeCurrency))
    
    if req.type == 1 or req.type == 3 then
        gData.noticeManager:modify(NoticeType.free_draw_card, -1)
        local rouletteType = self:GetRouletteType(math.ceil(req.type / 2))

        local flag = nil
        if req.type == 1 then
            flag = "pt"
            gData.userInfo.roleInfo:UpDataDescplantPrimaryWheelTime(gData:currentTime() + rouletteType[4] )
        else
            flag = "hh"
            gData.userInfo.roleInfo:UpDataDescplantSecondaryWheelTime(gData:currentTime() + rouletteType[4] )
        end

        local txpCurrenyValue = self("tx"..flag.."bCurrenyValue")
        
        if txpCurrenyValue then
            self:RecoverNextFreeTime(flag)
        end
    end
    -- local info = gData.userInfo.plantInfos.plants[rsp.infos[0].bi.id]
    
    self:SetLotteryCardInfo(rsp.infos)
    self.amtRepeat = false
end

function VPlantlotteryDlg:SetLotteryCardInfo(infos)
    local lotterData = gData.userInfo.plantInfos.plants
    local count = infos:Count()

    local rewards = {}

    for var = 0, count - 1 do
        table.insert(rewards, infos[var].bi.id)
    end

    rewards = self:RewardsSort(rewards, count)

    for var = 0, count - 1 do
        local info = VItemData:new()
        
            info:CreateWithPlantData(lotterData[rewards[var + 1]])
       

        local item = self("imgNewCard"..(var + 1));

        item.image = "carddiban"..info.quality..".png"
        item.quality = info.quality
        item("txCardName").text = info.name
        -- for var = 1, info.level do
        --     local imgStarC = item("imgStarC"..var)
            
        --     if info.quality >= 5 then
        --         imgStarC.offset = {imgStarC.offset.x - 1, 27}
        --     else
        --         imgStarC.offset = {imgStarC.offset.x, 13}
        --     end
            
        --     imgStarC.visible = 1
        -- end

        if (info.level or 0) > 0 then
                item("imgStarC").visible = 1
                item("txlevel").text = info.level
            else
                item("imgStarC").visible = 0
            end

            item("imgItemPlantC").image = info.image

            item("imgItemPlantC"):ReLayout()
    end
end

function VPlantlotteryDlg:RewardsSort(rewards, count)
    local newRewards = {}
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))

    for var = 1, count do
        local index = math.random(count - var + 1)
        table.insert(newRewards, rewards[index])
        table.remove(rewards, index)
    end

    return newRewards
end

function VPlantlotteryDlg:VipChageNotic( ... )
    -- body
    self("sunText").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeCurrency))

    rouletteType = self:GetRouletteType(3)
    self("txthbCurrenyValue").text = rouletteType[2].." 购买"

    if rouletteType[6] > gData.userInfo.roleInfo.vipInfo[0] then
        self("imgsuo").visible = 1
        self("btnthbBuy").gray = 1
        self("imgthbplotteryDlg").touch = 0
        self("txDesc3thbplotteryDlg").visible = 1
    else
        self("imgsuo").visible = 0
        self("btnthbBuy").gray = 0
        self("imgthbplotteryDlg").touch = 1
        self("txDesc3thbplotteryDlg").visible = 0
    end

    if self.vipLevel < gData.userInfo.roleInfo.vipInfo[0] then
        gWindow:showTip("恭喜vip等级提升了", 1)
        self.vipLevel = gData.userInfo.roleInfo.vipInfo[0]
    end
end

function VPlantlotteryDlg:onClick()
    --    local currentView = gView(-2)
    --    if currentView then
    --        currentView.visible = 1
    --    end
    self:StopTimer("SetNextFreeTime")
    VPlantlotteryDlg.super.onClick(self)
end