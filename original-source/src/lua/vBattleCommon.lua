--vBattleCommon.lua

require "vBattle"
require "vBattleAI"
require "vBattleBuff"
require "vBattleBullet"
require "vBattleCondition"
require "vBattleCreature"
require "vBattleEffect"
require "vBattleGround"
require "vBattleResource"
require "vBattleUnitFactory"

MODIFY_FLOAT = 0.00001

ECreatureAttr = {
	CREATURE_ATTR_ID = 0,								-- ID  
	CREATURE_ATTR_LIFE = 1,								-- 生命  
	CREATURE_ATTR_ATTACK = 2,							-- 攻击  
	CREATURE_ATTR_DEFEND = 3,							-- 防御  
	CREATURE_ATTR_ATTACK_SPEED = 4,					-- 攻击速度  
	CREATURE_ATTR_ATTACK_RANGE = 5,					-- 攻击距离  
	CREATURE_ATTR_MOVE_SPEED = 6,					-- 移动速度  
	CREATURE_ATTR_LEN = 7,								-- 长度  
	CREATURE_ATTR_WID = 8,								-- 宽度  
	CREATURE_ATTR_ATTACK_TYPE = 9,					-- 攻击类型 （1 地 2 空 3 两者）  
	CREATURE_ATTR_MOVE_TYPE = 10,					-- 移动类型 （1 地 2 空 3 两者）  
	CREATURE_ATTR_BULLET = 11,							-- 子弹  
	CREATURE_ATTR_SKILL = 12,							-- 技能  
	CREATURE_ATTR_SKILL_FIRST = 13,					-- 技能首次时间  
	CREATURE_ATTR_SKILL_CD = 14,						-- 技能CD  
	CREATURE_ATTR_AI_MOVE = 15,						-- 移动AI  
	CREATURE_ATTR_AI_ATTACK = 16,						-- 攻击AI  
	CREATURE_ATTR_ATTACK_PRE = 17,					-- 攻击前摇  
	CREATURE_ATTR_ATTACK_POST = 18,					-- 攻击后摇  
	CREATURE_ATTR_SKILL_TIMES = 19,					-- 技能释放次数  
	CREATURE_ATTR_RACE = 20,							-- 生物种族  
	CREATURE_ATTR_HIGHT = 21,							-- 高度
	CREATURE_ATTR_COST = 22,							-- 消耗  
	CREATURE_ATTR_AI_SKILL = 23,						-- 技能AI  
	CREATURE_ATTR_ARMOR1 = 24,						-- 护甲类型（盾牌）  
	CREATURE_ATTR_ARMOR2 = 25,						-- 护甲类型（头盔）  
	CREATURE_ATTR_ARMOR3 = 26,						-- 护甲类型（鞋子）  
	CREATURE_ATTR_ARMOR4 = 27,						-- 护甲类型（石肤）  
	CREATURE_ATTR_ARMOR5 = 28,						-- 护甲类型（防爆）  
	CREATURE_ATTR_DAMAGE_TYPE = 29,					-- 攻击类型（平射、抛射、陷阱、肉搏）  
	CREATURE_ATTR_DAMAGE_RACE = 30,				-- 伤害类型（物理、元素、神圣、化学）  
	CREATURE_ATTR_SUNSHINE_SPEED = 31,				-- 资源植物 阳光速率(小偷 攻击次数）  
	CREATURE_ATTR_SUNSHINE_VALUE = 32,				-- 阳光数值  
	CREATURE_ATTR_COMBAT = 33,						-- 战斗力  
	CREATURE_ATTR_BLOCK = 34,							-- 是否被补种的植物阻挡（0不阻挡，1阻挡）

	CREATURE_ATTR_MAX = 35,
}

ECreatureStatus = {
	CREATURE_STATUS_LAST_ATTACK_TIME = 0,			-- 上次攻击时间  
	CREATURE_STATUS_LAST_MOVE_TIME = 1,			-- 上次移动时间  
	CREATURE_STATUS_INV = 2,							-- 物理免疫  
	CREATURE_STATUS_HOLD = 3,						-- 定身  
	CREATURE_STATUS_HI = 4,							-- 定身免疫  
	CREATURE_STATUS_PRE = 5,							-- 攻击前摇  
	CREATURE_STATUS_POST = 6,							-- 攻击后摇
	CREATURE_STATUS_BLOCK = 7,                  			-- 被阻碍  
	CREATURE_STATUS_ACTIVE_TIME = 8,					-- 激活时间  
	CREATURE_STATUS_JUMP = 9,							-- 是否跳过  
	CREATURE_STATUS_NO_ATTACK = 10,				-- 不攻击
	CREATURE_STATUS_STEALTH = 11,					-- 隐身  
	CREATURE_STATUS_BITE = 12,							-- 被咬住  
	CREATURE_STATUS_SLEEP = 13,						-- 睡觉  
	CREATURE_STATUS_MAGIC_INV = 14,					-- 魔法免疫  
	CREATURE_STATUS_NO_SKILL = 15,					-- 禁止释放技能  
	CREATURE_STATUS_MAX = 16,
}

ECreatureAction = {
	ACTION_NULL = 0,
	ACTION_ATTACK = 1,
	ACTION_MOVE = 2,
	ACTION_SKILL = 3,
}

EBattleEffect = {
	EFFECT_MODIFY_ATTR = 1,							-- 修改属性  
	EFFECT_MODIFY_STATUS = 2,							-- 修改状态  
	EFFECT_ADD_BUFF = 3,								-- 添加buff  
	EFFECT_DAMAGE = 4,									-- 范围伤害  
	EFFECT_DANCE = 5,									-- 跳舞  
	EFFECT_MODIFY_DAMAGE = 6,						-- 修改伤害  
	EFFECT_OBJECT = 7,									-- 制造物体  
	EFFECT_SONW_MAN = 8,								-- 丢小僵尸
	EFFECT_SECKILL = 9,									-- 秒杀  
	EFFECT_SHEEP = 10,									-- 变羊  
	EFFECT_HP_1 = 11,										-- 加、减血数值（可叠加）  
	EFFECT_HP_2 = 12,										-- 加、减血百分比  
	EFFECT_BLACKHOLE = 13,								-- 黑洞  
	EFFECT_DAMAGE_2 = 14,								-- 造成伤害（设置伤害类型）  
	EFFECT_REVIVE = 15,									-- 复活  
	EFFECT_BULLET = 16,									-- 创建子弹  
	EFFECT_RANGE_DAMAGE = 17,						-- 均摊伤害  
	EFFECT_MOVE = 18,									-- 移动  
	EFFECT_DEL_BUFF = 19,								-- 删除buff
	EFFECT_MODIFY_HP_MAX = 20,   						-- 修改血量上限
	EFFECT_DAMAGE_3 = 21,        							-- 造成伤害（指定种族不同伤害）    
	EFFECT_SUICIDE = 22,        							-- 自杀

	EFFECT_MAX = 23,
}

EBattleLogEvent = {
-----------  逻辑事件  -----------
	LOG_EVENT_MOVE = 0,								-- 移动
	LOG_EVENT_BLOCK = 1,								-- 被阻挡
	LOG_EVENT_MOVE_END = 2,							-- 移动到尽头
	LOG_EVENT_ATTACK = 3,								-- 攻击
	LOG_EVENT_ATTACK_PRE = 4,							-- 攻击前摇
	LOG_EVENT_DAMAGE = 5,							-- 受到伤害
	LOG_EVENT_DEATH = 6,								-- 死亡
	LOG_EVENT_SKILL = 7,								-- 释放技能
	LOG_EVENT_SKILL_SHAKE = 8,						-- 技能前摇
	LOG_EVENT_ADD_UNIT = 9,							-- 添加单位
	LOG_EVENT_ADD_BUFF = 10,							-- 添加Buff
	LOG_EVENT_DEL_BUFF = 11,							-- 移除Buff
	LOG_EVENT_BATTLE_END = 12,						-- 战斗结束
	LOG_EVENT_WAKEUP = 13,							-- 苏醒  
	LOG_EVENT_SUNSHINE = 14,							-- 捡阳光  
	LOG_EVENT_NEW_SUNSHINE = 15, 					-- 产生阳光  
	LOG_EVENT_ADD_HP = 16,							-- 加血  
	LOG_EVENT_BATTLE_DROP = 17,						-- 掉落  
	LOG_EVENT_SHOVEL = 18,							-- 铲植物  
	LOG_EVENT_SUICIDE = 19,							-- 自杀
	LOG_EVENT_SUNSHINE_CONSUME = 20,				-- 阳光消耗
	LOG_EVENT_MAX = 21,

-----------  动画事件  客户端专用  -----------
	LOG_EVENT_INJURY = 101,							-- 受伤残肢动画事件
	LOG_EVENT_JUMP = 102,								-- 跳高动画事件
	LOG_EVENT_ROTATION = 103,						-- 回旋镖动画事件
	LOG_EVENT_GET_RESOURCE = 104,					-- 植物掉钱动画事件
	LOG_EVENT_SLEEP = 105,								-- 植物睡觉事件
	LOG_EVENT_ZOMBIE_ENTER = 106,					-- 僵尸进场事件
	LOG_EVENT_RESET_PLANT = 107,						-- 死亡位置重新放置植物事件
	LOG_EVENT_ZOMBIE_ACTIVE = 108,					-- 僵尸被激活
	LOG_EVENT_WAVE_ZOMBIE_ATTACK = 109,			-- 一大波僵尸接近中
	
}

-- 条件类型  
EBattleCondition = {
	BATTLE_CONDITION_STATUS = 1,						-- 状态检查  
	BATTLE_CONDITION_ATTR = 2,						-- 属性检查  
	BATTLE_CONDITION_PROBABILITY = 3,				-- 概率检查  
	BATTLE_CONDITION_TARGET = 4,						-- 目标检查  
	
	BATTLE_CONDITION_MAX = 5,
}

-- buff触发阶段  
EBattleBuffEvent = {
	BATTLE_BUFF_EVENT_ADD = 0,						-- 添加buff时  
	BATTLE_BUFF_EVENT_DEL = 1,							-- 删除buff时  
	BATTLE_BUFF_EVENT_UPDATE = 2,					-- 更新buff时  
	BATTLE_BUFF_EVENT_DEAD = 3,						-- 死亡时触发  
	BATTLE_BUFF_EVENT_ATTACK = 4,						-- 攻击时触发  

	BATTLE_BUFF_EVENT_MAX = 5,
}

EBattleBuffClearType = {
    BATTLE_BUFF_REMOVE_TIME  = 1,						-- 按照时间清除  
    BATTLE_BUFF_REMOVE_TIMES = 2,						-- 按照次数清除  
}

EBattleAttackAI = {
	AI_ATTACK_LINE = 1,									-- 直线远程攻击  
	AI_ATTACK_BACK = 2,									-- 攻击后排  
	AI_ATTACK_SPIKEWEED = 3,							-- 地刺攻击  
	AI_ATTACK_MELEE = 4,								-- 近战攻击  
	AI_ATTACK_THREE = 5,									-- 直线远程三路攻击
	AI_ATTACK_MELEE_MULTI = 6,							-- 近战多体攻击  
	AI_ATTACK_SPIKEWEED_2 = 7,							-- 钢锯地刺攻击  
	AI_ATTACK_THIEF = 8,									-- 小偷  
	AI_ATTACK_RESOURCE = 9,							-- 资源植物  
	AI_ATTACK_BACK_DOUBLE = 10,						-- 攻击后排二次  
	AI_ATTACK_THIEF_BLUE = 11,							-- 蓝色小偷  
	AI_ATTACK_MELEE_BLOCK = 12,						-- 近战攻击没放技能就被阻挡
	AI_ATTACK_RANGE_MULTI = 13,						-- 范围多体攻击
	AI_ATTACK_PRE_RACE = 14,						-- 优先攻击一个指定种族(魔法僵尸和炸弹僵尸)
	AI_ATTACK_PRE_RACE_DOUBLE = 15,					-- 优先攻击两个指定种族(魔法僵尸和炸弹僵尸)
	AI_ATTACK_MAX = 16,
}

EBattleMoveAI = {
	AI_MOVE_LINE = 1,									-- 直线移动  
	AI_MOVE_JUMP = 2,                   						-- 跳高怪的移动  
	
	AI_MOVE_MAX = 3,
}

EBattleSkillAI = {
	AI_SKILL_TIME = 1,										-- 按照时间释放  
	AI_SKILL_TARGET = 2,									-- 有敌方目标释放技能  
	AI_SKILL_TARGET_BITE = 3,							-- 有未被咬住的目标释放技能  
	AI_SKILL_TARGET_BODY = 4,							-- 身体上方有目标释放技能  
	AI_SKILL_TARGET_HURT = 5,							-- 有受伤的目标释放技能
	AI_SKILL_TARGET_RACE = 6,							-- 目标为玉米 or 西瓜
	AI_SKILL_TARGET_BODY_RACE = 7,						-- 身体上方有目标为橄榄球 or 伽刚特尔僵尸
	AI_SKILL_TARGET_PRE_RACE = 8,   					-- 优先选择指定种族(魔法僵尸和炸弹僵尸)
}

EUnitType = {
	TYPE_CREATURE = 0,									-- 生物
	TYPE_CREATURE_OBJECT = 1,							-- 物体
	TYPE_CREATURE_MAX = 2,

	TYPE_BULLET = 100,									-- 子弹
	TYPE_BULLET_TRACE = 101,							-- 追踪子弹
	TYPE_BULLET_CYCLE = 102,							-- 回旋镖
	TYPE_BULLET_MAX = 103,
}

EMoveType = {
	MOVE_TYPE_GROUND = 1,            					-- 地面  
	MOVE_TYPE_SKY = 2,       								-- 空中  
	MOVE_TYPE_SURFACE = 4,					        	-- 地表  
	MOVE_TYPE_LADDER = 8,								-- 梯子  
}

EPlantCreatureType = {
	SUNFLOWER_TYPE = 110,
	MARIGOLD_TYPE = 120,
	PEASHOOTER_TYPE = 130,
	WALLNUT_TYPE = 140,
	SPIKEWEED_TYPE = 150,
	KERNELPULT_TYPE = 160,
	BONKCHOY_TYPE = 170,
	MELONPULT_TYPE = 180,
	BLOOMERANG_TYPE = 190,
}

EMonsterCreatureType = {
	BASICZOMBIE_TYPE = 1,
	DIGGERZOMBIE_TYPE = 2,
	BOOMZOMBIE_TYPE = 3,
	ZOMBIEYETI_TYPE = 4,
	DANCINGZOMBIE_TYPE = 5,
	FLAGZOMBIE_TYPE = 6,
	GARGANTUAR_TYPE = 7,
	BACKUPDANCER_TYPE = 8,
	IMP_TYPE = 9,
	THIEF_TYPE = 10,
}

EDeadWay = {
    DEAD_NORMAL = 1,	--正常死亡
    DEAD_SUICIDE = 2,   --自杀
}