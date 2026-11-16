-- vRequest.lua

_VEncodeMode = {
	["ENCODE_RSA"] = 1,
	[1] = "ENCODE_RSA",
	["ENCODE_AESC"] = 2,
	[2] = "ENCODE_AESC",
	["ENCODE_AESS"] = 4,
	[4] = "ENCODE_AESS",
	["ENCODE_COMPRESS"] = 8,
	[8] = "ENCODE_COMPRESS",
	["ENCODE_PROTOBUF"] = 16,
	[16] = "ENCODE_PROTOBUF",
	["ENCODE_RAW"] = 32,
	[32] = "ENCODE_RAW",
}

_VMsgEncode = {
	["MsgReqAccountRegister"] = _VEncodeMode.ENCODE_RSA,
	["MsgReqLogin"] = _VEncodeMode.ENCODE_RSA,
}

VRequest = vclass("Request");

function VRequest:initChannelID()
	-- if not self.channelID then
	-- 	local var = Var();
	-- 	var:FromFile("2.xml");
	-- 	local channel = var:String();
	-- 	if channel ~= "" then
	-- 		self.channelID = tonumber(channel);
	-- 		--修正bug，重装后老账号丢失
	-- 		gRes:LoadUserData();
	-- 		gRes:SetInt("channelid", self.channelID);
	-- 		gRes:Flush();
	-- 	else
	-- 		self.channelID = 1;
	-- 	end
	-- end
	-- gLog("channel id = %s", self.channelID);
	local channelID = 1;
	local var = Var();
	var:FromFile("2.xml");
	local channel = var:String();
	if channel ~= "" then
		channelID = tonumber(channel);
		--修正bug，重装后老账号丢失
		gRes:LoadUserData();
		gRes:SetInt("channelid", channelID);
		gRes:Flush();
	end
	gLog("channel id = %s", channelID);
	self.channelID = channelID;
end

function VRequest:initialize()
	gPb:LoadFile("proto.js");
	self:initChannelID();
	self.reqQueue = {};
	self.sendingReq = nil;
	self.defaultDelay = 15;
	gHeartBeatError = 0;
end

--向SNS服务器post一段json
function VRequest:snsPost(extend, data, delegate, callBack)
	local dataVar = Var(data);
	local dataString = dataVar:ToString();
	local postUrl = gSnsUrl;
	if extend then postUrl = postUrl..extend end;

	gLog("sns post url = %s", postUrl);
	gLog("sns post content = %s", dataString);

	gNet:Post{url = postUrl, data = dataString, onFinish = function () VCallBack(delegate, callBack, gLua:Param()); end};
end

--向SNS服务器post一段二进制数据段
function VRequest:snsUpload(extend, dataVar, delegate, callBack)
	local postUrl = gSnsUrl;
	if extend then postUrl = postUrl..extend end;

	gLog("sns post url = %s", postUrl);

	gNet:Post{url = postUrl, data = dataVar, onFinish = function () VCallBack(delegate, callBack, gLua:Param()); end};
end

--向消息队列里面添加一条
function VRequest:addToReqQueue(data)
	if gData.offlineData:isOffline() then
		return;
	end;
	if data then
		table.insert(self.reqQueue, data);
		if #self.reqQueue == 1 then
			self:checkReqQueue();
		end
	end
end

--检查消息队列里面是否有可发送的消息。
function VRequest:checkReqQueue()
	if self.sendingReq then return end;
	self.sendingReq = self.reqQueue[1];
	if self.sendingReq then
		table.remove(self.reqQueue, 1);
		if not self:ReqSend(self.sendingReq) then
			self.sendingReq = nil;
			self:checkReqQueue();
		end
	end
end

function VRequest:tempRemoveVnode(data)
	if not data then return end;

	self.tempVNodeList = {};
	for k,v in pairs(data) do
		if type(v) == "table" and (v._node or v._vclass) then
			self.tempVNodeList[k] = v;
			data[k] = nil;
		end
	end
end

function VRequest:tempAddVnode(data)
	if not self.tempVNodeList then return end;
	for k,v in pairs(self.tempVNodeList) do
		data[k] = v;
	end
	self.tempVNodeList = nil;
end

