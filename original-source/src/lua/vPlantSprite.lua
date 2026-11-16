--vPlantSprite.lua
require "vProgcessTimer"


VPlantSprite = VClass("PlantSprite", VLayer)

function VPlantSprite:setFarmInfo(farmInfo, isSelf, scale)
    self.isSelf = isSelf;
    self.scaleCom = scale
    self.farmInfo = farmInfo;
    self:showStatus();

end

function VPlantSprite:ClearUpPlantStatus(key)
    --    local imgResource = gFarm("imgResource"..key)
    --    local txNextTime = gFarm("txNextTime"..key)
    --    local resAction = gFarm("resAction"..key)
    --    
    --    cclog("ccccccccccccccccccccccccccccccccccc")
    --    
    --    if imgResource ~= nil then
    --        imgResource:Delete()
    --    end
    --    if txNextTime ~= nil then
    --        txNextTime:Delete()
    --    end
    --    if resAction ~= nil then
    --        resAction:Delete()
    --    end
    self:StopResTime("OnTime");
    self:StopTimer("SetLvUpInfo")
    self:Delete()
end

function VPlantSprite:showStatus()
    local plant = self.farmInfo.plantInfo;
    if not plant.isWarPlant then
        if self.farmInfo:isHelp() then
            self:SetHelp(true);
        else
            self:SetHelp(false);
        end
    end
    self:ShowNextLvUpTime();
    self:LevelUpStart();
end

function VPlantSprite:SetStatusNodePos(node, s_height)
    local x, y = self.farmInfo.pos.x, self.farmInfo.pos.y
    local posX = (_CellPtx[y][x] + (_CellPtx[y][x + 1] - _CellPtx[y][x]) / 2) * self.scaleCom
    local posY = s_height + _CellPty[y][x] * self.scaleCom
    cclog("posx"..(x).."posy"..(y))
    cclog("xxxx"..node:getAnchorPoint().x.."yyyyyyyy"..node:getAnchorPoint().y)
    cclog("~~~~~~~~~~~~:"..(_CellPtx[y][x + 1]).."~~~~~~~~~~~"..(_CellPtx[y][x]))
    cclog("~~~~~~~~~~~~~~"..((_CellPtx[y][x] + (_CellPtx[y][x + 1] - _CellPtx[y][x]) / 2) * self.scaleCom).."~~~~~~~~~~~~"..(-_CellPty[y][x] * self.scaleCom))
    cclog("posx"..posX.."posy"..posY)
    cclog("~~~~~~~~~~~~~~~~~~~~~~~~nodewidth"..node:getContentSize().width)
    node:setPosition(posX, posY)
    --    node:ReLayout()
end

function VPlantSprite:SetHelp(vaule, data)
    self.isHelp = vaule;
    if vaule then
        if self.resArmature then
            self.resArmature:Delete();
            self.resArmature = nil;
        end

        if self.isSelf then
            self:ShowResource();
        else
            self:ShowHelpBubble(true);    
        end

        if data ~= nil then
            self.farmInfo:AddHelpStatus(PLANT_STATUS.PlantStatusHelp, data)
        end
    else
        if self.helpImage then
            self.helpImage:Delete();
            self.helpImage = nil;
        end

        self.farmInfo:removeStatus(PLANT_STATUS.PlantStatusHelp);

        if self.isSelf then
            self:ShowResource();
        else
            self:ShowHelpBubble(false);
        end
    end
end

