--vTrainingLayer.lua

VTrainingLayer = VClass("TrainingLayer", VLayer)


-- function VTrainingLayer:IsInRectLua(touch)
function VTrainingLayer:CheckAreaClick(touch)
	local location = self:convertTouchToNodeSpace(touch);
--	local size = self.size;
--	local rect = cc.rect(0, 0, size.width, size.height/2);
    
    if self.trainInfo.x == -1 or not self.atctionOver then
        cclog("全屏区域点击")
        return true
    end
    
    cclog(location.x.."~~~~~~~~~~~"..location.y.."~~~~~~~~~~~~~"..self.rectD.width.."~~~~~~~~~"..self.rectD.height)
	if self.atctionOver and cc.rectContainsPoint(self.rectD, location) then
        cclog("指定区域点击")
        -- self:RecoverBackGround()
--        self:RunAction{"sequence", {"delayTime", 0.5}, {"@ControlAreaClick"}}
       
            -- self:ControlAreaClick()
            return false;

	end

	return true;
end

function VTrainingLayer:onTouchBase(touch)
    self._winpos = self:getWinPos(-1);
    if not self:CheckAreaClick(touch) then
        self.isTouchedIn = true;
        self:InitListener(false);
        local touchBegin = self:getParent():convertTouchToNodeSpace(touch);
        self.touchBegin1 = touchBegin;
    else
        self.isTouchedIn = false;
        self:InitListener(true);
    end
    return true;
end

function VTrainingLayer:onMoveBase(touch)
    -- self:InitListener(true);
    self.isMoved = true;
end

function VTrainingLayer:onLeaveBase(touch)
    if not self:CheckAreaClick(touch) then
        cclog("onLeave指定区域点击")
        if self.isTouchedIn then
            if self.trainInfo.retiveArea == "manorView" then
                if not self.isMoved then
                    self:RecoverBackGround()
                    self:ControlAreaClick()
                else
                    local location = self:getParent():convertTouchToNodeSpace(touch);
                    local pos = cc.pSub(location, self.touchBegin1);
                    if math.abs(pos.y) < 5 and math.abs(pos.x) < 5 then
                        self:RecoverBackGround()
                        self:ControlAreaClick()
                    end
                end
            else
                self:RecoverBackGround()
                self:ControlAreaClick()
            end
        end
    else
       cclog("onLeave全屏区域点击")
       self:AllAreaClick()
    end
    self.isMoved = false;
end

function VTrainingLayer:Init( attr )
    -- body
    VTrainingLayer.super.Init(self, attr)
    self:NeedEvent(Eff_onEnter);
	self:SetLevel()
    self.move = true;
	
    gMainView.manorView:SetMove(false)
end

function VTrainingLayer:onPush()
    
--    self.layer1 = gView():Push(VLayer{name="Layer1", layout = "Left", color={0,0,0}, opacity=200, visible=0})
--    self.layer2 = gView():Push(VLayer{name="Layer2", relative = "Layer1", layout = "UpRightOut", color={0,0,0}, opacity=200, visible=0})
--    self.layer3 = gView():Push(VLayer{name="Layer3", layout = "Right", color={0,0,0}, opacity=200, visible=0})
--    self.layer4 = gView():Push(VLayer{name="Layer4", relative = "Layer1", layout = "DownRightOut", color={0,0,0}, opacity=200, visible=0})
    
--    <Layer="Layer1", layout = "Left", color=[0,0,0], opacity=200, visible=0>
--    <Layer="Layer2", relative = "Layer1", layout = "UpRightOut", color=[0,0,0], opacity=200, visible=0>
--    <Layer="Layer3", layout = "Right", color=[0,0,0], opacity=200, visible=0>
--    <Layer="Layer4", relative = "Layer1", layout = "DownRightOut", color=[0,0,0], opacity=200, visible=0>
    
    self.layer1 = self("Layer1")
    self.layer2 = self("Layer2")
    self.layer3 = self("Layer3")
    self.layer4 = self("Layer4")
    self.imgArrow1 = self("imgArrow1")
    self.imgArrow2 = self("imgArrow2")
    self.imgArrow3 = self("imgArrow3")
    self.imgArrow4 = self("imgArrow4")
    self.imgAreaClick = self("imgAreaClick")
