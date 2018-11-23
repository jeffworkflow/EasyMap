
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
		减少%value%+人物等级*%hero_lv_plus%受到的任意伤害
	]],


	--各种效果值
	value = {100,150,200},

	--
	hero_lv_plus = {5,6,7},


	--持续时间
	time = {10,10,15}
}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self


	self.event =  hero:event '受到伤害' (function (trg, damage)
		-- print('减伤前 ',damage.damage)
		-- local dmg = damage.damage - (self.value + self.level*self.hero_lv_plus)
		-- if dmg <=0 then 
		--    dmg = 0
		-- end
 		-- 最终伤害减免
		damage:mul(0,function(damage)
			damage.current_damage = damage.current_damage - (self.value + self.level*self.hero_lv_plus)
		end);
		
		--测试
		-- self.event1 = hero:event '受到伤害效果' (function(trg, damage)
		-- 	print('减伤后 ',damage.damage)
		-- end);	
		
	end);
	
end

function mt:on_remove()
	self.event:remove();
end









