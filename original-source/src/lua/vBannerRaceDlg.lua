VBannerRaceDlg = VClass("BannerRaceDlg", VMsgBox)


function VBannerRaceDlg:Init(attr)
	VBannerRaceDlg.super.Init(self, attr);
end

function VBannerRaceDlg:onPush()
	self("titleText").text = "战旗统帅";
	self:setUi();
end

function VBannerRaceDlg:setData(creature, image, raceType)
	self.creature = creature;
	self.image = image;
	self.raceType = raceType;
end

function VBannerRaceDlg:setUi()
	self("imageIcon").image = self.image;
	if self.raceType == 1 then
		local csvDatas = gData:readCsv("prop_plant_type.csv");
		local datas = csvDatas:linesWithRowValue(0, self.creature);
		self:setRace(datas);
	else
		local csvDatas = gData:readCsv("prop_monster_type.csv");
		local datas = csvDatas:linesWithRowValue(0, self.creature);
		self:setRace(datas);
	end
end

function VBannerRaceDlg:setRace(datas)
	if not datas or #datas <= 0 then return end;
	for i=1, 6 do
		if i <= #datas then
			self("textBannerRaceName"..i).visible = 1;
			self("textBannerRaceName"..i).text = datas[i].name;
			self("imageBannerRaceIcon"..i).visible = 1;
			if self.raceType == 1 then
				self("imageBannerRaceIcon"..i).scale = 0.55;
				self("imageBannerRaceIcon"..i).image = datas[i].image.."S.png";
			else
				self("imageBannerRaceIcon"..i).scale = 0.45;
				self("imageBannerRaceIcon"..i).image = datas[i].image.."L.png";
			end
		else
			self("textBannerRaceName"..i).visible = 0;
			self("imageBannerRaceIcon"..i).visible = 0;
		end
	end
end

