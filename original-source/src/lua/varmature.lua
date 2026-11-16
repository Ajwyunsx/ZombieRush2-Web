--varmature.lua

VArmature = VClass("Armature", VNode)

local ArmatureImg = {};
ArmatureImg["PeaShooterBody"] = "PeaShooter";
ArmatureImg["PeaShooterChild"] = "PeaShooter";
ArmatureImg["PoisonPeaBody"] = "PoisonPea";
ArmatureImg["PoisonPeaChild"] = "PoisonPea";
ArmatureImg["SnipeShooterBody"] = "SnipeShooter";
ArmatureImg["SnipeShooterChild"] = "SnipeShooter";
ArmatureImg["SnowPeaBody"] = "SnowPea";
ArmatureImg["SnowPeaChild"] = "SnowPea";

function VArmature:onCreate( attr )
	VArmature:addArmatureFile(attr.jsonName);
	return ccs.Armature:create(attr.jsonName);
end

function VArmature:addArmatureFileEx( name )
	if not gArmatureList[name] then
		gArmatureList[name] = name;
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(name..".png", name..".plist", name..".ExportJson");
	end
end
function VArmature:addArmatureFile( name )
	if ArmatureImg[name] ~= nil then
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(ArmatureImg[name]..".png", ArmatureImg[name]..".plist", name..".ExportJson");
	else
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(name..".png", name..".plist", name..".ExportJson");
	end
end

function VArmature:createArmature( jsonName, nodeName, layout, x, y )
	nodeName = nodeName or "";
	layout = layout or "UpLeft";
	x = x or 0;
	y = y or 0;
	
	return VArmature{ name = nodeName, jsonName = jsonName, layout = layout, offset = {x,y}};
end

function VArmature:on_position(position)
	self:SaveOffset();
end

function VArmature:on_animation( animationName )
	if animationName then
		self:getAnimation():play(animationName);
	end
end

function VArmature:play( animationName, duration, loop )
	duration = duration or -1;
	loop = loop or -1;
	if animationName then
		local movement = self:getAnimation():getAnimationData():getMovement(animationName);
		if movement then
			self:getAnimation():play(animationName, duration, loop);
		end
	end
end

function VArmature:pause( )
	self:getAnimation():pause();
end

function VArmature:resume( )
	self:getAnimation():resume();
end

function VArmature:stop( )
	self:getAnimation():stop();
end

function VArmature:setSpeedScale( speedScale )
	self:getAnimation():setSpeedScale(speedScale);
end

function VArmature:setEventCallFunc( funcName )
	self:getAnimation():setFrameEventCallFunc(funcName);
end

function VArmature:changeDisplay( boneName, imageName, imageIndex)
	if imageName then
		self:getBone(boneName):changeDisplayWithName(imageName, true);
	elseif imageIndex then
		self:getBone(boneName):changeDisplayWithIndex(imageIndex, true);
	end
end

function VArmature:addParticleBone( boneName, particlePlistName, x, y )
	if boneName == nil or particlePlistName == nil then
		return
	end

	x = x or 0;
	y = y or 0;

	local particleNode = cc.ParticleSystemQuad:create(particlePlistName);
	local bone = ccs.Bone:create(particlePlistName);
	bone:addDisplay(particleNode, 0);
	bone:changeDisplayWithIndex(0,true);
	bone:setIgnoreMovementBoneData(true);
	self:addBone(bone, boneName);
	bone:setPosition(x,y);
end

function VArmature:setPhysicsBitMask( categoryBitmask, contactTestBitmask, collisionBitmask )
	self:getPhysicsBody():setCategoryBitmask(categoryBitmask);
	self:getPhysicsBody():setContactTestBitmask(contactTestBitmask);
	self:getPhysicsBody():setCollisionBitmask(collisionBitmask);
end

function VArmature:addPhysicsListener( funcName, handlerType, view )
	local contactListener = cc.EventListenerPhysicsContact:create();
	contactListener:registerScriptHandler(funcName, handlerType);
	local eventDispatcher = view:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, view);
end

function VArmature:getBonePos( name )
	local bone = self:getBone(name);
	if bone then
		local renderNode = bone:getDisplayRenderNode();
		if renderNode then
			return renderNode:convertToWorldSpace(cc.p(0,0));
		else
			return cc.p(self:getPositionX(), self:getPositionY()+self:getContentSize().height*self:getAnchorPoint().y);
		end
	else
		return cc.p(self:getPositionX(), self:getPositionY()+self:getContentSize().height*self:getAnchorPoint().y);
	end
	-- assert(renderNode ~= nil, "VArmature:getBonePos Error self.jsonName = "..self.jsonName.."  boneName = "..name);
end

function VArmature:getBoneSize( name )
	local bone = self:getBone(name);
	local notBone = false;
	if bone then
		local renderNode = bone:getDisplayRenderNode();
		if renderNode then
			return renderNode:getContentSize();
		else
			notBone = true;
		end
	else
		notBone = true;
	end

	if notBone then
		local size = self:getContentSize();
		size.width = size.width / 2;
		size.height = size.height / 2;
		return size;
	end
end

function VArmature:getBoneAnchorPoint( name )
	local renderNode = self:getBone(name):getDisplayRenderNode();
	assert(renderNode ~= nil, "VArmature:getBoneAnchorPoint Error self.jsonName = "..self.jsonName.."  boneName = "..name);
	return renderNode:getAnchorPoint();
end


function VArmature:armatureCallBackFunc( )
	VCallBack(self.callBackDelegate, self.callBackFunc);
end

function VArmature:setEnable(enable)
	if enable then
		self.gray = 0;
		self.touch = 1;
	else
		self.gray = 1;
		self.touch = 0;
	end
end

function VArmature:haveAnimationWithName( name )
	if self:getAnimation():getAnimationData():getMovement(name) then
		return true;
	end
	return false;
end