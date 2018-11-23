
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
        攻击时有%chance%%几率对目标释放炼金术，额外获得基础金币*%gold%%的收入，对BOSS无效
	]],
	
	-- 几率
	chance = {100,20,30},

	-- power
	gold = {100,20,30},




}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self
	local player = hero:get_owner()
   
	self.event = hero:event '造成伤害效果' (function(trg, damage)
	   
	   
		--普攻触发
		if damage:is_common_attack()   then
            --几率触发
			if math.random(1,100) > self.chance then
				return
			end
			if not damage.target.reward_gold then
                print('单位没有设置掉落基础金钱')
			    return
			end	
			-- print(hero:get_owner())
			-- print(damage.target:get_level() * self.gold)
			player:addGold(damage.target.reward_gold * self.gold/100,hero)

		end
		
	end)


	
end

function mt:on_remove()
	self.event:remove();
end









