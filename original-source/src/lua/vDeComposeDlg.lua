require "vCardLayer"
require "vCardInfoDlg"

VDeComposeDlg = VClass("DeComposeDlg", VMsgBox)

function VDeComposeDlg:onClick(  )
end

function VDeComposeDlg:onPush()
	if self.aType == 1 then
		self("titliText").image = "wodezhiwuzi.png";
	end
	self:InitData();
	self.qualityChoose = 6;
	self.cardLayer = self("cardLayer");
	self.cardLayer.delegate = self;
	
end

function VDeComposeDlg:onPushFinish(  )
	self:showQualityLayer();
end

function VDeComposeDlg:showQualityLayer(  )
	local cardInfo = self.qualityCard[self.qualityChoose] or self.cards;
	self.cardLayer:InitLayer(self.qualityChoose, cardInfo);
	if self.qualityChoose == 6 then
		self("cardCountText").text = _Card_quality[self.qualityChoose].."卡牌："..(#cardInfo)
			.."/"..self.cardLimit;
	else
		self("cardCountText").text = _Card_quality[self.qualityChoose].."卡牌："..(#cardInfo);
	end
end

function VDeComposeDlg:setCardInfos(delegate, cards, aType)
	self.cards = cards;
	self.delegate = delegate;
	self.aType = aType;
end



function VDeComposeDlg:InitData()
	self.qualityCard = {};
	for quality=1,5 do
		local mi = {};
		for i,v in ipairs(self.cards) do
			local t = {};
			if v.quality == quality then
				table.insert(mi, v);
			end
		end
		self:sortCards(mi,self.aType);
		
		table.insert(self.qualityCard, mi);
	end
	local itemCommon = gData:LoadItemCommon();
	if self.aType == 1 then
		self.cardLimit = itemCommon.plantCardLimit;
	else
		self.cardLimit = itemCommon.monsterCardLimit;
	end
end

function VDeComposeDlg:sortCards(mi, aType)
	if aType == 2 then
		table.sort(mi, function(a,b)
			if a.monsterClass == b.monsterClass then
				return a.level > b.level;
			else
				return a.monsterClass > b.monsterClass;
			end
		end);
	end
	if aType == 1 then
		table.sort(mi, function(a,b)
			if a.isInFarm and not b.isInFarm then
				return false;
			elseif b.isInFarm and not a.isInFarm then
				return true;
			elseif a.classType == b.classType then
				return a.plantLevel > b.plantLevel;
			else
				return a.classType > b.classType;
			end
		end);
	end
end

function VDeComposeDlg:UpdateQualityOption(  )
	for i=1, 6 do 
		local option = self("option"..i);
		if self.qualityChoose == i then
			option.image = "cardxuanze"..i..".png";
			option("optionText").image = "kaxuanzi"..i..".png";
		else
			option.image = "cardweixuanze"..i..".png";
			option("optionText").image = "kaweixuanzi"..i..".png";
		end
	end
end


function VDeComposeDlg:changeQualityOption( quality )
	if self.qualityChoose == quality then return end
	self.qualityChoose = quality;
	self:UpdateQualityOption();
	self:showQualityLayer();
end

function VDeComposeDlg:updateDlg()
	self.cards = self.delegate:getAllCards(self.aType);
	self:InitData();
	self:showQualityLayer();
end
