--vcore.lua
vclass = require "middleclass"
gRes = cc.VResource:Static()

if gRes:Platform() == "android" then
	luaj = require("luaj")
end

if gRes:Platform() == "ios" or gRes:Platform() == "mac" then
	luaoc = require("luaoc")
end

require "BitTools"
gBit = BitTools:new();

-- 版本分支号为空(老版本) 默认设置为2-2分支
if gBranch == nil then
	gBranch = 2;
end

local local_bit = bit;
function versionToNumber(v)
	local _, _, a, b, c = string.find(v, "(%d+).(%d+).(%d+)");
	if a and b and c then
		-- return bit.bor(bit.lshift(a, 24), bit.lshift(b, 16), c);
		return gBit:_or(gBit:_or(gBit:_lshift(tonumber(a), 24), gBit:_lshift(tonumber(b), 16)), tonumber(c));
	end
	return 0;
end

function versionCompare(v1, v2)
	if v1 == v2 then return 0 end;
	if versionToNumber(v1) > versionToNumber(v2) then return 1 end;
	return -1;
end

gRes:makeDir("image");
if versionCompare(gRes:Version(), "1.0.3") ~= -1 then
	gRes:addSearchPath("image/");
end
if versionCompare(gRes:Version(), "1.0.5") ~= -1 then
	gShaderInterface = true;
end
if versionCompare(gRes:Version(), "1.0.6") ~= -1 then
	gListDynamicCellHight = true;
end

gDtr = cc.Director:getInstance()
gLua = cc.VLuaEngine:Static()
gNet = cc.VNetMgr:Static()
gPb = cc.VPbProto:Static()
gClient = cc.VClient:Static()
gFormat = string.format
gLog = function(...) 
	if gForTest then
		gRes:LogS(gFormat(...)) 
	end
end
gPush = function(node) return gWindow:Push(node) end
gPop = function(node) return gWindow:Pop(node) end
gView = function(idx) return idx and gWindow:view()(idx) or gWindow:view() end

VLuaType = {
	VLuaTypeNil				= 0,
	VLuaTypeBoolean			= 1,
	VLuaTypeLightUserData	= 2,
	VLuaTypeNumber			= 3,
	VLuaTypeString			= 4,
	VLuaTypeTable			= 5,
	VLuaTypeFunction		= 6,
	VLuaTypeUserdata		= 7,
	VLuaTypeThread			= 8,
	VLuaTypeObject			= 15,
	VLuaTypeArray			= 25,
	VLuaTypeBytes			= 50,
	VLuaTypeUint64			= 60
}

VDataIter = function() return cc.VDataIter:new(); end
VData = function(...) return cc.VData:new(...); end
VAction = function(...) return cc.VAction:create(...); end

function addZonePath(path)
	if gZoneid then
		return gZoneid.."/"..path;
	end
	return path;
end

function removeZonePath(path)
	if gZoneid then
		return string.gsub(path, gZoneid.."/", "");
	end
	return path;
end

function addUserPath(path)
	if gZoneid and gData.userInfo.userid then
		return gZoneid.."/"..gData.userInfo.userid.."/"..path;
	end
	return path;
end

function removeUserPath(path)
	if gZoneid and gData.userInfo.userid then
		return string.gsub(path, gZoneid.."/"..gData.userInfo.userid.."/", "");
	end
	return path;
end

