--vfarmUp.lua

VFarmUpDlg = VClass("FarmUpDlg", VMsgBox)

function VFarmUpDlg:onPush()
    self("artUp"):play("idle")
    local manorInfo = gData.userInfo.manorInfo;
    if manorInfo.filedMaxLevel then
        return;
    end

    self.txtFiledTitle = self("txtFiledCount");
    self.txtFiledCount = self("txtFiledCount");
    self.txfieldcountVUp = self("txfieldcountVUp");
--    self.txtLineTitle = self("txtLineTitle");
--    self.txtLineCount = self("txtLineCount");
--    self.txlineVUp = self("txlineVUp");
    self.bu_curyNumText = self("bu_curyNumText");
    self.txTimeSpace1 = self("txTimeSpace1");
    self.imgDexLvUp = self("imgDexLvUp");

--    self.txtFiledCount.text = ;
    self.txtFiledCount.text = "农田数量  : "..manorInfo.fieldCount.."块";
    self.txfieldcountVUp.text = manorInfo.nextFiledCount.."块";

--    self.txtLineTitle.text = "防守线路";
--    self.txtLineCount.text = manorInfo.defendLine.."条";
--    self.txlineVUp.text = manorInfo.nextDefendLine.."条";
   

    self("txlvn").text = manorInfo.extendLevel.."级"
    
--     if self:CheckCanLvUp() then
--         if manorInfo.levelupCurr ~= 0 and manorInfo.levelupGold == 0 then
-- --            self("bu_curyLevel").visible = 0;
-- --            self("bu_curyLevel").offset = {80,-50};
--             self.txTimeSpace1.text = manorInfo.levelupCurr;
--             self("imgTimeI1").image = "icon_zuanshi.png";
-- --            self("bu_curyLevel").visible = 1;
--         elseif manorInfo.levelupCurr == 0 and manorInfo.levelupGold ~= 0 then
-- --            self("bu_curyLevel").visible = 0;
-- --            self("bu_curyLevel").offset = {80,-50};
--             self.txTimeSpace1.text = manorInfo.levelupGold;
--             self("imgTimeI1").image = "icon_yibi.png"
-- --            self("bu_curyLevel").visible = 1;
--         else
-- --            self.bu_curyNumText.text = manorInfo.levelupCurr; --"庄园达到"..self.levelLimit.."级"
-- --            self.bu_coinNumText.text = manorInfo.levelupGold;
-- --            self("bu_coinLayer").visible = 1;
-- --            self("bu_curyLevel").visible = 1;
--         end
--     end

    
    if manorInfo.levelupCurr == 0 then
        self("txLvLimit").text = manorInfo.levelupCurr
    elseif manorInfo.levelupVip <= gData.userInfo.roleInfo.vipInfo[0] then
        self("imgLvLimit").visible = 0
        self("txLvLimit").text = "当前VIP"..gData.userInfo.roleInfo.vipInfo[0]..",可免费扩建农田"
    else
        local cost = self:GetCost()
        self("txLvLimit").text = manorInfo.levelupCurr.."(充值"..cost.."元达到vip"..manorInfo.levelupVip.."可免费扩建)";
    end
--    if self:CheckCanLvUp() then    
--        self("btnExtendUp").visible = 1;
--    else
--        self("txLimitExtendUp").text = "需要庄园等级"..self.levelLimit
--        self("txLimitExtendUp").visible = 1
--    end

    local imageString = "fieldexplant"..manorInfo.extendLevel..".png";
    self.imgDexLvUp.image = imageString;

    -- self("txvip").text = "VIP"..manorInfo.levelupVip.."可免费扩地"
end

function VFarmUpDlg:GetCost( ... )
    -- body
    local charge = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCharge);
    local des = nil

    local manorInfo = gData.userInfo.manorInfo;

    local vipCsv = gData:readCsv("user_vip.csv");

    local iter = VDataIter()
    while vipCsv.var:Travel(iter) do
        local item = iter:Data();
        if item[0] == manorInfo.levelupVip then
            des = item[1]
            break;
        end
    end

    if not des then
        return -1
    end

    return tonumber(des / gResRate)
