local mt = ac.skill['山丘之锤']
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

    --弹射范围
    boom_area = 150,
    
    --投射物数量
    count = 4,

    --弹射伤害比
    ejection_damage = 30,

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
    title = '山丘之锤',
    tip = [[标签：投射物
攻击时%my_chance%%几率对%client_count%个单位投射风暴之锤造成伤害，如果风暴之锤击杀了目标，像旁边弹射一次，造成%ejection_damage%%伤害，此伤害击杀不弹射
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
				local mvr = ac.mover.target
				{
					source = hero,
					target = u,
					model = self.model,
					speed = 1500,
					skill = skill,
				}
				if not mvr then
					return
				end
                function mvr:on_finish()
                    
                    u:damage
                    {
                        source = hero,
                        damage = max_damage,
                        skill = skill,
                        missile = self.mover,
                        damage_type = '法术'
                    }
                    
                    --如果目标死亡，进行一次弹射
                    if not u:is_alive() then 
                        local ejection_target = ac.selector():in_range(u,skill.boom_area): is_enemy(hero):is_not(u): of_not_building(): random()
                        
                        local mvr = ac.mover.target
                        {
                            source = u,
                            target = ejection_target,
                            model = self.model,
                            speed = 500,
                            skill = skill,
                        }
                        if not mvr then
                            return
                        end
                        function mvr:on_finish()
                            ejection_target:damage
                            {
                                source = hero,
                                damage = max_damage * skill.ejection_damage/100,
                                skill = skill,
                                missile = self.mover,
                                damage_type = '法术'
                            }
                        end    
						
				    end
			     	
					--return true
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