-- vResponse.lua

--scoket出错返回
function VUiOnSocketError(msg)
	local reqid = msg.reqid
	VUiOnRespone(0, -1 , nil, reqid);
end

--scoket超时返回
function VUiOnSocketTimeOut()
	VUiOnRespone(0, -2 , nil);
end

--游戏服务器消息返回处理
--msg:返回消息ID，result:返回错误码，data:返回数据内容， reqid:请求的消息ID
function VUiOnRespone( msg, result, data, reqid)
	gWindow:stopTimeOut();

	local req = nil;
	local name = CMD[msg];
	if name then
		gLog("%s(id:%d, ret:%d)", name, msg, result);
		local rsp = nil;
		if data and result==0 then rsp = gPb:Read(name, data) end;	--消息数据protobuf解包
		if rsp then
			gLog(rsp:ToString());
			rsp = VPb(rsp);
		end

		if name == "MsgRspHeartbeat" then 							--特殊处理心跳，心跳请求和一般逻辑请求不在同一个队列
			gRsp[name](gRsp, result, rsp);
			VCallBack(gData, "heartBeatCallBack", result, rsp);
			gHeartBeatReqing = nil;
			return;
		end

		req = gReq.sendingReq;

		local responePush = false;
		--判断返回的消息ID和请求的消息ID是否相差1
		if req then
			if msg == 1 then
				gReq.sendingReq = nil;
			else
				local reqID = CMD[req._pb];
				if reqID + 1 ~= msg then
					req = nil;
					responePush = true;	--此时认为消息为推送，不清除当前请求队列
				else
					gReq.sendingReq = nil;	--ID判断匹配，清除当前请求队列。
				end
			end
		else
			responePush = true;		--此时认为消息为推送，不清除当前请求队列
		end

		--处理公共数据，比如returnInfo
		gRsp:processCommon(rsp, req);

		--调用公共消息处理方法。
		if gRsp[name] then
			if req then
				gRsp[name](gRsp, result, rsp, req);
			else
				gRsp[name](gRsp, result, rsp);
				-- gLog("req not found on Rsp msg \"%s\"", name);	
			end
		else
			gLog("unSupported Class on Rsp msg \"%s\"", name);
		end

		--调用用户回调方法
		if req then
			VCallBack(req.delegate, req.callBack, result, rsp, req);
			-- if result ~= 0 and req.noAttrTypes then
			-- 	gReq:synRoleInfoAll();
			-- end
		end
	else
		if reqid == 100 then
			-- gHeartBeatReqing = nil;
		else
			req = gReq.sendingReq;
			gReq.sendingReq = nil;
		end
		
		gLog("unSupported Rsp id \"%d\"", msg);
		if req then
			VCallBack(req.delegate, req.callBack, result, nil, req);
			-- if result ~= 0 and req.noAttrTypes then
			-- 	gReq:synRoleInfoAll();
			-- end
		end
	end

	--show result code 
	if ((req and not req.noErrorTip) or not req) then
		if result == -1 then
			if req then
				local name = "MsgRsp"..string.sub(req._pb, 7);
				gLog("socket error on msg \"%s\"", name);
			else
				gLog("socket error ");
			end
			if reqid == 100 then
				gHeartBeatError = gHeartBeatError + 1;
				if gHeartBeatError >= 3 then
					gHeartBeatError = 0;
					if not gData.offlineData.offline then
					gWindow:showConfirmTip("网络连接中断，点击确定重新连接。", "", nil, nil, "netWorkError")
					end
				else
					gHeartBeatReqing = nil;
				end
			else
				if not gData.offlineData.offline then
				gWindow:showConfirmTip("网络连接中断，点击确定重新连接。", "", nil, nil, "netWorkError")
				end
			end
		elseif result == -2 then
			if req then
				local name = "MsgRsp"..string.sub(req._pb, 7);
				gLog("socket timeout on msg \"%s\"", name);
			else
				gLog("socket timeout ");
			end
			-- if reqid == 100 then
			-- 	gHeartBeatError = gHeartBeatError + 1;
			-- 	if gHeartBeatError >= 3 then
			-- 		gHeartBeatError = 0;
			-- 		gWindow:showConfirmTip("网络连接超时，点击确定重新连接。", "", nil, nil, "netWorkError")
			-- 	else
			-- 		gHeartBeatReqing = nil;
			-- 	end
			-- else
			-- 	gWindow:showConfirmTip("网络连接超时，点击确定重新连接。", "", nil, nil, "netWorkError")
			-- end
		elseif result ~= 0 then
			local errorCode = gData:readCsv("errorCode.csv");
			local errordiscr = errorCode:lineDataWithKey(result, 1);
			if not errordiscr then errordiscr = string.format("未知错误码(%d)",result) end;
			
			gLog("错误码信息：%s(%d)", errordiscr, result);

			errordiscr = errordiscr;
			errordiscr = "*"..errordiscr.."*";
			gWindow:showTip(errordiscr);
		end
	end

	if msg == 1 then
		if result == 10 then
			gWindow:showConfirmTip("网络连接中断，请重新登录。", "", nil, nil, "netWorkError")
		elseif result == 11 then
			gWindow:showConfirmTip("账号在其他地方登录，请重新登录。", "", nil, nil, "netWorkError")
		elseif result == 25 then
			gWindow:showConfirmTip("服务器正在维护中，请稍后再试。", "", nil, nil, "netWorkError")
		end
	end

	if not responePush then
		gReq:checkReqQueue();
	end
