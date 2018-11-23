
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
		攻击有%chance%%增加%power%智力，上限为人物等级*15，持续%time%s

	]],
	
	-- 几率
	chance = {100,20,30},

	-- power
	power = {10,20,30},

	--持续时间
	time = {5,10,15},

	-- 力量上限
	max_power = function(self, hero)
        return hero.level*3
	end,


}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self
	local base_attack = hero:get('智力')
	local criticle_attack = true;

	self.event = hero:event '造成伤害效果' (function(trg, damage)
       
		--普攻触发
		if damage:is_common_attack()   then
            --几率触发
			if math.random(1,100) > self.chance then
				return
			end
			
            --增加的力量上限为人物等级*15
			if (hero:get('智力')-base_attack + self.power)>= self.max_power   then

				--靠近临界值的最后一次攻击，是否允许增加力量。会导致 3 秒内的增加的攻击失效，不会出现一直攻击，一直在上限值
				if  not criticle_attack then
					return
				end
				criticle_attack = false

				hero:add_buff(filename)
				{
					skill = skill,
					time =  skill.time,
					power = self.max_power-self:get_stack()*self.power
				}
				-- print('人物等级*15',self.max_power,'增加的攻击',hero:get('攻击')-base_attack)

				return
			end

			criticle_attack = true;

			hero:add_buff(filename)
			{
				skill = skill,
				time =  skill.time,
				power = self.power
			}

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
	self.target:add('智力', self.power)
	
end

function mt:on_remove()
	self.skill:add_stack(-1)
	self.target:add('智力', - self.power)
end








