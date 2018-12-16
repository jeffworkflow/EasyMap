

local mt = ac.item['新手甲']{
    war3_id = 'I000',
    gold = 1,
    unique = 1,
    defence = 100,
    tip =[[
新手用的甲，防御 + %defence%
    ]],
    -- art = [[ReplaceableTextures\CommandButtons\BTNBlink.blp]],

}

function mt:before_add(unit)
    local p = unit:get_owner()
    if unit:has_item(self.name) then 
        p:sendMsg("已经有了|cffFCD830"..self.name.."|r，不可重复")
        -- unit:remove_item(self)
        return false
    end    
    return true
end    
