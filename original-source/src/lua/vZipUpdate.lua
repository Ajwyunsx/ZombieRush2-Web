--vZipUpdate.lua

VZipUpdate = vclass("ZipUpdate");

function VZipUpdate:updateFinish()
	updateFinished();
end

function VZipUpdate:loadVersionFromFile()
	self.versionList = {};
	local var = Var();
	local fileName = "image/ver.log";
	var:FromFile(fileName, false, false, _VPath.Public);

	local iter = VDataIter();
	while var:Travel(iter) do
		local key = iter:Name();
		local value = iter:Data();
		self.versionList[key] = value;
	end
end

function VZipUpdate:saveVersionToFile()
	local var = Var(self.versionList);
	local fileName = "image/ver.log";
	var:SaveFile(fileName);
end

function VZipUpdate:checkImageUpdate()
	if gNewImageZipList and #gNewImageZipList~=0 then
		local fileName = table.remove(gNewImageZipList, 1);
		local currentVer = self.versionList[fileName];
		local newVer = gNewImageZipVersions[fileName];

		if not currentVer or not newVer or newVer == -1 then
			self:getNewImageFile(fileName);
		elseif currentVer < newVer then
			self:getNewImageFile(fileName);
		else
			if gRes:GetFileLen(fileName) > 0 then
				self:checkImageUpdate();
			else
				self:getNewImageFile(fileName);
			end
		end
	else
		self:updateFinish();
	end
end

function VZipUpdate:unZipNewImageFile(fileName)
	gRes:UnZipFile(fileName);
end

function VZipUpdate:getNewImageFile(fileName)
	local url = gResUrl..fileName;
	downLoadFile(url, fileName, "gZipUpdate:newImageZipDownloadFinish(gLua:Param())");
end

function VZipUpdate:newImageZipDownloadFinish(msg)
	local ret = msg:Number("ret");
	if ret == 0 then
		local fileName = msg:String("filename");
		local newVer = gNewImageZipVersions[fileName];
		if newVer then
			self.versionList[fileName] = newVer;
			self:saveVersionToFile();
		end
		self:unZipNewImageFile(fileName);
	else
		cclog("get Image zip File error");
	end
	self:checkImageUpdate();
end