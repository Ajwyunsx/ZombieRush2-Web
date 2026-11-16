
VCardInfoDlg = VClass("CardInfoDlg", VMsgBox)

function VCardInfoDlg:onPush()
	local qualityTable = {"白色","绿色","蓝色","紫色","金色"};
	local classInfo = CreateCsvCacheByCsvNameAndKeys("banner_race.csv",0);
	local level = 0;
	local name = "";
	local image = "";
	local offset = {};
	if self.aType == 2 then
		self("mi_hpText").text = "生命："..self.cardInfo.hp;
		self("mi_aspd").text = string.format("攻速：%.2f秒/次",self.cardInfo.atkTime/1000);
		self("mi_atkText").text = "攻击："..self.cardInfo.atk;
		self("mi_speedText").text = "移速："..math.floor(self.cardInfo.speed/1000).."秒/格";
		self("mi_qualityText").text = "品质："..qualityTable[self.cardInfo.quality];
		self("mi_timeText").text = "复活："..gData:transformTimeToString(self.cardInfo.reviveTime);
		self("mi_spaceText").text = self.cardInfo.consume;
		self("mi_describeText").text = string.gsub(self.cardInfo.description,"\\n", "\n");
		self("mi_nameText").text = "名称："..self.cardInfo.name;
		self("mi_class").text = "系列："..classInfo[tostring(self.cardInfo.monsterClass)].name;
		level = self.cardInfo.level;
		name = self.cardInfo.name;
		image = self.cardInfo.image;
		offset = {50,-5};
	elseif self.aType == 1 then
		if self.cardInfo.isWarPlant then
			self("mi_atkText").text = "攻击："..self.cardInfo.plantAtc;
			self("mi_aspd").text = string.format("攻速：%.2f秒/次",(self.cardInfo.plantAspd/1000));
		else 
			local sufix = "";
			if self.cardInfo.resType == 1 then
				sufix = "icon_jinbi_S.png";
			elseif self.cardInfo.resType == 2 then
				sufix = "icon_yibi_S.png";
			else
				sufix = "icon_yueguang_S.png";
			end
			self("mi_atkText").text = "上限："..self.cardInfo.growMax;
			self("mi_spaceText").text = self.cardInfo.consume;
			self("mi_exText1").text = "产量：";
			self("mi_exIcon1").image = sufix;
			self("mi_exValue1").text = self.cardInfo.growSpeedHour.."/时";
			self("mi_exText1").visible = 1;
			self("mi_exIcon1").visible = 1;
			self("mi_exValue1").visible = 1;
			self("mi_aspd").visible = 0;
		end
		

		self("mi_hpText").text = "生命："..self.cardInfo.plantLife;
		self("mi_qualityText").text = "品质："..qualityTable[self.cardInfo.quality];
		self("mi_nameText").text = "名称："..self.cardInfo.plantName;
		self("mi_class").text = "系列："..classInfo[tostring(self.cardInfo.classType)].name;
		self("mi_describeText").text = string.gsub(self.cardInfo.plantDesc,"\\n", "\n");
		self("mi_exText2").text = "召唤：";
		self("mi_exIcon2").image = "icon_sun_S.png";
		self("mi_exValue2").text = self.cardInfo.consume;
		self("mi_exText2").visible = 1;
		self("mi_exIcon2").visible = 1;
		self("mi_exValue2").visible = 1;
		self("mi_speedText").visible = 0;
		self("mi_timeText").visible = 0;
		self("mi_spaceText").visible = 0;
		self("mi_spaceIcon").visible = 0;
		self("mi_spaceText1").visible = 0;
		level = self.cardInfo.plantLevel;
		name = self.cardInfo.plantName;
		image = self.cardInfo.plantImage;
		offset = {45,8};
	end
	self("starLevel").text = level;

	local armature = VArmature{name="cardAmt", jsonName=image, offset=offset, fit={-1,-1}};
	if armature:haveAnimationWithName("idle") then
		armature:play("idle");
	elseif armature:haveAnimationWithName("walk") then
		armature:play("walk");
	end
	self("mi_amtBgLayer"):Push(armature);
	self("titleText").text = "卡牌详情";
end

function VCardInfoDlg:setCardInfo(card, aType, title)
	self.cardInfo = card;
	self.aType = aType;
	self.title = title;
end

