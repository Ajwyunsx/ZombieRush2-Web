--vStoreDlg.lua

require "vBagTableViewCell"
require "vFormatData"
--require "vplantResCell"
--require "vplantWarCell"


VBagDlg = VClass("BagDlg", VMsgBox)

function VBagDlg:Init(attr)
    self.super.Init(self, attr)
    self.rowCount = 5
    self.maxShowCount = 2
    
--    cclog("ddddddddd"..gData.userInfo.roleInfo.bagSize.start_time) 
--    self.starttime = gData.userInfo.roleInfo.bagSize.start_time
    local itemCommon = gData:LoadItemCommon()
    self.maxBagSize = itemCommon.bagSize
end

--function VBagDlg:SetNextRefreshTime(idx, i)
----    self.timeNode = node
--    
--    self:StopTimer("OnTime")
--    
--    self.timeidx = idx
--    self.timei = i
--       
--    self.time = self:CalcNextRefreshTime()
--    
--    if self.time ~= 0 then
--        self:StartTimer("OnTime", self.time, 0, 0)
--    end
--    
--    local tbBag = self("tbBag")
--    
--    cclog("~~~~~~~~~~~~~~~~~~~~"..(idx or "没有啊啊啊啊啊啊啊啊啊啊啊啊啊"))
--    cclog("~~~~~~~~~~~~~~~~~~~~i"..(i or "没有啊啊啊啊啊啊啊啊啊啊啊啊啊"))
--    local cell = tbBag:cellAtIndex(idx)
--    
--    if cell ~= nil then
--        cell:SetNextRefreshTime(self.time, idx, i)
--    end
--    
--    return self.time
--end

--function VBagDlg:CalcNextRefreshTime()
--    local startTime = self.starttime
--    cclog("计时时间:"..startTime)
----    local time = startTime - gData:currentTime()
--    local bag_extend = gData:readCsv("bag_extend.csv");
--    local pbInfo = bag_extend:lineDataWithKey(self.openCount + 1);
--    local time = pbInfo[1] - gData:currentTime() + startTime 
--    cclog("time = %d", time);
--    
--    if time <= 0 then
--        self.hour = 0
--        self.min = 0
--        self.sec = 0
--        time = 0
--    else
--        self.hour = math.floor(time / 3600)
--        self.min = math.floor((time % 3600) / 60)
--        self.sec= ((time % 3600) % 60)
--    end
--    
--    return time
--end

function VBagDlg:OnTime(dt)
--    if self.sec == 0 then
--        self.sec = 59
--        self.min = self.min - 1
--        if self.min < 0 then
--            self.min = 59
--            self.hour = self.hour - 1
--            if self.hour < 0 then
--                self.hour = 0
--                self.min = 0
--                self.sec = 0
--                self.timeNode("txTimeBagC").text = "可开启"
                if self.lastTableBt.type == "ALL" and self.timeidx then
--    self.timeNode("txTimelotteryDlg").visible = 0
--                self.timeNode("txTimeBagC").visible = 1
        local tbBag = self("tbBag")
        local cell = tbBag:cellAtIndex(self.timeidx)
        cell:StopRefreshTime(self.timeidx, self.timei)
        end
--                self.timeNode("imgLockBagC").onClick = "node:Parent(2):onOpenClick("..self.timeidx..","..self.timei..")"
--                self:StopTimer("OnTime")
--                end
--            end
--        end
--    else
--        self.sec = self.sec - 1
--    end
--
--    self.timeNode("txTimeBagC").text = self.hour..":"..self.min..":"..self.sec
--    self.time = self.time - 1
end

function VBagDlg:InitData()
    self.data = VFormatData:new()
    
	if self.DlgType == "ALL" then
        self.data:InitAll()
	else
	   self.data:InitPlants()      
	end
	
    self.data:InitProperty()
end

