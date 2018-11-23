local mt = ac.skill['雷霆之箭']
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

    --爆炸范围
    boom_area = 150,
    
    --投射物数量
    count = 2,

    --异步下数据 只作为文本提示
    client_area = function(self)
        return 150 + ac.player.self.hero:get '额外范围'
    end,

    --投射物数量
    client_count = function(self)
        return 2 + ac.player.self.hero:get '额外投射物数量'
    end,
    --几率
    my_chance = function (self)
        return 15 + ac.player.self.hero:get '天赋触发几率'
    end,
    --投射物模型
    model = [[Abilities\Spells\Other\BlackArrow\BlackArrowMissile.mdl]],
    title = '雷霆之箭',
    tip = [[标签：投射物 范围
%my_chance%%几率对目标及周围单位发射%client_count%支雷霆之箭，命中目标后产生爆炸对%client_area%范围内单位造成伤害,
伤害计算：敏捷 * 3 + 智力 * 2
伤害类型：法术伤害]],
}


function mt:on_add()
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
        local max_damage = self.current_damage

        local target = damage.target
        --投射物数量
        local count = hero:get '额外投射物数量' + self.count - 1
        local group = ac.selector():in_range(hero,hero:get '攻击距离'):is_enemy(hero):is_not(target):get()
        if group and #group > 0 then
            while #group > count do
                table.remove(group,#group)
            end
        end
        table.insert(group,target)
        
		local unit_mark = {}
        for i,u in ipairs(group) do
            local mvr = ac.mover.target
            {
                source = hero,
                start = hero:get_launch_point(),
                skill = self,
                target = u,
                speed = 1500,
                model = self.model,
                size = 1,
            }
            if mvr then
                function mvr:on_finish()
                    
					if not unit_mark[target] then 
                        ac.effect(u:get_point(),[[AZ_CocoChristmas_D_Impact.mdx]],0,3,'origin'):remove()
                        for _, unit in ac.selector():in_range(u,self.boom_area):is_enemy(hero):ipairs() do
                            -- print(u.name,u.handle)
                            u:damage
                            {
                                source = hero,
                                skill = self,
                                damage = max_damage,
                                damage_type = '法术', 
                                missile = self.mover,
                            }
                        end
                        
						unit_mark[target] = true
                    end    
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