local mt = ac.unit_button['送水任务']{
    war3_id = 'h012',
    tip =[[
去基地下方有水的地方，装满水即可获得奖励。
    ]],
}

function mt:on_click()
    local unit = self.clicker
    unit:add_item('空瓶')
end
