

local mt = ac.item['新手戒指']{
    war3_id = 'I00D',
    gold = 1,
    unique = 1,
    life = 1000,
    tip =[[
新手用的戒指，生命 + %life%
    ]],
    -- art = [[ReplaceableTextures\CommandButtons\BTNBlink.blp]],

}

function mt:before_add(unit)
    local p = unit:get_owner()
    if unit:has_item(self.name) then 
        p:sendMsg("已经有了"..self.name.."，不可重复")
        -- unit:remove_item(self)
        return false
    end    
    return true
end    
