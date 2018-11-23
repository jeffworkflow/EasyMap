local mt = ac.unit_button['山神任务']{
    war3_id = 'ANcl',
}

function mt:on_click()
    local unit = self.clicker
    
    local trg = unit:event '单位-杀死单位'(function(trg, killer, killed)
        
		unit:add_item('神石')
        
    end)

end
