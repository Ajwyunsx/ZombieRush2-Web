require "vComposeLvUpCell"

VComposeLvUpDlg = VClass("ComposeLvUpDlg",VMsgBox)

function VComposeLvUpDlg:onPush()
	
    self("sunText").text = gData:attrValue(AttrType.AttrTypeSunshine)
    self.qualityNum = 6
	self.cardTbvNum = 7;
    self:InitData();
--	self:ReloadTableData("quality")
    self:ChageCardText(1)
	self:ReloadTableData("card")
end

function VComposeLvUpDlg:findCardByQuality(quality)
	local info = {};
	for i,v in pairs(self.monsters) do
		local t = {};
		local time = gData.userInfo.manorInfo:levelUpTime(v.id, LEVELUP_TYPE.LevelupMonster)
        if (v.quality == quality or quality == self.qualityNum) and time <= 0 and v.nextLevelId ~= 0 and v.nextLevelId then
			table.insert(info, v);
		end
	end
	return info;
end

function VComposeLvUpDlg:InitData()
	self.quality = {"全部","金","紫", "蓝", "绿", "白"};
	self.qualityChoose = 1;
	self.monsters = gData.userInfo.monsterInfo.monsterInfos or {};
	self.qualityCard = {};
    for i = 0, self.qualityNum - 1 do
        local mi = self:findCardByQuality(self.qualityNum - i);
		mi = self:GetSortQualityCard(mi)
		table.insert(self.qualityCard, mi);
	end
end

function VComposeLvUpDlg:GetSortQualityCard( list )
	-- body
	local sortList = list

	table.sort(sortList, function(a,b)
			if a.quality == b.quality then
				if a.monsterClass == b.monsterClass then
					return a.level > b.level;
				else 
					return a.monsterClass > b.monsterClass;
				end
			else
				return a.quality > b.quality;
			end
		end);

	return sortList
end


function VComposeLvUpDlg:onCell(idx, t, cell)
	if t.name == "qualityTbv" then
		self:onQualityCell(idx, cell)
	else
		self:onCardCell(idx, cell)
	end
end

function VComposeLvUpDlg:onQualityCell( idx, cell )
	-- body
	local index = idx + 1;
	cell("qualityTxt").text = self.quality[index];

    if idx == self.qualityChoose then
		cell("signImg").visible = 1;
	else
		cell("signImg").visible = 0;
	end

	cell("qualityBtn").onClick = "gView()('composeLvUpDlg'):changeQualityCell("..idx..")";
end

function VComposeLvUpDlg:onCardCell( idx, cell )
	-- body
	cell:Recover()
	cell:SetInfo(idx, nil, self.qualityCard[self.qualityChoose][idx + 1])
end

function VComposeLvUpDlg:ReloadTableData( flag )
	-- body
	local tb = self(flag.."Tbv")
	if flag == "card" then
        tb.number = table.getn(self.qualityCard[self.qualityChoose])
	else
	   tb.number = self[flag.."TbvNum"];
	end

	local txTip = self("txTip")

	if tb.number == 0 then
		txTip.text = self:GetTipText()
		txTip.visible = 1
		tb.visible = 0
	else
		txTip.visible = 0
		tb.visible = 1
	end

	tb.delegate = self;
	tb:reloadData();
end

function VComposeLvUpDlg:GetTipText( ... )
	-- body
	local index = self.qualityChoose
	local text = ""
	if index == 1 then
        text = "一张卡牌都没有，前往【抽卡】界面可以抽取僵尸卡"
	elseif index == 2 then
        text = "一张金色卡牌都没有，前往【抽卡】界面可以抽取僵尸卡"
	elseif index == 3 then
        text = "一张紫色卡牌都没有，前往【抽卡】界面可以抽取僵尸卡"
	elseif index == 4 then
        text = "一张蓝色卡牌都没有，前往【抽卡】界面可以抽取僵尸卡"
	elseif index == 5 then
        text = "一张绿色卡牌都没有，前往【抽卡】界面可以抽取僵尸卡"
	elseif index == 6 then
        text = "一张白色卡牌都没有，前往【抽卡】界面可以抽取僵尸卡"
	elseif index == 7 then
--        txCards.text = "白色卡牌:"..table.getn(self.qualityCard[self.qualityChoose])
	end

	return text
end


function VComposeLvUpDlg:changeQualityCell(idx)
	local lastChoose = self.qualityChoose;
	self.qualityChoose = idx;
	local tb = self("qualityTbv")
	tb:updateCellAtIndex(lastChoose);
	tb:updateCellAtIndex(idx);

--	self:ReloadTableData("card")
end

function VComposeLvUpDlg:changeQualityOption( quality )
    if self.qualityChoose == quality then return end
    self.qualityChoose = quality;
    self:UpdateQualityOption();
    self:ReloadTableData("card")
end

function VComposeLvUpDlg:UpdateQualityOption(  )
    for i=1, 6 do 
        local option = self("option"..i);
        if self.qualityChoose == i then
            option.image = "cardxuanze"..(7 - i)..".png";
            option("optionText").image = "kaxuanzi"..(7 - i)..".png";
            self:ChageCardText(i)
        else
            option.image = "cardweixuanze"..(7 - i)..".png";
            option("optionText").image = "kaweixuanzi"..(7 - i)..".png";
            
        end
    end
end

function VComposeLvUpDlg:ChageCardText(index)
    local txCards = self("txCards")
	if index == 1 then
        txCards.text = "全部卡牌 : "..table.getn(self.qualityCard[self.qualityChoose])
	elseif index == 2 then
        txCards.text = "金色卡牌 : "..table.getn(self.qualityCard[self.qualityChoose])
	elseif index == 3 then
        txCards.text = "紫色卡牌 : "..table.getn(self.qualityCard[self.qualityChoose])
	elseif index == 4 then
        txCards.text = "蓝色卡牌 : "..table.getn(self.qualityCard[self.qualityChoose])
	elseif index == 5 then
        txCards.text = "绿色卡牌 : "..table.getn(self.qualityCard[self.qualityChoose])
	elseif index == 6 then
        txCards.text = "白色卡牌 : "..table.getn(self.qualityCard[self.qualityChoose])
	elseif index == 7 then
--        txCards.text = "白色卡牌:"..table.getn(self.qualityCard[self.qualityChoose])
	end
end

function VComposeLvUpDlg:onClick()
    --    local currentView = gView(-2)
    --    if currentView then
    --        currentView.visible = 1
    --    end
    VComposeLvUpDlg.super.onClick(self)
end