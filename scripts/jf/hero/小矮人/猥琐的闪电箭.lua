local jass = require("jass.common")

local mt = ac.skill['猥琐的闪电箭']
mt{
    --等级
    level = 1,
    --是被动
    passive = true,

    --原始伤害
    damage = function(self,hero)
        return hero:get '智力' * 5
    end,

	--弹道速度
	speed = 1200,

	--飞行距离
	distance = 10000,

    --投射物数量
    count = function(self,hero)
        return hero:get '额外投射物数量' + 3
    end,

    --弹射次数
    number = 10,

	--自由碰撞时的碰撞半径
	hit_area = 100,

    --释放几率
    chance = function (self,hero)
        return 100 + hero:get '天赋触发几率'
    end,

    --投射物模型
    -- model = [[ColdArrowMissile.mdx]],
    model = [[StarDust.mdx]],
    title = '猥琐的闪电箭',
    tip = [[标签：投射物 范围
    伤害计算：智力*5
伤害类型：法术伤害]],
}


--计算折射角度
local function Reflectionangles(X,Y,distance,angle)
    local per_distance = 32
    while  per_distance <= per_distance 
    do
        local  x = X + per_distance * jass.Cos( angle * jass.bj_DEGTORAD ) 
        local  y = Y + per_distance * jass.Sin( angle * jass.bj_DEGTORAD ) 
    
        if jass.IsTerrainPathable(x, y,jass.PATHING_TYPE_WALKABILITY) then
            if ( jass.IsTerrainPathable( X + per_distance * jass.Cos( (180.00 - angle) * jass.bj_DEGTORAD ),
            Y + per_distance * jass.Sin( (180.00 - angle) * jass.bj_DEGTORAD ),jass.PATHING_TYPE_WALKABILITY) ) then

                angle = 360.00 - angle 

                return angle

            elseif ( jass.IsTerrainPathable( X + per_distance * jass.Cos( (360.00 - angle)*jass.bj_DEGTORAD ),
            Y + per_distance * jass.Sin( (360.00 - angle) * jass.bj_DEGTORAD ), jass.PATHING_TYPE_WALKABILITY) ) then
                
                angle = 180.00 - angle 
                return angle

            end
            
        end
        per_distance = per_distance + 32
    end    

    return angle  + 180.00 
end


local function create_mover(angle,skill,mover)

            --创建弹幕
            local mvr = ac.mover.line
            {
                source = skill.owner,
                start  = mover:get_point(),
                high = 110,
                height = 110,
                model = skill.model,
                speed = skill.speed,
                angle = angle,
                distance = skill.distance,
                skill = skill,
                hit_area = skill.hit_area,
                block = true,
    
            }
            if not mvr then
                return
            end

        --如果碰撞到了地形
        function mvr:on_block()
            local mover = mvr.mover
            local x,y = mover:get_point():get()
            local angle = Reflectionangles(x,y,32,angle)
            
            create_mover(angle,skill,mover)
            return true
        end

end



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
        --计算伤害
        local max_damage = self.current_damage

        local target = damage.target:get_point()
        local angle = hero:get_point() / target

        for i = 1,self.count do
            local angle = angle + (self.count / 2 - self.count - 0.5 + i) * 17.5
            --创建弹幕
            create_mover(angle,self,hero)
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
            --修改攻击方式
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