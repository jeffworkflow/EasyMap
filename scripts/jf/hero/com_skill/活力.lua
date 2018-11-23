
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
		每次攻击都会使受到的治疗效果提高%heal_percent%%持续%time%秒，最多叠加5层
	]],
	
	-- 几率
	chance = {100,20,30},

	-- 回血
	heal = {15,20,30},

	-- 回血 生命上限%
	heal_percent = {10,20,30},
    
	--最高层数
	max_stack = 5,

	--持续时间
	time = {2,10,15}


}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	self.event = hero:event '造成伤害效果' (function(trg, damage)
		
	    -- print('叠加层数：',self:get_stack())
		if self:get_stack() >= self.max_stack then
			return
		end

		--普攻触发
		if damage:is_common_attack()   then
            --几率触发
			if math.random(1,100) > self.chance then
				return
			end
			
			
			hero:add_buff(filename)
			{
				skill = skill,
				time =  skill.time,
				heal_percent = self.heal_percent
			}

			-- print(self.heal + hero:get '生命上限'*self.heal_percent/100)
		end
		
	end)


	
end

function mt:on_remove()
	self.event:remove();
end


local mt = ac.buff[filename]

mt.cover_type = 1

mt.effect = nil


function mt:on_add()
	
	self.skill:add_stack(1)
	local hero = self.target
	self.trg = hero:event '受到治疗效果' (function(trg, heal)
		if heal.skill and heal.skill.name == self.skill.name then
			return
		end
		-- if hero:get '生命' < hero:get '生命上限' then
			hero:heal
			{
				heal = heal.heal * self.skill.heal_percent/100,
				skill = self.skill,
			}
			-- print('治疗',heal.heal * self.skill.heal_percent/100)
			hero:add_effect('origin', [[Abilities\Spells\Undead\ReplenishMana\SpiritTouchTarget.mdl]]):remove()
		-- end
		
	end)
	
end

function mt:on_remove()
	self.skill:add_stack(-1)
	self.trg:remove();
end






