
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
		攻击有%chance%%使敌人流血，在%time%秒内 每秒受到 %value_base%%（+%value%%/人物等级） 的武器伤害（作为物理伤害）

	]],
	
	-- 几率
	chance = {100,20,30},

	-- power
	value = {10,20,30},
	value_base = {100,20,30},

	--持续时间
	time = {5,10,15},
    --武器伤害
	weapon_damage = 10


}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self
	local base_attack = hero:get('攻击')
	local criticle_attack = true;

	self.event = hero:event '造成伤害效果' (function(trg, damage)
       
		--普攻触发
		if damage:is_common_attack()   then
            --几率触发
			if math.random(1,100) > self.chance then
				return
			end
			
	 	   damage.target:add_buff(filename)
			{
				source = hero,
				skill = skill,
				time =  skill.time,
				value = self.power,
				damage = (self.value * hero.level + self.value_base)/100 * skill.weapon_damage
			}

		end
		
	end)


	
end

function mt:on_remove()
	self.event:remove();
end

local mt = ac.dot_buff[filename]

mt.debuff = true

function mt:on_add()
	self.eff = self.target:add_effect('chest', [[Abilities\Spells\Other\BreathOfFire\BreathOfFireDamage.mdl]])
end

function mt:on_remove()
	self.eff:remove()
end

function mt:on_pulse(damage)
	self.target:damage
	{
		source = self.source,
		damage = damage * self.pulse,
		skill = self.skill,
	}
end







