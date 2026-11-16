
VAlterPhotoDlg = VClass("AlterPhotoDlg", VMsgBox)

function VAlterPhotoDlg:Init(attr)
    self.super.Init(self, attr)
end

function VAlterPhotoDlg:onPush()
	self("artUp"):play("idle")
    self("imgHeadAlterPhoto").image = gData:headImage(self.roleInfo.id, self.roleInfo.image);
    self("imgHeadAlterPhoto"):SetHeadImageShader("zhezhao1.png")
end

function VAlterPhotoDlg:setRoleInfo(info)
    self.roleInfo = info
end

function VAlterPhotoDlg:onCloseClick()
    self:onClick()
end

function VAlterPhotoDlg:onSaveClick()
	if not self.didchangeImage then
		gWindow:showTip("请选择头像...");
		return;
	end
	local bmp = Var();
	bmp:FromFile("tmp_head.jpg", true, false, _VPath.Public);
	gRes:ReleaseFile("tmp_head.jpg");
	local currentTime = gData:currentTime();
	gTempHeadImage = currentTime;
	local userid = gData.userInfo.userid;
	-- local name = currentTime.."_"..userid..".jpg";
	-- local ret = bmp:SaveFile(name, false, false);
	-- if ret then
		local postData = Var();
		postData:AppendNumber(currentTime, 4);
		postData:AppendNumber(userid, 4);
		postData:AppendNumber(gZoneid, 4);
		postData:AppendNumber(bmp:Count(), 4);
		postData:AppendBytesData(bmp);

		gReq:snsUpload("/userAlbum/upload", postData, self, "uploadImageCallBack");
		gWindow:showWaitTip("正在上传头像...");
	-- end
	self.didchangeImage = false;
	gRes:RemoveFile("tmp_head.jpg");
end

function VAlterPhotoDlg:onCameraClick()
    gSys:openCamera(self, "imagePickCallBack");
end

function VAlterPhotoDlg:onPictrueClick()
    gSys:openPhotos(self, "imagePickCallBack");
end

function VAlterPhotoDlg:imagePickCallBack(path)
	self:StartTimer("changeImageDelay", 0, 0, 0.5);
end

function VAlterPhotoDlg:changeImageDelay()
	gDtr:getTextureCache():reloadTexture("tmp_head.jpg");
	self("imgHeadAlterPhoto").image = "tmp_head.jpg";
	self.didchangeImage = true;
end

function VAlterPhotoDlg:uploadImageCallBack(msg)
	local receive = msg:String("content");
	if receive then
		gLog("receive = %s", receive);
		local receiveData = Var();
		receiveData:FromString(receive);
		if receiveData.rs == 0 then
			self:reqChangeImage(gTempHeadImage);
			gLog("upload image finish");
		else
			local errordiscr = receiveData.error;
			gWindow:showTip(errordiscr);
			gWindow:closeWaitTip();
		end
	else
		gWindow:closeWaitTip();
	end
end

function VAlterPhotoDlg:reqChangeImage(imageId)
	local aParams = {};
	aParams.image = imageId;
	gReq:MsgReqPlayerUpdate(self, "changeImageCallBack", aParams);
end

function VAlterPhotoDlg:changeImageCallBack(result, aMsgRspPlayerUpdate, req)
	gWindow:closeWaitTip();
	if result == 0 then
		local name = gTempHeadImage.."_"..gData.userInfo.userid..".jpg";
		gData.userInfo.roleInfo:UpDataImage(gTempHeadImage)
		gWindow:showTip("更改头像成功");
		local myInfoDlg = gView()("myInfoDlg");
		if myInfoDlg then
			myInfoDlg:headImageDidChanged();
		end
		if gMainView then
			gMainView:refreshUserHeadImage();
		end
		self:onCloseClick();
	end
end

