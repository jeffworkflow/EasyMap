require 'jf.hero.小矮人.群体风暴之锤'
require 'jf.hero.小矮人.如意棒'
require 'jf.hero.小矮人.狂暴'
require 'jf.hero.小矮人.筋斗云'
require 'jf.hero.小矮人.明日之诗'
require 'jf.hero.小矮人.强化爆裂魔法'
require 'jf.hero.小矮人.直排御礼'
require 'jf.hero.小矮人.多重锤-目标'
require 'jf.hero.小矮人.多重锤-直线'
require 'jf.hero.小矮人.分裂锤'
require 'jf.hero.小矮人.快速射击'
require 'jf.hero.小矮人.龟派气功'
require 'jf.hero.小矮人.快速攻击'
require 'jf.hero.小矮人.霜冻攻击'

return ac.hero.create '小矮人'
{
	--物编中的id
	id = 'H00B',

	production = 'war3',

	model_source = '风潮网络',

	hero_designer = 'war3',

	hero_scripter = 'jeff',

	show_animation = { 'attack slam', 'spell channel' },

	--技能数量
	skill_count = 4,

	skill_names = '多重锤-目标 霜冻攻击 快速攻击 分裂锤' ,

	attribute = {
		['生命上限'] = 1000,
		['魔法上限'] = 600,
		['生命恢复'] = 3.5,
		['魔法恢复'] = 1.1,
		['魔法脱战恢复'] = 0,
		['攻击']    = 1,
		['护甲']    = 12,
		['移动速度'] = 310,
		['攻击间隔'] = 1.1,
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
		['弹道模型'] = [[Abilities\Spells\Other\BlackArrow\BlackArrowMissile.mdl]],
		['弹道速度'] = 900,
		['弹道弧度'] = 0,
		['弹道出手'] = {15, 0, 66},
		['弹道数量'] = 6,
	},

	difficulty = 1,

	--选取半径
	selected_radius = 32,
}
