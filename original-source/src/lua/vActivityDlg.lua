require "vCardDlg"
require "vCardlotteryDlg"
require "vQueryItemSelected"
require "vQuestDlg"
require "vAttainmentDlg"
require "vSigninDlg"
require "vPVPOptionDlg"
require "vSocietyDlg"
require "vFriendManageDlg"

VActivityDlg = VClass("ActivityDlg", VLayer)

function VActivityDlg:Init(attr)
    VLayer.Init(self, attr);
    self:NeedEvent(Eff_onEnter+Eff_onExit);
--     -- if gWindow.needAction then
--     --     self.pushAction = {{"fadeTo",0,0},{"scaleTo",0,0.2},{"show"},{"scaleTo",0.15,1.2},{"spawn",{"fadeTo",0.1,self.opacity},{"scaleTo",0.1,1.0}}};
--     --     self.popAction = {{"fadeTo",0.1,0},{"scaleTo",0.1,0.8},{"hide"}};
--     --     self.stopEventTime = 0.3;
--     -- end
end

function VActivityDlg:onPush()
    self.imageNum = 6;
    self.activityLayer = self("activityImg");
    self:showDlg();
end

function VActivityDlg:onPop( )

end

function VActivityDlg:showDlg( )
    self:showAnimation();
    gMainView.btnMoreFunc("topImage").image="mv_x.png";
end

function VActivityDlg:hideDlg()
    self:hideAnimation();
    gMainView.btnMoreFunc("topImage").image="mv_jia.png";
end



function VActivityDlg:showAnimation()
    self:setVisible(true);

    -- local layerTime = 0.1;
    self.activityLayer.layout = "DownOut";
    local h = self.activityLayer:getContentSize().height;
    self.activityLayer:RunAction{{"moveBy",0.2,0,h}};

    -- local actionTime = 0.1;
    -- for i=1,self.imageNum do
    --     local dTime = layerTime + i * 0.08;
    --     self.items[i]:RunAction{{"hide"}, {"scaleTo", 0, 0, 0}, {"delayTime", dTime}, {"show"}, {"scaleTo", actionTime, 1.2, 1.2}, {"scaleTo", actionTime, 0.9, 0.9}, {"scaleTo", actionTime, 1.0, 1.0}};
    -- end
end

function VActivityDlg:hideAnimation()
    -- for i=1,self.imageNum do
    --     self.items[i]:StopAction();
    -- end
    self:setVisible(false);
end

function VActivityDlg:openCardDlg()
    gView():Push("vCardDlg.vui");
    self:hideDlg();
end

function VActivityDlg:openFriend()
    local node1 = VNode("vSocietyDlg.vui")
    local node2 = VNode("vFriendManageDlg.vui")
    gView():Push(node1)
    node1.isActivity = 0
    gView():Push(node2)
    self:hideDlg();
end

function VActivityDlg:openQueryItemDlg()
    local node = VNode("vQueryItemSelected.vui")
    gView():Push(node)
    self:hideDlg();
end

function VActivityDlg:openQuestDlg(  )
    local node = VNode("vQuestDlg.vui");
    gView():Push(node);
    self:hideDlg();
end

function VActivityDlg:openAttainmentDlg(  )
    local node = VNode("vAttainmentDlg.vui");
    gView():Push(node);
    self:hideDlg();
end


function VActivityDlg:openSignDlg(  )
    local node = VNode("vSigninDlg.vui");
    gView():Push(node);
    self:hideDlg();
end

function VActivityDlg:openBag()
    local node = VNode("vBagDlg.vui")
    node.DlgType = "ALL"
    gView():Push(node);
    self:hideDlg();
end

function VActivityDlg:openMore( )
   local systemSetDlg = VNode("vSystemSetDlg.vui");
   systemSetDlg:SetRoleInfo(gData.userInfo.roleInfo);
   gView():Push(systemSetDlg);
   self:hideDlg();
end
