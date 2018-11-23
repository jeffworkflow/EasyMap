
local file = debug.getinfo(1, "S").source -- 第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息
local filename = string.sub(file, 2, -1) -- 去掉开头的"@"
-- filename = string.match(path, "^.*/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
filename = stripextension(strippath(filename))


local mt = ac.skill[filename]

mt{
    --等级
    level = 1,
    --最大等级
    max_level = 3,
	tip = [[
		|cff11ccff被动：|r
		击杀敌人后增加额外%gold%枚金币，受金币加成影响

	]],
	
	-- 几率
	chance = {100,20,30},

	-- power
	gold = {99,20,30},




}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self
	local player = hero:get_owner()
   
	self.event = hero:event '单位-杀死单位' (function(trg, killer, target)
	   
		if not target.reward_gold then
			print('单位没有设置掉落基础金钱')
			return
		end	
		player:addGold(self.gold,hero)
		
	end)


	
end

function mt:on_remove()
	self.event:remove();
end









