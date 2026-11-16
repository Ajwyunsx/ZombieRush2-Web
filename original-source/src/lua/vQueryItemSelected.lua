--=============================================================
--FileName:vQueryItemSelected.lua
--Author  :phil.song
--Describe:view monster or  plant info type selected
--=============================================================
require "vCardAtlasDlg"

--=============================================================
VQueryItemSelected = VClass("QueryItemSelected", VMsgBox);
--=============================================================
function VQueryItemSelected:Init(attr)
    self.super.Init(self, attr);
end
function VQueryItemSelected:onPush()
    self.atlasLevel = 20;
end
 -- aType：2为怪物，1为植物
function VQueryItemSelected:queryTheItem(node,aType)
	local aNode = VNode("vCardAtlasDlg.vui");
	local info = {};
	if aType == 2 then
		info = self:GetAllMonsterAtlasInfo();
	elseif aType == 1 then
		info = self:GetAllPlantAtlasInfo();
	end
	if next(info) then
		aNode:setQuertyInfo(info, aType);
	    gView():Push(aNode)
	end
	node("amt"):play("normal");
end

--读取所有的五星僵尸卡牌
function VQueryItemSelected:GetAllMonsterAtlasInfo(  )
	local info = {};
	local tblMonstersCsv = gData:readCsv("prop_monster.csv");
	local monsterDatas = tblMonstersCsv:allData();
	for i,v in ipairs(monsterDatas) do 
		if v.level == self.atlasLevel then
			local t = {};
			t.level = v.level;
			t.quality = v.quality;
			t.id = v.id;

			local csv = gData:readCsv("prop_monster_type.csv");
		    local lineData = csv:linesWithKeyRowValues(v.monsterClass, v.quality);
		    if not lineData then 
		        return {};
		    end
		    t.name = lineData.name;
		    t.image = lineData.image;
		    table.insert(info, t);
		end
	end
	return info;
end

--读取所有五星级的植物卡片
function VQueryItemSelected:GetAllPlantAtlasInfo()
	local info = {};
	local tblMonstersCsv = gData:readCsv("prop_plant.csv");
	local monsterDatas = tblMonstersCsv:allData();
	for i,v in ipairs(monsterDatas) do 
		if v.level == self.atlasLevel then
			local t = {};
			t.level = v.level;
			t.quality = v.quality;
			t.id = v.thingid;
			local csv = gData:readCsv("prop_plant_type.csv");
		    local lineData = csv:linesWithKeyRowValues(v.classType, v.quality);
		    if not lineData then 
		        return;
		    end
		    t.name = lineData.name;
		    t.image = lineData.image;
		    table.insert(info, t);
		end
	end
	return info;
end
