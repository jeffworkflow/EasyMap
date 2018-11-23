
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
		击杀单位增加%power%力量，持续%time%s
	]],
	

	-- power
	power = {100,200,300},

	--持续时间
	time = {5,10,15}
}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
    
	self.event =  hero:event '单位-杀死单位' (function(trg, killer, target)


		hero:add_buff(filename)
		{
			skill = skill,
			time =  skill.time,
			power = self.power
		}
        -- print('力量1 当前层数:',self:get_stack())


	end)


	
end

function mt:on_remove()
	self.event:remove();
end



local mt = ac.buff[filename]

mt.cover_type = 1

function mt:on_add()
	self.skill:add_stack(1)
	self.target:add('力量', self.power)
	-- print('力量1 增加攻击','原始攻击：',self.target:get('攻击'),'增加攻击',self.power)

end

function mt:on_remove()
	self.skill:add_stack(-1)
	self.target:add('力量', - self.power)
end









