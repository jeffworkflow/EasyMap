local mt = ac.skill['山丘的大锤子']
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

    --移动距离
    move_distance = 200,
    max_distance = 1000,
    
    --投射物数量
    count = 1,
    
    --碰撞范围
    hit_area = 300,

    --主伤害伤害比
    main_damage = 120,

    --主伤害伤害比
    second_damage = 20,

    --异步下数据 只作为文本提示
    client_area = function(self)
        return 150 + ac.player.self.hero:get '额外范围'
    end,

    --投射物数量
    client_count = function(self)
        return 4 + ac.player.self.hero:get '额外投射物数量'
    end,
    --几率
    my_chance = function (self)
        return 15 + ac.player.self.hero:get '天赋触发几率'
    end,
    --投射物模型
    model = [[Abilities\Spells\Other\BlackArrow\BlackArrowMissile.mdl]],
    title = '山丘的大锤子',
    tip = [[标签：投射物
攻击时%my_chance%%几率丢出%client_count%个超大的风暴之锤,对碰撞单位造成%main_damage%%伤害，每移动 %move_distance% 距离就会释放一次雷霆一击,造成%second_damage%%伤害,风暴之锤移动%max_distance%距离。
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
        local count = hero:get '额外投射物数量' + self.count 
       
		local unit_mark = {}

		for i,u in ac.selector()
			: in_range(hero,hero:get('攻击距离'))
			: is_enemy(hero)
			: of_not_building()
			: sort_nearest_hero(hero) --优先选择距离英雄最近的敌人。
			: set_sort_first(target)
			: ipairs()
     	do
			if i <= count then
				local mvr = ac.mover.line
				{
                    source = hero,
                    model = skill.model,
                    speed = 800,
                    angle = hero:get_point()/u:get_point(),
                    distance = skill.max_distance,
                    high = 10,
                    skill = skill,
                    size = 3,
                    model=[[Abilities\Spells\Human\StormBolt\StormBoltMissile.mdl]],
                    hit_area = skill.hit_area,
                    hit_type = ac.mover.HIT_TYPE_ENEMY,
                    per_moved = 0
				}
				if not mvr then
					return
                end
                local hit_unit ={}
                function mvr:on_move()
                    self.per_moved = self.per_moved + self.speed * 0.03
                    -- print(self.per_moved,skill.move_distance)
                    if self.per_moved >= skill.move_distance then 
                        self.per_moved = 0
                        
                        ac.effect(self.mover:get_point(),[[Abilities\Spells\Human\Thunderclap\ThunderClapCaster.mdl]],0,1,'origin'):remove();

                        for i,u in ac.selector()
                            : in_range(self.mover,150)
                            : is_enemy(hero)
                            : of_not_building()
                            : ipairs()
                        do
                            if not hit_unit[u]  then
                                u:damage
                                {
                                    source = hero,
                                    damage = max_damage * skill.second_damage/100,
                                    skill = skill,
                                    missile = self.mover,
                                    damage_type = '法术'
                                }
                                hit_unit[u] = true
                            end
                        end    

                    end
                end    
                function mvr:on_hit(dest)
                    
                    dest:damage
                    {
                        source = hero,
                        damage = max_damage * skill.main_damage /100,
                        skill = skill,
                        missile = self.mover,
                        damage_type = '法术'
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