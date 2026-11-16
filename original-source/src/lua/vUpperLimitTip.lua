--vUpperLimitTip.lua

VUpperLimitTip = VClass("UpperLimitTip", VMsgBox);

function VUpperLimitTip:setLimitInfo( li, delegate, callback, params )
	self.limitInfo = li;
	self.delegate = delegate;
	self.callback = callback;
	self.params = params;
end

function VUpperLimitTip:onPush()
	self("bgImg").touch = 1;
	self("titleText").text = "超额提醒";
	self.tbv = self("tbv");
	self.tbv.delegate = self;
	self.tbv.number = math.ceil(#self.limitInfo/2);
end

function VUpperLimitTip:onPushFinish(  )
	self.tbv:reloadData();
end

function VUpperLimitTip:onCell( idx, t, cell )
	for i=1,2 do
		local n = idx * 2 + i;
		local info = self.limitInfo[n];
		local item = cell("itemly"..i);
		if info then
			item.visible = 1;
			local image, name = gData:getResoureIconByID(info.type, info.id);
			item("itemImg").image = image;
			item("itemName").text = name;
			item("itemCount").text = "x"..info.count;
		else
			item.visible = 0;
		end
	end
end

function VUpperLimitTip:onOKAction(  )
	if self.delegate and self.callback then
		VCallBack(self.delegate, self.callback, unpack(self.params));
	end
	self:doPop();
end