--    self:SetRoleScale()
    
    self.posRela = 1.5
    
    local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
        self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
    end 
    
    self("imgdafu1"):setEventCallFunc(callBack);
    self("imgdafu2"):setEventCallFunc(callBack);
    self("imgcorpse1"):setEventCallFunc(callBack);
    self("imgcorpse2"):setEventCallFunc(callBack);

end

function VTrainingLayer:SetRoleScale(parameters)
    local imgdafuWord1 = self("imgdafuWord1")
    local txdafuWord1 = self("txdafuWord1")
    
    self("imgdafu1").scale = gView():getScaleX() / 2 * 1.67
    self("imgdafuWord1").size = {450 * gView():getScaleX(),  75 * gView():getScaleX()}
    self("txdafuWord1").scale = gView():getScaleX()
    
    
    self("imgdafu2").scale = gView():getScaleX() / 2 * 1.67
    self("imgdafuWord2").size = {450 * gView():getScaleX(),  75 * gView():getScaleX()}
    self("txdafuWord2").scale = gView():getScaleX()
    
    self("imgcorpse1").scale = gView():getScaleX() / 2 * 1.67
    self("imgcorpseWord1").size = {450 * gView():getScaleX(),  75 * gView():getScaleX()}
    self("txcorpseWord1").scale = gView():getScaleX()
    
    self("imgcorpse2").scale = gView():getScaleX() / 2 * 1.67
    self("imgcorpseWord2").size = {450 * gView():getScaleX(),  75 * gView():getScaleX()}
    self("txcorpseWord2").scale = gView():getScaleX()
end

function VTrainingLayer:onPushFinishBase(parameters)
--    self:RunAction{"sequence", {"delayTime", 1}, {"@roleSayAtctionStart"}}
    self:SetRoleScale()
    self:SetTrainingScene()
end

function VTrainingLayer:SetLevel()
	self.level = 50000
end

function VTrainingLayer:SetTrainInfo(info)
    local trainInfo = {}
    trainInfo.id = info.id
    trainInfo.limitid = info.limitid
    trainInfo.limitLevel = info.limitLevel
    trainInfo.limitLevel = info.limitLevel
    trainInfo.limitRes1 = info.limitRes1
    trainInfo.resCount1 = info.resCount1
    trainInfo.limitRes2 = info.limitRes2
    trainInfo.resCount2 = info.resCount2
    trainInfo.place = info.place
    trainInfo.farmx = info.farmx
    trainInfo.farmy = info.farmy
    trainInfo.scale = info.scale
    trainInfo.dafuPlace = info.dafuPlace
    trainInfo.dafuText = info.dafuText
    trainInfo.corpsePlace = info.corpsePlace
    trainInfo.corpseText = info.corpseText
    trainInfo.x = info.x
    trainInfo.y = info.y
    trainInfo.width = info.width
    trainInfo.height = info.height
    trainInfo.btName = info.btName
    trainInfo.arrow = info.arrow
    trainInfo.save = info.save
    trainInfo.retiveArea = info.retiveArea
    cclog("设置场景信息了:"..trainInfo.btName.."~~~~~~~~~~~~~~"..trainInfo.retiveArea)
    trainInfo.otherLimit = info.otherLimit
    trainInfo.action = info.action
    
    self.trainInfo = trainInfo
end


function VTrainingLayer:RecoverScene(parameters)
    self.opacity = 0
end


function VTrainingLayer:SetTrainingScene()
--    self:SetbackGround()
    self:RecoverBackGround()
--    self:SetbackGround()
    self:SetRole("dafu")
    self:SetRole("corpse")
    self:SetManorScene()
--    self:SetArrow()
end

function VTrainingLayer:SetManorScene()
    if self.trainInfo.farmx == -1 then