end

--网络错误，弹回登录界面。
function netWorkError()
	if gView() == gMainView or gView() == gBattleView then
		gHeartBeatReqing = nil;
		gWindow:jumpToLoginView();
	end
end

------------------------------------------------------------
--公共处理return info
VResponse = vclass("Response");
function VResponse:processReturnInfo(returnInfo, noAttrTypes, req)
	local iter = VDataIter();
	if returnInfo.rtis then
		while returnInfo.rtis:Travel(iter) do
	    	local item = iter:Data();
	    	if item.type == ThingType.ThingTypeItem then
	    		local bagInfo = gData.userInfo.bagInfos;
	    		bagInfo:addItem(item.guid, item.thingid, item.count);
	    	elseif item.type == ThingType.ThingTypePlant then
	    		local plantManager = gData.userInfo.plantInfos;
	    		
	    		if req then
		    		plantManager:updatePlant(item.guid, item.thingid, item.count, req.isManorPlant);
		    	else
		    		plantManager:updatePlant(item.guid, item.thingid, item.count);
		    	end
	    	elseif item.type == ThingType.ThingTypeArm then
	    		local mi = gData.userInfo.monsterInfo;
	    		mi:addMonster(item.guid, item.thingid, item.count);
	    	elseif item.type == ThingType.ThingTypeWounded then
	    	elseif item.type == ThingType.ThingTypeDead then
	    	elseif item.type == ThingType.ThingTypeHeroExp then
	    	end
	    end
	end
	iter = VDataIter();
	if returnInfo.rais then
		local roleInfo = gData.userInfo.roleInfo;
		while returnInfo.rais:Travel(iter) do
	    	local item = iter:Data();
	    	--不处理req中指定的某些属性类型，用于预先处理过消耗的协议。
	    	if not noAttrTypes or not noAttrTypes[item.type] then
				roleInfo:addAttrValue(item.type, item.value);
	    	end
	    	if item.type == AttrType.AttrTypeExp then
	    	elseif item.type == AttrType.AttrTypeLevel then
	    	elseif item.type == AttrType.AttrTypeCurrency then
	    		if item.value > 0 then
	    			gAudio:playEffect("sys_get_vcoin.au");
	    		else
	    			gAudio:playEffect("sys_cost_vcoin.ogg");
	    		end
	    	elseif item.type == AttrType.AttrTypeStamina then
	    	elseif item.type == AttrType.AttrTypeCharge then
	    	elseif item.type == AttrType.AttrTypeMoney then
	    		if gView() == gMainView then
		    		if item.value > 0 then
		    			gAudio:playEffect("sys_get_coin.ogg");
		    		else
		    			gAudio:playEffect("sys_cost_coin.ogg");
		    		end
		    	end
	    	elseif item.type == AttrType.AttrTypeSunshine then
	    		if gView() == gMainView then
		    		if item.value > 0 then
		    			gAudio:playEffect("sys_get_sun.ogg");
		    		else
		    			gAudio:playEffect("sys_cost_sun.ogg");
		    		end
		    	end
	    	end
	    end
	end
end

function VResponse:processCommon(rsp, req)
	if not rsp then return end;
	local iter = VDataIter()
	while rsp:Travel(iter) do
		local item = iter:Data();
		if type(item) == "table" and item._pb and item._pb == "ReturnInfo" then
			if item.userid == gData.userInfo.userid then
				if req then
					if not req.noReturnInfo then 				--不处理returnInfo
						self:processReturnInfo(item, req.noAttrTypes, req);
					end
					-- if not req.noReturnTip then
					-- 	gWindow:checkNeedShowReturn(item);
					-- end
				else
					self:processReturnInfo(item, nil, nil);
					-- gWindow:checkNeedShowReturn(item);
				end
			end
			break
		end
	end
end


function VResponse:MsgRspAccountRestore( result, aMsgRspAccountRestore, req )
	if result == 0 then

	end
end

function VResponse:MsgRspAccountRestore2( result, aMsgRspAccountRestore2, req )
	if result == 0 then
		if aMsgRspAccountRestore2 then
			local rsp = aMsgRspAccountRestore2;
			local psw = rsp.psw;
			local accountid = rsp.accountid;
			
			gData.accountInfo:setAccountIDandPsw(accountid, psw);
			gClient:setUserid(accountid);
		end
	end