function VPlantSprite:SetPos(scale)
    --    local offsetx = 5 - self.farmInfo.pos.y;
    --    local offsety = self.farmInfo.pos.x - 1;
    --
    --    local posx, posy = self:GetPosWithOffset(offsetx, offsety, fieldSize, ratio)
    local x, y = self.farmInfo.pos.x, self.farmInfo.pos.y
    --    local posx = (_CellPtx[y][x + 1] - _CellPtx[y][x]) * scale / 2  - self.size.width / 2 + _CellPtx[y][x] * scale
    --    local posy = (_CellPty[y + 1][x] - _CellPty[y][x]) * scale / 2 - self.size.height / 2 + _CellPty[y][x] * scale
    --    self:setPosition((_CellPtx[y][x] + (_CellPtx[y][x + 1] - _CellPtx[y][x]) / 2) * scale, _CellPty[y][x] * scale)
    local rect = self:getBoundingBox();
    local offsetx = rect.width/2;
    self.offset = {(_CellPtx[y][x] + (_CellPtx[y][x + 1] - _CellPtx[y][x]) / 2) * scale - offsetx, -_CellPty[y][x] * scale}
    --    self:setPosition(0, 0);
    cclog("posx"..(x).."posy"..(y))
    cclog("~~~~~~~~~~~~:"..(_CellPtx[y][x + 1]).."~~~~~~~~~~~"..(_CellPtx[y][x]))
    cclog("~~~~~~~~~~~~~~"..((_CellPtx[y][x] + (_CellPtx[y][x + 1] - _CellPtx[y][x]) / 2) * scale).."~~~~~~~~~~~~"..(-_CellPty[y][x] * scale))


    --    self.offset = {_CellPtx[y][x] * scale, -_CellPty[y][x] * scale}
end

--function VPlantSprite:GetPosWithOffset(offsetx, offsety, fieldSize, ratio)
--    local emendx = fieldSize.width / 2 - self.size.width / 2
--    local emendy = fieldSize.height - self.size.height - ratio.revisey * fieldSize.height
--
--    local posx = (ratio.x * offsety + (ratio.x - 1) * offsetx) * fieldSize.width + emendx + ratio.revisex * (1 - ratio.x) * fieldSize.width
--    local posy = (offsety * ratio.y + (1 - ratio.y) * offsetx) * fieldSize.height + emendy - offsetx * ratio.revisey * fieldSize.height
--
--    return posx, posy
--end

function VPlantSprite:OnTime(dt)
    self:ShowResource();
end

function VPlantSprite:showGrowPop(isHarvest, isGrowMax)
    local resType = self.farmInfo.plantInfo.resType;
    if not self.resArmature then
        local rect = self:getBoundingBox();
        local offsetx = 0--rect.width * 3 / 5 + 1;
        self.resArmature = VArmature:createArmature("airBubble", "", "Center");
        if resType ==1 then
            self.resArmature:changeDisplay("气泡", nil, 1);
        else
            self.resArmature:changeDisplay("气泡", nil, 0);
        end
        self.resArmature.scale = 1.5;
        self.resArmature:play("idle");

        self.resArmatureLayer = VLayer{size={100,90}, color={255,0,0,0}, layout="UpOut",offset={-offsetx,0}};
        self.resArmatureLayer.touch = 1;
        self.resArmatureLayer.onClick = "node:Parent():onClick()";
        self.resArmatureLayer:Push(self.resArmature);
        self:Push(self.resArmatureLayer);
    -- self.resArmature = self:Push(VImage{name = "imgResource"..self.farmInfo:ReturnKey(), touch = 1, layout = "Up", image = "jinbiduoxiaotubiao.png", offset={-offsetx,-60}, onClick = "node:Parent():onClick()"})
    --        self.resArmature = gFarm:Push(VImage{name = "imgResource"..self.farmInfo:ReturnKey(), touch = 1})--, onClick = "node:Parent():onClick()"})
    --        self.resArmature.delegate = self
    --        self.resArmature.onClick = "VCallBack(node.delegate, 'PlantReceive')"
    --        self.resArmature:ReLayout()
    --        self:SetStatusNodePos(self.resArmature, 100)
    end



    if isGrowMax then
        if resType == 1 then
            self.resArmature:changeDisplay("气泡", nil, 3);
        else
            self.resArmature:changeDisplay("气泡", nil, 2);
        end
        cclog("涨满出现资源")
        self.resArmatureLayer.visible = 1;
    --        self.resArmature:ReLayout()
    --        self:SetStatusNodePos(self.resArmature, 100)
    elseif isHarvest then
        if resType == 1 then
            self.resArmature:changeDisplay("气泡", nil, 1);
        else
            self.resArmature:changeDisplay("气泡", nil, 0);
        end

        cclog("可收获出现资源")
        self.resArmatureLayer.visible = 1;
    --        self.resArmature:ReLayout()
    --        self:SetStatusNodePos(self.resArmature, 100)
    else
        cclog("不能收获")
        self.resArmatureLayer.visible = 0;
    end


