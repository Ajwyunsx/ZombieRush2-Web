require "vChapterCell"
require "vPageTable"

VChapterDlg = VClass("ChapterDlg", VMsgBox)

gSPDungeonPassed = true;
gAutoShowLevelDlg = false;

function VChapterDlg:onPush()
    self("artUp"):play("idle")

    gData.userInfo.dungeonInfo:LoadlevelShopExToFile()
--    self("sunText").text = gData:attrValue(AttrType.AttrTypeSunshine)
--    self.qualityTbvNum = 6;
--    self.cardTbvNum = 7;
--    self:InitData();
--    self:ReloadTableData("quality")
    self.column = 4
    
    self.particleNode = cc.ParticleSystemQuad:create("DungeonParticle.plist");
    self:addChild(self.particleNode)
    
    
    
    self("txYuanbaoShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeMoney))
    self("txJinbiShop").text = gData:fmtMicrometer(gData:attrValue(AttrType.AttrTypeSunshine))


    gData.userInfo.dungeonInfo.needShow = true
    
    self("backBtn").visible = false;

    local actInfos = gData.userInfo.dungeonInfo.actInfos
    if actInfos then
        self.actInfos = actInfos
    end
    self:InitPropDungeonInfo()
    self:ReloadTableData("card")
    self:CheckEnterFarmConfirm();
    self("backBtn").visible = gData.offlineData:isEnterFarmBtnVisible();
    gAutoShowLevelDlg = false;
    gSPDungeonPassed = self("backBtn").visible;
end

function VChapterDlg:onPushFinish(parameters)
    self.particleNode:setPosition(cc.p(-100,71));
    self.particleNode:runAction(cc.Sequence:create(cc.FadeTo:create(0,0), cc.DelayTime:create(1), cc.FadeTo:create(0,255)));
end

function VChapterDlg:InitPropDungeonInfo(parameters)
    local csv = gData:readCsv("prop_dungeon.csv");
    self.dungeonCount = csv:lineCount();

    local hasOpen = 0
    for key, var in pairs(self.actInfos) do
            hasOpen = hasOpen + 1
    end

    if hasOpen == 0 then
        hasOpen = 1
    end

    local lockCount = csv:lineDataWithKey(hasOpen, 2)

    self.dungeonCount = math.min(self.dungeonCount, hasOpen + 1 + lockCount)
end

function VChapterDlg:ReloadTableData( flag )
    -- body
    local tb = self("chapterTbv")
    cclog("~~~~~"..math.ceil(self.dungeonCount / 4))
    tb.number = math.ceil(self.dungeonCount / 4)
    tb.delegate = self;
    tb:reloadData();
end

function VChapterDlg:onCell(idx, t, cell)
	cell:Recover(self.column)
    cell:SetInfo(self.column, self.actInfos, idx, self.dungeonCount)
end

function VChapterDlg:onClose(parameters)
    if gData.offlineData.offline then
        gWindow:showConfirmTip("进入农场需要在连接网络的情况下登录游戏，\n是否重新登录?", "确定", "取消", nil, "netWorkError", nil, nil);
        return;
    end
    gData.userInfo.dungeonInfo.needShow = false
    leveldlg = gView()("levelDlg");
    if leveldlg then
        gData.userInfo.dungeonInfo.levelShow = nil
        VLevelDlg.super.onClick(leveldlg)
    end
    VChapterDlg.super.onClick(self);
    gData.offlineData:enterFarm();
end

function VChapterDlg:CheckEnterFarmConfirm()
    local nowPassed = gData.offlineData:isEnterFarmBtnVisible();
    if ((not gAutoShowLevelDlg) or ((not gSPDungeonPassed) and nowPassed)) and --不是自动显示关卡界面的, 或者是上次没过, 这次过了
     (not gData.userInfo.farmEntered) and gData.offlineData:isEnterFarmBtnVisible() then
        if gData.offlineData.offline then
            gWindow:showConfirmTip("您的农场已建成, 去看看吧！\n（此功能需联网）", "确定", nil, nil, nil, nil, nil);
        else
            gWindow:showConfirmTip("您的农场已建成, 去看看吧！\n（此功能需联网）", "确定", nil, self, "onClose", nil, nil);
        end;
   end;
end