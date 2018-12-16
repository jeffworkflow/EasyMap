
require 'jf.rule.设置'   --设置英雄，学习，智能施法，预览位置对应的 技能id。
require 'jf.rule.player' --设置队伍与同盟
require 'jf.rule.rects' --加载预设的区域
-- require 'jf.rule.units' -- 注册 单位死亡加钱事件（小兵、建筑）
require 'jf.rule.misc' --加载伤害系统
require 'jf.rule.hero' --注册英雄，添加技能点，隐藏属性，注册死亡复活事件，注册英雄升级事件。
--require 'jf.rule.attack' --禁止队友互A，按s停止攻击。
require 'jf.rule.win' -- 结束，回收建筑、单位、回收各种事件分发等。
require 'jf.rule.kill_hero' -- 连杀，称号，文字，声音，野怪杀死，等一系列事件
require 'jf.rule.gold' --初始化金币，每秒多少钱，玩家离开变卖装备，分配金币。
--require 'jf.rule.home' --基地光环，友军回百分比的生命与魔法
require 'jf.rule.tp'  -- 处理 tp 回城事件
require 'jf.rule.visible' --处理战争迷雾相关
-- require 'jf.rule.multiboard' -- 显示多面板信息。包含刷新补刀数，杀英雄数，死亡总数等
require 'jf.rule.tips'   --每3分钟本地玩家随机提示 游戏规则。
require 'jf.rule.sound'  --初始化每个英雄的各个动作声音
--require 'maps.rule.积分'
require 'jf.rule.新积分'  -- 积分计算（类似王者荣耀的的战力）
require 'jf.rule.keybord_mouse'

local jass = require 'jass.common'

jass.SetSkyModel([[Environment\Sky\LordaeronSummerSky\LordaeronSummerSky.mdx]])