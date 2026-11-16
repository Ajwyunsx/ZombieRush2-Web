require "vBannerRouletteResultDlg"

VBannerlotteryDlg = VClass("BannerlotteryDlg", VMsgBox)

function VBannerlotteryDlg:Init(attr)
	 VBannerlotteryDlg.super.Init(self, attr);
	 self:initData();
end

function VBannerlotteryDlg:onPush()
	self:initUI();
    self:onShow();
    self:creatAmt();
end

function VBannerlotteryDlg:setCallBack(parentDelegate, callBack)
    self.parentDelegate = parentDelegate;
    self.callBack = callBack;
end

function VBannerlotteryDlg:initData()
	local csvDatas = gData:readCsv("banner_roulette.csv");
	local data = csvDatas:lineDataWithKey(BannerLotteryType.type_pu);
    if not data then return end;
    self.puCostType = data.costType;
	self.puCostId = data.costId;
	self.puCostAmount = data.costAmount;
	data = csvDatas:lineDataWithKey(BannerLotteryType.type_zuan);
    if not data then return end;
    self.zuanCostType = data.costType;
	self.zuanCostId = data.costId;
	self.zuanCostAmount = data.costAmount;
    self.coverLayerSize = nil;
    self.puSize = nil;
    self.zuanSize = nil;
    self.puPosX, self.puPosY = nil;
    self.zuanPosX, self.zuanPosY = nil;
    self.imageBannerPosX, self.imageBannerPosY = nil;
end

function VBannerlotteryDlg:initUI()
    self("textXunZhang").text=self.puCostAmount.."购买";
	img, name = gData:getResoureIconByID(self.zuanCostType, self.zuanCostId);
    self.zuanCostName = name;
	self("textZuanShi").text = self.zuanCostAmount.."购买";
    self.bgImage = self("bgImage");
    self.imageYingZiPu = self("imageYingZiPu");
    self.imageYingZiZuan = self("imageYingZiZuan");
    self.imageBanner = self("imageBanner");
    self.imageBanner.visible = 0;
    self.imageGuang = self("imageGuang");
    self.imageGuang.visible = 0;
end

function VBannerlotteryDlg:onShow()
    local itemInfo = gData.userInfo.bagInfos:itemThingid(self.puCostId);
    if itemInfo and itemInfo.amount > 0 then
        self("itemNum").text = itemInfo.amount;
    else
        self("itemNum").text = 0;
    end

    self("zuanShiNum").text = gData:attrValue(self.zuanCostId);
end

function VBannerlotteryDlg:creatAmt()
    self:creatPuAmt();
    self:creatZuanAmt();
end

function VBannerlotteryDlg:addAmtCallBack(amt)
    local function callBack( bone, evt, originFrameIndex, currentFrameIndex )
        self:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex );
    end 
    amt:setEventCallFunc(callBack);
end

function VBannerlotteryDlg:creatPuAmt()
    local amt = VArmature{name="puamt", jsonName="puchou", layout="Center"};
    self.puSize = amt:getContentSize();
    local layer = VLayer{name="puchou", size=self.puSize, offsetP={0.162, 0.215}}
    layer:Push(amt);
    self.bgImage:Push(layer);
    self:addAmtCallBack(amt);
end

function VBannerlotteryDlg:creatZuanAmt()
    local amt = VArmature{name="zuanamt", jsonName="zuanchou", layout="Center"};
    self.zuanSize = amt:getContentSize();
    local layer = VLayer{name="zuanchou", size=self.zuanSize, offsetP={0.575, 0.24}}
    layer:Push(amt);
    self.bgImage:Push(layer);
    self:addAmtCallBack(amt);
end

--勋章购买
function VBannerlotteryDlg:puLottery()
	self:Lottery(BannerLotteryType.type_pu);
end

--元宝购买
function VBannerlotteryDlg:zuanLottery()
	self:Lottery(BannerLotteryType.type_zuan);
end

function VBannerlotteryDlg:Lottery(atype)
    self:setBtnClickAble(false);
    --检查战功或者砖石资源  
    if atype == BannerLotteryType.type_pu then --勋章抽取
        local itemInfo = gData.userInfo.bagInfos:itemThingid(self.puCostId);
        if not itemInfo or self.puCostAmount > itemInfo.amount then
            local item = gData:itemInfo(self.puCostId);
            if not item then
                gWindow:showTip("材料不足", 1);
            else
                gWindow:showTip(item.name.."不足", 1);
            end
            self:setBtnClickAble(true);
            return;
        end
    else
        local currencyCount = gData:attrValue(self.zuanCostId);
        if self.zuanCostAmount > currencyCount then
            gWindow:showMoneyLackDlg(self.zuanCostAmount);
            self:setBtnClickAble(true);
            return;
        end
    end

    local count = gData.userInfo.bannerInfos:count();
    local csvDatas = gData:readCsv("banner_common.csv");
    if csvDatas then
        local csvData = csvDatas:lineData(0);
        if csvData and count >= csvData.maxBanners then
            gWindow:showConfirmTip("战旗数量已经达到上限，无法获得新的战旗，请分解多余的战旗后，再进行购买。",  "前往分解","取消", self,  "openBannerInfosDlg", nil, "战旗已满");
            self:setBtnClickAble(true);
            return;
        end
    end

    if not self.coverLayerSize then
        self.coverLayerSize = self("layerCover"):getContentSize();
    end

    if not self.puPosX then
        self.puPosX, self.puPosY = self("puchou"):getPosition();
    end

    if not self.zuanPosX then
        self.zuanPosX, self.zuanPosY = self("zuanchou"):getPosition();
    end

    self.imageYingZiPu.visible = 0;
    self.imageYingZiZuan.visible = 0;
    self("layerCover").visible = 1;
    self.imageGuang.visible = 0;
    self.imageBanner.visible = 0;

    if atype == BannerLotteryType.type_pu then --勋章抽取
        self("zuanchou").visible= 0;
        self("puchou"):RunAction{"sequence", {"jumpBy", 0.5, self.coverLayerSize.width/2-self.puPosX, self.coverLayerSize.height/2-self.puPosY, 100, 1}, {"delayTime", 0.2}, {self, "reqlottery", atype}};
    else
        self("puchou").visible= 0;
        self("zuanchou"):RunAction{"sequence", {"jumpBy", 0.5, self.coverLayerSize.width/2-self.zuanPosX, self.coverLayerSize.height/2-self.zuanPosY, 100, 1}, {"delayTime", 0.2}, {self, "reqlottery", atype}};
    end