function VBagDlg:onPush()
    self:InitData()
    self("backBtn").onClick = "node:Parent():onClick()"
    
    self("titleImage").level = 10
    self("backBtn").level = 10
    
    self("titliText").image = "cangku.png";
    if self.DlgType ~= "ALL" then
        self("lyrPlantBag").visible = true
--        self("lyrAllBag").visible = false
        self.lastTableBt = self("btnResBag")
        self.lastTableBt.type = "ALLPLANT"
    else        
        self.lastTableBt = self("btnGiftsBag")
        self.lastTableBt.type = "PROPERTY"
--        self.lastTableBt.level = 100
--        self("txStoreBag").text = self.openCount.."/"..self.maxBagSize
        self("txStoreBag").text = table.getn(self.data.all).."/"..self.maxBagSize
        self("imgCountHtBag").visible = 1
        gFarm:SetCurrentTouchPos(0, 0)
    end
    self:ReloadTable("PROPERTY")
end

function VBagDlg:onCell(idx, t, cell)
    self:SetCellInfo(idx, cell, t.type)
end

function VBagDlg:UpdataTableCell(rsp, req)
    local tbBag = self("tbBag")
    cclog("调用UpdataTableCell了")
    local startPosidx = math.max(req.idx - self.maxShowCount, 0)
            --        local startPosi = (self.openCount - req.count) - self.rowCount * startPosidx
            cclog("startPosidx"..startPosidx)
    for var = startPosidx, req.idx + self.maxShowCount do
                local cell = tbBag:cellAtIndex(var)
                if cell then
                    self:onCell(var, tbBag, cell)
                end
                --            for var = 1, self.rowCount do
                --                self:onCell(var, cell, tbBag)
                --          end
            end
end


function VBagDlg:SetCellInfo(idx, cell, type)
    cell:Recover(self.rowCount)
    cell.infos = {}
    local i = 1
    for var = idx * self.rowCount + 1, idx * self.rowCount + self.rowCount do
    
        local info = self:GetTableInfo(var, type)
        
            
    
            cell:SetInfo(info, i, idx, var, self.maxBagSize, type)
        
        i = i + 1
    end
end


function VBagDlg:GetTableInfo(i, type)
    local info
    
    if type == "PLANT" then
        info = self.data.plants[i]
    elseif type == "STAGE" then
        info = self.data.suitInfos[i]
    elseif type == "ALL" then
        info = self.data.all[i]
    elseif type == "OTHER" then
        info = self.data.others[i]
    elseif type == "PLANTRES" then
        info = self.data.plantRes[i]
    elseif type == "ALLPLANT" then
        info = self.data.plants[i]
    elseif type == "GIFTS" then
        info = self.data.gifts[i]
    elseif type == "PROPERTY" then
        info = self.data.property[i]
    else
        info = self.data.plantWar[i]
    end

    return info
end

function VBagDlg:ChageTableB( type )
     if not type then
         return
     end

     if self.lastTableBt.type == type then
         return
     end

     local btnBag = nil
    
     if type == "PLANT" then
         btnBag = self("btnPlantBag")
         self.data:InitPlants()
     elseif type == "STAGE" then
         btnBag = self("btnStageBag")
         self.data:InitSuits()
     elseif type == "OTHER" then 
        btnBag = self("btnAllBag")
        
         self.data:InitOthers()
     elseif type == "ALL" then
         btnBag = self("btnAllBag")
         self.data:InitAll()
     elseif type == "PLANTRES" then
         btnBag = self("btnResBag")
         self.data:InitPlantRess()
     elseif type == "ALLPLANT" then
         btnBag = self("btnAllPlantBag")
         self.data:InitPlants()
    elseif type == "GIFTS" then
        btnBag = self("btnGiftsBag")
        self.data:InitGifts()
    elseif type == "PROPERTY" then
        btnBag = self("btnPropertyBag")
        self.data:InitProperty()
     else
         btnBag = self("btnDefBag")
         self.data:InitPlantWars()
     end
    
    local image = VImage{name="tmp", image="mubanweixuanzhong.png"}
    
    self("btnPropertyBag").image = "mubanweixuanzhong.png"
    self("btnPropertyBag")("imgAllBag").image = "daoju2.png"
    self("btnPropertyBag").size = {image.size.width, image.size.height};
    self("btnGiftsBag").image = "mubanweixuanzhong.png"
    self("btnGiftsBag")("imgAllBag").image = "libao2.png"
    self("btnGiftsBag").size = {image.size.width, image.size.height};
    self("btnAllBag").image = "mubanweixuanzhong.png"
    self("btnAllBag")("imgAllBag").image = "cailiao2.png"
    self("btnAllBag").size = {image.size.width, image.size.height};
    
    local image1 = VImage{name="tmp1", image="mubanxuanzhong.png"}
    btnBag.image = "mubanxuanzhong.png"
    if type == "GIFTS" then
        btnBag("imgAllBag").image = "libao1.png"
    elseif type == "OTHER" then
        btnBag("imgAllBag").image = "cailiao1.png"
    elseif type == "PROPERTY" then
        btnBag("imgAllBag").image = "daoju1.png"
    end
    btnBag.size = {image1.size.width, image1.size.height};
    