end

function VPlantSprite:ShowNextLvUpTime(parameters)
    --    local txTime = VTimeText{name = "txNextTime", layout = "Up", step = {0, -1}}
    --    local progcessTimer = VProgcessTimer{name = "proNextTime", image="xiangqingpaopao.png", percentage = 0, type = 0, direction = 0, layout = "Up", step = {0, -1}}
    --    self:Push(progcessTimer)
    --    progcessTimer:IncreaseAction(10,100)
    --    setLevelUpInfo
    if not self.isSelf then
        return
    end

    local timeSpace = gData.userInfo.manorInfo:levelUpTime(self.farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
    cclog("id:"..self.farmInfo.plantInfo.id.."时间:"..timeSpace.."类型"..LEVELUP_TYPE.LevelupPlant)
    if timeSpace == 0 then
        return
    end

    if self.UpgradeTimer == nil then
        local rect = self:getBoundingBox();
        local offsetx = 0--rect.width/2;
       
        self.UpgradeTimer = VUpgradeTimer{name = "txNextTime"..self.farmInfo:ReturnKey(), level = 100, bgImage = "zhiwujindutiaodi.png", image = "zhiwujindutiao.png", fontSize=20, layout = "Down", scale=1.5}
        self.UpgradeTimer.offset = {-offsetx, -140}
        self:Push(self.UpgradeTimer)
        --        self.UpgradeTimer:ReLayout()
        --        self:SetStatusNodePos(self.UpgradeTimer, 100)
        --        cclog("锚点"..self.UpgradeTimer:getAnchorPoint().x.."~~~~~~~~~"..self.UpgradeTimer:getAnchorPoint().y)
    end
    self.UpgradeTimer:stopTimer()
    self.UpgradeTimer:setTimer(timeSpace, self.farmInfo.plantInfo.timeCost)
    self.maxUpgradeTime = self.farmInfo.plantInfo.timeCost;
end

function VPlantSprite:LevelUpStart(parameters)
    local timeSpace = gData.userInfo.manorInfo:levelUpTime(self.farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
    -- cclog("id:"..self.farmInfo.plantInfo.id.."时间:"..timeSpace.."类型"..LEVELUP_TYPE.LevelupPlant)
    if timeSpace > 0 then
        self:StartTimer("SetLvUpInfo", timeSpace, 0, 0)
        if self.UpgradeTimer then
            self.UpgradeTimer:setTimer(timeSpace, self.farmInfo.plantInfo.timeCost)
            self.UpgradeTimer:startTimer()
            self.maxUpgradeTime = self.farmInfo.plantInfo.timeCost;
        end
    else
        self:StopTimer("SetLvUpInfo")
        if self.UpgradeTimer then
            self.UpgradeTimer:stopTimer();
            self.UpgradeTimer:Delete();
            self.UpgradeTimer = nil;
        end
    end
end

function VPlantSprite:ReMoveNextLvUpTime(parameters)
    self:StopTimer("SetLvUpInfo")
    --    local txNextTime = self("txNextTime")
    if self.UpgradeTimer then
        self.UpgradeTimer:Delete();
        --        txNextTime = nil;
        self.UpgradeTimer = nil
    end
    local layOperation = gView()("layOperation")
    if layOperation.visible ~= 0 and layOperation.tab == self.farmInfo then
        layOperation:closeLayer()
    end
end

function VPlantSprite:levelUpStaffThing()
    -- local exp = self.farmInfo.plantInfo.nextLevelCost.userExp;

    local rect = self:getBoundingBox();
    local offsetx = 0--rect.width*3/4;
    if not self.LevelUpAmature then

        self.LevelUpAmature = VArmature:createArmature("buildingUpdateAnimation", "", "Down", -offsetx, 0);
        self.LevelUpAmature.scale = 0.5;
        self:Push(self.LevelUpAmature); 
    end
    self.LevelUpAmature:play("update", nil, 0);
--    local exp = "Exp+";
--    local aText = VText{text=exp, fontSize=35, color={43,222,27}, layout="Center", offset={-offsetx, 20}, level=100};
--    aText:RunAction{{"hide"},{"delayTime",0.1},{"show"},{"moveBy",2,0,30},{"delete"}};
--    self:Push(aText);

    self.farmInfo:levelUp();
    self.farmInfo:RemoveLevelUpStart()

    self:StopTimer("SetLvUpInfo")
    if self.UpgradeTimer then
        self.UpgradeTimer:Delete();
        self.UpgradeTimer = nil;
    end

    local imageName = "battleStart.png"

    if self.farmInfo.plantInfo.plantLevel == 0 then
        imageName = "battleStartBlack.png"
    end

    self("imglevel").image = imageName
    self("txlevel").text = self.farmInfo.plantInfo.plantLevel

    local layOperation = gView()("layOperation")
    if layOperation.visible ~= 0 and layOperation.tab == self.farmInfo and layOperation.type == LEVELUP_TYPE.LevelupPlant then
        self:PlantOperationLay()
    else
        cclog("未重置")
    end

end

function VPlantSprite:SetLvUpInfo(parameters)
    -- local exp = self.farmInfo.plantInfo.nextLevelCost.userExp;
    -- gLog("VPlantSprite SetLvUpInfo exp = %d", exp);
    -- gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeExp, exp);
    if self.maxUpgradeTime and self.maxUpgradeTime < 5 then
        gData.userInfo.roleInfo:stopHeartBeatSynTimer(AttrType.AttrTypeExp, 5);
        gData.userInfo.roleInfo:stopHeartBeatSynTimer(AttrType.AttrTypeLevel, 5);
    end
    self.maxUpgradeTime = nil;

    self:levelUpStaffThing()
end

function VPlantSprite:RecoverLvInfo(parameters)
--    self:StopTimer("SetLvUpInfo")
--    local txNextTime = self("txNextTime")
--    if txNextTime then
--        txNextTime:Delete();
--        txNextTime = nil;
--    end
--    self.farmInfo:revertLevel();
--    local layOperation = gView()("layOperation")
--    if layOperation.visible ~= 0 and layOperation.tab == self.farmInfo then
--        layOperation:closeLayer()
--    end
end

function VPlantSprite:ShowResource()
    if not self.isSelf then
        return
    end
    local plant = self.farmInfo.plantInfo;
    if not plant.isWarPlant then
        cclog("StopTimer:~~~~~~~~~~~~~~~~~~OnTime")
        self:StopResTime("OnTime");
        local harvestTime, maxTime = self.farmInfo:timeForHarvest();
        if harvestTime == 0 then
            if maxTime == 0 then
                cclog("资源长满了")
                self:showGrowPop(true, true);
            else
                cclog("资源可收获但未涨满"..maxTime)
                self:showGrowPop(true, false);
                --                self:StartTimer("OnTime", maxTime, 0, 0);
                self.resTime = gDtr:getScheduler():scheduleScriptFunc( 
                    function () VCallBack(self, "OnTime"); end, maxTime, false);
            end
        else
            cclog("资源不能收获也未涨满"..harvestTime)
            self:showGrowPop(false, false);
            self:StopTimer("OnTime");
            --            self:StartTimer("OnTime", harvestTime, 0, 0);
            self.resTime = gDtr:getScheduler():scheduleScriptFunc( 
                function () VCallBack(self, "OnTime"); end, harvestTime, false);
            cclog("StartTimer:~~~~~~~~~~~~~~~~~~OnTime")
        end
    end
end

function VPlantSprite:ShowHelpBubble(isHelp)

end

function VPlantSprite:showChoosedAnimation()
    self:closeChoosedAnimation();
    if not self.animationArrow then
        local rect = self:getBoundingBox();
        local offsetx = 0 --rect.width*3/4;
        self.animationArrow = VImage{name = "imgArrow", layout = "Up", image = "xuanzhongjiantouxiao.png", offset={-offsetx,-60}};
        self:Push(self.animationArrow);
    end

    self.animationArrow:RunAction{"repeatForever", {"sequence", {"moveBy", 0.3, 0, 15}, {"moveBy", 0.3, 0, -15}}}
    self.animationArrow.visible = true;
    local plant = self("plant")
    plant:RunAction{"spawn",{{"scaleTo", 0.1, 1.2}, {"scaleTo", 0.1, 1}}, {"repeat", -1, {"sequence", {"tintTo", 0.65, 110, 110, 110}, {"tintTo", 0.65, 255, 255, 255}}}};
end

function VPlantSprite:closeChoosedAnimation()
    if self.animationArrow then
        self.animationArrow:stopAllActions();
        self.animationArrow:ReLayout();
        self.animationArrow.visible = false;
        local plant = self("plant")
        plant:stopAllActions()
        plant.color = {255, 255, 255}
    end
end

function VPlantSprite:didChoosed()
    self:showChoosedAnimation();
end

function VPlantSprite:didUnChoose()
    self:closeChoosedAnimation();
end

function VPlantSprite:OnHelpTimeOver()
    self:showStatus();
end

function VPlantSprite:onHelpClick()
    if not self.isHelp then
        gFarm:ReqManorPlantHelp(self.farmInfo)
    end
end

function VPlantSprite:onClick()
    if self.isSelf and self.farmInfo.canHarvest then
        local res, vipRes = self.farmInfo:produceValue()
        self:PlantReceive(res, vipRes)
        gFarm:ReqPlantReceive(self.farmInfo)
        return _VTouchType.PlantReceive;
    else
        self:PlantOperationLay();
        return _VTouchType.PlantSelect;
    end
end



function VPlantSprite:PlantOperationLay()
    local title = {}
    if self.farmInfo.plantInfo.plantLevel == 0 then
    title.text = self.farmInfo.plantInfo.plantName
    else
        title.text = self.farmInfo.plantInfo.plantName..self.farmInfo.plantInfo.plantLevel.."星"
    end
    title.color = gData:getNameColorByQuality(self.farmInfo.plantInfo.quality)
    local tab = self.farmInfo
    local buttons = {}
    --功能开关：植物
    if gData.userInfo.roleInfo:isFunctionOpen(GameFunction.plant_info) then
        local button1 = {}
        button1.callBack = "onbtnInfoClick"
        button1.delegate = self
        button1.icon = "mv_xinxi.png"
        button1.descText = "mv_zixinxi.png"
        table.insert(buttons, button1)
    end

    if self.isSelf then
        cclog("~~~~~剩余时间NNNNNNNNNN~~~~~"..gData.userInfo.manorInfo:levelUpTime(self.farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant))
        if gData.userInfo.roleInfo:isFunctionOpen(GameFunction.plant_levelup) then
            if gData.userInfo.manorInfo:levelUpTime(self.farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant) == 0 then
                

                if gData.userInfo.roleInfo:isFunctionOpen(GameFunction.plant_retrieve) then
                    local button2 = {}
                    button2.callBack = "onbtnBackClick"
                    button2.delegate = self
                    button2.icon = "mv_huishou.png"
                    button2.descText = "mv_zihuishou.png"
                    table.insert(buttons, button2)
                end

                if not self.farmInfo.plantInfo.isWarPlant and gData.userInfo.roleInfo:isFunctionOpen(GameFunction.plant_havest) then
                    if gData.userInfo.roleInfo:isFunctionOpen(GameFunction.havest_accelerate) then
                        local button3 = {}
                        button3.icon = "mv_zijiasuziyuananniu.png"
                        button3.descText = "mv_zijiasuziyuan.png"
                        local timeSpace = self.farmInfo:GetProduceSpace()   ---gData.userInfo.manorInfo:levelUpTime(self.farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
                        local cost = self:getTimeAccelerateCost(timeSpace)

                        if cost == 0 then
                            button3.gray = 1
                        else
                            button3.callBack = "onbtnSepUpClick"
                            button3.delegate = self
                            button3.cost = cost
                        end
                        table.insert(buttons, button3)
                    end
                end
                
                local button4 = {}
                button4.callBack = "onbtnLvUpClick"
                button4.delegate = self
                button4.icon = "mv_shengxing.png"
                button4.descText = "mv_zishengxing.png"
                table.insert(buttons, button4)
            else
                if gData.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_cancel) then
                    local button2 = {}
                    button2.callBack = "onbtnLvUpCancel"
                    button2.delegate = self
                    button2.icon = "mv_x.png"
                    button2.descText = "mv_ziquxiao.png"
                    table.insert(buttons, button2)
                end

                if gData.userInfo.roleInfo:isFunctionOpen(GameFunction.levelup_accelerate) then
                    local button7 = {}
                    button7.callBack = "onbtnLvUpSpeed"
                    button7.delegate = self
                    button7.icon = "mv_zilijiwanchenganniu.png" --"jisushengji.png"
                    button7.descText = "mv_zilijiwancheng.png"
                    local timeSpace = gData.userInfo.manorInfo:levelUpTime(self.farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
                    local cost = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupMonster, timeSpace, self.farmInfo.plantInfo.timeCost)
                    button7.cost = cost
                    table.insert(buttons, button7)
                end
            end
        end



        if not self.farmInfo.plantInfo.isWarPlant and gData.userInfo.roleInfo:isFunctionOpen(GameFunction.plant_havest) then

            local res, vipRes = self.farmInfo:produceValue()
            local button5 = {}
            if res == 0 then
                button5.gray = 1
            else
                button5.callBack = "onbtnReceiveClick"
                button5.delegate = self
            end
            button5.icon = "mv_shouhuo.png"
            button5.descText = "mv_zishouhuo.png"
            table.insert(buttons, button5)
        end

    end
    gAudio:playEffect("sys_plant_select.ogg");
    gFarm:ShowOperationLay(buttons, title, tab, LEVELUP_TYPE.LevelupPlant);
end


function VPlantSprite:PlantReceive()
    local res, vipRes = self.farmInfo:produceValue()
    local resType = self.farmInfo.plantInfo.resType;
    if resType == 1 then
        gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeSunshine, res);
    elseif resType == 2 then
        gData.userInfo.roleInfo:addAttrValue(AttrType.AttrTypeMoney, res);
    end
    self:showHarestAction(res, resType);



    -- if vipRes ~= 0 then
    --     self.resAction2 = self:Push(VText{name = "vipresAction", text = "+"..vipRes, layout = "UpOut", step = {-0.5, 0}, relative="resAction", color = {255, 0, 0}})
    --     self.resAction2:RunAction{{"spawn",{"moveBy", 2, 0, 10},{"sequence", {"delayTime",1.5},{"fadeTo",0.5,0}}},{"delete"}};
    -- end

    -- self.resAction1:RunAction{{"spawn",{"moveBy", 2, 0, 10},{"sequence", {"delayTime",1.5},{"fadeTo",0.5,0}}},{"delete"}};

    self.farmInfo:resetPlantTime();
    self:ShowResource();
    --    self:StopTimer("OnTime");
    --    self:StartTimer("OnTime", 5, 0, 0);
    self:StopResTime()
    self.resTime = gDtr:getScheduler():scheduleScriptFunc( 
        function () VCallBack(self, "OnTime"); end, 5, false);
