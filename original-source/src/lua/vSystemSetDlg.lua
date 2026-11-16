
require "vGameSetDlg"
require "vPlantlotteryDlg"
require "vCorpselotteryDlg"
require "vPrivatChatDlg"

VSystemSetDlg = VClass("SystemSetDlg", VMsgBox)

function VSystemSetDlg:Init(attr)
    VSystemSetDlg.super.Init(self, attr)
    self.pushAction = nil--{{"fadeTo",0,0},{"scaleTo",0,0.2},{"show"},{"scaleTo",0.15,1.2},{"spawn",{"fadeTo",0.1,self.opacity},{"scaleTo",0.1,1.0}}};
    self.popAction = nil--{{"fadeTo",0.1,0},{"scaleTo",0.1,0.8}};
end

function VSystemSetDlg:onPush()
    -- self:refreshAudioConfig()
    local lyrSystemSetDlg = self("lyrSystemSetDlg");
    local imgBackGroundlyrBag = self("imgBackGroundlyrBag");
    local bagSize = imgBackGroundlyrBag:getContentSize();
    local w = bagSize.width + 10;
    lyrSystemSetDlg:RunAction{{"moveBy", 0.3, -w, 0}};
end

function VSystemSetDlg:SetRoleInfo(info)
    self.roleInfo = info
end

function VSystemSetDlg:onGameSet()
    local systemSetDlg = VNode("vGameSetDlg.vui");
    gView():Push(systemSetDlg);
end

function VSystemSetDlg:onAccountSet()
    local myInfoManageDlg = VNode("vMyInfoManageDlg.vui");
    myInfoManageDlg:SetRoleInfo(self.roleInfo);
    gView():Push(myInfoManageDlg);
end

function VSystemSetDlg:onNotice()
    gSys:openSite(gSiteUrl);
end

function VSystemSetDlg:onMusicB(bl)
    cclog("onMusicB")
    if gAudio:getEffectOff() == 1 then
        gAudio:setEffectOff(0);
    else
        gAudio:setEffectOff(1);
    end
    gData:saveConfig();
    self("imgOffSetBSystemSetD").visible = bl
end

function VSystemSetDlg:refreshAudioConfig()
    if gAudio:getEffectOff() == 1 then
        self("imgOffSetBSystemSetD").visible = 1;
    else
        self("imgOffSetBSystemSetD").visible = 0;
    end

    if gAudio:getMusicOff() == 1 then
        self("imgOffSetSystemSetD").visible = 1;
    else
        self("imgOffSetSystemSetD").visible = 0;
    end
end

function VSystemSetDlg:onMusic(bl)
    if gAudio:getMusicOff() == 1 then
        gAudio:setMusicOff(0);
        if gAudio:isMusicPlaying() then
            gAudio:resumeMusic();
        else
            if gView() == gMainView then
                gAudio:playMusic("enterGame.ogg",true);
            else
                gAudio:playMusic("beginGame.ogg",true);
            end
        end
    else
        gAudio:pauseMusic();
        gAudio:setMusicOff(1);
    end
    gData:saveConfig();
    self("imgOffSetSystemSetD").visible = bl
end

function VSystemSetDlg:onService()
    local messageView = self("PrivatChatDlg");
    if not messageView then
        messageView = self:Push("vPrivatChatDlg.vui");
    end
    messageView:loadByUserid(gGameMasterId);
end


function VSystemSetDlg:onOutGame()

    local extend = {}
    extend.title = "提示" 
    extend.content = "是否退出游戏!"
    -- commonMsgDlg:ShowCommMsgBox("FREE", self, "exitGame", extend)
    gAudio:playEffect("sys_exitGame.ogg");

    gWindow:showConfirmTip("是否退出游戏!", "确定", "取消", self, "exitGame", "", "提示",
        extend);
end

function VSystemSetDlg:exitGame()
    gData.offlineData:saveOfflineData();
    gDtr:endToLua();
end

function VSystemSetDlg:openSignDlg(  )
    local node = VNode("vSigninDlg.vui");
    gView():Push(node);
    self:doPop();
end

function VSystemSetDlg:openEventEntry(  )
    gWindow:showNormalTip("功能暂未开放，敬请期待！");
    -- gWindow:showWaitTip("loading...");
    -- gReq:MsgReqActivityInfoQuery(gMainView, "activityInfoQueryRespone");
    -- self:doPop();
end

function VSystemSetDlg:openQueryItemDlg()
    local node = VNode("vQueryItemSelected.vui")
    gView():Push(node)
    self:doPop();
end
