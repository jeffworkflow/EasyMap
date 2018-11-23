
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
		生命值低于%below_life%%时获得一个%value%%减伤效果，持续%time%s，此技能%cool%秒触发一次
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
	local skill = self


	self.event =  hero:event '受到伤害效果' (function (trg, damage)
		-- print('减伤前 ',damage.missile)
    	-- print('受到伤害：',damage.damage)
		if self:is_cooling() then
			return
		end

		local life = hero:get '生命'
		local max_life = hero:get '生命上限'
		local target_life = max_life * self.below_life / 100

		if life < target_life then

			-- 最终伤害减免
			-- damage:div(self.value/100);
			-- 最终伤害减免
			hero:add_buff(filename)
			{
				skill = skill,
				time =  skill.time,
				value = skill.value
			}
			--激活技能冷却
		   self:active_cd();

		end
		--测试
		-- self.event1 = hero:event '受到伤害效果' (function(trg, damage)
		-- 	print('减伤后 ',damage.damage)
		-- end);	
		
	end);
	
	
end

function mt:on_remove()
	self.event:remove();
end


local mt = ac.buff[filename]


function mt:on_add()
	local hero = self.target
	self.trg = hero:event '受到伤害' (function(trg, damage)
		damage:div(self.value/100)
	end)
	
end

function mt:on_remove()
	self.trg:remove();
    -- print(' ',self.damage.damage)
	--self.mover:remove()
end


function mt:on_cover(new)
	return true
end