--        self:RunAction{"sequence", {"delayTime", 1}, {"@SetbackGround"}}
        cclog("屏幕无移动")
        self:SetbackGround()
        return
    end
    
    local srcRect = {}
    srcRect.x = self.trainInfo.farmx
    srcRect.y = self.trainInfo.farmy
    
    if self.trainInfo.scale == "" or self.trainInfo.scale == nil or self.trainInfo.scale == true then
        self.trainInfo.scale = 1
    end
    
    gMainView.manorView:SetTrainingScene(srcRect, self.rectD, tonumber(self.trainInfo.scale))
end

function VTrainingLayer:ScaleManor()
    if self.trainInfo.scale == "" then
        return
    end
    
    gMainView.manorView:Scale(tonumber(self.trainInfo.scale))
end

function VTrainingLayer:SetArrow()
    self.imgArrow1.visible = 0
    self.imgArrow2.visible = 0
    self.imgArrow3.visible = 0
    self.imgArrow4.visible = 0
    self.imgArrow1:StopAction()
    self.imgArrow2:StopAction()
    self.imgArrow3:StopAction()
    self.imgArrow4:StopAction()
    if self.trainInfo.arrow ~= 0 and self.trainInfo.arrow ~= "" and self.trainInfo.arrow ~= nil then
        local arrow = self("imgArrow"..self.trainInfo.arrow)
        arrow:ReLayout()
--        arrow:RunAction{"sequence", {"delayTime", 1.2}, {"show"}}
--        arrow.visible = 1
        local signX = 1
        local signY = -1
        if self.trainInfo.arrow == 2 then
            signX = -1
        elseif self.trainInfo.arrow == 3 then
            signY = 1
        elseif self.trainInfo.arrow == 4 then
            signX = -1
            signY = 1
        end
        
        cclog("方向:"..signX.."~~~~~~~~~~~~~"..signY)
        
        self.imgAreaClick.visible = true
        
        self.imgAreaClick:RunAction{{"sequence", {"fadeTo", 0, 0}, {"show"}, {"repeat", -1, {"sequence", {"fadeTo", 0.5, 255}, {"fadeTo", 0.5, 0}}}}};
        arrow:RunAction{"sequence", {"show"}, {"repeat", -1, {"sequence",{"moveBy", 0.5, -signX * 10, signY * 10}, {"moveBy", 0.5, signX * 10, -signY * 10}}}}
    end
end

function VTrainingLayer:RecoverBackGround()
    self.opacity = 200
    self.layer1.visible = 0
    self.layer2.visible = 0
    self.layer3.visible = 0
    self.layer4.visible = 0
    
    self.imgArrow1.visible = 0
    self.imgArrow2.visible = 0
    self.imgArrow3.visible = 0
    self.imgArrow4.visible = 0
    self.imgAreaClick.visible = 0
    
    self.atctionOver = false
end

function VTrainingLayer:SetbackGround()
    
    if self.trainInfo.x == -1 and self.trainInfo.btName == -1 then
        cclog("设置全局点击")
        self.opacity = 200
        self.layer1.visible = 0
        self.layer2.visible = 0
        self.layer3.visible = 0
        self.layer4.visible = 0
    else
        cclog("设置局部点击")
        self.opacity = 0
        
        if self.trainInfo.x ~= -1 then
            
            if self.trainInfo.retiveArea ~= "" then
                cclog("设置局部点击根据相对控件设置")
                local node = gView()(self.trainInfo.retiveArea)
                
                if not node then
                    cclog("不存在"..self.trainInfo.retiveArea)
                    gMainView.manorView:SetMove(true)
                    cclog("retiveArea删除")
                    self:Delete()
                    self = nil
                    return
                end
                
                local scaleX = 1--manorView:getContentSize().width / 2235  * 1.54 * gView():getScaleX()
                local scaleY = 1--manorView:getContentSize().height / 1474 * 1.54 * gView():getScaleY()
                if self.trainInfo.retiveArea == "manorView" then
                    scaleX = node.scale * 1.54
                    scaleY = node.scale * 1.54
                end
                local pos = node:convertToWorldSpace(cc.p(0,0))

                local x = (self.trainInfo.x  * scaleX * gView():getScaleX() + pos.x)
                local y = (self.trainInfo.y  * scaleY * gView():getScaleY() + pos.y) 
