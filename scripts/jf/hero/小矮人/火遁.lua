local mt = ac.skill['火遁']
mt{
    --等级
    level = 1,

    --是被动
    passive = true,

    --原始伤害
    damage = function(self,hero)
        return hero:get '智力' * 2 + hero:get '敏捷' * 3
    end,

    --释放几率
    chance = function (self,hero)
        return 85 + hero:get '天赋触发几率'
    end,

    --喷火范围
    hit_area = 250,
    
    
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
    model = [[Abilities\Spells\Other\BreathOfFire\BreathOfFireMissile.mdl]],
    --爆炸模型
    boom_model = [[K_WJQF.mdx]],
    title = '火遁',
    tip = [[标签：范围
攻击时%my_chance%%朝前方喷射火焰，对角度范围%hit_area%的敌人造成%main_damage%%伤害
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
       
        local mvr = ac.mover.line{
            start = (hero:get_point() - {hero:get_facing(), 80}),
            angle = hero:get_facing(),
            distance = 800,
            model = skill.model,
            speed = 1200,
            height = 50 + hero:get_high() / 3,
            skill = skill,
        }
        if mvr then
            local skill = self
            local g = {}
            function mvr:on_move()
                local p = self.mover:get_point()
                for _, u in ac.selector()
                :in_sector(p, skill.hit_area, hero:get_facing(), 120)
                :add_filter(function(u)
                    return not g[u]
                end)
                :is_enemy(hero)
                :ipairs()
                do
                    g[u] = true
                    u:damage{
                        source = hero,
                        target = u,
                        damage = max_damage * skill.main_damage/100,
                        skill = skill,
                        damage_type = '法术',
                    }
                end
            end
    
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