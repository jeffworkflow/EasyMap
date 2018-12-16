rawset(_G, 'poi', {})

--require 'jf.tower.防御塔-强化'

local map = {}
local fogmodifier = require 'types.fogmodifier'
local timerdialog = require 'types.timerdialog'

map.map_name = 'demo1'

ac.game:event '游戏-开始' (function()
	--刷兵
	local army = require 'jf.army._init'

	army:init()

	local hero = ac.player(1).hero
	hero:add('攻击',1000)
	hero:add('攻击速度',1000)
	
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


	--注册野怪
	local creeps = require 'jf.creeps._init'
	--creeps.init()

	--注册防御塔
	--require 'jf.tower.init'         

	--注册英雄
	require 'jf.hero.init'

	

	--测试
	-- local test = require 'test.init'
	-- local jass = require 'jass.common'
	-- test.init()

    -- local hero2 = test.helper:dummy('小矮人',10000, 1);
	-- hero2:set_level(15);
	-- hero2:set('攻击', 100);
	-- print(hero2:get_point():getZ())
	local rect = require 'types.rect'
	local tt = rect.j_rect('wq')

	for i=1,30 do
		local u = ac.player[12]:create_unit('进攻怪物 Lv1',tt)
		-- u:add_ability 'A00V'
		u:add_buff('定身'){
			time = 60
		}
	end 

	
    -- for i = 1, 80 do
    --     local u = ac.player[13]:create_unit('进攻怪物 Lv1',rect.j_rect 'attack')
	-- 	u:add_buff('定身'){
	-- 		time = 60
	-- 	}
    --     u:add_ability 'A00V'
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
	require 'jf.map_shop._init'
	
    --等待选人结束
	require 'jf.choose_hero.init'

	--注册智能施法
	require 'jf.smart_cast.init'

	local shop 
	--全地图找商店
    local group = ac.selector():allow_god():get()
    for _, u in ipairs(group) do
        if u:get_name() == '进阶商店' then
            shop = u
            break;
        end    
	end    
	-- print(shop)
	shop:add_item_button('灵宝剑',10)
	-- shop:add_item_button('新手剑',10)
	shop:add_item_button('神石',10)
	
	local rect = require 'types.rect'
	local tt = rect.create('400','0','800','400')
	local point = tt:get_point()
	point:add_item('新手石')
	point:add_item('新手石')
	point:add_item('新手石')
	point:add_item('新手石')
	point:add_item('新手石')
	point:add_item('新手剑')
	point:add_item('新手剑')
	point:add_item('新手剑')
	point:add_item('新手戒指')
	point:add_item('新手戒指')
	point:add_item('新手甲')
	point:add_item('新手甲')


	--游戏选择难度
	require 'jf.game_choose._init'
	-- local Dialog = require 'types.dialog'
	-- local jass = require 'jass.common'
	-- local degree_dialog ={
	-- 	title = '游戏难度'
	-- }
	
	

	ac.wait(1*1000, function()
		ac.game:event_notify('游戏-选择难度')
		
		

		-- local handle = jass.DialogCreate()
		-- jass.DialogSetMessage(handle, degree_dialog.title)
		-- jass.DialogDisplay(ac.player(1).handle, handle, true)
			  
	end)
	


end

return map
