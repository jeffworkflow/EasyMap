local mt = ac.skill['不规则运动']

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
		
		
		-- local target1 = hero:get_point()
		-- target1 = target1 + {0,0,100}
	    -- local max_on_move_count = 40
		local mvr = ac.mover.target
		{
			source = hero,
			target = target,
			model = self.model,
			speed = 800,
			-- high = 400,
			height = 300,
			--反方向
			-- angle =  target:get_point()/ hero:get_point() ,
			turn_speed = 360,
			skill = skill,
			damage = damage,
			hit_area = skill.hit_area,
			on_move_count = 0,
		}
		if not mvr then
			return
		end
		function mvr:on_move()
			--================= v2 ===============
			
			-- if self.on_move_count < 20  then
			-- 	self.height = self.height +10

			-- 	 self.angle = source_angle
			-- else 

			--================= v1 ============
			-- print('已经移动进程',self.moved_progress,'当前移动进程',self.progress)
		
			-- local p1, p2 = self.mover:get_point(), self.target:get_point()
			-- local target_angle = p1 / p2
			-- local source_angle = p2 / p1

			-- local target1 = hero:get_point()
			-- target1 = target1 + {0,0,100}

            -- -- ac.math_angle(target_angle,self.angle )
			-- if self.on_move_count < 20  then
		
			-- 	local progress
			-- 	local speed = self.speed * 0.03 * self.time_scale
			-- 	if speed >= self.distance then
			-- 		progress = 1
			-- 	else
			-- 		progress = speed / self.distance
			-- 	end
			-- 	local height = 0
			-- 	--线性
			-- 	local target_high = self.target_high
			-- 	if self.target then
			-- 		target_high = target_high + self.target:get_high()
			-- 	end
			-- 	local height_n = (target_high - self.high) * progress
			-- 	--print('height_n', target_high, self.high, progress)
			-- 	self.high = self.high + height_n
			-- 	height = height + height_n
			-- 	self.height_l = self.height_l + height_n

			-- 	-- local progress = (1 - self.moved_progress) * progress
			-- 	self.moved_progress =  progress
				
			-- 	local height_n = 16 * self.height * self.moved_progress * (1 - self.moved_progress  )
			-- 	--height_n = height_n*4
			-- 	print('progress',progress,'moved_progress',self.moved_progress,'height_n',height_n)
				

			-- 	height = height + height_n - self.height_c
			-- 	self.height_c = height_n
			-- 	self.mover:add_high(height)
			-- 	-- local height_n = 4 * self.height * self.moved_progress * (1 - self.moved_progress)
			-- 	-- height = height + height_n - self.height_c
			-- 	-- self.height_c = height_n
			-- 	-- self.mover:add_high(height)
			-- 	-- self.height = self.height + 10

			-- 	self.angle = source_angle
			-- else 
			-- 	if self.on_move_count < 40 then
			-- 		--  self.height =  self.height + 10 
			-- 		self.angle = target_angle
			-- 	end	
			-- end	
			
			
		    -- self.on_move_count = self.on_move_count +1
		end
		function mvr:on_hit()
			
			target:damage
			{
				source = hero,
				damage = damage,
				skill = skill,
				missile = self.mover,
				damage_type = '法术',
				allow_other_skill = true
			}
				
			--return true
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