end

function VResponse:MsgRspAccountRegister( result, aMsgRspAccountRegister, req )
	if result == 0 then
		local rsp = aMsgRspAccountRegister;
		local accountid = rsp.accountid;
		local psw = rsp.psw;

		gData.accountInfo:setAccountIDandPsw(accountid, psw);
		gClient:setUserid(accountid);
	end
end

function VResponse:MsgRspLogin( result, aMsgRspLogin, req )
	if result == 0 then
		local rsp = aMsgRspLogin;
		local sessionid = rsp.sessionid;
		local info = rsp.info;
		local aes_key = rsp.aes_key;

		if req.account_name then
			local accountid = info.accountid;
			local psw = req.psw;
			gData.accountInfo:setAccountIDandPsw(accountid, psw);
			gClient:setUserid(accountid);
		end

		if sessionid then
			gClient:setSessionid(sessionid);
		end

		if aes_key then
			gClient:setAesKey(aes_key);
		end

		gData.accountInfo:synWithPbData(info);
	end
end

function VResponse:MsgRspRoleRegister( result, aMsgRspRoleRegister, req )
	if result == 0 then
		local rsp = aMsgRspRoleRegister;
		local info = rsp.info;

		gData.accountInfo:synWithPbData(info);
	end
end

function VResponse:MsgRspGameEnter( result, aMsgRspGameEnter, req )
	if result == 0 then
        if aMsgRspGameEnter then
			local rsp = aMsgRspGameEnter;
			local time = rsp.time;

			gData.timeDev = time - os.time();
			cclog("gData.timeDev = %f", gData.timeDev);
		end
	end
end

function VResponse:MsgRspHeartbeat( result, aMsgRspHeartbeat, req )
	
end

function VResponse:MsgRspStaticUserDataQuery( result, aMsgRspStaticUserDataQuery, req )

end

function VResponse:MsgRspUserDataSyn( result, aMsgRspUserDataSyn, req )
	if result == 0 then
		local rsp = aMsgRspUserDataSyn;
		if rsp then
			local user_info = rsp.user_info;
			if req then
				gData.userInfo:synWithPbData(user_info, req.isHeartBeat, req.syn_flag);
			else
				gData.userInfo:synWithPbData(user_info, true, 0);
			end;
		end
	end
end


function VResponse:MsgRspRichOtherUserInfoQuery( result, aMsgRspRichOtherUserInfoQuery, req )
	if result == 0 then
		local rsp = aMsgRspRichOtherUserInfoQuery;
	end
end

--------------------------------------------------------------------------------------------------------
--												聊天
--------------------------------------------------------------------------------------------------------
function VResponse:MsgRspMessagePost( result, aMsgRspMessagePost, req )
	if result == 0 then
		
	end
end

--团战聊天
function VResponse:MsgRspGroupBattleMessagePost( result, aMsgRspGroupBattleMessagePost, req )
	if result == 0 then
	end
end
function VResponse:MsgRspGroupBattleMessageFetch( result, aMsgRspGroupBattleMessageFetch, req )
	if result == 0 then
	end
end

--------------------------------------------------------------------------------------------------------
--												农场\背包\商店模块
--------------------------------------------------------------------------------------------------------


------ 植物的种植与回收

function VResponse:MsgRspManorPlantPlace( result, aMsgRspManorPlantPlace, req )
	if result == 0 then
		local rsp = aMsgRspManorPlantPlace;
        local mi = rsp.mi;
        
        gData.userInfo.manorInfo:synWithPbData(mi)

        if req.pos.x ~= 0 then
        	gData:RunTrainning(nil, "RSPPLANT")
        end
	end 
end


------ 植物升级

function VResponse:MsgRspManorPlantLevelUp( result, aMsgRspManorPlantLevelUp, req )
	gData.userInfo.manorInfo:enableStopHeartBeatSyn(false);
    gData:enableStopUserSyn(false);
	if result == 0 then
        local rsp = aMsgRspManorPlantLevelUp;
        local mi = rsp.mi;
        gData.userInfo.manorInfo:synWithPbData(mi)
	end
end

function VResponse:MsgRspManorPlantLevelUpCancel( result, aMsgRspManorPlantLevelUpCancel, req )
	if result == 0 then


	end
end


------植物收获

function VResponse:MsgRspManorPlantReceive( result, aMsgRspManorPlantReceive, req )
	if result == 0 then
        local rsp = aMsgRspManorPlantReceive;
        local fi = rsp.fi;
        gData.userInfo.manorInfo:updateFarmInfo(fi)
	end
end

