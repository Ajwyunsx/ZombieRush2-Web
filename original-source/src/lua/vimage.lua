--vimage.lua

VImage = VClass("Image", VNode)

gImageTempHandls = {};

function VImage:onCreate(attr)
    return cc.Sprite:create();
end

function VImage:on_image(image)
    if not image then return end;
    if gRes:checkImageExist(image) then
        self:changeImage(image);
        self:DoSizeChange();
    else
        if self.needLoad or self.headImage then
            local imagePath = tostring(image);
            if versionCompare(gRes:Version(), "1.0.3") ~= -1 then
                imagePath = "image/"..imagePath;
            end
            gImageTempHandls[imagePath] = self;
            self._image = image;

            if gResUrl then
                local url = gResUrl..image;
                if self.headImage then
                    url = gResUrl.."/img/userIcon/"..image;
                end
                
                downLoadFile(url, imagePath, gFormat("imageDownLoadFinish(gLua:Param())"));
                gLog("image %s is not exist", image);
            end
        end
    end
end

function VImage:on_defaultImage(image)
    self:changeImage(image);
    self:DoSizeChange();
end

function imageDownLoadFinish(msg)
    local ret = msg:Number("ret");
    local filename = msg:String("filename");
    if gImageTempHandls[filename] then
        gImageTempHandls[filename]:imageDownLoadFinish(msg);
    end
end

function VImage:imageDownLoadFinish(msg)
    local ret = msg:Number("ret");
    local filename = msg:String("filename");
    local realFileName = filename;
    if versionCompare(gRes:Version(), "1.0.3") ~= -1 then
        realFileName = string.sub(filename, 7);    
    end
    if ret == 0 then
        if self._image == realFileName then
            self:changeImage(realFileName);
            self:DoSizeChange();
        end
        gLog("image %s download finish", realFileName);
    else
        if self.defaultImage then
            self:changeImage(self.defaultImage);
            self:DoSizeChange();
        end
        gLog("image %s download failed", realFileName);
    end
    gImageTempHandls[filename] = nil;
end

function VImage:changeImage(image)
    self:setTexture(image);
    if self._attr.size then
        self.size = self._attr.size;
    end
end

function VImage:on_flipX(flipX)
	if flipX > 0 then
		self:setFlippedX(true);
	else
		self:setFlippedX(false);
	end
end

function VImage:on_flipY(flipY)
	if flipY > 0 then
		self:setFlippedY(true);
	else
		self:setFlippedY(false);
	end
end

function VImage:setEnable(enable)
    if enable then
        self.gray = 0;
        self.touch = 1;
    else
        self.gray = 1;
        self.touch = 0;
    end
end

function VImage:onClickAudio()
    if self.audioEffect then
        gAudio:playEffect(self.audioEffect);
    else
        gAudio:playEffect("sys_common.ogg");
    end
end

function VImage:onTouchBase(touch)
    if self.tableView then
        if not self.tableView:IsInRect(touch) then
            return false;
        end
    end
    VImage.super.onTouchBase(self, touch);
end

function VImage:imageCallBackFunc( )
    VCallBack(self.callBackDelegate, self.callBackFunc);
end