--     btnBag.level = 100
     self.lastTableBt = btnBag
     self.lastTableBt.type = type
--    self("lyShowBag"):ReLayout()
    
     self:ReloadTable(type) 
end

function VBagDlg:GetCellCount(type)
    local count = 0

    if type == "PLANT" then
        count = table.getn(self.data.plants)
    elseif type == "STAGE" then
        count = table.getn(self.data.suitInfos)
    elseif type == "OTHER" then 
        count = table.getn(self.data.others)
    elseif type == "ALL" then
        count = table.getn(self.data.all)
    elseif type == "PLANTRES" then
        count = table.getn(self.data.plantRes)
    elseif type == "ALLPLANT" then
        count = table.getn(self.data.plants)
    elseif type == "GIFTS" then
        count = table.getn(self.data.gifts)
    elseif type == "PROPERTY" then
        count = table.getn(self.data.property)
    else
        count = table.getn(self.data.plantWar)
    end

    local num, remainder = math.modf(count / self.rowCount)

    if remainder ~= 0 then
        num = num + 1
    end

    return num
end

function VBagDlg:ReloadTable( type )
    local count
    if type == "ALL" then
        count = math.ceil(self.maxBagSize / self.rowCount)
    else
        count = self:GetCellCount(type)
    end
    
    
    if count < 4 then
--        self("tbBag").visible = false;
--        self("txNoneBag").visible = true;
--    else
--        self("tbBag").visible = true;
--        self("txNoneBag").visible = false;
        count = 4
    end

    local tbBag = self("tbBag");
    tbBag.type = type
    tbBag.number = count;
    tbBag.delegate = self;
    tbBag:reloadData();
    
    local cell = tbBag:cellAtIndex(20)

    if cell then
        cclog("*******20")
    end
    
    cell = tbBag:cellAtIndex(1)
    if cell then
        cclog("*******1111")
    end
    --cell:SetNextRefreshTime(self.time, idx, i)
end

function VBagDlg:onCellSize(idx, t)
    if idx == 0 then
        return 685,217
    else
        return 683,151
    end
end

--function VBagDlg:ReqBagExtend(aParam)
--    aParam.openCount = self
--    aParam.idx = self.idx
--    aParam.i = self.i
--    gReq:MsgReqBagExtend(self, "BagExtendCallBack", aParam)
----    self:BagExtendSuccess(nil, aParam)
--end

function VBagDlg:BagExtendCallBack(result, rsp, req)
    if result == 0 then
        self:BagExtendSuccess(rsp, req)
    else
        self:BagExtendFail()
    end
end