------植物加速
function VResponse:MsgRspManorPlantAccelerate( result, aMsgRspManorPlantAccelerate, req )
	if result == 0 then
		gData.userInfo.roleInfo:UpDataAccelerateProduceTimes()
	end
end



function VResponse:MsgRspThingSell( result, aMsgRspThingSell, req )
	if result == 0 then
		
	end
end

------仓库扩充 备注:现在时间戳为格子开启时刻的时间戳
function VResponse:MsgRspBagExtend( result, aMsgRspBagExtend, req )
	if result == 0 then
	    local rsp = aMsgRspBagExtend
	    local cur_value = rsp.total_count
        gData.userInfo.roleInfo.bagSize.cur_value = cur_value
        cclog("当前仓库容量:"..cur_value)
        local csvData = gData:readCsv("bag_extend.csv");
        local lineData = csvData:lineDataWithKey(cur_value);
        
        gData.userInfo.roleInfo:UpDataStartTime()
        
	end

end


------仓库物品使用
function VResponse:MsgRspItemUse( result, aMsgRspItemUse, req )
	if result == 0 then
		
	end
end

------仓库物品出售

-----扩地
function VResponse:MsgRspManorExtend( result, aMsgRspManorExtend, req )
	if result == 0 then
		local mi = aMsgRspManorExtend.mi;
        gData.userInfo.manorInfo:synWithPbData(mi)
	end
end


-----商店刷新  备注:现在时间戳为下次刷新的时间
function VResponse:MsgRspShopRefresh( result, aMsgRspShopRefresh, req )
	if result == 0 then
		local rsp = aMsgRspShopRefresh;
		local si = rsp.si;
		local times = rsp.times;
		
        gData.userInfo.roleInfo.roleShopInfo:synWithPbData(si);
        gData.userInfo.roleInfo:UpDataShopRefreshTimes(times)
	end
end


-----商店买东西
function VResponse:MsgRspItemBuy( result, aMsgRspItemBuy, req )
	if result == 0 then
		local rsp = aMsgRspItemBuy;
		local si = rsp.si;
        
        if si then
		    gData.userInfo.roleInfo.roleShopInfo:synWithPbData(si);
		end
	end
end


-----商店扩充
function VResponse:MsgRspShopExtend( result, aMsgRspShopExtend, req )
	if result == 0 then
		local rsp = aMsgRspShopExtend;
		local si = rsp.si;

		gData.userInfo.roleInfo.roleShopInfo:synWithPbData(si);
	end
end

---------------------------------------------- 农场\背包\商店模块 End ---------------------------------------------


--------------------------------------------------------------------------------------------------------
--												新手训练模块
--------------------------------------------------------------------------------------------------------

function VResponse:MsgRspTrainingComplete( result, aMsgRspTrainingComplete, req )
	if result == 0 then
		
	end
end
---------------------------------------------- 新手训练模块 End ---------------------------------------------


--------------------------------------------------------------------------------------------------------
--												植物僵尸抽奖模块
--------------------------------------------------------------------------------------------------------

function VResponse:MsgRspPlantWheel( result, aMsgRspPlantWheel, req )
	if result == 0 then
	end
end

function VResponse:MsgRspMonsterWheel( result, aMsgRspMonsterWheel, req )
	if result == 0 then

	end
end

function VResponse:MsgRspMonsterAdvance( result, aMsgRspMonsterAdvance, req )
	if result == 0 then
		local rsp = aMsgRspMonsterAdvance;
		local ai = rsp.ai;
		local armyid = ai.armyid;
		local qulity = ai.qulity;
		gData.userInfo.armyTechInfos.techInfos[armyid]:updateQuality(qulity)
	end
end
---------------------------------植物僵尸抽奖模块end----------------------------------------




--------------------------------------------------------------------------------------------------------
--												好友模块
--------------------------------------------------------------------------------------------------------

-----------用户查询
function VResponse:MsgRspUserSearch( result, aMsgRspUserSearch, req )
	if result == 0 then
		
	end
end


--------好友查询
function VResponse:MsgRspBriefUserInfoQuery( result, aMsgRspBriefUserInfoQuery, req )
	if result == 0 then
		local rsp = aMsgRspBriefUserInfoQuery;
		if not rsp then return end;
		local infos = rsp.infos;--Is list
		if infos then
			local iter = VDataIter();
			while infos:Travel(iter) do
				local userInfo = VBriefUserInfo:new();
				userInfo:synWithPbData(iter:Data());
				gData:addBriefUserInfo(userInfo);
		    end
		end
	end
end

----------好友添加
function VResponse:MsgRspFriendAdd( result, aMsgRspFriendAdd, req )
	if result == 0 then
		gData.userInfo.friendInfos:AddFriend(req.userid)
	end
end


----------删除好友
function VResponse:MsgRspFriendDel( result, aMsgRspFriendDel, req )
	if result == 0 then
		for k, v in ipairs(req.userids) do
        	gData.userInfo.friendInfos:DelFriend(v)
    	end
	end
