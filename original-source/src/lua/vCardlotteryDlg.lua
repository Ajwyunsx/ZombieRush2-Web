require "vBannerlotteryDlg"
require "vCommonDlg"

VCardlotteryDlg = VClass("CardlotteryDlg", VMsgBox)

function VCardlotteryDlg:Init(attr)
    self.super.Init(self, attr)
end

function VCardlotteryDlg:onPush()
    self.imgLight = self("imgLight")
    self("titliText").image = "chouka.png";
    self:checkBannerFuc();

    self.l_evolveImage = self("l_evolveImage")
    self.l_iheritImage = self("l_iheritImage")
    self.l_bannerImage = self("l_bannerImage")


    self.l_evolveImage.onTouchBase = function(touch) 
        
        VButton.super.onTouchBase(self.l_evolveImage, touch);
        self.l_evolveImage:setButtonState(_VButtonState.highlighted);
        self.l_evolveImage.pressCount = 0
        self:onLightAction(1)
    end

    self.l_evolveImage.onLeaveBase = function(touch) 
        
        self.l_evolveImage:setButtonState(_VButtonState.normal);
        VButton.super.onLeaveBase(self.l_evolveImage, touch);
        self:CloseAllButtonTouch()
        self:RunAction{{"delayTime", 0.5}, {self, "onPlantCardClick"}};
    end

    self.l_iheritImage.onTouchBase = function(touch) 
        
        VButton.super.onTouchBase(self.l_iheritImage, touch);
        self.l_iheritImage:setButtonState(_VButtonState.highlighted);
        self.l_iheritImage.pressCount = 0
        self:onLightAction(2)
    end
    
    self.l_iheritImage.onLeaveBase = function(touch) 

        self.l_iheritImage:setButtonState(_VButtonState.normal);
        VButton.super.onLeaveBase(self.l_iheritImage, touch);
        self:CloseAllButtonTouch()
        self:RunAction{{"delayTime", 0.5}, {self, "onMonsterCardClick"}};
    end

    self.l_bannerImage.onTouchBase = function(touch)
        VButton.super.onTouchBase(self.l_bannerImage, touch);
        self.l_bannerImage:setButtonState(_VButtonState.highlighted);
        self.l_bannerImage.pressCount = 0
        
        local isOpen, openLevel  = gData.userInfo:isBannerFuncOpen();

        if not isOpen and openLevel then
            gWindow:showTip("庄园等级达到"..openLevel.."级时，解锁抽取战旗功能");
            return;
        end

        
        self:onLightAction(3)
    end
    
    self.l_bannerImage.onLeaveBase = function(touch)
        self.l_bannerImage:setButtonState(_VButtonState.normal);
        VButton.super.onLeaveBase(self.l_bannerImage, touch);
        
        local isOpen, openLevel  = gData.userInfo:isBannerFuncOpen();

        if not isOpen and openLevel then
            return;
        end

        
        self:CloseAllButtonTouch()
        self:RunAction{{"delayTime", 0.5}, {self, "onBannerCardClick"}};
    end
end

function VCardlotteryDlg:CloseAllButtonTouch( ... )
    -- body
    self.l_evolveImage.touch = 0
    self.l_iheritImage.touch = 0
    self.l_bannerImage.touch = 0

end

function VCardlotteryDlg:OpenAllButtonTouch( ... )
    -- body
    self.l_evolveImage.touch = 1
    self.l_iheritImage.touch = 1
    self.l_bannerImage.touch = 1
end

function VCardlotteryDlg:checkBannerFuc()
   if gData.userInfo:isBannerFuncOpen() then
        self("image_suo").visible = 0;
    else
        self("image_suo").visible = 1;
    end
end

function VCardlotteryDlg:onPlantCardClick( ... )
	local plantlotteryDlg = VNode("vPlantlotteryDlg.vui");
    gView():Push(plantlotteryDlg);
    self.imgLight:StopAction()
    self.hasAction = false
    -- self.imgLight.offset = {-303,0}
    self.imgLight.visible = 0
    self:OpenAllButtonTouch()
end

function VCardlotteryDlg:onMonsterCardClick( ... )
	local corpselotteryDlg = VNode("vCorpselotteryDlg.vui");
    gView():Push(corpselotteryDlg);
    self.imgLight:StopAction()
    self.hasAction = false
--    self.imgLight.offset = {20,0}
    self.imgLight.visible = 0
    self:OpenAllButtonTouch()
end

function VCardlotteryDlg:onBannerCardClick( ... )
--    local isOpen, openLevel  = gData.userInfo:isBannerFuncOpen();
--
--    if not isOpen and openLevel then
--        gWindow:showTip("庄园"..openLevel.."级解锁");
--        return;
--    end

	local bannerlotteryDlg = VNode("vBannerlotteryDlg.vui");
	gView():Push(bannerlotteryDlg);
    self.imgLight:StopAction()
    self.hasAction = false
--    self.imgLight.offset = {310,0}
    self.imgLight.visible = 0
    self:OpenAllButtonTouch()
end

function VCardlotteryDlg:onLightAction(index)
    cclog("onRepeat")
--    self.imgLight:StopAction()
    if not self.hasAction and self.hasAction ~= index then
        self.hasAction = index
        if index == 1 then
            self.imgLight.offset = {-233,0}
        elseif index == 2 then
            self.imgLight.offset = {20,0}
        elseif index == 3 then
            self.imgLight.offset = {244,0}
        end
        self.imgLight.visible = 1
        -- self.imgLight:StopAction()
        self.imgLight:RunAction{"repeat", -1, {"rotateBy", 1, 10}};
    end
end