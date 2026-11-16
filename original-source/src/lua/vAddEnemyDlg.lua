VAddEnemyDlg = VClass("AddEnemyDlg", VMsgBox)

function VAddEnemyDlg:onPush(parameters)
    self("artUp"):play("idle")
end

function VAddEnemyDlg:SetDlgInfo(idx)
    self.idx = idx
end

function VAddEnemyDlg:AddEnemy(parameters)
    local text = self("edtIDAddEnemyD"):getText()
    if text ~= "" then
        if gData.userInfo.enemyInfos:EnemyCount() < gData.userInfo.enemyInfos.enemyLimit then

        else
            gWindow:showTip("仇敌已达到上限,无法添加")
            return
        end

        local aParam = {}
        aParam.userid = tonumber(text)
        aParam.idx = self.idx
        gView()("enemyOption"):ReqEnemyAdd(aParam)
        self:doPop()
    else
        gWindow:showTip("请输入ID", 1)
	end
end