end


----------好友帮忙
function VResponse:MsgRspManorPlantHelp( result, aMsgRspManorPlantHelp, req )
	if result == 0 then
		local rsp = aMsgRspManorPlantHelp;
		local ri = rsp.ri;
		local rtis = ri.rtis;--Is list
--		local param1 = rtis[0].param1;
--		local count = rtis[0].count;
--		local param0 = rtis[0].param0;
--		local guid = rtis[0].guid;
--		local thingid = rtis[0].thingid;
--		local type = rtis[0].type;
		local rais = ri.rais;--Is list
--		local value = rais[0].value;
--		local type_1 = rais[0].type;
		local userid = ri.userid;
		local fi = rsp.fi;
		gData.userInfo.manorInfo:updateFarmInfo(fi)

	end
end

---------------------------------------------- 好友模块 End ---------------------------------------------



--------------------------------------------------------------------------------------------------------
--												修改角色资料模块
--------------------------------------------------------------------------------------------------------

-----------账号修改
function VResponse:MsgRspAccountUpdate( result, aMsgRspAccountUpdate, req )
	if result == 0 then
		if req.new_name ~= nil then
        	gData.accountInfo:UpDataName(req.new_name)
	    end
	    if req.new_psw ~= nil then
	    	local rsp = aMsgRspAccountUpdate
	        gData.accountInfo:SetOwnPsw(true)
	        gData.accountInfo:setAccountIDandPsw(rsp.info.accountid, req.new_psw)
	    end  
	end
end


-----------角色资料更新
function VResponse:MsgRspPlayerUpdate( result, aMsgRspPlayerUpdate, req )
	if result == 0 then
-- 		local rsp = aMsgRspPlayerUpdate;
-- 		local ri = rsp.ri;
-- 		local rtis = ri.rtis;--Is list
-- --		local param1 = rtis[0].param1;
-- --		local count = rtis[0].count;
-- --		local param0 = rtis[0].param0;
-- --		local guid = rtis[0].guid;
-- --		local thingid = rtis[0].thingid;
-- --		local type = rtis[0].type;
-- 		local rais = ri.rais;--Is list
-- --		local value = rais[0].value;
-- --		local type_1 = rais[0].type;
-- 		local userid = ri.userid;
		if req.nick ~= nil then
	        gData.userInfo.roleInfo:UpDataNick(req.nick)
	        gData.userInfo.roleInfo:UpDataNickChange()
	    end
	    if req.sex ~= nil then
	        gData.userInfo.roleInfo:UpDataSex(req.sex)
	    end
	end
end

-----------绑定步骤1
function VResponse:MsgRspAccountBinding( result, aMsgRspAccountBinding, req )
	if result == 0 then
		
	end
end


-----------绑定步骤2
function VResponse:MsgRspAccountBinding2( result, aMsgRspAccountBinding2, req )
	if result == 0 then
		if req.binding_type == BindingType.BindingEmail then
	        gData.accountInfo:UpDataEmail(req.value)
	    elseif req.binding_type == BindingType.BindingMobile then
	        gData.accountInfo:UpDataPhone(req.value)
	    elseif req.binding_type == BindingType.BindingIdcard then
	        gData.accountInfo:UpDataIDCard(req.value)
	    end
	end
end
---------------------------------------------- 修改角色资料模块 End ---------------------------------------------



--------------------------------------------------------------------------------------------------------
--												战斗日志模块
--------------------------------------------------------------------------------------------------------

function VResponse:MsgRspEnemyDel( result, aMsgRspEnemyDel, req )
	if result == 0 then
		local rsp = aMsgRspEnemyDel;
        gData.userInfo.enemyInfos:DelEnemy(req.userid)
	end
end

function VResponse:MsgRspEnemyAdd( result, aMsgRspEnemyAdd, req )
	if result == 0 then
		local rsp = aMsgRspEnemyAdd;
		 gData.userInfo.enemyInfos:AddEnemy(req.userid)
	end
end

function VResponse:MsgRspBattleLogQuery( result, aMsgRspBattleLogQuery, req )
	if result == 0 then
	end
end


---------------------------------------------- 战斗日志模块 End ---------------------------------------------






--------------------------------------------------------------------------------------------------------
--												战争建筑
--------------------------------------------------------------------------------------------------------


function VResponse:MsgRspMonsterLevelUp( result, aMsgRspMonsterLevelUp, req )
	if result == 0 then
		local rsp = aMsgRspMonsterLevelUp;
		local mi = rsp.mi;
		-- gData.userInfo.manorInfo:synWithPbData(mi);
	end
end

