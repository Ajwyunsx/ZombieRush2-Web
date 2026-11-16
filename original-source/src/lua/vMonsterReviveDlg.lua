require "vReviveLayer"

VMonsterReviveDlg = VClass("MonsterReviveDlg", VMsgBox);

function VMonsterReviveDlg:onPush()
	self:InitData();
	
	self:InitDlg();

	self.reviveLayer = self("reviveLayer");
	self.reviveLayer.delegate = self;
end

function VMonsterReviveDlg:onPushFinish()
	self:showQualityLayer();
end

function VMonsterReviveDlg:showQualityLayer(  )
	
	local cardInfo = self.qualityCard[self.qualityChoose] or self.cards;
	self.reviveLayer:InitLayer(self.qualityChoose, cardInfo);
	if self.qualityChoose == 6 then
		self("tippText").text = _Card_quality[self.qualityChoose].."卡牌："..(#cardInfo)
			.."/"..self.cardLimit;
	else
		self("tippText").text = _Card_quality[self.qualityChoose].."卡牌："..(#cardInfo);
	end
end

function VMonsterReviveDlg:onClick()
end

function VMonsterReviveDlg:InitDlg()
	self("vcoinText").text = gData.userInfo.roleInfo:attrValue(AttrType.AttrTypeCurrency);
	local itemCommon = gData:LoadItemCommon();
	local reviveItemId = itemCommon.reviveWaterid;
	local count = gData.userInfo.bagInfos:itemCountThingid(reviveItemId);
	self("pieceText").text = count;

	 local curTime = gData:currentTime();
	 local isFind = false;
	 for i,v in ipairs(self.cards) do
	 	if curTime < v.reTime then
	 		isFind = true;
	 		break;
	 	end
	 end
	 self("allReviveBtn"):setEnable(isFind);
	 self("rateTipp").text = "优先消耗复活药水，"..self.reviveWaterPrice.."钻石抵扣1药水"
end

function VMonsterReviveDlg:InitData()
	--初始化复活药水价格
	self.reviveWaterPrice = 2;
	local csvData = gData:readCsv("item_common.csv");
    local reviveWaterId = csvData.reviveWaterid or 5001;
    csvData = gData:readCsv("item_direct_buy.csv");
    local lineData = csvData:lineDataWithKey(reviveWaterId);
    if lineData then
    	self.reviveWaterPrice = lineData[3];
    end

	self.qualityChoose = 6;
	self.cards = {};
	self.qualityCard = {};
	local itemCommon = gData:LoadItemCommon();
	self.cardLimit = itemCommon.monsterCardLimit;
	local monsters = gData.userInfo.monsterInfo.monsterInfos;
	for i,v in pairs(monsters) do
		table.insert(self.cards, v);
	end
	for quality=1,5 do
		self.qualityCard[quality] = {};
	end

	for i,v in ipairs(self.cards) do
		table.insert(self.qualityCard[v.quality], v);
	end
	
	local func2 = function(a,b)
		local curTime = gData:currentTime();
		if a.reTime < curTime then
			if b.reTime < curTime then
				if a.quality < b.quality then
					return false;
				elseif a.quality > b.quality then
					return true;
				else
					if a.monsterClass == b.monsterClass then
						return a.level > b.level;
					else
						return a.monsterClass > b.monsterClass;
					end
				end
			else
				return false;
			end
		elseif b.reTime < curTime then 
			return true;
		else
			if a.quality < b.quality then
					return false;
			elseif a.quality > b.quality then
				return true;
			else
				if a.monsterClass == b.monsterClass then
					return a.level > b.level;
				else
					return a.monsterClass > b.monsterClass;
				end
			end
		end
	end

	local func = function(t)
		local count = #t;
		for k=1,count do 
			for i=1,count-k do 
				if not func2(t[i], t[i+1]) then
					local n = t[i+1];
					t[i+1] = t[i];
					t[i] = n;
				end
			end
		end
	end


	for i,v in pairs(self.qualityCard) do 
		func(v);
	end
	func(self.cards);
end

function VMonsterReviveDlg:onReliveAll()
	local curTime = gData:currentTime();
	local ids = {};
	local itemCommon = gData:LoadItemCommon();
	local reviveItemId = itemCommon.reviveWaterid;
	local rwTime = itemCommon.reviveWaterTime;
	local count = gData.userInfo.bagInfos:itemCountThingid(reviveItemId);
	local cost = 0;
	for i,card in ipairs(self.cards) do
		if card.reTime > curTime then
			table.insert(ids, card.id);
			local time = card.reTime - curTime;
			cost = cost + math.ceil(time/rwTime);
		end
	end
	if cost > count then
		gWindow:showTip("道具不足！", 2);
		return;
	end

	gWindow:showWaitTip("loading...",10);
	gReq:MsgReqMonsterRevive(self, "ReviveAllCallBack", ids);
end

function VMonsterReviveDlg:ReviveAllCallBack(result, rsp, req)
	if result == 0 then
		gWindow:showTip("全部复活成功！", 2);
		local mis = rsp.mis;
		local iter = VDataIter();
    	while mis:Travel(iter) do
    		local mi = iter:Data();
			local bi = mi.bi;
			local thingid = bi.thingid;
			local time = bi.time;
			local id = bi.id;
			local monsterInfo = gData.userInfo.monsterInfo.monsterInfos[id];
			monsterInfo:synWithPbData(mi);
		end
		self:onPush();
		self:onPushFinish();
	end
	gWindow:closeWaitTip();
end

function VMonsterReviveDlg:changeQualityOption( quality )
	if self.qualityChoose == quality then return end
	self.qualityChoose = quality;
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
	
	self:showQualityLayer();
end 

function VMonsterReviveDlg:showYaoshuiCameFrom( )
    self("shabixuqiu").visible = 1;
    self("shabixuqiu1").visible = 1;
end

function VMonsterReviveDlg:shabixuqiuyincang( )
    self("shabixuqiu").visible = 0;
    self("shabixuqiu1").visible = 0;
end