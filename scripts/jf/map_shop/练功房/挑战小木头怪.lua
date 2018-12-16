
local map = require 'jf.map'
local rect = require 'types.rect'
local creep = require 'jf.creeps.creep'

local mt = ac.unit_button['挑战小木头怪']{
    war3_id = 'h00V',
}

function mt:on_click()
    local unit = self.clicker
    local p = unit:get_owner()
    local ret = 'practice'..p.id

    -- 根据点击玩家 决定 小金币怪的刷新区域
    -- 只需要传入string 就行
    local cep = ac.creep['小木头怪']
    cep:set_region(ret)
    cep:start()
    
end



local mt = ac.creep['小木头怪']{    
    creeps_datas = '[小木头怪]*30',
    cool_count =5,
    is_hero_leave_death = true,
    is_region_replace = true,

}
function mt:on_start()

end
function mt:on_next()

end
function mt:on_finish()

end


