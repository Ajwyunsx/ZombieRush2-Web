-------------------------------------------------------------------------------
--------------------------- VReviveLayer

VReviveCell = VClass("TableViewCell", ReviveCell);


function VReviveCell:onReviveCell(card, idx)
	self:onShowCell(card);
	self("timeText").visible = 0;
	self("reviveBtn").visible = 0;
	self("tipText").visible = 1;
end

function VReviveCell:onShowCell(card)
	self("starLevel").text = card.level;
	self("nameText").text = card.name;
	self("cardBtn").image = "carddiban"..card.quality..".png";
	self("cardBtn"):ReLayout();
end

function VReviveCell:onUnReviveCell(card, idx, time)
	if not self.rwTime then
		local itemCommon = gData:LoadItemCommon();
		self.rwTime = itemCommon.reviveWaterTime;
	end
	local reTime = card.reTime - gData:currentTime();
	local count = math.ceil(reTime/self.rwTime);

	self:onShowCell(card);
	self("timeText").visible = 1;
	self("timeText").time = time;
	self("timeText"):setDelegateCallback(self, "reviveTimeOver");
	self("reviveBtn").visible = 1;
	self("tipText").visible = 0;

	self("costText").text = count;
	self("reviveBtn").onClick = "node:Parent(4):onReviveClick("..idx..")";
end

function VReviveCell:reviveTimeOver()
	self("timeText").visible = 0;
	self("reviveBtn").visible = 0;
	self("tipText").visible = 1;
end

-------------------------------------------------------------------------------
--------------------------- VReviveLayer
VReviveLayer = VClass("ReviveLayer", VLayer);

function VReviveLayer:InitLayer(idx, cards)
	local quality = idx;
	self.tbv = self("cardTbv");
	self.cards = cards;
	self.tbv.number = #self.cards;
	self.tbv.delegate = self;
	self.tbv:reloadData();
	if self.tbv.number ==  0 then
		if quality == 6 then
			self("reliveTip").text = "一张卡牌都没有，前往【抽卡】界面可以抽取僵尸卡";
		else
			self("reliveTip").text = "一张".._Card_quality[quality].."卡都没有，前往【抽卡】界面可以抽取僵尸卡";
		end
	else
		self("reliveTip").text = "";
	end
end

function VReviveLayer:onCell(idx, t, cell)
	idx = idx + 1;
	local card = self.cards[idx];
	cell("iconImg").image = card.image.."L.png";
	local curTime = gData:currentTime();
	if card.reTime > curTime then --
		local time = card.reTime - curTime;
		cell:onUnReviveCell(card, idx, time);
	else
		cell:onReviveCell(card, idx);
	end

	cell("cardBtn").onClick = "node:Parent(4):onCardClick("..idx..")";
end


function VReviveLayer:onCardClick(idx)
	local card = self.cards[idx];
	local ci = VNode("vCardInfoDlg.vui");
	ci:setCardInfo(card,2);
	gView():Push(ci);
end



function VReviveLayer:onReviveClick(idx)
	local card = self.cards[idx];
	local itemCommon = gData:LoadItemCommon();
	local reviveItemId = itemCommon.reviveWaterid;
	local rwTime = itemCommon.reviveWaterTime;
	local count = gData.userInfo.bagInfos:itemCountThingid(reviveItemId);
	local reTime = card.reTime - gData:currentTime();

	if reTime <= 0 then 
		gWindow:showTip("复活时间已经结束！");
		return;
	end
	local cost = math.ceil(reTime/rwTime);
	if count < cost then
		local costInfo = {
			[1] = {
				["thingid"] = 5001,
				["type"] = 2,
				["count"] = cost-count,
			}
		};
		gWindow:showCostLackDlg(costInfo, gReq, "MsgReqMonsterRevive",
			 self, "ReviveCallBack", card.id, idx);
		return;
	end
	gWindow:showWaitTip("loading...");
	gReq:MsgReqMonsterRevive(self, "ReviveCallBack", card.id, idx);
end

function VReviveLayer:ReviveCallBack(result, rsp, req)
	gWindow:closeWaitTip();
	if result == 0 then
		gWindow:showTip("复活成功！", 2);
		local mis = rsp.mis;
		if req.idx then
			local mi = mis[0];
			local bi = mi.bi;
			local thingid = bi.thingid;
			local time = bi.time;
			local id = bi.id;
			local monsterInfo = gData.userInfo.monsterInfo.monsterInfos[id];
			monsterInfo:synWithPbData(mi);
			self.cards[req.idx] = monsterInfo;
			-- gLog("************** self.cards[req.idx].reTime == %d",self.cards[req.idx].reTime - gData:currentTime());
			self.tbv:updateCellAtIndex(req.idx-1);
			self.delegate:InitDlg();
		end
	end
end