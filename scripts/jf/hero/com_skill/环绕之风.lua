
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
		攻击有%chance%%几率触发天赋技能，创建%max_stack%个龙卷风围绕旋转，对碰到单位造成%value%伤害，同时每个龙卷风提供%red_damage%%的减伤比,持续%time%s.结束时，龙卷风将向四面八方冲出去并造成%value%伤害，%stun_time%秒晕眩,cd %cool%s
        
        ]],
	
	-- cd
	cool = {10,5,5},
	-- 几率
	chance = {100,20,30},
	--最大个数
	max_stack = {3,4,4},
	--伤害值
    value = {50,50,50},

	--晕眩时间
    stun_time = {1,2,3},
    
    -- 减伤比
    red_damage = 20,
	
	--持续时间
    time = {3.2,10,15},

	--持续时间
    distance = {1000,1200,1500},

    --跟随物 碰击 范围
    hit_area = function(self,hero)
        return 100 + hero:get('额外范围')
    end ,
    -- 跟随物模型
    follow_model = [[AZ_Goods_Eul's Scepter of Divinity(3).MDX]],
    folow_model_size = 0.8,
    follow_move_skip = 10,

}

-- 被动
mt.passive = true



function mt:on_add()
	local skill = self
	local hero = self.owner
    self.movers = {}
    -- hero:add('额外范围',50)
    -- print(hero:get('额外范围'))
    -- print(self.hit_area)
    
    -- hero:add('攻击',1000)
    -- print(self.damage_plus)

    local function range_attack_start(hero, damage)
	
        -- print(self.damage_plus)
        if damage.skill and damage.skill.name == self.name then
            return
        end
        local target = damage.target
        local damage = damage.damage
        local movers = self.movers
    
        local angle = 0
    
        for i = 1, self.max_stack do
    
            local mvr = hero:follow{
                source = hero,
                model = self.follow_model,
                distance = 200,
                skill = self,
                angle_speed = 90,
                on_move_skip = self.follow_move_skip,
                angle = angle,
                size = self.folow_model_size,
            }
        
            if not mvr then
                return
            end
            local unit_mark = {}
    
            function mvr:on_move()

                for _, unit in ac.selector()
                    : in_range(self.mover, skill.hit_area)
                    : is_enemy(hero)
                    : ipairs()
                do  
                    if not unit_mark[unit]  then
                        unit:damage
                        {
                            source = hero,
                            skill = skill,
                            damage = skill.value 
                        }
                        unit_mark[unit] = true
                    end    
    
                end
            end
        
            angle = angle +  360 / self.max_stack

            self.movers[i] = mvr
            -- movers[self.skill:get_stack()] = mvr
        end
    
    
        hero.range_attack_start = self.oldfunc
    
    end
    
	self.oldfunc = hero.range_attack_start

	self.event = hero:event '单位-攻击出手' (function(trg, data)
       
		if self:is_cooling() then
			return
		end
		
		if math.random(1,100) > self.chance then
			return
        end

		if self:get_stack() >= self.max_stack then
			return
        end
        --修改攻击方式。
        hero.range_attack_start = range_attack_start

        --激活cd
        self:active_cd()

        --增加减伤buff 
        hero:add_buff(filename)
		{
			skill = skill,
			time =  skill.time,
			red_damage = skill.red_damage
        }

        --时间到时，扩散出去。 self.time
        ac.wait(self.time*1000, function() 
            print(self.movers)
            for _, mvr in ipairs(self.movers) do
                -- local angle = mvr:get_point() / hero:get_point();
            --    print( mvr.mover,mvr.angle,skill.distance,skill.hit_area)
               local mover = mvr.mover
               local angle = mvr.angle
              
               mvr.mover:setAlpha(0)
               mvr:remove()
               --    table.remove(self.movers,_)
               
               local new_mvr = ac.mover.line
                {
                    model = self.follow_model,
                    source = mover,
                    angle = angle,
                    speed = 800,
                    distance = skill.distance,
                    skill = skill,
                    hit_area = skill.hit_area,
                    size = self.folow_model_size,
                }
                if not new_mvr then
                    print("没有创建投射物？")
                    return
                end
                function new_mvr:on_move()
                    -- print("移动中",self.size)
                    -- -- -- if self.size <=1 then 
                    --   self.size = self.size + 1
                      self.angle = self.angle + 5
                    -- end  
                end    
                -- print("创建投射物成功，",new_mvr.mover:get_point())
                -- print("创建投射物成功，",new_mvr.mover._effect_list)
                function new_mvr:on_hit(dest)
                 
                    dest:damage
                    {
                        source = hero,
                        damage = skill.value ,
                        skill = skill,
                    }
                    dest:add_buff '晕眩'
                    {
                        source = hero,
                        time = skill.stun_time,
                    }
                    
                end
                
                -- mvr:remove()

            end
        end)
        
        

	end)


end

function mt:on_remove()
	self.event:remove();
end


local mt = ac.buff[filename]

mt.cover_type = 1

mt.effect = nil

function mt:on_add()
    
    -- self.skill:add_stack(1)
    self.target:add('减伤比', self.red_damage)
	
end

function mt:on_remove()
    
	-- self.skill:add_stack(-1)
    self.target:add('减伤比', - self.red_damage)

end