function VBagDlg:BagExtendSuccess(rsp, req)
    local tbBag = self("tbBag")
    
    self.openCount = gData.userInfo.roleInfo.bagSize.cur_value
   
    self.starttime = gData.userInfo.roleInfo.bagSize.start_time
    self("txStoreBag").text = table.getn(self.data.all).."/"..self.openCount
    
    if tbBag and tbBag.type == "ALL" then
        
        local startPosidx = math.floor((self.openCount - req.count) / self.rowCount)
--        local startPosi = (self.openCount - req.count) - self.rowCount * startPosidx
        
        for var = startPosidx, req.idx + 1 do
            local cell = tbBag:cellAtIndex(var)
            if cell then
                self:onCell(var, tbBag, cell)
            end
        end        
    end
end


function VBagDlg:BagExtendFail()

end

function VBagDlg:ReqSuitCompound(aParam)
    cclog("ReqSuitCompound")
    aParam.idx = self.idx
    aParam.i = self.i
    gReq:MsgReqSuitCompound(self, "ReqSuitCompoundBack", aParam)
    gWindow:showWaitTip()
end

function VBagDlg:ReqSuitCompoundBack(result, rsp, req)
    if result == 0 then
        self:ReqSuitCompoundSuccess(rsp, req)
    else
        self:ReqSuitCompoundFail()
    end
end


function VBagDlg:ReqSuitCompoundSuccess(rsp, req)
    if rsp ~= nil then
        local sis = rsp.sis;
        local bi = sis.bi;
        
--        local count = sis:Count()
--        for var = 0, count - 1 do
--            gData.userInfo.suitInfo:addSuit(sis[var].bi.id, sis[var].bi.thingid)
--            gData.userInfo.suitInfo.suits[sis[var].bi.id]:synWithPbData(sis[var])
--        end
        gData.userInfo.suitInfo:synWithOtherPbData(sis)
        
        self.data.suitInfos = nil
        self.data.all = nil
        self.data.others = nil
        
        self.data:InitSuits()
        self.data:InitOthers()
        self.data:InitAll()
        
        self("txStoreBag").text = table.getn(self.data.all).."/"..self.openCount
        
--        self:ShowSuitCompoundSuccess(rsp)
        
        if self.lastTableBt.type == "OTHER" or self.lastTableBt.type == "ALL" or self.lastTableBt.type == "STAGE" then
--            self:ReloadTable(self.lastTableBt.type)
            
            self:UpdataTableCell(rsp, req)
        end
    end
    gWindow:showTip("基因合成成功", 1);
    
    gWindow:closeWaitTip()
end

function VBagDlg:ShowSuitCompoundSuccess(rsp)
    
    local sis = rsp.sis;

    local id = 0
    local count = sis:Count()
    local suits = {}
    
    for var = 0, count - 1 do
        local suit = sis[var]
        
        table.insert(suits, suit.bi.id)
      
    end


    count = table.getn(suits)

    local suitInfos = gData.userInfo.suitInfo.suits
    local compounds = {}

    for var = 1, count do
        local suitInfo = suitInfos[suits[var]]
        if suitInfo then
            local data = VItemData:new()
            data:CreateWithSuitData(suitInfo)

            table.insert(compounds, data)
        end
    end

    if table.getn(compounds) == 1 then
        cclog("合成11111111111")
        local composeDlg = VNode("vComposeDlg.vui");
        composeDlg:SetlotterInfo(compounds[1])
        composeDlg.delegate = self;
        gView():Push(composeDlg);
    elseif table.getn(compounds) > 1 then
        cclog("合成22222222222")
    else
        cclog("合成33333333333")
    end
end


function VBagDlg:ReqSuitCompoundFail()
    gWindow:closeWaitTip()
end

function VBagDlg:ReqItemUse(aParam)
    gWindow:showWaitTip()
    aParam.idx = self.idx
    aParam.i = self.i
    gReq:MsgReqItemUse(self, "ReqItemUseBack", aParam)
    gWindow:showWaitTip()
end

function VBagDlg:ReqItemUseBack(result, rsp, req)
    gWindow:closeWaitTip();
    if result == 0 then
        self:ReqItemUseSuccess(rsp, req)
    else
        self:ReqItemUseFail()
    end
