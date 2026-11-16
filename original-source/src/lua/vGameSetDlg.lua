
_VSetting = VEnum{
	Music = 0,
	Audio = 1,
}

VGameSetDlg = VClass("GameSetDlg", VMsgBox)

function VGameSetDlg:onPush()
	local itemb = self("imgSoundBGameSet");
	local iteme = self("imgSoundEGameSet");
	if gAudio:getEffectOff() == 1 then
		iteme("imgSoundBGGGameSet").visible = 0;
	else
		iteme("imgSoundBGGGameSet").visible = 1;
	end

	if gAudio:getMusicOff() == 1 then
		itemb("imgSoundBGGGameSet").visible = 0;
	else
		itemb("imgSoundBGGGameSet").visible = 1;
	end
end

function VGameSetDlg:onPop()
	gData:saveConfig();
	-- local systemView = gView()("systemSetDlg");
	-- if systemView then
	-- 	systemView:refreshAudioConfig();
	-- end
end

function VGameSetDlg:onMusicE()
	local item = self("imgSoundEGameSet");
	if item("imgSoundBGGGameSet"):isVisible() then
		item("imgSoundBGGGameSet").visible = 0;
	else
		item("imgSoundBGGGameSet").visible = 1;
	end
	if gAudio:getEffectOff() == 1 then
		gAudio:setEffectOff(0);
	else
		gAudio:setEffectOff(1);
	end
end

function VGameSetDlg:onMusicB()
	local item = self("imgSoundBGameSet");
	if item("imgSoundBGGGameSet"):isVisible() then
		item("imgSoundBGGGameSet").visible = 0;
	else
		item("imgSoundBGGGameSet").visible = 1;
	end
	if gAudio:getMusicOff() == 1 then
		gAudio:setMusicOff(0);
		if gAudio:isMusicPlaying() then
            gAudio:resumeMusic();
        else
            if gView() == gMainView then
                gAudio:playMusic("enterGame.ogg",true);
            else
                gAudio:playMusic("beginGame.ogg",true);
            end
        end
	else
		gAudio:setMusicOff(1);
		gAudio:pauseMusic();
	end
end

function VGameSetDlg:onNotice()
	local item = self("imgNoticeGameSet");
	if item("imgSoundBGGGameSet"):isVisible() then
		item("imgSoundBGGGameSet").visible = 0;
	else
		item("imgSoundBGGGameSet").visible = 1;
	end
end