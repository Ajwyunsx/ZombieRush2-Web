--NoticeInfo.lua

VNoticeInfo = vclass("NoticeInfo")
--[[
	游戏内通知使用方法：
	1、在venum.lua的NoticeType里面定义新类型
	2、VNoticeInfo:getImage加入通知需要的图片
	3、在新增需要通知的数据出，调用VNoticeManager:modify加入通知数据
	4、在VMainView:onDoEvent内加入回调事件。回调方法内调用VNoticeManager:modify清除数据
]]
function VNoticeInfo:initialize()
	self.dType = 0;--类型
	self.count = 0;
	self.param = 0; --扩展参数， dType=NoticeType.quest时，param=0表示新任务，param=1表示完成任务
	self.obj = nil; --参数,一般存放回调相关的数据
end

function VNoticeInfo:getImage()
	if self.dType == NoticeType.finish_monster_star then
		return "hd_shengxingwancheng.png";
	elseif self.dType == NoticeType.quest then
		return "hd_meirirenwu.png";
	elseif self.dType == NoticeType.free_draw_card then
		return "hd_mianfeichouka.png";
	elseif self.dType == NoticeType.achievement_finish then
		return "hd_chengjiudacheng.png";
	elseif self.dType == NoticeType.battle_end then
		return "hd_tuanzhanjieshu.png";
	elseif self.dType == NoticeType.battle_begin then
		return "hd_tuanzhanzhong.png";
	elseif self.dType == NoticeType.shop_refresh then
		return "hd_shengxingwancheng.png";
	end
end

function VNoticeInfo:add(count)
	self.count  = self.count + count;
	if(self.count  < 0) then
		self.count  = 0;
	end
end

------------------------------------------------------------------

VNoticeManager = vclass("NoticeManager")

function VNoticeManager:initialize()
	self.noticeInfos = {};
	self.checkIn = VNoticeInfo:new();
	self.checkIn.dType = NoticeType.check_in;
end

function VNoticeManager:getByType(dType)
	if dType == NoticeType.check_in then
		return self.checkIn;
	else
		if #self.noticeInfos > 0 then
			for i = 1, #self.noticeInfos do
				if self.noticeInfos[i].dType == dType then
					return self.noticeInfos[i];
				end
			end
			return nil
		else
			return nil;
		end
	end
end

-- @param count > 0 加count; count < 0 减少count; 
function VNoticeManager:modify(dType, count, obj, param)
	if not param then
		param = 0;
	end

	if dType == NoticeType.check_in then
		self.checkIn.count = self.checkIn.count + count;
		self.checkIn.obj = obj;
		self.checkIn.param = param;
		self:notice();
		return;
	end

	count = (count or 0);
	local index = 0;
	for i=1, #self.noticeInfos do
		local noticeInfo = self.noticeInfos[i];
		if noticeInfo.dType == dType then
			if noticeInfo.dType == NoticeType.quest and param ~= NoticeQuestType.quest_finish and noticeInfo.param == NoticeQuestType.quest_finish then
			else
				noticeInfo:add(count);
				noticeInfo.obj = obj;
				noticeInfo.param = param;
			end
			index = i;
			break;
		end
	end
	if index == 0 then
		local noticeInfo = VNoticeInfo:new();
		noticeInfo.dType = dType;
		noticeInfo.count = count;
		noticeInfo.obj = obj;
		noticeInfo.param = param;
		table.insert(self.noticeInfos, noticeInfo);
 	--判断count是否等于0，如果为0，则删除
 	elseif self.noticeInfos[index].count <= 0 then
 		table.remove(self.noticeInfos, index);
	end
	
	self:notice();
end



--全量覆盖
function VNoticeManager:cover(dType, count, obj, param)
	if dType == NoticeType.achievement_finish then
		if not count then
			gLog("achievement_finish count = nil");
		else
			gLog("achievement_finish count = "..count);
		end
	end 

	if not param then
		param = 0;
	end

	if dType == NoticeType.check_in then
		self.checkIn.count = count;
		self.checkIn.obj = obj;
		self.checkIn.param = param;
		self:notice();
		return;
	end
	count = (count or 0);
	local index = 0;
	for i=1, #self.noticeInfos do
		local noticeInfo = self.noticeInfos[i];
		if noticeInfo.dType == dType then
			if noticeInfo.dType == NoticeType.quest and param ~= NoticeQuestType.quest_finish and noticeInfo.param == NoticeQuestType.quest_finish then
			else
				noticeInfo.count = count;
				noticeInfo.obj = obj;
				noticeInfo.param = param;
			end
			index = i;
			break;
		end
	end
	if index == 0 then
		if count ~= 0 then
			local noticeInfo = VNoticeInfo:new();
			noticeInfo.dType = dType;
			noticeInfo.count = count;
			noticeInfo.obj = obj;
			noticeInfo.param = param;
			table.insert(self.noticeInfos, noticeInfo);
		end
 	--判断count是否等于0，如果为0，则删除
 	elseif self.noticeInfos[index].count <= 0 then
 		table.remove(self.noticeInfos, index);
	end
	
	self:notice();
end

-- 清零
function VNoticeManager:clear(dType)
	if dType == NoticeType.check_in then
		self.checkIn.count = 0;
		self.checkIn.obj = nil;
		self.checkIn.param = 0;
		self:notice();
		return;
	end
	local index = 0;
	for i = 1, #self.noticeInfos do
		local noticeInfo = self.noticeInfos[i];
		if noticeInfo.dType == dType then
			index = i;
			break;
		end
	end
	if index > 0 then
		table.remove(self.noticeInfos, index);
	end
end

function VNoticeManager:notice()
	if gView() == gMainView then
		gView():refreshNoticeInfos();
	end
end
