--vBattleUnitFactory.lua

---------------------------------------  BattleUnitFactory  ---------------------------------------

BattleUnitFactory = vclass("BattleUnitFactory");

function BattleUnitFactory:initialize( )

end

-- @Param int , BattleUnit*
-- @Return void
function BattleUnitFactory:GetNewCreature( unitType, prop )
	if unitType >= EUnitType.TYPE_CREATURE_MAX or not prop then
		return nil;
	end

	if unitType == EUnitType.TYPE_CREATURE then
		return BattleCreature:new(prop);
	elseif unitType == EUnitType.TYPE_CREATURE_OBJECT then
		return BattleObject:new(prop);
	else
		return nil;
	end
end

-- @Param int , BulletProp*
-- @Return void
function BattleUnitFactory:GetNewBullet( unitType, prop )
	if unitType >= EUnitType.TYPE_BULLET_MAX or unitType < EUnitType.TYPE_BULLET or not prop then
		return nil;
	end

	if unitType == EUnitType.TYPE_BULLET then
		return BattleBullet:new(prop);
	elseif unitType == EUnitType.TYPE_BULLET_TRACE then
		return BattleBulletTrace:new(prop);
	elseif unitType == EUnitType.TYPE_BULLET_CYCLE then
		return BattleBulletCycle:new(prop);
	else
		return nil;
	end
end