--建筑升级
function VResponse:MsgRspManorBuildingLevelUp( result, aMsgRspManorBuildingLevelUp, req )
	gData.userInfo.manorInfo:enableStopHeartBeatSyn(false);
	gData:enableStopUserSyn(false);
	if result == 0 then
		local rsp = aMsgRspManorBuildingLevelUp;
		local mi = rsp.mi;
		gData.userInfo.manorInfo:synWithPbData(mi);
	else
		if req.type == BUILDING_TYPE.BuildingStore then 
			local storeInfo = gData.userInfo.manorInfo.storeInfo;
			storeInfo:revertLevelUp();
		elseif req.type == BUILDING_TYPE.BuildingArmycamp then
			local armCampInfo = gData.userInfo.manorInfo.armCamp;
			armCampInfo:revertLevelUp();
		elseif req.type == BUILDING_TYPE.BuildingBasecamp then
			local baseCampInfo = gData.userInfo.manorInfo.baseCampInfo;
			baseCampInfo:revertLevelUp();
		elseif req.type == BUILDING_TYPE.BuildingLaboratory then
			local laboratory = gData.userInfo.manorInfo.laboratory;
			laboratory:revertLevelUp();
		end
	end

	if gMainView then
		gMainView.manorView:setLevelOpreation(req.type, false);
        gMainView:refreshBuilding(req.type);
    end
end


--建筑工人购买
function VResponse:MsgRspManorFarmerAdd( result, aMsgRspManorFarmerAdd, req )
	if result == 0 then
		local rsp = aMsgRspManorFarmerAdd;
		local mi = rsp.mi;
		gData.userInfo.manorInfo:synWithPbData(mi);
	else
		gData.userInfo.manorInfo:addFarmer(-1);
		if gMainView then
			gMainView:refreshFarmerValue();
		end
	end
end

--加速升级
function VResponse:MsgRspLevelUpAccelerate( result, aMsgRspLevelUpAccelerate, req )
	gData.userInfo.manorInfo:enableStopHeartBeatSyn(false);
	gData:enableStopUserSyn(false);
	gData.userInfo.roleInfo:noHeartBeatSyn(AttrType.AttrTypeExp, false);
	gData.userInfo.roleInfo:noHeartBeatSyn(AttrType.AttrTypeLevel, false);
	gData.userInfo.roleInfo:noHeartBeatSyn(AttrType.AttrTypeCurrency, false);
	if result == 0 then
		-- local rsp = aMsgRspLevelUpAccelerate;
		-- local mi = rsp.mi;
		-- gData.userInfo.manorInfo:synWithPbData(mi);
	end

	if req.type and gMainView then
		if req.type == LEVELUP_TYPE.LevelupBuilding then
			local id = req.id:ToInt();
			gMainView.manorView:setLevelOpreation(id, false);
		elseif req.type == LEVELUP_TYPE.LevelupPlant then
			local plantId = req.id:String();
			gFarm:setLevelOpreationWithId(plantId, false);
		end
	end
end

--取消升级
function VResponse:MsgRspLevelUpCancel( result, aMsgRspLevelUpCancel, req )
	gData.userInfo.manorInfo:enableStopHeartBeatSyn(false);
	gData:enableStopUserSyn(false);
	if result == 0 then
		-- local rsp = aMsgRspLevelUpCancel;
		-- local mi = rsp.mi;
		-- gData.userInfo.manorInfo:synWithPbData(mi);
	end
	if req.type and gMainView then
		if req.type == LEVELUP_TYPE.LevelupBuilding then
			local id = req.id:ToInt();
			gMainView.manorView:setLevelOpreation(id, false);
		elseif req.type == LEVELUP_TYPE.LevelupPlant then
			local plantId = req.id:String();
			gFarm:setLevelOpreationWithId(plantId, false);
		end
	end
end

function VResponse:MsgRspPlantInherit( result, aMsgRspPlantInherit, req )
	if result == 0 then
		local rsp = aMsgRspPlantInherit;
		local pi = rsp.pi;
		local p = gData.userInfo.plantInfos.plants[pi.bi.id];
		if p then
			p:synWithPbData(pi);
		end
		local mi = rsp.mi;
		gData.userInfo.manorInfo:synWithPbData(mi);
	end
end

--------------------------------------------------------------------------------------------------------
--												每日活动
--------------------------------------------------------------------------------------------------------

--抽奖
function VResponse:MsgRspRoulettePlay( result, aMsgRspRoulettePlay, req )
	-- if result == 0 then
	-- end
end

--签到
function VResponse:MsgRspUserCheckIn( result, aMsgRspUserCheckIn, req )
	-- if result == 0 then
	-- end
end

--完成任务
function VResponse:MsgRspQuestFinish( result, aMsgRspQuestFinish, req )
	-- if result == 0 then

	-- end
end

--------------------------------------------------------------------------------------------------------
--												排行榜模块
--------------------------------------------------------------------------------------------------------

