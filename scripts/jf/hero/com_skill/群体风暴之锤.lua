local mt = ac.skill['群体风暴之锤']

mt{
    level = 1,
    max_level = 4,
    requirement = {1,2,3,4},

    art = [[ReplaceableTextures\CommandButtons\BTNStormBolt.blp]],

    title = '群体风暴之锤',

    tip = [[
对目标周围%area%码内的单位扔出一个锤子，造成%damage%点伤害，并眩晕%stun_time%秒。
    ]],

    cost = 30,
    cool = 5,
    target_type = ac.skill.TARGET_TYPE_UNIT,

    range = 1000,

    cast_animation = 'spell throw',
    cast_animation_speed = 1.5,

    --施法前摇
    cast_start_time = 0.3,
    cast_finish_time = 0.5,

    speed = 1200,

    hit_area = 100,

    stun_time = 2,

    --范围
    area = 600,

    damage = function ( self, hero )
        return hero:get_ad() * 2
    end

}

function mt:on_cast_shot(  )
    local hero = self.owner
    local target = self.target
    local damage = self.damage
    local i = 0
    for _,u in ac.selector()
        : in_range(target,self.area)
        : is_enemy(hero)
        : of_not_building()
        : ipairs()
    do
        local mvr = ac.mover.target{
            source = hero,
            start = hero:get_launch_point(),
            skill = self,
            target = u,
            target_high = 50,
            speed = self.speed,
            model = [[Abilities\Spells\Human\StormBolt\StormBoltMissile.mdl]],
            size = 1.2,
            hit_area = self.hit_area,
        }
        if mvr then
            function mvr:on_hit( dest )
                dest:damage{
                    source = hero,
                    damage = damage,
                    skill = self.skill,
                }
                print('dest:',dest,'damage:',damage)
                dest:add_buff '晕眩'{
                    source = hero,
                    time = self.skill.stun_time,
                }
                --print('你真的好？')
            end

            function mvr:on_remove(  )
                print('群体风暴锤 - on_remove')
                self.mover:remove()
            end
        else
            print('居然没有创建投射物？')
        end

        i = i+1
    end
end