function pairsByKeys(t)  
    local a = {}  
    for n in pairs(t) do
        a[#a+1] = n
    end
    table.sort(a)  
    local i = 0  
    return function()
        i = i + 1  
        return a[i], t[a[i]]  
    end  
end

function VCallBack(delegate, callBack, ...)
	if callBack then
		if type(callBack) == "string" then
			if delegate and delegate["IsValid"] then
				if delegate:IsValid() and delegate[callBack] then
					delegate[callBack](delegate, ...)
				end
			elseif delegate then
				if delegate[callBack] then
					delegate[callBack](delegate, ...)
				end
			elseif _G[callBack] then
				_G[callBack](...);
			end
	    else
	        callBack(...);
	    end
	end
end

function makePswMd5(psw)
	if psw and psw ~= "" then
		return gClient:md5(gClient:base64(gClient:md5(psw)));
	end
	return psw
end

function FromVData( data )
    if data then
        local tp = type(data);
        if tp == "table" and data._cobj then
            data = data._cobj
        elseif tp ~= "userdata" then
            return data
        end
        tp = data:Type();
	    if tp == VLuaType.VLuaTypeObject then
		    local obj = {}
		    local iter = VDataIter()
		    while data:Travel(iter) do
			    obj[iter:Name()] = FromVData(iter:Data())
		    end
		    return obj
	    elseif tp == VLuaType.VLuaTypeArray then
		    local lst = {}
		    local iter = VDataIter()
		    while data:Travel(iter) do
			    table.insert(lst, FromVData(iter:Data()))
		    end
		    return lst
 	    end
    end
	return data;
end

_Var = {}
_Var.__index = function( t, k )
    if t._cobj[k] then
    	local func = function( self, ... )
    		return t._cobj[k](self._cobj, ...);
    	end
    	rawset(t, k, func);
        return func;
    end
	return t._cobj:Get(k);
end

_Var.__newindex = function( t, k, v )
	if v then
		t._cobj:Set(k, v);
	end
end

function Var( data )
	if type(data) ~= "userdata" or not data.IsVData then
		data = data and VData(data) or VData();
	end
	return setmetatable({_cobj = data}, _Var);
end

function downLoadFile(fileUrl, fileName, onFinish, onProgress, range)
	gNet:Get({url=fileUrl, filename=fileName, onFinish=onFinish, onProgress=onProgress, range=range});
end

------------------------------------------------------------------------
_PbClass = {}
_PbClass.__index = function( t, k )
	local v = t.this[k];
    if v then
    	rawset(t, k, v);
        return v;
    end
	v = _Var.__index(t, k)
	if type(v) == "table" and v._pb then
		v = VPb(v);
		rawset(t, k, v);
	end
	return v;
end

_PbClass.__newindex = function( t, k, v )
	if v then
		t._cobj:Set(k, v);
	end
end
function _PbClass__call(t, data)
	if type(data) ~= "userdata" or not data.IsVData then
		data = data and VData(data) or VData();
	end
	local v = setmetatable({_cobj = data, this = t or {}}, _PbClass);
	if v.Initialize then
		v:Initialize();
	end
	return v;
end
function _PbClass__index(t, k)
    local v;
    while t do
        v = rawget(t,k);
        if v then break; end
        t = t.super;
    end
    return v;
end
function VPb( v )
	return _PbClass__call(v._pb and _G["Pb"..v._pb], v._cobj);
end
function PbClass(name, super)
    local obj = _G["Pb"..name];
    if not obj then
        if super then
            obj = {super = super}
            setmetatable(obj, {__call = _PbClass__call,  __index = _PbClass__index});
        else
            obj = setmetatable({class = name}, {__call = _PbClass__call});
        end
        _G["Pb"..name] = obj;
    end
    return obj;
end

function getMapCount( map )
	if not map then
		return 0;
	end
	
	local count = 0;
	for k,v in pairs(map) do
		count = count + 1;
	end
	return count;
end

function getMapItem(map, index)
	if not map then
		return nil;
	end

	local i = 0;
	for k, v in pairs(map) do
		if i == index then
			return v;
		end
		i = i+1;
	end
end

function isEmail( str )
	return nil ~= string.find(str,"^.+@.+%..+$");
end
function isPhoneNumber( str )
	return nil ~= string.find(str,"^1[3-8]%d%d%d%d%d%d%d%d%d$");
end

--str:源字符串， ss起始字符串， ll长度
function stringSub( str , ss,  ll)
    local len  = #str
    local left = 0
    local t = ""
    local start = 1
    local wordLen = 0
	local ct = 0;
	local st = 1;
    while len ~= left do
        local tmp = string.byte(str, start)
		local i = 0
		if tmp < 0x80 then
			i = 1
		elseif tmp < 0xe0 then
			i = 2
		elseif tmp < 0xf0 then
			i = 3
		elseif tmp < 0xf8 then
			i = 4
		elseif tmp < 0xfc then
			i = 5
		else
			i = 6			
		end
		wordLen = wordLen + i
        local tmpString = string.sub(str, start, wordLen)
        start = start + i
        left = left + i
		if st >= ss then
			t = t .. tmpString
			ct = ct + 1
			if ct >= ll then
				break
			end
		end
		st = st + 1
    end
    return t
end

--str:源字符串，返回字符串长度, 无论中英文都返回1
function stringLen( str )
	local idx = 1;
	local result = 0;
    while idx<=#str do
        local tmp = string.byte(str, idx)
		local i = 0
		if tmp < 0x80 then
			i = 1
		elseif tmp < 0xe0 then
			i = 2
		elseif tmp < 0xf0 then
			i = 3
		elseif tmp < 0xf8 then
			i = 4
		elseif tmp < 0xfc then
			i = 5
		else
			i = 6			
		end
		idx = idx + i
        result = result + 1
    end
    return result
end


function formatPrice(price)
	if price then
		return "¥"..price;
	else
		return "";
	end
end

function formatChargeDesc()
	if gCanPay ~= nil and gCanPay == false then
		return "购买";
	else
		return "领取";
	end
end

function getClientVersion()
	if gClientVer then
		return gClientVer;
	else
		return gVersion;
	end
end

function logout()
    if gHeartBeatReqing then
        gHeartBeatReqing = nil;
    end
    gWindow:jumpToLoginView();
end

function loginCancel()
    FailResetUi();
end