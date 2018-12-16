local Game_degree = {}
setmetatable(Game_degree, Game_degree)

ac.game_degree = Game_degree

local mt = {}
Game_degree.__index = mt

setmetatable(mt, {
    __newindex = function ( t, k, v )
        if type(v) == 'table' and v.action then
            setmetatable(v, v)
            v.__index = Game_degree
        end
        rawset(t, k, v)
    end
})

--设置普通回合最大波数
function mt:set_round_number(n)
    local round = require 'rule.round.normal_round.normal_round_exist'
    round:set_max_round_number(n)
end

--获取进攻怪的玩家
function mt:get_invade_creep_player()
    if not self.invade_creep_player then
        self.invade_creep_player = ac.player.force[1][1]:get_invade_creep_player()
    end
    return self.invade_creep_player
end

function mt:show_degree_msg(msg, time)
    ac.player.self:sendMsg(msg, time)
end

--设置物编科技等级
function mt:set_research_level(id)
    local player = self:get_invade_creep_player()
    player:set_research_level(id, 1)
end

--增加进攻野怪的难度攻击力
--  百分比
function mt:add_invade_creep_attack(atk_rate)
    local player = self:get_invade_creep_player()
    self.invade_creep_attack_trg = player:event '单位-创建'(function(trg, unit)
        local atk = unit:get_attack() * atk_rate / 100
        unit:add_add_attack(atk)
    end)
end

--增加进攻野怪的防御
--  百分比
function mt:add_invade_creep_defence(def_rate)
    local player = self:get_invade_creep_player()
    self.invade_creep_defence_trg = player:event '单位-创建'(function(trg, unit)
        local def = unit:get_defence() * def_rate / 100
        unit:add_add_defence(def)
    end)
end

--获取当前的难度
function mt:get_game_degree()
    return self._game_degree
end

--设置当前的难度
function mt:set_game_degree(degree)
    self._game_degree = degree
end


mt['小白过家家级'] = {
    msg = [[
        |cffff0000小白过家家难度|r：
        地图敌对怪物不会变异
        生存30波后会迎来最终回合
        无特殊怪物进攻
    ]],
    level = 1,
    action = function(self, player)
        print(player, '点击了 小白过家家级 难度')
        Game_degree:set_game_degree(self)
        self:show_degree_msg(self.msg, 20)

        -- self:set_round_number(30)
    end

}

mt['老鸟各自飞级'] = {
    msg = [[
        |cffff0000老鸟各自飞难度|r：
        可以选择 生存 | 防守 | 生存+防守模式
        地图敌对怪物会变异
        36波后，迎来最终回合
        小概率触发特殊怪物进攻
    ]],
    level = 2,
    research_id = 'R101',
    attack_rate = 30,
    action = function(self, player)
        print(player, '点击了 老鸟各自飞级 难度')
        Game_degree:set_game_degree(self)
        self:show_degree_msg(self.msg, 20)

        -- self:set_round_number(30)
        
        -- self:set_research_level(self.research_id)
        -- self:add_invade_creep_attack(self.attack_rate)
    end
}

mt['老鸟劝退级'] = {
    msg = [[
            |cffff0000老鸟劝退飞难度|r：
            可以选择 生存 | 防守 | 生存+防守模式
            地图敌对怪物会大幅变异
            36波后，迎来最终回合
            概率触发特殊怪物进攻
            触发游戏彩蛋
    ]],
    level = 3,
    research_id = 'R102',
    attack_rate = 50,
    defence_rate = 20,
    action = function(self, player)
        print(player, '点击了 老鸟劝退级 难度')
        Game_degree:set_game_degree(self)
        self:show_degree_msg(self.msg, 30)

        -- self:set_round_number(30)

        -- self:set_research_level(self.research_id)
        -- self:add_invade_creep_attack(self.attack_rate)
        -- self:add_invade_creep_defence(self.defence_rate)
    end
}


return Game_degree