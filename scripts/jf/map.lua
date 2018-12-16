rawset(_G, 'poi', {})

--require 'jf.tower.防御塔-强化'

local map = {}
local fogmodifier = require 'types.fogmodifier'

map.map_name = 'demo1'

ac.game:event '游戏-开始' (function()
	--刷兵
	local army = require 'jf.army'

	--army.init()
	
	--启用计时
	local gamet = require 'jf.rule.gametime'
	gamet.gt() 
end)

function map.init()
	--加载地图规则
	require 'jf.rule.init'
    

	--注册不可通行区域
	--map.pathRegionInit()
	--print("2")

	--注册瀑布机制
	--local spring = require 'jf.spring'
	--spring.init()
	--print("1")
	ac.game:event_notify('游戏-开始')
	--print("不调用游戏开始，进行测试")

	
    --测试
	--local testing = require 'jf.testing.init'
	--testing.init()
    --require 'jf.exeroom.init'

	--exeroom.init()
	--注册野怪
	--local creeps = require 'jf.creeps'
	--creeps.init()

	--注册防御塔
	--require 'jf.tower.init'         

	--注册英雄
	require 'jf.hero.init'

	local rect = require 'types.rect'

	-- for i = 1, 100 do
	-- 	local u = ac.player[6]:create_unit('萌物A',rect.create(400,-600,400,-600));
	-- 	print(u)
	-- 	-- local u = player.com[2]:create_unit('萌物A', rect.j_rect 'army_m1')
	-- 	u.reward_gold = 35
	-- 	u.reward_exp = 31110
	-- 	u:set_level(3)
	-- 	u:add('魔法上限', 100)
		
	-- end

	-- for i = 1, 10 do
	-- 	local u = ac.player[6]:create_unit('h001',map.rects['test']);
	-- 	-- print(u,map.rects['test'])
	--     u:add('生命上限', 10000000)
	-- 	u:set_level(3)
	-- 	u.weapon ={}
	-- 	u.attribute = {}
	-- 	u.weapon['弹道模型'] = [[StarDust.mdx]]
	-- 	u:set('攻击距离',1000);
	-- 	-- u:add('减伤值',40) 
	-- end
	
	

	--注册物品
	require 'jf.map_item._init'

	--注册商店
	require 'jf.map_shop.init'
	
    --等待选人结束
	--require 'jf.choose_hero.init'

	--注册智能施法
	require 'jf.smart_cast.init'


end

return map