end

function VBannerlotteryDlg:setBtnClickAble(clickAble)
    if clickAble then
        self("imageMudiPu").touch = 1;
        self("imageMudiZuan").touch = 1;
        self("backBtn").touch = 1;
    else
        self("imageMudiPu").touch = 0;
        self("imageMudiZuan").touch = 0;
        self("backBtn").touch = 0;
    end
end

function VBannerlotteryDlg:openBannerInfosDlg()
    local bannerInfoDlg = VNode("vBannerInfoDlg.vui");
    gView():Push(bannerInfoDlg);
end

function VBannerlotteryDlg:reqlottery(atype)
    self.amtRepeat = true;
    self.gainBannerId = -1;
    if atype == BannerLotteryType.type_pu then --勋章抽取
        self("puamt"):play("chou");
        gReq:MsgReqBannerRoulette(self, "puLotteryBack", atype);
    else
        self("zuanamt"):play("chou");
        gReq:MsgReqBannerRoulette(self, "zuanLotteryBack", atype);
    end
   
end

function VBannerlotteryDlg:puLotteryBack(result, rsp, req)
    self.amtRepeat = false;
    if result == 0 then
        self.gainBannerId = rsp.info.bi.id;
    end
end

function VBannerlotteryDlg:zuanLotteryBack(result, rsp, req)
    self.amtRepeat = false;
     if result == 0 then
       self.gainBannerId = rsp.info.bi.id;
    else
        self:setBtnClickAble(true);
    end
end

function VBannerlotteryDlg:onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
    if evt == "zuanCheckRsp" then
        if not self.amtRepeat then
            if self.gainBannerId ~= -1 then
                self("zuanamt"):play("chouchu", nil, 0);
            else
                self:resetUI();
            end
        end
    elseif evt == "zuanAddBanner" then
        self:bannerAnimation();
    elseif evt == "puCheckRsp" then
        if not self.amtRepeat then
               if self.gainBannerId ~= -1 then
                self("puamt"):play("chouchu", nil, 0);
            else
                self:resetUI();
            end
        end
    elseif evt == "puAddBanner" then
        self:bannerAnimation();
    else
    end
end

function VBannerlotteryDlg:bannerAnimation()
   if self.gainBannerId  ~= -1 and gData.userInfo.bannerInfos.bannerInfos[self.gainBannerId] then
        local bannerInfo = gData.userInfo.bannerInfos.bannerInfos[self.gainBannerId];
        self.imageBanner:setTexture(bannerInfo:getImage());
        self.imageBanner:RunAction{"sequence", {"scaleTo", 0, 0.5, 0.5}, {"moveTo", 0, self.coverLayerSize.width/2, self.coverLayerSize.height}, {"show"}, {"moveTo", 0.2, self.coverLayerSize.width/2, self.coverLayerSize.height/2}, {"scaleTo", 0.2, 1, 1}, {self, "lightAnimation"}};
    else
        self:resetUI();
    end
end

function VBannerlotteryDlg:lightAnimation()
    self.imageGuang.visible = 1;
    self.imageGuang:RunAction{"sequence", {self, "setTouch"}, {"rotateBy", 0.6, 360}, {"rotateBy", 0.7, 360}, {"rotateBy", 0.8, 360}, {"repeat", -1, {"rotateBy", 1, 360}}};
end

function VBannerlotteryDlg:setTouch()
    self("layerCover").touch = 1;
end


function VBannerlotteryDlg:showBanner()
    self:resetUI();
    local dlg = VNode("vBannerRouletteResultDlg.vui");
    dlg:setBannerInfo(gData.userInfo.bannerInfos.bannerInfos[self.gainBannerId]);
    gView():Push(dlg);
end

function VBannerlotteryDlg:resetUI()
    self.imageYingZiPu.visible = 1;
    self.imageYingZiZuan.visible = 1;
    self("layerCover").visible = 0;
    self("layerCover").touch = 0;
    self.imageGuang.visible = 0;
    self.imageBanner.visible = 0;
    self("zuanamt"):play("idle", nil, 0);
    self("puamt"):play("idle", nil, 0);
    self("puchou").visible = 1;
    self("puchou"):setPosition(self.puPosX, self.puPosY);
    self("zuanchou").visible = 1;
    self("zuanchou"):setPosition(self.zuanPosX, self.zuanPosY);
    self:setBtnClickAble(true);
    self:onShow();
end

function VBannerlotteryDlg:doClose()
    self:doPop();
    if self.parentDelegate and self.callBack then
        VCallBack(self.parentDelegate, self.callBack);
    end
end

function VBannerlotteryDlg:onClick()
end

function VBannerlotteryDlg:showZhanxunCameFrom( )
    self("shabixuqiu").visible = 1;
    self("shabixuqiu1").visible = 1;
end

function VBannerlotteryDlg:shabixuqiuyincang( )
    self("shabixuqiu").visible = 0;
    self("shabixuqiu1").visible = 0;
end