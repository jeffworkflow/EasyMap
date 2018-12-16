function print_r (lua_table, indent)

    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print(formatting)
            print_r(v, indent + 1)
            print(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print(formatting..szValue..",")
        end
    end
end


local player = require 'ac.player'
local rect = require 'types.rect'
--print_r(rct)
--print(rct["maxx"])
local region = require 'types.region'
local unitgroup = require 'types.unitgroup'
local exeroom_region = region.create(rect.j_rect 'army_m1')

exeroom_region.unit_count = 0
exeroom_region.unit_group = unitgroup:CreateGroup()
--local tt = unitgroup:CreateGroup()
--local u = player.com[1]:create_unit('萌物A', rct)
--u:set('生命', 1000000)
--u:set('生命上限', 1000000)
--print("group unit add start")
--print(u.handle)
--tt:GroupAddUnit(u)
--tt:GroupRemoveUnit(u)
--print("group unit add end")

exeroom_region:event '区域-进入' (function(self, unit)
    if unit:get_team() ~= 2 then return end
    exeroom_region.unit_group:GroupAddUnit(unit)
    

    --exeroom_region.unit_count = exeroom_region.unit_count + 1
    --print('区域-进入',exeroom_region.unit_group[0],' ',unit:get_name()) 	


    unit:event '单位-死亡' (function(self)
        --exeroom_region.unit_count = exeroom_region.unit_count - 1
        exeroom_region.unit_group:GroupRemoveUnit(unit)
        --print('区域-单位-死亡',exeroom_region.unit_group[0],' ',unit:get_name()) 
        --print(exeroom_region.unit_count) 
        --return exeroom_region.unit_count
    end)
    



end)


exeroom_region:event '区域-离开' (function(self, unit)
    if unit:get_team() ~= 2 then return end
    unit:kill()
--	print(exeroom_region.unit_count) 

end)

local function alive_remove(i,tt)
    if tt == nil then return end
    --print(tt:is_alive())
    if tt:is_alive() ~= true  then 
        --print('移除开始')
        exeroom_region.unit_group:GroupRemoveUnit(tt)
        --print('移除结束')
    end
end	


local product_army = ac.loop(1000,function(t)
    
    --rect['练功房'] = {}
    --print(exeroom_region.unit_group[0])
    exeroom_region.unit_group:ForGroup(alive_remove)
    
    
    if exeroom_region.unit_group[0] <=2 then 
        local t = ac.timer(20,20, function()
            local u = player.com[2]:create_unit('萌物A', rect.j_rect 'army_m1')
            u.reward_gold = 35
			u.reward_exp = 80
            --table.insert(rect['练功房'],u)
        end)
        t:on_timer()
        
    end	
    --print(exeroom_region.unit_count)
end)
product_army:on_timer()	


