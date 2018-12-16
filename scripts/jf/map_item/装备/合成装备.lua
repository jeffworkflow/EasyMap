local streng_item_list = {
    {'新手剑+1','新手剑*1 新手石*1'},
    {'新手剑+2','新手剑+1*1 新手石*1'},
    {'灵宝剑','新手剑*1 新手甲*1 新手戒指*1'}

}
local function streng_item(alltable,unit)

    local u = unit
    local p = unit:get_owner()

    for _, data in ipairs(alltable) do
        local dest_str, source_str = table.unpack(data)
        
        local source_names = {}
        local max_cnt = 0
        for k,v in source_str:gmatch '(%S+)%*(%d+%s-)' do
            source_names[k]=v
            max_cnt = max_cnt +1
        end
        local is_streng_suc =false 
        local i = 0
        for k,v in pairs(source_names) do
            -- print(k)
            i = i + 1
            local it = u:has_item(k)
            if not it then
                is_streng_suc =false 
                -- print('合成失败，没有',k)    
                break
            end     

            local stack = it:get_stack() 
            if stack == 0 or stack == 1 then
                stack = 1
            end    
            --print(it.name,stack,v)

            if stack == tonumber(v) then
                --print('有这个'..it.name..',且数量正确')
                if  i == max_cnt then
                    is_streng_suc = true
                end    
            end
        end    

        -- 如果合成成功，移除材料，添加新物品
        if is_streng_suc then 
            for k,v in pairs(source_names) do
                u:remove_item(k)
            end
            p:sendMsg('合成'..dest_str..'成功')
            local new_item = u:add_item(dest_str)  

            -- 新物品 ， 材料列表 k = 材料名 ，v =数量
            ac.game:event_notify('物品-合成成功',new_item,source_names)  
            
        end    

    end    

end    

ac.game:event '单位-获得物品后' (function(trg, unit, it)

    -- print(it.name,it.removed,it.unique,unit:has_item(it.name))
    --合成装备
    streng_item(streng_item_list,unit)
	

end)
ac.game:event '物品-合成成功' (function(trg, new_item, source_names) 
    local name = new_item:get_name()
    if name =='灵宝剑' then
        print('21')
    end    

end)