end

function VPlantSprite:StopResTime(parameters)
    if self.resTime then
        gDtr:getScheduler():unscheduleScriptEntry(self.resTime)
        self.resTime = nil;
    end
end

function VPlantSprite:showHarestAction(res, resType)
    local delayTime = 0.3;
    local showTime = 0.1;
    local rect = self:getBoundingBox();
    local offsetx = 0--rect.width/2;

    local img = "qianbi.png";
    if resType == 1 then
        img = "yangguang.png";
    end

    for i=1, 8 do
        -- delayTime = delayTime + 0.1 * i;
        showTime = showTime + 0.05 * i;
        local aImage = VImage{image=img, layout="UpOut", offset={-offsetx,0}, scale=1.5};
        aImage:RunAction{{"hide"},{"delayTime",showTime},{"show"},
            {"sequence",{"moveBy",delayTime,0, 100},{"fadeTo",delayTime,0}},{"delete"}};
        self:Push(aImage);
    end

    local resLimit = 0
    if resType == 1 then

        local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
        resLimit = gData.userInfo.manorInfo.storeInfo.sunshineMax - sunShine;
    else
        local coin = gData:attrValue(AttrType.AttrTypeMoney)
        resLimit = gData.userInfo.manorInfo.storeInfo.coinMax - coin;
    end

    if res <= 0 and resLimit <= 0 then
        if resType == 1 then
            res = "金币已满"
        else
            res = "银币已满"
        end
    end

    local aText = VText{text=res, fontSize=60, color={43,222,27}, layout="UpOut", offset={-offsetx, -110}};
    aText:RunAction{{"hide"},{"delayTime",0.1},{"show"},{"moveBy",2,0,30},{"delete"}};
    self:Push(aText);
