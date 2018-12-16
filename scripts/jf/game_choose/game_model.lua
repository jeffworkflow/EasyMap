local table_insert = table.insert

local Map_rects = require 'types.rect'

local Game_model = {}
setmetatable(Game_model, Game_model)

ac.game_model = Game_model

local mt = {}
Game_model.__index = mt

setmetatable(mt, {
    __newindex = function ( t, k, v )
        if type(v) == 'table' and v.action then
            setmetatable(v, v)
            v.__index = Game_model
        end
        rawset(t, k, v)
    end
})


--修改普通回合的进攻算法为加强型的生存模式
function mt:strengthen_normal_invade_pattern()
    local Normal_round = Map_game.normal_round
    local normal_round_default_invade_pattern = Normal_round.get_attack_target
    self.normal_round_default_invade_pattern = normal_round_default_invade_pattern
    local rct = Map_rects['战斗区域']

    local new_invade_pattern = function(self, u)
        local heros = {}
        for _, u in ac.selector()
            :in_range(ac.point(0, 0), 9999)
            :add_filter(function(u)
                if not (rct < u) then
                    return
                end
                if u:is_hero() then
                    return true
                end
            end)
            :ipairs()
        do
            table_insert(heros, u)
        end
        local hero
        if #heros == 0 then
            hero = normal_round_default_invade_pattern(self, u)
        else
            local dis
            for i = 1, #heros do
                local temp = u:get_point() * heros[i]
                if not dis then
                    dis = temp
                    hero = heros[i]
                end
                if temp < dis then
                    hero = heros[i]
                end
            end
        end
        if not hero then
            ac.player.self:sendMsg(('怪物%s无法找到进攻的英雄，陷入发狂状态！'):format(u:get_name()))
            u:add_buff('进攻怪-发狂'){
                time = 20,
                skill = true,
            }
        end
        return hero
    end
    Normal_round.get_attack_target = new_invade_pattern

end

--修改普通回合进攻算法为防守模式
function mt:use_normal_defense_invade_pattern()
    local Normal_round = Map_game.normal_round
    local normal_round_default_invade_pattern = Normal_round.get_attack_target
    self.normal_round_default_invade_pattern = normal_round_default_invade_pattern

    local new_invade_pattern = function(self, u)
        
    end
    Normal_round.get_attack_target = new_invade_pattern
end


mt['生存模式'] = {
    msg = [[
        |cffff0000生存模式|r：
        回合内死亡不会复活，直到新的回合开始
    ]],
    action = function(self, player)
        print(player, '点击了 生存模式')
        ac.player.self:sendMsg(self.msg, 20)
        local degree = ac.game_degree
        local lv = degree:get_game_degree().level
        --难度一以上，修改怪物进攻算法
        if lv > 1 then
            -- self:strengthen_normal_invade_pattern()
        end
        
    end
}

mt['防守模式'] = {
    msg = [[
        |cffff0000防守模式|r：
        玩家需要守护中心区域的基地
        进攻怪会直接对建筑发起进攻
    ]],
    action = function(self, player)
        print(player, '点击了 防守模式')
        ac.player.self:sendMsg(self.msg, 20)
    end
}

mt['生存+防守模式'] = {
    msg = [[
        |cffff0000生存+防守模式|r：
        年轻？？？
    ]],
    action = function(self, player)
        print(player, '点击了 生存+防守模式')
        ac.player.self:sendMsg(self.msg, 30)
end
}

local buf = ac.buff['进攻怪发狂']

buf.move_speed_rate = 50
buf.effect_model = [[Abilities\Spells\Orc\Bloodlust\BloodlustSpecial.mdl]]
buf.size = 0.5


function buf:on_add()
    local unit = self.target
    self.ef1 = unit:add_effect(self.effect_model, 'hand left')
    self.ef2 = unit:add_effect(self.effect_model, 'hand right')
    self.move_speed = unit:add_move_speed(0, self.move_speed_rate)
    unit:add_size(self.size)
end

function buf:on_remove()
    if self.ef1 then
        self.ef1:remove()
    end
    if self.ef2 then
        self.ef2:remove()
    end
    local unit = self.target
    if unit:is_alive() or unit:is_hero() and not unit:is_remove() then
        unit:add_move_speed(-self.move_speed)
        unit:add_size(-self.size)
    end
end

return Game_model