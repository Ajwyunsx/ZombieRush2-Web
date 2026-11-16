VBannerInfo = vclass("BannerInfo")

function VBannerInfo:initialize()
	self.id = "0";
	self.attackAttr = nil; --攻击属性
	self.defendAttr = nil; --防御属性
	self.plants = {}; --统率植物种类
	self.monsters = {}; -- 统率怪物种类
end

function VBannerInfo:getCreatures()
	local list = {};
	for i = 1, #self.monsters do
		table.insert(list, self.monsters[i]);
	end

	for j = 1, #self.plants do
		table.insert(list, self.plants[j]);
	end
	return list;
end

function VBannerInfo:getImage()
	local count = self:getCreatureCount();
	if count >= 5 then
		return "jin.png";
	elseif count<5 and count >= 4 then
		return "zi.png";
	elseif count < 4 and count >= 3 then
		return "lan.png";
	elseif count <3 and count >= 2 then
		return "lv.png";
	else
		return "bai.png";
	end
end

function VBannerInfo:getImageBg()
	local count = self:getCreatureCount();
	if count >= 5 then
		return "bj_jin.png";
	elseif count<5 and count >= 4 then
		return "bj_zi.png";
	elseif count < 4 and count >= 3 then
		return "bj_lan.png";
	elseif count <3 and count >= 2 then
		return "bj_lv.png";
	else
		return "bj_bai.png";
	end
end

function VBannerInfo:getQualityName()
	local count = self:getCreatureCount();
	if count >= 5 then
		return "金色";
	elseif count<5 and count >= 4 then
		return "紫色";
	elseif count < 4 and count >= 3 then
		return "蓝色";
	elseif count <3 and count >= 2 then
		return "绿色";
	else
		return "白色";
	end
end

function VBannerInfo:getName()
	local name = "战旗";
	local csvDatas = gData:readCsv("banner_attr.csv");
	if self.attackAttr then
		local attrCsv = csvDatas:lineDataWithKey(self.attackAttr.value);

		if not attrCsv then
			return gLog("attr %d not found in banner_attr.csv", self.attackAttr.value);
		end
		name = attrCsv.name .. name;
	end

	if self.defendAttr then
		local attrCsv = csvDatas:lineDataWithKey(self.defendAttr.value);

		if not attrCsv then
			return gLog("attr %d not found in banner_attr.csv", self.defendAttr.value);
		end
		name = attrCsv.name .. name;
	end
	return name;
end

function VBannerInfo:getQuality()
	local quality = 0;
	if self.attackAttr then
		quality = quality + self.attackAttr.level_max;
	end

	if self.defendAttr then
		quality = quality + self.defendAttr.level_max;
	end
	return quality/2;
end

--取统率的生物数量（植物+怪物）
function VBannerInfo:getCreatureCount()
	local count = 0;
	if self.plants then
		count = count + #self.plants;
	end

	if self.monsters then
		count = count + #self.monsters;
	end
	return count; 
end

function VBannerInfo:update(pbData)
	if not pbData or not pbData.bi then 
		return 
	end
	self.id = pbData.bi.id;
	if pbData.bi.attack_attr then
		self.attackAttr = VBannerAttr:new(pbData.bi.attack_attr.level_max, pbData.bi.attack_attr.level, pbData.bi.attack_attr.value);
	else
		self.attackAttr = nil;
	end

	if pbData.bi.defend_attr then
		self.defendAttr = VBannerAttr:new(pbData.bi.defend_attr.level_max, pbData.bi.defend_attr.level, pbData.bi.defend_attr.value);
	else
		self.defendAttr = nil;
	end
	self.plants = {};

	if pbData.bi.plants then
		self.plants = self:convert2List(pbData.bi.plants);
	end
	self.monsters = {};
	if pbData.bi.monsters then
		self.monsters = self:convert2List(pbData.bi.monsters);
	end
end

function VBannerInfo:convert2List(datas)
	local list = {};
	local iter = VDataIter();
	while datas:Travel(iter) do
		local data = iter:Data();
		table.insert(list, data);
	end
	return list;
end

-------------------VBannerInfoManager----------------------
VBannerInfoManager = vclass("BannerInfoManager")

function VBannerInfoManager:initialize()
	self.bannerInfos = {};
end

function VBannerInfoManager:synWithPbData(pbData)
	local infos = pbData.infos;
	local iter = VDataIter();
    while infos:Travel(iter) do
    	local exBannerInfo = iter:Data();
    	if exBannerInfo.ctrl.op == _VCtrlOP.None or 
    		exBannerInfo.ctrl.op == _VCtrlOP.Rep or
    		exBannerInfo.ctrl.op == _VCtrlOP.Add then
    		self:updateOrAddBanner(exBannerInfo.info);
    	elseif exBannerInfo.ctrl.op == _VCtrlOP.Del then
    		self.bannerInfos[exBannerInfo.info.bi.id] = nil;
    	end
    end
end

function VBannerInfoManager:updateOrAddBanner(bannerInfo)
	if not self.bannerInfos[bannerInfo.bi.id] then
		self.bannerInfos[bannerInfo.bi.id] = VBannerInfo:new();
	end
	self.bannerInfos[bannerInfo.bi.id]:update(bannerInfo);
end

function VBannerInfoManager:deleteBanner(id)
	if self.bannerInfos[id] then
		self.bannerInfos[id] = nil;
	end
end

--全部战旗数量
function VBannerInfoManager:count()
	return getMapCount(self.bannerInfos);
end

-----------------VBannerAttr---------------------------------
VBannerAttr = vclass("BannerAttr")

function VBannerAttr:initialize(level_max, level, value)
	self.level_max = level_max;	--等级上限
	self.level = level;	    --当前等级
	self.value = value;	    --属性值
end

--------------------VActiveBanner----------------------------
-- VActiveBanner = vclass("ActiveBanner")

-- function VActiveBanner:initialize()
-- 	self.id = "0";		      --id
-- 	self.attackLevelMax = 0;	--进攻等级上限
-- 	self.defendLevelMax = 0;	--防御等级上限
-- end

-- function VActiveBanner:active(id, attackLevelMax, defendLevelMax)
-- 	self.id = id;
-- 	self.attackLevelMax = attackLeveLMax;
-- 	self.defendLevelMax = defendLevelMax;
-- end

-- function VActiveBanner:update(pbData)
-- 	self.id = pbData.id;
-- 	self.attackLevelMax = pbData.attack_level_max;
-- 	self.defendLevelMax = pbData.defend_level_max;
-- end

-- function VActiveBanner:getImage()
-- 	if self.id == "0" then
-- 		return "wu.png";
-- 	else
-- 		local quality = (self.attackLevelMax + self.defendLevelMax)/2;
-- 		return VBannerInfo:getImage(quality);
-- 	end
-- end