--                local x = self.trainInfo.x * scaleX + node:convertToWorldSpace(cc.p(0,0)).x
--                local y = self.trainInfo.y * scaleY + node:convertToWorldSpace(cc.p(0,0)).y


                local width = self.trainInfo.width * scaleX * gView():getScaleX()
                local height = self.trainInfo.height * scaleY * gView():getScaleY()
                
                
--                cclog("posS"..posX.x.."posS"..posX.y.."width"..width.."height"..height.."self.trainInfo.retiveArea:"..self.trainInfo.retiveArea)
--                cclog("self:getContentSize().width"..self:getContentSize().width.."self:getContentSize().height"..self:getContentSize().height)
--                cclog("pos.x"..pos.x.."pos.y"..pos.y.."width"..width.."height"..height.."self.trainInfo.retiveArea:"..self.trainInfo.retiveArea)
--                cclog("x"..x.."y"..y.."width"..width.."height"..height.."self.trainInfo.retiveArea:"..self.trainInfo.retiveArea)
                self:showControlArea(x, y ,width, height)
                
                
                cclog("ScaleX   "..gView():getScaleX().."   ScaleY   "..gView():getScaleY())
                cclog("gWindow   "..gWindow.size.width.."   gWindow   "..gWindow.size.height)
                cclog("layer1   "..self.layer1:getContentSize().width.."   layer1   "..self.layer1:getContentSize().height)
                cclog("MainView   "..gView()("MainView"):getContentSize().width.."   MainView   "..gView()("MainView"):getContentSize().height)
                cclog("MainView   "..gView():getContentSize().width.."   MainView   "..gView():getContentSize().height)
                cclog("MainView   "..gView("MainView"):getContentSize().width.."   MainView   "..gView("MainView"):getContentSize().height)
                
            else
                cclog("设置局部点击不根据相对控件设置")
--            layer1.size = {self.trainInfo.x, gWindow.size.height}
--            layer2.size = {self.trainInfo.width, gWindow.size.height - self.trainInfo.y - self.trainInfo.height}
--            layer3.size = {gWindow.size.width - self.trainInfo.x - self.trainInfo.width, gWindow.size.height}
--            layer4.size = {self.trainInfo.width, self.trainInfo.y}
                self:showControlArea(self.trainInfo.x, self.trainInfo.y, self.trainInfo.width, self.trainInfo.height)
            end
            
        else
            cclog("设置局部点击根据按钮设置"..self.trainInfo.btName)
            
            local tableName, btName, itemName, cellNum = gData:TrainInfoBtNameFormat(self.trainInfo.btName)
            local bt = nil
--            local bt = gView()(self.trainInfo.btName)
              if tableName ~= nil then
                cclog("~~~~按钮"..self.trainInfo.btName)
--                local num = string.sub(self.trainInfo.btName, 19, -1)
--                local btName = string.sub(self.trainInfo.btName, 1, 18)
--                local table = gView()("tabLevelView")
                local table = gView()(tableName)
                if not table then
                    cclog("不存在table"..tableName)
                    gMainView.manorView:SetMove(true)
                    cclog("btName删除")
                    self:Delete()
                    self = nil
                    return
                end
                
                if not cellNum or cellNum == "" then
                    cclog("不存在数字"..cellNum)
                    gMainView.manorView:SetMove(true)
                    cclog("btName删除")
                    self:Delete()
                    self = nil
                    return
                end
                local cell = table:cellAtIndex(tonumber(cellNum) - 1)
                
                if not cell then
                    cclog("不存在cell"..cell)
                    gMainView.manorView:SetMove(true)
                    cclog("btName删除")
                    self:Delete()
                    self = nil
                    return
                end
                
                if itemName == nil then
                    bt = cell(btName)
                else
                    bt = cell(itemName)(btName)
                end

            else
                bt = gView()(self.trainInfo.btName)
            end
            
            if not bt then
                cclog("不存在"..self.trainInfo.btName)
                gMainView.manorView:SetMove(true)
                cclog("btName删除")
                self:Delete()
                self = nil
                return
            end
            
            if tableName ~= nil then
                gView()(tableName):setTouchEnabled(false)
            end
            
            
                local pos = bt:convertToWorldSpace(cc.p(0,0))
                local width, height = bt:getContentSize().width, bt:getContentSize().height