end

function VPlantSprite:onbtnLvUpClick()
    --    if not self.farmInfo.plantInfo.nextLevelBattle then
--    cclog("植物当前等级:"..self.farmInfo.plantInfo.plantLevel.."~~~~~~~~~"..self.farmInfo.plantInfo.maxLevel)
    if self.farmInfo.plantInfo.nextThingid == 0 then

        gWindow:showTip("该植物已经满星了!", 1)
        return 
    end

    --    if self.farmInfo.plantInfo.nextLevelCost.levelLimit > gData.userInfo.manorInfo.baseCampInfo.level then
    --        gWindow:showTip("需要庄园等级"..self.farmInfo.plantInfo.nextLevelCost.levelLimit, 1);
    --        return 
    --    end
    --    
    if gData.userInfo.manorInfo:idleFarmer() == 0 then
        --        gWindow:showTip("工人不足", 1)
        local mi = gData.userInfo.manorInfo;

        if mi:farmerNextCost() then
            gWindow:showFarmerLackTip();
        else
            gWindow:showTip("工人都在忙碌中，没有空闲的工人。", 1);
        end

        return 
    end
    local plantLvUpDlg = nil

    local plantLvUpDlg = VNode("vCardLevelUpDlg.vui");
    plantLvUpDlg:setCardInfo(self.farmInfo, 1);
    gView():Push(plantLvUpDlg);
