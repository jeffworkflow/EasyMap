
local file = debug.getinfo(1, "S").source -- 第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息
local filename = string.sub(file, 2, -1) -- 去掉开头的"@"
-- filename = string.match(path, "^.*/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
filename = stripextension(strippath(filename))


local mt = ac.skill[filename]

mt{
    --等级
    level = 0,
    max_level = 4,
	--范围
	area = 350,	
	tip = [[
		|cff11ccff被动：|r
		命中目标时%chance%% 分裂出 %count%个投射物碎片,碎片造成%damage_rate%%伤害。
	]],
	

	--弹幕数量
	count = {2,4,6,8},

	--造成伤害的比例
	damage_rate = 30,

	--概率触发多重锤
	chance = 40, --90表示百分90%

	
	--弹道速度
	speed = 800,

	--自由碰撞时的碰撞半径
	hit_area = 100,

	--分裂范围
	split_area = 500,
}

mt.passive = true
--  mt.passive = true
--  mt.level = 1


function mt:on_add()
	
	local hero = self.owner
	local skill = self
	local split_flag = true
	 
	self.event = hero:event '造成伤害效果' (function(trg, damage)
		--不允许分裂 就返回。
		if not split_flag  then
           return
		end	
		--不允许额外技能效果返回（不允许范围伤害，同时又有分裂效果）
		if not damage.allow_other_skill  then
			return
		 end	
		--没有绑定技能，绑定了技能，技能不是投射物，直接返回。
		if not damage.skill or not damage.skill.type or damage.skill.type ~= '投射物' then 
		   return
		end   

		local model = damage.skill.model
		if not model then
			model = hero.weapon['弹道模型']
		end	

		local source = damage.target
		local damage = damage.damage/100*self.damage_rate
		
		
		-- if math.random(1,100) > self.chance then
		-- 	return
		-- end
		for i,u in ac.selector()
			: in_range(source,skill.split_area)
			: is_enemy(hero)
			: of_not_building()
			: is_not(source)
			: sort_nearest_hero(hero) --优先选择距离英雄最近的敌人。
			: ipairs()
		do
			
			if i <= skill.count then
				local mvr = ac.mover.target
				{
					source = source,
					target = u,
					model = model,
					speed = skill.speed,
					high = 110,
					skill = skill,
					damage = damage,
					hit_area = skill.hit_area,
				}
				if not mvr then
					return
				end
				function mvr:on_finish()
					split_flag = false ; --本次投射物完成后不允许分裂
					u:damage{
						source = hero,
						damage = damage,
						skill = skill,
					}
					split_flag = true ; --下次攻击允许分裂
					
				end
			end	
		end	
		





	end)


end

function mt:on_remove()
	self.event:remove();
end








