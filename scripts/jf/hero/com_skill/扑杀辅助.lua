
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
		辅助任何可击中敌人的技能，击中后血量<+%value%% 时将会直接死亡。
	]],
	
	--各种效果值
	value = {99,150,200},

}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
    
	self.event =  hero:event '造成伤害效果' (function(trg, damage)
        -- print(damage:is_skill() )
		--技能触发
		if damage:is_skill()   then
			
			local life = damage.target:get '生命'
			local max_life = damage.target:get '生命上限'
			local target_life = max_life * self.value / 100
            -- print(life,target_life)
			if life <= target_life then
				
			    damage:kill()
            end
		end
	end)
	
end

function mt:on_remove()

	self.event:remove();
end