end

function VPlantSprite:onbtnLvUpCancel()
    local aParma = {}
    aParma.farmInfo = self.farmInfo
    aParma.title = "停止升级吗?"
    aParma.content =  "停止升级只会返还"..(self:CancelResReturn()).."费用"

    gWindow:showConfirmTip("停止升级只会返还"..(self:CancelResReturn()).."费用", "确定", "取消", gFarm, "ReqManorPlantLevelUpCancel", "", "停止升级吗?",
        aParma);

end

function VPlantSprite:onbtnLvUpSpeed(parameters)
    local timeSpace = gData.userInfo.manorInfo:levelUpTime(self.farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
    local cost = gData:getTimeAccelerateCost(LEVELUP_TYPE.LevelupPlant, timeSpace, self.farmInfo.plantInfo.timeCost)

    gWindow:showPayTip("立刻完成升级吗？", "立刻完成需要消耗"..cost.."钻石", cost, gFarm, "ReqLevelUpAccelerate", self.farmInfo);

--    gFarm:ReqLevelUpAccelerate(self.farmInfo)
end

function VPlantSprite:CancelResReturn(parameters)
--    local plant = self.farmInfo.plantInfo
--    --    local costItem1 = gData:itemInfo(plant.nextLevelCost[4]);
--    local itemCommon = gData:LoadItemCommon()
--
--    local text = ""
--
--    if plant.nextLevelCost.coinCost ~= 0 then
--        --        text = text.." 金币"..math.floor(plant.nextLevelCost.coinCost * itemCommon.retResScale / 100)
--        text = text..itemCommon.retResScale.."%"
--    end
--    if plant.nextLevelCost.sunCost ~= 0 then
--        --        text = text.." 阳光"..math.floor(plant.nextLevelCost.sunCost * itemCommon.retResScale / 100)
--        text = text..itemCommon.retResScale.."%"
--    end    
--    --    if costItem1 ~= nil and plant.nextLevelCost[5] ~= 0 then      
--    --        text = text.."、"..costItem1[1]..plant.nextLevelCost[5]--.."、"..costItem2[1]..plant.nextLevelCost[7]
--    --    end

    return "60%"
end

function VPlantSprite:onbtnSepUpClick()
    --    local user_vipCsv = gData:readCsv("user_vip.csv");
    --    local vipLevel= gData.userInfo.roleInfo.vipInfo[0]
    --    local accelerateLimit = user_vipCsv:lineDataWithKey(vipLevel);



    cclog("今日以加速次数"..gData.userInfo.roleInfo.dayInfo.accelerate_produce_times.."~~~~~~~~~~"..idx_vip_accProduce)
    if gData.userInfo.roleInfo.dayInfo.accelerate_produce_times >= gData.userInfo.roleInfo.vipInfo[idx_vip_accProduce] then
        gWindow:showTip("今日植物最多加速"..gData.userInfo.roleInfo.vipInfo[idx_vip_accProduce].."次")
        return
    end

    local timeSpace = self.farmInfo:GetProduceSpace()   ---gData.userInfo.manorInfo:levelUpTime(self.farmInfo.plantInfo.id, LEVELUP_TYPE.LevelupPlant)
    local cost = self:getTimeAccelerateCost(timeSpace)

    --    gWindow:showConfirmTip("立即加速生产吗？", "确定", "取消", gFarm, "ReqPlantAccelerate", "", "立即完成升级吗？",
    --        self.farmInfo);

    gWindow:showPayTip("立即加速生产吗？", "立即加速需要消耗"..cost.."钻石", cost, gFarm, "ReqPlantAccelerate", self.farmInfo);

end

function VPlantSprite:getTimeAccelerateCost(leftTime)


    local p1 = 0.0000006;
    local p2 = 1.015;
    return math.ceil(math.pow(p1 * math.pow(leftTime, 1.6588), p2));
end


function VPlantSprite:onbtnReceiveClick()
    local res, vipRes = self.farmInfo:produceValue()
    self:PlantReceive(res, vipRes)
    gFarm:ReqPlantReceive(self.farmInfo)

end

function VPlantSprite:onbtnBackClick()

--    local open = gData.userInfo.roleInfo.bagSize.cur_value
--    local userdcount = gData:GetBagUsedCount()
--    
--    if open <= userdcount then
--        gWindow:showTip("背包剩余空间不足!请先清理背包", 1);
--        return
--    end
    
    gWindow:showConfirmTip("点击确定将使种植在庄园的植物放回背包，放回背包的植物将不参与防守。", "确定", "取消", gFarm, "ReqManorPlantPlaceToBag", "", "回收植物吗?",
        self.farmInfo);
end

function VPlantSprite:onbtnStrengClick()
    local ip = VNode("vIntensifyPlantDlg.vui");
    ip.plantInfo = self.farmInfo.plantInfo;
    self:getView():Push(ip);
end

function VPlantSprite:onbtnInfoClick()

    showCardInfoDlgById(self.farmInfo.plantInfo.thingid, 1)
end

function VPlantSprite:checkClick(touch)
    --    if self:IsInRect(touch) then
    --        return self:onClick();
    --    end
    return false;
end

function VPlantSprite:isLevelOping()
    return self.isLevelOpreation;
end

function VPlantSprite:setLevelOpreation(isOp)
    self.isLevelOpreation = isOp;
    if isOp then
        self:StartTimer("levelOpreationTimeOut", 20, 0);
    else
        self:StopTimer("levelOpreationTimeOut");
    end
end

function VPlantSprite:levelOpreationTimeOut()
    self.isLevelOpreation = false;
end