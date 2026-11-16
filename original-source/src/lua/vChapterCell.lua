require "vLevelDlg"

VChapterCell = VClass("ChapterCell", VTableViewCell)

function VChapterCell:showTip(parameters)
    gWindow:showTip("asdfasdfasdf")
end

function VChapterCell:Recover(count, type)
    for var = 1, count do
        local item = self("lyChapterItem"..var)
        item("txchapter").text = ""
        item("imgLock").visible = 1
        item("txStarhas").text = 0
--        item("txStarAll").text = 60
        item("imgtaijie").visible = 1
        item("lyStarBg").visible = 1
        local bgImg = item("bgImg")
        if bgImg then
            bgImg:StopAction()
            bgImg:doPop()
        end
        local heiqika = item("heiqika")
        if heiqika then
            heiqika:doPop()
        end
        
--        bgImg.onClick = nil
----        bgImg:StopAction()
--        bgImg.jsonName = nil
    end
    
    self.info = nil
end


function VChapterCell:SetInfo(count, infos, idx, showCount)
    cclog("SetInfo")
    self.info = {}
    local chapters = gData.userInfo.dungeonInfo.chapters
    for var = 1, count do
        local index = var + idx * count
        local item = self("lyChapterItem"..var)
        
        if index > showCount then
            item.visible = 0
        else
--            local info = nil
--            
--            if infos then
--                info = infos[index]
--            end
    
            local imgLock = item("imgLock")
            
            local name = chapters[index].name
            
            
            
            item("txchapter").text = name
            
            local layout = "Down"
            local offset = {0, 10}
            
            if index % 2 == 0 then
                layout = "Up"
                offset = {0, -50}
            end
            
            local i = (index - 1) % 5 + 1
            
            
            local bgImg = VArmature{name="bgImg", jsonName = "ka"..i, layout = layout, touch=1, offset = offset, level = -2}

            item:Push(bgImg)
            
            
            local isUnLock = nil
            
            if index > 1 then
                local limit = chapters[index].limit
                isUnLock = gData.userInfo.dungeonInfo:CheckChaptersPass(limit)
            end
            
            if (isUnLock or index == 1) then
                imgLock.visible = 0
                item("txchapter").color = {67,209,231}
            else
                item("lyStarBg").visible = 0
                item("txchapter").color = {59,136,144}
            end
    
            if index == showCount and not isUnLock then
                local heiqika = VArmature{name="heiqika", jsonName = "heiqika", layout = layout, touch=1, scale = 1.2, offset = offset, level = -1}
                item:Push(heiqika)
                heiqika:play("kaiheiqi")
            end

            if index == showCount then
                item("imgtaijie").visible = 0
            end
            
            local starAll = 60
            if chapters[index] then
                starAll = chapters[index].count
            end
            
--            if info and chapters[index] then
--                item("txStarhas").text = info.starHas.."/"..starAll
            item("txStarhas").text = gData.userInfo.dungeonInfo:GetChapterStar(index).."/"..(starAll or 60)
--            end
            
            if imgLock.visible == 0 or imgLock.visible == false then
                bgImg.onClick="node:Parent(2):OpenLevel("..index..")"
                local randomDuration = math.random(0,20)

                
                --    self:pause();
                bgImg:getAnimation():gotoAndPlay(randomDuration);
--                bgImg:play("move")
--                bgImg:RunAction{"sequence", {"repeat", -1, {"sequence", {"moveBy", 1, 0, 10}, {"moveBy", 2, 0, -20}, {"moveBy", 1, 0, 10}}}}
            end

            cclog("index~~~~~~~~~~~~~~~~~~~~"..index)
           
                bgImg:play("move");
            
            local randomDuration = math.random(0,10)
            bgImg:RunAction{"sequence", {"moveBy", 0, 0, randomDuration}, {"moveBy", (10 - randomDuration) / 10, 0, 10 - randomDuration}, {"moveBy", 2, 0, -20}, {"moveBy", 1, 0, 10}, {"repeat", -1, {"sequence", {"moveBy", 1, 0, 10}, {"moveBy", 2, 0, -20}, {"moveBy", 1, 0, 10}}}}

            self.info[index] =  chapters[index]
            item.visible = 1
        end
    end   
end

function VChapterCell:OpenLevel( index )
    -- body
    cclog("OpenLevel")
    local dlg = VNode("vLevelDlg.vui")
    dlg:SetDlgInfo(self.info[index])
    gView():Push(dlg)
end