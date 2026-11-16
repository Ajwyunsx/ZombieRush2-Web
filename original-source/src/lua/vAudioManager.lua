VAudioManager = vclass("AudioManager");

function VAudioManager:initialize( )
	self.musicOff = 0;
	self.effectOff = 0;
    self.effects = {};
end

function VAudioManager:stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
end

function VAudioManager:getMusicVolume()
    return cc.SimpleAudioEngine:getInstance():getMusicVolume()
end

function VAudioManager:isMusicPlaying()
    return cc.SimpleAudioEngine:getInstance():isMusicPlaying()
end

function VAudioManager:getEffectsVolume()
    return cc.SimpleAudioEngine:getInstance():getEffectsVolume()
end

function VAudioManager:setMusicVolume(volume)
    cc.SimpleAudioEngine:getInstance():setMusicVolume(volume)
end

function VAudioManager:stopEffect(filename)
    local handle = self.effects[filename];
    cc.SimpleAudioEngine:getInstance():stopEffect(handle)
end

function VAudioManager:stopMusic(isReleaseData)
    local releaseDataValue = false
    if nil ~= isReleaseData then
        releaseDataValue = isReleaseData
    end
    cc.SimpleAudioEngine:getInstance():stopMusic(releaseDataValue)
end

function VAudioManager:playMusic(filename, isLoop)
	if self:getMusicOff() == 1 then
		return;
	end
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    filename = gSys:getPlatformMusicFileName(filename);
    cc.SimpleAudioEngine:getInstance():playMusic(filename, loopValue)
end

function VAudioManager:pauseAllEffects()
    cc.SimpleAudioEngine:getInstance():pauseAllEffects()
end

function VAudioManager:preloadMusic(filename)
    cc.SimpleAudioEngine:getInstance():preloadMusic(filename)
end

function VAudioManager:resumeMusic()
    cc.SimpleAudioEngine:getInstance():resumeMusic()
end

function VAudioManager:playEffect(filename, isLoop, isCommon)
	if self:getEffectOff() == 1  then
		return;
	end
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    if not isCommon then
        filename = gSys:getPlatformMusicFileName(filename);
    end
    self.effects[filename] = cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue);
end

function VAudioManager:rewindMusic()
    cc.SimpleAudioEngine:getInstance():rewindMusic()
end

function VAudioManager:willPlayMusic()
    return cc.SimpleAudioEngine:getInstance():willPlayMusic()
end

function VAudioManager:unloadEffect(filename)
    cc.SimpleAudioEngine:getInstance():unloadEffect(filename)
end

function VAudioManager:preloadEffect(filename)
    cc.SimpleAudioEngine:getInstance():preloadEffect(filename)
end

function VAudioManager:setEffectsVolume(volume)
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(volume)
end

function VAudioManager:pauseEffect(handle)
    cc.SimpleAudioEngine:getInstance():pauseEffect(handle)
end

function VAudioManager:resumeAllEffects(handle)
    cc.SimpleAudioEngine:getInstance():resumeAllEffects()
end

function VAudioManager:pauseMusic()
    cc.SimpleAudioEngine:getInstance():pauseMusic()
end

function VAudioManager:resumeEffect(handle)
    cc.SimpleAudioEngine:getInstance():resumeEffect(handle)
end

function VAudioManager:getInstance()
    return cc.SimpleAudioEngine:getInstance()
end

function VAudioManager:destroyInstance()
    return cc.SimpleAudioEngine:destroyInstance()
end


function VAudioManager:getMusicOff( )
    --if gPackage == 1000 then
    --    local off = gSys:isMusicEnabled()
    --    return off;
    --else
        return self.musicOff;
    --end
end

function VAudioManager:setMusicOff( off )
    self.musicOff = off;
end

function VAudioManager:getEffectOff( )
    --if gPackage == 1000 then
    --    local off = gSys:isMusicEnabled()
    --    return off;
    --else
        return self.effectOff;
    --end
end

function VAudioManager:setEffectOff( off )
    self.effectOff = off;
end

