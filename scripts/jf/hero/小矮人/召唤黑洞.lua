local mt = ac.skill['万箭齐发']
mt{
    --等级
    level = 0,

    --是被动
    passive = true,

    --原始伤害
    damage = function(self,hero)
        return hero:get '智力' * 2 + hero:get '敏捷' * 3 +400
    end,

    --释放几率
    chance = function (self,hero)
        return 85 + hero:get '天赋触发几率'
    end,

    --暗影之箭范围
    area = 800,
    
    --数量
    count = 10,
    
    --投射物碰撞距离
    hit_area = 100,
    
    --主伤害比
    main_damage = 30,

    --异步下数据 只作为文本提示
    client_area = function(self)
        return 150 + ac.player.self.hero:get '额外范围'
    end,

    --几率
    my_chance = function (self)
        return 15 + ac.player.self.hero:get '天赋触发几率'
    end,
    --投射物模型
    model = [[cosmic field_65.mdx]],
    --爆炸模型
    boom_model = [[anyingzhijing.mdx]],
    -- boom_model = [[boom.mdx]],
    title = '万箭齐发',
    tip = [[标签：投射物
攻击时%my_chance%%几率丢出%count%个从天而降的暗影之箭，击中目标时，对目标及%client_area%范围的敌人造成%main_damage%%伤害
伤害计算：敏捷 * 3 + 智力 * 2
伤害类型：法术伤害]],
}


function mt:on_add()
    local skill = self
    local hero = self.owner
    --记录默认攻击方式
    if not hero.oldfunc then
        hero.oldfunc = hero.range_attack_start
    end

    --新的攻击方式
    local function range_attack_start(hero,damage)
        if damage.skill and damage.skill.name == self.name then
            return
        end

        local target = damage.target
        local max_damage = self.current_damage
        --投射物数量
        -- local count = hero:get '额外投射物数量' + self.count 
        --范围
        local hit_area = hero:get '额外范围' + self.hit_area 
       
        local unit_mark = {}
        

        for i = 1,skill.count do 

            local random_time = math.random(1, 400)
		    hero:timer(random_time, 1, function(t)
                local angle = math.random(1, 360)
                local s = target:get_point() - {angle, math.random(1, skill.area)}

                local angle1 = math.random(1, 360)
                local t = s - {angle1, 150}
                -- local p = ac.point(0,0)

                -- local u = hero:create_dummy('nabc',p,0)
                local mover = hero:create_dummy('nabc',s, 0)
                --落下箭矢
                local mvr = ac.mover.target
                {
                    source = hero,
                    mover = mover,
                    start = s,
                    target = t,
                    -- angle = angle,
                    speed = 600,
                    turn_speed =720,
                    high = 1500,
                    heigh = 1500,
                    skill = skill,
                    model = skill.model,
                    size = 1.3
                }
                if mvr then
                    function mvr:on_move()
                        
                        if self.high <= 50 then
                            self.mover:get_point():add_effect(skill.boom_model):remove()
                            self.mover:remove()
                            self:remove()

                            for i,u in ac.selector()
                            : in_range(self.mover:get_point(),hit_area)
                            : is_enemy(hero)
                            : of_not_building()
                            : ipairs()
                            do
                                u:damage
                                {
                                    source = hero,
                                    damage = max_damage * skill.main_damage / 100,
                                    skill = skill,
                                    missile = self.mover,
                                    damage_type = '法术'
                                }
                            end
                        end

                    end 
                end    
            end   );

        end


      --还原默认攻击方式
      hero.range_attack_start = hero.oldfunc
    end    

    self.trg = hero:event '单位-发动攻击' (function(_, damage)
        --触发时修改攻击方式
        if math.random(100) <= self.chance then
            self = self:create_cast()
            --当前伤害要在回调前初始化
            self.current_damage = self.damage
            hero:event_notify('触发天赋技能', self)
            hero.range_attack_start = range_attack_start
            
        end 

        return false
    end)

end



function mt:on_remove()
    local hero = self.owner
    hero.range_attack_start = hero.oldfunc
    self.trg:remove()
end