
local rect = require 'types.rect'
local region = require 'types.region'

local mt = ac.item['空瓶']{
    war3_id = 'I00K',
    gold = 1,
    unique = 1,
    tip =[[
空的瓶子，去基地下方有水的地方，装满水即可获得奖励。
    ]],
    -- art = [[ReplaceableTextures\CommandButtons\BTNBlink.blp]],

}

function mt:before_add(unit)
    local p = unit:get_owner()
    p:pingMinimap(rect.j_rect 'getwater',1)

    if unit:has_item(self.name) then 
        p:sendMsg("已经有了|cffFCD830"..self.name.."|r，不可重复")
        -- unit:remove_item(self)
        return false
    end    
    return true
end    

function mt:on_add()
    local item = self
    local water_region = region.create(rect.j_rect 'getwater')
    
    local unit = self.owner
    local p = unit:get_owner()
    
    --小地图任务提示，声音
    unit:play_sound([[Sound\Interface\AutoCastButtonClick1.wav]])
    p:pingMinimap(rect.j_rect 'getwater',1)

    self.trg =  water_region:event '区域-进入' (function(self, unit)
        print(unit,'进入取水区',item.name)
        if unit:has_item(item.name) then 
            p:sendMsg("完成|cffFCD830送水任务|r，奖励|cffFCD8301000|r经验");
            unit:addXp(1000);
            unit:remove_item(item.name);
        end    
    end)
end

function mt:on_drop()
    if self.trg then
        self.trg:remove()
    end
end