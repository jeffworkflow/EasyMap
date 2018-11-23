
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
		攻击有%chance%%增加%attack_speed%%攻击速度，上限为%max_attack_speed%%，持续%time%s
		
	]],
	
	-- 几率
	chance = {100,20,30},

	-- 攻击速度
	attack_speed = {15,20,30},

	-- 攻击速度上限
	max_attack_speed = 150,
    
	--持续时间
	time = {5,10,15},

	--已增加的值
	keep_attack_speed = 0,



}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	local criticle_attack = true;

	self.event = hero:event '造成伤害效果' (function(trg, damage)
       
		--普攻触发
		if damage:is_common_attack()   then
            --几率触发
			if math.random(1,100) > self.chance then
				return
			end
			
            --增加的力量上限为人物等级*15
			if (self.keep_attack_speed + self.attack_speed) >= self.max_attack_speed   then

				--靠近临界值的最后一次攻击，是否允许增加力量。会导致 3 秒内的增加的攻击失效，不会出现一直攻击，一直在上限值
				if  not criticle_attack then
					return
				end
				criticle_attack = false

				hero:add_buff(filename)
				{
					skill = skill,
					time =  skill.time,
					attack_speed = self.max_attack_speed-self.keep_attack_speed
				}
				-- print('限定的最大攻击速度%',self.max_attack_speed..'%','已增加的攻击速度%',self.keep_attack_speed..'%')

				return
			end

			criticle_attack = true;

			hero:add_buff(filename)
			{
				skill = skill,
				time =  skill.time,
				attack_speed = self.attack_speed
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
	
	self.skill.keep_attack_speed = self.skill.keep_attack_speed + self.attack_speed
	-- print('增加前的攻击速度：',self.target:get('攻击速度'))
	self.target:add('攻击速度%', self.attack_speed)
	-- print('增加后的攻击速度：',self.target:get('攻击速度'))
	
end

function mt:on_remove()
	
	self.skill.keep_attack_speed = self.skill.keep_attack_speed - self.attack_speed
	self.target:add('攻击速度%', - self.attack_speed)
	-- print('减少后的攻击速度：',self.target:get('攻击速度'))
end








