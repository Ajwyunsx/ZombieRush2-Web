--vtimetext.lua

VTimeText = VClass("TimeText", VText)

function VTimeText:Init(attr)
	VText.Init(self, attr);
	self.suffix = attr.suffix or "";
	self.prefix = attr.prefix or "";
	self.format = attr.format or 1;
end

function VTimeText:on_time(timestamp)
	self.timestamp = tonumber(timestamp);
	if self.format == 1 then
		self:showTimeStamp();
	else
		self:showTimeStampNew();
	end
	if self.auto == 1 then
		self:startCountDown();
	end
end

function VTimeText:setDelegateCallback(delegate, callback, ...)
	self.delegate = delegate;
	self.callback = callback;
	self.params = {...};
end

function VTimeText:startCountDown()
	self:StartTimer("countDownLoop", 1);
end

function VTimeText:stopCountDown()
	self:StopTimer("countDownLoop");
end 

function VTimeText:showTimeStamp()
	local timeTable = os.date("!*t", self.timestamp);
	local timeString = "";
	local precision = 0;
	local max = self.max or 2;

	if precision < max and timeTable.month > 1 then
		timeString = timeString..(timeTable.month-1).."月";
		precision = precision + 1;
	end

	if precision < max and timeTable.day > 1 then
		timeString = timeString..(timeTable.day-1).."天";
		precision = precision + 1;
	end

	if precision < max and timeTable.hour > 0 then
		timeString = timeString..timeTable.hour.."小时";
		precision = precision + 1;
	end

	if precision < max and timeTable.min > 0 then
		timeString = timeString..timeTable.min.."分钟";
		precision = precision + 1;
	end

	if precision < max and timeTable.sec > 0 then
		timeString = timeString..timeTable.sec.."秒";
		precision = precision + 1;
	end

	if timeString == "" then
		timeString = 0;
	end
	
	self.text = self.prefix..timeString..self.suffix;
	if self.timestamp == 0 then
		self:countDownFinish();
	end
end

function VTimeText:showTimeStampNew()
	local timeTable = os.date("!*t", self.timestamp);
	local timeString = "";
	if timeTable.hour < 10 then
		timeTable.hour = "0"..timeTable.hour;
	end
	if timeTable.min < 10 then
		timeTable.min = "0"..timeTable.min;
	end
	if timeTable.sec < 10 then
		timeTable.sec = "0"..timeTable.sec;
	end
	timeString = timeString..timeTable.hour..":";
	timeString = timeString..timeTable.min..":";
	timeString = timeString..timeTable.sec;
	self.text = self.prefix..timeString..self.suffix;
	if self.timestamp == 0 then
		self:countDownFinish();
	end
end

function VTimeText:countDownLoop()
	self.timestamp = self.timestamp - 1;
	if self.timestamp < 0 then self.timestamp = 0 end;
	if self.format == 1 then
		self:showTimeStamp();
	else
		self:showTimeStampNew();
	end
end

function VTimeText:countDownFinish()
	self:StopTimer("countDownLoop");
	if self.delegate and self.callback then
		VCallBack(self.delegate, self.callback, self.timestamp, unpack(self.params));
	end
end