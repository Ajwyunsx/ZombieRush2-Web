require "vResolveTip"

VCardLayer = VClass("CardLayer", VLayer)


function VCardLayer:InitLayer(quality, cardInfo)
	self.quality = quality;
	self.cardInfo = cardInfo;
 	self.tbv = self("cardTbv");
 	self.tbv.number = #self.cardInfo;
 	self.tbv.delegate = self;
 	-- self.tbv:setTouchEnabled(false);
 	self.tbv:reloadData();
 	if self.tbv.number == 0 then
 		local cardClass = "";
 		if self.delegate.aType == 1 then
 			cardClass = "植物卡";
 		else
 			cardClass = "僵尸卡";
 		end
 		if quality == 6 then 
 			self("cardTip").text = "一张卡牌都没有，前往【抽卡】界面可以抽取"..cardClass;
 		else
	 		self("cardTip").text = "一张".._Card_quality[quality].."卡都没有，前往【抽卡】界面可以抽取"..cardClass;
	 	end
 	else
 		self("cardTip").text = "";
 	end
 end 


function VCardLayer:onCell(idx, t, cell)
	idx = idx + 1;
	local card = self.cardInfo[idx];
	local level = 0;
	local levelUpType = 0;
	if self.delegate.aType == 2 then
		cell("nameText").text = card.name;
		cell("iconImg").image = card.image.."L.png";
		level = card.level;
	elseif self.delegate.aType == 1 then
		cell("nameText").text = card.plantName;
		cell("iconImg").image = card.plantImage.."S.png";
		level = card.plantLevel;
	end
	cell("starLevel").text = level;
	-- for i=1,5 do
	-- 	local star = cell("starImg"..i);
	-- 	if i > level then
	-- 		star.visible = 0;
	-- 	else
	-- 		star.visible = 1;
	-- 	end
	-- end
	cell("suitCount").text = "x"..card.decomposeInfo.effectValue;
	cell("suitIcon").image = gData:getResoureIconByID(2, card.decomposeInfo.effectId);
	cell("cardBtn").image = "carddiban"..card.quality..".png";
	cell("cardBtn"):ReLayout();
	cell("cardBtn").onClick = "node:Parent(4):onCardClick("..idx..")";
	if card.isInFarm then
		cell("resolveBtn"):setEnable(false);
		cell("resolveBtn").image = "zhongzhizhong.png";
		cell("resolveBtn").topImage = nil;
	else
		cell("resolveBtn"):setEnable(true);
		cell("resolveBtn").image = "lvsetongyonganniu.png";
		cell("resolveBtn").topImage = "fenjiezi.png";
		cell("resolveBtn").onClick = "node:Parent(4):onResolveCardClick("..idx..")";
	end
end

function VCardLayer:onCardClick(idx)
	local card = self.cardInfo[idx];
	
	local ci = VNode("vCardInfoDlg.vui");
	ci:setCardInfo(card,self.delegate.aType);
	gView():Push(ci);
end

function VCardLayer:onResolveCardClick(idx)

	local card = self.cardInfo[idx];
	if self.delegate.aType == 2 then
		if gData.userInfo.manorInfo:levelUpTime(card.id, LEVELUP_TYPE.LevelupMonster) > 0 then
			gWindow:showTip("升星中的卡牌无法分解！",2);
			return;
		end
	else 
		if gData.userInfo.manorInfo:levelUpTime(card.id, LEVELUP_TYPE.LevelupPlant) > 0 then
			gWindow:showTip("升星中的卡牌无法分解！",2);
			return;
		end
	end
	if card.decomposeInfo.limit > gData.userInfo.manorInfo.baseCampInfo.level then
		gWindow:showTip("该类卡牌分解需要庄园达到"..card.decomposeInfo.limit.."级！",2);
		return;
	end

	local rt = VNode("vResolveTip.vui");
	rt:InitData(self, card, self.delegate.aType);
	gView():Push(rt);
	-- 	return;
	-- end	
	-- self:resolveCard(card);
end

function VCardLayer:resolveCard(card)
	gWindow:showWaitTip("loading...",10);
	gReq:MsgReqThingDecompose(self, "resolveCardCallBack", card.id, self.delegate.aType);
end

function VCardLayer:resolveCardCallBack(result, rsp, req)
	if result == 0 then
		local id = req.ids[1]:ToString();
		local ri = rsp.info;
		gWindow:showReWardTip(ri,"fenjiechenggong.png");
		local offset = self.tbv:getContentOffset();
		self.delegate:updateDlg();
		self.tbv:setContentOffset(offset);
	end
	gWindow:closeWaitTip();
end