end

function VFarmUpDlg:CheckCanLvUp()
    local extend_level = gData.userInfo.manorInfo.extendLevel
    local csvData = gData:readCsv("manor_field_extend_level.csv");
    local level = gData.userInfo.manorInfo.baseCampInfo.level
    
    if not csvData then
        gWindow:showTip("没找到manor_field_extend_level.csv文件", 1)
        return
    end

    local lineData = csvData:lineDataWithKey(extend_level);
    self.levelLimit = lineData[1]
    
    if level < lineData[1] then--lineData:Get(1) then  --测试数据
        return false
    else
        return true
    end
end

function VFarmUpDlg:onbtnExtendClick( )
    local extend_level = gData.userInfo.manorInfo.extendLevel
    local csvData = gData:readCsv("manor_field_extend_level.csv");
    
    if not csvData then
        gWindow:showTip("没找到manor_field_extend_level.csv文件", 1)
        return
    end
    
    local lineData = csvData:lineDataWithKey(extend_level + 1);
    
    if not lineData then
        gWindow:showTip("等级已达上限", 1)
        return
    else
        lineData = csvData:lineDataWithKey(extend_level);
    end

    local manorInfo = gData.userInfo.manorInfo;

    if manorInfo.levelupVip <= gData.userInfo.roleInfo.vipInfo[0] then
        self:ReqManorExtend()
        return
    end

    local YB = gData:attrValue(AttrType.AttrTypeCurrency)
    local coin = gData:attrValue(AttrType.AttrTypeMoney)
--    local level = gData:attrValue(AttrType.AttrTypeLevel)
    local level = gData.userInfo.manorInfo.baseCampInfo.level
    
    local lacks = {}
    
    if level < lineData[1] then--lineData:Get(1) then  --测试数据
--        local tip = gView():Push("vTipDlg.vui")
--        tip:ShowTip("LVLIMIT");
--        gWindow:showTip("玩家等级不足", 1);
--        return false
    
        gWindow:showTip("庄园等级不足"..lineData[1].."级", 1);
        return false
    elseif YB < lineData[3] then
--        local tip = gView():Push("vTipDlg.vui")
--        tip:ShowTip("YBNOTENOUGH");
--        gWindow:showTip("钻石不足", 1);
--        return false
        gWindow:showMoneyLackDlg(lineData[3])
            return
        
    elseif coin < lineData[2] then
--        local tip = gView():Push("vTipDlg.vui")
--        tip:ShowTip("CIONNOTENOUGH");
--        gWindow:showTip("金币不足", 1);
--        return false
        local res = {}
        res.thingid = 20
        res.type = 1
        res.count = lineData[2] - coin
        self:AddLackRes(lacks, res)
    
    end
    
    if table.getn(lacks) ~= 0 then
        gWindow:showCostLackDlg(lacks, self, "ReqManorExtend")
    else
        
        
        self:ReqManorExtend(aParam)
    end   
end

function VFarmUpDlg:ReqManorExtend(parameters)
    local csvData = gData:readCsv("manor_field_extend_level.csv");

    if not csvData then
        gWindow:showTip("没找到manor_field_extend_level.csv文件", 1)
        return
    end
    
    local extend_level = gData.userInfo.manorInfo.extendLevel
    local lineData = csvData:lineDataWithKey(extend_level);
    
    
    local aParam = {}
    
    if lineData[2] ~= 0 and lineData[3] == 0 then
        aParam.type = 1
    elseif lineData[2] == 0 and lineData[3] ~= 0 then
        aParam.type = 2
    elseif lineData[2] == 0 and lineData[3] == 0 then
        aParam.type = 2
    end

    aParam.node = self

    gFarm:ReqManorExtend(aParam)

    self:onClick()
end

function VFarmUpDlg:onbtnCloseClick( )
    self:onClick();
end

function VFarmUpDlg:AddLackRes(lacks, resCost)
    table.insert(lacks, resCost)
end