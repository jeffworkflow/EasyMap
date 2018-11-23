
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
		每次攻击有%chance%%几率将增加自身%value%点护甲值，持续%time%秒，可叠加%max_stack%层。
	]],
	
	--最高层数
	max_stack =  {5,2,3},

	--几率
	chance =  {100,2,3},

	--各种效果值
	value = {10,150,200},

	--持续时间
	time = {10,10,15}
}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
    
	self.event =  hero:event '造成伤害效果' (function(trg, damage)

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
				value = self.value
			}
		end
	end)


	
end

function mt:on_remove()

	self.event:remove();
end


local mt = ac.buff[filename]

mt.cover_type = 1
-- mt.cover_max = 5

function mt:on_add()
	self.skill:add_stack(1)
	self.target:add('护甲', self.value)
	-- print('力量2 增加攻击','原始攻击：',self.target['属性']['攻击'],self.target['属性']['攻击%'])

end

function mt:on_remove()
	self.skill:add_stack(-1)
	self.target:add('护甲', - self.value)
end








