require "vDeComposeDlg"
require "vComposeDlg"
require "vMonsterReviveDlg"

VCardArmatureLayer = VClass("CardArmatureLayer", VLayer);

function VCardArmatureLayer:onTouchBase( touch )
	VCardArmatureLayer.super.onTouchBase(self, touch);
	self("amt"):play("click");
end

function VCardArmatureLayer:onLeaveBase(touch)
	VCardArmatureLayer.super.onLeaveBase(self, touch);
	self("amt"):play("normal");
end

_Card_quality = {
	[1] = "白色",
	[2] = "绿色",
	[3] = "蓝色",
	[4] = "紫色",
	[5] = "金色",
	[6] = "全部",
}

VCardDlg = VClass("CardDlg", VMsgBox)

function VCardDlg:onPush()
	self("titliText").image = "wodekapaizi.png";
	--我的植物
	self:CreatePlantCard();

	--植物合成
	self:CreatePlantCompose();

	--我的僵尸
	self:CreateMonsterCard();

	--僵尸合成
	self:CreateMonsterCompose();

	--僵尸复活
	self:CreateMonsterRelive();
end

function VCardDlg:CreatePlantCard(  )
	local amt = VArmature{name="amt", jsonName="plantCard", animation="normal", layout="Center"};
	local aSize = amt:getContentSize();
	local layer = VCardArmatureLayer{name="plantCardLayer", size=aSize, layout="Left", offset={50.05,-20},
	 touch=1, onClick="node:Parent(1):openCardDlg(node, 1)" }
	layer:Push(amt);
	self:Push(layer);
end

function VCardDlg:CreatePlantCompose()
	local amt = VArmature{name="amt", jsonName="plantCompose", animation="normal", layout="Center"};
	local aSize = amt:getContentSize();
	local layer = VCardArmatureLayer{name="plantComposeLayer", size=aSize, layout="Left", offsetP={0.25,0},
	 touch=1, onClick="node:Parent(1):openComposeDlg(node, 1)" }
	layer:Push(amt);
	self:Push(layer);
end

function VCardDlg:CreateMonsterCard(  )
	local amt = VArmature{name="amt", jsonName="monsterCard", animation="normal", layout="Center"};
	local aSize = amt:getContentSize();
	local layer = VCardArmatureLayer{name="monsterCardLayer", size=aSize, layout="Center",
	 touch=1, onClick="node:Parent(1):openCardDlg(node, 2)" }
	layer:Push(amt);
	self:Push(layer);
end

function VCardDlg:CreateMonsterCompose()
	local amt = VArmature{name="amt", jsonName="monsterCompose", animation="normal", layout="Center"};
	local aSize = amt:getContentSize();
	local layer = VCardArmatureLayer{name="monsterComposeLayer", size=aSize, layout="Right", offsetP={-0.25,0},
	 touch=1, onClick="node:Parent(1):openComposeDlg(node, 2)" }
	layer:Push(amt);
	self:Push(layer);
end

function VCardDlg:CreateMonsterRelive(  )
	local amt = VArmature{name="amt", jsonName="monsterRelive", animation="normal", layout="Center"};
	local aSize = amt:getContentSize();
	local layer = VCardArmatureLayer{name="monsterReliveLayer", size=aSize, layout="Right", offsetP={-0.05,0},
	 touch=1, onClick="node:Parent(1):openReliveDlg(node)" }
	layer:Push(amt);
	self:Push(layer);
end


function VCardDlg:onClick()
end

function VCardDlg:getAllCards(aType)
	local info = {};
	if aType == 2 then
		local monsters = gData.userInfo.monsterInfo.monsterInfos;
		for i,v in pairs(monsters) do
			table.insert(info, v);
		end
		table.sort(info, function(a,b)
			if a.quality < b.quality then 
				return false;
			elseif a.quality > b.quality then
				return true;
			else
				if a.monsterClass > b.monsterClass then
					return true;
				elseif a.monsterClass < b.monsterClass then
					return false;
				else
					return a.level > b.level;
				end
			end
		end)
	elseif aType == 1 then
		local farmPlants = gData.userInfo.manorInfo.farmInfos;
		for i,v in pairs(farmPlants) do
			v.plantInfo.isInFarm = true;
			table.insert(info, v.plantInfo);
		end
		local bagPlants = gData.userInfo.plantInfos.plants;
		for i,v in pairs(bagPlants) do
			table.insert(info, v);
		end
		table.sort(info, function(a,b)
			if a.isInFarm and not b.isInFarm then
				return false;
			elseif b.isInFarm and not a.isInFarm then
				return true;
			elseif a.quality < b.quality then 
				return false;
			elseif a.quality > b.quality then
				return true;
			else
				if a.classType < b.classType then
					return false;
				elseif a.classType > b.classType then
					return true;
				else
					return a.plantLevel > b.plantLevel;
				end
			end
		end)
	end
	return info;
end

function VCardDlg:getComposeCards(aType)
	if aType == 2 then
		return self:getMonsterCards();
	elseif aType == 1 then
		return self:getPlantCards();
	end
	
end

function VCardDlg:getMonsterCards()
	local info = {};
	local composeCsv = gData:readCsv("monster_compose.csv");
	local composeData = composeCsv:allData();
	local map = {};
	for i,v in ipairs(composeData) do
		local card = map[v.mid];
		if not card then
			card = VMonsterInfo:new()
			map[v.mid] = card;
			card.thingid = v.mid;
			card:loadBaseCsv();
		    card:loadBattleCsv();
		    card:loadDecomposeCsv();
		    card:loadMonsterTypeCsv();
		    card:loadSkillchangeCsv();
			table.insert(info, card);
		end
		if not card.composeInfo then
			card.composeInfo = {};
		end
		local ci = {};
		ci.aType = v.type;
		ci.effectId = v.effectId;
		ci.effectValue = v.effectValue;
		table.insert(card.composeInfo, ci);
	end
	return info;
end

function VCardDlg:getPlantCards()
	local info = {};
	local composeCsv = gData:readCsv("plant_compose.csv");
	local composeData = composeCsv:allData();
	local map = {};
	for i,v in ipairs(composeData) do
		local card = map[v.pid];
		if not card then
			card = VPlantInfo:new();
			map[v.pid] = card;
			card.thingid = v.pid;

			card:loadBaseCsv();
			card:loadDescritionCsv();
			card:loadSkillchangeCsv();
			card.resType = card:GetPlantType()
		    if card.resType == 0 then
		        card.isWarPlant = true;
		    end
			card:loadBattleCsv();
			card:loadDeComposeCsv();
			if not card.isWarPlant then
		        card:loadProductCsv();
		    end

			table.insert(info, card);
		end
		if not card.composeInfo then
			card.composeInfo = {};
		end
		local ci = {};
		ci.aType = v.type;
		ci.effectId = v.effectId;
		ci.effectValue = v.effectValue;
		table.insert(card.composeInfo, ci);
	end
	return info;
end

function VCardDlg:openComposeDlg(node, aType)

	local cd = VNode("vComposeDlg.vui");
	
	local cards = self:getComposeCards(aType);
	
	cd:setCardInfos(self, cards, aType);

	gView():Push(cd);
end

function VCardDlg:openReliveDlg( node )
	local mr = VNode("vMonsterReviveDlg.vui");
	gView():Push(mr);
end

function VCardDlg:openCardDlg(node, aType) -- aType：2为怪物，1为植物
	local md = VNode("vDeComposeDlg.vui");
	local cards = self:getAllCards(aType);
	md:setCardInfos(self, cards, aType);
	gView():Push(md);
end
