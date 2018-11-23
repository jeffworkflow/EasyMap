
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
		减少%value%%攻击速度，增加%value1%%额外伤害
	]],
	--CD
	cool = {5,1,1},
	-- value
	value = {20,2,3},
	-- value
	value1 = {20,2,3},
	
}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
	hero:add('攻击速度%',-self.value) 
	hero:add('攻击%',self.value1) 



	
end

function mt:on_remove()
	hero:add('攻击速度%',self.value) 
	hero:add('攻击%',-self.value1) 
end






