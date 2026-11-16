--vfriendInfo.lua

VFriendInfo = vclass("FriendInfo")

function VFriendInfo:initialize(userid)
    self.userid = userid
end

function VFriendInfo:synWithPbData(pbData)
	self.userid = pbData.info.bi.userid;
end

function VFriendInfo:synWithReqData(data)
    self.image = data.image
    self.level = data.level
    self.sex = data.sex
    self.nick = data.nick
end

VFriendManager = vclass("FriendManager")

function VFriendManager:initialize()
	self.friends = {};

    self:LoadUserCommon()
end

function VFriendManager:synWithPbData(pbData)
	local infos = pbData.infos;
	local iter = VDataIter();
    while infos:Travel(iter) do
    	local exFriend = iter:Data();
    	if exFriend.ctrl.op == _VCtrlOP.None or 
    		exFriend.ctrl.op == _VCtrlOP.Rep or
    		exFriend.ctrl.op == _VCtrlOP.Add then
    		if not self.friends[exFriend.info.bi.userid] then
    			self.friends[exFriend.info.bi.userid] = VFriendInfo:new();
    		end
    		self.friends[exFriend.info.bi.userid]:synWithPbData(exFriend);
    	elseif exFriend.ctrl.op == _VCtrlOP.Del then
    		self.friends[exFriend.info.bi.userid] = nil;
    	end
    end
end

function VFriendManager:LoadUserCommon( ... )
    -- body
    local csv = gData:readCsv("user_common.csv");
    local lineData = csv:lineData(0);
    if not lineData then 
        gLog("user_common.csv miss ID:%d", 0);
        return nil;
    end

    self.friendLimit = lineData.friendLimit
end

function VFriendManager:AddFriend(userid)
    if not self.friends[userid] then
        local friend = VFriendInfo:new(userid);
        self.friends[userid] = friend;
    end
end

function VFriendManager:DelFriend(userid)
    if self.friends[userid] then
        self.friends[userid] = nil
    end
end

function VFriendManager:friendCount()
	local count = 0;
	for k,v in pairs(self.friends) do
		count = count + 1;
	end
	return count;
end

function VFriendManager:isFriend(userid)
    if self.friends[userid] then
        return true;
    end
    return false;
end