require "vChangeStuffDlg"
-- require "vMateriaLackTip"

VComposeLayer = VClass("ComposeLayer", VLayer)

function VComposeLayer:InitLayer(quality)
	self.quality = quality;
	self.cards = self.delegate.qualityCard[self.quality] or self.delegate.cards;


 	self.tbv = self("cardTbv");
 	self.tbv.number = #self.cards;
 	self.tbv.delegate = self;
 	self.tbv:reloadData();
 end 


function VComposeLayer:onCell(idx, t, cell)
	idx = idx + 1;
	local card = self.cards[idx];
	local level = 0;
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
	cell("iconImg"):ReLayout();
	local sun = -card.composeInfo[2].effectValue

	local isSunOk = false;
	if gData.userInfo.roleInfo:attrValue(card.composeInfo[2].effectId) >= sun then
		isSunOk = true;
	end
	local count = gData.userInfo.bagInfos:itemCountThingid(card.composeInfo[1].effectId);
	cell("suitNeedText").text = "/"..(-card.composeInfo[1].effectValue);
	cell("suitText").text = count;
	cell("suitIcon").image = gData:getResoureIconByID(2, card.composeInfo[1].effectId);
	local isSuitOk = false;
	if count + card.composeInfo[1].effectValue < 0 then
		cell("suitText").color = {255,0,0};
	else
		isSuitOk = true;
		cell("suitText").color = {85,66,40};
	end

	if isSuitOk then
		if isSunOk then
			cell("composeBtn").onClick = "node:Parent(4):composeCard("..idx..",0)";
		else
			cell("composeBtn").onClick = "node:Parent(4):composeCard("..idx..",2)";
		end
	else
		cell("composeBtn").onClick = "node:Parent(4):composeCard("..idx..",1)";
	end
	
	cell("changeStuffBtn").onClick = "node:Parent(4):openChangeStuffDlg("..idx..")";
	cell("cardImg").image = "carddiban"..card.quality..".png";
	cell("cardImg").touch = 1;
	cell("cardImg").onClick = "node:Parent(4):openCardInfoDlg("..idx..")";
	-- cell("iconImg").image = card.image;
end

--点击查看卡牌信息
function VComposeLayer:openCardInfoDlg( idx )
	local card = self.cards[idx];
	if self.delegate.aType == 2 then
		local ci = VNode("vCardInfoDlg.vui");
		ci:setCardInfo(card,2);
		gView():Push(ci);
	elseif self.delegate.aType == 1 then
		local ci = VNode("vCardInfoDlg.vui");
		ci:setCardInfo(card,1);
		gView():Push(ci);
	end
end

--合成按钮响应
function VComposeLayer:composeCard(idx, flag)
	--判断卡牌是否达到上限
	
	--碎片不足
	if flag == 1 then
		self:ShowComposeFailTip();
	--阳光不足
	elseif flag == 2 then
		local card = self.cards[idx];
		local costInfo = {};
		local effectId = card.composeInfo[2].effectId;
		local sun = -card.composeInfo[2].effectValue - gData.userInfo.roleInfo:attrValue(effectId);
		table.insert(costInfo, {type=1, thingid=effectId, count=sun});
		gWindow:showCostLackDlg(costInfo, self, "SendComposeMsg", idx);
	else
		self:SendComposeMsg(idx);
	end
end

--发送合成请求
function VComposeLayer:SendComposeMsg( idx )
	gWindow:showWaitTip("loading");
	local card = self.cards[idx];
	gReq:MsgReqThingCompose(self,"composeCardCallBack", card.thingid, self.delegate.aType, idx);
end

--显示材料不足提示
function VComposeLayer:ShowComposeFailTip()
	-- local mbox = VNode("vCommonMsgBox_C.vui");
	-- mbox("title").image = "hechengshibai.png";
	-- local tip = "材料不足，合成失败！";
	-- local tipText = VText{text=tip, fontSize=22, color={90,40,0}, layout="Center"};
	-- local btmTip = VText{text="点击任意位置关闭", fontSize=18, layout="Down", offset={0,-35}, color={93,47,0}}
	-- mbox("bgImg"):Push(btmTip);
	-- mbox("bgImg"):Push(tipText);
	gWindow:showNormalTip("材料不足，合成失败！","合成失败");
	-- self.delegate:Push(mbox);
end

--合成返回
function VComposeLayer:composeCardCallBack(result, rsp, req)
	gWindow:closeWaitTip();
	if result == 0 then
		gWindow:showTip("合成成功！");
		local card = self.cards[req.idx];
		local ci = VNode("vCardInfoDlg.vui");
		ci:setCardInfo(card, self.delegate.aType);
		gView():Push(ci);
		self.tbv:updateCellAtIndex(req.idx-1);
	end
end

--材料转换按钮响应
function VComposeLayer:openChangeStuffDlg(idx)
	local card = self.cards[idx];

	local maxCount, costCount = 0,0;
	local itemid = card.composeInfo[1].effectId
	local itemInfo = gData.userInfo.bagInfos:itemThingid(itemid);

	local csv = gData:readCsv("box_effect.csv");
	local infos = csv:linesWithRowValue(0,itemid);
	if not infos then 
		gLog("get data from box_effect.csv with key:"..itemid.." error");
		return;
	end
	if itemInfo then
		costCount = math.abs(infos[1].effectCount);
		maxCount = math.floor(itemInfo.amount/costCount);
	end


	if maxCount <= 0 then
		-- local mbox = VNode("vCommonMsgBox_C.vui");
		-- mbox("title").image = "hechengshibai.png";
		-- local tip = "材料不足，转换失败！";
		-- local tipText = VText{text=tip, fontSize=22, color={90,40,0}, layout="Center"};
		-- local btmTip = VText{text="点击任意位置关闭", fontSize=18, layout="Down", offset={0,-35}, color={93,47,0}}
		-- mbox("bgImg"):Push(btmTip);
		-- mbox("bgImg"):Push(tipText);
		-- self.delegate:Push(mbox);
		gWindow:showNormalTip("材料不足，转换失败！");
		return;
	end
	local cs = VNode("vChangeStuffDlg.vui");
	cs:InitData(self, itemInfo, maxCount, costCount);
	gView():Push(cs);
end