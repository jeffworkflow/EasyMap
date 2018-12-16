
local map = require 'jf.map'
local rect = require 'types.rect'

local mt = ac.unit_button['传送到练功房']{
    war3_id = 'h01I',
}

function mt:on_click()
    local unit = self.clicker
    local p = unit:get_owner()
    local x,y = rect.j_rect('practice'..p.id):get_point():get()
    local point = ac.point(x,y+200)
    
    unit:blink(point,true,false,true)
end




