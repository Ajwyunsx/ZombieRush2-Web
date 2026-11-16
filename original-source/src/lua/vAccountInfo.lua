-- vAccountInfo.lua

VAccountInfo = vclass("AccountInfo")

function VAccountInfo:initialize()
    if gRes:Platform() == "android" then
        if gRes:GetFileLen("Data.txt") > 0 then
            self:loadAccountFromPub();
            if not self.id or self.id == 0 then
                self:loadAccountFromRes();
            end
        else
            self:loadAccountFromRes();
            if self.id ~= 0 and self.psw ~= "" then
                self:saveAccountToPub()
            end
        end
    else
        self:loadAccountFromRes();
    end
end

function VAccountInfo:loadAccountFromRes()
    self.id = gRes:Int("account_id");
    self.name = gRes:String("account_name");
    self.psw = gRes:String("account_psw");
    self.lastZoneId = gRes:Int("lastZoneId");
    self.lastRoleId = gRes:Int("lastRoleId");
    self.isAddShortCut = gRes:Int("isAddShortCut");
    if type(self.lastZoneId) == "boolean" then
        self.lastZoneId = nil;
    end
end

function VAccountInfo:loadAccountFromPub()
    if gRes:Platform() == "android" then
        local account = Var();
        account:FromFile("Data.txt", false, true, _VPath.Public);
        self.id = account.account_id;
        self.psw = account.account_psw;
        self.name = account.account_name;
        self.lastZoneId = account.lastZoneId;
        self.lastRoleId = account.lastRoleId;
        self.isAddShortCut = account.isAddShortCut;
        if type(self.lastZoneId) == "boolean" then
            self.lastZoneId = nil;
        end
    end
end

function VAccountInfo:saveAccountToPub()
    if gRes:Platform() == "android" then
        if self.id ~= 0 and self.psw ~= "" then
            local account = Var();
            account.account_id = self.id;

            local stringVar = Var();
            local pswString = tostring(self.psw);
            stringVar:SetString(pswString, string.len(pswString))
            account.account_psw = stringVar;

            stringVar = Var();
            local nameString = tostring(self.name);
            stringVar:SetString(nameString, string.len(nameString))
            account.account_name = stringVar;
            
            account.lastZoneId = self.lastZoneId;
            account.lastRoleId = self.lastRoleId;
            account.isAddShortCut = self.isAddShortCut;
            account:SaveFile("Data.txt", false, true);
        end
    end
end

function VAccountInfo:synWithPbData(pbData)
	self.id = pbData.accountid;
	-- self.psw = pbData.part1.psw;
	-- self.sim = pbData.part1.sim;
	if pbData.part3 then
        self.name = pbData.part3.name
		self.zoneRoleInfos = pbData.part3.role_infos;
		self.mobile = pbData.part3.mobile;
		self.email = pbData.part3.email;
        self.id_card_number = pbData.part3.id_card_number
        self.own_psw = pbData.part3.own_psw
        self:saveAccountName();
	end
end

function VAccountInfo:UpDataName(name)
    self:setAccountName(name);
end

function VAccountInfo:UpDataEmail(email)
    self.email = email
end

function VAccountInfo:UpDataPhone(mobile)
    self.mobile = mobile
end

function VAccountInfo:UpDataIDCard(id_card_number)
    self.id_card_number = id_card_number
end

function VAccountInfo:SetOwnPsw(bl)
    self.own_psw = bl
end

function VAccountInfo:GetSafeLevel()
    local txlevel = "" 
    local num = 0
    if self.mobile ~= nil then
        num = num + 2
    end
    if self.email ~= nil then
        num = num + 2
    end
    if self.id_card_number ~= nil then
        num = num + 2
    end
    if self.own_psw == true then
        num = num + 1
    end

    if num == 0 then
        txlevel = "危险"
    elseif num <= 3 then
        txlevel = "低"
    elseif num < 7 then
        txlevel = "中"
    else
        txlevel = "高"
    end   

    return txlevel
end

function VAccountInfo:IsFirstBindEmail()
    if self.email == nil or self.email == "" then
        return true
    else
        return false
    end
end

function VAccountInfo:IsFirstAlterAccount()
    return not self.own_psw
end

function VAccountInfo:IsBindPhone(parameters)
    if self.mobile ~= nil or self.email == "" then
	   return true
	else
	   return false
	end
end

function VAccountInfo:zoneRoleCount()
	if not self.zoneRoleInfos then return 0 end;
	return self.zoneRoleInfos:Count();
end

function VAccountInfo:useridWithZoneid(zoneid)
	local userids = {};
	if not self.zoneRoleInfos then return userids end;
	local iter = VDataIter();
    while self.zoneRoleInfos:Travel(iter) do
    	local roleInfo = iter:Data();
    	if roleInfo.zoneid == zoneid then
    		table.insert(userids, roleInfo.userid);
    	end
    end
    return userids;
end

function VAccountInfo:setLastZoneId(lastZoneId)
	if not lastZoneId then return end;
	self.lastZoneId = lastZoneId;
	gRes:SetInt("lastZoneId", lastZoneId);
	gRes:Flush();
    self:saveAccountToPub();
end

function VAccountInfo:setAccountIDandPsw(accountId, psw)
	if not accountId or not psw then return end;
	self.id = accountId;
	self.psw = psw;
	gRes:SetInt("account_id", accountId);
	gRes:SetString("account_psw", psw);
	gRes:Flush();
    self:saveAccountToPub();
end

function VAccountInfo:setAccountName(name)
    if not name then return end;
    self.name = name;
    self:saveAccountName();
end

function VAccountInfo:saveAccountName()
    if not self.name then return end;
    gRes:SetString("account_name", self.name);
    gRes:Flush();
    self:saveAccountToPub();
end

function VAccountInfo:setDidAddShortCut(isAddShortCut)
    self.isAddShortCut = isAddShortCut;
    gRes:SetInt("isAddShortCut", self.isAddShortCut);
    gRes:Flush();
    self:saveAccountToPub(); 
end

function VAccountInfo:setLastRoleId(roleId)
    self.lastRoleId = roleId;
    gRes:SetInt("lastRoleId", self.lastRoleId);
    gRes:Flush();
    self:saveAccountToPub(); 
end
