local table_insert = table.insert

local mt = ac.skill['元素守护']

mt{
    follow_model = [[units\human\Knight\Knight.mdl]],
    folow_model_size = 2.5,
    follow_move_skip = 5,
    attack_model = [[Abilities\Spells\Human\ManaFlare\ManaFlareTarget.mdl]],
    attack_model_size = 1.0,
    time = 10,
    tip = [[
        asdasd
    ]],
}

function mt:on_cast_shot()
    local skill = self
    local unit = self.owner
    local ang = 0
    local movers = {}
    for i = 1, 3 do
        local mvr = unit:follow{
            source = unit,
            model = self.follow_model,
            distance = 200,
            high = 50,
            skill = self,
            angle_speed = 180,
            on_move_skip = self.follow_move_skip,
            angle = ang,
            size = self.folow_model_size,
        }
        table_insert(movers, mvr)
        ang = ang + 120

        function mvr:on_move()
            local point = self.mover:get_point()
            for _, u in ac.selector()
                :in_range(point, 500)
                :is_enemy(unit)
                :ipairs()
            do
                local mvr_tg = ac.mover.target{
                    source = unit,
                    start = point,
                    target = u,
                    model = skill.attack_model,
                    high = 80,
                    speed = 300,
                    skill = skill,
                }
                function mvr_tg:on_finish()
                    u:damage{
                        source = unit,
                        skill = self.skill,
                        damage_type = '魔法',
                        damage = 10,
                    }
                end 
                break
            end
        end
    end
    
    ac.wait(self.time*1000, function()
        for _, mvr in ipairs(movers)do
            mvr:remove()
        end
    end)
end