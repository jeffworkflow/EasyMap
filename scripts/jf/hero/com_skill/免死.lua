
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
	    避免一次死亡，并回复%value%%生命值，此技能每%cool%s触发一次
	]],

	--CD
	cool = {18,1,1},

	--各种效果值
	value = {90,150,200},

	--生命值低于
	below_life = {100,80,80},

	--持续时间
	time = {5,5,5}

}

-- 被动
mt.passive = true

function mt:on_add()
	local hero = self.owner
	self.trg = hero:event '单位-即将死亡' (function(trg, damage)
		if self:is_cooling() then
			return
		end
		hero:add_effect('origin', [[Abilities\Spells\Human\Resurrect\ResurrectCaster.mdl]]):remove()
		
		hero:heal{ 
			heal = hero:get '生命上限'*self.value/100, 
			skill = self 
		}
	
		self:active_cd()
		return true
	end)
end

function mt:on_remove()
	self.trg:remove()
end








