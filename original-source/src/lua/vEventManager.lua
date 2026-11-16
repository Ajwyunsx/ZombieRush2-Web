VEventMaganer = vclass("EventMaganer");

function VEventMaganer:initialize()
	self.events = {};
end

-- function VEventMaganer:startEventLoop()
-- 	self:stopEventLoop();
-- 	self.eventHandle = gDtr:getScheduler():scheduleScriptFunc( 
-- 		function () VCallBack(gEvent, "eventLoop"); end, 1, false);
-- end

-- function VEventMaganer:stopEventLoop()
-- 	if self.eventHandle then
-- 		gDtr:getScheduler():unscheduleScriptEntry(self.eventHandle)
-- 	end
-- end

-- function VEventMaganer:eventLoop()
-- 	for i,v in ipairs(self.msg) do
-- 		if self.events[v] then
-- 			for id,info in  ipairs(self.events[v]) do
-- 				if info.delegate then
-- 					VCallBack(info.delegate, info.callBack);
-- 				end
-- 			end
-- 		end
-- 	end
-- 	self.msg = {};
-- end

function VEventMaganer:registeEvent(id, delegate, callBack)
	-- if not self.events[id] then
	-- 	self.events[id] = {};
	-- else
	-- 	self:removeEvent(id,delegate);
	-- end
	-- local info = {};
	-- info.delegate = delegate;
	-- info.callBack = callBack;
	-- table.insert(self.events[id], info);
end

function VEventMaganer:removeEvent(id, delegate)
	if self.events[id] then
		for i,v in ipairs(self.events[id]) do
			if delegate and v.delegate == delegate then
				table.remove(v,i);
				break;
			end
		end
	end
end

function VEventMaganer:removeAllEvent()
	self.events = {};
end

function VEventMaganer:pushEvent(id)
	-- table.insert(self.msg, id);
	if self.events[id] then
		for id,info in  ipairs(self.events[id]) do
			if info.delegate then
				VCallBack(info.delegate, info.callBack);
			end
		end
	end
end
