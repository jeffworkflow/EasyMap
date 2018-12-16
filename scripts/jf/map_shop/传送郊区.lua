local map = require 'jf.map'

local mt = ac.unit_button['传送郊区']{
    war3_id = 'h013',
    tip =[[
传送到郊区，可快速取水或打小怪
    ]],
}

function mt:on_click()
    local unit = self.clicker
    unit:blink(map.rects['郊区'],true,false,true)

end