--                layer1.size = {pos.x, gWindow.size.height}
--                layer2.size = {width, gWindow.size.height - pos.y - height}
--                layer3.size = {gWindow.size.width - pos.x - width, gWindow.size.height}
--                layer4.size = {width, pos.y}
                local scaleX = 1--manorView:getContentSize().width / 2235  * 1.54 * gView():getScaleX()
                local scaleY = 1--manorView:getContentSize().height / 1474 * 1.54 * gView():getScaleY()
                if self.trainInfo.retiveArea == "manorView" then
                    local node = gView()(self.trainInfo.retiveArea)
                    scaleX = node.scale
                    scaleY = node.scale
                end

                self.trainInfo.x = pos.x
                self.trainInfo.y = pos.y
                self.trainInfo.width = width  * scaleX * gView():getScaleX()
                self.trainInfo.height = height  * scaleY * gView():getScaleY()
                
                cclog("按钮区域pos.x"..pos.x.."pos.y"..pos.y.."width"..width.."height"..height.."self.trainInfo.retiveArea:"..self.trainInfo.retiveArea)
                
                self:showControlArea(self.trainInfo.x, self.trainInfo.y, self.trainInfo.width, self.trainInfo.height)
                
--                self.rectD = cc.rect(self.trainInfo.x, self.trainInfo.y, self.trainInfo.width, self.trainInfo.height);
            
        end
        
        self.layer1.visible = 1
        self.layer2.visible = 1
        self.layer3.visible = 1
        self.layer4.visible = 1
    end
    
    self:SetArrow()
--    local layer1
    self.atctionOver = true
end

--function VTrainingLayer:ShowbackGround()
--	if self.trainInfo.x == -1 and self.trainInfo.btName == -1 then
--        self.opacity = 200
--        self.layer1.visible = 0
--        self.layer2.visible = 0
--        self.layer3.visible = 0
--        self.layer4.visible = 0
--    else
--        self.opacity = 0
--        self.layer1.visible = 1
--        self.layer2.visible = 1
--        self.layer3.visible = 1
--        self.layer4.visible = 1
--    end
--    
--    
--    self.atctionOver = true
--end


function VTrainingLayer:showControlArea(x, y, width, height)
    self.layer1.size = {x, gWindow.size.height}
    self.layer2.size = {width, gWindow.size.height - y - height}
    self.layer3.size = {gWindow.size.width - x - width, gWindow.size.height}
    self.layer4.size = {width, y}
    self.imgAreaClick.size = {width, height} 
    self.rectD = cc.rect(x, y, width, height);
end


function VTrainingLayer:SetRole(role)
    if self.trainInfo[role.."Place"] ~= 0 then
        if (self[role.."LastP"] == nil or self[role.."LastP"] == 0) and self.trainInfo[role.."Place"] ~= 0 then
            self:ShowRole(role)
        elseif self[role.."LastP"] ~= 0 and self.trainInfo[role.."Place"] ~= self[role.."LastP"] then
            self:ShowRole(role)
        else
            self:ShowRoleSay(role)
        end
    else
--        self("img"..role.."1").visible = 0
--        self("img"..role.."2").visible = 0
        if self[role.."LastP"] ~= 0 and self[role.."LastP"] ~= nil then
            self:RoleLeave(role)
        end
    end
end

--function VTrainingLayer:IsArea()
--	
--end

function VTrainingLayer:ShowRole(role)
    local startPos = 0
    if self.trainInfo[role.."Place"] == 2 then
        startPos = gWindow.size.width
    end

    self("img"..role.."1").visible = 0
    self("img"..role.."2").visible = 0
    local txroleWord = self("tx"..role.."Word"..self.trainInfo[role.."Place"])
    local imgrole = self("img"..role..self.trainInfo[role.."Place"])
    local imgroleWord = self("img"..role.."Word"..self.trainInfo[role.."Place"])
    txroleWord.text = self.trainInfo[role.."Text"]
    imgroleWord:setScaleX((self.posRela - self.trainInfo[role.."Place"]) * 2)
    cclog("***** scale = %f", (self.posRela - self.trainInfo[role.."Place"]) * 2);
