VResolveTip = VClass("ResolveTip", VMsgBox);

function VResolveTip:onPush()
	self("titleText").text = "分解提示";
	local cardName = "";
	local image,name = gData:getResoureIconByID(self.card.decomposeInfo.type, self.card.decomposeInfo.effectId);
	if self.aType == 1 then
		cardName = self.card.plantName;
	else
		cardName = self.card.name;
	end
	self("itemImg").image = image;
	self("itemName").text = name;
	self("itemCount").text = "x"..self.card.decomposeInfo.effectValue;
	self("tipText").text = "是否确认分解"..cardName.."，分解之后可获得以下材料：";
end

function VResolveTip:InitData(delegate, card, aType)
	self.delegate = delegate;
	self.card = card;
	self.aType = aType;
end

function VResolveTip:onSureBtnClick()
	self.delegate:resolveCard(self.card);
	self:doPop();
end
