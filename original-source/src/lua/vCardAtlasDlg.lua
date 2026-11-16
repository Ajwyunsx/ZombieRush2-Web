--vCardAtlasDlg.lua

VCardAtlasDlg = VClass("CardAtlasDlg", VMsgBox);

function VCardAtlasDlg:onPush(  )
	self.itemCount = 5;
	self.tbv = self("tbv");
	self.tbv.number = math.ceil((#self.atlasInfo)/self.itemCount);
	self.tbv.delegate = self;
	if self.aType == 1 then 
		self("titliText").image = "zhiwutujian.png";
	end
	self("countTip").text = "共计："..tostring(#self.atlasInfo);
end

function VCardAtlasDlg:onPushFinish(  )
	self.tbv:reloadData();
end

function VCardAtlasDlg:setQuertyInfo( info, aType)
	self.atlasInfo = info;
	self.aType = aType;
end

function VCardAtlasDlg:onCell( idx, t, cell )
	for i=1, self.itemCount do
		local item = cell("item_"..i);
		local n = self.itemCount * idx + i;
		local info = self.atlasInfo[n];
		if info then
			item.visible = 1;
			item("item_img").image = "carddiban"..info.quality..".png";
			item("cardName").text = info.name;
			if self.aType == 1 then
				item("iconImg").image = info.image.."S.png";
			else
				item("iconImg").image = info.image.."L.png";
			end
			item:ReLayout();
			item.onClick = "node:Parent(4):onOpenCardInfo("..n..")";
		else
			item.visible = 0;
		end
	end
end

function VCardAtlasDlg:onOpenCardInfo( n )
	local info = self.atlasInfo[n];
	showCardInfoDlgById(info.id, self.aType);
end