--    imgroleWord.layout = "LeftOut"
--    imgroleWord.offset = {-200, 0}
--    self:ReLayout()
    cclog("***** imgrole.x = %f,  y = %f", imgrole:getPositionX(), imgrole:getPositionY());
    cclog("***** startPos:x = %f", startPos);
    cclog("****** size.w = %f, size.h = %f",  imgroleWord:getContentSize().width, imgroleWord:getContentSize().height);
    
    local sign = (self.posRela - self.trainInfo[role.."Place"]) * 2
    
    local x = imgrole:getContentSize().width * imgrole:getScaleX() * imgrole:getAnchorPoint().x - (sign - 1) * imgrole:getContentSize().width * imgrole:getScaleX() / 4;
    local y = imgrole:getContentSize().height * imgrole:getScaleY() * imgrole:getAnchorPoint().y;
    local angle = imgrole:getRotation()
    
    
    
    
--    imgroleWord.offset = {sign * imgrole:getContentSize().width / 2 + sign * 10, - sign * 50}
    
    cclog("ccccccccccccccc"..(sign * imgrole:getContentSize().width / 2 + sign * 10))
--    imgrole:RunAction{"sequence", {"show"}, {"moveTo", 0.4, 400, 100}, {"repeat", 1, {"sequence", {"rotateTo", 0.05, angle + 20}, {"rotateTo", 0.1, angle - 20}, {"rotateTo", 0.05, 0}}}}
--    imgrole:RunAction{"sequence", {"show"}, {"moveTo", 0.4, (self.posRela - self.trainInfo[role.."Place"]) * 2 * x + startPos, y}, {"repeat", 1, {"sequence", {"rotateTo", 0.05, angle + 20}, {"rotateTo", 0.1, angle - 20}, {"rotateTo", 0.05, 0}}}}
    imgrole:RunAction{"sequence", {"show"}, {"moveTo", 0.4, sign * x + startPos, y}, {"spawn", {self, "ShowImgroleWord", imgrole, imgroleWord, txroleWord, startPos, sign}, {self, "roleSayAtctionStart", imgrole}}}
--    imgroleWord:RunAction{"sequence", {"delayTime", 0.6}, {"show"}, {{self, "roleSayAtctionStart", imgrole}}}
    
    
    self[role.."LastP"] = self.trainInfo[role.."Place"]
end

function VTrainingLayer:ShowImgroleWord(imgrole, imgroleWord, txroleWord, startPos, sign)
    local posX = startPos + sign * imgrole:getContentSize().width * imgrole:getScaleX() + (imgroleWord:getContentSize().width / 2 - 30) * sign
    local posY = imgrole:getContentSize().height * imgrole:getScaleY() - 80 * gView():getScaleX()
    imgroleWord:setPosition(posX, posY)
--    imgroleWord.offset = {sign * 10, -50 * sign}
--    imgroleWord.offset = {200, -200}
--    txroleWord.offset = [sign * 10, -50 * sign]
--	imgroleWord:ReLayout()
    txroleWord:ReLayout()
	imgroleWord.visible = 1
    txroleWord:RunAction{"sequence", {"delayTime", 0.1}, {"show"}}
end

function VTrainingLayer:roleSayAtctionStart(imgrole)
	imgrole:play("talk", -1, 0)    
end

function VTrainingLayer:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
    if evt == "finishTalk" then
        bone:getArmature():play("idle");
    end
end

function VTrainingLayer:ShowRoleSay(role)
    
    
    if self.trainInfo[role.."Text"] == "" then
        self("img"..role.."Word"..self.trainInfo[role.."Place"]).visible = 0
        self("tx"..role.."Word"..self.trainInfo[role.."Place"]).visible = 0
    else
        self("img"..role.."Word"..self.trainInfo[role.."Place"]).visible = 1
        self("tx"..role.."Word"..self.trainInfo[role.."Place"]).visible = 1
        self("tx"..role.."Word"..self.trainInfo[role.."Place"]).text = self.trainInfo[role.."Text"]
    end
end

