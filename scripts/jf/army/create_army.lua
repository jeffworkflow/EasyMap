
local map = require 'jf.map'
local army_datas = require 'jf.army.army_datas'
local player = require 'ac.player'
local timerdialog = require 'types.timerdialog'
local rect = require 'types.rect'
local fogmodifier = require 'types.fogmodifier'

local army = {}
setmetatable(army, army)

local mt = {}
army.__index = mt

map.army = army

--类型
mt.type = '普通回合'

--附加的类型
mt.additive_type = '防守模式'

--波数
mt.index = 0

--最大波数数量，默认36回合
mt._max_number = 36

--回合状态，四种状态，创建、准备、开始、结束
mt.state = nil

--计时器窗口
mt.timerdialog = nil

function mt:init()

    if not self.timerdialog then
        self.timerdialog = timerdialog:new()
            :set_title_color(255, 0, 0)
            :set_bg_color()
    end
    self.index = 0
    local tower_data = army_datas:get_guarded_tower()
    self.tower_data = tower_data

    --全地图找预设 主城 建筑。
    local group = ac.selector():allow_god():get()
    for _, u in ipairs(group) do
        if u:get_name() == tower_data.name then
            self.main_tower = u
            break;
        end    
    end    
    map.main_tower = self.main_tower
    -- print(self.timerdialog)
    self:create()

end

function mt:create()
    self.state = '创建'
    self.index = self.index + 1
    self.creep_datas = army_datas:get_datas_by_index( self.index )
    self:prepare()
end

function mt:prepare()
    self.state = '预备'
    --生存模式的清怪时间为防守模式的准备时间
    local prepare_time = self.creep_datas.prepare_time 
    self.timerdialog:set_time(5 or prepare_time)
        :set_title(('第%s回合出兵：'):format(self.index))
        :set_title_color(255, 0, 0)
        :set_on_expire_listener(function (  )
            self.timerdialog:show(false)
            self:start()
        end)
        :show()
        :run()

end

--回合开始，发布相关信息
function mt:show_start_round_msg(  )
    local datas = self.creep_datas
    player.self:sendMsg('[敌人进攻]：' .. datas.msg, 5)
end


--进攻单位获取进攻目标
function mt:get_attack_target(u)
    return self.main_tower:get_point()
end

--创建一个进攻单位
function mt:create_attack_unit(point)
    local name = self.creep_datas.name

    local u = player.com[2]:create_unit(name, point, math.random(0,360))
    u.reward_money = self.creep_datas.reward_money
    u.reward_xp = self.creep_datas.reward_xp
    u.fall_item = self.creep_datas.fall_item

    local target = self:get_attack_target(u)
    if not target then
        target = u:get_point()
    end
    u:issue_order('attack', target)
end

--出现时的特效
mt.invade_effect_model = [[Doodads\Cinematic\ShimmeringPortal\ShimmeringPortal.mdl]]
--创建一个进攻单位的时间间隔
mt.invade_gap_time = 0.1

--发兵
function mt:create_invades()
    local datas = self.creep_datas
    local numbers = datas.count

   --区域不支持中文
    local creep_birth_rects ={}
    table.insert(creep_birth_rects,rect.j_rect 'attack')

    -- print(rect.j_rect 'outtown':get())
    for i =1 , 10 do
        fogmodifier.create(player[i], creep_birth_rects[1])
    end    
 
    local birth_rect_count = #creep_birth_rects
    local number_1 = math.floor(numbers / birth_rect_count )
    local number_2 = numbers - number_1 * birth_rect_count
    
    -- print(birth_rect_count)
    for i = 1, birth_rect_count do
      
        local number = number_1
        if i == 1 then
            number = number + number_2
        end
        local rct = creep_birth_rects[i]
        local ef = rct:get_point():add_effect(self.focus_effect_model)
        local index = 0
        ac.loop(self.invade_gap_time * 1000, function ( t )
            self:create_attack_unit( rct:get_point() )

            index = index + 1
            if index == number then
                t:remove()
                ef:remove()
                if i == 1 then
                    --创建完所有的进攻怪物了，进入回合下一阶段
                    -- 清怪时间+准备时间为每波间隔时长。
                    local time = self.creep_datas.clear_time
                    self.timerdialog:set_time(time or 10  )
                            :set_title('回合结束：')
                            :set_title_color(255, 0, 0)
                            :set_on_expire_listener(function (  )
                                self:finish()
                            end)
                            :show()
                            :run()
                end
            end
        end)
    end
end

function mt:start()
    self.state = '开始'
    self:show_start_round_msg()
    self:create_invades()
end

function mt:finish(is_reward)
    self.state = '结束'
    self.timerdialog:pause()
    self.timerdialog:show(false)

    --回合结束，如果 返回真，停止下回合。 
    if not ac.game:event_dispatch( '回合-结束', self) then
        -- 下一波存在 则 开启下一回合
        if  army_datas:get_datas_by_index( self.index +1 ) then
           self:create()
        end
    end    
    
end


return army