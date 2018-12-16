local mt = ac.item['神石']{
    war3_id = 'ID01',
    gold = 1000,
    --最大的可用次数
    max_stack = 100,
    unique = 1,
    tip =[[
        傻逼神石
    ]],
    art = [[ReplaceableTextures\CommandButtons\BTNBlink.blp]],

}

-- function mt:before_add(unit)
--     local p = unit:get_owner()
--     if unit:has_item(self.name) then 
--         p:sendMsg("已经领取了"..self.name.."任务，请不要重复领取")
--         -- unit:remove_item(self)
--         return false
--     end    
--     -- p:sendMsg("已经领取了神石任务，请不要重复领取")
--     return true
-- end    
function mt:on_add()
    local unit = self.owner
    local p = unit:get_owner()
    self.kill_unit_trg = unit:event '单位-杀死单位'(function(trg, killer, killed)
        if self:get_stack() < self.max_stack then
            self:add_stack()
        end
    end)
end

function mt:on_drop()
    if self.kill_unit_trg then
        self.kill_unit_trg:remove()
    end
end