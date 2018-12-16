
local map = require 'jf.map'
local rect = require 'types.rect'

map.rects['challenge2'] = rect.j_rect('challenge2')

local mt = ac.unit_button['新手boss']{
    war3_id = 'h014',
}

function mt:on_click()
    local unit = self.clicker
    local x,y = map.rects['challenge2']:get_point():get()
    local point = ac.point(x,y-600)
    
    unit:blink(point,true,false,true)
    ac.creep['新手boss']:start()
end



local mt = ac.creep['新手boss']{    
    region = 'challenge2',
    creeps_datas = '[挑战新手boss]*1',
    cool =5,
    is_hero_leave_death = true,

}
function mt:on_start()

end
function mt:on_next()

end
function mt:on_finish()

end