-- 排行榜查询
function VResponse:MsgRspUserRankInfoQuery( result, aMsgRspUserRankInfoQuery, req )
	if result == 0 then
		local rsp = aMsgRspUserRankInfoQuery;
	end
end

-- 排行榜领奖
function VResponse:MsgRspUserRankInfoReward( result, aMsgRspUserRankInfoReward, req )
	if result == 0 then
		local rsp = aMsgRspUserRankInfoReward;
	end
end

-- 排行榜兑换奖励
function VResponse:MsgRspUserRankRewardExchange( result, aMsgRspUserRankRewardExchange, req )
	if result == 0 then
		local rsp = aMsgRspUserRankRewardExchange;
	end
end

--------------------------------------------------------------------------------------------------------
--												战斗模块
--------------------------------------------------------------------------------------------------------

-- 掠夺对象查询
function VResponse:MsgRspFindOpponent( result, aMsgRspFindOpponent, req )
	if result == 0 then
		
	end
end

-- 战斗开始
function VResponse:MsgRspAttack( result, aMsgRspAttack, req )
	if result == 0 then
		if gBattleView then
			gBattleView:startBattle(aMsgRspAttack);
		end
		local assist_info = aMsgRspAttack.assist_info; 
		gData.userInfo.roleInfo.roleBattleInfo:synWithAssistInfo(assist_info);
	else
		if gBattleView then
			gBattleView:attackError(result);
		end
	end
end

-- 战斗定时上报
function VResponse:MsgRspBattleReport( result, aMsgRspBattleReport, req )
	if result == 0 then
		local rsp = aMsgRspBattleReport;
	end
end

-- 战斗结束上报
function VResponse:MsgRspAttackEnd( result, aMsgRspAttackEnd, req )
	-- if result == 0 then
	-- 	if gBattleView then
	-- 		-- 结算
	-- 		local result = aMsgRspAttackEnd.result;
	-- 		gBattleView:showBattleResultView(result);
			
	-- 		-- 战斗逻辑比较
	-- 		local str = aMsgRspAttackEnd.str;
	-- 		gBattleView:compareBattleLog(str);
	-- 	end
	-- else
	-- 	if gBattleView then
	-- 		gBattleView:attackError(result);
	-- 	end
	-- end
end

-- 关卡战斗开始
function VResponse:MsgRspDungeonStart( result, aMsgRspDungeonStart, req )
	if result == 0 then
		local rsp = aMsgRspDungeonStart;
	else
		if gBattleView then
			gBattleView:attackError(result);
		end
	end
end

-- 关卡战斗结束上报
function VResponse:MsgRspDungeonEnd( result, aMsgRspDungeonEnd, req )
	-- if result == 0 then
	-- 	gData.offlineData:updateLastServerData(aMsgRspDungeonEnd.info);
	-- end
	-- if result == 0 then
	-- 	if gBattleView then
	-- 		-- 结算
	-- 		local result = aMsgRspActEnd.result;
	-- 		gBattleView:showBattleResultView(result);

	-- 		-- 刷新关卡
	-- 		if aMsgRspActEnd.ai then
	-- 			gData.userInfo.roleInfo:UpDataActInfo(aMsgRspActEnd.ai);
	-- 		end

	-- 		-- 战斗逻辑比较
	-- 		local str = aMsgRspActEnd.str;
	-- 		gBattleView:compareBattleLog(str);
	-- 	end
	-- else
	-- 	if gBattleView then
	-- 		gBattleView:attackError(result);
	-- 	end
	-- end
end

-- 团战开打
function VResponse:MsgRspGroupBattleAttack( result, aMsgRspGroupBattleAttack, req )
	if result == 0 then
		if gBattleView then
			gBattleView:startBattle(aMsgRspGroupBattleAttack);
		end
	else
		if gBattleView then
			gBattleView:attackError(result);
		end
	end
end

--团战信息查询
function VResponse:MsgRspGroupBattleInfoQuery( result, aMsgRspGroupBattleInfoQuery, req )
	if result == 0 then

	end
end

--批量查询我的战场信息
function VResponse:MsgRspGroupBattleSelfInfoQuery( result, aMsgRspGroupBattleSelfInfoQuery, req )
	if result == 0 then
	end
end

--团战加入
function VResponse:MsgRspGroupBattleJoin( result, aMsgRspGroupBattleJoin, req )
	if result == 0 then
	end
end

---------------------------------------------- 战斗模块 End ---------------------------------------------

--通用快捷购买
function VResponse:MsgRspThingDirectBuy( result, aMsgRspThingDirectBuy, req )
	if result == 0 then
	end
end

--------------------------------------------------------------------------------------------------------
--												卡牌系统
--------------------------------------------------------------------------------------------------------

--卡牌分解
function VResponse:MsgRspThingDecompose( result, aMsgRspThingDecompose, req )
	if result == 0 then

	end
