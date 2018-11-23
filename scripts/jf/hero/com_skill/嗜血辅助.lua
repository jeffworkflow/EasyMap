
local file = debug.getinfo(1, "S").source -- 第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息
local filename = string.sub(file, 2, -1) -- 去掉开头的"@"
-- filename = string.match(path, "^.*/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
filename = stripextension(strippath(filename))


local mt = ac.skill[filename]

mt{
    --等级
    level = 0,
    --最大等级
    max_level = 3,
	tip = [[
		|cff11ccff被动：|r
		若敌人拥有【流血】效果，立即结算剩余伤害，并且额外造成%value%%伤害

	]],

	-- power
	value = {10,20,30},


}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self
	local base_attack = hero:get('攻击')

	self.event = hero:event '造成伤害效果' (function(trg, damage)
  
		if damage.skill and damage.skill.name == self.name then
			return
		end

		--结算红莲太刀
		local buff = damage.target:find_buff '流血'
		if buff then
			local dama = 0
			for _, dmg in ipairs(buff.damages) do
				dama = dama + dmg
			end
			-- print(dama,buff.pulse)
			
			damage.target:damage
			{
				source = hero,
				damage = dama * buff.pulse*(1+self.value),
				skill = skill,
			}
		
			buff:remove()
		end
		
	end)


	
end

function mt:on_remove()
	self.event:remove();
end






