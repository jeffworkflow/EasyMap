require 'jf.hero.com_skill.init'
require 'jf.hero.小矮人.爆裂火球'
require 'jf.hero.小矮人.铁砂之剑'
require 'jf.hero.小矮人.斩红跳砍'
require 'jf.hero.小矮人.多重影分身'
require 'jf.hero.小矮人.追踪御礼'
require 'jf.hero.小矮人.凝霜冰杖'
require 'jf.hero.小矮人.不规则运动'
require 'jf.hero.小矮人.雷霆之箭'
require 'jf.hero.小矮人.山丘之锤'
require 'jf.hero.小矮人.灵符[梦想封印]'
require 'jf.hero.小矮人.回旋刃'
require 'jf.hero.小矮人.山丘的大锤子'
require 'jf.hero.小矮人.猥琐的闪电箭'
require 'jf.hero.小矮人.光速[光速跳跃]'
require 'jf.hero.小矮人.万箭齐发'
require 'jf.hero.小矮人.火遁'


return ac.hero.create '小矮人'
{
	--物编中的id
	id = 'T00B',

	production = 'war3',

	model_source = '风潮网络',

	hero_designer = 'war3',

	hero_scripter = 'jeff',

	show_animation = { 'attack slam', 'spell channel' },

	--技能数量
	skill_count = 6,
	--免死 攻击速度I 猎杀者  炼金 掠夺 偷窃
	--力量I 力量II 力量III
	--敏捷I 敏捷II 敏捷III
	--智力I 智力II 智力III
	--雷霆之箭 山丘之锤  回旋刃 山丘的大锤子 
	--  龟派气功 凝霜冰杖 追踪御礼 环绕之风  智力I 智力II 智力III 闪烁 嗜血辅助 流血 扑杀辅助  多重锤-目标 范围辅助 分裂箭  多重投射 蓄力 勇猛 致命恐惧 追猎 求生 死亡体验  憎恨 坚韧 磐石 恐吓   净化III 净化II 净化I 愈体 回春 活力 攻击回血  力量1 力量2  力量3  霜冻攻击    多重锤-目标 生命成长

	--[[data.attack = true
	data.common_attack = true
	data.skill = data.skill 猥琐的闪电箭   灵符[梦想封印]
	]]
	skill_names = ' 闪烁  多重影分身   力量III 爆裂火球   ' ,

	attribute = {
		['力量'] = 10,
		['敏捷'] = 10,
		['智力'] = 10,
		['生命上限'] = 1000,
		['魔法上限'] = 600,
		['生命恢复'] = 3.5,
		['魔法恢复'] = 1.1,
		['魔法脱战恢复'] = 0,
		['攻击']    = 1,
		['护甲']    = 10,
		['移动速度'] = 310,
		['攻击间隔'] = 0.7,
		['攻击速度'] = 50,
		['攻击距离'] = 1000,
	},

	upgrade = {
		['生命上限'] = 125,
		['魔法上限'] = 30,
		['生命恢复'] = 0.25,
		['魔法恢复'] = 0.1,
		['攻击']    = 1.3,
		['护甲']    = 1.3,
	},

	weapon = {
		--['弹道模型'] = [[GryphonRiderMissile2.mdx]],
		['弹道模型'] = [[StarDust.mdx]],
		
	    --['弹道模型'] = [[Abilities\Spells\Other\BlackArrow\BlackArrowMissile.mdl]],
		['弹道速度'] = 900,
		['弹道弧度'] = 0,
		['弹道出手'] = {15, 0, 66},
		['弹道数量'] = 2,
		['技能范围'] = 100,
	},

	difficulty = 1,

	--选取半径
	selected_radius = 32,
}
