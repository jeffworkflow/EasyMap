local mt = ac.skill['多重锤-目标']

mt{
    --等级
    level = 0,
	--范围
	area = 350,	
	tip = [[
		|cff11ccff被动：|r
		攻击%chance%%并发射%count%个锤子。
	]],
	

	count = function(self, hero)
        return hero.weapon['弹道数量']
	end	,
	--概率触发多重锤
	chance = 40, --90表示百分90%


		
	--弹道速度
	speed = 1000,

	

	
	--自由碰撞时的碰撞半径
	hit_area = function(self, hero)
        return hero.weapon['技能范围']
	end,
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
		local damage = damage.damage
		local unit_mark = {}

		for i,u in ac.selector()
			: in_range(hero,hero:get('攻击距离'))
			: is_enemy(hero)
			: of_not_building()
			: sort_nearest_hero(hero) --优先选择距离英雄最近的敌人。
			: ipairs()
     	do
			if i <= hero.weapon['弹道数量'] then
				local mvr = ac.mover.target
				{
					source = hero,
					target = u,
					model = hero.weapon['弹道模型'],
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
				
					u:damage
					{
						source = hero,
						damage = damage,
						skill = skill,
					}
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