end


function VBagDlg:ReqItemUseSuccess(rsp, req)
--    if rsp ~= nil then
--        local sis = rsp.sis;
--        local bi = sis.bi;
--
--        --        local count = sis:Count()
--        --        for var = 0, count - 1 do
--        --            gData.userInfo.suitInfo:addSuit(sis[var].bi.id, sis[var].bi.thingid)
--        --            gData.userInfo.suitInfo.suits[sis[var].bi.id]:synWithPbData(sis[var])
--        --        end
--        gData.userInfo.suitInfo:synWithOtherPbData(sis)

--    self.data.suitInfos = nil
    self.data.all = nil
   self.data.others = nil
--    self.data.plants = nil
    self.data.property = nil
    self.data.gifts = nil

--    self.data:InitSuits()
   self.data:InitOthers()
    self.data:InitAll()
--    self.data:InitPlants()
    self.data:InitGifts()
    self.data:InitProperty()

    self("txStoreBag").text = table.getn(self.data.all).."/"..self.maxBagSize
    
--        if self.lastTableBt.type == "OTHER" or self.lastTableBt.type == "ALL" or self.lastTableBt.type == "STAGE" then
--            self:ReloadTable(self.lastTableBt.type)
    self:UpdataTableCell(rsp, req)
--        end
--    end
--        self:ShowPlantCompoundSuccess(rsp)
    
    -- gWindow:showTip("物品使用成功", 1);
    self:ShowItemGain(rsp, req)

    local comODlg = gView()("comODlg")
    if comODlg ~= nil then
        comODlg:onClick()
    end
    local plantDefODlg = gView()("plantDefODlg")
    if plantDefODlg ~= nil then
        plantDefODlg:onClick()
    end
    local plantResODlg = gView()("plantResODlg")
    if plantResODlg ~= nil then
        plantResODlg:onClick()
    end
    
    gWindow:closeWaitTip()
end

function VBagDlg:ShowItemGain(rsp, req)
    local items = {}
    
    local ri = rsp.ri;
    local rtis = ri.rtis;

    local iter = VDataIter();
    if rtis then
        while rtis:Travel(iter) do
            local item = iter:Data();
            if item.count > 0 then
            local image, name = gData:getResoureIconByID(item.type, item.thingid)
    
            local iteminfo = {}
            
            iteminfo.thingid = item.thingid
            iteminfo.image = image
            iteminfo.name = name
            iteminfo.count = item.count
            iteminfo.type = item.type
            table.insert(items, iteminfo)
        end
        end
    end

    local rewardTip = VNode("vRewardTip.vui");
    rewardTip:setItemInfo(items, "goumaichenggong.png");
    gView():Push(rewardTip);
end

function VBagDlg:ShowPlantCompoundSuccess(rsp)
    local ri = rsp.ri;
    local rtis = ri.rtis;

    local plants = {}
    local count = rtis:Count()
    for var = 0, count - 1 do
        local plant = rtis[var]
        if plant.count > 0 and plant.type == 4 then
            table.insert(plants, plant.guid)
        end
    end
    
    local count = table.getn(plants)
    
    local plantInfos = gData.userInfo.plantInfos.plants
    local compounds = {}
    
    for var = 1, count do
        local plantInfo = plantInfos[plants[var]]
        if plantInfo then
            local data = VItemData:new()
            data:CreateWithPlantData(plantInfo)
       
            table.insert(compounds, data)
        end
    end
    
    if table.getn(compounds) == 1 then
        local composeDlg = VNode("vComposeDlg.vui");
        composeDlg:SetlotterInfo(compounds[1])
        composeDlg.delegate = self;
        gView():Push(composeDlg);
    elseif table.getn(compounds) > 1 then
        
    else
        
    end
end


function VBagDlg:ReqItemUseFail()
    gWindow:closeWaitTip()
end