--向服务器发送一条协议请求
function VRequest:ReqSend(data)
	local reqID = CMD[data._pb];
	if not reqID then gLog("unSupported Req Msg \"%s\"", data._pb) return false end;

	self:tempRemoveVnode(data);				--临时删除数据段中的Node节点，避免把node节点传递到网络层。
	local pbData = gPb:Write(data);			--protobuf封包。
	if not pbData then gLog("proto write error on Req Msg \"%s\"", data._pb) return false end;

	local encodeType = _VMsgEncode[data._pb];
	if not encodeType then encodeType = _VEncodeMode.ENCODE_PROTOBUF end;
	local reqData = gClient:pack(reqID, pbData, encodeType);			--消息封包加密
	if not reqData then gLog("pack error on Req Msg \"%s\"", data._pb) return false end;

	local dataVar = Var(data);
	gLog(data._pb..dataVar:ToString());
	gNet:Send{url = gServer, data = reqData, reqid = reqID, onError="@VUiOnSocketError"};
	self:tempAddVnode(data);				--把临时删除数据段中的Node节点加回去

	gWindow:startTimeOut(self.defaultDelay);
	return true;
end

function VRequest:synRoleInfoAll()
	local param = {};
	param.syn_flag = 1;
	param.data_type = GameDataType.DataTypeRoleInfo;
	self:MsgReqUserDataSyn(nil, nil, param);
end

--------------------------------------------------
function VRequest:MsgReqAccountRestore(delegate, callBack, flag, value, sim)
	local var = {_pb = "MsgReqAccountRestore"};
	var.value = value;
	var.sim = sim;
	var.key = gClient:getAesKey();
	var.flag = flag;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqAccountRestore2(delegate, callBack, flag, value, code, partner_channel)
	local var = {_pb = "MsgReqAccountRestore2"};
	var.value = value;
	var.code = code;
	var.key = gClient:getAesKey();
	var.flag = flag;
	var.partner_channel = partner_channel;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqAccountRegister(delegate, callBack)
	local var = {_pb = "MsgReqAccountRegister"};
	var.channel = self.channelID;
	var.extend = gSys:getExtend();
	var.sim = gSys:getImsiNumb();
	var.programid = gGameId;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqLogin(delegate, callBack, accountName, psw)
	local var = {_pb = "MsgReqLogin"};
	var.aes_key = gClient:getAesKey();
	var.reqid = gClient:reqid();
	var.account_name = accountName;
	var.psw = psw;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqRoleRegister(delegate, callBack, nick)
	local var = {_pb = "MsgReqRoleRegister"};
	var.nick = nick;
	var.key = gClient:getAesKey();
	var.accountid = gData.accountInfo.id;
	var.psw = gData.accountInfo.psw;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqGameEnter(delegate, callBack, userid, reconnect)
	local var = {_pb = "MsgReqGameEnter"};
	var.channel_id = self.channelID;
	var.userid = userid;
	var.reconnect = reconnect;
	if gRes:Platform() == "android" then
		var.client_type = 0;
	elseif gRes:Platform() == "ios" then
		var.client_type = 20;
	elseif gRes:Platform() == "mac" then
		var.client_type = 21;
	elseif gRes:Platform() == "win32" then
		var.client_type = 40;
	else
		var.client_type = 99;
	end

	var.client_ver = getClientVersion();
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqHeartbeat(delegate, callBack)
	local var = {_pb = "MsgReqHeartbeat"};
	var.chat_ids = {};
	var.chat_ids[1] = 1;
	var.noErrorTip = true;
	var.delegate = delegate;
	var.callBack = callBack;
	self.heartBeatReq = var;
	self:ReqSend(var);
	gHeartBeatReqing = var;
end

