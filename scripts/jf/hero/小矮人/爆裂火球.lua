local mt = ac.skill['爆裂火球']

mt{
    --等级
    level = 0,
	tip = [[
		|cff11ccff被动：|r
		攻击时%chance%%触发火球术，对%area%周围造成%damage%伤害。
	]],
	

	count = function(self, hero)
        return hero.weapon['弹道数量']
	end	,
	--概率触发多重锤
	chance = 100, --90表示百分90%

	--类型
	type = '投射物',

	--model
	model = [[GryphonRiderMissile2.mdx]],
		
	--弹道速度
	speed = 1000,
		
	--范围
	area = 350,	
	--伤害
	damage = 30,


	--自由碰撞时的碰撞半径
	hit_area = 100,

}

mt.passive = true
--  mt.passive = true
--  mt.level = 1


function mt:on_add()
	local skill = self
	local function range_attack_start(hero, damage)
	
		if damage.skill and damage.skill.name == self.name then
			return
		end
		local target = damage.target
		local damage = skill.damage
		local unit_mark = {}

		for i,u in ac.selector()
			: in_range(hero,hero:get('攻击距离'))
			: is_enemy(hero)
			: of_not_building()
			: sort_nearest_hero(hero) --优先选择距离英雄最近的敌人。
			: set_sort_first(target)
			: ipairs()
     	do
			if i <= hero.weapon['弹道数量'] then
				local mvr = ac.mover.target
				{
					source = hero,
					target = u,
					model = self.model,
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
					for _,target in ac.selector()
						: in_range(u,skill.area)
						: is_enemy(hero)
						: of_not_building()
						: ipairs()
					do 
						if not unit_mark[target] then 
							if target == u then --命中中心的敌人额外伤害，并允许触发额外辅助
								target:damage
								{
									source = hero,
									damage = damage,
									skill = skill,
									missile = self.mover,
									damage_type = '法术',
									allow_other_skill = true
								}
							else 
								target:damage
								{
									source = hero,
									damage = damage,
									damage_type = '法术',
									missile = self.mover,
									skill = skill,
								}
							end	
							unit_mark[target] = true
				    	end
			     	end
					--return true
				end
			end	
		end
		hero.range_attack_start = self.oldfunc

	end

	local hero = self.owner
	self.oldfunc = hero.range_attack_start

	self.event = hero:event '单位-攻击出手' (function(trg, data)
        
		
		if math.random(1,100) > self.chance then
			return
		end
		
		hero.range_attack_start = range_attack_start
	end)


end

function mt:on_remove()
	self.event:remove();
end






