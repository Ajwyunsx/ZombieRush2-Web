require "vComposeLayer"

VComposeDlg = VClass("ComposeDlg", VMsgBox)

function VComposeDlg:onClick(  )
	
end

function VComposeDlg:onPush()
	self:InitData();
	self.qualityChoose = 6;
	self.composeLayer = self("composeLayer");
	self.composeLayer.delegate = self;
	self:InitQualityOption();
	if self.aType == 1 then
		self("titliText").image = "zhiwuhechengzi.png";
	end
end

function VComposeDlg:onPushFinish( )
	self.composeLayer:InitLayer(self.qualityChoose);
end

-- function VComposeDlg:setSunshineValue()
-- 	self("sunText").text = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeSunshine);
-- end

function VComposeDlg:setCardInfos(delegate, cards, aType)
	self.delegate = delegate;
	self.cards = cards;
	self.aType = aType;
end

function VComposeDlg:InitData()
	local aType = self.aType;
	local func2 = function(a,b)

		local acount = gData.userInfo.bagInfos:itemCountThingid(a.composeInfo[1].effectId);
		local bcount = gData.userInfo.bagInfos:itemCountThingid(b.composeInfo[1].effectId);

		if acount < bcount then
			return true;
		elseif acount > bcount then 
			return false;
		else
			if aType == 1 then
				if a.quality > b.quality then 
					return false;
				elseif a.quality < b.quality then
					return true;
				else
					return a.classType < b.classType
				end
			else
				if a.quality > b.quality then 
					return false;
				elseif a.quality < b.quality then
					return true;
				else
					return a.monsterClass < b.monsterClass;
				end
			end;
		end
	end

	local func = function(t)
		local count = #t;
		for k=1,count do 
			for i=1,count-k do 
				if func2(t[i], t[i+1]) then
					local n = t[i+1];
					t[i+1] = t[i];
					t[i] = n;
				end
			end
		end
	end

	func(self.cards);
	self.qualityCard = {};
	for quality=1,5 do
		local mi = {};
		for i,v in pairs(self.cards) do
			if v.quality == quality then
				table.insert(mi, v);
			end
		end
		func(mi);
		table.insert(self.qualityCard, mi);
	end



	local itemCommon = gData:LoadItemCommon();
	if self.aType == 1 then
		self.cardLimit = itemCommon.plantCardLimit;
	else
		self.cardLimit = itemCommon.monsterCardLimit;
	end
end



function VComposeDlg:ShowTurnBtn( isShow )
	self("leftTurnBtn").visible = isShow;
	self("rightTurnBtn").visible = isShow;
end

function VComposeDlg:InitQualityOption(  )
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


function VComposeDlg:changeQualityOption(quality)
	if self.qualityChoose == quality then return end
	self.qualityChoose = quality;
	self:InitQualityOption();
	self.composeLayer:InitLayer(self.qualityChoose);
end

function VComposeDlg:IsCardUpperLimit(  )
	if self.aType == 1 then
		local curFCount = #gData.userInfo.manorInfo.farmInfos;
		local curBCount = #gData.userInfo.plantInfos.plants;

		return (curFCount + curBCount) >= self.cardLimit;
	else
		local curCount = #gData.userInfo.monsterInfo.monsterInfos;
		return curCount >= self.cardLimit;
	end
end