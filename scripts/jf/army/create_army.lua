
local player = require 'ac.player'
local map = require 'jf.map'

--开始刷兵
function map.createArmy()
	if map.army_timer then
		map.army_timer:remove()
		map.army_timer = nil
		return
	end
	local wave = -1
	--print(3)
	map.army_timer = ac.loop(10 * 1000, function(t)
		--成长
		wave = wave + 1
		
		--每30秒刷一波兵
		for _, force in ipairs{'沉沦遗迹', '幻想神社'} do
			for _, way in ipairs{'上路', '中路', '下路'} do
				--print(way)
				local units	= map.units['小兵类型'][force][way]
				--print(units)
				local rects	= map.rects['刷兵区域'][force][way]
				--print(rects)
				
				local i = 0
				local t = ac.timer(500, #units, function()
					i = i + 1
					local name	= units[i]
					--print(name)
					local data = ac.lni.unit[name]
					-- print_r(data)
					local u = player.com[force]:create_unit(name, rects[1], rects[1]:get_point() / rects[2]:get_point())
					for k, v in pairs(data.upgrade) do
						u:add(k, v * wave)
					end
					--保存钱和经验奖励
					u.reward_gold = data['金钱']
					u.reward_exp = data['经验']

					--发布移动攻击指令
					u:issue_order('attack', rects[2])
					
					--在小兵身上保存状态
						--寻路路径
					u:set_data('移动路径', rects)
				end)
				t:on_timer()
			end
		end
	end)
	map.army_timer:on_timer()
end