function VTrainingLayer:RoleLeave(role)
    local startPos = 0
    if self[role.."LastP"] == 2 then
        startPos = gWindow.size.width
    end
    
    self("tx"..role.."Word"..self[role.."LastP"]).visible = 0
    self("img"..role.."Word"..self[role.."LastP"]).visible = 0
    local imgrole = self("img"..role..self[role.."LastP"])
    
    
    local sign = (self[role.."LastP"] - self.posRela) * 2

    local x = imgrole:getContentSize().width * imgrole:getScaleX() * imgrole:getAnchorPoint().x - (sign - 1) * imgrole:getContentSize().width * imgrole:getScaleX() / 4;
    local y = imgrole:getContentSize().height * imgrole:getScaleY() * imgrole:getAnchorPoint().y;
    
    
--    local x = imgrole:getContentSize().width * imgrole:getAnchorPoint().x;
--    local y = imgrole:getContentSize().height * imgrole:getAnchorPoint().y;
    imgrole:RunAction{"sequence", {"moveTo", 0.4, (self[role.."LastP"] - self.posRela) * 2 * x + startPos, y}, {"hide"}}
    
    self[role.."LastP"] = self.trainInfo[role.."Place"]
end


function VTrainingLayer:TrainningEmpty(parameters)
    local trainningCsv = gData:LoadTraining()
    local info = trainningCsv:lineData(self.trainInfo.id)
    
    local coin = gData:attrValue(AttrType.AttrTypeMoney)
    local sunShine = gData:attrValue(AttrType.AttrTypeSunshine)
        
        
    if info == nil then
        return true
    end
    
    if gData.userInfo.manorInfo.baseCampInfo.level <= info.limitLevel and coin >= info.resCount1 and sunShine >= info.resCount2  then
        return true
    end
    
    self:SetTrainInfo(info)
--    cclog("任务id:"..self.trainInfo.id)
    return false
end

function VTrainingLayer:RunNextTrainning(parameters)
    
    self.atctionOver = false
    self:SaveTarnning()
    
    local isRun = self:RunTrainningAtcion()
    
    self:RecoverBackGround()
    
    local tableName = gData:TrainInfoBtNameFormat(self.trainInfo.btName)
    
    if tableName ~= nil then
        local table = gView()(tableName)
        if table then
            table:setTouchEnabled(true)
        end
    end
    
    if not isRun then
    local ret = gData:RunTrainning(self.trainInfo.id, "TRAINLAYER")
    end
    
--    if not ret then
--        cclog("~~~~~下一个新手任务false")
--    end
--    
--    if not isRun and not ret and not gMainView then
--        gMainView.manorView:SetMove(true)
--        cclog("RunNextTrainning删除")
--        self:Delete()
--        self = nil
--    end
end

function VTrainingLayer:SaveTarnning(parameters)
    gData.userInfo.roleInfo:UpDataTraining(self.trainInfo.id)    --.training = self.trainInfo.id
	if self.trainInfo.save == 1 then
--        gData.userInfo.roleInfo:UpDataTraining(self.trainInfo.id)    --.training = self.trainInfo.id        
        local aParam = {}
        aParam.training_id = self.trainInfo.id
        gReq:MsgReqTrainingComplete(nil, nil, aParam)
	end
end

function VTrainingLayer:RunTrainningAtcion(parameters)
    
	if self.trainInfo.action == 1 then
        cclog("播动画了")
        self.atctionOver = true
        gMainView:gotoNewbieBattleView()
        return true
    end
    
    return false
end

function VTrainingLayer:ControlAreaClick(parameters)
    
--    if not self.atctionOver then
--        cclog("atctionOver为false~~~~~~~~~2.5~~~~~~~~~~~"..self.trainInfo.id)
--        return 
--    end
--    self.atctionOver = true
    cclog("ControlAreaClick")
    self:RunNextTrainning()
end

-- function VTrainingLayer:onClick(parameters)
function VTrainingLayer:AllAreaClick(parameters)
    if self.trainInfo.x ~= -1 then
          
        return
    end
    
    if not self.atctionOver then
        
        return 
    end
    
    self:RunNextTrainning()
end