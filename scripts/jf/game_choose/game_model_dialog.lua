local Dialog = require 'types.dialog'
local Player = require 'ac.player'
local Game_degree = require 'jf.game_choose.game_degree'
local Game_model = require 'jf.game_choose.game_model'

local degree_dialog, model_dialog

local function choose_degree(degree, player)
    player:sendMsg(('%s 选择了 %s 难度'):format(player:get_name(), degree), 10)
    Game_degree[degree]:action(player)
end

local function choose_model(model, player)
    player:sendMsg(('%s 选择了 %s 模式'):format(player:get_name(), model), 10)
    Game_model[model]:action(player)
end

local function close_dialog(dialog)
    if dialog and dialog.type == 'dialog' then
        dialog:remove()
    end
end

local function open_model_dialog(player)
    local dialog = Dialog:new(model_dialog)
    dialog:show(player)
        :set_life(120)
        :run()
    return dialog
end

local function end_choose_game_model()
    ac.game:event_notify('游戏-开始选择英雄')
    ac.game:event_notify('游戏-开始')
end


degree_dialog = {

    title = '请选择游戏难度',

    buttons = {
        [1] = {
            title = '小白过家家级',
            key = nil,
            on_click = function(dialog, player)
                print(player, '点击了 小白过家家级 难度')
                choose_degree('小白过家家级', player)
                choose_model('生存模式', player)
                close_dialog(dialog)
                end_choose_game_model()
            end,
        },
        [2] = {
            title = '老鸟各自飞级',
            key = nil,
            on_click = function(dialog, player)
                print(player, '点击了 老鸟各自飞级 难度')
                choose_degree('老鸟各自飞级', player)
                close_dialog(dialog)
                local model_dialog = open_model_dialog(player)
            end,
        },
        [3] = {
            title = '老鸟劝退级',
            key = nil,
            on_click = function(dialog, player)
                print(player, '点击了 老鸟劝退级 难度')
                choose_degree('老鸟劝退级', player)
                close_dialog(dialog)
                local model_dialog = open_model_dialog(player)
                model_dialog:add_button(model_dialog.hide_button)
                model_dialog:refresh()
            end,
        },
    },

}

model_dialog = {

    title = '请选择游戏模式',

    buttons = {
        [1] = {
            title = '生存模式',
            key = nil,
            on_click = function(dialog, player)
                choose_model('生存模式', player)
                close_dialog(dialog)
                end_choose_game_model()
            end,
        },
        [2] = {
            title = '防守模式',
            key = nil,
            on_click = function(dialog, player)
                choose_model('防守模式', player)
                close_dialog(dialog)
                end_choose_game_model()
            end,
        },
    },

    hide_button = {
        title = '生存+防守模式',
        key = nil,
        on_click = function(dialog, player)
            choose_model('生存+防守模式', player)
            close_dialog(dialog)
            end_choose_game_model()
        end,
    },

}

local function open_degree_dialog(player)
    local dialog = Dialog:new(degree_dialog)
    dialog:show(player)
        :set_life(120)
        :run()
end

local function init()
    local player
    for _, p in pairs(Player.force[1]) do
        if p:is_player() then
            player = p
            break
        end
    end
    open_degree_dialog(player)
end

ac.game:event '游戏-选择难度'(function()
    print('游戏-选择难度')
    init()
end)