end

--卡牌合成
function VResponse:MsgRspThingCompose( result, aMsgRspThingCompose, req )
	if result == 0 then
	end
end


--僵尸复活
function VResponse:MsgRspMonsterRevive( result, aMsgRspMonsterRevive, req )
	if result == 0 then

	end
end

---------------------------------------------- 卡牌模块 End ---------------------------------------------

function VResponse:MsgRspDungeonReport( result, aMsgRspDungeonReport, req )
	if result == 0 then
		--do nothing
	
	end
end

function VResponse:MsgRspDungeonPurchase( result, aMsgRspDungeonPurchase, req )
	if result == 0 then
		
	end
end

function VResponse:MsgRspDungeonOnlineReward( result, aMsgRspDungeonOnlineReward, req )
	if result == 0 then
		
	end
end

--推荐对手查询
function VResponse:MsgRspFindOpponent( result, aMsgRspFindOpponent, req )
	if result == 0 then

	end
end

function VResponse:MsgRspBriefUserBattleInfoQuery( result, aMsgRspBriefUserBattleInfoQuery, req )
	if result == 0 then
		
	end
end

--团战领取奖励
function VResponse:MsgRspGroupBattleReward( result, aMsgRspGroupBattleReward, req )
	if result == 0 then
	end
end

function VResponse:MsgServerNotifyAction( result, aMsgServerNotifyAction)
	if result == 0 then
		gData:ServerNotifyAction(result, aMsgServerNotifyAction)
	end
end

--------------------------------------------------------------------------------------------------------
--												活动相关
--------------------------------------------------------------------------------------------------------
function VResponse:MsgRspActivityInfoQuery( result, aMsgRspActivityInfoQuery, req )
	if result == 0 then
		local rsp = aMsgRspActivityInfoQuery;
		local activityInfo = rsp.activity_info;

		local show_statusinfo = {};
		local start_statusinfo = {};
		local reward_statusinfo = {};

		local iter = VDataIter();
		if activityInfo.show_statusinfo and activityInfo.show_statusinfo.id then
			while activityInfo.show_statusinfo.id:Travel(iter) do
				local id = iter:Data();
				table.insert(show_statusinfo, id);
			end
		end

		iter = VDataIter();
		if activityInfo.start_statusinfo and activityInfo.start_statusinfo.id then
			while activityInfo.start_statusinfo.id:Travel(iter) do
				local id = iter:Data();
				table.insert(start_statusinfo, id);
			end
		end

		iter = VDataIter();
		if activityInfo.reward_statusinfo and activityInfo.reward_statusinfo.id then
			while activityInfo.reward_statusinfo.id:Travel(iter) do
				local id = iter:Data();
				table.insert(reward_statusinfo, id);
			end
		end
		
		gData.userInfo.eventEntryInfos:update(show_statusinfo, start_statusinfo, reward_statusinfo);
	end
end
---------------------------------------------- 活动相关 End ---------------------------------------------

----------------------------------------------	战旗 ----------------------------------------------------
function VResponse:MsgRspBannerRoulette( result, aMsgRspBannerRoulette, req )
	if result == 0 then
		local rsp = aMsgRspBannerRoulette;
		gData.userInfo.bannerInfos:updateOrAddBanner(rsp.info);
		if rsp.active_info and rsp.active_info.bi then
			gData.userInfo.roleInfo:updateActive(rsp.active_info)
		end
	end
end

function VResponse:MsgRspBannerLevelUp( result, aMsgRspBannerLevelUp, req )
	if result == 0 then
		local rsp = aMsgRspBannerLevelUp;
		gData.userInfo.bannerInfos:updateOrAddBanner(rsp.info);
	end
end

function VResponse:MsgRspBannerActivate( result, aMsgRspBannerActivate, req )
	if result == 0 then
		local rsp = aMsgRspBannerActivate;
		gData.userInfo.roleInfo:updateActive(rsp.active_info);
	end
end

function VResponse:MsgRspBannerDecompose( result, aMsgRspBannerDecompose, req )
	if result == 0 then
		gData.userInfo.bannerInfos:deleteBanner(req.bannerId);
	end
end
----------------------------------------------  战旗 End-------------------------------------------------



----查找有战斗的目标玩家
function VResponse:MsgRspBattlePlayerQuery( result, aMsgRspBattlePlayerQuery, req )
	if result == 0 then
		local rsp = aMsgRspBattlePlayerQuery;
--		local in_battle_targets = rsp.in_battle_targets[0];

	end
end
----增加升星器
function VResponse:MsgRspLabContainerAdd( result, aMsgRspLabContainerAdd, req )
	if result == 0 then
		local rsp = aMsgRspLabContainerAdd;
		local mi = rsp.mi;
		gData.userInfo.manorInfo:synWithPbData(mi)
	end
end