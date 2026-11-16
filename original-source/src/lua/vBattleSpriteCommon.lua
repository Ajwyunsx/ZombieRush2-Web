--vBattleSpriteCommon.lua

require "vBattleBulletSprite"
require "vBattlePeaBulletSprite"
require "vBattleCornBulletSprite"
require "vBattleMelonBulletSprite"
require "vBattleLightningBulletSprite"
require "vBattleBoomerangBulletSprite"
require "vBattleThiefBulletSprite"

require "vBattlePlantSprite"
require "vBattleSunFlowerSprite"
require "vBattleMarigoldSprite"
require "vBattlePeaShooterSprite"
require "vBattleSnowPeaSprite"
require "vBattleWallNutSprite"
require "vBattleSpikeweedSprite"
require "vBattleKernelPultSprite"
require "vBattleBonkChoySprite"
require "vBattleMelonPultSprite"
require "vBattleBloomerangSprite"

require "vBattleMonsterSprite"
require "vBattleBasicZombieSprite"
require "vBattleMagicZombieSprite"
require "vBattleBoomZombieSprite"
require "vBattleFootballZombieSprite"
require "vBattleDancingZombieSprite"
require "vBattleFlagZombieSprite"
require "vBattleGargantuarSprite"
require "vBattleBackupDancerSprite"
require "vBattleIMPSprite"
require "vBattleThiefZombieSprite"

require "vBattleSpoilBoxSprite"
require "vBattleSunShineSprite"
require "vBattleObjectSprite"
require "vBattleBuffSprite"
require "vBattleDropItemSprite"


require "vBattleTestMonsterSprite"
require "vBattleTestPlantSprite"

-- 生物动作类型
ECreatureAnimationType = {
	ANIMATION_NULL = 0,					-- 无动作
	ANIMATION_IDLE = 1,						-- 休息
	ANIMATION_MOVE = 2,					-- 移动
	ANIMATION_ATTACK = 3,					-- 攻击
	ANIMATION_SKILL = 4,					-- 放技能
	ANIMATION_DIE = 5,						-- 死亡
}

-- Buff动画
EBuffAnimationType = {
	BUFF_SLOW_DOWN = 1,					-- 减速
	BUFF_BUTTER_DOWN = 2,					-- 黄油定身
	BUFF_EVIL = 3,								-- 恶魔buff
	BUFF_REBIRTH = 4,							-- 重生
	BUFF_HELLBOY = 5,						-- 地狱男爵
	BUFF_TAISUI_UP = 6,						-- 太岁顶起
	BUFF_BEAT_BACK = 7,						-- 击退
	BUFF_MODIFY_HP_MAX = 8,				-- 修改血量上限
	BUFF_DIZZINESS = 9,						-- 眩晕定身
	BUFF_MUSHROOM = 10,					-- 变身蘑菇
	BUFF_RUSH = 11,							-- 冲锋
	BUFF_USEFUL = 12,						-- 通用增益Buff
	BUFF_USELESS = 13,						-- 通用减益Debuff
	BUFF_BLACK_HOLE = 14,					-- 黑洞吸引
	BUFF_DANCE = 15,						-- 跳舞
	BUFF_OTHER_SHORE = 16,				-- 彼岸菊Debuff
	BUFF_BLOODY = 17,						-- 血腥海棠Debuff
	BUFF_LADYENFORCERS_HOLD = 18,		-- 捕蝇草夹住目标
	BUFF_SHAMAN = 19,						-- 萨满菊花Debuff	
	BUFF_POISON = 20,						-- 中毒变紫色	
	BUFF_STAY_DAZE = 21,					-- 不做事发呆 
}

-- 子弹动画
EBulletAnimationType = {
	NORMAL_TYPE = 0,						-- 普通
	PARA_CURVE_TYPE = 1,					-- 抛物线
	LIGHTNING_TYPE = 2,						-- 闪电通道
	BOOMERANG_TYPE = 3,					-- 变身蘑菇
}

-- 界面层级
EAnimationSpriteLevel = {
	PLANT_LEVEL = 6,
	MONSTER_LEVEL = 7,
	DROP_LEVEL = 8,
	BULLET_LEVEL = 9,
	SUNSHINE_LEVEL = 10,

	HIGH_LEVEL = 20,
}
