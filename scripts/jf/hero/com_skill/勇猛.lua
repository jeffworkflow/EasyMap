
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
        攻击时若周围%area%范围内敌人数量>%enemy%则提高%value%%伤害
	]],
	--CD
	cool = {5,1,1},
	-- value
	value = {10,2,3},
	-- value
	area = {350,350,350},
	-- value
	enemy = {2,5,5},
	
}

-- 被动
mt.passive = true


function mt:on_add()
	
	local hero = self.owner
	local skill = self

	-- hero.weapon['弹道模型'] = [[Abilities\Spells\Other\FrostDamage\FrostDamage.mdl]]
	
	self.event =  hero:event '造成伤害' (function(trg, damage)
		-- if self:is_cooling() then
		-- 	return
		-- end
		
		if damage:is_common_attack()   then
            local group = ac.selector()
							: in_range(hero,self.area)
							: is_enemy(hero)
							: of_not_building()
							: get()

            if #group >= self.enemy then 
			   damage:mul(self.value)
			end   
			--激活技能冷却
			-- self:active_cd()
		end	
		
	end)


	
end

function mt:on_remove()

	self.event:remove();
end






