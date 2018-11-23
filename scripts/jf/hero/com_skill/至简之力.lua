
local file = debug.getinfo(1, "S").source -- 第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息
local filename = string.sub(file, 2, -1) -- 去掉开头的"@"
filename = stripextension(strippath(filename))


local mt = ac.skill[filename]

mt{
    --等级
    level = 0,
    --最大等级
    max_level = 3,
	tip = [[
		|cff11ccff被动：|r
		攻击时降低天赋技能造成伤害5%, 并回复生命上限 * %heal_percent%%的生命值
		
	]],
	
	-- 几率
	chance = {100,20,30},

	-- 回血
	heal = {15,20,30},

	-- 回血 生命上限%
	heal_percent = {1,20,30},
    


}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	self.event = hero:event '造成伤害效果' (function(trg, damage)
		
		--普攻触发
		if damage:is_common_attack()   then
            --几率触发
			if math.random(1,100) > self.chance then
				return
			end
			
			hero:heal{ 

				heal  = hero:get '生命上限'*self.heal_percent/100, 
			    skill = self 
		
			}
			-- print(self.heal + hero:get '生命上限'*self.heal_percent/100)
		end
		
	end)


	
end

function mt:on_remove()
	self.event:remove();
end