function VBagDlg:ReqMonsterAdvance(info)
    self.armyTechInfo = gData.userInfo.armyTechInfos.techInfos[info.advanceInfo.mid];
    self.oldInfo = {}
    self.oldInfo.Attribute = self.armyTechInfo:getBattleAttribute()
    self.oldInfo.maxAttribute = self.armyTechInfo:GetMaxBattleAttribute()
    
    gReq:MsgReqMonsterAdvance(self, "ReqMonsterAdvanceBack", info.thingid, self.idx, self.i)
    gWindow:showWaitTip()
end

function VBagDlg:ReqMonsterAdvanceBack(result, rsp, req)
    if result == 0 then
        self:ReqMonsterAdvanceSuccess(rsp, req)
    else
        self:ReqMonsterAdvanceFail(result, rsp, req)
    end
end


function VBagDlg:ReqMonsterAdvanceSuccess(rsp, req)
--    self.data.suitInfos = nil
    self.data.all = nil
   -- self.data.others = nil
--    self.data.plants = nil

--    self.data:InitSuits()
--    self.data:InitOthers()
    self.data:InitAll()
--    self.data:InitPlants()

    self("txStoreBag").text = table.getn(self.data.all).."/"..self.openCount
  
--    self:ReloadTable(self.lastTableBt.type)
    self:UpdataTableCell(rsp, req)
    
    gWindow:showTip("进阶卡使用成功", 1);
    
    local newInfo = {}
    newInfo.Attribute = self.armyTechInfo:getBattleAttribute()
    newInfo.maxAttribute = self.armyTechInfo:GetMaxBattleAttribute()

    local qualityChangeDlg = VNode("vQualityChangeDlg.vui");
    --    lotterRewardWDlg:SetlotterInfo(info)
    local info = {}
    info.armyTechInfo = self.armyTechInfo
    info.oldInfo = self.oldInfo
    info.newInfo = newInfo
    qualityChangeDlg:SetInfo(info)
    gView():Push(qualityChangeDlg);
    
    local comODlg = gView()("comODlg")
    if comODlg ~= nil then
        comODlg:onClick()
    end

    gWindow:closeWaitTip()
end


function VBagDlg:ReqMonsterAdvanceFail(result, rsp, req)
    gWindow:closeWaitTip()
end

function VBagDlg:ReqThingSell(aParam)
    gReq:MsgReqThingSell(self, "ReqThingSellBack", aParam, self.idx, self.i)
    gWindow:showWaitTip()
end

function VBagDlg:ReqThingSellBack(result, rsp, req)
    if result == 0 then
        self:ReqThingSellSuccess(rsp, req)
    else
        self:ReqThingSellFail(result, rsp, req)
    end
end


function VBagDlg:ReqThingSellSuccess(rsp, req)
--    self.data.suitInfos = nil
    self.data.all = nil
   self.data.others = nil
--    self.data.plants = nil
    self.data.property = nil
    self.data.gifts = nil

--    self.data:InitSuits()
   self.data:InitOthers()
    self.data:InitAll()
--    self.data:InitPlants()
    self.data:InitGifts()
    self.data:InitProperty()

    self("txStoreBag").text = table.getn(self.data.all).."/"..self.maxBagSize

--    self:ReloadTable(self.lastTableBt.type)
    self:UpdataTableCell(rsp, req)
    gWindow:closeWaitTip()
end


function VBagDlg:ReqThingSellFail(result, rsp, req)
    gWindow:closeWaitTip()
end

function VBagDlg:SetCurrentOperatItem(idx, i)
    self.idx = idx
    self.i = i
end


function VBagDlg:onbtnCloseClick( )
    self:onClick()
end

function VBagDlg:onClick()
--    local currentView = gView(-2)
--    if currentView then
--        currentView.visible = 1
--    end
    self:StopTimer("OnTime")
    gMainView:ClearUpNewBagItem()
    gMainView:CheckNewBagItem()
    VBagDlg.super.onClick(self)
end