function VRequest:MsgReqStaticUserDataQuery(delegate, callBack, id, type, count, aParam)
	local var = {_pb = "MsgReqStaticUserDataQuery"};

	local idUint64 = Var();
	idUint64:SetUint64(id);
	var.id = idUint64;
	var.count = count;
	var.data_type = type;
	var.aParam = aParam;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqUserDataSyn(delegate, callBack, aParam)
	local var = {_pb = "MsgReqUserDataSyn"};
	var.syn_flag = aParam.syn_flag;
	var.data_type = aParam.data_type;
	if var.data_type == GameDataType.DataTypeAll then
		var.data_type = GameDataType.DataTypeAll - GameDataType.DataTypeBattle;
	end
	var.isHeartBeat = aParam.isHeartBeat;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqUserSearch(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqUserSearch"};
	var.condition_nums = aParam.condition_nums
	var.condition_strs = aParam.condition_strs
	var.start = aParam.start;
	var.count = aParam.count;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqRichOtherUserInfoQuery(delegate, callBack, userid, flag)
	local var = {_pb = "MsgReqRichOtherUserInfoQuery"};
	var.flag = flag;
	var.target = userid;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--------------------------------------------------------------------------------------------------------
--												聊天
--------------------------------------------------------------------------------------------------------
function VRequest:MsgReqMessagePost(delegate, callBack, target, context, type)
	local var = {_pb = "MsgReqMessagePost"};
	var.target = target;
	var.context = context;
	var.type = type;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--团战聊天查询
function VRequest:MsgReqGroupBattleMessageFetch(delegate, callBack, msgid, battleid)
	local var = {_pb = "MsgReqGroupBattleMessageFetch"};
	local idUint64 = Var();
	idUint64:SetUint64(msgid);
	var.max_messageid = idUint64;

	local battleid64 = Var();
	battleid64:SetUint64(battleid);
	var.battleid = battleid64;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--团战聊天
function VRequest:MsgReqGroupBattleMessagePost(delegate, callBack, battleid, msg)
	local var = {_pb = "MsgReqGroupBattleMessagePost"};
	var.message = msg;
	local idUint64 = Var();
	idUint64:SetUint64(battleid);
	var.battleid = idUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end
--------------------------------------------------------------------------------------------------------
--												农场\背包\商店模块
--------------------------------------------------------------------------------------------------------


-----植物摆放与回收

function VRequest:MsgReqManorPlantPlace(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqManorPlantPlace"};
	local plantidUint64 = Var();
	plantidUint64:SetUint64(aParam.plantid);
	var.plantid = plantidUint64;
	
	local pos = {_pb = "Point"};
	pos.x = aParam.x;
	pos.y = aParam.y;
	if aParam.x == 0 then
		var.isManorPlant = true
	end
	var.pos = pos;
	
	var.delegate = delegate;
	var.callBack = callBack;
	var.aParam = aParam;
	self:addToReqQueue(var);
end


-----植物升级

function VRequest:MsgReqManorPlantLevelUp(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqManorPlantLevelUp"};

	local plantidUint64 = Var();
	plantidUint64:SetUint64(aParam.plantid);

	var.noAttrTypes = {};
	var.noAttrTypes[AttrType.AttrTypeSunshine] = 1;
	var.noAttrTypes[AttrType.AttrTypeMoney] = 1;
	
	var.plantid = plantidUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	var.aParam = aParam;
	self:addToReqQueue(var);
end

------取消植物升级
function VRequest:MsgReqManorPlantLevelUpCancel(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqManorPlantLevelUpCancel"};

	local plantidUint64 = Var();
	plantidUint64:SetUint64(aParam.plantid);
	var.plantid = plantidUint64;
	var.aParam = aParam;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-----植物收获

function VRequest:MsgReqManorPlantReceive(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqManorPlantReceive"};
	local plantidUint64 = Var();

	var.noAttrTypes = {};
	var.noAttrTypes[aParam.resType] = 1;
	
	plantidUint64:SetUint64(aParam.plantid);
	var.plantid = plantidUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	var.aParam = aParam;
	self:addToReqQueue(var);
end

-----植物加速
function VRequest:MsgReqManorPlantAccelerate(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqManorPlantAccelerate"};
	local plantidUint64 = Var();
	plantidUint64:SetUint64(aParam.plantid);
	var.plantid = plantidUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	var.aParam = aParam;
	self:addToReqQueue(var);
end

-----农场扩建
function VRequest:MsgReqManorExtend(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqManorExtend"};
	var.type = aParam.type
	var.node = aParam.node
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-----仓库扩充
function VRequest:MsgReqBagExtend(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqBagExtend"};
	var.lyrBagCell = aParam.lyrBagCell
	var.idx = aParam.idx
	var.i = aParam.i
	var.node = aParam.node
	var.type = aParam.type;
	var.count = aParam.count;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-------基因合成
function VRequest:MsgReqSuitCompound(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqSuitCompound"};
	var.thingid = aParam.thingid;
	var.idx = aParam.idx
	var.i = aParam.i
	var.count = aParam.count;
	var.qulity = aParam.qulity;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-------物品使用
function VRequest:MsgReqItemUse(delegate, callBack, aParam)
	if not aParam then
		return
	end
	local plantidUint64 = Var();
	plantidUint64:SetUint64(aParam.bagid);

	local var = {_pb = "MsgReqItemUse"};
	var.itemid = aParam.itemid;
	var.count = aParam.count;
	var.idx = aParam.idx
	var.i = aParam.i
	var.bagid = plantidUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqThingSell(delegate, callBack, aParam, idx, i)
	if not aParam then
		return
	end
	local var = {_pb = "MsgReqThingSell"};
	local tis = {_pb = "ThingSellInfo"};
	
	var.idx = idx
	var.i = i
	var.tis = aParam;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


-----商店买东西
function VRequest:MsgReqItemBuy(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqItemBuy"};
	var.boxid = aParam.boxid;
	var.type = aParam.type;
	var.idx = aParam.idx
	var.i = aParam.i
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


------商店刷新
function VRequest:MsgReqShopRefresh(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqShopRefresh"};
	var.type = aParam.type;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


---------商店扩充
function VRequest:MsgReqShopExtend(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqShopExtend"};
	var.count = aParam.count;
	var.idx = aParam.idx
	var.i = aParam.i
	var.node = aParam.node
	var.count = aParam.count;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

---------------------------------农场\背包\商店模块end----------------------------------------




--------------------------------------------------------------------------------------------------------
--												植物僵尸抽奖模块
--------------------------------------------------------------------------------------------------------

function VRequest:MsgReqPlantWheel(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqPlantWheel"};
	var.type = aParam.type;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-- function VRequest:MsgReqMonsterWheel(delegate, callBack, aParam)
-- 	if not aParam then
-- 		return
-- 	end

-- 	local var = {_pb = "MsgReqMonsterWheel"};
-- 	var.itemid = 0;
-- 	var.type = aParam.type;
-- 	var.delegate = delegate;
-- 	var.callBack = callBack;
-- 	self:addToReqQueue(var);
-- end

function VRequest:MsgReqMonsterWheel(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqMonsterWheel"};
	var.ids = aParam.ids;
	var.counts = aParam.counts;
	var.type = aParam.type;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqMonsterAdvance(delegate, callBack, thingid, idx, i)
	if not thingid then
		return
	end

	local var = {_pb = "MsgReqMonsterAdvance"};
	var.idx = idx
	var.i = i
	var.thingid = thingid;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

---------------------------------植物僵尸抽奖模块end----------------------------------------




--------------------------------------------------------------------------------------------------------
--												好友模块
--------------------------------------------------------------------------------------------------------

--------添加好友
function VRequest:MsgReqFriendAdd(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqFriendAdd"};
	var.userid = aParam.userid;
	var.nick = aParam.nick;
	var.pos = aParam.pos
	var.parm = aParam.parm
	var.delegate = delegate;
	var.callBack = callBack;
	var.friendDelegate = aParam.friendDelegate;
	var.friendCallback = aParam.friendCallback;
	self:addToReqQueue(var);
end


--------查找好友
function VRequest:MsgReqBriefUserInfoQuery(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqBriefUserInfoQuery"};
	var.userids = aParam.userids;
	var.node = aParam.node;
	var.start = aParam.start
	var.type = aParam.type
	var.delegate = delegate;
	var.callBack = callBack;
	var.userDelegate = aParam.userDelegate;
	var.userCallBack = aParam.userCallBack;
	self:addToReqQueue(var);
end


--------删除好友
function VRequest:MsgReqFriendDel(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqFriendDel"};
	var.userids = aParam.userids;
	var.pos = aParam.pos;
	var.parm = aParam.parm
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


--------好友帮忙
function VRequest:MsgReqManorPlantHelp(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqManorPlantHelp"};
	local plantidUint64 = Var();
	plantidUint64:SetUint64(aParam.plantid);
	var.plantid = plantidUint64;
	var.target = aParam.target;
	var.pos = aParam.pos
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

---------------------------------好友end----------------------------------------



--------------------------------------------------------------------------------------------------------
--												修改角色资料模块
--------------------------------------------------------------------------------------------------------

-----------账号修改
function VRequest:MsgReqAccountUpdate(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqAccountUpdate"};
	var.old_psw = aParam.old_psw;
	var.new_psw = aParam.new_psw;
	var.new_name = aParam.new_name;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


-----------角色资料更新
function VRequest:MsgReqPlayerUpdate(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqPlayerUpdate"};
	var.image = aParam.image;
	var.nick = aParam.nick;
	var.sex = aParam.sex;
	var.desc = aParam.desc;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-----------绑定步骤1
function VRequest:MsgReqAccountBinding(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqAccountBinding"};
	var.value = aParam.value;
	var.binding_type = aParam.binding_type;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


-----------绑定步骤2
function VRequest:MsgReqAccountBinding2(delegate, callBack, aParam)
	if not aParam then
		return
	end
	local var = {_pb = "MsgReqAccountBinding2"};
	var.value = aParam.value;
	var.code = aParam.code;
	var.binding_type = aParam.binding_type;
	var.partner_channel = aParam.partner_channel;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

---------------------------------------------- 修改角色资料模块 End ---------------------------------------------



--------------------------------------------------------------------------------------------------------
--												新手训练模块
--------------------------------------------------------------------------------------------------------

function VRequest:MsgReqTrainingComplete(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqTrainingComplete"};
	var.training_id = aParam.training_id;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end
---------------------------------------------- 新手训练模块 End ---------------------------------------------



--------------------------------------------------------------------------------------------------------
--												战斗日志模块
--------------------------------------------------------------------------------------------------------

--------仇人录
function VRequest:MsgReqEnemyAdd(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqEnemyAdd"};
	var.userid = aParam.userid;
	var.idx = aParam.idx
	var.parm = aParam.parm
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

function VRequest:MsgReqEnemyDel(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqEnemyDel"};
	var.userid = aParam.userid;
	var.parm = aParam.parm
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

------------战斗日志详细查询
function VRequest:MsgReqBattleLogQuery( id, delegate, callBack, result)
	local var = {_pb = "MsgReqBattleLogQuery"};
	local idUint64 = Var();
	idUint64:SetUint64(id);
	var.id = idUint64;
	var.result = result;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


---------------------------------------------- 战斗日志模块 End ---------------------------------------------


------------------------------------------------------------------------------------
---------------------------------战争建筑-------------------------------------------
------------------------------------------------------------------------------------

--怪物升级
function VRequest:MsgReqMonsterLevelUp(delegate, callBack, aParam)
	if not aParam then
		return
	end

	local var = {_pb = "MsgReqMonsterLevelUp"};

	local idUint64 = Var();
	idUint64:SetUint64(aParam.id);

	var.noAttrTypes = {};
	var.noAttrTypes[AttrType.AttrTypeSunshine] = 1;
	var.noAttrTypes[AttrType.AttrTypeMoney] = 1;

	var.thingid = aParam.thingid;
	var.pos = aParam.pos
	var.id = idUint64
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--建筑升级
function VRequest:MsgReqManorBuildingLevelUp(delegate, callBack, t)
	local var = {_pb = "MsgReqManorBuildingLevelUp"};
	var.noAttrTypes = {};
	var.noAttrTypes[AttrType.AttrTypeSunshine] = 1;
	var.noAttrTypes[AttrType.AttrTypeMoney] = 1;
	var.type = t;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--快速训练
function VRequest:MsgReqManorTrainingAccelerate(delegate, callBack, count, id, idx)
	local var = {_pb = "MsgReqManorTrainingAccelerate"};
	var.noReturnInfo = true;
	var.count = count;
	var.thingid = id;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--添加工人
function VRequest:MsgReqManorFarmerAdd(delegate, callBack, count)
	local var = {_pb = "MsgReqManorFarmerAdd"};
	var.count = count;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--加速升级
function VRequest:MsgReqLevelUpAccelerate(delegate, callBack, id, type, pos, class, cost)
	local var = {_pb = "MsgReqLevelUpAccelerate"};
	local id_suit_64 = Var();
	id_suit_64:SetUint64(id);
	var.noAttrTypes = {};
	var.noAttrTypes[AttrType.AttrTypeCurrency] = 1;
	var.noAttrTypes[AttrType.AttrTypeExp] = 1;
	var.noAttrTypes[AttrType.AttrTypeLevel] = 1;
	var.id = id_suit_64;
	var.type = type;
	var.pos = pos;
	var.class = class
	var.cost = cost;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
	gData.userInfo.roleInfo:noHeartBeatSyn(AttrType.AttrTypeExp, true);
	gData.userInfo.roleInfo:noHeartBeatSyn(AttrType.AttrTypeLevel, true);
	gData.userInfo.roleInfo:noHeartBeatSyn(AttrType.AttrTypeCurrency, true);
end

--取消升级
function VRequest:MsgReqLevelUpCancel(delegate, callBack, id, type, pos, class)
	local var = {_pb = "MsgReqLevelUpCancel"};
	local id_suit_64 = Var();
	id_suit_64:SetUint64(id);
	var.id = id_suit_64;
	var.type = type;
	var.pos = pos;
	var.class = class
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

------------------------------------------------------------------------------------
---------------------------------  活动  -------------------------------------------
------------------------------------------------------------------------------------

--抽奖
function VRequest:MsgReqRoulettePlay(delegate, callBack, multiple, type)
	local var = {_pb = "MsgReqRoulettePlay"};
	var.noReturnTip = true;
	var.multiple = multiple;
	var.type = type;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--签到
function VRequest:MsgReqUserCheckIn(delegate, callBack, type, days, idx, muliple)
	local var = {_pb = "MsgReqUserCheckIn"};
	var.noReturnTip = true;
	var.type = type;
	var.days = days;
	var.idx = idx;
	var.muliple = muliple;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--完成任务
function VRequest:MsgReqQuestFinish(delegate, callBack, questid, idx)
	local var = {_pb = "MsgReqQuestFinish"};
	var.questid = questid;
	var.idx = idx;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--------------------------------------------------------------------------------------------------------
--												排行榜模块
--------------------------------------------------------------------------------------------------------

-- 排行榜查询
function VRequest:MsgReqUserRankInfoQuery( start, count, type, delegate, callBack )
	-- local var = {_pb = "MsgReqUserRankInfoQuery"};
	-- var.start = start;
	-- var.count = count;
	-- var.type = type;
	-- var.delegate = delegate;
	-- var.callBack = callBack;
	-- self:addToReqQueue(var);
end

-- 排行榜领奖
function VRequest:MsgReqUserRankInfoReward( type, delegate, callBack )
	local var = {_pb = "MsgReqUserRankInfoReward"};
	var.type = type;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-- 排行榜兑换奖励
function VRequest:MsgReqUserRankRewardExchange( index, delegate, callBack )
	local var = {_pb = "MsgReqUserRankRewardExchange"};
	var.id = index;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--------------------------------------------------------------------------------------------------------
--												战斗模块
--------------------------------------------------------------------------------------------------------

-- 战斗开始
function VRequest:MsgReqAttack( targetId, battletype, delegate, callBack )
	local var = {_pb = "MsgReqAttack"};
	var.type = battletype;
	var.target = targetId;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-- 战斗定时上报
function VRequest:MsgReqBattleReport( eventTable, delegate, callBack )
	local var = {_pb = "MsgReqBattleReport", infos={}};
	for i,v in ipairs(eventTable) do
		local infos = {_pb = "BattleEvent", params={}, params2={}};
		infos.time = v.time;
		infos.road = v.road;
		infos.params = v.params;
		local idUint64 = Var();
		idUint64:SetUint64(v.params2[1]);
		infos.params2[1] = idUint64;
		infos.type = v.type;
		var.infos[i] = infos;
	end

	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-- 战斗结束上报
function VRequest:MsgReqAttackEnd( defender, time, battleEvent, retreatFlag, battleid, delegate, callBack )
	local var = {_pb = "MsgReqAttackEnd", infos={}};
	var.defender = defender;
	var.time = time;
	var.flag = retreatFlag;
	local idUint64 = Var();
	idUint64:SetUint64(battleid);
	var.battleid = idUint64;

	if battleEvent then
		for i,v in ipairs(battleEvent) do
			local infos = {_pb = "BattleEvent", params={}, params2={}};
			infos.type = v.type;
			infos.time = v.time;
			infos.road = v.road;
			infos.params = v.params;
			local idUint64 = Var();
			idUint64:SetUint64(v.params2[1]);
			infos.params2[1] = idUint64;
			table.insert(var.infos, infos);	
		end
	end

	var.delegate = delegate;
	var.callBack = callBack;
	var.noReturnTip = true;
	self:addToReqQueue(var);
end

-- 关卡战斗开始
function VRequest:MsgReqDungeonStart( id, delegate, callBack)
	local var = {_pb = "MsgReqDungeonStart"};
	var.id = id;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-- 关卡战斗结束上报
function VRequest:MsgReqDungeonEnd( actid, time, battleEvent, retreatFlag, delegate, callBack)
	local var = {_pb = "MsgReqDungeonEnd", infos={}};
	var.id = actid;
	var.time = time;
	var.flag = retreatFlag;

	if battleEvent then
		for i,v in ipairs(battleEvent) do
			local infos = {_pb = "BattleEvent", params={}, params2={}};
			infos.type = v.type;
			infos.time = v.time;
			infos.road = v.road;
			infos.params = v.params;
			local idUint64 = Var();
			idUint64:SetUint64(v.params2[1]);
			infos.params2[1] = idUint64;
			table.insert(var.infos, infos);	
		end
	end

	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

-- 团战开打
function VRequest:MsgReqGroupBattleAttack( targetId, battleId, delegate, callBack)
	local var = {_pb = "MsgReqGroupBattleAttack"};
	var.target = targetId;
	local idUint64 = Var();
	idUint64:SetUint64(battleId);
	var.battleid = idUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


--单次团战信息查询
function VRequest:MsgReqGroupBattleInfoQuery(delegate, callBack, battleid, param)
	local var = {_pb = "MsgReqGroupBattleInfoQuery"};
	local idUint64 = Var();
	idUint64:SetUint64(battleid);
	var.battleid = idUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	var.param = param;
	self:addToReqQueue(var);
end

--批量查询我的战场信息
function VRequest:MsgReqGroupBattleSelfInfoQuery(delegate, callBack, battleids)
	local var = {_pb = "MsgReqGroupBattleSelfInfoQuery"};
	var.battleids = {};
	for i,v in ipairs(battleids) do
		local idUint64 = Var();
		idUint64:SetUint64(v);
		table.insert(var.battleids, idUint64);
	end
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--加入团战
function VRequest:MsgReqGroupBattleJoin(delegate, callBack, target, attacker, defender, battleid)
	local var = {_pb = "MsgReqGroupBattleJoin"};
	var.target = target;
	var.attacker = attacker;
	var.defender = defender;
	local idUint64 = Var();
	idUint64:SetUint64(battleid);
	var.battleid = idUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

---------------------------------------------- 战斗模块 End ---------------------------------------------


--通用快捷购买
function VRequest:MsgReqThingDirectBuy(delegate, callBack, costInfo)
	local var = {_pb = "MsgReqThingDirectBuy"};
	var.dis = {};
	for i,v in ipairs(costInfo) do
		local dis = {_pb = "DirectBuyInfo"};
		dis.thingid = v.thingid;
		dis.count = v.count;
		dis.type = v.type;
		var.dis[i] = dis;
	end
	
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--------------------------------------------------------------------------------------------------------
--												卡牌系统
--------------------------------------------------------------------------------------------------------

--卡牌分解
function VRequest:MsgReqThingDecompose(delegate, callBack, id, aType)
	local var = {_pb = "MsgReqThingDecompose"};
	var.ids = {};
	local idUint64 = Var();
	idUint64:SetUint64(id);
	var.ids[1] = idUint64;
	var.type = aType;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--卡牌合成
function VRequest:MsgReqThingCompose(delegate, callBack, thingid, aType, idx)
	local var = {_pb = "MsgReqThingCompose"};
	var.thingid = thingid;
	var.count = 1;
	var.type = aType;
	var.idx = idx;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--僵尸复活
function VRequest:MsgReqMonsterRevive(delegate, callBack, id, idx)
	local var = {_pb = "MsgReqMonsterRevive"};
	var.ids = {};
	if type(id) == "table" then
		for i,v in ipairs(id) do 
			local idUint64 = Var();
			idUint64:SetUint64(v);
			table.insert(var.ids, idUint64);
		end
	else
		local idUint64 = Var();
		idUint64:SetUint64(id);
		var.ids[1] = idUint64;
		var.idx = idx;
	end
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

---------------------------------------------- 卡牌模块 End ---------------------------------------------

---------------------------------------------- 单机进度上报 ---------------------------------------------
function VRequest:MsgReqDungeonReport(delegate, callBack, data, chapterid, levelid)
	local var = {_pb = "MsgReqDungeonReport"};
	var.infos={};
	for i=1,#data do
		local act = {_pb = "ActInfo"};
		act.id = data[i].id;
		act.pass = data[i].pass;
		act.infos = {};
		for j=1,#data[i].campaignInfo do
			local camp = {_pb = "CampaignInfo"};
			camp.id = data[i].campaignInfo[j].id;
			camp.record = data[i].campaignInfo[j].record;
			camp.online_reward = data[i].campaignInfo[j].online_reward;
			camp.purchase = data[i].campaignInfo[j].purchase;
			table.insert(act.infos, camp);
		end
		table.insert(var.infos, act);
	end

	var.chapterid = chapterid
	var.levelid = levelid
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


---------------------------------------------- 关卡购买礼物 ---------------------------------------------
function VRequest:MsgReqDungeonOnlineReward(delegate, callBack, id)
	local var = {_pb = "MsgReqDungeonOnlineReward"};
	var.id = id;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end



---------------------------------------------- 关卡购买点 ---------------------------------------------
function VRequest:MsgReqDungeonPurchase(delegate, callBack, userDelegate, userCallBack, remind, id)
	local var = {_pb = "MsgReqDungeonPurchase"};
	var.remind = remind;
	var.id = id;
	var.delegate = delegate;
	var.callBack = callBack;
	var.userDelegate = userDelegate;
	var.userCallBack = userCallBack;
	self:addToReqQueue(var);
end


---------------------------------------------- 好友团战信息 ---------------------------------------------
function VRequest:MsgReqBriefUserBattleInfoQuery(delegate, callBack, pamram)
	local var = {_pb = "MsgReqBriefUserBattleInfoQuery"};
	var.userids = pamram.userids;
	var.pamram = pamram
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


--推荐对手查询
function VRequest:MsgReqFindOpponent(delegate, callBack, isCost)
	local var = {_pb = "MsgReqFindOpponent"};
	var.use_currency = isCost;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--团战领奖
function VRequest:MsgReqGroupBattleReward(delegate, callBack, battleid)
	local var = {_pb = "MsgReqGroupBattleReward"};
	local idUint64 = Var();
	idUint64:SetUint64(battleid);
	var.battleid = idUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

---------------------------------------------- 活动相关 ---------------------------------------------
function VRequest:MsgReqActivityInfoQuery(delegate, callBack)
	local var = {_pb = "MsgReqActivityInfoQuery"};
	var.channel = self.channelID;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

------------------------------------------------战旗系统----------------------------------------------

--抽取
function VRequest:MsgReqBannerRoulette(delegate, callBack, type)
	local var = {_pb = "MsgReqBannerRoulette"};
	var.type = type;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--升级
function VRequest:MsgReqBannerLevelUp(delegate, callBack, id, type, curLevel, maxLevel)
	local var = {_pb = "MsgReqBannerLevelUp"};
	var.attr_type = type;
	local idUint64 = Var();
	idUint64:SetUint64(id);
	var.id = idUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	var.curLevel = curLevel;
	var.maxLevel = maxLevel;
	self:addToReqQueue(var);
end

--分解
function VRequest:MsgReqBannerDecompose(delegate, callBack, id)
	local var = {_pb = "MsgReqBannerDecompose"};
	local idUint64 = Var();
	idUint64:SetUint64(id);
	var.id = idUint64;
	var.bannerId = id;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end

--激活
function VRequest:MsgReqBannerActivate(delegate, callBack, id)
	gLog("点击激活。。。")
	local var = {_pb = "MsgReqBannerActivate"};
	local idUint64 = Var();
	idUint64:SetUint64(id);
	var.id = idUint64;
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end


---查找有战斗的目标玩家
function VRequest:MsgReqBattlePlayerQuery(delegate, callBack, targets)
	local var = {_pb = "MsgReqBattlePlayerQuery"};
	var.targets = targets or {};
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end
----//增加升星器
function VRequest:MsgReqLabContainerAdd(delegate, callBack, count, pos)
	local var = {_pb = "MsgReqLabContainerAdd"};
	var.count = count;
	var.pos = pos
	var.delegate = delegate;
	var.callBack = callBack;
	self:addToReqQueue(var);
end
